
FROM nvidia/cuda:12.9.1-cudnn-devel-ubuntu22.04

SHELL ["/bin/bash", "-c"]

ARG USER_ID=1000
ARG USER_GID=$USER_ID
ARG USER_NAME=ubuntu
ARG PASSWORD=ubuntu

RUN if id -u $USER_ID ; then userdel `id -un $USER_ID`; fi 

RUN groupadd --gid $USER_GID $USER_NAME && \
    useradd --uid $USER_ID --gid $USER_GID -m $USER_NAME && \
    apt-get update && \
    apt-get install -y sudo && \
    echo $USER_NAME:$PASSWORD | chpasswd && \
    echo "$USER_NAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
WORKDIR /home/$USER_NAME
ENV TERM=xterm-256color

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo

# setup timezone
RUN echo 'Asia/Tokyo' > /etc/timezone && \
    ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    apt-get update && DEBIAN_FRONTEND=noninteractive && \
    apt-get install -q -y --no-install-recommends \
        tzdata && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# setup environment
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# locale
RUN apt-get update && DEBIAN_FRONTEND=noninteractive && \
    apt-get install -q -y --no-install-recommends \
        locales && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
RUN locale-gen en_US.UTF-8

# install basic packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    x11-apps \
    mesa-utils \
    apt-utils \
    can-utils \
    net-tools \
    curl \
    lsb-release \
    less \
    tmux \
    command-not-found \
    git \
    xsel \
    vim \
    wget \
    gedit \
    gnupg2 \
    build-essential \
    python3-dev \
    python3-pip \
    xdg-utils \
    nautilus \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $USER_NAME
WORKDIR /home/$USER_NAME

# install pytorch
RUN pip3 install torch torchvision

RUN git clone https://github.com/masakifujiwara1/tmux_config.git && \
    cp tmux_config/.tmux.conf ~/ && \
    rm -rf tmux_config

ENV NVIDIA_VISIBLE_DEVICES ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

CMD ["bash"]