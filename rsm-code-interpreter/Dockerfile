# Use an official Python runtime as a parent image
FROM python:3.8-slim-buster

# Set the working directory in the container
WORKDIR /usr/src/app

# Add metadata to the image to describe which port the container is listening on at runtime
EXPOSE 8888

RUN apt-get update && apt-get install -y \
  gcc \
  g++ \
  python3-dev \
  libfreetype6-dev \
  pkg-config \
  make \
  libgdal-dev \
  libcairo2-dev \
  portaudio19-dev \
  libgirepository1.0-dev \
  distro-info \
  libboost-all-dev \
  cmake \
  libdbus-1-dev \
  python-apt \
  unattended-upgrades \
  graphviz \
  libgraphviz-dev

# Set GDAL environment variable
ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal

# Install any needed packages specified in requirements.txt
COPY rsm-code-interpreter/requirements-full.txt ./requirements.txt
RUN pip install --no-cache-dir -r ./requirements.txt

NOW ADD textract after cloning and fixing the requirements file

# Run app.py when the container launches
CMD ["jupyter", "lab", "--ip='*'", "--port=8888", "--no-browser", "--allow-root"]
