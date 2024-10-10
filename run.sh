#!/bin/bash

eval "docker container run \
--network host \
-it \
--name my-cudagl \
-e DISPLAY=$DISPLAY \
--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
-v $PWD/docker_share:/home/ubuntu/host_files \
--privileged \
-v /dev:/dev \
--env="XAUTHORITY=$XAUTH" \
-v "$XAUTH:$XAUTH" \
--env="QT_X11_NO_MITSHM=1" \
--ipc=host \
masakifujiwara1/cudagl:11.7.1-cudnn8-devel-ubuntu22.04-torch-humble"