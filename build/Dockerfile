ARG PHP_VERSION=8.1
ARG UBUNTU_VERSION=jammy
FROM ubuntu:${UBUNTU_VERSION}
ARG PHP_VERSION

LABEL name Remote-Wake-Sleep-On-LAN-Docker
LABEL version 0.1

## for apt to be noninteractive
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN apt-get -y update && \
    apt install -y  \
    apache2 \
    php \
    php-curl \
    libapache2-mod-php \
    libcurl4-gnutls-dev \
    iputils-ping \
    wakeonlan \
    git

WORKDIR /root
RUN git clone https://github.com/sciguy14/Remote-Wake-Sleep-On-LAN-Server.git &&\
    chown root: /var/www/html &&\
    chmod u+s `which ping`

COPY ports.conf /etc/apache2/

RUN a2enmod headers &&\
    echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    service apache2 restart &&\
    mv -f Remote-Wake-Sleep-On-LAN-Server/apache2_configs/000-default_http.conf /etc/apache2/sites-available/000-default.conf &&\
    sed -i.bak "s/expose_php = On/expose_php = Off/g" /etc/php/${PHP_VERSION}/apache2/php.ini &&\
    sed -i.bak "s/E_ALL & ~E_NOTICE & ~E_STRICT & ~E_DEPRECATED/error_reporting = E_ERROR/g" /etc/php/${PHP_VERSION}/apache2/php.ini &&\
    sed -i.bak "s/ServerSignature On/ServerSignature Off/g" /etc/apache2/conf-available/security.conf &&\
    sed -i.bak "s/ServerTokens OS/ServerTokens Prod/g" /etc/apache2/conf-available/security.conf &&\
    sed -i.bak "s/;extension=curl/extension=curl/g" /etc/php/${PHP_VERSION}/apache2/php.ini && \
    service apache2 restart &&\
    mv Remote-Wake-Sleep-On-LAN-Server/www/html/* /var/www/html &&\
    mv Remote-Wake-Sleep-On-LAN-Server/www/html/.htaccess /var/www/html &&\
    rm -rf Remote-Wake-Sleep-On-LAN-Server/ &&\
    rm -f /var/www/html/index.html

COPY config.php /var/www/html/config.php
COPY entrypoint.sh /

ENV APACHE2_PORT=80
ENV PASSPHRASE=admin
ENV RWSOLS_MAX_PINGS=15
ENV RWSOLS_SLEEP_TIME=5
ENV RWSOLS_COMPUTER_NAME=
ENV RWSOLS_COMPUTER_MAC=
ENV RWSOLS_COMPUTER_IP=
ENV RWSOLS_SLEEP_PORT=7760
ENV RWSOLS_SLEEP_CMD=suspend

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
CMD ["-c"]