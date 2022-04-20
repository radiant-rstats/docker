# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

from jupyter_core.paths import jupyter_data_dir
import subprocess
import os
import errno
import stat

c = get_config()
c.NotebookApp.ip = "0.0.0.0"
c.NotebookApp.port = 8989
c.NotebookApp.open_browser = False
c.NotebookApp.allow_origin = "*"

# settings for system monitor (does not enforce)
c.ResourceUseDisplay.mem_limit = 8 * 1024 * 1024 * 1024
c.ResourceUseDisplay.track_cpu_percent = True
c.ResourceUseDisplay.cpu_limit = 4

# https://github.com/jupyter/notebook/issues/3130
c.FileContentsManager.delete_to_trash = False


def _radiant_command(port):
    return [
        "/usr/local/bin/R",
        "-e",
        f"radiant.data::launch(package='radiant', host='0.0.0.0', port={port}, run=FALSE)",
    ]


def _gitgadget_command(port):
    return [
        "/usr/local/bin/R",
        "-e",
        f"gitgadget::gitgadget(host='0.0.0.0', port={port}, launch.browser=FALSE)",
    ]


c.ServerProxy.servers = {
    "radiant": {
        "command": _radiant_command,
        "timeout": 30,
        "launcher_entry": {
            "title": "Radiant",
            "icon_path": "/opt/shiny/logo.svg",
        },
    },
    "gitgadget": {
        "command": _gitgadget_command,
        "timeout": 30,
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
