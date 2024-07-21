#!/bin/sh

if [ -z "$FILE_NAME" ]; then
  FILE_NAME="soft_ac-0.0.1-SNAPSHOT.jar"
fi

exec socat TCP4-LISTEN:27777,fork,reuseaddr TCP4:"$MONGODB_HOST":"$MONGODB_PORT" &
exec socat TCP4-LISTEN:6319,fork,reuseaddr TCP4:"$REDIS_HOST":"$REDIS_PORT" &

echo "Starting Xorg server..."
if [ -f /tmp/.X0-lock ]; then
    rm /tmp/.X0-lock
fi
Xvfb :0 -screen 0 1024x768x16 &
# Wait for Xvfb to start
sleep 2;
echo "Starting stalonetray..."
stalonetray &
echo "Staring nginx..."
nginx -c /ipcom/nginx/conf/nginx.conf -p /ipcom/nginx/ &

cd /ipcom/ && exec java -Djasypt.encryptor.password=faTai21com20 -Djava.awt.headless=false -jar "$FILE_NAME"