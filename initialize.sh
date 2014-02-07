#!/usr/bin/env bash

###############################################################################
#                                                                             #
# This script does the initialization for a blog env on linux(Debian 7)       #
# such as : git, nginx, rvm, ruby, etc                                        #
# https://github.com/Foredoomed/blog-env-init                                 #
#                                                                             #
# Created: 2013/10/28                                                         #
# Last Updated: 2013/10/28                                                    #
#                                                                             #
###############################################################################


DIR="/data/blog"
FILES="/data/blog/*"
SOURCES_LIST="/etc/apt/sources.list"
RUBY_VERSION="1.9.3-p484"
GEMRC=".gemrc"
LIMITS="/etc/security/limits.conf"

NGINX_CONF="https://raw.github.com/Foredoomed/lnmp/master/nginx.conf"
NGINX_OLD="/etc/nginx/nginx.conf"
NGINX_BAK="/etc/nginx/nginx.conf.bak"
NGINX_DIR="/etc/nginx/"

echo -e "\n***Initialization started***"

# create folder
echo -e "\nCreating folder..."
cd ~
if [ -d "$DIR" ]; then
  sudo rm -rf $FILES
else
  sudo mkdir -p "$DIR"
fi

# update linux
echo -e "\nStopping sendmail..."
service sendmail stop

echo -e "\nStopping httpd..."
service httpd stop

echo -e "\nDeleting useless packages..."
sudo apt-get -y purge apache2-* bind9-* xinetd samba-* nscd-* portmap sendmail-* sasl2-bin

sudo sh -c 'echo "deb http://nginx.org/packages/debian/ wheezy nginx" >> $SOURCES_LIST'
sudo sh -c 'echo "deb-src http://nginx.org/packages/debian/ wheezy nginx"" >> $SOURCES_LIST'

sudo apt-get autoremove && sudo apt-get clean

echo -e "\nUpdating os..."
sudo apt-get update && sudo apt-get -y upgrade

# install git
echo -e "\nInstalling git..."
sudo apt-get -y install git

# install nginx
echo -e "\nInstalling nginx..."

wget http://nginx.org/keys/nginx_signing.key
sudo apt-key add nginx_signing.key
sudo apt-get install nginx

echo -e "\nFetching nginx config file..."
wget https://raw.github.com/Foredoomed/lnmp/master/nginx.conf
sudo /bin/cp -f $NGINX_OLD $NGINX_BAK
sudo mv nginx.conf $NGINX_DIR

echo -e "\nStarting nginx..."
sudo service nginx start

# install rvm and ruby
echo -e "\nInstalling rvm..."
sudo apt-get -y install curl
curl -L https://get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh

echo -e "\nInstalling ruby..."
rvm install $RUBY_VERSION
cd ~
touch $GEMRC
echo "gem: --no-ri --no-rdoc" > $GEMRC

# install required gems
echo -e "\nInstalling Jekyll..."
sudo gem install jekyll

# change locale time
echo -e "\nSetting local time to shanghai..."
sudo /bin/cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# change open file limit
echo -e "\nSetting open file limit..."
sudo echo "* soft nofile 65535" >> LIMITS
sudo echo "* hard nofile 65535" >> LIMITS

# build blog
echo -e "\nFetching blog..."
cd $DIR
git clone https://github.com/Foredoomed/foredoomed.org.git

echo -e "\nBuilding blog..."
jekyll build

echo -e "\n***Initialization completed***"
