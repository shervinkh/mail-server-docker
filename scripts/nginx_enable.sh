#!/bin/bash
for service in "$@"
do
    ln -s /etc/nginx/servers-available/$service /etc/nginx/servers-enabled/$service
done
