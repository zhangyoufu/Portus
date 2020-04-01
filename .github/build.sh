#!/bin/bash
set -ex

# change Docker daemon config
if [ -f /etc/docker/daemon.json ]; then
	DOCKERD_CONFIG=$(sudo cat /etc/docker/daemon.json)
else
	DOCKERD_CONFIG={}
fi
DOCKERD_CONFIG=$(jq '.+{experimental:true}' <<<"${DOCKERD_CONFIG}")
sudo tee /etc/docker/daemon.json <<<"${DOCKERD_CONFIG}"
sudo systemctl restart docker

# generate patch
git remote add upstream https://github.com/SUSE/Portus.git
git fetch upstream master
git diff upstream/master -- . ':!.github' >.github/docker/portus.patch

# build docker image and push
docker build --squash --tag "${IMAGE_PATH}" .github/docker/
docker login -u "${REGISTRY_USERNAME}" -p "${REGISTRY_PASSWORD}" "${IMAGE_PATH%%/*}"
docker push "${IMAGE_PATH}"
