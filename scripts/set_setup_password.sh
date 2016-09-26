#!/bin/bash

salt=$(date +%s | md5sum | cut -d ' ' -f 1)
hash_pass=$salt:$(printf $salt:$1 | sha1sum | cut -d ' ' -f 1)
echo "\$CONF['setup_password'] = '$hash_pass';" >> /etc/webapps/postfixadmin/config.inc.php
