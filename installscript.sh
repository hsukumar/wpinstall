#!/bin/bash
# The following script is Copyright Dr. Hari Sukumar hari@itpros.in
clear
echo -n "Enter the MySQL root password: "
read -s rootpw
echo -n "Enter database name: "
read dbname
echo -n "Enter database username: "
read dbuser
echo -n "Enter database user password: "
read -s dbpass

db="create database $dbname;GRANT ALL PRIVILEGES ON $dbname.* TO $dbuser@localhost IDENTIFIED BY '$dbpass';FLUSH PRIVILEGES;"
mysql -u root -p$rootpw -e "$db"

if [ $? != "0" ]; then
 echo "[Error]: Database creation failed"
 exit 1
else
 echo "------------------------------------------"
 echo " Database has been created successfully "
 echo "------------------------------------------"
 echo " DB Info: "
 echo ""
 echo " DB Name: $dbname"
 echo " DB User: $dbuser"
 echo " DB Pass: $dbpass"
 echo ""
 echo "------------------------------------------"
fi

echo -n "Enter the website Name including .com or .net or .info or .org: "
read websitename

cd /etc/httpd/vhost
touch $websitename.conf

# The following will create a .conf file

echo "<VirtualHost *:80>
ServerAdmin <emaiaddress>
DocumentRoot /var/www/html/$websitename/web
ServerName $websitename
ServerAlias www.$websitename
ScriptAlias /cgi-bin/ /var/www/html/$websitename/cgi-bin/
ErrorLog /var/www/html/$websitename/logs/error_log
TransferLog /var/www/html/$websitename/logs/access_log
Options FollowSymLinks
Options +Includes
#AllowOverride All
</VirtualHost>" >> $websitename.conf
cd /var/www/html/
mkdir $websitename
cd  $websitename
mkdir logs private cgi-bin web
cd web
mkdir stats
echo "run install? (y/n)"
read -e run
if [ "$run" == n ] ; then
exit
else
echo "====================================================="
echo "An awesome robot is now installing WordPress for you."
echo "====================================================="
#download wordpress
curl -O https://wordpress.org/latest.tar.gz
#unzip wordpress
tar -zxvf latest.tar.gz
#change dir to wordpress
cd wordpress
#copy file to parent dir
cp -rf . ..
#move back to parent dir
cd ..
#remove files from wordpress folder
rm -R wordpress
#create wp config
cp wp-config-sample.php wp-config.php
#set database details with perl find and replace
perl -pi -e "s/database_name_here/$dbname/g" wp-config.php
perl -pi -e "s/username_here/$dbuser/g" wp-config.php
perl -pi -e "s/password_here/$dbpass/g" wp-config.php
#set WP salts
perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' wp-config.php

#create uploads folder and set permissions
mkdir wp-content/uploads
chmod 775 wp-content/uploads
echo "Cleaning..."
#remove zip file
rm latest.tar.gz
echo "========================="
echo "Installation is complete."
echo "========================="
fi
