FROM shervinkh/my-archlinux
MAINTAINER "Shervin Khastoo" <shervinkh145@gmail.com>
COPY scripts /scripts
RUN pacman -Sy --noconfirm && \
    pacman -S --noconfirm postfix mariadb dovecot opendkim opendmarc roundcubemail pigeonhole nginx-mainline php-imap php-intl postfixadmin php-fpm binutils python fakeroot python-setuptools cmake help2man gcc make && \
    /scripts/aur_install.sh python-pydns python-pyspf python-postfix-policyd-spf postsrsd && \
    pacman -Rs --noconfirm binutils fakeroot python-setuptools cmake help2man gcc make
COPY configs /etc/
RUN /scripts/php_enable.sh curl exif iconv imap intl ldap mysqli pdo_mysql zip && \
    sed --in-place 's/;date.timezone =/date.timezone = "Iran"/' /etc/php/php.ini && \
    sed --in-place 's:ExecStart=/usr/sbin/mysqld:ExecStart=/usr/sbin/mysqld --datadir=/data/mysql:' /usr/lib/systemd/system/mariadb.service && \
    sed --in-place 's/HELO_reject = SPF_Not_Pass/HELO_reject = Fail/' /etc/python-policyd-spf/policyd-spf.conf && \
    /scripts/service_enable.sh mariadb dovecot php-fpm opendkim opendmarc nginx postfix postsrsd && \
    mkdir -p /data/cert /data/dkim /etc/nginx/servers-enabled && \
    groupadd -g 5000 vmail && \
    useradd -u 5000 -g vmail -s /usr/bin/nologin -d /data/mail -m vmail && \
    postmap /etc/postfix/transport && \
    rm /etc/postsrsd/postsrsd.secret && \
    /scripts/nginx_enable.sh postfixadmin roundcube && \
    chown -R opendkim:mail /etc/opendkim && \
    chown -R opendmarc:postfix /etc/opendmarc && \
    chown -R postsrsd:root /etc/postsrsd && \
    /scripts/extend.sh /etc/postfix/main.cf && \
    /scripts/extend.sh /etc/postfix/master.cf && \
    ln -s /etc/systemd/system/initializer.service /etc/systemd/system/multi-user.target.wants/ && \
    ln -s /etc/systemd/system/mysql_initializer.service /etc/systemd/system/multi-user.target.wants/ && \
    mkdir -p /etc/systemd/system/timers.target.wants/ && \
    ln -s /etc/systemd/system/roundcube_clean.timer /etc/systemd/system/timers.target.wants/ && \
    rm -rf /usr/share/webapps/roundcubemail/installer && \
    /scripts/initialize_des_key.sh
VOLUME ["/data"]
ENTRYPOINT ["/usr/sbin/init"]
EXPOSE 25 143 587 993 8001 8002

