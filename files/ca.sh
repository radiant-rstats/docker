#!/usr/bin/env zsh -i

## doesn't work because conda activate must be
## run interactively to work

if [ "$1" != "" ]; then
    fprn="conda activate $1"
    # eval $fprn
    conda activate $1
    echo "\nEnvironment activated: $2"
    echo "\nThe code run in this function is:\n"
    echo $fprn

    echo "\nSee the link below for additional information about conda"
    echo "https://docs.conda.io/projects/conda/en/latest/user-guide/index.html"
else
    echo "\nThis function requires the name of an existing conda environment"
    echo "\nThe following environments are available on your system"
    /usr/local/bin/cl

    echo "\nActivating the conda base environment"
    conda activate
fi