FROM vnijs/rsm-msba-spark:latest
LABEL Vincent Nijs "radiant@rady.ucsd.edu"
USER root

# Configure Hadoop 
COPY ./ci-test-case1.R /opt/mgta453/
RUN chmod 644 -R /opt/mgta453
RUN chmod +rx /opt/mgta453

EXPOSE 8989 8765 22

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

USER ${NB_USER}
ENV HOME /home/${NB_USER}
