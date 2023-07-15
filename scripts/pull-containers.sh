## pull the latest version of all generated from radiant-stats/docker 
# img_list=(r-focal radiant rsm-msba rsm-msba-spark rsm-msba-intel-jupyterhub rsm-vscode)
img_list=(rsm-msba-arm rsm-msba-intel rsm-msba-intel-jupyterhub)

for img in ${img_list[@]}; do
   docker pull vnijs/${img}
done
