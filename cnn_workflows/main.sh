
# parse arguments
export RMGPY_BRANCH=$1
export RMGDB_BRANCH=$2
export BASE_DIR="$( cd "$( dirname "$3" )/" && pwd )"
export BASE_DATA_DIR=${BASE_DIR}/$(basename $3)

# prepare dir for this job
THIS_WF_DIR=$BASE_DATA_DIR/$(date +%Y-%m-%d_%H-%M-%S)
rm -rf $THIS_WF_DIR
mkdir -p $THIS_WF_DIR
echo "This workflow locates at: "$THIS_WF_DIR
echo "RMG-Py Branch: "$RMGPY_BRANCH
echo "RMG-database Branch: "$RMGDB_BRANCH

# execute workflow
. install.sh $RMGPY_BRANCH $RMGDB_BRANCH $THIS_WF_DIR

# copy task specs and run tasks
cd $BASE_DIR
cp -r tasks $THIS_WF_DIR
. $BASE_DIR/run_task.sh Cp $THIS_WF_DIR
. $BASE_DIR/run_task.sh Hf298 $THIS_WF_DIR
. $BASE_DIR/run_task.sh S298 $THIS_WF_DIR

## TODO
## after all the jobs done
## should remove the environments