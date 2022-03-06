#!/bin/zsh

function conda_remove() {
    conda remove -y -n $1 --all
    jupyter kernelspec remove -y $1
}

if [ "$1" != "" ]; then
    echo "Please confirm that you want to remove the conda environment '$1'"
    echo "Press y or n, followed by [ENTER]:"
    read cont
    if [ "${cont}" != "y" ]; then
        echo "The conda_remove function requires the name of a conda envivronment to remove"
        echo "Note that if a jupyter kernel with the same exists, it will be removed as well"
    else
        conda_remove $1
    fi
else
    echo "The conda_remove function requires the name of a conda envivronment to remove"
    echo "Note that if a jupyter kernel with the same exists, it will be removed as well"
fi

echo ""
echo "The code run in this function is:"
declare -f conda_remove

echo "\nSee the link below for additional information about conda"
echo "https://docs.conda.io/projects/conda/en/latest/user-guide/index.html"