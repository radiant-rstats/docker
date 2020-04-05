git pull
docker login
DOCKERHUB_VERSION=1.7.2
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

LABEL=r-bionic
build
# if you use the line below, manually remove the 'allow' section afterwards
# launcher "radiant" "Radiant" "shiny-apps"

LABEL=radiant
build

## making list of vsix files to install using "setup"
rm -f ./rsm-msba/vsix/vsix_list.txt
touch ./rsm-msba/vsix/vsix_list.txt
vsix_list=$(ls -d ./rsm-msba/vsix/*.vsix 2>/dev/null)
for i in ${vsix_list}; do
  echo "https://github.com/radiant-rstats/docker/raw/master/${i}" >> ./rsm-msba/vsix/vsix_list.txt
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

exit

cp r-bionic/userconf.sh rsm-vscode/userconf.sh
cp r-bionic/launch.sh rsm-vscode/launch.sh
cp rsm-msba/requirements.txt rsm-vscode/requirements.txt
cp rsm-msba/clean.sh rsm-vscode/clean.sh
cp rsm-msba/pg_hba.conf rsm-vscode/pg_hba.conf
cp rsm-msba/postgresql.conf rsm-vscode/postgresql.conf
cp rsm-msba-spark/requirements.txt rsm-vscode/requirements_spark.txt

LABEL=rsm-vscode
build

# git add .
# git commit -m "Update to image version ${DOCKERHUB_VERSION}"
# git push

