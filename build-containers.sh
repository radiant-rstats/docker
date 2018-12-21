git pull
docker login
DOCKERHUB_VERSION=1.0.1
UPLOAD="NO"
# UPLOAD="YES"

build () {
  {
    if [[ "$1" == "NO" ]]; then
      docker build --build-arg DOCKERHUB_VERSION=${DOCKERHUB_VERSION} --no-cache -t $USER/${LABEL}:latest ./${LABEL}
    else
      docker build --build-arg DOCKERHUB_VERSION=${DOCKERHUB_VERSION} -t $USER/${LABEL}:latest ./${LABEL}
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
    docker push $USER/${LABEL}:${DOCKERHUB_VERSION}; docker push $USER/${LABEL}:latest
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
  cp -p ./launch-rsm-msba.sh ./launch-${LABEL}.sh
  sed_fun "s/^LABEL=\"rsm-msba\"/LABEL=\"${LABEL}\"/" ./launch-${LABEL}.sh
  sed_fun "s/launch-rsm-msba\.sh/launch-${LABEL}\.sh/" ./launch-${LABEL}.sh
}

LABEL=r-bionic
build

LABEL=radiant
build

LABEL=rsm-msba
build

LABEL=rsm-msba-spark
build
launcher

LABEL=rsm-jupyterhub
build

# LABEL=rsm-msba-beakerx
# build
# launcher

# git add .
# git commit -m "Update to image version ${DOCKHUB_VERSION}"
# git push
