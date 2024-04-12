# Enable the IOMMU
echo "Enabling the IOMMU" >> $logfile
sed -i 's/GRUB_CMDLINE_LINUX="[^"]*/& intel_iommu=on iommu=pt/' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& intel_iommu=on iommu=pt/' /etc/default/grub
update-grub
update-initramfs -u
