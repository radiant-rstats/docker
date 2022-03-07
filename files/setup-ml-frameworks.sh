#!/bin/bash
set -e

mamba install -y -c \
  tensorflow \
  keras 

if [ "$(uname -m)" != "aarch64" ]; then
  # ML frameworks that are not (yet) available for ARM64
  # 'pytorch' \
  # 'pyro-ppl' \
  # 'jax' \
  # 'jaxlib' \
  mamba install -y -c \
    numpyro
fi

mamba clean --all -f -y \
  && fix-permissions "${CONDA_DIR}"
