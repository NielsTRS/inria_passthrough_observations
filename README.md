# inria_passthrough_observations

Ce dépôt regroupe des expérimentations de recherche sur le passthrough PCIe de SSD NVMe via VFIO/IOMMU. L’objectif principal est de vérifier si des observables côté hôte peuvent encore être récupérés sur un périphérique PCIe (NVMe) alors qu’il est en passthrough sur une machine virtuelle, et d’en analyser les implications en matière de sécurité.

## Configuration + Création image
### Sur le host
Réservation sur yeti : 
```bash
oarsub -t exotic -t deploy -p yeti -I
kadeploy3 debian-kvm
```

Modification du grub du host, ajouter : 
```
iommu_intel=on iommu=pt iomem=relaxed
```
```bash
sudo update-grub
```

Ajout des modules vfio : 
```bash
sudo nano /etc/modules 

vfio
vfio_iommu_type1
vfio_pci

sudo update-initramfs -u -k all
```

Sur le host :
```bash
sudo apt install lsscsi
```

Pour voir la liste des contrôleurs disques : 
```bash
sudo lsscsi -v

On veut celui ci : nvme1n1 -> 6d:00.0

lspci -nnk -s 6d:00.0
6d:00.0 Non-Volatile memory controller [0108]: Samsung Electronics Co Ltd NVMe SSD Controller 172X [144d:a821] (rev 01)
	Subsystem: Dell Express Flash NVMe PM1725 1.6TB AIC [1028:1fc4]
	Kernel driver in use: nvme
	Kernel modules: nvme

echo "options vfio-pci ids=144d:a821" | sudo tee /etc/modprobe.d/vfio.conf

sudo reboot
```

### Création de la VM :
```bash
sudo qemu-img create -f qcow2 /tmp/debian-12.qcow2 20G 
sudo virsh net-start default
sudo virt-install \
  --name debian12-vm \
  --memory 2048 \
  --vcpus 2 \
  --disk path=/tmp/debian-12.qcow2,format=qcow2 \
  --location 'http://deb.debian.org/debian/dists/bookworm/main/installer-amd64/' \
  --os-variant debian11 \
  --network network=default \
  --graphics none \
  --extra-args 'console=ttyS0,115200n8 serial'
```

### Modification de la VM :

Si la VM tourne : sudo virsh shutdown debian12-vm

```bash
sudo virsh edit debian12-vm
Ajout dans <devices> : 
<hostdev mode='subsystem' type='pci' managed='yes'>
  <source>
    <address domain='0x0000' bus='0x6d' slot='0x00' function='0x0'/>
  </source>
</hostdev>
<iommu model='intel'> <driver aw_bits='48' caching_mode='on'/> </iommu>
```

Démarre la VM :
```bash
sudo virsh net-start default
sudo virsh start debian12-vm
sudo virsh console debian12-vm
```

### Vérification du passthrough, sur le host : 
```bash
lspci -nnk -s 6d:00.0
6d:00.0 Non-Volatile memory controller [0108]: Samsung Electronics Co Ltd NVMe SSD Controller 172X [144d:a821] (rev 01)
	Subsystem: Dell Express Flash NVMe PM1725 1.6TB AIC [1028:1fc4]
	Kernel driver in use: vfio-pci
	Kernel modules: nvme

lsblk
NAME    MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda       8:0    0 447.1G  0 disk 
├─sda1    8:1    0   3.7G  0 part [SWAP]
├─sda2    8:2    0  28.9G  0 part 
├─sda3    8:3    0  31.7G  0 part /
├─sda4    8:4    0   953M  0 part 
└─sda5    8:5    0 381.9G  0 part /tmp
nvme0n1 259:1    0   1.5T  0 disk
```

### Vérification du passthrough dans la VM : 
```bash
lsblk
NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
vda     254:0    0   20G  0 disk 
├─vda1  254:1    0   19G  0 part /
├─vda2  254:2    0    1K  0 part 
└─vda5  254:5    0  975M  0 part [SWAP]
nvme0n1 259:0    0  1.5T  0 disk
```

## Utilisation du passthrough
oarsub -t exotic -t deploy -p yeti -I
kadeploy3 debian-kvm (image disponible sur mon home)

une fois qu’on a un accès sur yeti : 
```bash
sudo update-grub
sudo reboot
sudo cp debian12-vm.xml /etc/libvirt/qemu/
cp debian-12.qcow2 /tmp
sudo virsh net-start default
sudo virsh start debian12-vm
```

sur un nouveau terminal pour yeti : 
sudo virsh console debian12-vm
**login : vm**
**mdp : vm**

dans le host, faire un cat /proc/iomem en sudo : 
```
bf400000-c5ffffff : PCI Bus 0000:6c
  bf400000-bf4fffff : PCI Bus 0000:6d
    bf400000-bf403fff : 0000:6d:00.0
      bf400000-bf403fff : vfio-pci
```

puis lancer un script bash sur le host (scripts/doorbell.sh) : 
```bash
#!/bin/bash
BASE=0xbf400000
DBELL=$((BASE + 0x100C))
while true; do
    VAL=$(sudo busybox devmem $DBELL 32)
    echo "$(date +%s) $VAL"
    sleep 0.1
done
```

et faire un gros dd sur la vm : 
```bash
sudo dd if=/dev/nvme0n1 of=/tmp/testfile bs=1G count=10 oflag=direct
```

## Analyse
Le script (script/doorbell.sh) lit en boucle BAR0 + 0x100C ("Completion Queue Head Doorbell").

Pendant le dd dans la VM :
- La valeur de ce registre change régulièrement.
- Les changements s’arrêtent pile quand le dd se termine.

### Explication

BAR0 (0xbf400000) est la fenêtre MMIO exposée par la puce NVMe.
- Quand le guest écrit dans son BAR0 (via son driver VFIO/IOMMU), l’accès traverse :
  - La traduction d’adresse PCIe → IOMMU
  - Arrive au contrôleur NVMe
- Mais le mapping BAR0 reste visible dans l’espace physique host (/proc/iomem → bf400000-bf403fff).

Donc le même registre matériel est accessible simultanément par :
- Le CPU du guest (via passthrough et IOMMU).
- Le CPU du host (via /dev/mem, devmem, ioremap…).

L'expérience démontre que :
- Les registres NVMe (BAR0) restent accessibles sur le host même en passthrough.
- Le host peut observer en temps réel l’activité du SSD utilisé par la VM.
- Les doorbells s’animent exactement pendant la durée des I/O, ce qui prouve qu'on observe les vraies transactions NVMe du gues