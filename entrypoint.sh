#!/bin/bash

/usr/local/spark/sbin/start-history-server.sh &
$ZEPPELIN_HOME/bin/zeppelin-daemon.sh start &

echo 'Sleeping infinity to keep the container running'
sleep infinity
echo 'Done sleeping'