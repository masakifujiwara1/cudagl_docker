FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04

SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive
ARG ROS_DISTRO=humble
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
        cmake \
        gnupg2 \
        python3-dev \
        python3-pip \
        software-properties-common \
        libglvnd-dev \
        libxext6 \
        libx11-dev \
        libxmu-dev \
        libxi-dev \
        libgl1-mesa-dev \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu117

# install ROS2 Humble
RUN sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(source /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
        ros-${ROS_DISTRO}-desktop \
        && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# install colcon and rosdep
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
        python3-colcon-common-extensions \
        python3-rosdep \
        python3-argcomplete \
        && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# install ros2 packages
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
        gazebo \
        ros-${ROS_DISTRO}-gazebo-ros-pkgs \
        ros-${ROS_DISTRO}-joint-state-publisher* \
        python3-colcon-mixin \
        python3-rosdep \
        python3-vcstool && \
    sudo rosdep init && \
    rosdep update --rosdistro ${ROS_DISTRO} && \
    sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

# install xacro
RUN pip3 install xacro

# set ros2 workspace
RUN source /opt/ros/${ROS_DISTRO}/setup.bash && mkdir -p ros2_ws/src && cd ~/ros2_ws && colcon build --symlink-install

# check OpenGL
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
        libglvnd0 \
        libgl1 \
        libglx0 \
        libegl1 \
        libxext6 \
        libx11-6 && \
    sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,graphics

# config setting
COPY config/.bashrc /home/$USER_NAME/.bashrc
COPY config/.vimrc /home/$USER_NAME/.vimrc
COPY config/.tmux.conf /home/$USER_NAME/.tmux.conf

CMD ["bash"]
