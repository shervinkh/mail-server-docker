FROM shervinkh/my-archlinux
MAINTAINER "Shervin Khastoo" <shervinkh145@gmail.com>
COPY scripts /scripts/
RUN /update.sh && \
    pacman -S --noconfirm postfix mariadb dovecot opendkim opendmarc spamassassin roundcubemail pigeonhole nginx-mainline php-imap php-intl postfixadmin php-fpm binutils python fakeroot python-setuptools cmake help2man gcc make && \
    /scripts/aur_install.sh python-pydns python-pyspf python-postfix-policyd-spf postsrsd && \
    pacman -Rs --noconfirm fakeroot python-setuptools cmake help2man && \
    /cleanup.sh
COPY configs /etc/
RUN /scripts/php_enable.sh curl exif iconv imap intl ldap mysqli pdo_mysql zip && \
    sed --in-place 's/;date.timezone =/date.timezone = "Iran"/' /etc/php/php.ini && \
    sed --in-place 's/inet_protocols = ipv4/inet_protocols = all/' /etc/postfix/main.cf && \
    mkdir /data /etc/nginx/servers-enabled && \
    groupadd -g 5000 vmail && \
    useradd -u 5000 -g vmail -s /usr/bin/nologin -d /data/mail -m vmail && \
    groupadd -g 89 -f mysql && \
    (id -u mysql &> /dev/null || useradd -u 89 -g mysql -d /var/lib/mysql -m mysql) && \
    mkdir -p /run/mysqld && \
    chown mysql:mysql /run/mysqld && \
    postmap /etc/postfix/transport && \
    rm -rf /etc/postsrsd/ && \
    /scripts/nginx_enable.sh postfixadmin roundcube && \
    /scripts/extend.sh /etc/postfix/main.cf && \
    /scripts/extend.sh /etc/postfix/master.cf && \
    rm -rf /usr/share/webapps/roundcubemail/installer && \
    chown -R opendkim:mail /etc/opendkim && \
    chown -R opendmarc:postfix /etc/opendmarc
VOLUME ["/data"]
ENTRYPOINT ["/scripts/entrypoint.sh"]
EXPOSE 25 143 587 993 4190 8001 8002 9001

