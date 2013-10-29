#!/usr/bin/env bash

###############################################################################
#                                                                             #
# This script does the initialization for a blog env on linux(Debian 6)       #
# such as : git, nginx, rvm, ruby, etc                                        #
# https://github.com/Foredoomed/vps-init                                      #
#                                                                             #
# Created: 2013/10/28                                                         #
# Last Updated: 2013/10/28                                                    #
#                                                                             #
###############################################################################


SOURCES_LIST = "/etc/apt/sources.list"
RUBY_VERSION = "2.0.0-p247"
GEMRC = ".gemrc"
LIMITS = "/etc/security/limits.conf"

NGINX_CONF = "https://raw.github.com/Foredoomed/lnmp/master/nginx.conf"
NGINX_OLD = "/etc/nginx/nginx.conf"
NGINX_BAK = "/etc/nginx/nginx.conf.bak"
NGINX_DIR = "/etc/nginx"

# create folder
cd ~
mkdir data
mkdir /data/blog

# update linux
echo "Stopping sendmail..."
service sendmail stop

echo "Stopping httpd..."
service httpd stop

echo "Deleting useless packages..."
sudo apt-get -y purge apache2-* bind9-* xinetd samba-* nscd-* portmap sendmail-* sasl2-bin
sudo apt-get autoremove && apt-get clean

echo "Updating os..."
sudo apt-get update && apt-get upgrade

# install git
echo "Installing git..."
sudo apt-get install git

# install nginx
echo "Installing nginx..."

sudo echo "deb http://nginx.org/packages/debian/ squeeze nginx" >> $SOURCES_LIST
sudo echo "deb-src http://nginx.org/packages/debian/ squeeze nginx" >> $SOURCES_LIST
sudo apt-get update

wget http://nginx.org/keys/nginx_signing.key
sudo apt-key add nginx_signing.key
sudo apt-get install nginx

echo "Fetching nginx config file..."
wget https://raw.github.com/Foredoomed/lnmp/master/nginx.conf
cp $NGINX_OLD $ENGINX_BAK
mv nginx.conf $NGINX_DIR

echo "Starting nginx..."
nginx start

# install rvm and ruby
echo "Installing rvm..."
curl -L https://get.rvm.io | bash -s stable
echo "Installing ruby..."
rvm install $RUBY_VERSION
cd ~
touch $GEMRC
echo "gem: --no-ri --no-rdoc" > $GEMRC

# install required gems
echo "Install Jekyll..."
gem install jekyll

# change locale time
echo "Setting local time to shanghai..."
cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# change open file limit
echo "Setting open file limit..."
sudo echo "* soft nofile 65535" >> LIMITS
sudo echo "* hard nofile 65535" >> LIMITS

# build blog
echo "Fetching blog..."
cd /data/blog
git clone git@github.com:Foredoomed/foredoomed.org.git

echo "Building blog..."
jekyll build

echo "Environment initialization succeeded"
