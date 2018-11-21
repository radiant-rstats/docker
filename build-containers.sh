git pull
docker login
VERSION=0.9.7

## r-bionic
#docker build -t $USER/r-bionic:latest ./r-bionic
## docker build --no-cache -t $USER/r-bionic:latest ./r-bionic
#docker tag $USER/r-bionic:latest $USER/r-bionic:${VERSION}
#docker push $USER/r-bionic:${VERSION}; docker push $USER/r-bionic:latest

## radiant
#docker build -t $USER/radiant:latest ./radiant
## docker build --no-cache -t $USER/radiant ./radiant
#docker tag $USER/radiant:latest $USER/radiant:${VERSION}
#docker push $USER/radiant:${VERSION}; docker push $USER/radiant:latest

## rsm-msba
#docker build -t $USER/rsm-msba:latest ./rsm-msba
## docker build --no-cache -t $USER/rsm-msba ./rsm-msba
#docker tag $USER/rsm-msba:latest $USER/rsm-msba:${VERSION}
#docker push $USER/rsm-msba:${VERSION}; docker push $USER/rsm-msba:latest

## rsm-msba
IMAGE=rsm-msba
docker build -t $USER/${IMAGE}:latest ./${IMAGE}
# docker build --no-cache -t $USER/${IMAGE} ./${IMAGE}
docker tag $USER/${IMAGE}:latest $USER/${IMAGE}:${VERSION}
docker push $USER/${IMAGE}:${VERSION}; docker push $USER/${IMAGE}:latest

## rsm-msba-spark
IMAGE=rsm-msba-spark
docker build -t $USER/${IMAGE}:latest ./${IMAGE}
# docker build --no-cache -t $USER/${IMAGE} ./${IMAGE}
docker tag $USER/${IMAGE}:latest $USER/${IMAGE}:${VERSION}
docker push $USER/${IMAGE}:${VERSION}; docker push $USER/${IMAGE}:latest

## rsm-msba-beakerx
IMAGE=rsm-msba-beakerx
docker build -t $USER/${IMAGE}:latest ./${IMAGE}
# docker build --no-cache -t $USER/${IMAGE} ./${IMAGE}
docker tag $USER/${IMAGE}:latest $USER/${IMAGE}:${VERSION}
docker push $USER/${IMAGE}:${VERSION}; docker push $USER/${IMAGE}:latest

