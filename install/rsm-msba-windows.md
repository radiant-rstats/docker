# Contents

- [Installing the RSM-MSBA-INTEL computing environment on Windows](#installing-the-rsm-msba-intel-computing-environment-on-windows)
- [Updating the RSM-MSBA-INTEL computing environment on Windows](#updating-the-rsm-msba-intel-computing-environment-on-windows)
- [Using VS Code](#using-vs-code)
- [Connecting to postgresql](#connecting-to-postgresql)
- [Installing Python and R packages locally](#installing-python-and-r-packages-locally)
- [Committing changes to the computing environment](#committing-changes-to-the-computing-environment)
- [Cleanup](#cleanup)
- [Getting help](#getting-help)
- [Trouble shooting](#trouble-shooting)
- [Optional](#optional)

## Installing the RSM-MSBA-INTEL computing environment on Windows

Please follow the instructions below to install the rsm-msba-intel computing environment. It has Python, Jupyter Lab, R, Radiant, Rstudio, Postgres, Spark and various required packages pre-installed. The computing environment will be consistent across all students and faculty, easy to update, and also easy to remove if desired (i.e., there will *not* be dozens of pieces of software littered all over your computer).

**Step 1**: Upgrade Windows

Windows users must use Microsoft Windows 11, or Windows 10 Professional, Education, or Enterprise (64-bit). Students should be able to upgrade to Microsoft Windows 10 Education (64-bit) for free through their university. For Rady (UCSD) students, the steps in the upgrade process are shown in the following video: <a href="https://youtu.be/p0gcRbatO0w" target="_blank">https://youtu.be/p0gcRbatO0w</a>. The link to get Windows Education for students is shown below.

<https://onthehub.com/download/free-software/windows-10-education-for-students/>

Check if there are any updates available for your system by clicking on the Start icon and typing "Check for Updates". After upgrading to the latest version of Windows, open PowerShell and type `winver`. If you have windows 11 or the windows 10 version is 2004 or higher, as shown in the screenshot below, continue with **Step 2**. 

<img src="figures/windows-version.png" width="300px">

**Step 2**: Install Windows Subsystem for Linux (WSL2)

To activate WSL2, start PowerShell as an administrator and copy-and-paste the code below:

```bash
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
```
Followed by:

```bash
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart;
```

Next, restart your computer and re-open PowerShell to install Ubuntu. You will be asked to provide a username and password after install Ubuntu. 

```bash
wsl --set-default-version 2
wsl --install -d Ubuntu-22.04
```

> Important: Make sure to enter the same username and password you use to login to your computer

Check your username for Windows and Ubuntu by executing the command below in both (1) a Windows PowerShell and (2) an Ubuntu terminal. The output in both cases should be the same.

```bash
whoami
```

Next, restart your computer and re-open PowerShell to check that Ubuntu is set as the default linux distribution:

```bash
wsl --list
```

This should return the below:

```bash
PS C:\WINDOWS\system32> wsl --list
Windows Subsystem for Linux Distributions:
Ubuntu-22.04 (Default)
docker-desktop-data
docker-desktop
```

If Ubuntu is not set as the default linux distribution, update the default setting and double check that it is now correct

```bash
wsl --setdefault Ubuntu-22.04
wsl --list
```

**Step 3**: Install Windows Tools

Download and install the Microsoft <a href="https://www.microsoft.com/en-us/p/app-installer/9nblggh4nns1?activetab=pivot:overviewtab" target="_blank">App Installer</a>. After completing the install, open a new PowerShell terminal **as a regular user** and enter the commands below:

```bash
winget install -e Microsoft.VisualStudioCode;
winget install -e Docker.DockerDesktop;
```

This will install VS Code and Docker Desktop. If you are using Windows 10, you should also install Windows Terminal using the command below. Windows Terminal is available by default on Windows 11. We recommend you pin Windows Terminal and VS Code to the taskbar as you will use these tools regularly.

```bash
winget install -e Microsoft.WindowsTerminal;
```

Next, logout and back into Windows and then start Docker by clicking on the Whale icon that was added to your desktop (see image below).

![docker](figures/docker-icon.png)

You will know if Docker is running if you see the icon above in your system tray. If the containers shown in the image are moving up and down, docker hasn't finished starting up yet. Once the docker application is running, click on the docker icon in the system tray and select "Settings".

Start by clicking on _General_ to ensure "Use the WSL 2 based engine" is checked as in the screenshot below.

<img src="figures/docker-general-wsl2-based-engine.png" width="500px">

Next click on _Resources > WSL INTEGRATION_ and ensure integration with Ubuntu is enabled as in the screenshot below

<img src="figures/docker-resources-wsl2-integration.png" width="500px">

Optional: If you are interested, this linked video gives a brief intro to what Docker is: https://www.youtube.com/watch?v=YFl2mCHdv24

**Step 4**: Open an Ubuntu terminal to complete RSM-MSBA-INTEL computing environment setup

If you are using Windows Terminal you can click on the down-caret at the top of the window to start an Ubuntu terminal as shown in the screenshot below. Alternatively, you can click on the Windows Start icon and type "ubuntu" to start an Ubuntu terminal. Copy-and-paste the code below into the Ubuntu terminal and provide your password when prompted.

<img src="figures/start-ubuntu-terminal.png" width="500px">

```bash
cd ~; sudo -- sh -c 'apt -y update; apt -y upgrade; apt -y install xdg-utils wslu zsh ntpdate python-is-python3; ntpdate pool.ntp.org'
```

Now Ubuntu should be up to date and ready to accept commands to clone the docker repo with documentation and launch scripts. Again, provide your password if prompted.

```bash
git clone https://github.com/radiant-rstats/docker.git ~/git/docker;
```

After running the commands above you will be able to start the docker container by typing `~/git/docker/launch-rsm-msba-intel.sh -v ~` from an Ubuntu terminal.

Next, determine your Windows username by running the code below from an Ubuntu terminal:

```bash
USERNAME=$(powershell.exe '$env:UserName'|tr -d '\r');
echo $USERNAME;
```

Finally, we will create and launch a script `launch-rsm-msba-intel.bat` on your Desktop that you can double-click to start the container in the future. 

If you do **not** backup your Desktop to OneDrive, please copy-and-paste the code below as-is into an Ubuntu terminal. If you **do** backup your Desktop to OneDrive, you will need to adjust the `DTOP` variable in the section below to something like `DTOP="/OneDrive/Desktop"`

```bash
DTOP="/Desktop";
echo "wt.exe wsl.exe ~/git/docker/launch-rsm-msba-intel.sh -v ~" > /mnt/c/Users/"$USERNAME$DTOP"/launch-rsm-msba.bat;
chmod 755 /mnt/c/Users/"$USERNAME$DTOP"/launch-rsm-msba.bat;
cd ~;
ln -s /mnt/c/Users/"$USERNAME$DTOP"/ ./Desktop;
ln -s /mnt/c/Users/"$USERNAME"/Dropbox ./Dropbox;
ln -s "/mnt/c/Users/$USERNAME/Google Drive" "./Google Drive";
ln -s /mnt/c/Users/"$USERNAME"/OneDrive ./OneDrive;
ln -s /mnt/c/Users/"$USERNAME" ./win_home;
/mnt/c/Users/"$USERNAME$DTOP"/launch-rsm-msba.bat;
```

The created and launched script will finalize the installation of the computing environment. The first time you run this script it will download the latest version of the computing environment which can take some time. Wait for the image to download and follow any prompts. Once the download is complete you should see a menu as in the screen shot below.

<img src="figures/rsm-msba-menu-windows.png" width="500px">

**Trouble shooting**

If you do **not** have a file called `launch-rsm-msba.bat` on your Desktop, you can create one by copy-and-pasting the code below in to a text file using notepad. The "pause" line can be removed later if all works well. Open VS Code or notepad, copy-and-paste the code below into the editor, and save the file as `launch-rsm-msba.bat`. After saving, double-click the file to start the docker container.

```bash
wt.exe wsl.exe ~/git/docker/launch-rsm-msba-intel.sh -v ~
pause
```

**Step 5**: Check that you can launch JupyterLab and Rstudio

You will know that the installation was successful if you can start JupyterLab and Rstudio. If you press 1 (and Enter) Jupyter Lab should start up in your default web browser. If you are asked for login credentials, the **username is "jovyan"** and the **password is "jupyter"**. Have your browser remember the username and password so you won't be asked for it again.When you press 2 (and Enter) in the terminal, Rstudio should start up in a new tab in your web browser.

> Important: Always use q (and Enter) to shutdown the computing environment

**Jupyter**:

<img src="figures/rsm-jupyter.png" width="500px">

**Rstudio**:

<img src="figures/rsm-rstudio.png" width="500px">

To finalize the setup, open a terminal in Jupyter lab, press `q` and `Enter` when prompted, and then run the code below in the same terminal:

```bash
setup;
exit;
```

Now open a new terminal in JupyterLab and you should see some icons

<img src="figures/ohmyzsh-icons.png" width="400px">

## Updating the RSM-MSBA-INTEL computing environment on Windows

To update the container use the launch script and press 6 (and Enter). To update the launch script itself, press 7 (and Enter).

<img src="figures/rsm-msba-menu-windows.png" width="500px">

If for some reason you are having trouble updating either the container or the launch script open an Ubuntu terminal and copy-and-paste the code below. Note: You may have to right-click to get a copy-and-paste menu for the terminal. These commands will update the docker container, replace the old docker related scripts, and copy the latest version of the launch script to your Desktop.

```bash
docker pull vnijs/rsm-msba-intel;
rm -rf ~/git/docker;
git clone https://github.com/radiant-rstats/docker.git ~/git/docker;
~/git/docker/launch-rsm-msba-intel.sh -v ~;
```

## Using VS Code

Microsoft's open-source integrated development environment (IDE), VS Code or Visual Studio Code, was the most popular development environment according to a [Stack Overflow developer survey](https://survey.stackoverflow.co/2022#section-most-popular-technologies-integrated-development-environment). VS Code is widely used by Google developers and is the [default development environment at Facebook](https://www.zdnet.com/article/facebook-microsofts-visual-studio-code-is-now-our-default-development-platform/).


Run the code below from a PowerShell terminal after installing VS Code to install relevant extensions:

```powershell
Invoke-WebRequest -Uri https://raw.githubusercontent.com/radiant-rstats/docker/master/vscode/extensions.txt -OutFile extensions.txt; 
cat extensions.txt |% { code --install-extension $_ --force};
del extensions.txt;
```

To learn more about using VS Code to write python code see the links and comments below. The recommended process to install Python on your system is described in a [section below](#optional)

- <a href="https://code.visualstudio.com/docs/languages/python" target="_blank">Python in VS Code</a>
- <a href="https://code.visualstudio.com/docs/python/python-tutorial#_create-a-python-hello-world-source-code-file" target="_blank">VS Code Python Tutorial</a>

Note that you can use `Shift+Enter` to run the current line in a Python Interactive Window:

- <a href="https://code.visualstudio.com/docs/python/jupyter-support-py" target="_blank">Executing Python Code in VS Code</a>

When writing and editing python code you will have access to tools for auto-completion, etc. Your code will also be auto-formatted every time you save it using the "black" formatter.

- <a href="https://code.visualstudio.com/docs/python/editing" target="_blank">Editing Python in VS Code Python</a>

VS Code also gives you access to a debugger for your python code. For more information see the link below:

- <a href="https://code.visualstudio.com/docs/python/debugging" target="_blank">Debugging Python in VS Code Python</a>

You can even open and run Jupyter Notebooks in VS Code

- <a href="https://code.visualstudio.com/docs/datascience/jupyter-notebooks" target="_blank">Jupyter Notebooks in VS Code</a>

A major new feature in VS Code is the ability to use AI to help you write code. For more information see the links below:

- <a href="https://code.visualstudio.com/blogs/2023/03/30/vscode-copilot" target="_blank">VS Code Copilot</a>
- <a href="https://code.visualstudio.com/docs/editor/artificial-intelligence" target="_blank">VS Code AI</a>

## Connecting to postgresql

The rsm-msba-intel container comes with <a href="http://www.postgresqltutorial.com" target="_blank">postgresql</a> installed. Once the container has been started, you can access postgresql in different ways. The easiest is to use `pgweb`. Start `pgweb` and enter the code below in the "Scheme" tab:

```bash
postgresql://jovyan:postgres@127.0.0.1:8765/rsm-docker
```

<img src="figures/postgresql-pgweb.png" width="500px">

To access postgresql from Jupyter Lab use the code below:

```python
## connect to database
from sqlalchemy import create_engine, inspect
engine = create_engine('postgresql://jovyan:postgres@127.0.0.1:8765/rsm-docker')

## show list of tables
inspector = inspect(engine)
inspector.get_table_names()
```

For a more extensive example using Python see: <a href="https://github.com/radiant-rstats/docker/blob/master/postgres/postgres-connect.ipynb" target="_blank">https://github.com/radiant-rstats/docker/blob/master/postgres/postgres-connect.ipynb</a>

### Trouble shooting

If you cannot connect to postgresql it is most likely due to an issue with the docker volume that contains the data. The volume can become corrupted if the container is not properly stopped using `q + Enter` in the launch menu. To create a clean volume for postgres (1) stop the running container using `q + Enter`, (2) run the code below in a terminal, and (3) restart the container. If you are still having issues connecting to the postgresql server, please reach out for support through Piazza.

```bash
docker volume rm pg_data
```

## Installing Python and R packages locally

To install the latest version of R-packages you need, add the lines of code shown below to `~/.Rprofile` or copy-and-paste the lines into the Rstudio console.

```r
if (Sys.info()["sysname"] == "Linux") {
  options(repos = c(
    RSPM = "https://packagemanager.posit.co/cran/__linux__/jammy/latest",
    CRAN = "https://cloud.r-project.org"
  ))
} else {
  options(repos = c(
    CRAN = "https://cloud.r-project.org"
  ))
}
```

This will be done for you automatically if you run the `setup` command from a terminal inside the docker container. To install R packages that will persist after restarting the docker container, enter code like the below in Rstudio and follow any prompts. After doing this once, you can use `install.packages("some-other-package")` in the future.

```r
fs::dir_create(Sys.getenv("R_LIBS_USER"), recurse = TRUE)
install.packages("fortunes", lib = Sys.getenv("R_LIBS_USER"))
```

To install Python modules that will **not** persist after restarting the docker container, enter code like the below from the terminal in Jupyter Lab:

```bash
pip install pyasn1
```

Or ...

```bash
conda install -c conda-forge pyasn1
```

After installing a module you will have to restart any running Python kernels to `import` the module in your code.

### Using pip to install python packages

We recommend you use `pip` to install any additional packages you might need. For example, you can use the command below to install a new version of the `pyrsm` package that you will use regularly throughout the Rady MSBA program. Note that adding `--user` is important to ensure the package is still available after you restart the docker container

```bash
pip install --user "pyrsm>=0.9.1"
```
### Conda convenience functions

If you want to use a completely separate conda environment for a project you can use the `ccenv` function. To install Python modules that **will** persist after restarting the docker container, enter code like the below from the terminal in Jupyter Lab:

```bash
conda init zsh;
exit;
```

Reopen a terminal and run the below. Here `myenv` if a new conda environment and `pyasn1` is a package to install.

```bash
ccenv myenv pyasn1
```

After refreshing your browser window showing JupyterLab you should see a new icon `myenv`. Click on this icon and run `import pyasn1`. If you do not see an error message you will have successfully created a new conda environment. You can now create your own conda environments with whatever packages you need.

You can also use the `ccenv` function to add more python package to a specific environment:

```bash
ccenv myenv package_a package_b package_c
```

To list all available conda environments, use the `cl` command from a terminal in JuyterLab. To remove a conda environment use `cr myenv` where `myenv` is the environment you want to remove. To export an environment to share with others, use `ce myenv`. This will create a `myenv.yaml` file with information on all packages used in the `myenv` environment. To import a new environment from an existing `some_env.yaml` file use `ci some_env.yaml`. This will create a new environment called `some_env`.

If you want to see the code included in these functions, run the code below:

```bash
cat /usr/local/bin/ccenv;
cat /usr/local/bin/cl;
cat /usr/local/bin/cr;
cat /usr/local/bin/ce;
cat /usr/local/bin/ci;
```

### Switching conda environments in the terminal

If you want to change the conda environment used in a terminal you can use the command below:

```bash
conda activate myenv
```

To deactivate a conda environment use:

```bash
conda deactivate
```

When leaving a custom environment you will most likely want to switch to the `base` environment so instead of `conda deactivate` you can also use:

```bash
conda activate base
```

Tips to avoid the python problems depicted in the comic linked below:
- Stick with one or two tools to create environments (e.g., pip and conda)
- Don't go overboard with the number conda environments you create

<a href="https://xkcd.com/1987/" target="_blank">https://xkcd.com/1987/</a>

### Removing locally installed packages

To remove locally installed R packages press 8 (and Enter) in the launch menu and follow the prompts. To remove Python modules installed locally using `pip` press 9 (and Enter) in the launch menu

To remove any new conda environments you created, run the code below from a terminal in Jupyter Lab:

```bash
cr myenv
```

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

To save (or commit) these changes so they *will* be present after a (container) restart type, for example, `c myimage` (and Enter). This creates a new docker image with your changes and also a new launch script on your Desktop with the name `launch-rsm-msba-intel-myimage.sh` that you can use to launch your customized environment in the future.

If you want to share your customized version of the container with others (e.g., team members) you can push it is to Docker Hub <a href="https://hub.docker.com" target="_blank">https://hub.docker.com</a> by following the menu dialog after typing, e.g., `c myimage` (and Enter). To create an account on Docker Hub go to <a href="https://hub.docker.com/signup" target="_blank">https://hub.docker.com/signup</a>.

If you want to remove specific images from your computer run the commands below from a (bash) terminal. The first command generates a list of the images you have available.

`docker image ls;`

Select the IMAGE ID for the image you want to remove, e.g., `42b88eb6adf8`, and then run the following command with the correct image id:

`docker rmi 42b88eb6adf8;`

For additional resources on developing docker images see the links below:

- <https://colinfay.me/docker-r-reproducibility>
- <https://www.fullstackpython.com/docker.html>

## Cleanup

To remove any prior Rstudio sessions, and locally installed R-packages, press 8 (+ Enter) in the launch menu. To remove locally installed Python packages press 9 (+ Enter) in the launch menu.

> Note: It is also possible initiate the process of removing locally installed packages and settings from within the container. Open a terminal in Jupyter Lab or Rstudio and type `clean`. Then follow the prompts to indicate what needs to be removed.

You should always stop the `rsm-msba-intel` docker container using `q` (and Enter) in the launch menu. If you want a full cleanup and reset of the computational environment on your system, however, execute the following commands from a (bash) terminal to (1) remove prior R(studio) and Python settings, (2) remove all docker images, networks, and (data) volumes, and (3) 'pull' only the docker image you need (e.g., rsm-msba-intel):

```bash
rm -rf ~/.rstudio;
rm -rf ~/.rsm-msba;
rm -rf ~/.local/share/jupyter
docker system prune --all --volumes --force;
docker pull vnijs/rsm-msba-intel;
```

## Getting help

Please bookmark this page in your browser for easy access in the future. You can also access the documentation page for your OS by typing h (and Enter) in the launch menu. Note that the launch script can also be started from the command line (i.e., a bash terminal) and has several important arguments:

* `launch -t 2.7.0` ensures a specific version of the docker container is used. Suppose you used version 2.7.0 for a project. Running the launch script with `-t 2.7.0` from the command line will ensure your code still runs, without modification, years after you last touched it!
* `launch -v ~/rsm-msba` will treat the `~/rsm-msba` directory on the host system (i.e., your macOS computer) as the home directory in the docker container. This can be useful if you want to setup a particular directory that will house multiple projects
* `launch -d ~/project_1` will treat the `project_1` directory on the host system (i.e., your Windows computer) as the project home directory in the docker container. This is an additional level of isolation that can help ensure your work is reproducible in the future. This can be particularly useful in combination with the `-t` option as this will make a copy of the launch script with the appropriate `tag` or `version` already set. Simply double-click the script in the `project_1` directory and you will be back in the development environment you used when you completed the project
* `launch -s` show additional output in the terminal that can be useful to debug any problems
* `launch -h` prints the help shown in the screenshot below

<img src="figures/docker-help.png" width="500px">

> Note: If you do not see the option to show help, please upgrade the launch script by pressing 7 (and Enter)

## Trouble shooting

If there is an error related to the firewall, antivirus, or VPN, try turning them off to check if you can now start up the container. You should not be without a virus checker or firewall however! We recommend using **Windows Defender**. If you are not sure if Windows Defender is correctly configured, please check with IT.

Alternative "fixes" that have worked, are to restart docker by right-clicking on the "whale" icon in the system tray and/or restart your computer. It is best to quit any running process before you restart your computer (i.e., press q and Enter in the launch menu)

## Optional

To install python3 from conda on macOS run the command below from PowerShell follow the prompts. The defaults are generally good.

```powershell
winget install -e --id Anaconda.Miniconda3
```

For more on minicoda visit the page below:

<https://docs.conda.io/en/latest/miniconda.html>

Once you have completed the install, open a new Anaconda Terminal from Windows terminal if you want to install python packages. For example:

```bash
conda install -c conda-forge pandas polars duckdb ipykernel black
```

If you want to add the Miniconda terminal to the dropdown menu in the Windows Terminal, open Windows Terminal and press `Ctrl + ,`. Then press the settings icon to open up the settings.json file in VS Code. Scroll down until you see "profiles" and then add the below to the "list" section. Save the file, open a new Windows Terminal, and you should see the option to open a Miniconda terminal. You can see a full version of the settings.json file at the link below.

<https://github.com/radiant-rstats/docker/blob/master/vscode/settings.json>

```yaml
        ,{
            // Miniconda Powershell prompt for local user install (non-admin install)
            "guid": "{1caa0dad-35be-5f56-a812-afceeeaa1234}",
            "name": "Miniconda",
            "commandline": "%windir%\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -ExecutionPolicy ByPass -NoExit -Command \"& '%USERPROFILE%\\Miniconda3\\shell\\condabin\\conda-hook.ps1' ; conda activate '%USERPROFILE%\\Miniconda3' \"",
            "icon": "%USERPROFILE%\\Miniconda3\\Menu\\Iconleak-Atrous-PSConsole.ico",
            "hidden": false,
            "startingDirectory": "%HOMEPATH%"
        }
```


If you want to make your terminal look nicer and add syntax highlighting, auto-completion, etc. consider following the install instructions linked below:

<https://github.com/radiant-rstats/docker/blob/master/install/setup-ohmyzsh.md>

<img src="figures/ohmyzsh-powerlevel10k.png" width="500px">
