#!/bin/bash
#SBATCH -p debug
#SBATCH -J cnn_wf
#SBATCH -n 1

rmgpy_branch="cnn_framework_concise2"
rmgdb_branch="master"
base_data_dir='base_data'

bash main.sh $rmgpy_branch $rmgdb_branch $base_data_dir