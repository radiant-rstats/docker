#!/usr/bin/env zsh

CMD="conda info --envs"
echo "$CMD\n"
eval $CMD

CMD="jupyter kernelspec list"
echo "$CMD\n"
eval $CMD

echo "\nSee the link below for additional information about conda"
echo "https://docs.conda.io/projects/conda/en/latest/user-guide/index.html"
