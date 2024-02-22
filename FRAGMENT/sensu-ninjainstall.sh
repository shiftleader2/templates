# Ninja install sensu
echo "Ninja installing sensu" >> $logfile
wget http://rpm.iik.ntnu.no/sensu_1.9.0-2_amd64.deb
dpkg -i sensu_1.9.0-2_amd64.deb
rm sensu_1.9.0-2_amd64.deb
