#!/bin/sh

LOGROTATE_LOGFILES="${LOGROTATE_LOGFILES:?Files for rotating must be given}"
LOGROTATE_FILENUM="${LOGROTATE_FILENUM:-7}"

cat > /etc/logrotate.conf << EOF
${LOGROTATE_LOGFILES}
{
  daily
  rotate ${LOGROTATE_FILENUM}
  missingok
  notifempty
  compress
  delaycompress
  copytruncate
}

/var/log/cron
/var/log/maillog
/var/log/messages
/var/log/secure
/var/log/spooler
{
  daily
  rotate 7
  compress
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
