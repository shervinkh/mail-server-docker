#!/bin/bash

deskey=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9-_#&!*%?' | fold -w 24 | head -n 1)

echo "\$config['des_key'] = '$deskey';" >> /etc/webapps/roundcubemail/config/config.inc.php
