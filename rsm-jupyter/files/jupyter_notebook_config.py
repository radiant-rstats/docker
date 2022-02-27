# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

from jupyter_core.paths import jupyter_data_dir
import subprocess
import os
import shutil
import errno
import stat
import textwrap
import getpass
import tempfile

c = get_config()
c.NotebookApp.ip = "0.0.0.0"
c.NotebookApp.port = 8989
c.NotebookApp.open_browser = False
c.NotebookApp.allow_origin = "*"

# https://github.com/jupyter/notebook/issues/3130
c.FileContentsManager.delete_to_trash = False


def _radiant_command(port):
    # based on @yuvipanda's comments
    # https://github.com/yuvipanda/jupyter-launcher-shortcuts/issues/1
    conf = textwrap.dedent(
        """
        run_as {user};
        # make debugging easier
        sanitize_errors false;
        preserve_logs true;
        # access_log /var/log/shiny-server/access.log dev;
        server {{
            listen {port};
            location / {{
                site_dir {site_dir};
                log_dir /var/log/shiny-server;
                reconnect false;
                directory_index off;
            }}
        }}
    """
    ).format(
        user=getpass.getuser(),
        port=str(port),
        site_dir="/opt/shiny/radiant/inst/app",
    )

    # shiny-server configuration
    f = tempfile.NamedTemporaryFile(mode="w", delete=False)
    f.write(conf)
    f.close()

    return ["shiny-server", f.name]


def _gitgadget_command(port):
    # based on @yuvipanda's comments
    # https://github.com/yuvipanda/jupyter-launcher-shortcuts/issues/1
    conf = textwrap.dedent(
        """
        run_as {user};
        # make debugging easier
        sanitize_errors false;
        preserve_logs true;
        # access_log /var/log/shiny-server/access.log dev;
        server {{
            listen {port};
            location / {{
                site_dir {site_dir};
                log_dir /var/log/shiny-server;
                reconnect false;
                directory_index off;
            }}
        }}
    """
    ).format(
        user=getpass.getuser(),
        port=str(port),
        site_dir="/opt/shiny/gitgadget/inst/app",
    )

    # shiny-server configuration
    f = tempfile.NamedTemporaryFile(mode="w", delete=False)
    f.write(conf)
    f.close()

    return ["shiny-server", f.name]


c.ServerProxy.servers = {
    "radiant": {
        "command": _radiant_command,
        "timeout": 20,
        "launcher_entry": {
            "title": "Radiant",
            "icon_path": "/opt/shiny/logo.svg",
        },
    },
    "gitgadget": {
        "command": _gitgadget_command,
        "timeout": 20,
        "launcher_entry": {
            "title": "Git Gadget",
            "icon_path": "/opt/shiny/gitgadget.svg",
        },
    },
}

# Generate a self-signed certificate
if "GEN_CERT" in os.environ:
    dir_name = jupyter_data_dir()
    pem_file = os.path.join(dir_name, "notebook.pem")
    try:
        os.makedirs(dir_name)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(dir_name):
            pass
        else:
            raise
    # Generate a certificate if one doesn't exist on disk
    subprocess.check_call(
        [
            "openssl",
            "req",
            "-new",
            "-newkey",
            "rsa:2048",
            "-days",
            "365",
            "-nodes",
            "-x509",
            "-subj",
            "/C=XX/ST=XX/L=XX/O=generated/CN=generated",
            "-keyout",
            pem_file,
            "-out",
            pem_file,
        ]
    )
    # Restrict access to the file
    os.chmod(pem_file, stat.S_IRUSR | stat.S_IWUSR)
    c.NotebookApp.certfile = pem_file
