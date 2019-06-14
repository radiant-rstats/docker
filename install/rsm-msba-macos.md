# Contents
  - [Installing the RSM-MSBA computing environment on macOS](#installing-the-rsm-msba-computing-environment-on-macos) 
  - [Updating the RSM-MSBA computing environment on macOS](#updating-the-rsm-msba-computing-environment-on-macos) 
  - [Connecting to postgresql](#connecting-to-postgresql)
  - [Installing R and Python packages locally](#installing-r-and-python-packages-locally)
  - [Cleanup](#cleanup)
  - [Trouble shooting](#trouble-shooting)

## Installing the RSM-MSBA computing environment on macOS

Please follow the instructions below to install the rsm-msba-spark computing environment. It has R, Rstudio, Python, Jupyter Lab, and various required packages pre-installed. The computing environment will be consistent across all students and faculty, easy to update, and also easy to remove if desired (i.e., there will *not* be dozens of pieces of software littered all over your computer).

**Step 1**: Install docker from the link below and make sure it is running. You will know it is running if you see the icon below at the top-right of your screen. If the containers in the image are moving up and down docker hasn't finished starting up yet.

![](figures/docker-icon.png)

https://download.docker.com/mac/stable/Docker.dmg

You can also change the (maximum) resources docker is allowed to use on your system. You can set this to approximately 50% of the maximum available on your system.

<img src="figures/docker-resources-mac.png" width="500px">

Optional: If you are interested, the linked video gives a brief intro to what Docker is: https://www.youtube.com/watch?v=YFl2mCHdv24

**Step 2**: Open a terminal and copy-and-paste the code below

You will need the macOS command line developer tools for the next steps. Follow the prompts until the software is installed.

```bash
xcode-select --install;
```

**Step 3**: Now copy-and-paste the code below

```bash
git clone https://github.com/radiant-rstats/docker.git ~/git/docker;
cp -p ~/git/docker/launch-rsm-msba-spark.sh ~/Desktop/launch-rsm-msba-spark.command;
~/Desktop/launch-rsm-msba-spark.command;
```

This step will clone and start up a script that will finalize the installation of the computing environment. The first time you run this script it will download the latest version of the computing environment which can take some time. Wait for the container to download and follow any prompts. Once the download is complete you should see a menu as in the screen shot below. 

<img src="figures/rsm-msba-menu-macos.png" width="500px">

The code above also creates a copy of the file `launch-rsm-msba-spark.command` on your Desktop that you can double-click to start the container again in the future.

Copy-and-paste the command below to create a shortcut to the launch script to use from the command line. 

```bash
ln -s ~/git/docker/launch-rsm-msba-spark.sh /usr/local/bin/launch;
```

**Step 4**: Check that you can launch Rstudio and Jupyter

You will know that the installation was successful if you can start Rstudio and Jupyter Lab. When you press 2 (and Enter) in the terminal, Rstudio should start up in your default web browser. If you press 3 (and Enter) Jupyter Lab should start up in another tab in your web browser. For Rstudio the username is "jovyan" and the password is "rstudio". For Jupyter the password is "jupyter".

> Important: Always use q (and Enter) to shutdown the computing environment

**Rstudio**:

<img src="figures/rsm-rstudio.png" width="500px">

**Jupyter**:

<img src="figures/rsm-jupyter.png" width="500px">

## Updating the RSM-MSBA computing environment on macOS

To update the container use the launch script and press 5 (+ enter). To update the launch script itself, press 6 (+ enter).

<img src="figures/rsm-msba-menu-macos.png" width="500px">

If for some reason you are having trouble updating either the container or the launch script open a terminal and copy-and-paste the code below. These commands will update the docker container, replace the old docker related scripts, and copy the latest version of the launch script to your Desktop.

```bash
docker pull vnijs/rsm-msba-spark;
rm -rf ~/git/docker;
git clone https://github.com/radiant-rstats/docker.git ~/git/docker;
cp -p ~/git/docker/launch-rsm-msba-spark.sh ~/Desktop/launch-rsm-msba-spark.command;
```

## Connecting to postgresql

The rsm-msba-spark container comes with <a href="http://www.postgresqltutorial.com" target="_blank">postgresql</a> installed. Once the container has been started, you can access postgresql from Rstudio using the code below:

```r
## connect to database
library(DBI)
library(RPostgreSQL)
con <- dbConnect(
  dbDriver("PostgreSQL"),
  user = "jovyan",
  host = "127.0.0.1",
  port = 8765,
  dbname = "rsm-docker",
  password = "postgres"
)

## show list of tables
dbListTables(con)
```

For a more extensive example using R see: <a href="https://github.com/radiant-rstats/docker/blob/master/postgres/postgres-connect.md target="_blank">https://github.com/radiant-rstats/docker/blob/master/postgres/postgres-connect.md</a>

To access postgresql from Jupyter Lab using the code below:

```py
## connect to database
from sqlalchemy import create_engine
engine = create_engine('postgresql://jovyan:postgres@127.0.0.1:8765/rsm-docker')

## show list of tables
engine.table_names()
```

For a more extensive example using Python see: <a href="https://github.com/radiant-rstats/docker/blob/master/postgres/postgres-connect.ipynb" target="_blank">https://github.com/radiant-rstats/docker/blob/master/postgres/postgres-connect.ipynb</a>

## Installing R and Python packages locally

To install R packages that will persist after restarting the docker container, enter code like the below in Rstudio and follow any prompts:

`install.packages("fortunes", lib = Sys.getenv("R_LIBS_USER"))`

To install Python modules that will persist after restarting the docker container, enter code like the below from the terminal in Jupyter Lab:

`pip3 install --user redis`

After installing a module you will have to restart any running Python kernels to `import` the module in your code.

To remove locally installed R packages press 7 (and Enter) in the launch menu and follow the prompts. To remove locally installed Python modules press 8 (and Enter) in the launch menu. 

## Cleanup

To remove any prior Rstudio sessions, and locally installed R-packages, press 6 (and Enter) in the launch menu. To remove locally installed Python modules press 7 (and Enter) in the launch menu.

You should always stop the `rsm-msba-spark` docker container using `q` (and Enter) in the launch menu. If you want a full cleanup and reset of the computational environment on your system, however, execute the following commands from a (bash) terminal to (1) remove prior R(studio) and Python settings, (2) remove all docker images, networks, and (data) volumes, and (3) 'pull' only the docker image you need (e.g., rsm-msba-spark):

```bash
rm -rf ~/.rstudio;
rm -rf ~/.rsm-msba;
docker system prune --all --volumes --force;
docker pull vnijs/rsm-msba-spark;
```

## Trouble shooting

The only issues we have seen on macOS so far can be addressed by restarting docker and/or restarting your computer

## Optional

To install python3 on macOS using **homebrew**, run the commands below from a terminal:

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)";
brew install python3;
```
