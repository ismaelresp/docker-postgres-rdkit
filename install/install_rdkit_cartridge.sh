#! /bin/bash -i

source config.sh

apt-get update
apt-get install -yq --no-install-recommends \
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


# DOWNLOAD RDKIT
if [ -d ${RDKIT_VERSION}.tar.gz ]; then
  echo "${RDKIT_VERSION}.tar.gz is a directory. Cannot download and save RDKit release tar.gz file. Please, rename or move such directory. Aborting..."
  exit 1
elif [ -f ${RDKIT_VERSION}.tar.gz ]; then
  echo "Skipping download of ${RDKIT_VERSION}.tar.gz. File already exists. Using already present './${RDKIT_VERSION}.tar.gz' as RDKit release tar.gz file."
else
  wget --quiet https://github.com/rdkit/rdkit/archive/refs/tags/${RDKIT_VERSION}.tar.gz
fi

if [ ! -f ${RDKIT_VERSION}.tar.gz ]; then
  echo "Cannot download ${RDKIT_VERSION}.tar.gz. Please, try to run the script later or download from https://github.com/rdkit/rdkit/archive/refs/tags/${RDKIT_VERSION}.tar.gz or from the official RDKit source code repository and save the file as '${RDKIT_VERSION}.tar.gz' in the current working directory. Aborting..."
  exit 1
fi

# REMOVE ALL CONTENTS IN $RDBASE
rm -r "$RDBASE"

# REMOVE ALL CONTENTS IN rdkit-${RDKIT_VERSION}
rm -r rdkit-${RDKIT_VERSION}

# UNTAR RDKIT
tar -xzf ${RDKIT_VERSION}.tar.gz
mv rdkit-${RDKIT_VERSION} "$RDBASE"
if [ ! -d "$RDBASE" ]; then
  echo "Cannot untar ${RDKIT_VERSION}.tar.gz in the working directory or cannot move its contents to '$RDBASE'. Aborting..."
  exit 1
fi


conda activate

# source: https://www.rdkit.org/docs/Install.html
# CREATE ENVIRONMENT ONLY WITH FROZEN VERSIONS OF PACKAGES AND LIBRARIES
conda create -y -c conda-forge --name rdkit_built_dep --file requeriments_conda_rdkit_build.txt
# # USE LATESTS PACKAGES AND LIBRARIES INSTEAD (might only work with latest RDKit release)
# # conda create -y --name rdkit_built_dep 
# # conda activate rdkit_built_dep;conda install -y -c conda-forge numpy matplotlib catch2 pytest; \
# # conda install -y -c conda-forge cmake cairo pillow eigen pkg-config; \
# # conda install -y -c conda-forge boost-cpp boost py-boost pandas; \
# # conda install -y -c conda-forge gxx_linux-64;

conda activate rdkit_built_dep
pip install yapf==0.11.1
pip install coverage==3.7.1

# BUILDING RDKIT

# source: https://www.rdkit.org/docs/Install.html
# source: https://github.com/rdkit/rdkit/blob/master/Code/PgSQL/rdkit/README.md

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

make  -j $ncpu

# INSTALLING RDKIT IN $RDBASE AND POSTGRESQL RDKIT EXTENSION IN POSTGRESQL LIB
make install && rm ${RDKIT_VERSION}.tar.gz
mkdir -p "$PG_ETC_MAIN_PATH"

# %ENV in perl: the hash %ENV contains your current environment. Setting a value in ENV changes the environment for 
# any child processes you subsequently fork() off.
# source: https://perldoc.perl.org/variables/%25ENV
# from 'pg_ctlcluster'. It is a perl script:
# # prepare environment (empty except for content of 'environment', and LANG)
# %ENV = read_cluster_conf_file $version, $cluster, 'environment'; # read_cluster_conf_file: Reads a config file in a cluster folder.
#                                                                  # Defined in 'PgCommon.pm'. $version is the PostgreSQL major version.
#                                                                  # $cluster is name of the cluster. 'main' by default.
#                                                                  # 'environment' is a file with a PostgreSQL config file format. 
# [...]
#  exec $pg_ctl @options or error "could not exec $pg_ctl @options: $!"; # $pg_ctl value is the path to the specific cluster pg_ctl.
#                                                                        # pg_ctl and its child processes inherit the enviroment in %ENV.
#
# 'pg_ctlcluster' expects cluster folders to be in the path in the environment variable PG_CLUSTER_CONF_ROOT.
# If PG_CLUSTER_CONF_ROOT is not set, it defaults to '/etc/postgresql', as set in the perl package file 'PgCommon.pm'.
# Paths to cluster folders must follow the following path: "$PG_CLUSTER_CONF_ROOT/$version/$cluster/"
# systemd and SysV init.d scripts start PostgreSQL running the 'pg_ctlcluster $version $cluster start'
# or 'pg_ctlcluster ${version}-${cluster start}'command for running the perl script with the filename 'pg_ctlcluster'.

echo "LD_LIBRARY_PATH = '$RDBASE/lib:$CONDA_PREFIX/lib'" | tee -a "$PG_ETC_MAIN_PATH"/environment

popd
