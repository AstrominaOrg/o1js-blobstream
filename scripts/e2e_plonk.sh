#!/bin/bash

# exit if any of scripts exit
set -e 

args=("$@")
ENV=$(realpath ${args[0]})
source ${ENV}
SCRIPT_DIR=$(dirname -- $(realpath $0)) 
cd $SCRIPT_DIR/..

pushd ./contracts

node_version=$(node -v)
node_version=${node_version:1}
node_version=${node_version%\.*}
node_version=${node_version%\.*}
node_version=$(($node_version))
if [ $node_version -lt 22 ]
then
  echo "Node version is too low - $node_version. Please upgrade to NodeJS 22 or higher."
  exit 1
fi

npm install
npm run build

popd

WORK_DIR_RELATIVE_TO_SCRIPTS="./scripts/${WORK_DIR}"
mkdir -p ${WORK_DIR_RELATIVE_TO_SCRIPTS}

CACHE_DIR_RELATIVE_TO_SCRIPTS="./scripts/${CACHE_DIR}"
mkdir -p ${CACHE_DIR_RELATIVE_TO_SCRIPTS}

# get aux pairing witness 
./scripts/get_aux_witness_plonk.sh ${ENV}

# test e2e proof 
./scripts/plonk_tree.sh ${ENV}