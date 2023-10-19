FROM nvidia/cuda:12.2.2-cudnn8-devel-ubuntu22.04 as devel

ARG DEBIAN_FRONTEND=noninteractive
ARG OPENCV_VERSION=4.8.1
ARG CUDA_ARCH_BIN=8.0

RUN apt-get update &&\
    apt-get install -y \
    git\
    unzip \
    wget

# Fetch opencv and opencv_contrib sources
RUN git clone --depth 1 --branch ${OPENCV_VERSION} https://github.com/opencv/opencv.git /opt/opencv-${OPENCV_VERSION} &&\
    cd /opt/opencv-${OPENCV_VERSION} &&\
    git fetch origin pull/24104/head &&\
    git config --global user.email "build@docker.com" &&\
    git config --global user.name "Docker" &&\
    git cherry-pick ab8cb6f8a9034da2a289b84685c6d959266029be &&\
    git clone --depth 1 --branch ${OPENCV_VERSION} https://github.com/opencv/opencv_contrib.git /opt/opencv_contrib-${OPENCV_VERSION}

RUN apt-get install -y \
    build-essential \
    cmake \
    libjpeg-dev \
    libopenexr-dev \
    libopenjp2-7-dev \
    libpng-dev \
    libtiff-dev \
    libwebp-dev 

# Create build folder and switch to it
RUN mkdir /opt/opencv-${OPENCV_VERSION}/build &&\
    cd /opt/opencv-${OPENCV_VERSION}/build &&\
    cmake \
      -D OPENCV_EXTRA_MODULES_PATH=/opt/opencv_contrib-${OPENCV_VERSION}/modules \
      -D WITH_CUDA=ON \
      -D WITH_CUDNN=ON \
      -D OPENCV_ENABLE_NONFREE=ON \
      -D OPENCV_DNN_CUDA=ON \
      -D ENABLE_FAST_MATH=ON \
      -D CUDA_FAST_MATH=ON \
      -D CUDA_ARCH_BIN=${CUDA_ARCH_BIN} \
      -D CMAKE_BUILD_TYPE=RELEASE \
      # Install path will be /usr/local/lib (lib is implicit)
      -D CMAKE_INSTALL_PREFIX=/usr/local \
      .. &&\
    make -j$(nproc) &&\
    # Install to /usr/local/lib
    make install &&\
    ldconfig &&\
    # Remove OpenCV sources and build folder
    rm -rf /opt/opencv-${OPENCV_VERSION} && rm -rf /opt/opencv_contrib-${OPENCV_VERSION}

# FROM nvidia/cuda:12.2.2-cudnn8-runtime-ubuntu22.04 as runtime
