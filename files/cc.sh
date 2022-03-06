#!/bin/zsh -i

function conda_create_kernel() {
    mamba create -y -n $1 ipykernel $2
    mamba activate $1
    ipython kernel install --user --name=$1
    mamba deactivate
}

if [ "$1" != "" ]; then
    conda_create_kernel $1
    echo "The code run in this function is:"
    declare -f conda_create_kernel
    echo "You may need to refresh your browser to see the new kernel icon for environment '$1'"
else
    echo "This function to create a conda kernel requires the name of a conda envivronment to create and the names of any packages you want to install"
fi

echo "\nSee the link below for additional information about conda"
echo "https://docs.conda.io/projects/conda/en/latest/user-guide/index.html"
