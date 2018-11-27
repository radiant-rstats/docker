git pull
docker login
VERSION=0.9.9

## r-bionic
IMAGE=r-bionic
# docker build -t $USER/${IMAGE}:latest ./${IMAGE}
docker build --no-cache -t $USER/${IMAGE} ./${IMAGE}
docker tag $USER/${IMAGE}:latest $USER/${IMAGE}:${VERSION}
docker push $USER/${IMAGE}:${VERSION}; docker push $USER/${IMAGE}:latest

## radiant
IMAGE=radiant
docker build -t $USER/${IMAGE}:latest ./${IMAGE}
# docker build --no-cache -t $USER/${IMAGE} ./${IMAGE}
docker tag $USER/${IMAGE}:latest $USER/${IMAGE}:${VERSION}
docker push $USER/${IMAGE}:${VERSION}; docker push $USER/${IMAGE}:latest

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
## docker build --no-cache -t $USER/${IMAGE} ./${IMAGE}
docker tag $USER/${IMAGE}:latest $USER/${IMAGE}:${VERSION}
docker push $USER/${IMAGE}:${VERSION}; docker push $USER/${IMAGE}:latest
