#! /bin/bash

docker run -d --name anovnc \
 -p 127.0.0.1:6200:6200 \
 --restart=unless-stopped  \
 ghcr.io/hw/anovnc
