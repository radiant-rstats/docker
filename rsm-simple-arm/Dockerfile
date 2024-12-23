# find all here: https://quay.io/repository/jupyter/pyspark-notebook?tab=tags
# aarch64-10.22.2024 problems running dpkg for some reason
# impacts installs that need to find OS stuff but gets blocked by conda paths
FROM quay.io/jupyter/pyspark-notebook@sha256:319eae80d974242c03a3f744a63f373d35b17e4b9d1203c2a0175660f7b0ad0e

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

EXPOSE 22

# Switch back to jovyan to avoid accidental container runs as root
USER ${NB_UID}
ENV HOME /home/${NB_USER}
# WORKDIR "${HOME}"

# not running any commands yet
# ENTRYPOINT []
CMD ["/usr/local/bin/start-services.sh"]
# CMD ["/bin/bash"]

