#!/bin/bash

if [ ! ${MAIL_SERVER} ]; then export MAIL_SERVER=mail.example.com; fi
if [ ! ${MAIN_DOMAIN} ]; then export MAIN_DOMAIN=example.com; fi
if [ ! ${ALL_DOMAINS} ]; then export ALL_DOMAINS=example.com,example.org; fi
if [ ! ${SETUP_PASSWORD} ]; then export SETUP_PASSWORD=admin; fi

if [ ! -e /root/.initialized ]
then
mkdir -p /data/{cert,dkim,sieve,mail,postsrsd,opendmarc}
chown root:root /data
[ -e /data/mysql/mysql ] || mysql_install_db --user=mysql --basedir=/usr --datadir=/data/mysql
[ -e /data/postsrsd/postsrsd.secret ] || dd if=/dev/urandom bs=18 count=1 status=none | base64 > /data/postsrsd/postsrsd.secret
chown -R vmail:vmail /data/mail
chown -R opendmarc:postfix /data/opendmarc
chown -R postsrsd:root /data/postsrsd
chmod 400 /data/postsrsd/postsrsd.secret

echo "myhostname = ${MAIL_SERVER}" >> /etc/postfix/main.cf
echo "mydomain = ${MAIN_DOMAIN}" >> /etc/postfix/main.cf
sed --in-place "s/__DOMAIN__/${MAIN_DOMAIN}/;s/__DOMAINS__/${ALL_DOMAINS}/" /etc/supervisor.d/srs.ini

[ -e /data/cert/mail_dhparams.pem ] || openssl dhparam -out /data/cert/mail_dhparams.pem 2048
([ -e /data/cert/mail.key ] && [ -e /data/cert/mail.crt ]) || openssl req -new -x509 -nodes -newkey rsa:4096 -keyout /data/cert/mail.key -out /data/cert/mail.crt -days 3650 <<EOF
IR
Tehran
Tehran
${MAIN_DOMAIN}
mail
${MAIL_SERVER}
postmaster@${MAIN_DOMAIN}
EOF

cp /data/cert/mail.crt /etc/ca-certificates/trust-source/anchors/
trust extract-compat

sed --in-place -e "s/CERT_PEER_CN/${MAIL_SERVER}/" /etc/webapps/roundcubemail/config/config.inc.php

chmod 400 /data/cert/mail.key
chmod 444 /data/cert/mail.crt

if [ "${AUTO_DKIM}" == true ]
then
    rm -f /data/dkim/SigningTable
fi

([ -e /data/dkim/KeyTable ] && [ -e /data/dkim/SigningTable ] && [ -e /data/dkim/TrustedHosts ]) || (
[ -e /data/dkim/main.private ] || opendkim-genkey -r -s main -d ${MAIN_DOMAIN} -D /data/dkim -b 4096

domains=$(echo ${ALL_DOMAINS} | tr "," "\n")
truncate /data/dkim/KeyTable --size 0
truncate /data/dkim/SigningTable --size 0
echo -e "127.0.0.1\n172.16.0.0/12" > /data/dkim/TrustedHosts
for domain in $domains
do
    echo "$domain" >> /data/dkim/TrustedHosts
    echo "main._domainkey.$domain $domain:main:/data/dkim/main.private" >> /data/dkim/KeyTable
    echo "*@$domain main._domainkey.$domain" >> /data/dkim/SigningTable
done
)

chown -R opendkim:mail /data/dkim
chmod 400 /data/dkim/*.private
chmod 444 /data/dkim/*.txt

chown -R vmail:vmail /data/sieve/

/scripts/set_setup_password.sh ${SETUP_PASSWORD}
/scripts/initialize_des_key.sh

mkdir -p /var/log/{supervisor,nginx}

touch /root/.initialized
echo "Initialized data directory!"
fi

