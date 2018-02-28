import csv
from dupefu import *

def weight_bibs(bibs,dupes,file_title):
#weighting dupes

	dupe_file = file_title + '_duplicates.csv' 
	report_file = file_title + '_report.csv'
	isbn_file = file_title + '_isbns_to_add.csv'

	check_books = list()

	for k,v in dupes.items():
		
		#print(k,v)

		load = open('results/' + dupe_file,'a')
		report = open('results/' + report_file,'a')
		isbns = open('results/' + isbn_file,'a')
		
		bib_set = {}
		
		for bib_id in v:
			bib_details = bibs[bib_id]
			rating = rate_bib( bib_details )
			bib_set.setdefault(bib_id,rating)
			#write the output report for anyone who cares to look at it - mostly for debugging
			report.write(str(bib_id) + '|' + str(bib_details[0]) + '|' + str(bib_details[1]) + '|' + str(bib_details[2]) + '|' + str(bib_details[4]) + '|' + str(bib_details[5]) + '|' + str(rating) + '\n')
		
		#print(bib_set)
		#determine the winner
		winner = max(iter(bib_set.keys()), key =(lambda key: bib_set[key]))

		check_set = list()

		bib_set.pop(winner)

		for k in bib_set:

			#print(winner)
			load.write(str(winner) + ',' + str(k) + '\n')

			# ISBN1 = bibs[winner][0]
			# ISBN2 = bibs[k][0]
			
			# uniqueISBNs = list(set(ISBN2) - set(ISBN1))
			# if uniqueISBNs:
			# 	for i in uniqueISBNs:
			# 		isbns.write(str(winner) + ',' + i + '\n')

			check_set.append(k)
		
		check_set = [winner] + [check_set] + [bib_details[1]] + [bib_details[2]]

		#print(check_set)

		check_books.append(check_set)

	######removed the section to generate a sample
	#create a random sample
	# if sample > 0:
	# 	random_sample = sample(check_books,int(1))
	# 	#print random_sample
	# 	for e in random_sample:
	#  		random_list.writerow(e)


