#!/bin/bash
rm -rf /tmp/aur_build;
for pkg in "$@"
do
    mkdir /tmp/aur_build && cd /tmp/aur_build && wget https://aur.archlinux.org/cgit/aur.git/snapshot/$pkg.tar.gz && tar xzpf * && cd $pkg && chmod 777 /tmp/aur_build/$pkg && sudo -u nobody makepkg && pacman -U *.pkg.tar.xz --noconfirm && rm -rf /tmp/aur_build
done

