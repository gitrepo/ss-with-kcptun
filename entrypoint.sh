#!/bin/sh
curl  "https://ss.nsupdate.info:mJPDcwcCpt@ipv4.nsupdate.info/nic/update" &
ss-server -p $SS_PORT -k $SS_PASSWORD -m $SS_METHOD -t $SS_TIMEOUT -d 8.8.8.8 -d 208.67.222.222 -u --fast-open &
/opt/kcptun/server_linux_amd64  -t "127.0.0.1:443" -l ":29900"  -mode fast2 &
