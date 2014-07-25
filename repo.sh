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

# Create the directory if it's not available
checkDirectory(){
    completeDir=${baseDir}/${1}
    if [ ! -d $completeDir ] ; then
	echo "[+] Creating reposiroty directory"
	mkdir $completeDir
    fi
}

# Get each directory 
getDirs(){
  find ${baseDir}/${1} -maxdepth 1 -type d | egrep -v "^${baseDir}/${1}$"
}

# Get the latests packages
checkDirectory 6.5
rsync  -avSHP --delete --exclude "local*" --exclude "xen4" --exclude "SCL" --exclude "cr" --exclude "fasttrack" --exclude "isos" --exclude "repodata" --exclude "i386" centos.mirror.iweb.ca::centos/6.5/ ${baseDir}/6.5
getDirs 6.5 | xargs -I {} createrepo -v {}

checkDirectory 7
rsync  -avSHP --delete --exclude "local*" --exclude "fasttrack" --exclude "isos" --exclude "repodata" --exclude "i386" centos.mirror.iweb.ca::centos/7/ ${baseDir}/7
getDirs 7 | xargs createrepo -v

# Fix the files permission
chown -R apache:apache /mnt/repo
chcon -R --reference=/var/www/html/ /mnt/repo

# Unlock the process
rm -f /mnt/repo/lock
