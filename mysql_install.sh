#!/bin/bash

user=mysql
group=mysql

#create group if not exists
egrep "^$group" /etc/group >& /dev/null
if [ $? -ne 0 ]
then
    groupadd $group
fi

#create user if not exists
egrep "^$user" /etc/passwd >& /dev/null
if [ $? -ne 0 ]
then
    useradd -g $group $user
fi

cur_dir=$(cd "$(dirname "$0")"; pwd)

data_dir=/htdata/mysql
src_dir=/usr/local/src
bin_dir=/usr/local/mysql
yum install git wget
yum install -y gcc gcc-c++  make
yum install –y openssl openssl-devel ncurses ncurses-devel cmake
 

cd $src_dir 

if [ ! -f $src_dir/mysql-5.5.41.tar.gz ] ; then 
	wget https://downloads.mariadb.com/archives/mysql-5.5/mysql-5.5.41.tar.gz
fi

if [ ! -d $src_dir/mysql-5.5.41 ] ; then
	tar	-zxvf mysql-5.5.41.tar.gz
fi

if [ ! -e $bin_dir/bin/mysqld_safe ] ; then
	cd $src_dir/mysql-5.5.41
	cmake . -DCMAKE_INSTALL_PREFIX=$bin_dir -DMYSQL_DATADIR=$data_dir
	make && make install
fi

if [ ! -e $bin_dir/bin/mysqld_safe ] ; then
	echo "fail to install mysql"
	exit;
fi
 
cd $data_dir
chown -R mysql $data_dir
chgrp -R mysql .


cp $cur_dir/init_sh/mysqld /etc/init.d/
cp $cur_dir/sys_config/my.cnf /etc/
chown root.root /etc/rc.d/init.d/mysqld 


cd /usr/local/mysql 
chown -R root .  
scripts/mysql_install_db --user=mysql
$bin_dir/bin/mysqld_safe --user=mysql

$bin_dir/bin/mysqladmin -u root password '123456'  
 
chkconfig --add mysqld   
chkconfig --level 3 mysqld on
chkconfig --level 5 mysqld on 

echo 'export PATH=$PATH:/usr/local/mysql/bin' >> /etc/profile
source /etc/profile


mysql -u root -p -e "SET PASSWORD FOR 'root'@'localhost'=PASSWORD('123456');"
