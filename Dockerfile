# Use an appropriate base image with CUDA and Python
FROM nvidia/cuda:11.6.2-base-ubuntu20.04

# Install python 3.10 and required dependencies
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3.10 python3.10-dev python3.10-distutils

RUN apt-get install openssh-client git  -y
Run apt-get install -y curl

# Make python3.10 the default python
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Add the remote public key inside the known hosts of the container
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# Install pip for python3.10
RUN apt-get install -y python3.10-distutils
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3.10 get-pip.py && \
    rm get-pip.py

# Install CUDA toolkit and cudnn if necessary
# Add instructions here depending on your CUDA version requirements

# Set environment variables
ENV CUDA_HOME=/usr/local/cuda \
    LD_LIBRARY_PATH=/usr/local/cuda/lib64 \
    PATH=/usr/local/cuda/bin:${PATH}

# Copy the requirements file
COPY requirements.txt /

# Install packages from requirements.in
RUN --mount=type=ssh pip install -r /requirements.txt

