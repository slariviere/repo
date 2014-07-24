#!/bin/bash
# Author: Sébastien Larivière <sebastien@lariviere.me>
# Simple script to create a centos repository local clone

# Varialbes
baseDir=/mnt/repo

# Check if a process is already running 
if [ -f /mnt/repo/lock ]; then
    echo "Updates via rsync already running."
    exit 0
else
    touch /mnt/repo/lock     
fi

# Create repository for all the default repository
createRepo(){
  version=$1
  createrepo -v "${baseDir}/${version}/os"
  createrepo -v "${baseDir}/${version}/updates"
  createrepo -v "${baseDir}/${version}/extras"
  createrepo -v "${baseDir}/${version}/centosplus"
  createrepo -v "${baseDir}/${version}/contrib"
}

# Create the directory if it's not available
checkDirectory(){
    completeDir=${baseDir}/${1}
    if [ ! -d $completeDir ] ; then
	echo "[+] Creating reposiroty directory"
	mkdir $completeDir
    fi
}

# Get the latests packages
checkDirectory 6.5
rsync  -avSHP --delete --exclude "local*" --exclude "xen4" --exclude "SCL" --exclude "cr" --exclude "fasttrack" --exclude "isos" --exclude "repodata" --exclude "i386" centos.mirror.iweb.ca::centos/6.5/ ${baseDir}/6.5
createRepo 6.5

checkDirectory 7
rsync  -avSHP --delete --exclude "local*" --exclude "fasttrack" --exclude "isos" --exclude "repodata" --exclude "i386" centos.mirror.iweb.ca::centos/7/ ${baseDir}/7
createRepo 7

# Fix the files permission
chown -R apache:apache /mnt/repo
chcon -R --reference=/var/www/html/ /mnt/repo

# Unlock the process
rm -f /mnt/repo/lock
