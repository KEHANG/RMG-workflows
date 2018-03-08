
# parse arguments
TASK=$1
THIS_WF_DIR=$2
TASK_DIR=${THIS_WF_DIR}/tasks/$TASK

# run task
cd ${TASK_DIR}
export RMG_WS=${THIS_WF_DIR}/RMG-Py
sbatch submit_task.sl ${RMG_WS} ${cnn_wf_env} ${THIS_WF_DIR} ${TASK_DIR}

