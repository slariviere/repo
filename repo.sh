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
  find ${baseDir}/${1} -mindepth 2 -maxdepth 2 -type d
}

# Create a repository file usable to get the local repository
getRepoDef(){
  sourceDir=${baseDir}/6.5
  hostname=$(hostname -f)
  repoFilename=${baseDir}/CentOS-Base-Local.repo

  if [ ! -f $repoFilename ]; then
     touch $repoFilename
  else
     rm -f $repoFilename
     touch $repoFilename
  fi

  for repoDir in $(find ${sourceDir} -mindepth 1 -maxdepth 1 -type d)
  do
    repoName=$(echo $repoDir | sed 's/.*\///')
    echo "[${repoName}-local]" >>  $repoFilename
    echo "name=Local-\$releasever - ${repoName}" >> $repoFilename
    echo -e "baseurl=http://${hostname}/\$releasever/${repoName}/\$basearch/\n" >> $repoFilename
  done
}

# Get the latests packages
checkDirectory 6.5
rsync  -avSHP --delete --exclude "local*" --exclude "xen4" --exclude "SCL" --exclude "cr" --exclude "fasttrack" --exclude "isos" --exclude "repodata" --exclude "i386" centos.mirror.iweb.ca::centos/6.5/ ${baseDir}/6.5
getDirs 6.5 | xargs -I {} createrepo -v {}
getRepoDef 

checkDirectory 7
rsync  -avSHP --delete --exclude "local*" --exclude "fasttrack" --exclude "isos" --exclude "repodata" --exclude "i386" centos.mirror.iweb.ca::centos/7/ ${baseDir}/7
getDirs 7 | xargs -I {} createrepo -v {}

# Fix the files permission
chown -R apache:apache /mnt/repo
chcon -R --reference=/var/www/html/ /mnt/repo

# Unlock the process
rm -f /mnt/repo/lock
