FROM node:18-alpine
WORKDIR /usr/src/app

ENV OPENCV_BUILD_ROOT=/usr/src/opencv
ENV OPENCV4NODEJS_AUTOBUILD_OPENCV_VERSION=4.8.1

# install necessary build tools and libraries to compile opencv
RUN apk add --update --no-cache \
    build-base \
    cmake \
    git \
    linux-headers \
    python3

# install and build opencv
RUN npm i -g @u4/opencv4nodejs
