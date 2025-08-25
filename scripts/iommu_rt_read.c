#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/mm.h>
#include <linux/highmem.h>
#include <linux/io.h>
#include <linux/uaccess.h>

static unsigned long long phys_addr = 0;
module_param(phys_addr, ullong, 0444);
MODULE_PARM_DESC(phys_addr, "Adresse physique à lire");

static int __init read_phys_init(void)
{
    unsigned long pfn;
    struct page *page;
    void *vaddr;
    size_t i;

    if (!phys_addr) {
        pr_err("Veuillez fournir phys_addr=<addr>\n");
        return -EINVAL;
    }

    if (phys_addr & ~PAGE_MASK) {
        pr_warn("L'adresse n'est pas alignée sur une page — arrondi vers le bas\n");
        phys_addr &= PAGE_MASK;
    }

    pfn = phys_addr >> PAGE_SHIFT;

    if (!pfn_valid(pfn)) {
        pr_err("PFN 0x%lx invalide\n", pfn);
        return -EINVAL;
    }

    page = pfn_to_page(pfn);
    if (!page) {
        pr_err("Impossible d'obtenir struct page pour PFN 0x%lx\n", pfn);
        return -ENOMEM;
    }

    vaddr = kmap_local_page(page);
    if (!vaddr) {
        pr_err("Impossible de mapper la page physique\n");
        return -ENOMEM;
    }

    pr_info("Lecture de la page physique 0x%llx\n", phys_addr);

    for (i = 0; i < 64; i += 8) { // On affiche juste les 64 premiers octets
        unsigned long long val;
        val = *(unsigned long long *)(vaddr + i);
        pr_info("%04zx: %016llx\n", i, val);
    }

    kunmap_local(vaddr);
    return 0;
}

static void __exit read_phys_exit(void)
{
    pr_info("Module read_phys_page déchargé\n");
}

module_init(read_phys_init);
module_exit(read_phys_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("ChatGPT");
MODULE_DESCRIPTION("Lecture d'une page physique via kmap_local_page()");
