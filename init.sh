#!/usr/bin/env bash

###############################################################################
#                                                                             #
# This script does the initialization for a blog env on linux(Debian 7)       #
# such as : git, nginx, rvm, ruby, etc                                        #
# https://github.com/Foredoomed/blog-env-init                                 #
#                                                                             #
# Created: 2013/10/28                                                         #
# Last Updated: 2014/6/7                                                      #
#                                                                             #
###############################################################################


DIR="/data"
SOURCES_LIST="/etc/apt/sources.list"
RUBY_VERSION="1.9.3-p547"
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
  sudo rm -rf $DIR/*
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
sudo apt-get autoremove && sudo apt-get clean

echo -e "\nUpdating os..."
sudo sh -c 'echo "deb http://nginx.org/packages/debian/ wheezy nginx" >> $SOURCES_LIST'
sudo sh -c 'echo "deb-src http://nginx.org/packages/debian/ wheezy nginx" >> $SOURCES_LIST'

sudo sh -c 'echo "deb http://security.debian.org/ wheezy/updates main" >> $SOURCES_LIST'
sudo sh -c 'echo "deb-src http://security.debian.org/ wheezy/updates main" >> $SOURCES_LIST'

echo "Package: *
Pin: release a=security
Pin-Priority: 1001" >> /ect/apt/preferences
sudo apt-get update && sudo apt-get -y dist-upgrade

# install git
echo -e "\nInstalling git..."
sudo apt-get -y install git

# install nginx
echo -e "\nInstalling nginx..."
wget http://nginx.org/keys/nginx_signing.key
sudo apt-key add nginx_signing.key
sudo apt-get -y install nginx
rm -rf nginx_signing.key

echo -e "\nFetching nginx config file..."
wget https://raw.github.com/Foredoomed/lnmp/master/nginx.conf
sudo /bin/cp -f $NGINX_OLD $NGINX_BAK
sudo mv nginx.conf $NGINX_DIR

echo -e "\nStarting nginx..."
sudo service nginx start

# install rbenv and ruby
echo -e "\nInstalling rbenv..."
#git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
#echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
#echo 'eval "$(rbenv init -)"' >> ~/.bashrc
#source ~/.bashrc
sudo apt-get -y install curl
curl https://raw.githubusercontent.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash
echo "export RBENV_ROOT=\"\${HOME}/.rbenv\"
if [ -d \"\${RBENV_ROOT}\" ]; then
  export PATH=\"\${RBENV_ROOT}/bin:\${PATH}\"
  eval \"\$(rbenv init -)\"
fi" >> ~/.bashrc
source ~/.bashrc

# install ruby-build:
pushd /tmp
  git clone git://github.com/sstephenson/ruby-build.git
  cd ruby-build
  ./install.sh
popd

echo -e "\nInstalling ruby..."
sudo apt-get -y install --only-upgrade openssl
sudo apt-get -y install --only-upgrade libssl1.0.0
sudo apt-get -y install autoconf bison build-essential libssl-dev libyaml-dev libreadline6 libreadline6-dev zlib1g zlib1g-dev
touch ~/$GEMRC
echo "gem: --no-ri --no-rdoc" > $GEMRC
rbenv install $RUBY_VERSION
rbenv rehash
rbenv global $RUBY_VERSION

# install required gems
echo -e "\nInstalling Bundler..."
gem install bundler
rbenv rehash

# change locale time
echo -e "\nSetting local time to shanghai..."
sudo /bin/cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# change open file limit
echo -e "\nSetting open file limit..."
sudo echo "* soft nofile 65535" >> LIMITS
sudo echo "* hard nofile 65535" >> LIMITS

# build blog
echo -e "\nFetching blog..."
cd /data
git clone https://github.com/Foredoomed/foredoomed.org.git blog
cd blog
bundle install

echo -e "\nBuilding blog..."
jekyll build

echo -e "\n***Initialization completed***"
