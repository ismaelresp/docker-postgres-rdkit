#! /bin/bash -i

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

# apt-get install -yq --no-install-recommends postgresql-$PG_MAJOR

# REMOVE ALL CONTENTS IN $RDBASE
rm -r "$RDBASE"
# DOWNLOAD RDKIT
wget --quiet https://github.com/rdkit/rdkit/archive/refs/tags/${RDKIT_VERSION}.tar.gz \
 && tar -xzf ${RDKIT_VERSION}.tar.gz \
 && mv rdkit-${RDKIT_VERSION} "$RDBASE" \
 && rm ${RDKIT_VERSION}.tar.gz


conda activate
conda create -y -c conda-forge --name rdkit_built_dep --file requeriments_conda_rdkit_build.txt
# conda create -y --name rdkit_built_dep 
# conda activate rdkit_built_dep;conda install -y -c conda-forge numpy matplotlib catch2 pytest; \
# conda install -y -c conda-forge cmake cairo pillow eigen pkg-config; \
# conda install -y -c conda-forge boost-cpp boost py-boost pandas; \
# conda install -y -c conda-forge gxx_linux-64;
conda activate rdkit_built_dep
pip install yapf==0.11.1
pip install coverage==3.7.1

# BUILDING RDKIT
mkdir "$RDBASE"/build
pushd "$RDBASE"/build
conda activate rdkit_built_dep;cmake -DPy_ENABLE_SHARED=1 \
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

make  -j $(nproc)

# INSTALLING RDKIT IN $RDBASE AND POSTGRESQL RDKIT EXTENSION IN POSTGRESQL LIB
make install
mkdir -p "$PG_ETC_MAIN_PATH"
echo "LD_LIBRARY_PATH = '$RDBASE/lib:$CONDA_PREFIX/lib'" | tee -a "$PG_ETC_MAIN_PATH"/environment

popd
