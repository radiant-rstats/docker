# x86_64-ubuntu-22.04	7/25/2024
FROM quay.io/jupyter/pyspark-notebook@sha256:fb5e83562d196ead71f31e4ae1e37c6fe13e1c13c3cbf55d64ffc6166f0aedb7

LABEL Vincent Nijs "radiant@rady.ucsd.edu"

# Fix DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# fixes the issue where sudo requires terminal for password when starting postgres
RUN echo "${NB_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

COPY files/start-services-simplified.sh /usr/local/bin/start-services.sh
RUN chmod +x /usr/local/bin/start-services.sh

# setting up ssh connection
RUN mkdir -p /var/run/sshd \
  && ssh-keygen -A \
  && echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config \
  && echo 'PermitRootLogin no' >> /etc/ssh/sshd_config \
  && echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config \
  && echo "AllowUsers ${NB_USER}" >> /etc/ssh/sshd_config \
  && chmod 0755 /var/run/sshd \
  && chsh -s $(which zsh) ${NB_USER}

EXPOSE 22 8989

# not running any commands yet
CMD ["/usr/local/bin/start-services.sh"]

# Switch back to jovyan to avoid accidental container runs as root
USER ${NB_UID}
ENV HOME /home/${NB_USER}
WORKDIR "${HOME}"
