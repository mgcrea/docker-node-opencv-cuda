FROM nvidia/cuda:12.2.2-cudnn8-devel-ubuntu22.04 as devel

ARG DEBIAN_FRONTEND=noninteractive
ARG OPENCV_VERSION=4.8.1
ARG CUDA_ARCH_BIN=8.0
# ARG OPENCV_INSTALL_PREFIX=/usr/local

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
      -D CMAKE_INSTALL_PREFIX=/usr/src/opencv-${OPENCV_VERSION} \
      .. &&\
    make -j$(nproc) &&\
    make install &&\
    ldconfig

# Install node.js
ENV NODE_VERSION 18.18.2
ARG ARCH=x64
# ARG NODE_INSTALL_PREFIX=/usr/local

RUN apt-get install -y \
    curl

RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
    amd64) ARCH='x64';; \
    ppc64el) ARCH='ppc64le';; \
    s390x) ARCH='s390x';; \
    arm64) ARCH='arm64';; \
    armhf) ARCH='armv7l';; \
    i386) ARCH='x86';; \
    *) echo "unsupported architecture"; exit 1 ;; \
  esac \
  # use pre-existing gpg directory, see https://github.com/nodejs/docker-node/pull/1895#issuecomment-1550389150
  && export GNUPGHOME="$(mktemp -d)" \
  # gpg keys listed at https://github.com/nodejs/node#release-keys
  && set -ex \
  && for key in \
    4ED778F539E3634C779C87C6D7062848A1AB005C \
    141F07595B7B3FFE74309A937405533BE57C7D57 \
    74F12602B6F1C4E913FAA37AD3A89613643B6201 \
    DD792F5973C6DE52C432CBDAC77ABFA00DDBF2B7 \
    61FC681DFB92A079F1685E77973F295594EC4689 \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
    C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
    108F52B48DB57BB0CC439B2997B01419BD92F80A \
    A363A499291CBBC940DD62E41F10027AF002F8B0 \
  ; do \
      gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" || \
      gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" ; \
  done \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && gpgconf --kill all \
  && rm -rf "$GNUPGHOME" \
  && grep " node-v$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
  && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
  # smoke tests
  && node --version \
  && npm --version

# RUN mkdir /opt/node-${NODE_VERSION} &&\
#     cd /opt/node-${NODE_VERSION} &&\
#     curl -fsSLO --compressed "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${ARCH}.tar.xz" &&\
#     curl -fsSLO --compressed "https://nodejs.org/dist/v${NODE_VERSION}/SHASUMS256.txt.asc" &&\
#     gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc

# Install pnpm
# RUN corepack enable \
#     && corepack prepare pnpm@latest-8 --activate

# Remove OpenCV sources and build folder
# RUN rm -rf /opt/opencv-${OPENCV_VERSION} && rm -rf /opt/opencv_contrib-${OPENCV_VERSION}

# FROM nvidia/cuda:12.2.2-cudnn8-runtime-ubuntu22.04 as runtime
