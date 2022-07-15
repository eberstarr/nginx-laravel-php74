FROM ubuntu:18.04
MAINTAINER Eber
ENV TZ=Asia/Taipei

# update & upgrade all packages
RUN DEBIAN_FRONTEND=noninteractive apt update && \
    apt-get -o Dpkg::Options::="--force-confold" upgrade -q -y --force-yes && \
    apt-get -o Dpkg::Options::="--force-confold" dist-upgrade -q -y --force-yes

# install require package
RUN DEBIAN_FRONTEND=noninteractive \
    apt install -y software-properties-common curl wget zip unzip

# setup server locale
RUN DEBIAN_FRONTEND=noninteractive \
    apt install -y locales && \
    locale-gen --purge en_US.UTF-8
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# setup timezone to $TZ
RUN DEBIAN_FRONTEND=noninteractive \
    apt install -y tzdata && \
    rm -rf /etc/localtime && \
    ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# install Nginx
RUN DEBIAN_FRONTEND=noninteractive \
    add-apt-repository ppa:nginx/stable && \
    apt update && apt install -y nginx

# install PHP
RUN DEBIAN_FRONTEND=noninteractive \
    add-apt-repository -y ppa:ondrej/php && \
    apt update && \
    apt install -y php-pear php-cli php-common php-xml \
                   php7.4 php7.4-fpm php7.4-cli php7.4-common \
                   php7.4-xml php7.4-json php7.4-opcache \
                   php7.4-readline php7.4-curl php7.4-mysql \
                   php7.4-mbstring php7.4-zip php7.4-gd \
                   php7.4-intl php7.4-dev

# install Composer
RUN DEBIAN_FRONTEND=noninteractive \
    apt install wget -y
RUN cd ~
RUN DEBIAN_FRONTEND=noninteractive \
    wget -c https://getcomposer.org/download/1.10.10/composer.phar
RUN chmod u+x composer.phar
RUN mv composer.phar /usr/local/bin/composer

# install supervisor
RUN DEBIAN_FRONTEND=noninteractive \
    apt install -y supervisor

# install Vim
RUN DEBIAN_FRONTEND=noninteractive \
    add-apt-repository ppa:jonathonf/vim && \
    apt update && apt install -y vim

# install Git
RUN DEBIAN_FRONTEND=noninteractive \
    add-apt-repository ppa:git-core/ppa && \
    apt update && apt install -y git

# cleans packages
RUN DEBIAN_FRONTEND=noninteractive \
    apt autoremove && apt clean

# setup configration
RUN mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
COPY config/default /etc/nginx/sites-available/default

RUN mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
COPY config/nginx.conf /etc/nginx/nginx.conf

RUN mv /etc/php/7.4/fpm/php-fpm.conf /etc/php/7.4/fpm/php-fpm.conf.bak
COPY config/php-fpm.conf /etc/php/7.4/fpm/php-fpm.conf

RUN mv /etc/php/7.4/fpm/php.ini /etc/php/7.4/fpm/php.ini.bak
COPY config/php.ini /etc/php/7.4/fpm/php.ini

# prepare init file
COPY start.sh /root/start.sh
RUN date > /root/image-created-date
RUN chmod -R 755 /root/start.sh
