# Use a base image
FROM jupyter/all-spark-notebook:2023-07-28

# Prevents prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
USER root

# Update and install ssh server
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    openssh-server \
    python-is-python3 \
    zsh

# Create directory for sshd
RUN mkdir /var/run/sshd

# Create SSH host keys
RUN ssh-keygen -A

# Set password for the user (you should change 'ubuntu' to a secure password)
RUN echo 'jovyan:ubuntu' | chpasswd

# SSH login fix, otherwise user gets kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Deny root logins
RUN echo 'PermitRootLogin no' >> /etc/ssh/sshd_config

# oh-my-zsh (need to install wget and curl again ...)
RUN apt-get update -qq && apt-get -y --no-install-recommends install wget curl \
    && sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    && git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && git clone https://github.com/supercrabtree/k ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/k \
    && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k \
    && cp -R /home/jovyan/.oh-my-zsh /etc/skel/.oh-my-zsh

COPY files/zshrc /etc/skel/.zshrc
COPY files/p10k.zsh /etc/skel/.p10k.zsh
COPY files/usethis /usr/local/bin/usethis
COPY files/clean.sh /usr/local/bin/clean

# settings for local install of python packages 
ARG PYBASE=/home/${NB_USER}/.rsm-msba
ENV PYBASE=${PYBASE}
ENV PYTHONUSERBASE=${PYBASE} \
    JUPYTER_PATH=${PYBASE}/share/jupyter \
    JUPYTER_DATA_DIR=${PYBASE}/share/jupyter \
    JUPYTER_CONFIG_DIR=${PYBASE}/jupyter \
    JUPYTER_RUNTIME_DIR=/tmp/jupyter/runtime \
    RSTUDIO_WHICH_R=/usr/local/bin/R \
    SHELL=/bin/zsh \
    ZDOTDIR=/home/${NB_USER}/.rsm-msba/zsh 

# Activate Conda environment in all new shells
RUN echo "source /opt/conda/etc/profile.d/conda.sh" >> /etc/zkel/.zshrc \
    && echo "conda activate base" >> /etc/zkel/.zshrc

# Change default shell to zsh
RUN chsh -s $(which zsh)

# for Jupyter and the notebook_config file
COPY files/condarc /opt/conda/.condarc
COPY files/setup.sh /usr/local/bin/setup
RUN fix-permissions /etc/skel \
    && fix-permissions /usr/local/bin \
    && chmod 755 /usr/local/bin/*

# Expose port 22 for ssh
EXPOSE 22

# Run sshd
CMD ["/usr/sbin/sshd", "-D"]

# Set user to jovyan
# USER ${NB_UID}