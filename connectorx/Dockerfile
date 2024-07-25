FROM arm64v8/ubuntu:22.04

# Installing devel dependencies
RUN apt-get update
RUN apt-get install -y \
    libmysqlclient-dev \
    freetds-dev \
    libpq-dev \
    wget \
    curl \
    build-essential \
    libkrb5-dev \
    clang \
    git

# Creating and changing to a new directory
RUN mkdir /wheeler
WORKDIR /wheeler

# Installing and setting up rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="$PATH:/root/.cargo/bin"

# Installing just through cargo
RUN cargo install just

# Installing python3.11.7 from source
RUN wget https://www.python.org/ftp/python/3.11.7/Python-3.11.7.tgz
RUN tar -xvf Python-3.11.7.tgz
RUN cd Python-3.11.7 && ./configure --enable-optimizations
RUN cd Python-3.11.7 && make install
RUN pip3.11 install poetry

# Cloning the connectorx repo and switching to the 0.3.1 tag
RUN git clone https://github.com/sfu-db/connector-x.git
WORKDIR /wheeler/connector-x
RUN git checkout tags/v0.3.3

# Installing maturin
RUN pip3.11 install maturin[patchelf]==0.14.15

# Building the python wheel through maturin
RUN maturin build -m connectorx-python/Cargo.toml -i python3.11 --release

# Copying the wheel into the host system
# the below didn't work for me
# COPY /wheeler/connector-x/connectorx-python/target/wheels/connectorx-* .

# use the below to access the wheel in /wheeler/connector-x/connectorx-python/target/wheels/
# docker run -it -v ./:/root your_user_name/connectorx /bin/bash

# then navigate to the directory below and copy the wheel to the home directory
# which is mounted to your current directory on your host OS
# /wheeler/connector-x/connectorx-python/target/wheel