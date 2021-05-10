#!/bin/sh

LOGROTATE_LOGFILES="${LOGROTATE_LOGFILES:?Files for rotating must be given}"
LOGROTATE_FILESIZE="${LOGROTATE_FILESIZE:-10M}"
LOGROTATE_FILENUM="${LOGROTATE_FILENUM:-5}"

cat > /etc/logrotate.conf << EOF
${LOGROTATE_LOGFILES}
{
  size ${LOGROTATE_FILESIZE}
  missingok
  notifempty
  copytruncate
  rotate ${LOGROTATE_FILENUM}
}

/var/log/cron
/var/log/maillog
/var/log/messages
/var/log/secure
/var/log/spooler
{
    size 1G
    missingok
    sharedscripts
    postrotate
	      /bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true
    endscript
}
EOF

if [ -z "$CRON_EXPR" ]; then
  CRON_EXPR="0 6	* * *"
  echo "CRON_EXPR environment variable is not set. Set to default: $CRON_EXPR"
else
  echo "CRON_EXPR environment variable set to $CRON_EXPR"
fi

echo "$CRON_EXPR	/usr/sbin/logrotate -v /etc/logrotate.conf" >> /etc/crontabs/root

(crond -f) & CRONPID=$!
trap "kill $CRONPID; wait $CRONPID" SIGINT SIGTERM
wait $CRONPID
