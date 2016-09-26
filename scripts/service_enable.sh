#!/bin/bash
for service in "$@"
do
    ln -s /usr/lib/systemd/system/$service.service /etc/systemd/system/multi-user.target.wants/
done
