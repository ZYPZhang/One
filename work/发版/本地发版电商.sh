#!/usr/bin/env bash
cd /usr/local/src/dians/my-app
svn update
npm run build
ssh 123.207.159.67 "/usr/local/bin/depmfk4_ds"
ssh 123.207.159.67 "/usr/local/bin/sto && /usr/local/bin/sta"
ssh 23.207.159.67 "nginx -s reload"
rsync -avz --progress --delete /usr/local/src/dians/my-app/build root@123.207.159.67:/mnt/nginx/
