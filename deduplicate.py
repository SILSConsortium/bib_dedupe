import csv
import collections
import time
import re
import datetime
import yaml
import random
import string

from fuzzywuzzy import fuzz
from fuzzywuzzy import process

#our includes
from identify import *
from dupefu import *
from bib_weight import *
from polaris import *

parser = argparse.ArgumentParser()
g = parser.add_mutually_exclusive_group()
g.add_argument("-i", "--isbn", help="Use the ISBN dataset.",action="store_true")
g.add_argument("-u", "--upc", help="Use the UPC dataset.",action="store_true")
g.add_argument("-t", "--title", help="The agency of the user being created.",action="store_true")
g.add_argument("-s", "--sample", help="Use the sample data file in the sample_data folder",action="store_true")
args = parser.parse_args()

if args.upc:
	match_type = "upc"
elif args.title:
	match_type = "title"
elif args.sample:
	match_type = "sample"
else: 
	match_type = "isbn"

start_time = time.time()

print('loading config...')
c = yaml.load(open("config.yaml","r"))

#determine which record set and data file to use
conf = c[match_type]
record_set = conf['record_set']
data_file = conf['data_file']

print('initial match point is ' + match_type +'. Using Record Set ID ' + str(record_set))

#comment out this line if you have a fresh duplicates file stored locally
if match_type != "sample":
	print('extracting the duplicate records from Polaris')
	get_dupes(record_set,data_file)

print('converting bib data to hash')
bibs = bib_to_hash(data_file)

print('number of bibs to analyze: ' + str(len(bibs)))

print('beginning identification of duplicates')
results = identify_dupes(bibs,conf)

print('number of duplicates detected: ' + str(len(results)))

print('calculate weighting scores')
#name the output file
now = (datetime.datetime.now().strftime("%Y-%m-%d-%H:%M"))
file_title = now + '_' + match_type + '_' + str(record_set)
#weight the bibs
weight_bibs(bibs,results,file_title)

#add the results to Polaris
insert_results(file_title)

print("--- %s seconds ---" % (time.time() - start_time))