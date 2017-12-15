#!/usr/bin/env bash

###############################################################################
#                                                                             #
# This script does the initialization for a blog env on linux(Debian 7)       #
# such as : git, nginx, rvm, ruby, etc                                        #
# https://github.com/Foredoomed/blog-env-init                                 #
#                                                                             #
# Created: 2013/10/28                                                         #
# Last Updated: 2014/6/12                                                     #
#                                                                             #
###############################################################################


DIR="/home"
SOURCES_LIST="/etc/apt/sources.list"
RUBY_VERSION="2.1.2"
GEMRC=".gemrc"
LIMITS="/etc/security/limits.conf"

NGINX_CONF="https://raw.github.com/Foredoomed/lnmp/master/nginx.conf"
NGINX_OLD="/etc/nginx/nginx.conf"
NGINX_BAK="/etc/nginx/nginx.conf.bak"
NGINX_DIR="/etc/nginx/"

echo -e "\n***Initialization started***"

# update system package
sudo apt-get update
sudo apt-get -y upgrade

# create folder
#echo -e "\nCreating folder..."
#cd ~
#if [ -d "$DIR" ]; then
#  sudo rm -rf $DIR/*
#else
#  sudo mkdir -p "$DIR"
#fi

# update linux
echo -e "\nStopping sendmail..."
service sendmail stop

echo -e "\nStopping httpd..."
service httpd stop

echo -e "\nDeleting useless packages..."
sudo apt-get -y purge apache2-* bind9-* xinetd samba-* nscd-* portmap sendmail-* sasl2-bin
sudo apt-get autoremove && sudo apt-get clean

echo -e "\nUpdating os..."
sudo apt-get update && sudo apt-get -y upgrade

# install git
echo -e "\nInstalling git..."
sudo apt-get -y install git

# install nginx
echo -e "\nInstalling nginx..."
#wget http://nginx.org/keys/nginx_signing.key
#sudo apt-key add nginx_signing.key
#echo "deb http://nginx.org/packages/debian/ wheezy nginx" >> $SOURCES_LIST
#echo "deb-src http://nginx.org/packages/debian/ wheezy nginx" >> $SOURCES_LIST
#sudo apt-get update
sudo apt-get -y install nginx
#rm -rf nginx_signing.key

echo -e "\nStarting nginx..."
wget https://raw.github.com/Foredoomed/lnmp/master/nginx.conf
sudo /bin/cp -f $NGINX_OLD $NGINX_BAK
sudo mv nginx.conf $NGINX_DIR
sudo service nginx start

# install rbenv and ruby
#echo -e "\nInstalling rbenv..."
#git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
#echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
#echo 'eval "$(rbenv init -)"' >> ~/.bashrc
#source ~/.bashrc
#sudo apt-get -y install curl
#curl https://raw.githubusercontent.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash
#echo "export RBENV_ROOT=\"\${HOME}/.rbenv\"
#if [ -d \"\${RBENV_ROOT}\" ]; then
#  export PATH=\"\${RBENV_ROOT}/bin:\${PATH}\"
#  eval \"\$(rbenv init -)\"
#fi" >> ~/.bashrc
#source ~/.bashrc

# install ruby-build:
#pushd /tmp
#  git clone git://github.com/sstephenson/ruby-build.git
#  cd ruby-build
#  ./install.sh
#popd

# install rvm
sudo apt-get -y install curl
echo -e "\nInstalling rvm"
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh

echo -e "\nInstalling ruby..."
touch ~/$GEMRC
echo "gem: --no-ri --no-rdoc" > $GEMRC
rvm install 1.9.3-p547

# install required gems
echo -e "\nInstalling bundler..."
gem install bundler

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
