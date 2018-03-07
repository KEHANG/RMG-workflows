#!/bin/bash
set -e

# parse arguments
RMGPY_BRANCH=$1
RMGDB_BRANCH=$2
THIS_WF_DIR=$3

# prepare RMG-Py
echo ""
cd $THIS_WF_DIR
git clone https://github.com/ReactionMechanismGenerator/RMG-Py.git

cd RMG-Py
if [ $RMGPY_BRANCH != "master" ]; then
  git checkout -b ${RMGPY_BRANCH} origin/${RMGPY_BRANCH}
fi
rmgpy_sha=$(git rev-parse HEAD)

# prepare RMG-database
echo ""
cd $THIS_WF_DIR
git clone https://github.com/ReactionMechanismGenerator/RMG-database.git

cd RMG-database
if [ $RMGDB_BRANCH != "master" ]; then
  git checkout -b ${RMGDB_BRANCH} origin/${RMGDB_BRANCH}
fi
rmgdb_sha=$(git rev-parse HEAD)

# dump RMG-Py and RMG-database metadata
# for recording
cd ${THIS_WF_DIR}
branch_meta="{rmgpy_branch:${RMGPY_BRANCH},"
branch_meta="${branch_meta} rmgpy_sha:${rmgpy_sha},"
branch_meta="${branch_meta} rmgdb_branch:${RMGDB_BRANCH},"
branch_meta="${branch_meta} rmgdb_sha:${rmgdb_sha}}"
echo ${branch_meta} >> branch_meta.json

# figure out OS, prepare conda environment
echo ""
cd $THIS_WF_DIR/RMG-Py

if [[ $MACHTYPE == *"apple"* ]]; then
	export CURRENT_OS="mac"
elif [[ $MACHTYPE == *"linux"* ]]; then
	export CURRENT_OS="linux"
else
	echo "$MACHTYPE not supported. Exiting..."
	exit 0
fi
echo "Current OS: "$CURRENT_OS

export cnn_wf_env='cnn_wf_env_'${rmgpy_sha:0:8}'_'${rmgdb_sha:0:8}
env_existed=(`conda info --envs | grep ${cnn_wf_env} | wc -l`)
if [ $env_existed == "0" ]; then
	sed -i -e "s/rmg_env/${cnn_wf_env}/g" environment_${CURRENT_OS}.yml
	conda env create -f environment_${CURRENT_OS}.yml
	git checkout environment_${CURRENT_OS}.yml
else
	echo "conda env exists: ${cnn_wf_env}; Skip creating it again..."
fi

# compile RMG-Py
echo ""
source activate ${cnn_wf_env}
make
source deactivate



