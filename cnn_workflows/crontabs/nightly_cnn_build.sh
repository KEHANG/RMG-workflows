#########################################
# Add conda path to PATH (user specific)#
#########################################
# export PATH=/your/conda/bin:$PATH

####################################
# Add other necessary path to PATH #
# (e.g., slave node's sbatch)      #
####################################

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd )"

cd ${BASE_DIR}
echo $(date +%Y-%m-%d:%H:%M:%S) "Nightly Build for CNN"
sbatch submit.sl