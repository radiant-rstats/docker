#!/bin/zsh -i

set -e

function conda_import_environment() {
    if [ "$2" != "" ]; then
        env_name="$2"
    else
        env_name=$(basename -- "$1")
        env_name="${env_name%.*}"
    fi
    conda env create --file "$1" --name "${env_name}"
    conda activate "${env_name}"
    ipython kernel install --user --name="${env_name}"
    conda deactivate
    echo "You may need to refresh your browser to see the new kernel icon for environment '${env}'\n"
}

if [ "$1" != "" ]; then
    conda_import_environment $1 $2
    echo "You may need to refresh your browser to see the new kernel icon for environment '$1' \n"
    echo "The code run in this function is:"
    declare -f conda_import_environment
else
    echo "This function to import a conda environment requires the path to a yml file with conda envivronment details to be used. You can add a 2nd argument to indicate the name you want to use for the new environment. If no 2nd argument is provided the environment name will be extracted from the yaml file name"
fi

echo "\nSee the link below for additional information about conda"
echo "https://docs.conda.io/projects/conda/en/latest/user-guide/index.html"
