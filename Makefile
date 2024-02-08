PLATFORM:=linux/amd64
IMAGE:=mgcrea/node-opencv-cuda
OPENCV_VERSION:=4.9.0
LTS_NODE_VERSION:=20.11.0

TAG:=18-opencv-4-cuda-12-cudnn8-runtime-ubuntu22.04
LTS_TAG:=20-opencv-4-cuda-12-cudnn8-runtime-ubuntu22.04
DEVEL_TAG:=18-opencv-4-cuda-12-cudnn8-devel-ubuntu22.04
LTS_DEVEL_TAG:=20-opencv-4-cuda-12-cudnn8-devel-ubuntu22.04

all: build

env:
	@echo ${IMAGE}

bash:
	@docker run -it --rm --platform $(PLATFORM) $(IMAGE):$(TAG) /bin/bash

build:
	@docker build --platform $(PLATFORM) --build-arg OPENCV_VERSION=$(OPENCV_VERSION) --tag $(IMAGE):$(TAG) .

build-lts:
	@docker build --platform $(PLATFORM) --build-arg NODE_VERSION=$(LTS_NODE_VERSION) --tag $(IMAGE):$(LTS_TAG) .

build-devel:
	@docker build --file Dockerfile.devel --platform $(PLATFORM) --tag $(IMAGE):$(DEVEL_TAG) .

build-devel-lts:
	@docker build --file Dockerfile.devel --platform $(PLATFORM) --build-arg NODE_VERSION=$(LTS_NODE_VERSION) --tag $(IMAGE):$(LTS_DEVEL_TAG) .

.PHONY: all
