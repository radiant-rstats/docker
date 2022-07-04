#!/usr/bin/env zsh

function conda_create_kernel() {
    if { conda env list | grep "$1"; } >/dev/null 2>&1; then
        echo "Conda environment $1 already exists"
        echo "Adding packages to $1"
    else
        conda create -y -n $1
    fi

    conda activate $1
    conda install -y -c conda-forge ipykernel "${@:2}"
    ipython kernel install --user --name=$1
    conda deactivate
}

if [ "$1" != "" ]; then
    conda_create_kernel $1 ${@:2}
    echo "The code run in this function is:"
    declare -f conda_create_kernel
    echo "You may need to refresh your browser to see the new kernel icon for environment '$1'"
else
    echo "This function is used to create a conda environment kernel and requires the name of a conda envivronment to create and the names of any packages you want to install. For example:"
    echo "cc myenv pyasn1"
fi

echo "\nSee the link below for additional information about conda"
echo "https://docs.conda.io/projects/conda/en/latest/user-guide/index.html"
