
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd )"

cd ${BASE_DIR}
echo $(date +%Y-%m-%d:%H:%M:%S) "Nightly Build for CNN"
sbatch submit.sl