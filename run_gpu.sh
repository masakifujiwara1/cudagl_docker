#!/bin/bash

eval "docker container run \
--network host \
--gpus all \
-it \
--name my-cudagl-torcs \
-e DISPLAY=$DISPLAY \
--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
-v $PWD/docker_share:/home/ubuntu/host_files \
--privileged \
-v /dev:/dev \
-v $PWD/scripts/reward.py:/home/ubuntu/gym_torcs/reward.py \
-v /run/user/1000/:/run/user/1000/ \
--env="XAUTHORITY=$XAUTH" \
-v "$XAUTH:$XAUTH" \
--env="QT_X11_NO_MITSHM=1" \
--ipc=host \
masakifujiwara1/cudagl:11.3.0-devel-ubuntu20.04-torch-torcs"
