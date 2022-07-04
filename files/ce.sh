#!/usr/bin/env zsh -i

if [ "$1" != "" ] && [ "$2" != "" ]; then
    fprn="conda env export --name $1 > '$2'"
    eval $fprn
    echo "\nEnvironment file saved to $2"
    echo "\nThe code run in this function is:\n"
    echo $fprn
elif [ "$1" != "" ]; then
    fn="$PWD/$1.yml"
    fprn="conda env export --name $1 > '${fn}'"
    eval $fprn
    echo "\nEnvironment file saved to ${fn}"
    echo "\nThe code run in this function is:\n"
    echo $fprn
else
    echo "\nThe conda export function requires the name of a conda environment to export"
fi
echo "\nSee the link below for additional information about conda"
echo "https://docs.conda.io/projects/conda/en/latest/user-guide/index.html"