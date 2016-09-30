# My Mail server Docker
A mail server with postfix, dovecot, roundcube, postfixadmin supporting DKIM, DMARC, SPF, SRS, IMAP
- Run with `docker run --detach --tty --restart=always --name=mail-server -v /home/user/mail-server/log:/var/log -v /home/user/mail-server/data:/data -e MAIL_SERVER=mail.example.com -e MAIN_DOMAIN=example.com -e ALL_DOMAINS=example.com,example.org -e SETUP_PASSWORD=admin -e AUTO_DKIM=true -p 25:25 -p 143:143 -p 587:587 -p 993:993 shervinkh/mail-server`
