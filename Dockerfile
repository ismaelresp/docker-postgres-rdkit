# Requires 16 GB of RAM for building RDKIT with 14 CPUs, but it depends on the number of CPUs used for the build. 
# You'll probably need to change your docker settings to increase the maximum RAM the containers
# are able to use.

FROM postgres:16

ENV PG_MAJOR 16
ENV PATH=/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/postgresql/$PG_MAJOR/bin

RUN  apt-get update \
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
    postgresql-server-dev-all  \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /

# DOWNLOAD AND INSTALL CONDA
# source: https://github.com/ContinuumIO/docker-images/blob/main/miniconda3/debian/Dockerfile

# Leave these args here to better use the Docker build cache
# renovate: datasource=custom.miniconda_installer
ARG INSTALLER_URL_LINUX64="https://repo.anaconda.com/miniconda/Miniconda3-py312_24.4.0-0-Linux-x86_64.sh"
ARG SHA256SUM_LINUX64="b6597785e6b071f1ca69cf7be6d0161015b96340b9a9e132215d5713408c3a7c"
# renovate: datasource=custom.miniconda_installer
ARG INSTALLER_URL_S390X="https://repo.anaconda.com/miniconda/Miniconda3-py312_24.4.0-0-Linux-s390x.sh"
ARG SHA256SUM_S390X="e973f1b6352d58b1ab35f30424f1565d7ffa469dcde2d52c86ec1c117db11aad"
# renovate: datasource=custom.miniconda_installer
ARG INSTALLER_URL_AARCH64="https://repo.anaconda.com/miniconda/Miniconda3-py312_24.4.0-0-Linux-aarch64.sh"
ARG SHA256SUM_AARCH64="832d48e11e444c1a25f320fccdd0f0fabefec63c1cd801e606836e1c9c76ad51"

RUN set -x && \
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
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh shasum && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy

# use a bash shell with login so it keeps conda activation and environment across RUN instructions
SHELL ["/bin/bash", "--login", "-c"] 

# For downloading older versions of RDKIT 
# RUN rm -fr rdkit
# ARG RDKIT_VERSION=Release_2020_09_1
# RUN wget --quiet https://github.com/rdkit/rdkit/archive/${RDKIT_VERSION}.tar.gz \
#  && tar -xzf ${RDKIT_VERSION}.tar.gz \
#  && mv rdkit-${RDKIT_VERSION} rdkit2 \
#  && rm ${RDKIT_VERSION}.tar.gz

# DOWNLOAD RDKIT
RUN rm -fr rdkit
ARG RDKIT_VERSION=Release_2024_03_3
RUN wget --quiet https://github.com/rdkit/rdkit/archive/refs/tags/${RDKIT_VERSION}.tar.gz \
 && tar -xzf ${RDKIT_VERSION}.tar.gz \
 && mv rdkit-${RDKIT_VERSION} rdkit \
 && rm ${RDKIT_VERSION}.tar.gz

# CREATE CONDA RDKIT BUILD ENVIRONMENT
ADD requeriments_conda_rdkit_build.txt .
# RUN conda create -y -c conda-forge --name rdkit_built_dep --file requeriments_conda_rdkit_build.txt
RUN conda create -y --name rdkit_built_dep 
RUN conda activate rdkit_built_dep;conda install -y -c conda-forge numpy matplotlib catch2 pytest; \
conda install -y -c conda-forge cmake cairo pillow eigen pkg-config; \
conda install -y -c conda-forge boost-cpp boost py-boost pandas; \
conda install -y -c conda-forge gxx_linux-64;
RUN pip install yapf==0.11.1
RUN pip install coverage==3.7.1

# BUILD RDKIT
RUN mkdir /rdkit/build
WORKDIR /rdkit/build
RUN conda activate rdkit_built_dep;cmake -DPy_ENABLE_SHARED=1 \
  -DRDK_INSTALL_INTREE=ON \
  -DRDK_INSTALL_STATIC_LIBS=OFF \
  -DRDK_BUILD_CPP_TESTS=ON \
  -DPYTHON_NUMPY_INCLUDE_PATH="$(python -c 'import numpy ; print(numpy.get_include())')" \
  -DBOOST_ROOT="$CONDA_PREFIX" \
  -DBoost_NO_BOOST_CMAKE=OFF \
  -DBoost_NO_SYSTEM_PATHS=OFF \
  -DRDK_BUILD_AVALON_SUPPORT=ON \
  -DRDK_BUILD_CAIRO_SUPPORT=ON \
  -DRDK_BUILD_INCHI_SUPPORT=ON \
  -D RDK_BUILD_PGSQL=ON \
  -D PostgreSQL_CONFIG_DIR=/usr/lib/postgresql/$PG_MAJOR/bin \
  -D PostgreSQL_INCLUDE_DIR="/usr/include/postgresql" \
  -D PostgreSQL_TYPE_INCLUDE_DIR="/usr/include/postgresql/$PG_MAJOR/server" \
  -D PostgreSQL_LIBRARY="/usr/lib/x86_64-linux-gnu/libpq.so.5" \
  ..

RUN make  -j $(nproc)
# INSTALL RDKIT
RUN make install
RUN mkdir -p /etc/postgresql/$PG_MAJOR/main/
RUN echo "LD_LIBRARY_PATH = '/rdkit/lib:$CONDA_PREFIX/lib'" | tee -a /etc/postgresql/$PG_MAJOR/main/environment

# PREPARE RDKIT TESTING
# # RUN chown postgres /rdkit/build/Code/PgSQL/rdkit/regression*
# # RUN chown postgres /rdkit/build/Code/PgSQL/rdkit/results
# RUN chown postgres /rdkit/build/Testing/Temporary/
# # RUN chgrp postgres /rdkit/build/Code/RDGeneral; chmod g+w /rdkit/build/Code/RDGeneral
# RUN touch /rdkit/build/Code/RDGeneral/error_log.txt; chown postgres /rdkit/build/Code/RDGeneral/error_log.txt
# RUN chgrp postgres /rdkit/Code/ForceField/MMFF/test_data/; chmod g+w /rdkit/Code/ForceField/MMFF/test_data/
# RUN chgrp postgres /rdkit/Code/GraphMol/FileParsers/test_data/; chmod g+w /rdkit/Code/GraphMol/FileParsers/test_data/
# RUN chgrp postgres /rdkit/Code/GraphMol/Depictor/test_data/; chmod g+w /rdkit/Code/GraphMol/Depictor/test_data/
# # RUN chgrp postgres /rdkit/build/Code/GraphMol/Depictor; chmod g+w /rdkit/build/Code/GraphMol/Depictor
# RUN touch /rdkit/build/Code/GraphMol/Depictor/junk.mol; chown postgres /rdkit/build/Code/GraphMol/Depictor/junk.mol
# RUN chgrp postgres /rdkit/Code/GraphMol/FileParsers/; chmod g+w /rdkit/Code/GraphMol/FileParsers/

WORKDIR /rdkit
RUN find . -type d -exec chgrp postgres {} +
RUN find . -type d -exec chmod g+w {} +
WORKDIR /rdkit/build

# POSTGRES SERVER CONFIGURATION
ADD postgresql.conf /
RUN cp /postgresql.conf /var/lib/postgresql/data/postgresql.conf

# SETUP POSTGRES FOR TESTING
RUN su postgres -l -c 'conda init'
ENV POSTGRES_USER=protwis
STOPSIGNAL SIGINT
CMD useradd -m -s /bin/bash $POSTGRES_USER; su postgres -l -c 'conda activate rdkit_built_dep;\
  export PATH="$PATH:/usr/lib/postgresql/'$PG_MAJOR'/bin"; export LD_LIBRARY_PATH="/rdkit/lib:$CONDA_PREFIX/lib"; \
  postgres -D '"$PGDATA"



# # TEST RDKIT BUILD AND INSTALLATION
# /bin/bash
# su $POSTGRES_USER -l -c 'createuser -sE postgres'
# su postgres

# cd /rdkit/build
# conda activate rdkit_built_dep

# export RDBASE=$PWD/..
# export PYTHONPATH=$RDBASE
# export LD_LIBRARY_PATH=$RDBASE/lib:$LD_LIBRARY_PATH

# psql -c 'create extension rdkit'
# ctest

# For runing the image use:
# docker run --network gpcrdb -d --platform linux/amd64 --name postgres16-rdkit2024_03_3 \
# -v postgres_data:/var/lib/postgresql/data \
# -e POSTGRES_USER=protwis \
# -e POSTGRES_PASSWORD=protwis \
# -p 5432:5432 \
# postgres16-rdkit2024_03_3
