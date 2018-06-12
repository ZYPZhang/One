#!/bin/bash
# 获取ip
ip=`ping -c 1 $1 | awk -F'[() ]+' '/from/{print $5}'`

# 天津市众成房地产经纪有限公司


[ $fbs -eq 75 ] && /usr/bin/rsync -avz --progress --delete /mnt/lib/lib67 root@$ip:/usr/local/jboss/server/default/lib/
[ $fbs -eq 90 ] && /usr/bin/rsync -avz --progress --delete /mnt/databack/lib/ root@$ip:/mnt/databack/lib/wlib /mnt/databack/lib/

# 先检测服务器状态,是否已有过发版处理.
fbs=`du -sm /usr/local/jboss/server/default/lib/| awk '{print $1}'`
[ $fbs -eq 75 -o $fbs -eq 17 ] && fbs=0 || fbs=1
echo $fbs
case fbs in
    0)
        sto
        mkdir -p /mnt/databack/lib/olib
        mv /usr/local/jboss/server/default/lib/* /mnt/databack/lib/olib


    ;;
    1)

    ;;
esac

