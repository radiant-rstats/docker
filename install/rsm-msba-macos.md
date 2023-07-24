# Contents

- [Installing the RSM-MSBA-INTEL computing environment on macOS](#installing-the-rsm-msba-intel-computing-environment-on-macos)
- [Updating the RSM-MSBA-INTEL computing environment on macOS](#updating-the-rsm-msba-intel-computing-environment-on-macos)
- [Using VS Code](#using-vs-code)
- [Connecting to postgresql](#connecting-to-postgresql)
- [Installing Python and R packages locally](#installing-python-and-r-packages-locally)
- [Committing changes to the computing environment](#committing-changes-to-the-computing-environment)
- [Cleanup](#cleanup)
- [Getting help](#getting-help)
- [Trouble shooting](#trouble-shooting)
- [Optional](#optional)

## Installing the RSM-MSBA-INTEL computing environment on macOS

Please follow the instructions below to install the rsm-msba-intel computing environment. It has Python, Jupyter Lab, R, Radiant, Rstudio, Postgres, Spark and various required packages pre-installed. The computing environment will be consistent across all students and faculty, easy to update, and also easy to remove if desired (i.e., there will *not* be dozens of pieces of software littered all over your computer).

**Step 1**: Install docker from the link below and make sure it is running. You will know it is running if you see the icon below at the top-right of your screen. If the containers in the image are moving up and down docker hasn't finished starting up yet.

![docker](figures/docker-icon.png)

[download docker for macOS with and Intel chip](https://desktop.docker.com/mac/stable/amd64/Docker.dmg)

You should change the (maximum) resources docker is allowed to use on your system. We recommend you set this to approximately 50% of the maximum available on your system.

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
cp -p ~/git/docker/launch-rsm-msba-intel.sh ~/Desktop/launch-rsm-msba.command;
~/Desktop/launch-rsm-msba.command;
```

This step will clone and start up a script that will finalize the installation of the computing environment. The first time you run this script it will download the latest version of the computing environment which can take some time. Wait for the container to download and follow any prompts. Once the download is complete you should see a menu as in the screen shot below.

<img src="figures/rsm-msba-arm-menu-macos-m1.png" width="500px">

The code above also copies the file `launch-rsm-msba-intel.sh` to `launch-rsm-msba.command` on your Desktop. You will be able to double-click this file to start the container again in the future.

Run the command below to launch the docker container from the command line.

```bash
~/git/docker/launch-rsm-msba-intel.sh -v ~;
```

After running this command you will be able to start the docker container by typing `launch` from a terminal.

**Step 4**: Check that you can launch Jupyter and Rstudio

You will know that the installation was successful if you can start Jupyter Lab. When you press 1 (+ Enter) in the terminal, Jupyter Lab should start up in your default web browser. If you are asked for login credentials, the username is "jovyan" and the password is "jupyter". Have your browser remember the username and password so you won't be asked for it again. When you press 2 (+ Enter) in the terminal, Rstudio should start up in a new tab in your web browser.

> Important: Always use q (+ Enter) to shutdown the computing environment

**Jupyter**:

<img src="figures/rsm-msba-arm.png" width="500px">

**Rstudio**:

<img src="figures/rsm-rstudio.png" width="500px">

To finalize the setup, open a terminal in Jupyter lab, press `q` and `Enter` if prompted, and then run the code below in the same terminal:

```bash
setup;
exit;
```

Now open a new terminal in JupyterLab and you should see some icons

<img src="figures/ohmyzsh-icons.png" width="400px">

## Updating the RSM-MSBA-INTEL computing environment on macOS

To update the container use the launch script and press 6 (+ Enter). To update the launch script itself, press 7 (+ Enter).

<img src="figures/rsm-msba-arm-menu-macos.png" width="500px">

If for some reason you are having trouble updating either the container or the launch script open a terminal and copy-and-paste the code below. These commands will update the docker container, replace the old docker related scripts, and copy the latest version of the launch script to your Desktop.

```bash
docker pull vnijs/rsm-msba-intel;
rm -rf ~/git/docker;
git clone https://github.com/radiant-rstats/docker.git ~/git/docker;
cp -p ~/git/docker/launch-rsm-msba-intel.sh ~/Desktop/launch-rsm-msba.command;
```

## Using VS Code

Microsoft's open-source integrated development environment (IDE), VS Code or Visual Studio Code, was the most popular development environment according to a [Stack Overflow developer survey](https://survey.stackoverflow.co/2022#section-most-popular-technologies-integrated-development-environment). VS Code is widely used by Google developers and is the [default development environment at Facebook](https://www.zdnet.com/article/facebook-microsofts-visual-studio-code-is-now-our-default-development-platform/).

VS Code can be installed from the link below and is an excellent, and very popular, editor for Python, R, and many other programming languages.

<a href="https://code.visualstudio.com/download" target="_blank">https://code.visualstudio.com/download</a>

Run the code below from a terminal on macOS after installing VS Code to install relevant extensions:

```bash
cd ~/git/docker/vscode;
./extension-install.sh;
cd -;
```

To learn more about using VS Code to write python code see the links and comments below.

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
    RSPM = "https://packagemanager.rstudio.com/all/__linux__/jammy/latest",
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

To save (or commit) these changes so they *will* be present after a (container) restart type, for example, `c myimage` (+ Enter). This creates a new docker image with your changes and also a new launch script on your Desktop with the name `launch-rsm-msba-myimage.command` that you can use to launch your customized environment in the future.

If you want to share your customized version of the container with others (e.g., team members) you can push it is to Docker Hub <a href="https://hub.docker.com" target="_blank">https://hub.docker.com</a> by following the menu dialog after typing, e.g., `c myimage` (+ Enter). To create an account on Docker Hub go to <a href="https://hub.docker.com/signup" target="_blank">https://hub.docker.com/signup</a>.

If you want to remove specific images from your computer run the commands below from a (bash) terminal. The first command generates a list of the images you have available.

`docker image ls;`

Select the IMAGE ID for the image you want to remove, e.g., `42b88eb6adf8`, and then run the following command with the correct image id:

`docker rmi 42b88eb6adf8;`

For additional resources on developing docker images see the links below:

- <https://colinfay.me/docker-r-reproducibility>
- <https://www.fullstackpython.com/docker.html>

## Cleanup

To remove any prior Rstudio sessions and locally installed R-packages, press 8 (+ Enter) in the launch menu. To remove locally installed Python modules press 9 (+ Enter) in the launch menu.

> Note: It is also possible initiate the process of removing locally installed packages and settings from within the container. Open a terminal in Jupyter Lab or Rstudio and type `clean`. Then follow the prompts to indicate what needs to be removed.

You should always stop the `rsm-msba-intel` docker container using `q` (+ Enter) in the launch menu. If you want a full cleanup and reset of the computational environment on your system, however, execute the following commands from a (bash) terminal to (1) remove prior R(studio) and Python packages, (2) remove all docker images, networks, and (data) volumes, and (3) 'pull' only the docker image you need (e.g., rsm-msba-intel):

```bash
rm -rf ~/.rstudio;
rm -rf ~/.rsm-msba;
rm -rf ~/.local/share/jupyter
docker system prune --all --volumes --force;
docker pull vnijs/rsm-msba-intel;
```

## Getting help

Please bookmark this page in your browser for easy access in the future. You can also access the documentation page for your OS by typing h (+ Enter) in the launch menu. Note that the launch script can also be started from the command line (i.e., a bash terminal) and has several important arguments:

* `launch -t 2.7.0` ensures a specific version of the docker container is used. Suppose you used version 2.7.0 for a project. Running the launch script with `-t 2.7.0` from the command line will ensure your code still runs, without modification, years after you last touched it!
* `launch -v ~/rsm-msba` will treat the `~/rsm-msba` directory on the host system (i.e., your macOS computer) as the home directory in the docker container. This can be useful if you want to setup a particular directory that will house multiple projects
* `launch -d ~/project_1` will treat the `project_1` directory on the host system (i.e., your macOS computer) as the project home directory in the docker container. This is an additional level of isolation that can help ensure your work is reproducible in the future. This can be particularly useful in combination with the `-t` option as this will make a copy of the launch script with the appropriate `tag` or `version` already set. Simply double-click the script in the `project_1` directory and you will be back in the development environment you used when you completed the project
* `launch -s` show additional output in the terminal that can be useful to debug any problems
* `launch -h` prints the help shown in the screenshot below

<img src="figures/docker-help.png" width="500px">

## Trouble shooting

The only issues we have seen on macOS so far can be addressed by restarting docker and/or restarting your computer

## Optional

To install python3 from conda on macOS run the command below and follow the prompts to accept the defaults settings.

```bash
sh <(curl -s https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh);
```

For more on minicoda visit the page below:

<https://docs.conda.io/en/latest/miniconda.html>

Once you have completed the install, open a new terminal if you want to install python packages. For example:

```bash
conda install -c conda-forge pandas polars duckdb ipykernel black
```

If you want to make your terminal look nicer and add syntax highlighting, auto-completion, etc. follow the install instructions linked below:

<https://github.com/radiant-rstats/docker/blob/master/install/setup-ohmyzsh.md>

<img src="figures/ohmyzsh-powerlevel10k-iterm.png" width="500px">

To install a more feature-rich terminal for macOS see: <https://iterm2.com/>{target="_blank"}
