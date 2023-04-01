ARG PHP_VERSION=8.1
ARG ALPINE_VERSION=3.17.3
FROM alpine:${ALPINE_VERSION}
ARG PHP_VERSION

LABEL name Remote-Wake-Sleep-On-LAN-Docker-alpine
LABEL version 0.1

RUN apk update && \
    apk add apache2 \
    sudo \
    php \
    php-curl \
    php$phpverx-apache2 \
    git

WORKDIR /root
RUN git clone https://github.com/sciguy14/Remote-Wake-Sleep-On-LAN-Server.git &&\
    chmod u+s `which ping`

# not required in alpine?
#     sed -i.bak "s/;extension=curl/extension=curl/g" /etc/php$PHPNODOT/php.ini && \

# we need to remove the symbolic link of ping to busybox
# instead we add a function in profile that calls busybox ping but suppresses the output of the command if not reachable
# we also need to add a function that maps the wakeonlan command to ether-wake 

RUN PHPNODOT=$(echo "${PHP_VERSION}" | tr -d .) && \
    echo "ServerName localhost" >> /etc/apache2/httpd.conf && \
    mv Remote-Wake-Sleep-On-LAN-Server/apache2_configs/000-default_http.conf /etc/apache2/conf.d/000-default.conf &&\
    sed -i.bak "s/expose_php = On/expose_php = Off/g" /etc/php$PHPNODOT/php.ini &&\
    sed -i.bak "s/E_ALL & ~E_NOTICE & ~E_STRICT & ~E_DEPRECATED/error_reporting = E_ERROR/g" /etc/php$PHPNODOT/php.ini &&\
    sed -i.bak "s/ServerSignature On/ServerSignature Off/g" /etc/apache2/httpd.conf &&\
    sed -i.bak "s/ServerTokens OS/ServerTokens Prod/g" /etc/apache2/httpd.conf &&\
    sed -i.bak 's/#LoadModule rewrite_module/LoadModule rewrite_module/g' /etc/apache2/httpd.conf && \
    sed -i.bak 's/#LoadModule mod_headers/LoadModule mod_headers/g' /etc/apache2/httpd.conf && \
    sed -i.bak 's/var\/www\/html/var\/www\/localhost\/htdocs/g' /etc/apache2/conf.d/000-default.conf && \
    mv Remote-Wake-Sleep-On-LAN-Server/www/html/* /var/www/localhost/htdocs &&\
    mv Remote-Wake-Sleep-On-LAN-Server/www/html/.htaccess /var/www/localhost/htdocs &&\
    rm -rf Remote-Wake-Sleep-On-LAN-Server/ &&\
    rm -f /var/www/localhost/htdocs/index.html &&\
    mv /bin/ping /bin/ping_orig

COPY additional_scripts/ping.sh /bin/ping.sh
COPY additional_scripts/wakeonlan.sh /bin/wakeonlan.sh
COPY additional_scripts/nosudopwd_ether-wake /etc/sudoers.d/

COPY config.php /var/www/localhost/htdocs/config.php
COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh &&\
 chmod +x /bin/ping.sh &&\
 chmod +x /bin/wakeonlan.sh && \
 ln -s /bin/ping.sh /bin/ping && \
 ln -s /bin/wakeonlan.sh /bin/wakeonlan

ENV APACHE2_PORT=8080
ENV INTERFACE_FOR_WOL=eth0
ENV PASSPHRASE=admin
ENV RWSOLS_MAX_PINGS=15
ENV RWSOLS_SLEEP_TIME=5
ENV RWSOLS_COMPUTER_NAME=
ENV RWSOLS_COMPUTER_MAC=
ENV RWSOLS_COMPUTER_IP=
ENV RWSOLS_SLEEP_PORT=7760
ENV RWSOLS_SLEEP_CMD=suspend

# actually the port can be changed by the APACHE2_PORT, so this is just a default, but also has no real impact since network type host must be used to run the container (to make WoL work)
# there is another way, but it needs config changes on the host running the container
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
