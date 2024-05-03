# Install and configure Nvidia vGPU manager (AI Enterprise)
# Install AI Enterprise driver / vGPU manager
echo "Installing Nvidia AI Enterprise vGPU Manager" >> $logfile
rmmod nouveau

if grep -q Intel /proc/cpuinfo; then
  sed -i 's/GRUB_CMDLINE_LINUX="[^"]*/& rd.driver.blacklist=nouveau nouveau.modeset=0 intel_iommu=on iommu=pt/' /etc/default/grub
  sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& rd.driver.blacklist=nouveau nouveau.modeset=0 intel_iommu=on iommu=pt' /etc/default/grub
else
  sed -i 's/GRUB_CMDLINE_LINUX="[^"]*/& rd.driver.blacklist=nouveau nouveau.modeset=0/' /etc/default/grub
  sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& rd.driver.blacklist=nouveau nouveau.modeset=0' /etc/default/grub
fi

echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf
echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf
update-grub
update-initramfs -u

wget http://rpm.iik.ntnu.no/nvidia/nvidia-aie-ubuntu.deb -O /tmp/nvidia-aie.deb
apt -y install /tmp/nvidia-aie.deb
rm /tmp/nvidia-aie.deb
