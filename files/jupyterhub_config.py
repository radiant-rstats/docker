# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

# Configuration file for JupyterHub
import os
from pwd import getpwnam
from grp import getgrnam
from dockerspawner import DockerSpawner
import docker


c = get_config()

max_num_cpu = 6


class MyDockerSpawner(DockerSpawner):
    def uid_for_user(self, user):
        return getpwnam(user.name).pw_uid

    def gid_for_user(self, user):
        return getgrnam(user.name).gr_gid

    def get_env(self):
        env = super().get_env()
        env["NB_UID"] = self.uid_for_user(self.user)
        env["NB_GID"] = self.gid_for_user(self.user)
        env["PYTHONUSERBASE"] = "~/.rsm-msba"
        env["OPENBLAS_NUM_THREADS"] = str(max_num_cpu)
        env["OMP_NUM_THREADS"] = str(max_num_cpu)
        # new stuff starts here
        env["JUPYTERHUB_VERSION"] = "2.2.0"
        env["DOCKER_MACHINE_NAME"] = "jupyterhub"
        env["DOCKER_NETWORK_NAME"] = "jupyterhub-network"
        env["DOCKER_NOTEBOOK_IMAGE"] = "jupyterhub-user"
        env["LOCAL_NOTEBOOK_IMAGE"] = "jupyterhub-user"
        env["DOCKER_NOTEBOOK_DIR"] = "/home/jovyan/"
        env["DOCKER_SPAWN_CMD"] = "start-singleuser.sh"
        env["SSL_KEY"] = "/etc/jupyterhub/secrets/rsm-compute-01.ucsd.edu.key"
        env["SSL_CERT"] = "/etc/jupyterhub/secrets/chained.crt"
        env[
            "COOKIE_SECRET_FILE_PATH"
        ] = "/etc/jupyterhub/secrets/jupyterhub_cookie_secret"
        env["SQLITE_FILE_PATH"] = "/etc/jupyterhub/secrets/jupyterhub.sqlite"
        env["PROXY_PID_FILE_PATH"] = "/etc/jupyterhub/secrets/jupyterhub-proxy.pid"
        return env


c.DockerSpawner.extra_create_kwargs = {"user": "root"}
c.Authenticator.delete_invalid_users = True

# We rely on environment variables to configure JupyterHub so that we
# avoid having to rebuild the JupyterHub container every time we change a
# configuration parameter.

# Spawn single-user servers as Docker containers
# c.JupyterHub.spawner_class = 'dockerspawner.DockerSpawner'
c.JupyterHub.spawner_class = MyDockerSpawner
# Spawn containers from this image
# c.DockerSpawner.image = os.environ["DOCKER_NOTEBOOK_IMAGE"]
c.DockerSpawner.image = "vnijs/rsm-msba-intel-jupyterhub"  # this line may be omitted
# JupyterHub requires a single-user instance of the Notebook server, so we
# default to using the `start-singleuser.sh` script included in the
# jupyter/docker-stacks *-notebook images as the Docker run command when
# spawning containers.  Optionally, you can override the Docker run command
# using the DOCKER_SPAWN_CMD environment variable.
spawn_cmd = os.environ.get("DOCKER_SPAWN_CMD", "start-singleuser.sh")
c.DockerSpawner.extra_create_kwargs.update({"command": spawn_cmd})
# Connect containers to this Docker network
# network_name = os.environ["DOCKER_NETWORK_NAME"]
network_name = "jupyterhub-network"
c.DockerSpawner.use_internal_ip = True
c.DockerSpawner.network_name = network_name
# Pass the network name as argument to spawned containers
c.DockerSpawner.extra_host_config = {
    "network_mode": network_name,
    "cpu_period": 100000,
    "cpu_quota": max_num_cpu * 100000,
    # "device_requests": [docker.types.DeviceRequest(count=-1, capabilities=[["gpu"]])]
}
c.Spawner.mem_limit = (
    "16G"  # cpu limit set above using c.DockerSpawner.extra_host_config
    # "64G"  # cpu limit set above using c.DockerSpawner.extra_host_config
)
c.DockerSpawner.cpu_limit = 0.5
c.Spawner.cpu_limit = 0.5

# Explicitly set notebook directory because we'll be mounting a host volume to
# it.  Most jupyter/docker-stacks *-notebook images run the Notebook server as
# user `jovyan`, and set the notebook directory to `/home/jovyan/work`.
# We follow the same convention.
notebook_dir = os.environ.get("DOCKER_NOTEBOOK_DIR") or "/home/jovyan/work"
c.DockerSpawner.notebook_dir = notebook_dir


c.DockerSpawner.environment = {"JUPYTER_ENABLE_LAB": "yes"}


# Mount the real user's Docker volume on the host to the notebook user's
# notebook directory in the container
c.DockerSpawner.volumes = {
    "/home/{username}": notebook_dir,
    "pg_data_{username}": "/var/lib/postgresql/14/main",
    "/srv/jupyterhub/resources": "/srv/jupyterhub/resources",
    "/srv/jupyterhub/capstone_data": "/srv/jupyterhub/capstone_data",
}

c.DockerSpawner.read_only_volumes = {
    "/srv/jupyterhub/read-only": "/srv/jupyterhub/read-only",
    "/home/vnijs/Dropbox/": "/home/vnijs/Dropbox/",
}

# Remove containers once they are stopped
c.DockerSpawner.remove_containers = True
c.JupyterHub.cleanup_servers = False

# User containers will access hub by container name on the Docker network
c.JupyterHub.hub_ip = "172.17.0.1"
c.JupyterHub.hub_port = 8080

# TLS config
# c.JupyterHub.port = 443
# c.JupyterHub.ssl_key = os.environ["SSL_KEY"]
c.JupyterHub.ssl_key = "/etc/jupyterhub/secrets/rsm-compute-01.ucsd.edu.key"
# c.JupyterHub.ssl_cert = os.environ["SSL_CERT"]
c.JupyterHub.ssl_cert = "/etc/jupyterhub/secrets/chained.crt"

# Reverse proxy config
# c.JupyterHub.port = 8000
c.JupyterHub.port = 8000
c.JupyterHub.bind_url = "http://127.0.0.1:8000"
# c.JupyterHub.bind_url = 'https://rsm-compute-01.ucsd.edu'


# New
# c.JupyterHub.ip = '127.0.0.1'
c.JupyterHub.ip = "0.0.0.0"

c.JupyterHub.concurrent_spawn_limit = 80
c.Spawner.start_timeout = 120

c.PAMAuthenticator.open_sessions = False

from jupyterhub.auth import PAMAuthenticator
import pamela
from tornado import gen


class KerberosPAMAuthenticator(PAMAuthenticator):
    @gen.coroutine
    def authenticate(self, handler, data):
        """Authenticate with PAM, and return the username if login is successful.
        Return None otherwise.
        Establish credentials when authenticating instead of reinitializing them
        so that a Kerberos cred cache has the proper UID in it.
        """
        username = data["username"]
        try:
            pamela.authenticate(
                username,
                data["password"],
                service=self.service,
                resetcred=pamela.PAM_ESTABLISH_CRED,
            )
        except pamela.PAMError as e:
            if handler is not None:
                self.log.warning(
                    "PAM Authentication failed (%s@%s): %s",
                    username,
                    handler.request.remote_ip,
                    e,
                )
            else:
                self.log.warning("PAM Authentication failed: %s", e)
        else:
            return username


c.JupyterHub.authenticator_class = KerberosPAMAuthenticator


# c.JupyterHub.cookie_secret_file = os.environ["COOKIE_SECRET_FILE_PATH"]
c.JupyterHub.cookie_secret_file = "/etc/jupyterhub/secrets/jupyterhub_cookie_secret"
# c.JupyterHub.db_url = os.environ["SQLITE_FILE_PATH"]
c.JupyterHub.db_url = "/etc/jupyterhub/secrets/jupyterhub.sqlite"
# c.ConfigurableHTTPProxy.pid_file = os.environ["PROXY_PID_FILE_PATH"]
c.ConfigurableHTTPProxy.pid_file = "/etc/jupyterhub/secrets/jupyterhub-proxy.pid"


# c.JupyterHub.log_level = 'DEBUG'
# c.Spawner.debug = True
# c.DockerSpawner.debug = True

# Whitlelist users and admins
c.Authenticator.whitelist = whitelist = set()
c.Authenticator.admin_users = admin = set()
c.JupyterHub.admin_access = True
pwd = os.path.dirname(__file__)
with open(os.path.join(pwd, "userlist")) as f:
    for line in f:
        if line:
            #    continue
            parts = line.split()
            # in case of newline at the end of userlist file
            if len(parts) >= 1:
                name = parts[0]
                # whitelist.add(name)
                if len(parts) > 1 and parts[1] == "admin":
                    admin.add(name)
