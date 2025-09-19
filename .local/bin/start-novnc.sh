#! /bin/bash

docker run -d --name novnc \
 --add-host=host.docker.internal:host-gateway \
 --restart=unless-stopped  \
 -p 127.0.0.1:6200:6200 \
 ghcr.io/hw/novnc
