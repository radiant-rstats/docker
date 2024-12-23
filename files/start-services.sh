#!/bin/bash
set -e

# Setup PostgreSQL data directory with current user permissions
# mkdir -p /var/lib/postgresql/${POSTGRES_VERSION}/main
# chown -R $(id -u):$(id -g) /var/lib/postgresql/${POSTGRES_VERSION}/main

# # Add dynamic user entry to /etc/passwd if it doesn't exist
# if ! grep -q "^${USER}:" /etc/passwd; then
#     echo "${USER}:x:$(id -u):$(id -g)::/home/${USER}:/bin/bash" >> /etc/passwd
# fi

# Start PostgreSQL
# /usr/lib/postgresql/${POSTGRES_VERSION}/bin/postgres -c config_file=/etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf &

# Start sshd
/usr/sbin/sshd -D &

# Start JupyterLab (this will be our foreground process)
# /opt/conda/bin/jupyter lab --ip=0.0.0.0 --port=8989 --allow-root --NotebookApp.token=''