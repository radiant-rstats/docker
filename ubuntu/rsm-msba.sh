## Installing python packages
pip3 install -r ../rsm-msba/py_requirements.txt

apt-get -y install --no-install-recommends
  libzmq3-dev \
  gpg-agent

APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

## don't use nodejs 10 until this issue is resolved
## https://github.com/jupyter-widgets/ipywidgets/issues/2061
# RUN curl -sL https://deb.nodesource.com/setup_10.x | bash
curl -sL https://deb.nodesource.com/setup_9.x | bash
apt-get install -y nodejs
npm install -g npm
jupyter labextension install @jupyter-widgets/jupyterlab-manager
jupyter labextension install @jupyterlab/shortcutui
jupyter labextension install @jupyterlab/git

## enable jupyterlab git extension
jupyter serverextension enable --py jupyterlab_git --system

R -e 'install.packages(c("repr", "IRdisplay", "crayon", "pbdZMQ", "uuid"))' -e 'devtools::install_github("IRkernel/IRkernel")'
R -e 'IRkernel::installspec(user = FALSE)'

# install google chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
apt-get -y update
apt-get install -y google-chrome-stable

## chromedriver
wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`/chromedriver_linux64.zip
unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/

