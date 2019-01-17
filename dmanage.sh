#!/bin/bash

## based on https://stackoverflow.com/a/32723285/1974918
# imgs=$(docker images)
# imgs+=('foo')
# echo $imgs

#imgs=$(awk '{print $0 $1 $2}')
#echo $imgs
# $imgs | sed 's/\t/,|,/g' | column -s ',' -t

# imgs=$(docker images | awk '!/<none>/' | awk '!/<none>/ { print $1 }')
imgs=($(docker images | awk '!/<none>/ { print $1 }' | tail -n+2))
vers=($(docker images | awk '!/<none>/ { print $2 }' | tail -n+2))

echo $imgs
echo ${imgs[2]}
echo ${imgs[3]}
echo ${vers[2]}
echo ${vers[3]}
itt=(1 2 3 4 5)

list_images () {
  echo "Press ($1) to delete ... ${imgs[$1]}:${vers[$1]} followed by [ENTER]:"
}
# for img in ${imgs}; do
for i in ${itt}; do
  list_images $i
done


# running=$(docker ps -q)
# if [ "${running}" != "" ]; then
#   echo "Stopping running containers ..."
#   docker stop ${running}
# else
#   echo "No running containers"
# fi
#
# imgs=$(docker images | awk '/<none>/ { print $3 }')
# if [ "${imgs}" != "" ]; then
#   echo "Removing unused containers ..."
#   docker rmi ${imgs}
# else
#   echo "No images to remove"
# fi
#
# procs=$(docker ps -a -q --no-trunc)
# if [ "${procs}" != "" ]; then
#   echo "Removing errand docker processes ..."
#   docker rm ${procs}
# else
#   echo "No processes to purge"
# fi
#
