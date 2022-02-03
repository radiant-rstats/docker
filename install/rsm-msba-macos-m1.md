# Contents

- [Installing the RSM-MSBA computing environment on macOS M1](#installing-the-rsm-msba-computing-environment-on-macos-M1)
- [Updating the RSM-MSBA computing environment on macOS M1](#updating-the-rsm-msba-computing-environment-on-macos-M1)
- [Using VS Code for Python](#using-vs-code-for-python)
- [Connecting to postgresql](#connecting-to-postgresql)
- [Installing R and Python packages locally](#installing-r-and-python-packages-locally)
- [Committing changes to the computing environment](#committing-changes-to-the-computing-environment)
- [Cleanup](#cleanup)
- [Getting help](#getting-help)
- [Trouble shooting](#trouble-shooting)
- [Optional](#optional)

<!-- markdownlint-disable MD033 MD034 -->

## Installing the RSM-MSBA computing environment on macOS M1

Please follow the instructions below to install the rsm-msba-spark computing environment. It has R, Rstudio, Python, Jupyter Lab, Postgres, VS Code, Spark and various required packages pre-installed. The computing environment will be consistent across all students and faculty, easy to update, and also easy to remove if desired (i.e., there will *not* be dozens of pieces of software littered all over your computer).

**Step 1**: Install docker from the link below and make sure it is running. You will know it is running if you see the icon below at the top-right of your screen. If the containers in the image are moving up and down docker hasn't finished starting up yet.

![docker](figures/docker-icon.png)

[download docker for macOS with an M1 (ARM) chip](https://desktop.docker.com/mac/stable/arm64/Docker.dmg?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-mac-arm64)

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
cp -p ~/git/docker/launch-rsm-msba-spark-m1.sh ~/Desktop/launch-rsm-msba-spark-m1.command;
~/Desktop/launch-rsm-msba-spark-m1.command;
```

This step will clone and start up a script that will finalize the installation of the computing environment. The first time you run this script it will download the latest version of the computing environment which can take some time. Wait for the container to download and follow any prompts. Once the download is complete you should see a menu as in the screen shot below.

<img src="figures/rsm-msba-menu-macos.png" width="500px">

The code above also creates a copy of the file `launch-rsm-msba-spark-m1.command` on your Desktop that you can double-click to start the container again in the future.

Copy-and-paste the command below to create a shortcut to the launch script to use from the command line.

```bash
ln -s ~/git/docker/launch-rsm-msba-spark-m1.sh /usr/local/bin/launch;
```

**Step 4**: Check that you can launch Rstudio and Jupyter

You will know that the installation was successful if you can start Rstudio and Jupyter Lab. When you press 2 (and Enter) in the terminal, Rstudio should start up in your default web browser. If you press 3 (and Enter) Jupyter Lab should start up in another tab in your web browser. If you are asked for login credentials, the username is "jovyan" and the password is "jupyter". Have your browser remember the username and password so you won't be asked for it again. 

> Important: Always use q (and Enter) to shutdown the computing environment

**Rstudio**:

<img src="figures/rsm-rstudio.png" width="500px">

**Jupyter**:

<img src="figures/rsm-jupyter.png" width="500px">

To finalize the setup for Radiant, Rstudio, and VS Code open a terminal in either Rstudio or Jupyter lab and run the code below:

```bash
setup;
source ~/.zshrc;
```

**Radiant**:

To start Radiant, open RStudio and follow the steps in the picture below

<!-- ssh-copy-id -i ~/.ssh/id_rsa.pub username@rsm-compute-01.ucsd.edu -->

## Updating the RSM-MSBA computing environment on macOS M1

To update the container use the launch script and press 6 (+ enter). To update the launch script itself, press 7 (+ enter).

<img src="figures/rsm-msba-menu-macos.png" width="500px">

If for some reason you are having trouble updating either the container or the launch script open a terminal and copy-and-paste the code below. These commands will update the docker container, replace the old docker related scripts, and copy the latest version of the launch script to your Desktop.

```bash
docker pull raghavprasad13/rsm-msba-spark;
rm -rf ~/git/docker;
git clone https://github.com/radiant-rstats/docker.git ~/git/docker;
cp -p ~/git/docker/launch-rsm-msba-spark-m1.sh ~/Desktop/launch-rsm-msba-spark-m1.command;
```

## Using VS Code for Python

Microsoft's open-source integrated development environment (IDE), VS Code or Visual Studio Code, was the most popular development environment in according to a [Stack Overflow developer survey](https://insights.stackoverflow.com/survey/2018#development-environments-and-tools). VS Code is widely used by Google developers and is the [default development environment at Facebook](https://www.zdnet.com/article/facebook-microsofts-visual-studio-code-is-now-our-default-development-platform/).

VS Code can be launched from Jupyter and is an excellent, and very popular, editor for python. The video linked below will walk you through how to activate some key extensions for R and Python in VS Code.

<a href="https://youtu.be/VyauXgMuq18" target="_blank">https://youtu.be/VyauXgMuq18</a>

After running the setup command mentioned above, everything you need for python development will be available. To learn more about using VS Code to write python code see the links and comments below.

- <a href="https://code.visualstudio.com/docs/python/python-tutorial#_create-a-python-hello-world-source-code-file" target="_blank">VS Code Python Tutorial</a>

Note that you can use `Shift+Enter` to run the current line in a Python Interactive Window:

- <a href="https://code.visualstudio.com/docs/python/jupyter-support-py" target="_blank">Executing Python Code in VS Code</a>

When writing and editing python code you will have access to "Intellisense" for auto-completions. Your code will also be auto-formatted every time you save it using the "black" formatter.

- <a href="https://code.visualstudio.com/docs/python/editing" target="_blank">Editing Python in VS Code Python</a>

VS Code also gives you access to a debugger for your python code. For more information see the link below:

- <a href="https://code.visualstudio.com/docs/python/debugging" target="_blank">Debugging Python in VS Code Python</a>

- To convert a python code file to a Jupyter Notebook, use the code below from a terminal. You can open a terminal in VS Code by typing CTRL+`

```bash
jupytext --to notebook your-python-script.py
```

- To convert a Jupyter Notebook to a python code file, use the code below from a terminal. You can open a terminal in VS Code by typing CTRL+`

```bash
jupytext --to py your-python-script.ipynb
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

For a more extensive example using R see: <a href="https://github.com/radiant-rstats/docker/blob/master/postgres/postgres-connect.md" target="_blank">https://github.com/radiant-rstats/docker/blob/master/postgres/postgres-connect.md</a>

To access postgresql from Jupyter Lab using the code below:

```py
## connect to database
from sqlalchemy import create_engine
engine = create_engine('postgresql://jovyan:postgres@127.0.0.1:8765/rsm-docker')

## show list of tables
engine.table_names()
```

For a more extensive example using Python see: <a href="https://github.com/radiant-rstats/docker/blob/master/postgres/postgres-connect.ipynb" target="_blank">https://github.com/radiant-rstats/docker/blob/master/postgres/postgres-connect.ipynb</a>

### Trouble shooting

If you cannot connect to postgresql it is most likely due to an issue with the docker volume that contains the data. The volume can become corrupted if the container is not properly stopped using `q + Enter` in the launch menu. To create a clean volume for postgres (1) stop the running container using `q + Enter`, (2) run the code below in a terminal, and (3) restart the container. If you are still having issues connecting to the postgresql server, please reach out for support through Piazza.

```
docker volume rm pg_data
```

## Installing R and Python packages locally

To install the latest version of R-packages you need, add the lines of code shown below to `~/.Rprofile` or copy-and-paste the lines into the Rstudio console.

```
if (Sys.info()["sysname"] == "Linux") {
  options(repos = c(
    RSM = "https://rsm-compute-01.ucsd.edu:4242/rsm-msba/__linux__/focal/latest",
    RSPM = "https://packagemanager.rstudio.com/all/__linux__/focal/latest",
    CRAN = "https://cloud.r-project.org"
  ))
} else {
  options(repos = c(
    RSM = "https://radiant-rstats.github.io/minicran",
    CRAN = "https://cloud.r-project.org"
  ))
}
```

This will be done for you automatically if you run the `setup` command from a terminal inside the docker container. To install R packages that will persist after restarting the docker container, enter code like the below in Rstudio and follow any prompts. After doing this once, you can use `install.packages("some-other-package")` in the future.

```r
fs::dir_create(Sys.getenv("R_LIBS_USER"), recurse = TRUE)
install.packages("fortunes", lib = Sys.getenv("R_LIBS_USER"))
```

To install Python modules that will persist after restarting the docker container, enter code like the below from the terminal in Rstudio or Jupyter Lab:

`pip3 install --user pyrsm`

After installing a module you will have to restart any running Python kernels to `import` the module in your code.

To remove locally installed R packages press 8 (and Enter) in the launch menu and follow the prompts. To remove locally installed Python modules press 9 (and Enter) in the launch menu.


## Committing changes to the computing environment

By default re-starting the docker computing environment will remove any changes you made. This allows you to experiment freely, without having to worry about "breaking" things. However, there are times when you might want to keep changes.

As shown in the previous section, you can install R and Python packages locally rather than in the container. These packages will still be available after a container restart.

To install binary R packages for Ubuntu Linux you can use the command below. These packages will *not* be installed locally and would normally not be available after a restart.

```bash
sudo apt update;
sudo apt install r-cran-ada;
```

Similarly, some R-packages have requirements that need to be installed in the container (e.g., the `rgdal` package). The following two linux packages would need to be installed from a terminal in the container as follows:

```bash
sudo apt update;
sudo apt install libgdal-dev libproj-dev;
```

After completing the step above you can install the `rgdal` R-package locally using the following from Rstudio:

`install.packages("rgdal", lib = Sys.getenv("R_LIBS_USER"))`

To save (or commit) these changes so they *will* be present after a (container) restart type, for example, `c myimage` (and Enter). This creates a new docker image with your changes and also a new launch script on your Desktop with the name `launch-rsm-msba-spark-myimage.command` that you can use to launch your customized environment in the future.

If you want to share your customized version of the container with others (e.g., team members) you can push it is to Docker Hub <a href="https://hub.docker.com" target="_blank">https://hub.docker.com</a> by following the menu dialog after typing, e.g., `c myimage` (and Enter). To create an account on Docker Hub go to <a href="https://hub.docker.com/signup" target="_blank">https://hub.docker.com/signup</a>.

If you want to remove specific images from your computer run the commands below from a (bash) terminal. The first command generates a list of the images you have available.

`docker image ls;`

Select the IMAGE ID for the image you want to remove, e.g., `42b88eb6adf8`, and then run the following command with the correct image id:

`docker rmi 42b88eb6adf8;`

For additional resources on developing docker images see the links below:

- <https://colinfay.me/docker-r-reproducibility>
- <https://www.fullstackpython.com/docker.html>

## Cleanup

To remove any prior Rstudio sessions, and locally installed R-packages, press 8 (and Enter) in the launch menu. To remove locally installed Python modules press 9 (and Enter) in the launch menu.

> Note: It is also possible initiate the process of removing locally installed packages and settings from within the container. Open a terminal in Jupyter Lab or Rstudio and type `clean`. Then follow the prompts to indicate what needs to be removed.

You should always stop the `rsm-msba-spark` docker container using `q` (and Enter) in the launch menu. If you want a full cleanup and reset of the computational environment on your system, however, execute the following commands from a (bash) terminal to (1) remove prior R(studio) and Python settings, (2) remove all docker images, networks, and (data) volumes, and (3) 'pull' only the docker image you need (e.g., rsm-msba-spark):

```bash
rm -rf ~/.rstudio;
rm -rf ~/.rsm-msba;
rm -rf ~/.local/share/jupyter
docker system prune --all --volumes --force;
docker pull raghavprasad13/rsm-msba-spark;
sudo -- bash -c 'rm -f /usr/local/bin/launch; ln -s ~/git/docker/launch-rsm-msba-spark-m1.sh /usr/local/bin/launch; chmod 755 /usr/local/bin/launch';
```

## Getting help

Please bookmark this page in your browser for easy access in the future. You can also access the documentation page for your OS by typing h (and Enter) in the launch menu. Note that the launch script can also be started from the command line (i.e., a bash terminal) and has several important arguments:

* `launch -t 1.7.2` ensures a specific version of the docker container is used. Suppose you used version 1.7.2 for a project. Running the launch script with `-t 1.7.2` from the command line will ensure your code still runs, without modification, years after you last touched it!
* `launch -d ~/project_1` will treat the `project_1` directory on the host system (i.e., your macOS computer) as the project home directory in the docker container. This is an additional level of isolation that can help ensure your work is reproducible in the future. This can be particularly useful in combination with the `-t` option as this will make a copy of the launch script with the appropriate `tag` or `version` already set. Simply double-click the script in the `project_1` directory and you will be back in the development environment you used when you completed the project
* `launch -v ~/rsm-msba` will treat the `~/rsm-msba` directory on the host system (i.e., your macOS computer) as the home directory in the docker container. This can be useful if you want to setup a particular directory that will house multiple projects
* `launch -s` show additional output in the terminal that can be useful to debug any problems
* `launch -h` prints the help shown in the screenshot below

<img src="figures/docker-help.png" width="500px">

> Note: If you do not see the option to show help, please upgrade the launch script by pressing 7 (and Enter)

## Trouble shooting

The only issues we have seen on macOS so far can be addressed by restarting docker and/or restarting your computer

## Optional

To install python3 on macOS using **homebrew**, run the commands below from a terminal:

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)";
brew install python3;
```

If you want to make your terminal look nicer and add syntax highlighting, auto-completion, etc. consider following the install instructions linked below:

<https://github.com/radiant-rstats/docker/blob/master/install/setup-ohmyzsh.md>

<img src="figures/ohmyzsh-powerlevel10k.png" width="500px">

If you have VSCode installed locally on your host OS (https://code.visualstudio.com/download), you can connect to a running container by adding the below to `~/.ssh/config` and selecting `docker_local` from the options listed by `Remote SSH: Connect to Host...`

```bash
Host docker_local
    User jovyan
    HostName 127.0.0.1
    StrictHostKeyChecking no
    Port 2121
```

<!-- 

After setting up keys for git and gitlab, user should be able to use the below to avoid (multiple) logins for Remote SSH

cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

You may also need the below: 

```
eval `ssh-agent`
ssh-add
``` 

Copying over the public key to the MSBA server

```
ssh-copy-id -i ~/.ssh/id_rsa.pub sc1
```

-->
<!-- 
# Selenium example that works with docker compose
# From outside the container access using
library(RSelenium)
remDr <- remoteDriver(
    remoteServerAddr = "127.0.0.1",
    port = 4444L,
)
remDr$open()
remDr$navigate("http://www.google.com") 

# From inside main computing environment
library(RSelenium)
remDr <- remoteDriver(
    remoteServerAddr = "selenium",
    port = 4444L,
)
remDr$open()
remDr$navigate("http://www.google.com") 

# If you need multiple selenium containers, just add one 
# to the docker-compose file
  # selenium2:
    # image: 
      # selenium/standalone-firefox
    # ports:
      # - 127.0.0.1:4445:444
-->