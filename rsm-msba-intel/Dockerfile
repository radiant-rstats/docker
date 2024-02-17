FROM vnijs/rsm-msba-intel:2.9.1


LABEL Vincent Nijs "radiant@rady.ucsd.edu"

ARG DOCKERHUB_VERSION_UPDATE
ENV DOCKERHUB_VERSION=${DOCKERHUB_VERSION_UPDATE}
ENV DOCKERHUB_NAME=rsm-msba-intel

# Fix DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

RUN apt-get update -qq && apt-get -y --no-install-recommends install lsof
RUN pip install pyrsm --upgrade

# setup hadoop
ENV JAVA_HOME "/usr/lib/jvm/java-17-openjdk-amd64/"
ENV HADOOP_VERSION 3.3.4
ENV HADOOP_HOME /opt/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
COPY files/setup-hadoop.sh setup.sh
RUN chmod +x setup.sh \
  && ./setup.sh \
  && rm setup.sh

# hadoop configuration
ADD files/scalable_analytics/core-site.xml $HADOOP_HOME/etc/hadoop/
ADD files/scalable_analytics/hdfs-site.xml $HADOOP_HOME/etc/hadoop/
ADD files/scalable_analytics/init-dfs.sh /opt/hadoop/
ADD files/scalable_analytics/start-dfs.sh /opt/hadoop/
ADD files/scalable_analytics/stop-dfs.sh /opt/hadoop/
RUN chown -R ${NB_USER} ${HADOOP_HOME} \
  && chmod 755 ${HADOOP_HOME}/*.sh \
  && chmod 755 /usr/bin/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin

# setting up ssh connection
RUN mkdir -p /var/run/sshd \
  && ssh-keygen -A \
  && echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config \
  && echo 'PermitRootLogin no' >> /etc/ssh/sshd_config \
  && echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config \
  && chsh -s $(which zsh) ${NB_USER}

EXPOSE 22 4040 4041 8181 8282 8765 8989 8501 8000
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Switch back to jovyan to avoid accidental container runs as root
USER ${NB_UID}
ENV HOME /home/${NB_USER}
WORKDIR "${HOME}"
