## pull the latest version of all generated from radiant-stats/docker 
img_list=(r-focal radiant rsm-msba rsm-msba-spark rsm-jupyterhub rsm-vscode)

for img in ${img_list[@]}; do
   docker pull vnijs/${img}
done
