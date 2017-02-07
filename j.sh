#!/bin/bash

#######################################################
#
# Jekyll Server Manager Script
#
# Copyright (c) 2016 liushoukai <kay21156929@gmail.com>
#
#######################################################

JEKYLL="/usr/local/rvm/gems/ruby-2.0.0-p643/bin/jekyll"

USAGE="\e[1;32mUsage: $0 start|restart|stop port\e[0m"
 PORT=$2
PIDFILE="jekyll_$PORT.pid"

if [ $# -ne 2 ];then
    echo -e $USAGE
    exit 1
fi


function stop() {
    if [ -e $PIDFILE ]; then
        ps -ef|grep `cat $PIDFILE`|grep -v grep
        if [ $? -eq 0 ]; then
            kill `cat $PIDFILE` && rm $PIDFILE && echo "jekyll server[port: $PORT] stop sucessfully."
            return 0
        fi
    fi
    echo "jekyll server[port: $PORT] stop failure."
    return 1;
}

function start() {
    if [ -e $PIDFILE ]; then
        ps -ef|grep `cat $PIDFILE`|grep -v grep
        if [ $? -eq 0 ]; then
            echo "jekyll server[port: $PORT] already started."
            exit 0
        else
            rm $PIDFILE
        fi
    fi
    nohup $JEKYLL server --port $PORT &> /dev/null &
    echo "nohup $JEKYLL server --port $PORT &> /dev/null &"
    sleep 3 #wait for the script to run
    echo "ps -ef|grep $!|grep -v grep"
    ps -ef|grep $!|grep -v grep
    if [ $? -eq 0 ]; then
        echo $! > $PIDFILE
        echo "jekyll server[port: $PORT] start sucessfully."
    else
        echo "jekyll server[port: $PORT] start failure."
    fi
}

case $1 in
    start)
        start;
        ;;
    restart)
        stop;
        start;
        ;;
    stop)
        stop;
        ;;
    *)
        echo -e $USAGE
        exit 1
        ;;
esac












