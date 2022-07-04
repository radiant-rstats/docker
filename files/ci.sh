#!/usr/bin/env zsh -i

function conda_import_environment() {
    env=$(basename -- "$1")
    env="${filename%.*}"
    conda env create --file $1 --name "${env}"
    conda activate $1
    ipython kernel install --user --name=$1
    conda deactivate
}

if [ "$1" != "" ]; then
    conda_import_environment $1
    echo "You may need to refresh your browser to see the new kernel icon for environment '$1'\n"
    echo "The code run in this function is:"
    declare -f conda_import_environment
else
    echo "This function to import a conda environment requires the path to a yml file with conda envivronment details to be used"
fi

echo "\nSee the link below for additional information about conda"
echo "https://docs.conda.io/projects/conda/en/latest/user-guide/index.html"