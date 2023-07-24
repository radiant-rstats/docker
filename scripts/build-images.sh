#!/bin/bash

# git pull
docker login

## moving to msba-arm and msba-intel tags
# docker pull vnijs/rsm-msba-arm:2.7.0
# docker tag vnijs/rsm-msba-arm:2.7.0 vnijs/rsm-msba-arm:2.7.0
# docker push vnijs/rsm-msba-arm:2.7.0

# docker tag vnijs/rsm-msba-arm:2.7.0 vnijs/rsm-msba-arm:latest
# docker push vnijs/rsm-msba-arm:latest

# docker pull vnijs/rsm-msba-intel:2.7.0
# docker tag vnijs/rsm-msba-intel:2.7.0 vnijs/rsm-msba-intel:2.7.0
# docker push vnijs/rsm-msba-intel:2.7.0

# docker pull vnijs/rsm-msba-intel:2.7.0
# docker tag vnijs/rsm-msba-intel:2.7.0 vnijs/rsm-msba-intel:latest
# docker push vnijs/rsm-msba-intel:latest

# docker pull vnijs/rsm-jupyterhub:2.7.0
# docker tag vnijs/rsm-jupyterhub:2.7.0 vnijs/rsm-msba-intel-jupyterhub:2.7.0
# docker tag vnijs/rsm-msba-intel-jupyterhub:2.7.0 vnijs/rsm-msba-intel-jupyterhub:latest
# docker push vnijs/rsm-msba-intel-jupyterhub:2.7.0
# docker push vnijs/rsm-msba-intel-jupyterhub:latest




# mkdir -vp ~/.docker/cli-plugins/
# # curl --silent -L "https://github.com/docker/buildx/releases/download/v0.6.3/buildx-v0.6.3.linux-amd64" > ~/.docker/cli-plugins/docker-buildx
# curl --silent -L "https://github.com/docker/buildx/releases/download/v0.6.3/buildx-v0.6.3.linux-arm64" > ~/.docker/cli-plugins/docker-buildx
# chmod a+x ~/.docker/cli-plugins/docker-buildx

DOCKERHUB_VERSION=2.7.0
JHUB_VERSION=2.7.0
# JHUB_VERSION=2.6.5
DOCKERHUB_USERNAME=vnijs
UPLOAD="NO"
# UPLOAD="YES"

if [ "$(uname -m)" = "arm64" ]; then
  ARCH="linux/arm64"
else
  ARCH="linux/amd64"
  # ARCH="linux/amd64,linux/arm64"
fi

build () {
  {
    ## using buildx to create multi-platform images
    ## run commands below the first time you build for platforms
    # docker buildx create --use
    # docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
    # docker buildx rm builder
    # docker buildx create --name builder --driver docker-container --use
    # docker buildx inspect --bootstrap
    if [[ "$1" == "NO" ]]; then
      # docker buildx build --progress=plain --load --platform ${ARCH} --build-arg DOCKERHUB_VERSION_UPDATE=${DOCKERHUB_VERSION} --no-cache --tag $DOCKERHUB_USERNAME/${LABEL}:latest --tag $DOCKERHUB_USERNAME/${LABEL}:$DOCKERHUB_VERSION ./${LABEL}
      docker buildx build -f "${LABEL}/Dockerfile" --progress=plain --load --platform ${ARCH} --build-arg DOCKERHUB_VERSION_UPDATE=${DOCKERHUB_VERSION} --no-cache --tag $DOCKERHUB_USERNAME/${LABEL}:latest --tag $DOCKERHUB_USERNAME/${LABEL}:$DOCKERHUB_VERSION .
    else
      # docker buildx build --progress=plain --load --platform ${ARCH} --build-arg DOCKERHUB_VERSION_UPDATE=${DOCKERHUB_VERSION} --tag $DOCKERHUB_USERNAME/${LABEL}:latest --tag $DOCKERHUB_USERNAME/${LABEL}:$DOCKERHUB_VERSION ./${LABEL}
      docker buildx build -f "${LABEL}/Dockerfile" --progress=plain --load --platform ${ARCH} --build-arg DOCKERHUB_VERSION_UPDATE=${DOCKERHUB_VERSION} --tag $DOCKERHUB_USERNAME/${LABEL}:latest --tag $DOCKERHUB_USERNAME/${LABEL}:$DOCKERHUB_VERSION .
    fi
  } || {
    echo "-----------------------------------------------------------------------"
    echo "Docker build for ${LABEL} was not successful"
    echo "-----------------------------------------------------------------------"
    sleep 3s
    exit 1
  }
  if [ "${UPLOAD}" == "YES" ]; then
    docker tag $USER/${LABEL}:latest $USER/${LABEL}:${DOCKERHUB_VERSION}
    docker push $USER/${LABEL}:${DOCKERHUB_VERSION}
    docker push $USER/${LABEL}:latest
  fi
}

# what os is being used
ostype=`uname`
if [[ "$ostype" == "Darwin" ]]; then
  sed_fun () {
    sed -i '' -e $1 $2
  }
else
  sed_fun () {
    sed -i $1 $2
  }
fi

launcher () {
  cp -p ./launch-$1.sh ./launch-${LABEL}.sh
  sed_fun "s/^LABEL=\"$1\"/LABEL=\"${LABEL}\"/" ./launch-${LABEL}.sh
  sed_fun "s/launch-$1\.sh/launch-${LABEL}\.sh/" ./launch-${LABEL}.sh
  if [ "$2" != "" ] && [ "$3" != "" ]; then
    sed_fun "s/$2/$3/" ./launch-${LABEL}.sh
  fi
}

LABEL=rsm-code-interpreter
build

exit 0

if [ "$(uname -m)" = "arm64" ]; then
  LABEL=rsm-msba-arm
  build
else
  LABEL=rsm-msba-intel
  build

  ## replace 127.0.0.1 by 0.0.0.0 for ChromeOS
  cp -p ./launch-rsm-msba-intel.sh ./launch-rsm-msba-intel-chromeos.sh
  sed_fun "s/127.0.0.1/0.0.0.0/g" ./launch-rsm-msba-intel-chromeos.sh
  sed_fun "s/ostype=\"Linux\"/ostype=\"ChromeOS\"/" ./launch-rsm-msba-intel-chromeos.sh

  LABEL=rsm-msba-intel-jupyterhub
  build

  ## new containers should be launched using the newest version of the container
  docker tag vnijs/rsm-msba-intel-jupyterhub:$JHUB_VERSION jupyterhub-user

  ## new containers should be launched using the newest version of the container
  #docker tag vnijs/rsm-msba-intel-jupyterhub:latest jupyterhub-test-user
fi

## to connec on a server use
# ssh -t vnijs@rsm-compute-01.ucsd.edu docker run -it -v ~:/home/jovyan vnijs/rsm-msba-intel-jupyterhub /bin/bash;
