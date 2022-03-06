#!/bin/zsh -i

function conda_export_kernel() {
    conda env export --name $1 > $2
}

if [ "$1" != "" ] && [ "$2" != "" ]; then
    conda_export_kernel $1 $2
    fun_print=$(declare -f conda_export_kernel)
elif [ "$1" != "" ]; then
    fn = "$(pwd)/$2.yml"
    conda_export_kernel $1 > "$fn"
    fun_print=$(declare -f conda_export_kernel)
else
    echo "The create conda kernel function requires the name of a conda envivronment to create"
fi

echo "The code run in this function is:"
echo $fun_print

echo "\nSee the link below for additional information about conda"
echo "https://docs.conda.io/projects/conda/en/latest/user-guide/index.html"