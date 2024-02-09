#!/bin/bash

IMAGE_TYPE="${IMAGE_TYPE:-runtime}" # runtime | devel
REGISTRY="docker.io"
OWNER=mgcrea
PLATFORM="linux/amd64"
ROOT_IMAGE_NAME="mgcrea/node-opencv-cuda"
ROOT_IMAGE_TAG="18-opencv-4-cuda-12-cudnn8-${IMAGE_TYPE}-ubuntu22.04"
GIT_FOLDER="repo/docker-stacks"

echo "Cloning jupyter/docker-stacks repository..."
if [ ! -d "${GIT_FOLDER}" ]; then
  mkdir $(dirname ${GIT_FOLDER});
  git clone -o github git@github.com:jupyter/docker-stacks.git ${GIT_FOLDER}
  cd ${GIT_FOLDER}
else
  cd ${GIT_FOLDER}
  git pull
fi

echo "Building images..."
REGISTRY="${REGISTRY}" OWNER="${OWNER}" make build/docker-stacks-foundation DOCKER_BUILD_ARGS="--platform linux/amd64 --build-arg ROOT_CONTAINER=${ROOT_IMAGE_NAME}:${ROOT_IMAGE_TAG}"
REGISTRY="${REGISTRY}" OWNER="${OWNER}" make build/base-notebook DOCKER_BUILD_ARGS="--platform linux/amd64 --build-arg BASE_CONTAINER=${OWNER}/docker-stacks-foundation:latest"
REGISTRY="${REGISTRY}" OWNER="${OWNER}" make build/minimal-notebook DOCKER_BUILD_ARGS="--platform linux/amd64 --build-arg BASE_CONTAINER=${OWNER}/base-notebook:latest"
REGISTRY="${REGISTRY}" OWNER="${OWNER}" make build/scipy-notebook DOCKER_BUILD_ARGS="--platform linux/amd64 --build-arg BASE_CONTAINER=${OWNER}/minimal-notebook:latest"
REGISTRY="${REGISTRY}" OWNER="${OWNER}" make build/pytorch-notebook DOCKER_BUILD_ARGS="--platform linux/amd64 --build-arg BASE_CONTAINER=${OWNER}/scipy-notebook:latest"

echo "Tagging & Pushing images to ${REGISTRY}..."

images=("docker-stacks-foundation" "base-notebook" "minimal-notebook" "scipy-notebook" "pytorch-notebook")

for image in "${images[@]}"
do
  echo "$image"
  docker tag ${OWNER}/${image}:latest ${OWNER}/${image}:${ROOT_IMAGE_TAG}
  docker push ${OWNER}/${image}:latest && docker push ${OWNER}/${image}:${ROOT_IMAGE_TAG}
done
