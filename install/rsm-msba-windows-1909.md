# Contents

- [Installing the RSM-MSBA computing environment on Windows](#installing-the-rsm-msba-computing-environment-on-windows)
- [Updating the RSM-MSBA computing environment on Windows](#updating-the-rsm-msba-computing-environment-on-windows)
- [Using VS Code for Python](#using-vs-code-for-python)
- [Connecting to postgresql](#connecting-to-postgresql)
- [Installing R and Python packages locally](#installing-r-and-python-packages-locally)
- [Committing changes to the computing environment](#committing-changes-to-the-computing-environment)
- [Cleanup](#cleanup)
- [Getting help](#getting-help)
- [Trouble shooting](#trouble-shooting)

<!-- markdownlint-disable MD033 MD034 -->

## Installing the RSM-MSBA computing environment on Windows

Please follow the instructions below to install the rsm-msba-spark computing environment. It has R, Rstudio, Python, Jupyter Lab, Postgres, VS Code, Spark and various required packages pre-installed. The computing environment will be consistent across all students and faculty, easy to update, and also easy to remove if desired (i.e., there will *not* be dozens of pieces of software littered all over your computer).

**Step 1**: Upgrade Windows if you are currently using Windows Home Edition

Windows users **must** use Microsoft Windows 10 Professional, Education, or Enterprise (64-bit). Students will likely be able to upgrade to Microsoft Windows 10 Education (64-bit) for free through their university. For Rady (UCSD) students, the steps in the upgrade process are shown in the following video: <a href="https://youtu.be/p0gcRbatO0w" target="blank">https://youtu.be/p0gcRbatO0w</a>.

**Step 2**: Install docker from the link below and make sure it is running. You will know it is running if you see the icon below in your system tray. If the containers shown in the image are moving up and down docker hasn't finished starting up yet.

During the install process use *only* the default settings. If prompted, make sure to choose "Linux containers" and *not* "Windows containers". You may also be prompted to enable virtualization ("Hyper-V"). If so, click OK and your computer should restart.

![docker](figures/docker-icon.png)

<https://download.docker.com/win/stable/Docker%20for%20Windows%20Installer.exe>

Once the docker application has been installed, right click on the docker icon and select "Settings".

Start by clicking on _Resources > ADVANCED_ to change the resources docker is allowed to use on your system. You can set this to approximately 50% of the maximum available on your system.

<img src="figures/docker-resources.png" width="500px">

Next click on _Resources > FILE SHARING_ and then click on the + sign to share the "C" drive as shown in the image below

> Note: If you do not see an option to select shared drives you likely selected "Windows containers" rather than the default "Linux containers" during the docker install. Please re-install docker and make sure to select "Linux containers" when prompted.

<img src="figures/windows-shared-drives.png" width="500px">

Optional: If you are interested, this linked video gives a brief intro to what Docker is: https://www.youtube.com/watch?v=YFl2mCHdv24

**Steps 3-4 using the Rady installer**: Download and run the installer linked below to complete steps 3 and 4 of the install process on Windows

https://rady.ucsd.edu/faculty/directory/vnijs/RSM-MSBA-Computing-Environment-Latest.exe

If you see a warning message like the image shown below when you run the installer click on "More info" and then on "Run anyway".

<img src="figures/win-protected.png" width="300px">

<details>
<summary>Complete steps 3 and 4 manually</summary>

**Step 3**: Install git bash from the link below

<a href="https://git-scm.com/download/win" target="_blank">https://git-scm.com/download/win</a>

Keep the default settings until you are asked about "Configuring extra options". Set the options as shown in the screen shot below.

<img src="figures/symlinks.png" width="500px">

There is no need to "View Release Notes" on the last screen or "Launch Git Bash" just yet.

**Step4**: Open a bash terminal **as administrator** and copy-and-paste the code below to add `rsync` functionality. Note: You may have to right-click to get a copy-and-paste menu for the terminal

> Note: To open git bash as administrator, find the app in the Start Menu and select 'Run as administrator'.

```bash
curl http://www2.futureware.at/~nickoe/msys2-mirror/msys/x86_64/rsync-3.1.2-2-x86_64.pkg.tar.xz -o rsync.pkg.tar.xz;
tar xvJf rsync.pkg.tar.xz -C /c/Program\ Files/Git/;
rm -rf rsync.pkg.tar.xz;
```

Next, copy-and-paste the code below to clone the launch scripts needed to start the docker container.

```bash
git clone https://github.com/radiant-rstats/docker.git C:/Users/$USERNAME/git/docker;
cp -p C:/Users/$USERNAME/git/docker/launch-rsm-msba-spark.sh C:/Users/$USERNAME/Desktop;
C:/Users/$USERNAME/Desktop/launch-rsm-msba-spark.sh;
```

This step will clone and start up a script that will finalize the installation of the computing environment. The first time you run this script it will download the latest version of the computing environment which can take some time. Wait for the container to download and follow any prompts. Once the download is complete you should see a menu as in the screen shot below.

<img src="figures/rsm-msba-menu-windows.png" width="500px">

The code above also creates a copy of the file `launch-rsm-msba-spark.sh` on your Desktop that you can double-click to start the container again in the future.

Copy-and-paste the command below to create a shortcut to the launch script to use from the command line.

```bash
ln -s C:/Users/$USERNAME/git/docker/launch-rsm-msba-spark.sh /usr/bin/launch;
```

</details>

**Step 5**: Check that you can launch Rstudio and Jupyter

You will know that the installation was successful if you can start Rstudio and Jupyter Lab. When you press 2 (and Enter) in the terminal, Rstudio should start up in your default web browser. If you press 3 (and Enter) Jupyter Lab should start up in another tab in your web browser. For Rstudio, the username is "jovyan" and the password is "rstudio". For Jupyter the password is "jupyter"

> Important: Always use q (and Enter) to shutdown the computing environment

**Rstudio**:

<img src="figures/rsm-rstudio.png" width="500px">

**Jupyter**:

<img src="figures/rsm-jupyter.png" width="500px">

To finalize the setup for Radiant, Rstudio, and VS Code open a terminal in either Rstudio or Jupyter lab and run the code below:

```bash
setup
```

## Updating the RSM-MSBA computing environment on Windows

To update the container use the launch script and press 4 (+ enter). To update the launch script itself, press 5 (+ enter).

<img src="figures/rsm-msba-menu-windows.png" width="500px">

If for some reason you are having trouble updating either the container or the launch script open a bash terminal and copy-and-paste the code below. Note: You may have to right-click to get a copy-and-paste menu for the terminal. These commands will update the docker container, replace the old docker related scripts, and copy the latest version of the launch script to your Desktop.

```bash
docker pull vnijs/rsm-msba-spark;
rm -rf C:/Users/$USERNAME/git/docker;
git clone https://github.com/radiant-rstats/docker.git C:/Users/$USERNAME/git/docker;
cp -p C:/Users/$USERNAME/git/docker/launch-rsm-msba-spark.sh C:/Users/$USERNAME/Desktop;
```

## Using VS Code for Python

Microsoft's open-source integrated development environment (IDE), VS Code or Visual Studio Code, was the most popular development environment in according to a [Stack Overflow developer survey](https://insights.stackoverflow.com/survey/2018#development-environments-and-tools). VS Code is widely used by Google developers and is the [default development environment at Facebook](https://www.zdnet.com/article/facebook-microsofts-visual-studio-code-is-now-our-default-development-platform/).

VS Code can be launched from Jupyter and is an excellent, and very popular, editor for python. After running the setup command mentioned above, everything you need for python development will be available. To learn more about using VS Code to write python code see the links and comments below.

- <a href="https://code.visualstudio.com/docs/python/python-tutorial#_create-a-python-hello-world-source-code-file" target="_blank">VS Code Python Tutorial</a>

Note that you can use `Shift+Enter` to run the current line in a Python Interactive Window:

- <a href="https://code.visualstudio.com/docs/python/jupyter-support-py" target="_blank">Executing Python Code in VS Code</a>

When writing and editing python code you will have access to "Intellisense" for auto-completions. Your code will also be auto-formatted every time you save it using the "black" formatter.

- <a href="https://code.visualstudio.com/docs/python/editing" target="_blank">Editing Python in VS Code Python</a>

VS Code also gives you access to a debugger for your python code. For more information see the link below:

- <a href="https://code.visualstudio.com/docs/python/debugging" target="_blank">Debugging Python in VS Code Python</a>

- To convert a python code file to a Jupyter Notebook, use the code below from a terminal. You can open a terminal in VS Code by typing CTRL+'

```bash
jupytext --to notebook your-python-script.py
```

- To convert a Jupyter Notebook to a python code file, use the code below from a terminal. You can open a terminal in VS Code by typing CTRL+'

```bash
jupytext --to py your-python-script.ipynb
```

<!-- ssh-copy-id -i C:/Users/$USERNAME/.ssh/id_rsa.pub username@rsm-compute-01.ucsd.edu -->

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

To access postgresql from Jupyter Lab use the code below:

```py
## connect to database
from sqlalchemy import create_engine
engine = create_engine('postgresql://jovyan:postgres@127.0.0.1:8765/rsm-docker')

## show list of tables
engine.table_names()
```

For a more extensive example using Python see: <a href="https://github.com/radiant-rstats/docker/blob/master/postgres/postgres-connect.ipynb" target="_blank">https://github.com/radiant-rstats/docker/blob/master/postgres/postgres-connect.ipynb</a>

## Installing R and Python packages locally

To install the latest version of R-packages you need, add the line below to `~/.Rprofile`

`options(repos = c(RSM = "https://rsm-compute-01.ucsd.edu:4242/rsm-msba/__linux__/focal/latest", CRAN = "https://cloud.r-project.org"))`

This will be done for you automatically if you run the `setup` command from a terminal inside the docker container. To install R packages that will persist after restarting the docker container, enter code like the below in Rstudio and follow any prompts. After doing this once, you can use `install.packages("some-other-package")` in the future.

```r
fs::dir_create(Sys.getenv("R_LIBS_USER"), recurse = TRUE)
install.packages("fortunes", lib = Sys.getenv("R_LIBS_USER"))
```

To install Python modules that will persist after restarting the docker container, enter code like the below from the terminal in Rstudio or Jupyter Lab:

`pip3 install --user pyrsm`

After installing a module you will have to restart any running Python kernels to `import` the module in your code.

To remove locally installed R packages press 7 (and Enter) in the launch menu and follow the prompts. To remove locally installed Python modules press 8 (and Enter) in the launch menu

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

To save (or commit) these changes so they *will* be present after a (container) restart type, for example, `c myimage` (and Enter). This creates a new docker image with your changes and also a new launch script on your Desktop with the name `launch-rsm-msba-spark-myimage.sh` that you can use to launch your customized environment in the future.

If you want to share your customized version of the container with others (e.g., team members) you can push it is to Docker Hub <a href="https://hub.docker.com" target="_blank">https://hub.docker.com</a> by following the menu dialog after typing, e.g., `c myimage` (and Enter). To create an account on Docker Hub go to <a href="https://hub.docker.com/signup" target="_blank">https://hub.docker.com/signup</a>.

If you want to remove specific images from your computer run the commands below from a (bash) terminal. The first command generates a list of the images you have available.

`docker image ls;`

Select the IMAGE ID for the image you want to remove, e.g., `42b88eb6adf8`, and then run the following command with the correct image id:

`docker rmi 42b88eb6adf8;`

For additional resources on developing docker images see the links below:

- <https://colinfay.me/docker-r-reproducibility>
- <https://www.fullstackpython.com/docker.html>

## Cleanup

To remove any prior Rstudio sessions, and locally installed R-packages, press 7 (and Enter) in the launch menu. To remove locally installed Python packages press 8 (and Enter) in the launch menu.

> Note: It is also possible initiate the process of removing locally installed packages and settings from within the container. Open a terminal in Jupyter Lab or Rstudio and type `clean`. Then follow the prompts to indicate what needs to be removed.

You should always stop the `rsm-msba-spark` docker container using `q` (and Enter) in the launch menu. If you want a full cleanup and reset of the computational environment on your system, however, execute the following commands from a (bash) terminal to (1) remove prior R(studio) and Python settings, (2) remove all docker images, networks, and (data) volumes, and (3) 'pull' only the docker image you need (e.g., rsm-msba-spark):

```bash
rm -rf C:/Users/$USERNAME/.rstudio;
rm -rf C:/Users/$USERNAME/.rsm-msba;
docker system prune --all --volumes --force;
docker pull vnijs/rsm-msba-spark;
```

## Getting help

Please bookmark this page in your browser for easy access in the future. You can also access the documentation page for your OS by typing h (and Enter) in the launch menu. 

Note that the launch script can also be started from the command line (i.e., a bash terminal) and has several important arguments:

* `launch -t 1.7.2` would ensure a specific version of the docker container is used. Suppose you used version 1.7.2 for a project. Using `-t 1.7.2` will ensure your code still runs without modification years after you last touched it
* `launch -d C:/Users/$USERNAME/project_1` will treat the `project_1` directory on the host system (i.e., your macOS computer) as the home directory in the docker container. This is an additional level of isolation that can help ensure your work is reproducible in the future. This can be particularly useful in combination with the `-t` option as this will make a copy of the launch script with the appropriate `tag` or `version` already set. Simply double-click the script in the `project_1` directory and you will be back in the development environment you used when you completed the project
* `launch -s` show additional output in the launch terminal that can be useful to debug any problems
* `launch -h` print the help shown in the screenshot below

<img src="figures/docker-help.png" width="500px"

> Note: If you do not see the option to show help, please upgrade the launch script using 

## Trouble shooting

Check if a firewall, virus-checker, or VPN is blocking docker's access to your home directory on the C-drive. If this is an issue on your system, a warning should be shown when you check the "C" drive in docker settings and click "Apply". See screen shot below:

<img src="figures/reset-credentials.png" width="500px">

If there is an error related to the firewall, antivirus, or VPN, try turning them off to check if you can now start up the container. You should not be without a virus checker or firewall however! We recommend using **Windows Defender**. If you are not sure if Windows Defender is correctly configured, please check with IT.

If you are able to select the C drive and no error is shown after clicking "Apply", try clicking on "Reset Credentials" or type "docker logout" in a (bash) terminal.

Alternative "fixes" that have worked, are to restart docker by right-clicking on the "whale" icon in the system tray and/or restart your computer. It is best to quit any running process before you restart your computer (i.e., press q and Enter in the launch menu)

## Optional

If you did *not* use the installer above to complete steps 3 and 4 you can install python3 on Windows using **chocolatey**. Open a CMD terminal **as administrator** and copy-and-paste the code below. Note: You may have to right-click to get a copy-and-paste menu for the terminal

```bash
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin";
```

Now close the terminal and open a new CMD terminal **as administrator** and copy-and-paste the code below:

```bash
choco install python3;
```
