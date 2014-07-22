#!/bin/bash
if [ -f /mnt/repo/lock ]; then
    echo "Updates via rsync already running."
    exit 0
fi
if [ -d /mnt/repo/6.5 ] ; then
    touch /mnt/repo/lock     
    rsync  -avSHP --delete --exclude "local*" --exclude "isos" --exclude "repodata" --exclude "i386" centos.mirror.iweb.ca::centos/7/ /mnt/repo/7
    rsync  -avSHP --delete --exclude "local*" --exclude "isos" --exclude "repodata" --exclude "i386" centos.mirror.iweb.ca::centos/6.5/ /mnt/repo/6.5
    createrepo -v /mnt/repo/6.5
    chown -R apache:apache /mnt/repo/6.5
    chcon -R --reference=/var/www/html/ /mnt/repo
    createrepo -v /mnt/repo/7
    chown -R apache:apache /mnt/repo/7
    chcon -R --reference=/var/www/html/ /mnt/repo
    /bin/rm -f /mnt/repo/lock
else
    echo "Target directory not present."
fi
