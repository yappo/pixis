#!/bin/sh
exec $MYAPP_HOME/script/pixis_web_fastcgi.pl \
    -l $MYAPP_SOCKET \
    -p $MYAPP_PIDFILE \
    -e \
    2>&1