
REF="vnijs/r-bionic"
# REF="vnijs/radiant"
# REF="vnijs/rsm-msba"
# REF="vnijs/rsm-msba-spark"
REF="vnijs/rsm-jupyterhub"
# REF="vnijs/rsm-vscode"
TAG="1.7.2"

docker image ls --filter reference=$REF --filter before=$REF:$TAG

echo "------------------------------------------"
echo "Remove listed docker images? (yes/no)"
echo "------------------------------------------"
read remove_old
if [ $remove_old == "yes" ]; then
  docker rmi $(docker image ls -q --all --filter reference=$REF --filter before=$REF:$TAG)
fi
