#! /bin/bash
source config.sh

# # POSTGRES TEST RUN
# # Distro default DAEMON:
# service postgresql start
# # TERMINAL (for testing in a machine with no postgres DB initialized):
# TESTING_DB_PATH="/var/lib/rdkit-cartridge-testing/postgresql/data/"
# POSTGRES_SUPERUSER=postgres
# PG_MAJOR=10
# RDBASE=/rdkit
# CONDA_INSTALL_DIR='/opt/conda'
# CONDA_PREFIX=$CONDA_INSTALL_DIR/envs/rdkit_built_dep
# mkdir -p "$TESTING_DB_PATH"
# chown $POSTGRES_SUPERUSER "$TESTING_DB_PATH"
# su $POSTGRES_SUPERUSER -l -c "export PATH='$PATH:/usr/lib/postgresql/$PG_MAJOR/bin'; initdb  -D '$TESTING_DB_PATH'"
# su $POSTGRES_SUPERUSER -l -c "export PATH='$PATH:/usr/lib/postgresql/$PG_MAJOR/bin'; export LD_LIBRARY_PATH='$RDBASE/lib:$CONDA_PREFIX/lib'; postgres -D '$TESTING_DB_PATH';"

su $POSTGRES_SUPERUSER -l -c "psql -c 'CREATE EXTENSION IF NOT EXISTS rdkit'"