#!/bin/bash

/scripts/initializer.sh && (/scripts/mysql_initializer.sh & /usr/bin/supervisord)

