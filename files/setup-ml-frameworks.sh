#!/bin/bash
set -e

if [ "$(uname -m)" != "aarch64" ]; then
  mamba install -y -c pytorch \
    pytorch \
    cpuonly
else
  mamba install -y astunparse numpy ninja pyyaml setuptools cmake cffi \
    typing_extensions future six requests dataclasses
  export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}
  git clone --recursive https://github.com/pytorch/pytorch/commit/201ddafc22e22c387b4cd654f397e05354d73d09
  cd pytorch
  git submodule sync \
  git submodule update --init --recursive --jobs 0 \
  python setup.py install
fi

mamba install -y -c conda-forge numpyro
