#!/bin/bash
# Author: Sébastien Larivière <sebastien@lariviere.me>
# Simple script to create a centos repository local clone

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
  
  createrepo -v "/mnt/repo/${version}/os"
  createrepo -v "/mnt/repo/${version}/updates"
  createrepo -v "/mnt/repo/${version}/extras"
  createrepo -v "/mnt/repo/${version}/centosplus"
  createrepo -v "/mnt/repo/${version}/contrib"
}

if [ -d /mnt/repo/6.5 ] ; then
    rsync  -avSHP --delete --exclude "local*" --exclude "fasttrack" --exclude "isos" --exclude "repodata" --exclude "i386" centos.mirror.iweb.ca::centos/7/ /mnt/repo/7
    createRepo 6.5
    rsync  -avSHP --delete --exclude "local*" --exclude "xen4" --exclude "SCL" --exclude "cr" --exclude "fasttrack" --exclude "isos" --exclude "repodata" --exclude "i386" centos.mirror.iweb.ca::centos/6.5/ /mnt/repo/6.5
    createRepo 7
    chown -R apache:apache /mnt/repo
    chcon -R --reference=/var/www/html/ /mnt/repo
    /bin/rm -f /mnt/repo/lock
else
    echo "Target directory not present."
fi
