#!/bin/bash
# https://www.percona.com/blog/2012/01/18/backing-up-binary-log-files-with-mysqlbinlog/
# nohup /usr/local/bin/mysql.binlog.stream.sh /etc/binlog/3.usk.me.conf 2>&1 > /var/log/mysql.binlog.stream.3.usk.me.log & 
source "$1"
cd $BACKUPDIR
echo "`date +%Y-%m-%d\ %H:%M:%S.%N` Backup dir: $BACKUPDIR "
while :
  do
    LASTFILE=`ls -1 $BACKUPDIR|grep -v orig|tail -n 1`
    TIMESTAMP=`date +%s`
    FILESIZE=$(stat -c%s "$LASTFILE")
    if [ $FILESIZE -gt 0 ]; then
	echo "`date +%Y-%m-%d\ %H:%M:%S.%N` Backing up last binlog"
	mv $LASTFILE $LASTFILE.orig$TIMESTAMP
    fi
    touch $LASTFILE
    echo "`date +%Y-%m-%d\ %H:%M:%S.%N` Starting live binlog backup"
    mysqlbinlog --raw --read-from-remote-server --stop-never --host $MYSQLHOST --port $MYSQLPORT -u $MYSQLUSER -p$MYSQLPASS $LASTFILE
    echo "`date +%Y-%m-%d\ %H:%M:%S.%N` mysqlbinlog exited with $? trying to reconnect in $RESPAWN seconds."
    sleep $RESPAWN
  done
