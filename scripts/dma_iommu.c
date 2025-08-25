#include <linux/module.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/kprobes.h>
#include <linux/ktime.h>
#include <linux/sched.h>
#include <linux/scatterlist.h>
#include <linux/dma-mapping.h>
#include <linux/kallsyms.h>
#include <linux/mm.h>
#include <linux/sched.h>
#include <linux/highmem.h>
#include <linux/mm_types.h>
#include <linux/pagemap.h>
#include <asm/pgtable.h>
#include <linux/pci.h>
#include <linux/iommu.h>
#include <asm/io.h>
#include <linux/mmu_notifier.h>
#include <linux/dma-direct.h>


MODULE_LICENSE("GPL");
MODULE_AUTHOR("You");
MODULE_DESCRIPTION("IOMMU tracing");

/*
 * Intel VT-d specific structures
 * From https://elixir.bootlin.com/linux/v6.15.4/source/drivers/iommu/intel/iommu.h#L601
 */
struct dma_pte {
    u64 val;
};

struct iommu_hwpt_vtd_s1 {
    __aligned_u64 flags;
    __aligned_u64 pgtbl_addr;
    __u32 addr_width;
    __u32 __reserved;
};

// struct dmar_domain {
// 	int	nid;			/* node id */
// 	struct xarray iommu_array;	/* Attached IOMMU array */

// 	u8 has_iotlb_device: 1;
// 	u8 iommu_coherency: 1;		/* indicate coherency of iommu access */
// 	u8 force_snooping : 1;		/* Create IOPTEs with snoop control */
// 	u8 set_pte_snp:1;

// 	spinlock_t lock;		/* Protect device tracking lists */
// 	struct list_head devices;	/* all devices' list */

// 	struct dma_pte	*pgd;		/* virtual address */
// 	int		gaw;		/* max guest address width */

// 	/* adjusted guest address width, 0 is level 2 30-bit */
// 	int		agaw;

// 	int		flags;		/* flags to find out type of domain */
// 	int		iommu_superpage;/* Level of superpages supported:
// 					   0 == 4KiB (no superpages), 1 == 2MiB,
// 					   2 == 1GiB, 3 == 512GiB, 4 == 1TiB */
// 	u64		max_addr;	/* maximum mapped address */

// 	struct iommu_domain domain;	/* generic domain data structure for
// 					   iommu core */
// };

struct dmar_domain {
    int    nid;            /* node id */
    struct xarray iommu_array;    /* Attached IOMMU array */

    u8 iommu_coherency: 1;        /* indicate coherency of iommu access */
    u8 force_snooping : 1;        /* Create IOPTEs with snoop control */
    u8 set_pte_snp:1;
    u8 use_first_level:1;        /* DMA translation for the domain goes
                     * through the first level page table,
                     * otherwise, goes through the second
                     * level.
                     */
    u8 dirty_tracking:1;        /* Dirty tracking is enabled */
    u8 nested_parent:1;        /* Has other domains nested on it */
    u8 has_mappings:1;        /* Has mappings configured through
                     * iommu_map() interface.
                     */

    spinlock_t lock;        /* Protect device tracking lists */
    struct list_head devices;    /* all devices' list */
    struct list_head dev_pasids;    /* all attached pasids */

    spinlock_t cache_lock;        /* Protect the cache tag list */
    struct list_head cache_tags;    /* Cache tag list */
    struct qi_batch *qi_batch;    /* Batched QI descriptors */

    int        iommu_superpage;/* Level of superpages supported:
                       0 == 4KiB (no superpages), 1 == 2MiB,
                       2 == 1GiB, 3 == 512GiB, 4 == 1TiB */
    union {
        /* DMA remapping domain */
        struct {
            /* virtual address */
            struct dma_pte    *pgd;
            /* max guest address width */
            int        gaw;
            /*
             * adjusted guest address width:
             *   0: level 2 30-bit
             *   1: level 3 39-bit
             *   2: level 4 48-bit
             *   3: level 5 57-bit
             */
            int        agaw;
            /* maximum mapped address */
            u64        max_addr;
            /* Protect the s1_domains list */
            spinlock_t    s1_lock;
            /* Track s1_domains nested on this domain */
            struct list_head s1_domains;
        };

        /* Nested user domain */
        struct {
            /* parent page table which the user domain is nested on */
            struct dmar_domain *s2_domain;
            /* page table attributes */
            struct iommu_hwpt_vtd_s1 s1_cfg;
            /* link to parent domain siblings */
            struct list_head s2_link;
        };

        /* SVA domain */
        struct {
            struct mmu_notifier notifier;
        };
    };

    struct iommu_domain domain;    /* generic domain data structure for
                       iommu core */
};

#define VTD_PAGE_SHIFT        (12)
#define VTD_PAGE_SIZE        (1UL << VTD_PAGE_SHIFT)
#define VTD_PAGE_MASK        (((u64)-1) << VTD_PAGE_SHIFT)
#define DMA_PTE_LARGE_PAGE  (1ULL << 7)

static inline u64 dma_pte_addr(struct dma_pte *pte)
{
    return pte->val & VTD_PAGE_MASK;
}
static inline bool dma_pte_present(struct dma_pte *pte)
{
    return (pte->val & 3) != 0;
}

static inline bool dma_pte_large(struct dma_pte *pte)
{
    return dma_pte_present(pte) && (pte->val & DMA_PTE_LARGE_PAGE);
}

static void walk_iommu_pagetable(struct dmar_domain *domain)
{
    struct dma_pte *pgd = domain->pgd; // Level 4
    int l4, l3, l2, l1;
    dma_addr_t iova = 0;

    for (l4 = 0; l4 < PTRS_PER_PTE; ++l4) {
        struct dma_pte *pmd_l3 = phys_to_virt(dma_pte_addr(&pgd[l4]));
        if (!dma_pte_present(&pgd[l4]))
            continue;

        for (l3 = 0; l3 < PTRS_PER_PTE; ++l3) {
            struct dma_pte *pmd_l2 = phys_to_virt(dma_pte_addr(&pmd_l3[l3]));
            if (!dma_pte_present(&pmd_l3[l3]))
                continue;

            for (l2 = 0; l2 < PTRS_PER_PTE; ++l2) {

                // 2 MiB page
                if (dma_pte_large(&pmd_l2[l2])) {
                    iova = (((u64)l4 << 39) |
                            ((u64)l3 << 30) |
                            ((u64)l2 << 21));

                    phys_addr_t pa = dma_pte_addr(&pmd_l2[l2]);
                    pr_info("IOVA 0x%llx -> PA 0x%llx (2MiB)\n",
                            iova, (u64)pa);
                    continue;   /* ne pas descendre en L1 */
                }
                // 2 MiB page 

                struct dma_pte *pmd_l1 = phys_to_virt(dma_pte_addr(&pmd_l2[l2]));
                if (!dma_pte_present(&pmd_l2[l2]))
                    continue;

                for (l1 = 0; l1 < PTRS_PER_PTE; ++l1) {
                    if (!dma_pte_present(&pmd_l1[l1]))
                        continue;

                    iova = (((u64)l4 << 39) |
                            ((u64)l3 << 30) |
                            ((u64)l2 << 21) |
                            ((u64)l1 << 12));

                    phys_addr_t pa = dma_pte_addr(&pmd_l1[l1]);
                    pr_info("IOVA: 0x%llx -> PA: 0x%llx\n", iova, (u64)pa);
                }
            }
        }
    }
}

// ----------- Init & Register -------------
static int __init dma_kp_init(void)
{
    struct pci_dev *pdev = NULL;

    pr_info("Intel IOMMU page table walker loaded\n");

    for_each_pci_dev(pdev) {
        struct device *dev = &pdev->dev;
        struct iommu_domain *domain;
        struct dmar_domain *dmar_domain;
        const struct dma_map_ops *ops = get_dma_ops(dev);

        pr_info("Walking domain for device %s, ops = %ps \n", dev_name(dev), ops);

        domain = iommu_get_domain_for_dev(dev);
        if (!domain){
            pr_info("No domain found for device %s\n", dev_name(dev));
            continue;
        }

        dmar_domain = container_of(domain, struct dmar_domain, domain);
        if (!dmar_domain->pgd){
            pr_info("No pgd found for device %s\n", dev_name(dev));
            continue;
        }

        // pr_info("use_first_level: %d, nested_parent: %d\n",
        //         dmar_domain->use_first_level,
        //         dmar_domain->nested_parent);
        walk_iommu_pagetable(dmar_domain);
    }
    return 0;
}

static void __exit dma_kp_exit(void)
{
    return;
    pr_info("DMA module unloaded\n");
}

module_init(dma_kp_init);
module_exit(dma_kp_exit);
