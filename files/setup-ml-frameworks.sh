#!/bin/bash
set -e

if [ "$(uname -m)" != "aarch64" ]; then
  mamba install --quiet --yes \
    numpyro
fi

