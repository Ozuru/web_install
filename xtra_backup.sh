#!/bin/bash
cur_dir=$(cd "$(dirname "$0")"; pwd)

database_passwd=$1
backup_dir=$2
yum install git wget
yum install -y gcc gcc-c++  make
 echo $1
 exit;
per_cnt=`yum list | grep percona | wc -l`

if [ $per_cnt -gt 0 ] ;then
    yum install http://www.percona.com/downloads/percona-release/redhat/0.1-3/percona-release-0.1-3.noarch.rpm
fi


per_cnt=`yum list | grep percona | wc -l`


if [ $per_cnt -eq 0 ] ;then
    echo " yum install percona error";
    exit;
fi

if [ ! $backup_dir ] ;then
	echo "no backup dir"
	exit
fi

yum install percona-xtrabackup

innobackupex --user=root --password=$database_passwd $backup_dir

sec_dir=`ls -tcl /home/git/web_install/ | grep '^d' | head -1 | awk '{print $NF}'`

innobackupex --user=root --password=$database_passwd --apply-log $backup_dir/$sec_dir
