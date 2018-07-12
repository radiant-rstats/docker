git pull
docker login
docker build -t $USER/r-bionic ./r-bionic
docker push $USER/r-bionic
# docker build -t $USER/radiant ./radiant
docker build --no-cache -t $USER/radiant ./radiant
docker push $USER/radiant
docker build -t $USER/rsm-msba ./rsm-msba
docker push $USER/rsm-msba
