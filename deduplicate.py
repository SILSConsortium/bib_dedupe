import csv
import collections
import time
import re
import time
import yaml

from fuzzywuzzy import fuzz
from fuzzywuzzy import process

#our includes
from identify import *
from dupefu import *
from bib_weight import *

start_time = time.time()

print 'loading config and converting bib data to hash'
conf = yaml.load(open("config.yaml","r"))
bibs = bib_to_hash(conf["file"])
print 'number of bibs: ' + str(len(bibs))

print 'beginning identification of duplicates'
results = identify_dupes(bibs,conf)

print 'number of duplicates detected: ' + str(len(results[0]))

print 'calculate weighting scores'
#name the output file
file_title = 'phase' + conf['phase'] + '_' + conf['format']
sample_size = conf['random_sample_size']

weight_bibs(bibs,results[0],file_title,sample_size)


print("--- %s seconds ---" % (time.time() - start_time))