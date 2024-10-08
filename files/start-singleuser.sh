#!/bin/bash
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

set -e

## starting up postgres
exec sudo -u postgres /usr/lib/postgresql/${POSTGRES_VERSION}/bin/postgres -c config_file=/etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf &
exec sudo /usr/sbin/sshd -D &

# set default ip to 0.0.0.0
if [[ "$NOTEBOOK_ARGS $@" != *"--ip="* ]]; then
    NOTEBOOK_ARGS="--ip=0.0.0.0 $NOTEBOOK_ARGS"
fi

# handle some deprecated environment variables
# from DockerSpawner < 0.8.
# These won't be passed from DockerSpawner 0.9,
# so avoid specifying --arg=empty-string
if [ ! -z "$NOTEBOOK_DIR" ]; then
    NOTEBOOK_ARGS="--notebook-dir='$NOTEBOOK_DIR' $NOTEBOOK_ARGS"
fi
if [ ! -z "$JPY_PORT" ]; then
    NOTEBOOK_ARGS="--port=$JPY_PORT $NOTEBOOK_ARGS"
fi
if [ ! -z "$JPY_USER" ]; then
    NOTEBOOK_ARGS="--user=$JPY_USER $NOTEBOOK_ARGS"
fi
if [ ! -z "$JPY_COOKIE_NAME" ]; then
    NOTEBOOK_ARGS="--cookie-name=$JPY_COOKIE_NAME $NOTEBOOK_ARGS"
fi
if [ ! -z "$JPY_BASE_URL" ]; then
    NOTEBOOK_ARGS="--base-url=$JPY_BASE_URL $NOTEBOOK_ARGS"
fi
if [ ! -z "$JPY_HUB_PREFIX" ]; then
    NOTEBOOK_ARGS="--hub-prefix=$JPY_HUB_PREFIX $NOTEBOOK_ARGS"
fi
if [ ! -z "$JPY_HUB_API_URL" ]; then
    NOTEBOOK_ARGS="--hub-api-url=$JPY_HUB_API_URL $NOTEBOOK_ARGS"
fi

NOTEBOOK_BIN="jupyterhub-singleuser --SingleUserNotebookApp.default_url=/lab"

. /usr/local/bin/start.sh $NOTEBOOK_BIN $NOTEBOOK_ARGS "$@"