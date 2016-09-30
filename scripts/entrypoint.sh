#!/bin/bash

/scripts/initialize.sh && (/scripts/mysql_initialize.sh & /usr/bin/supervisord)

