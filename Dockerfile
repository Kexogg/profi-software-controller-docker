FROM alpine:latest

RUN apk add --update nginx bash curl socat openjdk8-jre xorg-server xvfb stalonetray && \
    rm -rf /var/cache/apk/*

COPY /scripts/ipconfig /usr/bin/ipconfig
COPY /scripts/tasklist /usr/bin/tasklist
COPY /scripts/dummy /usr/bin/taskkill
COPY /scripts/tzutil /usr/bin/tzutil
COPY /scripts/cmd /usr/bin/cmd
COPY /scripts/cmd /usr/bin/cmd.exe

# Fake binaries for mongo and redis
COPY /scripts/dummy /ipcom/bin/redis/redis-server-x86.exe
COPY /scripts/dummy /ipcom/bin/mongod-x86.exe

# Copy the nginx and JAR files to the /ipcom image, if they exist
COPY files/ /ipcom/
# Copy the entrypoint script to the container
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV DISPLAY=:0
ENV MONGODB_HOST=mongo
ENV MONGODB_PORT=27017
ENV REDIS_HOST=redis
ENV REDIS_PORT=6379

ENTRYPOINT ["/entrypoint.sh"]