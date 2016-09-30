#!/bin/bash

echo ">> Waiting for MySQL to start"
WAIT=0
while ! nc -z localhost 3306; do
    sleep 1
    WAIT=$(($WAIT + 1))
    if [ "$WAIT" -gt 15 ]; then
        echo "Error: Timeout wating for MySQL to start"
        exit 1
    fi
done

if [ ! -e /data/.mysql_initialized ]
then
mysql_secure_installation <<EOF

y
root
root
y
y
y
y
EOF

mysql -u root -proot -e 'CREATE DATABASE postfix CHARACTER SET utf8 COLLATE utf8_general_ci;'
mysql -u root -proot -e 'CREATE DATABASE roundcube CHARACTER SET utf8 COLLATE utf8_general_ci;'

mysql -u root -proot roundcube < /usr/share/webapps/roundcubemail/SQL/mysql.initial.sql

touch /data/.mysql_initialized
echo "MySQL Initialized!"
fi
