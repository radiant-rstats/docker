#!/usr/bin/env zsh

if [ "$1" != "" ]; then
    echo "Please confirm that you want to remove the conda environment '$1'"
    echo "Press y or n, followed by [ENTER]:"
    read cont
    if [ "${cont}" != "y" ]; then
        echo "The cr (conda remove) function requires the name of a conda envivronment to remove"
        echo "Note that if a jupyter kernel with the same name exists, it will be removed as well"
    else
        echo "\nThe code run in this function is:\n"

        CMD="conda remove -y -n $1 --all"
        echo "$CMD\n"
        eval $CMD

        CMD="jupyter kernelspec remove -y $1"
        echo "$CMD\n"
        eval $CMD

        echo "\nSee the link below for additional information about conda"
        echo "https://docs.conda.io/projects/conda/en/latest/user-guide/index.html"
    fi
else
    echo "The conda_remove function requires the name of a conda envivronment to remove"
    echo "Note that if a jupyter kernel with the same name exists, it will be removed as well"
fi

