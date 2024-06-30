#! /bin/bash -i

#Adjust postgresql major version
export PG_MAJOR=10
#Adjust path to 'bin' postgresql binaries folder
PG_BIN_PATH="/usr/lib/postgresql/$PG_MAJOR/bin" # default path for postgres-10 installed from official ubuntu-bionic repository Ubuntu 18.04.5 LTS
#Adjust path to 'etc' 'main' postgresql configuration folder
PG_ETC_MAIN_PATH="/etc/postgresql/$PG_MAJOR/main" # default path for postgres-10 installed from official ubuntu-bionic repository Ubuntu 18.04.5 LTS
#CONDA installation folder
CONDA_INSTALL_DIR='/opt/conda'
#Adjust PATH environment variable 
export PATH="$CONDA_INSTALL_DIR"/bin:"$PG_BIN_PATH":$PATH
#RDKIT VERSION for the postgresql cartridge. It does not have to match the one installed together with django.
RDKIT_VERSION=Release_2024_03_3
#RDKIT source, build, and instalation folder
RDBASE=/rdkit

# TESTING PARMETERS
# Requires postgresql peer authentication enabled. Add the following line uncommented to pg_hba.conf:
# local  all      all          peer

#A postgres superuser that must be also a OS user with the same name. Required for testing RDKIT build. It will be automatically created if it does not exists.
#For postgresql 15+ it might work with partial priviledged user. Not tested.
POSTGRES_USER=rdkit-test

#A postgres superuser that must be also a OS user with the same name.
POSTGRES_SUPERUSER=postgres