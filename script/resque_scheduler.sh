#!/bin/bash

SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`

case $1 in
  start)
    ROOT="$SCRIPTPATH/.."
    cd $ROOT
    RAILS_ENV=production geigercrowd_rake resque:scheduler INITIALIZER_PATH=config/initializers/resque.rb 2>&1 >> $ROOT/log/resque_scheduler.log &
    echo $! > $ROOT/tmp/pids/resque_scheduler.pid
    ;;
  stop)
    kill $($ROOT/tmp/pids/resque_scheduler.pid)
    ;;
esac
