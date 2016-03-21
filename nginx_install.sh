#!/bin/bash

src_dir=/usr/local/src
cur_dir=$(cd "$(dirname "$0")"; pwd)
yum install git wget
yum -y install gcc gcc-c++  make automake autoconf 
yum -y install  pcre pcre-devel
yum -y install openssl openssl-devel

# command -v git >/dev/null 2>&1 || { yum install  git}
# command -v wget >/dev/null 2>&1 || { yum install  wget}
 
cd $src_dir

if [ ! -f $src_dir/LuaJIT-2.0.3.tar.gz ] ; then
	`wget  http://luajit.org/download/LuaJIT-2.0.3.tar.gz`
fi

if [ ! -d $src_dir/LuaJIT-2.0.3 ] ; then
	tar -zxvf LuaJIT-2.0.3.tar.gz
fi 

if [ ! -d /usr/local/luajit ] ; then
	cd $src_dir/LuaJIT-2.0.3
	make &&  make install PREFIX=/usr/local/luajit
fi 
cd $src_dir
  
export LUAJIT_INC=/usr/local/luajit/include/luajit-2.0/
export LUAJIT_LIB=/usr/local/luajit/lib



#
cd $src_dir

if [ ! -d $src_dir/ngx_devel_kit  ] ; then
	git clone    https://github.com/simpl/ngx_devel_kit 
fi 
if [ ! -d $src_dir/echo-nginx-module    ] ; then
	git clone    https://github.com/agentzh/echo-nginx-module 
fi 
 
if [ ! -d $src_dir/lua-nginx-module   ] ; then
	git clone   https://github.com/chaoslawful/lua-nginx-module
fi 
 
#git clone    https://github.com/yaoweibin/nginx_tcp_proxy_module
 
cd $src_dir


if [ ! -e $src_dir/nginx-1.9.9.tar.gz ] ; then
	wget http://nginx.org/download/nginx-1.9.9.tar.gz
fi

if [ ! -d $src_dir/nginx-1.9.9 ] ; then
	tar	-zxvf nginx-1.9.9.tar.gz
fi 

cd $src_dir/nginx-1.9.9
#patch -p1 < /usr/local/src/nginx_tcp_proxy_module/tcp.patch


./configure --sbin-path=/usr/local/nginx/nginx \
--conf-path=/usr/local/nginx/nginx.conf \
--pid-path=/usr/local/nginx/nginx.pid \
--add-module=/usr/local/src/ngx_devel_kit \
--add-module=/usr/local/src/echo-nginx-module \
--add-module=/usr/local/src/lua-nginx-module \
--with-http_ssl_module \
--with-http_stub_status_module \
--with-http_sub_module

make &&  make install

if [ ! -e /usr/local/nginx/nginx ] ; then
	echo ''
	
	exit
fi


ln -s /usr/local/luajit/lib/libluajit-5.1.so /lib64/libluajit-5.1.so.2

cd `dirname $0`

cp $cur_dir/init_sh/nginx /etc/init.d/

echo "alias nginxlog='cd /usr/local/nginx/logs'" >> /root/.bashrc 
source /root/.bashrc 
chkconfig nginx on;