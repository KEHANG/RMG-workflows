#!/bin/bash
#SBATCH -p debug
#SBATCH -J Cp
#SBATCH -n 1
#SBATCH --nodelist=node08

# parse arguments
RMG_WS=${1}
cnn_wf_env=${2}
THIS_WF_DIR=${3}
TASK_DIR=${4}

# for training
INPUT='predictor_input.py'
DATA_FILE='datasets.txt'
TRAIN_MODE='full_train'
BATCH_SIZE=1
NB_EPOCH=150
PATIENCE=10

# for testing
CNN_MODEL='./'
TEST_DATA_FILE='test_datasets.txt'

export PYTHONPATH=$RMG_WS:$PYTHONPATH
source activate ${cnn_wf_env}
export KERAS_BACKEND=theano
python $RMG_WS/scripts/train_cnn.py -i $INPUT -d ${DATA_FILE} -t ${TRAIN_MODE} -bs ${BATCH_SIZE} -ep ${NB_EPOCH} -pc ${PATIENCE}
python $RMG_WS/scripts/evaluate_cnn.py -d ${TEST_DATA_FILE} -m ${CNN_MODEL}
python ../../../../scripts/pusher.py -wfd ${THIS_WF_DIR} -td ${TASK_DIR}
source deactivate
