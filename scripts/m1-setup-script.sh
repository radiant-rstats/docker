# move to m1 ARM image
docker image rm vnijs/rsm-msba-spark:latest;
docker pull raghavprasad13/rsm-msba-spark:latest;
cd ~/git/docker;
git pull;
cp -p ~/git/docker/launch-rsm-msba-spark-m1.sh ~/Desktop/launch-rsm-msba-spark-m1.command;
chmod 755 ~/Desktop/launch-rsm-msba-spark-m1.command;
~/Desktop/launch-rsm-msba-spark-m1.command -v ~;

# to revert if needed
# docker image rm raghavprasad13/rsm-msba-spark:latest;
# docker pull vnijs/rsm-msba-spark:latest
# cp -p ~/git/docker/launch-rsm-msba-spark.sh ~/Desktop/launch-rsm-msba-spark.command;
# chmod 755 ~/Desktop/launch-rsm-msba-spark.command;
# ~/Desktop/launch-rsm-msba-spark.command -v ~;
