#!/bin/bash

SSLSERV=`netstat -nltp | grep 443 | awk '{print $7'} | cut -d/ -f2 | sed 's/.conf//g' | head -1`

if [[ "$SSLSERV" == "apache2" ]]; then
     if [ ! -f "/etc/apache2/mods-enabled/ssl.conf" ]; then
	ln -s /etc/apache2/mods-available/ssl.conf /etc/apache2/mods-enabled/ssl.conf
	echo 'Create symlink /etc/apache2/mods-enabled/ssl.conf.. Done!'
     fi
     sed -i 's|SSLProtocol all -SSLv2|SSLProtocol All -SSLv2 -SSLv3|g' /etc/apache2/mods-enabled/ssl.conf
     echo 'Fix /etc/apache2/mods-enabled/ssl.conf.. Done!'
     apache2ctl -t 2>&1 > /dev/null
     if [ $? == 0 ]; then
        /etc/init.d/apache2 restart
     else
        echo 'CHECK CONFIG FAILED! NEED CHECK MANUALLY!!'
     fi

elif [[ "$SSLSERV" == "httpd" ]]; then
     echo -e '<IfModule ssl_module>\nSSLProtocol All -SSLv2 -SSLv3\n</IfModule>' > /etc/httpd/conf.d/sslfix.conf
     echo 'Create /etc/httpd/conf.d/sslfix.conf.. Done!'
     apachectl -t 2>&1 > /dev/null
     if [ $? == 0 ]; then
        /etc/init.d/httpd restart
     else
        echo 'CHECK CONFIG FAILED! NEED CHECK MANUALLY!!'
     fi

elif [[ "$SSLSERV" == "nginx" ]]; then
    NGINXVER=`nginx -v 2>&1 | cut -d/ -f2`
    if [ "$NGINXVER" == "0.7.67" ] && [ -f "/etc/debian_version" ]; then
	echo -e 'deb http://nginx.org/packages/debian/ squeeze nginx\n' > /etc/apt/sources.list.d/nginxrepo.list
        apt-get update
        apt-get install nginx && echo 'Nginx updated!'
    fi
    echo 'ssl_protocols TLSv1 TLSv1.1 TLSv1.2;' > /etc/nginx/conf.d/sslfix.conf
    echo 'Create /etc/nginx/conf.d/sslfix.conf.. Done!'
    nginx -t 2>&1 > /dev/null
    if [ $? == 0 ]; then
        /etc/init.d/nginx restart
     else
        echo 'CHECK CONFIG FAILED! NEED CHECK MANUALLY!!'
     fi

elif [[ "$SSLSERV" == "" ]]; then
   echo '443 port not listen.. not listen - not problem!'
fi

