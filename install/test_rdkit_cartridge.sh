#! /bin/bash -i

source config.sh

# TEST RDKIT BUILD AND INSTALLATION

pushd "$RDBASE/build"
conda activate rdkit_built_dep

export RDBASE="$RDBASE"
export PYTHONPATH="$RDBASE"
export LD_LIBRARY_PATH="$RDBASE/lib:$LD_LIBRARY_PATH"

ctest "$@"

popd
