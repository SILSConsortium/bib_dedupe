# import csv
# import collections
# import time
# import re
from fuzzywuzzy import fuzz
from fuzzywuzzy import process

# #our includes
# from identify import *
from dupefu import *


# import time

#this is the main function for identifying dupes
def identify_dupes(bibs,conf):

	seen = set() #use for determining which bibs have been looked at already in the loop below

	dupes = {} #dictionary to store dupes

	#range for determining which bib sets have already been compared
	bib_list = sorted(bibs.keys())
	bib_list_count = len(bib_list)

	print(conf["title_match"])

	for i in range(0,bib_list_count):
		k1 = bib_list[i]

		if k1 in seen:
			next

		v1 = bibs[k1]

		for j in range(i + 1,bib_list_count):
			k2 = bib_list[j]
			if k2 in seen:
				continue

			v2 = bibs[k2]

#begin detecting dupes - use config.yaml to set your match points

			#isbn
			isbn_unique = compare_set(conf["isbn"],v1[0],v2[0], conf["null_isbn"])
			if isbn_unique:
				continue	

			# #title
			title_unique = compare_string(conf["title_match"],v1[1],v2[1],conf["title_fuzz"])
			if title_unique: 
				continue

			# #author
			author_unique = compare_string(conf["author_match"],v1[2],v2[2],conf["author_fuzz"])
			if author_unique:
				continue

			# #tom -- specific to Polaris
			tom_unique = compare_tom(conf["tom"],v1[3],v2[3])
			if tom_unique:
				continue	

			if v1[4] == 'KIT':
				continue

			# #gmd	
			gmd_unique = compare_string(conf["gmd_match"],v1[4],v2[4],conf["gmd_fuzz"])
			if gmd_unique:
				continue	

			# #pubdate
			pubdate_unique = compare_set(conf["pubdate"],v1[15],v2[15], conf["null_pubdate"])
			if pubdate_unique:
				continue	

			# #volume
			if v1[19] != v2[19]:
				continue

			# #title_num
			if v1[21] != v2[21]:
				continue

			# #notes 	
			notes_unique = compare_string(conf["notes_match"],v1[17],v2[17],conf["notes_fuzz"])
			if notes_unique:
				continue

			# #series	
			series_unique = compare_string(conf["series_match"],v1[18],v2[18],conf["series_fuzz"])
			if series_unique: 
				continue

			# #name part 245$p
			part_unique = compare_string(conf["name_part_match"],v1[20],v2[20],conf["name_part_fuzz"])
			if part_unique: 
				continue

			else:
				#print(k1,k2)
				add_or_insert_into_dictionary(dupes, k1, k2)
				seen.add(k2)


				#print(k1,v1[1],k2,v2[1])
				print(k1,v1[0],v1[1],v1[2],v1[4],v1[15],v1[17],v1[18]) 
				print(k2,v2[0],v2[1],v2[2],v2[4],v2[15],v2[17],v2[18])

	return dupes