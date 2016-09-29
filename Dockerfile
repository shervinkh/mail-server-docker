FROM shervinkh/my-archlinux
MAINTAINER "Shervin Khastoo" <shervinkh145@gmail.com>
COPY scripts /scripts
RUN /update.sh && \
    pacman -S --noconfirm supervisor cronie rsyslog postfix mariadb dovecot opendkim opendmarc roundcubemail pigeonhole nginx-mainline php-imap php-intl postfixadmin php-fpm binutils python fakeroot python-setuptools cmake help2man gcc make && \
    /scripts/aur_install.sh python-pydns python-pyspf python-postfix-policyd-spf postsrsd && \
    pacman -Rs --noconfirm binutils fakeroot python-setuptools cmake help2man gcc make && \
    pacman -Rdd --noconfirm systemd && \
    /cleanup.sh
COPY configs /etc/
RUN /scripts/php_enable.sh curl exif iconv imap intl ldap mysqli pdo_mysql zip && \
    sed --in-place 's/;date.timezone =/date.timezone = "Iran"/' /etc/php/php.ini && \
    sed --in-place 's/HELO_reject = SPF_Not_Pass/HELO_reject = Fail/' /etc/python-policyd-spf/policyd-spf.conf && \
    /scripts/change_log_dir.sh /etc/supervisord.conf  /etc/logrotate.d/nginx /etc/logrotate.d/rsyslog /etc/logrotate.d/supervisor && \
    mkdir /data /etc/nginx/servers-enabled /var/spool/rsyslog && \
    groupadd -g 5000 vmail && \
    useradd -u 5000 -g vmail -s /usr/bin/nologin -d /data/mail -m vmail && \
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
EXPOSE 25 143 587 993

