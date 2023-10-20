PLATFORM:=linux/amd64
IMAGE:=$(USER)/$(shell basename $(CURDIR))
TAG:=18-cuda-12.2.2-cudnn8-runtime-ubuntu22.04

all: build

run:
	@docker run -it --rm --platform $(PLATFORM) $(IMAGE):$(TAG) /bin/bash

build:
	@docker build --platform $(PLATFORM) --tag $(IMAGE):$(TAG) .

.PHONY: all
