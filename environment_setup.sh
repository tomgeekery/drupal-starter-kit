#!/bin/bash

# Script is intended to take a fresh install of Ubuntu 12.04 and prepare
# it for local Drupal development.

# Update all packages.
sudo apt-get update
sudo apt-get upgrade -y

# Install lamp stack.
sudo apt-get install lamp-server^ -y

# Install extra php and misc packages.
sudo apt-get install php5-gd php-pear php5-xdebug make git phpmyadmin -y
sudo sh -c "echo 'xdebug.remote_enable=1' >> /etc/php5/conf.d/xdebug.ini"
sudo sh -c "echo 'xdebug.remote_handler=dbgp' >> /etc/php5/conf.d/xdebug.ini"
sudo sh -c "echo 'xdebug.remote_mode=req' >> /etc/php5/conf.d/xdebug.ini"
sudo sh -c "echo 'xdebug.remote_host=127.0.0.1' >> /etc/php5/conf.d/xdebug.ini"
sudo sh -c "echo 'xdebug.remote_port=9000' >> /etc/php5/conf.d/xdebug.ini"

# Upload progress
sudo pecl install uploadprogress
sudo sh -c "echo 'extension = uploadprogress.so' > /etc/php5/apache2/conf.d/uploadprogress.ini"

# Drush
sudo pear channel-discover pear.drush.org
sudo pear install drush/drush
wget http://download.pear.php.net/package/Console_Table-1.1.3.tgz
tar xvfz Console_Table-1.1.3.tgz
sudo mv Console_Table-1.1.3 /usr/share/php/drush/lib
rm Console_Table-1.1.3.tgz
rm package.xml

# Enable rewrite
sudo a2enmod rewrite

# Setup htdocs in home folder
mkdir /home/$USER/websites
sudo ln -s /home/$USER/websites /var/www/$USER

# Setup git information.
echo -n "Enter your name for git commits: "
read GIT_NAME
echo -n "Enter your email for git commits: "
read GIT_EMAIL
git config --global user.name "'"$GIT_NAME"'"
git config --global user.email $GIT_EMAIL
cp .gitignore_global ~/
git config --global core.excludesfile ~/.gitignore_global

# Restart apache.
sudo service apache2 restart

# Install Geany for basic code editing.
sudo apt-get install geany geany-plugins -y

# Display message with instructions what to do next.
echo ""
echo "Congrats!  Your Ubuntu install is ready for Drupal development."
echo "Please run './create_drupal_site.sh sitename'.  Replace"
echo "sitename with the name you wish to call your new Drupal site."
echo ""
echo "Enjoy!"
