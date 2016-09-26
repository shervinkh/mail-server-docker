#!/bin/bash
for module in "$@"
do
   sed --in-place "s/;extension=$module.so/extension=$module.so/" /etc/php/php.ini
done
