#!/bin/bash

for file in "$@"
do
    sed --in-place -e 's:/var/log:/data/log:g' $file
done
