#!/bin/bash

if [ ! ${MAIL_SERVER} ]; then export MAIL_SERVER=mail.example.com; fi
if [ ! ${MAIN_DOMAIN} ]; then export MAIN_DOMAIN=example.com; fi
if [ ! ${ALL_DOMAINS} ]; then export ALL_DOMAINS=example.com,example.org; fi
if [ ! ${SETUP_PASSWORD} ]; then export SETUP_PASSWORD=admin; fi

if [ -e /root/.initialized ]
then
    echo "Already initialized!"
    exit 0
fi

mkdir -p /data/{cert,dkim,sieve,mail,postsrsd}
[ -e /data/mysql/mysql ] || mysql_install_db --user=mysql --basedir=/usr --datadir=/data/mysql
[ -e /data/postsrsd/postsrsd.secret ] || dd if=/dev/urandom bs=18 count=1 status=none | base64 > /data/postsrsd/postsrsd.secret
chown -R vmail:vmail /data/mail
chown -R postsrsd:root /data/postsrsd
chmod 400 /data/postsrsd/postsrsd.secret

echo "myhostname = ${MAIL_SERVER}" >> /etc/postfix/main.cf
echo "mydomain = ${MAIN_DOMAIN}" >> /etc/postfix/main.cf
echo "SRS_DOMAIN=${MAIN_DOMAIN}" >> /etc/postsrsd/postsrsd
echo "SRS_EXCLUDE_DOMAINS=${ALL_DOMAINS}" >> /etc/postsrsd/postsrsd
chown -R postsrsd:root /etc/postsrsd/

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

([ -e /data/dkim/KeyTable ] && [ -e /data/dkim/SigningTable ] && [ -e /data/dkim/TrustedHosts ]) || (
opendkim-genkey -r -s main -d ${MAIN_DOMAIN} -D /data/dkim -b 4096

domains=$(echo ${ALL_DOMAINS} | tr "," "\n")
echo "127.0.0.1" > /data/dkim/TrustedHosts
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

/scripts/set_setup_password.sh ${SETUP_PASSWORD}

chown -R vmail:vmail /data/sieve/

touch /root/.initialized
echo "Initialized!"

