#!/bin/bash
SCRIPTPATH=$(pwd)

# Print usage information
usage()
{
cat << EOF
usage: $0 options operand

This script downloads and installs drupal using your server of choice.

OPTIONS:
  -i    The server IP, defaults to 127.0.0.1
  -s    Server, can be ‘apache′ or ‘nginx′, defaults to apache

OPERAND:
  servername

EOF
}

# Initial assignment
IP=
SERVER=

# Get the named flags and assign
while getopts “i:s:” OPTION
do
  case $OPTION in
    i)
      IP=$OPTARG
      ;;
    s)
      SERVER=$OPTARG
      ;;
    ?)
      usage
      exit
      ;;
  esac
done

# Get the operands and assign to numbers
n=1
while [ $# -gt 0 ]; do
  if [ $n -lt $OPTIND ]; then
    let n=$n+1
    shift
  else
    break;
  fi
done

# Validate the inputs
if [[ -z $IP ]]
then
  IP=127.0.0.1
fi

if [[ -z $SERVER ]]
then
  SERVER=apache
fi

if [[ "$SERVER" != "apache" ]] && [[ "$SERVER" != "nginx" ]]
then
  SERVER=apache
fi

# Assignment
NAME=${1:0:64}
SQLNAME=${NAME:0:16}
PASS=${SQLNAME//o/0}
PASS=${PASS//i/1}
PASS=${PASS//e/3}
PASS=${PASS//a/@}

# Bring down all the site profile deps
cd ~/htdocs
drush make https://raw.github.com/tomgeekery/compro/master/make/compro.make $NAME

cd $NAME

mkdir sites/default/files
chmod 777 sites/default/files

cp sites/default/default.settings.php sites/default/settings.php
chmod 777 sites/default/settings.php

read -s -p "Enter your MYSQL root user password: " SQLPASS
mysql -uroot -p$SQLPASS -e "create database $NAME"
mysql -uroot -p$SQLPASS -e "grant all on $NAME.* to $SQLNAME@localhost identified by '$PASS'"

drush site-install compro --db-url=mysql://$SQLNAME:$PASS@localhost/$NAME --account-name=maintenance --account-pass=$PASS --site-name=$NAME

chmod 444 sites/default/settings.php

git init
git add .
git commit -m "Initial commit."
git branch -m master stage
git branch qa
git branch prod

cd $SCRIPTPATH

if [[ "$SERVER" == "nginx" ]]
then
  NGINX=/etc/nginx/sites-available

  # This is where the template part goes
  sed -e 's/\$NAME/'"$NAME"'/g' -e 's/\$USER/'"$USER"'/g' -e 's/\$IP/'"$IP"'/g' < templates/nginx.txt > templates/$NAME
  sudo mv templates/$NAME $NGINX/$NAME

  echo Activating site...
  sudo ln -s $NGINX/$NAME /etc/nginx/sites-enabled/$NAME
  echo Done.

  echo Restarting nginx...
  sudo service nginx restart
  echo Done.
fi

if [[ "$SERVER" == "apache" ]]
then
  APACHE=/etc/apache2/sites-available

  # This is where the template part goes
  sed -e 's/\$NAME/'"$NAME"'/g' -e 's/\$USER/'"$USER"'/g' < templates/apache.txt > templates/$NAME
  sudo mv templates/$NAME $APACHE/$NAME

  echo Activating site...
  sudo a2ensite $NAME
  echo Done.

  echo Restarting apache2...
  sudo service apache2 restart
  echo Done.
fi

echo Adding vhost entry to hosts file...
echo $IP"       "$NAME.local | sudo tee -a /etc/hosts
echo Done.

echo Visit the new site @ http://$NAME.local
echo Username: maintenance
echo Password: $PASS

exit 0
