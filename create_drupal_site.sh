#!/bin/bash

if [ -z $1 ]; then
  echo "Usage: create_drupal_site.sh newprojectname"
  exit 0
fi

NAME=${1:0:64}
SQLNAME=${NAME:0:16}

cd ~/htdocs
drush make https://raw.github.com/tomgeekery/compro/master/make/compro.make $NAME

cd $NAME

mkdir sites/default/files
chmod 777 sites/default/files

cp sites/default/default.settings.php sites/default/settings.php
chmod 777 sites/default/settings.php

PASS=${NAME//o/0}
PASS=${PASS//i/1}
PASS=${PASS//e/3}
PASS=${PASS//a/@}

read -s -p "Enter your MYSQL root user password: " SQLPASS
mysql -uroot -p$SQLPASS -e "create database $NAME"
mysql -uroot -p$SQLPASS -e "grant all on $NAME.* to $SQLNAME@localhost identified by '$PASS'"

drush site-install compro --db-url=mysql://$SQLNAME:$PASS@localhost/$NAME --account-name=admin --account-pass=$PASS --site-name=$NAME

APACHE=/etc/apache2/sites-available

sudo touch $APACHE/$NAME

echo Wrote the following to $APACHE/$NAME
echo "<VirtualHost *:80>" | sudo tee -a $APACHE/$NAME
echo "        ServerName "$NAME.dev | sudo tee -a $APACHE/$NAME
echo "        ServerAlias *."$NAME.dev | sudo tee -a $APACHE/$NAME
echo "        DirectoryIndex index.php index.html" | sudo tee -a $APACHE/$NAME
echo "        DocumentRoot /home/"$USER"/htdocs/"$NAME | sudo tee -a $APACHE/$NAME
echo "        <Directory /home/"$USER"/htdocs/"$NAME">" | sudo tee -a $APACHE/$NAME
echo "                Options -Indexes FollowSymLinks" | sudo tee -a $APACHE/$NAME
echo "                AllowOverride All" | sudo tee -a $APACHE/$NAME
echo "                Order allow,deny" | sudo tee -a $APACHE/$NAME
echo "                allow from all" | sudo tee -a $APACHE/$NAME
echo "        </Directory>" | sudo tee -a $APACHE/$NAME
echo "        ErrorLog /var/log/apache2/"$NAME.dev_error.log | sudo tee -a $APACHE/$NAME
echo "        CustomLog /var/log/apache2/"$NAME.dev_access.log combined | sudo tee -a $APACHE/$NAME
echo "</VirtualHost>" | sudo tee -a $APACHE/$NAME

echo Activating site...
sudo a2ensite $NAME
echo Done.

echo Restarting apache2...
sudo service apache2 restart
echo Done.

echo Adding vhost entry to hosts file...
echo 127.0.0.1"       "$NAME.dev | sudo tee -a /etc/hosts
echo Done.

git init
git add .
git commit -m "Initial commit."
git branch -m master stage
git branch qa
git branch prod

echo Visit the new site @ http://$NAME.dev
echo Username: admin
echo Password: $PASS

chmod 444 sites/default/settings.php

exit 0
