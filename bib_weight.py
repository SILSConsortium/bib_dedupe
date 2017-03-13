import csv
import collections
import time
import re
from fuzzywuzzy import fuzz
from fuzzywuzzy import process
from random import sample

#our includes
from identify import *
from dupefu import *

def weight_bibs(bibs,dupes,phase,sample):
#weighting dupes

	dupe_file = phase + '_duplicates.csv' 
	report_file = phase + '_report.csv'
	random_file = phase + '_sample.csv'
	isbn_file = phase + '_isbns_to_add.csv'

	check_books = list()

	for k,v in dupes.items():
		
		load = open('results/' + dupe_file,'a')
		report = open('results/' + report_file,'a')
		random_list = csv.writer(open('results/' + random_file,'a'))
		isbns = open('results/' + isbn_file,'a')

		bib_set = {}
		
		for bib_id in v:
			bib_details = bibs[bib_id]
			rating = rate_bib( bib_details )
			bib_set.setdefault(bib_id,rating)
			report.write(str(bib_id) + '|' + str(bib_details[0]) + '|' + str(bib_details[1]) + '|' + str(bib_details[2]) + '|' + str(bib_details[4]) + '|' + str(bib_details[5]) + '|' + str(rating) + '\n')
			
			#print bib_details[4]
			
		#determine the winner
		winner = max(bib_set.iterkeys(), key =(lambda key: bib_set[key]))

		check_set = list()

		bib_set.pop(winner)
		for k in bib_set:

			#print str(winner) + ',' + str(k)
			load.write(str(winner) + ',' + str(k) + '\n')

			ISBN1 = bibs[winner][0]
			ISBN2 = bibs[k][0]
			
			uniqueISBNs = list(set(ISBN2) - set(ISBN1))
			if uniqueISBNs:
				for i in uniqueISBNs:
					isbns.write(str(winner) + ',' + i + '\n')

			check_set.append(k)

		# for k,v in for_review.items():
		# 	for bib_id in v:
		# 		review.write(str(bib_id) + '\n')
		
		check_set = [winner] + [check_set] + [bib_details[1]] + [bib_details[2]]

		#print check_set

		check_books.append(check_set)

	#print check_books	

	#create a random sample
	if sample > 0:
		random_sample = sample(check_books,5)
		#print random_sample
		for e in random_sample:
	 		random_list.writerow(e)


