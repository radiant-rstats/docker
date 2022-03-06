#!/bin/zsh

function conda_import_kernel() {
    mamba env create --file $1
    mamba activate $1
    ipython kernel install --user --name=$1
    mamba deactivate
}

elif [ "$1" != "" ]; then
    conda_import_kernel $1
    echo "You may need to refresh your browser to see the new kernel icon for environment '$1'"
    echo ""
    echo "The code run in this function is:"
    declare -f conda_import_kernel
else
    echo "This function to create a conda kernel requires the path to a yml file with conda envivronment details that you want to create"
fi

echo "\nSee the link below for additional information about conda"
echo "https://docs.conda.io/projects/conda/en/latest/user-guide/index.html"