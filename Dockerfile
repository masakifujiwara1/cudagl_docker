FROM nvidia/cudagl:11.3.0-devel-ubuntu20.04

SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive
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
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# locale
RUN apt-get update && DEBIAN_FRONTEND=noninteractive && \
    apt-get install -q -y --no-install-recommends \
        locales && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
RUN locale-gen=en_US.UTF-8

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

# ENV setting
ARG USER_NAME=ubuntu
ARG GROUP_NAME=ubuntu
ARG UID=1000
ARG GID=1000
ARG PASSWORD=ubuntu
RUN groupadd -g $GID $GROUP_NAME && \
    useradd -m -s /bin/bash -u $UID -g $GID -G sudo $USER_NAME && \
    echo $USER_NAME:$PASSWORD | chpasswd && \
    echo "$USER_NAME   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER $USER_NAME
WORKDIR /home/$USER_NAME
# ENV HOME /home/$USER_NAME
ENV TERM=xterm-256color

# install pytorch
RUN pip3 install torch torchvision

# install ROS Noetic
RUN sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros/ubuntu $(source /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros1.list > /dev/null

RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
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

# install ros packages
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    ros-noetic-joint-state-publisher* \
    gazebo11 \
    ros-noetic-map-server* \
    ros-noetic-dwa* \
    ros-noetic-gazebo-ros-pkgs \
    python3-vcstool && \
    sudo rosdep init && \
    rosdep update && \
    sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

# install xacro
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    ros-noetic-xacro \
    && \
    sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

# set catkin workspace
RUN source /opt/ros/noetic/setup.bash && mkdir -p catkin_ws/src && cd ~/catkin_ws && catkin build 

# orne-box install
RUN sudo apt-get update &&\
    cd ~/catkin_ws/src &&\
    git clone -b TC_2024_EX https://github.com/masakifujiwara1/orne-box &&\
    wstool init &&\
    wstool merge orne-box/orne_box_pkgs.install &&\
    wstool up &&\
    rosdep update &&\
    rosdep install --from-paths . --ignore-src --rosdistro $ROS_DISTRO -y &&\
    cd ~/catkin_ws &&\
    catkin build --cmake-args -DCMAKE_BUILD_TYPE=Release &&\
    source /opt/ros/noetic/setup.bash &&\
    source ~/catkin_ws/devel/setup.bash &&\
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# config setting
COPY config/.bashrc /home/$USER_NAME/.bashrc
COPY config/.vimrc /home/$USER_NAME/.vimrc
COPY config/.tmux.conf /home/$USER_NAME/.tmux.conf

RUN sudo chown -R $USER_NAME:$PASSWORD .bashrc

CMD ["bash"]