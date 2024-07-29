
FROM nvidia/cudagl:11.3.0-devel-ubuntu20.04

SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND noninteractive
ARG ROS_DISTRO=noetic
ARG ROS_PKG=desktop
ENV ROS_ROOT=/opt/ros/${ROS_DISTRO}
ENV ROS_PYTHON_VERSION=3

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
        sudo \
        x11-apps \
        mesa-utils \
        curl \
        lsb-release \
        less \
        tmux \
        command-not-found \
        git \
        xsel \
        vim \
        wget \
        gnupg \
        build-essential \
        python3-dev \
        python3-pip \
        && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# install pytorch
RUN pip3 install torch torchvision

# install ROS Noetic
RUN sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' && \
    sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 && \
    sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    ros-noetic-desktop-full \
    && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# install catkin and rosdep
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    python3-catkin-tools \
    python3-rosdep \
    && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# initialize rosdep
RUN sudo rosdep init && \
    rosdep update

# install ros packages
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    ros-noetic-joint-state-publisher* \
    gazebo11 \
    ros-noetic-gazebo-ros-pkgs \
    ros-noetic-can-msgs \
    python3-vcstool && \
    rosdep update && \
    sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

# install xacro
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    ros-noetic-xacro \
    && \
    sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

WORKDIR /home
ENV HOME /home

# config setting
COPY config/.bashrc /home/.bashrc
COPY config/.vimrc /home/.vimrc
COPY config/.tmux.conf /home/.tmux.conf

CMD ["bash"]