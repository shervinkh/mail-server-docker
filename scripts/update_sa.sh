#!/bin/bash
/usr/bin/vendor_perl/sa-update
/usr/bin/vendor_perl/sa-compile
if [ "$1" == "learn" ]; then
/usr/bin/vendor_perl/sa-learn --nosync --spam /data/mail/*/*/.Junk/{cur,new}
/usr/bin/vendor_perl/sa-learn --nosync --ham /data/mail/*/*/cur
/usr/bin/vendor_perl/sa-learn --sync
/usr/bin/vendor_perl/sa-learn --dump magic
mkdir -p /data/spamassassin/backups
/usr/bin/vendor_perl/sa-learn --backup > /data/spamassassin/backups/sa-learn_`date +%j`.backup
fi
