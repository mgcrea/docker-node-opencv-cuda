# docker-node-opencv-cuda

## Features

Working OpenCV+CUDA Docker image for your Node.js applications.

- **powerful with GPU support:** Built on the latest [official CUDA images](https://hub.docker.com/r/nvidia/cuda) to enable CUDA-powered GPU acceleration.

- **streamlined:** Node is installed exactly like it is in the [official Node.js Dockerfile](https://github.com/nodejs/docker-node/blob/main/18/bullseye/Dockerfile) to enable out-of-the box support for application targeting existing node images.

- **lightweight:** We are using [Multi-stage builds](https://docs.docker.com/build/building/multi-stage/) to efficiently switch to a `devel` image used to build `opencv` to a lighter `runtime` image for the final release.

- **modern:** We are targeting the latest [OpenCV releases](https://github.com/opencv/opencv/releases) and plan to keep it up-to-date as much as possible.

## Getting started

- Using the command line interface:

```sh
docker pull mgcrea/node-opencv-cuda:18-opencv-4-cuda-12-cudnn8-runtime-ubuntu22.04
docker run -it --rm --runtime=nvidia --gpus all mgcrea/node-opencv-cuda:18-opencv-4-cuda-12-cudnn8-runtime-ubuntu22.04 nvidia-smi
```

- Using your own Dockerfile (basic example):

```dockerfile
FROM mgcrea/node-opencv-cuda:18-opencv-4-cuda-12-cudnn8-runtime-ubuntu22.04

# Install app
WORKDIR /app
COPY package.json .
COPY build ./build/
COPY node_modules ./node_modules/

EXPOSE 3000

CMD node .
```

## Notes

To fully leverage your GPU capabilities, you might need to tweak the `CUDA_ARCH_BIN` according to your GPU, you should check your [GPU Compute Capability](https://developer.nvidia.com/cuda-gpus) and build this image accordingly:

```sh
docker build --build-arg CUDA_ARCH_BIN=8.6 .
```

Multiple architectures can be supported with comma-separated values (eg. `CUDA_ARCH_BIN=8.0,8.6`).
