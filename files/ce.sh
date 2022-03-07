#!/bin/zsh

function conda_export_kernel() {
    conda env export --name $1 > $2
}

if [ "$1" != "" ] && [ "$2" != "" ]; then
    conda_export_kernel $1 $2
    fun_print=$(declare -f conda_export_kernel)
    echo "Environment file saved to $2\n"
elif [ "$1" != "" ]; then
    fn="$PWD/$1.yml"
    echo "${fn}"
    conda_export_kernel $1 "${fn}"
    fun_print=$(declare -f conda_export_kernel)
    echo "Environment file saved to ${fn}"
else
    echo "The create conda kernel function requires the name of a conda envivronment to create"
fi

echo "The code run in this function is:"
echo $fun_print

echo "\nSee the link below for additional information about conda"
echo "https://docs.conda.io/projects/conda/en/latest/user-guide/index.html"