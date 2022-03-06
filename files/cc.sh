#!/bin/zsh -i

function conda_create_kernel() {
    mamba create -y -n $1 ipykernel
    mamba activate $1
    ipython kernel install --user --name=$1
    mamba deactivate
}

function conda_create_kernel_from_yml() {
    mamba env create -n $1 --file $2
    mamba activate $1
    ipython kernel install --user --name=$1
    mamba deactivate
}

if [ "$1" != "" ] && [ "$2" != "" ]; then
    conda_create_kernel_from_yml $1 $2
    fun_print=$(declare -f conda_create_kernel_from_yml)
elif [ "$1" != "" ]; then
    conda_create_kernel $1
    fun_print=$(declare -f conda_create_kernel)
else
    echo "The create conda kernel function requires the name of a conda envivronment to create"
fi

echo "You may need to refresh your browser to see the new kernel icon for environment '$1'"
echo ""
echo "The code run in this function is:"

echo $fun_print
