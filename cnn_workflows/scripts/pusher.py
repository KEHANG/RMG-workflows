
# this module is designed to
# push performance result data
# as well as other crucial
# metadata to performance database

# s1a: get branch meta data
# s1b: get predictor, training/test
#	   datasets data
# s1c: get evaluation data
# s2:  compile into one record, add
#	   timestamp and date
# s3:  connect to performance db
# s4:  select right table and insert
#      the record
import os
import json
import time
import datetime
import argparse

import connector

def parse_arguments():
	"""
	Parse the command-line arguments. This uses the
	:mod:`argparse` module, which ensures that the command-line arguments are
	sensible, parses them, and returns them.
	"""

	parser = argparse.ArgumentParser()
	parser.add_argument('-wfd', '--workflow_dir', type=str, 
						help='directory of the current workflow')

	parser.add_argument('-td', '--task_dir', type=str, 
						help='directory of the current task of the workflow')

	return parser.parse_args()

def convert_predictor_input_to_json(input_file):

	input_file_str = ""
	with open(input_file, 'r') as f_in:
		for line in f_in:
			line_stripped = line.strip()
			if line_stripped.startswith('#'):
				continue
			input_file_str += line_stripped

	# remove header and tail
	input_file_str = input_file_str.replace("predictor_model(", "")
	input_file_str = input_file_str.replace(")", "")

	# correct quotes and booleans
	input_file_str = input_file_str.replace("'", '"')
	input_file_str = input_file_str.replace("True", "true")
	input_file_str = input_file_str.replace("False", "false")
	
	# make keys to strings
	arguments = [arg.strip().split('=')[0] for arg in input_file_str.split(',')]
	arg_vals = [arg.strip() for arg in input_file_str.split(',')]
	updated_arg_vals = [arg_val.replace(arguments[i], '"' + arguments[i] + '"').replace("=", ":") for i, arg_val in enumerate(arg_vals)]
	
	# concatenate argument-values
	input_file_str = "{" + ", ".join(updated_arg_vals) + "}"
	
	return json.loads(input_file_str)

def convert_datasets_file_to_json(datasets_file_path, training=True):
	
	datasets = {}
	with open(datasets_file_path, 'r') as f_in:
		for line in f_in:
			line = line.strip()
			if line and not line.startswith('#'):
				if training:
					dataset, testing_ratio = [token.strip() for token in line.split(':')]
					dataset = dataset.replace('.', '/')
					datasets[dataset] = float(testing_ratio)
				else:
					dataset = line.strip()
					dataset = dataset.replace('.', '/')
					datasets[dataset] = 1.0

	return datasets

def get_task_meta_data(task_dir):
	"""
	This returns three pieces of information for the task.
	1. predictor input 
	2. training datasets
	3. test datasets
	"""
	# get predictor meta data
	input_file = os.path.join(task_dir, 'predictor_input.py')
	predictor_input_meta = convert_predictor_input_to_json(input_file)

	# get training datasets
	training_datasets_file = os.path.join(task_dir, 'datasets.txt')
	training_datasets = convert_datasets_file_to_json(training_datasets_file, True)

	# get test datasets
	test_datasets_file = os.path.join(task_dir, 'test_datasets.txt')
	test_datasets = convert_datasets_file_to_json(test_datasets_file, False)

	# compile into task meta data
	task_meta = {}
	task_meta.update({"predictor_input":predictor_input_meta})
	task_meta.update({"training_datasets":training_datasets})
	task_meta.update({"test_datasets":test_datasets})

	return task_meta

def run():
	
	# parse arguments
	args = parse_arguments()
	workflow_dir = args.workflow_dir
	task_dir = args.task_dir

	# get branch meta data
	branch_meta_file = os.path.join(workflow_dir, 'branch_meta.json')
	with open(branch_meta_file, 'r') as f_in:
		branch_meta = json.load(f_in)

	# get predictor, training/test
	# datasets data
	task_meta = get_task_meta_data(task_dir)

	# get evaluation data
	evaluation_results_file = os.path.join(task_dir, 'evaluation_results.json')
	with open(evaluation_results_file, 'r') as f_in:
		evaluation_results = json.load(f_in)

	# compile and add timestamp, date
	timestamp = time.time()
	record = {"timestamp": time.time(),
			  "date": datetime.datetime.now().strftime("%Y-%m-%d-%H-%M")}

	record.update(branch_meta)
	record.update(task_meta)
	record.update({"evaluation_results":evaluation_results})

	# save record to json for backup
	with open('record_to_push.json', 'w') as f_out:
		json.dump(record, f_out, indent=4, sort_keys=True)

	# connect to db and table
	performance_db =  connector.connect_to_db('PredictorPerformanceDatabase')
	task_name = task_meta['predictor_input']['prediction_task'].split('(')[0]
	performance_table = getattr(performance_db, 'cnn_{0}_table'.format(task_name))

	# insert the record
	performance_table.insert_one(record)

run()


