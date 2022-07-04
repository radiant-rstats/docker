#!/usr/bin/env zsh -i

if [ "$1" != "" ]; then
    if [ "$2" != "" ]; then
        fn="$2"
    else
        fn="$PWD/$1.yaml"
    fi
    fprn="conda env export --name $1 > '${fn}'"
    eval $fprn
    echo "\nEnvironment file saved to ${fn}"
    echo "\nThe code run in this function is:\n"
    echo $fprn
else
    echo "\nThe conda export function requires the name of a conda environment to export. You can add a 2nd argument to indicate the file name you want to use for the yaml file. If no 2nd argument is provided the yaml file name will be extracted from the environment name (e.g., 'ce myenv' would generate file myenv.yaml)"
fi

echo "\nSee the link below for additional information about conda"
echo "https://docs.conda.io/projects/conda/en/latest/user-guide/index.html"