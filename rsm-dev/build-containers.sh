git pull
docker login
DOCKERHUB_VERSION=1.2.1
UPLOAD="NO"
UPLOAD="YES"

build () {
  {
    if [[ "$1" == "NO" ]]; then
      docker build --build-arg DOCKERHUB_VERSION_UPDATE=${DOCKERHUB_VERSION} --no-cache -t $USER/${LABEL}:latest ./${LABEL}
    else
      docker build --build-arg DOCKERHUB_VERSION_UPDATE=${DOCKERHUB_VERSION} -t $USER/${LABEL}:latest ./${LABEL}
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
  cp -p ./launch-$1.sh ./launch-${LABEL}.sh
  sed_fun "s/^LABEL=\"$1\"/LABEL=\"${LABEL}\"/" ./launch-${LABEL}.sh
  sed_fun "s/launch-$1\.sh/launch-${LABEL}\.sh/" ./launch-${LABEL}.sh
  if [ "$2" != "" ] && [ "$3" != "" ]; then
    sed_fun "s/$2/$3/" ./launch-${LABEL}.sh
  fi
}

LABEL=rsm-dev
build
# launcher "rsm-msba"

# git add .
# git commit -m "Updating the development version"
# git push
