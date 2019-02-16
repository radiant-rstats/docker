FROM vnijs/rsm-msba:latest

MAINTAINER Vincent Nijs "radiant@rady.ucsd.edu"

ARG DOCKERHUB_VERSION_UPDATE
ENV DOCKERHUB_VERSION=${DOCKERHUB_VERSION_UPDATE}

ENV DEBIAN_FRONTEND noninteractive

ENV POSTGRES_VERSION=10

## adding postgres
## mostly from https://docs.docker.com/engine/examples/postgresql_service/

## install PostgreSQL 10
RUN apt-get update && apt-get install -y \
  postgresql-${POSTGRES_VERSION} \
  postgresql-client-${POSTGRES_VERSION} \
  postgresql-contrib-${POSTGRES_VERSION}

## Run the rest of the commands as the postgres user
USER postgres

## create a PostgreSQL role named ${NB_USER} with "postgres" as the password and
## then create a database "rsm-docker" owned by the ${NB_USER} role.
RUN /etc/init.d/postgresql start \
    && psql --command "CREATE USER ${NB_USER} WITH SUPERUSER PASSWORD 'postgres';" \
    && createdb -O ${NB_USER} rsm-docker

## reject remote connections to the database
# RUN echo "host all  all    0.0.0.0/0  reject" >> /etc/postgresql/${POSTGRES_VERSION}/main/pg_hba.conf

## allow (remote) access
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/${POSTGRES_VERSION}/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf

VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

USER root

## updating the supervisord.conf file for Jupyter
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80 8787 8989 5432

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
