apt-get install mariadb-server -y
mysql -e "CREATE DATABASE roundcube;"
mysql -e "GRANT ALL PRIVILEGES ON roundcube.* TO roundcube@'localhost' IDENTIFIED BY 'password';"
mysql -e "FLUSH PRIVILEGES;"
clear
echo "Pembuatan Database Roundcube Selesai!!"
