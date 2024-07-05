#! /bin/bash

source config.sh

apt-get update \
&& apt-get install -yq --no-install-recommends \
    ca-certificates \
    build-essential \
    wget \
    git \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    mercurial \
    openssh-client \
    procps \
    subversion \
    bzip2 \
    postgresql-server-dev-$PG_MAJOR \
    postgresql-server-dev-all

# DOWNLOAD AND INSTALL CONDA
# source: https://github.com/ContinuumIO/docker-images/blob/main/miniconda3/debian/Dockerfile

# Leave these args here to better use the Docker build cache
# renovate: datasource=custom.miniconda_installer
INSTALLER_URL_LINUX64="https://repo.anaconda.com/miniconda/Miniconda3-py312_24.4.0-0-Linux-x86_64.sh"
SHA256SUM_LINUX64="b6597785e6b071f1ca69cf7be6d0161015b96340b9a9e132215d5713408c3a7c"
# renovate: datasource=custom.miniconda_installer
INSTALLER_URL_S390X="https://repo.anaconda.com/miniconda/Miniconda3-py312_24.4.0-0-Linux-s390x.sh"
SHA256SUM_S390X="e973f1b6352d58b1ab35f30424f1565d7ffa469dcde2d52c86ec1c117db11aad"
# renovate: datasource=custom.miniconda_installer
INSTALLER_URL_AARCH64="https://repo.anaconda.com/miniconda/Miniconda3-py312_24.4.0-0-Linux-aarch64.sh"
SHA256SUM_AARCH64="832d48e11e444c1a25f320fccdd0f0fabefec63c1cd801e606836e1c9c76ad51"

if [ -e ~/.bashrc.rdkit_cartridge_bkp ]; then
    mv ~/.bashrc.rdkit_cartridge_bkp ~/.bashrc.rdkit_cartridge_bkp_$(date +"%Y%m%d%H%M%S%3N")
fi

cp ~/.bashrc ~/.bashrc.rdkit_cartridge_bkp

set -x && \
    UNAME_M="$(uname -m)" && \
    if [ "${UNAME_M}" = "x86_64" ]; then \
        INSTALLER_URL="${INSTALLER_URL_LINUX64}"; \
        SHA256SUM="${SHA256SUM_LINUX64}"; \
    elif [ "${UNAME_M}" = "s390x" ]; then \
        INSTALLER_URL="${INSTALLER_URL_S390X}"; \
        SHA256SUM="${SHA256SUM_S390X}"; \
    elif [ "${UNAME_M}" = "aarch64" ]; then \
        INSTALLER_URL="${INSTALLER_URL_AARCH64}"; \
        SHA256SUM="${SHA256SUM_AARCH64}"; \
    fi && \
    wget "${INSTALLER_URL}" -O miniconda.sh -q && \
    echo "${SHA256SUM} miniconda.sh" > shasum && \
    sha256sum --check --status shasum && \
    mkdir -p /opt && \
    bash miniconda.sh -b -p "$CONDA_INSTALL_DIR" && \
    rm miniconda.sh shasum && \
    echo ". "$CONDA_INSTALL_DIR"/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find "$CONDA_INSTALL_DIR"/ -follow -type f -name '*.a' -delete && \
    find "$CONDA_INSTALL_DIR"/ -follow -type f -name '*.js.map' -delete && \
    "$CONDA_INSTALL_DIR"/bin/conda clean -afy
    conda init

    # ln -s "$CONDA_INSTALL_DIR"/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \