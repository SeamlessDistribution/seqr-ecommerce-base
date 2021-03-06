FROM ubuntu:14.04
MAINTAINER Grzegorz Wodo <grzegorz.wodo@gmail.com>

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list && apt-get update && apt-get -y dist-upgrade
RUN echo "deb http://ppa.launchpad.net/ondrej/php5-5.6/ubuntu trusty main" >> /etc/apt/sources.list && apt-key adv --keyserver keyserver.ubuntu.com --recv-key E5267A6C && apt-get update

# Update
RUN apt-get update
RUN apt-get -y upgrade

# Basic Requirements
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server mysql-client apache2 libapache2-mod-php5 php5-mysql php-apc python-setuptools curl git unzip vim-tiny

# Wordpress Requirements
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php5-curl php5-gd php5-intl php-pear php5-imap php5-mcrypt php5-memcache php5-ps php5-pspell php5-recode php5-sqlite php5-tidy php5-xmlrpc php5-xsl

# mysql config
ADD my.cnf /etc/mysql/conf.d/my.cnf
RUN chmod 664 /etc/mysql/conf.d/my.cnf

# apache config
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
RUN chown -R www-data:www-data /var/www/

VOLUME /var/www/html

# php config
RUN sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php5/apache2/php.ini
RUN sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php5/apache2/php.ini
RUN sed -i -e "s/short_open_tag\s*=\s*Off/short_open_tag = On/g" /etc/php5/apache2/php.ini
#XEBUG
#RUN apt-get -y install php5-dev php-pear
#RUN pecl install xdebug
RUN apt-get -y install php5-xdebug
RUN echo 'zend_extension="/usr/lib/php5/20131226/xdebug.so"' >> /etc/php5/apache2/php.ini
RUN echo "xdebug.remote_enable=on"  >> /etc/php5/apache2/php.ini
RUN echo "xdebug.remote_handler=dbgp" >> /etc/php5/apache2/php.ini
RUN echo "xdebug.remote_connect_back=On" >> /etc/php5/apache2/php.ini
RUN echo "xdebug.idekey=ECLIPSE_DBGP" >> /etc/php5/apache2/php.ini

# fix for php5-mcrypt
RUN /usr/sbin/php5enmod mcrypt

# Supervisor Config
RUN mkdir /var/log/supervisor/
RUN /usr/bin/easy_install supervisor
RUN /usr/bin/easy_install supervisor-stdout
ADD ./supervisord.conf /etc/supervisord.conf

# Initialization Startup Script
ADD ./start.sh /start.sh
RUN chmod 755 /start.sh

EXPOSE 3306
EXPOSE 80
EXPOSE 9000

CMD ["/bin/bash", "/start.sh"]
