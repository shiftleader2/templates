# A shell-script which sees which interface currently have an IP; and then 
# creates an OVS-bridge, assigns the discovered IP statically to the bridge, and
# moves the interface that had the IP as an uplink from the bridge.
interface=$(ip -4 address | grep BROADCAST | awk '{ print $2 }' | cut -f 1 -d ':')
ipv4=$(ip -4 address show dev ${interface} | grep inet | awk '{ print $2 }' | cut -f 1 -d '/')
mask4=$(ip -4 address show dev ${interface} | grep inet | awk '{ print $2 }' | cut -f 2 -d '/')
gw4=$(ip -4 route | grep default | grep ${interface} | head -n 1 | awk '{print $3}')
mac=$(ip -4 link show dev ${interface} | grep ether | awk '{ print $2 }')

echo "Installing openvswitch" >> $logfile
apt-get -y install openvswitch-switch

echo "Creating network-setup script" >> $logfile
echo "#!/bin/bash
logfile=$logfile
/bin/echo \"Creating the bridge 'infra'\" >> $logfile
/usr/bin/ovs-vsctl add-br infra
/bin/echo \"Connecting interface $interface to the infra bridge\" >> $logfile
/usr/bin/ovs-vsctl add-port infra $interface
/bin/echo \"Enable the internal port for the infra-bridge\" >> $logfile
/usr/bin/ovs-vsctl set interface infra type=internal
/bin/systemctl disable networkinstall.service
/sbin/reboot " > /opt/vswitchsetup.sh
chmod +x /opt/vswitchsetup.sh

echo "Creating systemd-service for network-setup script" >> $logfile
echo "[Unit]
Description=Network-setup
Requires=openvswitch-switch.service
After=openvswitch-switch.service

[Service]
ExecStart=/opt/vswitchsetup.sh

[Install]
WantedBy=multi-user.target" > /lib/systemd/system/networkinstall.service
systemctl enable networkinstall.service

echo "Configuring networking. Setting IP to ${ipv4}/${mask4} with ${gw4} as GW." >> $logfile
echo "#This file is created by shiftleader when the machine was installed.
network:
  version: 2
  renderer: networkd
  ethernets:
    ${interface}: {}
    infra:
      addresses:
        - ${ipv4}/${mask4}
      routes:
        - to: 0.0.0.0/0
          via: ${gw4}
      nameservers:
        addresses: [129.241.0.200, 129.241.0.201]" > /etc/netplan/01-netcfg.yaml

chmod 0640 /etc/netplan/01-netcfg.yaml
chown root:root /etc/netplan/01-netcfg.yaml
rm /etc/netplan/00-installer-config.yaml

echo "Done with the networking-configuration" >> $logfile
