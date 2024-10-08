#!/bin/bash
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

set -e

exec sudo -u postgres /usr/lib/postgresql/${POSTGRES_VERSION}/bin/postgres -c config_file=/etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf &
exec sudo /usr/sbin/sshd -D &

if [[ ! -z "${JUPYTERHUB_API_TOKEN}" ]]; then
  # launched by JupyterHub, use single-user entrypoint
  exec /usr/local/bin/start-singleuser.sh $*
else
  if [[ ! -z "${JUPYTER_ENABLE_LAB}" ]]; then
    . /usr/local/bin/start.sh jupyter lab $*
  else
    . /usr/local/bin/start.sh jupyter notebook $*
  fi
fi

