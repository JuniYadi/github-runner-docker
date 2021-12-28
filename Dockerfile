# base
FROM ubuntu:20.04

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

# set the github runner version
# see https://github.com/actions/runner/releases
ARG RUNNER_VERSION="2.286.0"

# Update LANG
RUN echo en_US.UTF-8 UTF-8 >> /etc/locale.gen

# update the base packages and add a non-sudo user
RUN apt-get update -y && apt-get upgrade -y && useradd -m docker

# install python and the packages the your code depends on along with jq so we can parse JSON
# add additional packages as necessary
RUN apt-get install -y --no-install-recommends \
    apt-transport-https \
    build-essential \
    ca-certificates \
    curl \
    dirmngr \
    dumb-init \
    gettext \
    gnupg \
    gpg-agent \
    inetutils-ping \
    jq \
    libcurl4-openssl-dev \
    libffi-dev \
    liblttng-ust0 \
    libssl-dev \
    locales \
    lsb-release \
    openssh-client \
    python \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    software-properties-common \
    sudo \
    tar \
    unzip \
    wget \
    zlib1g-dev \
    zstd

# install aws cli from pip
RUN pip3 install awscli --upgrade

# setup repo docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# install docker
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
    docker-ce \
    docker-ce-cli \
    containerd.io && \
    usermod -aG docker docker && \
    chmod -x /var/run/docker.sock

# install docker-compose
RUN  curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# cd into the user directory, download and unzip the github actions runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# install some additional dependencies
RUN chown -R docker ~docker && \
    /home/docker/actions-runner/bin/installdependencies.sh

# copy over the start.sh script
COPY start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# clean up
RUN rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]