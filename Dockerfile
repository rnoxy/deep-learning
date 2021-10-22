FROM nvidia/cuda:11.2.2-cudnn8-runtime-ubuntu20.04
LABEL maintainer="Rafal Nowak <rnoxy>"

# Add python version
ARG python_version=3.8
# Add dl user
ARG DLUSER_UID=999
ARG DLUSER_GID=0

ENV TZ=Europe/Warsaw
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install basic packages
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && apt-get install -y --no-install-recommends \
      bzip2 \
      g++ \
      git \
      vim \
      mc \
      htop \
      sudo \
      openssh-server \
      wget \
      nodejs \
      npm && rm -rf /var/lib/apt/lists/*

# Install conda
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH
RUN mkdir $CONDA_DIR && \
    wget --quiet --no-check-certificate https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/conda.sh && \
    /bin/bash /tmp/conda.sh -f -b -p $CONDA_DIR && \
    rm /tmp/conda.sh && \
    echo export PATH=$CONDA_DIR/bin:'$PATH' > /etc/profile.d/conda.sh && \
    conda install -y python=$python_version && \
    pip install --upgrade pip

# Install requirements
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt && rm -f /tmp/requirements.txt && \
    pip cache purge && conda clean -yt

# Add `dl` user with sudo privileges
RUN groupadd -f -g ${DLUSER_GID} dl_group && \
    useradd -d /home/dl -s /bin/bash -g ${DLUSER_GID} -u ${DLUSER_UID} dl && \
    usermod -aG sudo dl && \
    echo "dl ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

WORKDIR /home/dl

RUN chown -R dl:dl_group /home/dl && \
    chmod -R a+w /home/dl

# Set up password for `dl` user
RUN echo 'root:deep-learning' | chpasswd
RUN echo 'dl:deep-learning' | chpasswd
RUN mkdir /var/run/sshd

EXPOSE 22
EXPOSE 8888

USER dl

CMD ["/usr/bin/sudo", "/usr/sbin/sshd", "-D", "-o", "ListenAddress=0.0.0.0"]