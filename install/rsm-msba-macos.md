## Installing the RSM-MSBA computing environment on macOS

Please follow the instructions below to install the computing environment we will use in the MSBA program. The environment has R, Rstudio, Python, and Jupyter lab + plus required packages pre-installed. The environment will be consistent across all students and faculty, easy to update, and also easy to remove if desired (i.e., there will *not* be dozens of pieces of software littered all over your computer).

Important: You *must* complete the installation before our first class session on 8/6 or you will not be able to work on in-class exercises!

**Step 1**: Install docker from the link below and make sure it is running. You will know it is running if you see the icon below at the top-right of your screen. If the containers in the image are moving up and down docker hasn't finished starting up yet.

![](figures/docker-icon.png)

https://download.docker.com/mac/stable/Docker.dmg

You can also change the (maximum) resources docker is allowed to use on your system. You can set this (close) to the maximum available on your system.

<img src="figures/docker-resources-mac.png" width="500px">

Optional: If you are interested, the linked video gives a brief intro to what Docker is: https://www.youtube.com/watch?v=YFl2mCHdv24

**Step 2**: Open a terminal and copy-and-paste the code below

You will need the macOS command line developer tools for next steps. Follow the prompts until the software is installed.

```bash
xcode-select --install
```

**Step 3**: Now copy-and-paste the code below

```bash
git clone https://github.com/radiant-rstats/docker.git ~/git/docker
cp -p ~/git/docker/launch-rsm-msba.sh ~/Desktop/launch-rsm-msba.command
~/Desktop/launch-rsm-msba.command
```

This step will clone and start up a script that will finalize the installation of the computing environment. The first time you run this script it will download the latest version of the computing environment. Wait for the container to download and follow any prompts. Once the download is complete you should see a menu as in the screen shot below. You can press 2 (and Enter) to start Rstudio. Press 3 (and Enter) to start Jupyter Lab. Press q to quit. For Rstudio the username and password are both "rstudio". For Jupyter the password is "jupyter"

![](figures/rsm-msba-menu.png)

The code above also created a copy of the file `launch-rsm-msba.command` on your Desktop that you can double-click to "fire up" the container again in the future.

**Step 4**: Check that you can launch Rstudio and Jupyter

You will know that installation was successful if you can now run Rstudio and Jupyter. When you press 2 (+ enter) in the terminal, Rstudio should start up in your default web browser. If you press 3 (+ enter) Jupyter Lab should start up in another tab in your web browser. 

As mentioned above, for Rstudio the username and password are both "rstudio". For Jupyter Lab the password is "jupyter".

**Rstudio**:

<img src="figures/rsm-rstudio.png" width="500px">

**Jupyter**:

<img src="figures/rsm-jupyter.png" width="500px">

## Updating the RSM-MSBA computing environment on macOS

To update the container use the launch script and press 6 (+ enter). To update the launch script itself, press 7 (+ enter).

![](figures/rsm-msba-menu.png)

If for some reason you are having trouble updating either the container or the launch script open a terminal and copy-and-paste the code below. These commands will update the docker container, replace the old docker related scripts, and copy the latest version of the launch script to your Desktop.

```bash
docker pull vnijs/rsm-msba
rm -rf ~/git/docker
git clone https://github.com/radiant-rstats/docker.git ~/git/docker
cp -p ~/git/docker/launch-rsm-msba.sh ~/Desktop/launch-rsm-msba.command
```

## Extended functionality with Apache Spark

To extend the functionality of the computing container with `Apache Spark`, `pyspark`, and `sparklyr` copy the `launch-rsm-msba-spark.sh` scrpit from the `git/docker` directory to your desktop and rename it to `launch-rsm-msba-spark.command`. Starting up the script will update the computing environment. 

## Trouble shooting

The only issues we have seen on macOS so far can be "fixed" by restarting docker and/or restarting your computer
