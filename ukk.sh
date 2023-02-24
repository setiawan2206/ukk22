clear
#ip
read -p "Masukan ip : " a1
echo "auto ens33" >> /etc/network/interfaces
echo "iface ens33 inet static" >> /etc/network/interfaces
echo "	address $a1" >> /etc/network/interfaces
read -p "Masukan Netmask: " a2
echo "	netmask $a2" >> /etc/network/interfaces
read -p "Masukan Gateway Mikrotik : " T1
echo "	gateway $T1" >> /etc/network/interfaces
read -p "masukan domain : " a22
echo "nameserver $a1" > /etc/resolv.conf
echo "search $a22" >> /etc/resolv.conf
clear
systemctl restart networking
sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/gi" /etc/sysctl.conf

#DNS
apt-get install bind9 dnsutils -y
sed -i "s/localhost/$a22/gi" /etc/bind/named.conf.default-zones
sed -i "s/db.local/db.web/gi" /etc/bind/named.conf.default-zones
sed -i "s/db.127/db.ip/gi" /etc/bind/named.conf.default-zones
clear
#kebalikan ip address
read -p "Konfigurasi DNS Perlu Memasukan IP address dari Belakang :" b1
sed -i "s/127/$b1/gi" /etc/bind/named.conf.default-zones
cp /etc/bind/db.local /etc/bind/db.web
cp /etc/bind/db.127 /etc/bind/db.ip
sed -i "s/localhost/$a22/gi" /etc/bind/db.web
sed -i "s/127.0.0.1/$a1/gi" /etc/bind/db.web
sed -i "14d" /etc/bind/db.web
echo "www	IN	A	$a1" >> /etc/bind/db.web
echo "webmail	IN	A	$a1" >> /etc/bind/db.web

sed -i "s/localhost/$a22/gi" /etc/bind/db.ip
echo "1.0.0	IN	PTR	www.$a22." >> /etc/bind/db.ip
echo "1.0.0	IN	PTR	webmail.$a22" >> /etc/bind/db.ip
#paling belakang ip address
read -p "Konfigurasi DNS Perlu Memasukan IP address Paling Belakang :" b2
sed -i "s/1.0.0/$b2/gi" /etc/bind/db.ip
systemctl restart bind9.service

#Web Server
apt-get install apache2 lynx -y
echo "<?php
	phpinfo();
?>" > /var/www/html/index.php
systemctl restart apache2.service

#FTP
apt-get install proftpd -y
./ftp.sh
read -p "Masukan nama user untuk FTP : " u1
read -p "Masukan nama Direktory :" d1
mkdir $d1
useradd -d $d1 $u1
passwd $u1

#Webmail
./webmail.sh
cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/webmail.conf
sed -i "s/#ServerName www.example.com/ServerName webmail.$a22/gi" /etc/apache2/sites-available/webmail.conf
sed -i "s/var/usr/gi" /etc/apache2/sites-available/webmail.conf
sed -i "s/www/share/gi" /etc/apache2/sites-available/webmail.conf
sed -i "s/html/roundcube/gi" /etc/apache2/sites-available/webmail.conf
a2ensite webmail.conf
read -p "Webmail membutuhkan user, masukan nama user:" w1
adduser $w1
systemctl restart apache2

#Monitoring
apt-get snmp snmpd -y
sed -i "s/agentaddress  127.0.0.1,[::1]/#agentaddress  127.0.0.1,[::1]/gi"

#systemctl list-unit-files --type=service
