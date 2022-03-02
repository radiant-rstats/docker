#!/bin/bash

# git pull
docker login

#mkdir -vp ~/.docker/cli-plugins/
#curl --silent -L "https://github.com/docker/buildx/releases/download/v0.6.3/buildx-v0.6.3.linux-amd64" > ~/.docker/cli-plugins/docker-buildx
#chmod a+x ~/.docker/cli-plugins/docker-buildx

DOCKERHUB_VERSION=2.2.0
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

if [ "$(uname -m)" = "arm64" ]; then
  LABEL=rsm-jupyter
  build
else
  LABEL=rsm-jupyter-rs
  build
fi

exit

LABEL=r-focal
build

# if you use the line
# below, manually remove the 'allow' section afterwards
# launcher "radiant" "Radiant" "shiny-apps"

LABEL=radiant
build

## making list of vsix files to install using "setup"
rm -f ../docker-vsix/vsix_list.txt
touch ../docker-vsix/vsix_list.txt
cd ../docker-vsix
vsix_list=$(ls -d *.vsix 2>/dev/null)
cd -
for i in ${vsix_list}; do
  echo "https://github.com/radiant-rstats/docker-vsix/raw/master/${i}" >> ../docker-vsix/vsix_list.txt
done

LABEL=rsm-msba
build

LABEL=rsm-msba-spark
build
launcher "rsm-msba"

## replace 127.0.0.1 by 0.0.0.0 for ChromeOS
cp -p ./launch-rsm-msba-spark.sh ./launch-rsm-msba-spark-chromeos.sh 
sed_fun "s/127.0.0.1/0.0.0.0/g" ./launch-rsm-msba-spark-chromeos.sh 
sed_fun "s/ostype=\"Linux\"/ostype=\"ChromeOS\"/" ./launch-rsm-msba-spark-chromeos.sh 

LABEL=rsm-jupyterhub
build

## new containers should be launched using the newest version of the container
docker tag vnijs/rsm-jupyterhub:latest jupyterhub-user

## new containers should be launched using the newest version of the container
docker tag vnijs/rsm-jupyterhub:latest jupyterhub-test-user

# LABEL=rsm-jupyterhub-no-gpu
# build

exit

# testing for Rstudio Preview
# docker tag jupyterhub-test-user vnijs/jupyterhub-test-user
# docker push vnijs/jupyterhub-test-user:latest

cp r-focal/userconf.sh rsm-vscode/userconf.sh
cp r-focal/launch.sh rsm-vscode/launch.sh
# cp rsm-msba/requirements.txt rsm-vscode/requirements.txt
cp rsm-msba/requirements-base.txt rsm-vscode/requirements.txt
cp rsm-msba/clean.sh rsm-vscode/clean.sh
cp rsm-msba/pg_hba.conf rsm-vscode/pg_hba.conf
cp rsm-msba/postgresql.conf rsm-vscode/postgresql.conf
cp rsm-msba-spark/requirements.txt rsm-vscode/requirements_spark.txt
cp rsm-msba-spark/hadoop-config/core-site.xml rsm-vscode/hadoop-config/core-site.xml 
cp rsm-msba-spark/hadoop-config/hdfs-site.xml rsm-vscode/hadoop-config/hdfs-site.xml 

LABEL=rsm-vscode
build

## to connec on a server use
# ssh -t vnijs@rsm-compute-01.ucsd.edu docker run -it -v ~:/home/jovyan vnijs/rsm-vscode /bin/bash;

# git add .
# git commit -m "Update to image version ${DOCKERHUB_VERSION}"
# git push

