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
c.NotebookApp.port = 8888
c.NotebookApp.open_browser = False
c.NotebookApp.allow_origin = "*"

# https://github.com/jupyter/notebook/issues/3130
c.FileContentsManager.delete_to_trash = False

# shutdown the server after no activity for an hour
c.NotebookApp.shutdown_no_activity_timeout = 60 * 60

# shutdown kernels after no activity for 30 minutes
c.MappingKernelManager.cull_idle_timeout = 30 * 60

# check for idle kernels every two minutes
c.MappingKernelManager.cull_interval = 2 * 60

# custom start url
c.NotebookApp.custom_display_url = "http://127.0.0.1:" + str(c.NotebookApp.port)


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
        site_dir="/srv/shiny-server/radiant/inst/app",  # or your path
    )

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
        site_dir="/srv/shiny-server/gitgadget/inst/app",  # or your path
    )

    # shiny-server configuration
    f = tempfile.NamedTemporaryFile(mode="w", delete=False)
    f.write(conf)
    f.close()

    return ["shiny-server", f.name]


def _codeserver_command(port):
    full_path = shutil.which("code-server")
    if not full_path:
        raise FileNotFoundError("Can not find code-server in $PATH")
    # lstrip is used as a hack to deal with using paths in environments
    # when using git-bash on windows
    working_dir = os.getenv("CODE_WORKINGDIR", None).lstrip()
    if working_dir is None:
        working_dir = os.getenv("JUPYTER_SERVER_ROOT", ".")
    elif os.path.isdir(working_dir) is False:
        os.mkdir(working_dir)
    data_dir = os.getenv("CODE_USER_DATA_DIR", "")
    if data_dir != "":
        data_dir = "--user-data-dir=" + str(data_dir)
    extensions_dir = os.getenv("CODE_EXTENSIONS_DIR", "")
    if extensions_dir != "":
        extensions_dir = "--extensions-dir=" + str(extensions_dir)
    builtin_extensions_dir = os.getenv("CODE_BUILTIN_EXTENSIONS_DIR", "")
    if builtin_extensions_dir != "":
        builtin_extensions_dir = "--extra-builtin-extensions-dir=" + str(
            builtin_extensions_dir
        )

    return [
        full_path,
        "--bind-addr=0.0.0.0:" + str(port),
        "--auth",
        "none",
        data_dir,
        extensions_dir,
        builtin_extensions_dir,
        working_dir,
    ]


# def _help_command():
#     full_path = shutil.which("python3")
#     url = "https://github.com/radiant-rstats/docker/blob/master/install/rsm-msba-linux.md"
    # cmd = f"from IPython import display; display.display(display.Javascript('window.open(\"{url}\");'.format(url=\"{url}\")))"
    # return [full_path, "-c", cmd]
    # return [full_path, "-c", f"from webbrowser import open_new; open_new(\"{url}\")"]
    


c.ServerProxy.servers = {
    "radiant": {
        "command": _radiant_command,
        "timeout": 20,
        "launcher_entry": {"title": "Radiant", "icon_path": "/opt/radiant/logo.svg"},
    },
    "gitgadget": {
        "command": _gitgadget_command,
        "timeout": 20,
        "launcher_entry": {
            "title": "Git Gadget",
            "icon_path": "/opt/gitgadget/gitgadget.svg",
        },
    },
    "vscode": {
        "command": _codeserver_command,
        "timeout": 20,
        "launcher_entry": {
            "title": "VS Code",
            "icon_path": "/opt/code-server/vscode.svg",
        },
    },
    # "help": {
    #     "command": _help_command,
    #     "timeout": 20,
    #     "launcher_entry": {
    #         "title": "Help",
    #         "icon_path": "/opt/help/help.svg",
    #     },
    # },
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

os.environ["PYTHONUSERBASE"] = "/home/jovyan/.rsm-msba"
