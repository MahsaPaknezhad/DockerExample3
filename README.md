# Example of Creating a Docker Container using Pip-tools

This example shows:
* How to create a docker container using pip-tools
* How to clone and install a private GitHub repository using a SSH key in the container. 
* How to upgrade your pip-tools to be able to install packages with versions specified in the requirements.txt file. 

# Instructions

Add the private GitHub repository that you aim to clone and install in your conda venv to the ```requirements.txt``` file as shown below:
```
git+ssh://git@github.com/private_project.git@main
```
To install the SSH client and Git, add the following code to your Dockerfile:
```
# Install SSH client and Git
RUN apt-get update && \
    apt-get install -y \
    openssh-client \
    git \
    && rm -rf /var/lib/apt/lists/*
```

To install python3.10 and update the pip-tools:
```
# Install python 3.10 and required dependencies
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3.10 python3.10-dev python3.10-distutils

# Install pip for python3.10
RUN apt-get install -y python3.10-distutils
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3.10 get-pip.py && \
    rm get-pip.py
```

To clone a private repository in your ```requirements.txt``` file you will need to use a SSH key. First, in your Dockerfile add the remote public key inside the known hosts of the container. Otherwise, asking to add the ssh key to known hosts will be prompted at the build stage and your build process will return an error.
```
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts
```

In your Dockerfile use ```mount=type=ssh``` to load the ssh key and run the installation:

```
# Install packages from requirements.txt
RUN --mount=type=ssh pip install -r /requirements.txt
```

The --ssh command is only available with DOCKER_BUILDKIT so, declare it as an environment variable before building, then it is forwarded to the container.

```
export DOCKER_BUILDKIT=1
```

Build the Docker Image by running the following command:
```
docker build --ssh default=$HOME/.ssh/id_rsa -t model_trainer .
```

