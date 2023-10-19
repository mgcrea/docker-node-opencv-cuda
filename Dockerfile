FROM node:18-alpine
WORKDIR /usr/src/app

ENV OPENCV_BUILD_ROOT=/usr/src/opencv
ENV OPENCV4NODEJS_AUTOBUILD_OPENCV_VERSION=4.8.1
ENV OPENCV4NODEJS_AUTOBUILD_FLAGS=-DWITH_CUDA=ON -DWITH_CUDNN=ON -DOPENCV_DNN_CUDA=ON -DCUDA_FAST_MATH=ON
# ENV OPENCV4NODEJS_AUTOBUILD_FLAGS=-DBUILD_LIST=dnn

# install necessary build tools and libraries to compile opencv
RUN apk add --update --no-cache \
    build-base \
    cmake \
    git \
    linux-headers \
    python3

# install and build opencv
RUN npm i --global --loglevel verbose @u4/opencv4nodejs
