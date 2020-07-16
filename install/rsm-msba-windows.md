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

## Installing the RSM-MSBA computing environment on Windows

Please follow the instructions below to install the rsm-msba-spark computing environment. It has R, Rstudio, Python, Jupyter Lab, Postgres, VS Code, Spark and various required packages pre-installed. The computing environment will be consistent across all students and faculty, easy to update, and also easy to remove if desired (i.e., there will *not* be dozens of pieces of software littered all over your computer).

**Step 1**: Upgrade Windows

Windows users **must** use Microsoft Windows 10 Professional, Education, or Enterprise (64-bit). Students should be able to upgrade to Microsoft Windows 10 Education (64-bit) for free through their university. For Rady (UCSD) students, the steps in the upgrade process are shown in the following video: <a href="https://youtu.be/p0gcRbatO0w" target="_blank">https://youtu.be/p0gcRbatO0w</a>.

Check if there are any updates available for your system by clicking on the Start icon and typing "Check for Updates". After upgrading to the latest version of Windows, open PowerShell and type `winver`. If the windows version is 2004 or higher, as shown in the screenshot below, continue with step **#2**. If you are having issues upgrading your Windows version, please reach out your IT support staff. If upgrading is not feasible for some reason, use the install instructions shown in the document linked below:

<https://github.com/radiant-rstats/docker/blob/master/install/rsm-msba-windows-1909.md>

<img src="figures/windows-version.png" width="300px">

**Step 2**: Install Windows Subsystem for Linux (WSL2)

<!-- Set-VMProcessor "Docker Testing" -ExposeVirtualizationExtensions $true -->

To activate WSL2, start PowerShell as an administrator and copy-and-paste the code below:

```bash
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
```

Next, restart your computer and re-open PowerShell and set the default version of WSL to "2" using the code below

```bash
wsl --set-default-version 2
```

If you see a message that "WSL 2 requires an update to its kernel component", download and run the <a href="https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi" target="_blank">kernel installer</a> 

Next, get <a href="https://www.microsoft.com/en-us/p/ubuntu-2004-lts/9n6svws3rx71" target="_blank">Ubuntu 20.04</a> from the Windows Store. You will be asked to provide a username and password. Make sure to enter the same username and password you use to login to your computer.

**Step 3**: Install Windows Tools

Download and install the Microsoft <a href="https://github.com/microsoft/winget-cli/releases/download/v0.1.41821-preview/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.appxbundle" target="_blank">App Installer</a>. After completing the install, open PowerShell and enter the commands below to install the Windows Terminal and Ubuntu-20.04:

```bash
winget install -e Microsoft.WindowsTerminal
winget install -e Docker.DockerDesktop
```

This will install the "Windows Terminal" and Docker Desktop. We recommend you pin Windows Terminal to the taskbar as you will be using it regularly.

Next, logout and back into Windows and then start Docker by clicking on the Whale icon that was added to your desktop (see image below).

![docker](figures/docker-icon.png)

You will know if Docker is running if you see the icon below in your system tray. If the containers shown in the image are moving up and down, docker hasn't finished starting up yet. Once the docker application is running, right click on the docker icon in the system tray and select "Settings".

Start by clicking on _General_ to ensure "Use the WSL 2 based engine" is checked as in the screenshot below.

<img src="figures/docker-general-wsl2-based-engine.png" width="500px">

Next click on _Resources > WSL INTEGRATION_ and ensure integration with Ubuntu is enabled as in the screenshot below

<img src="figures/docker-resources-wsl2-integration.png" width="500px">

Optional: If you are interested, this linked video gives a brief intro to what Docker is: https://www.youtube.com/watch?v=YFl2mCHdv24

**Step 4**: Open an Ubuntu terminal to complete RSM-MSBA-SPARK computing environment setup

Click on the down-caret at the top of the terminal window to start an Ubuntu terminal as shown in the screenshot below. Then copy-and-paste the code below into the Ubuntu terminal and provide your password when prompted.

<img src="figures/start-ubuntu-terminal.png" width="500px">

```bash
cd; sudo -- sh -c 'apt -y update; apt -y upgrade; apt -y install xdg-utils;'
```

Now Ubuntu should be up to date and ready to accept commands to clone the docker repo with documentation and launch scripts. Again, provide your password if prompted.

```bash
git clone https://github.com/radiant-rstats/docker.git ~/git/docker;
sudo ln -s ~/git/docker/launch-rsm-msba-spark.sh /usr/local/bin/launch;
```

Next, determine your Windows username by running the code below from an Ubuntu terminal:

```bash
USERNAME=$(powershell.exe '$env:UserName'|tr -d '\r')
```

Finally, we will create and launch a script `launch-rsm-msba-spark.bat` on your Desktop that you can double-click to start the container in the future.

```bash
echo "REM Powershell.exe -command \"wsl launch\"" > /mnt/c/Users/"$USERNAME"/Desktop/launch-rsm-msba-spark.bat;
echo "Powershell.exe -command \"wsl launch -v ~\"" >> /mnt/c/Users/"$USERNAME"/Desktop/launch-rsm-msba-spark.bat;
chmod 755 /mnt/c/Users/"$USERNAME"/Desktop/launch-rsm-msba-spark.bat;
ln -s /mnt/c/Users/"$USERNAME"/Desktop Desktop
ln -s /mnt/c/Users/"$USERNAME"/Dropbox Dropbox
ln -s "/mnt/c/Users/$USERNAME/Google Drive" "Google Drive"
ln -s /mnt/c/Users/"$USERNAME"/OneDrive OneDrive
/mnt/c/Users/"$USERNAME"/Desktop/launch-rsm-msba-spark.bat;
```

The created and launched script will finalize the installation of the computing environment. The first time you run this script it will download the latest version of the computing environment which can take some time. Wait for the container to download and follow any prompts. Once the download is complete you should see a menu as in the screen shot below.

<img src="figures/rsm-msba-menu-wsl2.png" width="500px">

**Step 5**: Check that you can launch Rstudio and Jupyter

You will know that the installation was successful if you can start Rstudio and Jupyter Lab. When you press 2 (and Enter) in the terminal, Rstudio should start up in your default web browser. If you press 3 (and Enter) Jupyter Lab should start up in another tab in your web browser. If you are asked for login credentials, the username is "jovyan" and the password is "jupyter"

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

To update the container use the launch script and press 6 (and Enter). To update the launch script itself, press 7 (and Enter).

<img src="figures/rsm-msba-menu-wsl2.png" width="500px">

If for some reason you are having trouble updating either the container or the launch script open an Ubuntu terminal and copy-and-paste the code below. Note: You may have to right-click to get a copy-and-paste menu for the terminal. These commands will update the docker container, replace the old docker related scripts, and copy the latest version of the launch script to your Desktop.

```bash
docker pull vnijs/rsm-msba-spark;
rm -rf ~/git/docker;
git clone https://github.com/radiant-rstats/docker.git ~/git/docker;
sudo -- sh -c 'rm -rf /usr/local/bin/launch; ln -s ~/git/docker/launch-rsm-msba-spark.sh /usr/local/bin/launch;'
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

To remove locally installed R packages press 8 (and Enter) in the launch menu and follow the prompts. To remove locally installed Python modules press 9 (and Enter) in the launch menu

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

To remove any prior Rstudio sessions, and locally installed R-packages, press 8 (and Enter) in the launch menu. To remove locally installed Python packages press 9 (and Enter) in the launch menu.

> Note: It is also possible initiate the process of removing locally installed packages and settings from within the container. Open a terminal in Jupyter Lab or Rstudio and type `clean`. Then follow the prompts to indicate what needs to be removed.

You should always stop the `rsm-msba-spark` docker container using `q` (and Enter) in the launch menu. If you want a full cleanup and reset of the computational environment on your system, however, execute the following commands from a (bash) terminal to (1) remove prior R(studio) and Python settings, (2) remove all docker images, networks, and (data) volumes, and (3) 'pull' only the docker image you need (e.g., rsm-msba-spark):

```bash
rm -rf ~/.rstudio;
rm -rf ~/.rsm-msba;
rm -rf ~/.local/share/jupyter
docker system prune --all --volumes --force;
docker pull vnijs/rsm-msba-spark;
```

## Getting help

Please bookmark this page in your browser for easy access in the future. You can also access the documentation page for your OS by typing h (and Enter) in the launch menu. Note that the launch script can also be started from the command line (i.e., a bash terminal) and has several important arguments:

* `launch -t 1.7.2` ensures a specific version of the docker container is used. Suppose you used version 1.7.2 for a project. Running the launch script with `-t 1.7.2` from the command line will ensure your code still runs, without modification, years after you last touched it!
* `launch -d ~/project_1` will treat the `project_1` directory on the host system (i.e., your Windows computer) as the project home directory in the docker container. This is an additional level of isolation that can help ensure your work is reproducible in the future. This can be particularly useful in combination with the `-t` option as this will make a copy of the launch script with the appropriate `tag` or `version` already set. Simply double-click the script in the `project_1` directory and you will be back in the development environment you used when you completed the project
* `launch -v ~/rsm-msba` will treat the `~/rsm-msba` directory on the host system (i.e., your Windows computer) as the home directory in the docker container. This can be useful if you want to setup a particular directory that will house multiple projects
* `launch -s` show additional output in the terminal that can be useful to debug any problems
* `launch -h` prints the help shown in the screenshot below

<img src="figures/docker-help.png" width="500px">

> Note: If you do not see the option to show help, please upgrade the launch script by pressing 7 (and Enter)

## Trouble shooting

If there is an error related to the firewall, antivirus, or VPN, try turning them off to check if you can now start up the container. You should not be without a virus checker or firewall however! We recommend using **Windows Defender**. If you are not sure if Windows Defender is correctly configured, please check with IT.

Alternative "fixes" that have worked, are to restart docker by right-clicking on the "whale" icon in the system tray and/or restart your computer. It is best to quit any running process before you restart your computer (i.e., press q and Enter in the launch menu)

## Optional

You can install python3 and VS Code using **winget**. Open a Windows Terminal (PowerShell) and copy-and-paste the code below. Note: You may have to right-click to copy-and-paste the code into the terminal

```bash
winget install -e Python.Python;
winget install -e Microsoft.VisualStudioCode;
```

With VSCode installed locally on your host OS, you can connect to a running container by adding the below to `~/.ssh/config` and selecting `docker_local` from the options listed by `Remote SSH: Connect to Host...`

```bash
Host docker_local
    User jovyan
    HostName 127.0.0.1
    StrictHostKeyChecking no
    Port 2222
Host sc1
    User your-user-id
    HostName rsm-compute-01.ucsd.edu
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

<!-- ssh-copy-id -i ~/.ssh/id_rsa.pub username@rsm-compute-01.ucsd.edu -->