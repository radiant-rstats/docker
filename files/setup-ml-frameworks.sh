#!/bin/bash
set -e

if [ "$(uname -m)" != "aarch64" ]; then
  # has to be conda for some reason
  # conda install -y pytorch torchvision cpuonly -c pytorch
  pip install -y pytorch torchvision
  # pip install jaxlib==0.3.7
  # pip install jaxlib==0.3.22
  # pip install jaxlib==0.3.24 numpyro
else
  # mamba install -y astunparse numpy ninja pyyaml setuptools cmake cffi \
  #   typing_extensions future six requests dataclasses
  # export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}
  # git clone --recursive https://github.com/pytorch/pytorch
  # cd pytorch
  # # git checkout 201ddafc22e22c387b4cd654f397e05354d73d09
  # # git checkout 8a5cc940e39820ad61dedee5c01f366af182ff3a
  # # git checkout 945d333ae485673d7a603ca71822c9a39ca4775a
  # git checkout 76af71444a43962ee3e1cef987ac2028f2b8f44d
  # git submodule sync
  # git submodule update --init --recursive --jobs 0
  # python setup.py install

  # git clone https://github.com/pytorch/vision.git
  # cd vision
  # # git checkout ecbff88a1ad605bf04d6c44862e93dde2fdbfc84
  # # git checkout fb7f9a16628cb0813ac958da4525247e325cc3d2
  # # git checkout f467349ce0d41c23695538add22f6fec5a30ece4
  # git checkout deba056203d009fec6b58afb9fa211f6ee3328c8 
  # git submodule sync
  # git submodule update --init --recursive --jobs 0
  # python setup.py install

  # cd ..
  # rm -rf pytorch
  # rm -rf vision
  # conda install -y torchvision cpuonly -c pytorch


  # mamba install -y pytorch torchvision "pillow<9" -c pytorch -c anaconda
  # mamba install -y "pillow<9" -c anaconda
  mamba install -y pytorch torchvision cpuonly -c pytorch

  ## current version on conda-forge is 9.2.0
  ## caused problems for torchvision
  # mamba install -y "pillow<9" -c anaconda
fi

