- [Official CUDA images](https://hub.docker.com/r/nvidia/cuda/)
- [Your GPU Compute Capability](https://developer.nvidia.com/cuda-gpus)

https://github.com/nodejs/docker-node/blob/main/18/bullseye/Dockerfile

```sh
export OPENCV_VERSION=4.8.1
export CUDA_ARCH_BIN=8.0

cd /opt/opencv-4.8.1/build

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
  -D CMAKE_INSTALL_PREFIX=/usr/local \
  ..
```
