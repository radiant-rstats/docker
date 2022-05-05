#!/bin/bash
set -e

if [ "$(uname -m)" != "aarch64" ]; then
  conda install -y pytorch torchvision cpuonly -c pytorch
  pip3 install numpyro
  pip3 install jaxlib==0.3.7
else
  mamba install -y astunparse numpy ninja pyyaml setuptools cmake cffi \
    typing_extensions future six requests dataclasses
  export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}
  git clone --recursive https://github.com/pytorch/pytorch
  cd pytorch
  git checkout 201ddafc22e22c387b4cd654f397e05354d73d09
  git submodule sync
  git submodule update --init --recursive --jobs 0
  python setup.py install

  git clone https://github.com/pytorch/vision.git
  cd vision
  git checkout ecbff88a1ad605bf04d6c44862e93dde2fdbfc84
  git submodule sync
  git submodule update --init --recursive --jobs 0
  python setup.py install

  cd ..
  rm -rf pytorch
  rm -rf vision
  # conda install -y torchvision cpuonly -c pytorch
fi

