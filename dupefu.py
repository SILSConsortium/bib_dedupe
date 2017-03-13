import csv
import collections
import time
import re
import string
import time

from fuzzywuzzy import fuzz
from fuzzywuzzy import process


#our includes
from dupefu import *
from identify import *


#converts the bib fields to a dictionary for easy reading
def bib_to_hash ( file ):

	bibfile = open( file )
	bibReader = list(csv.reader(bibfile))
	bibs = {}

	for row in bibReader:

		#primary identification fields		
   		bibID = int(row[0])
		ISBN = str(row[15])
		Pubdate260 = re.search('\d+', row[17])

		MARCdate1 = re.findall('\d+', row[5])

		authornotes = row[19].translate(string.maketrans("",""), string.punctuation).upper()
		series = row[18].translate(string.maketrans("",""), string.punctuation).upper()

		if Pubdate260:
			MARCdate1.append(str(Pubdate260.group(0)))

		#create list of unique pubdates plus one
		pubdate = list(set(MARCdate1))
		pubdate = [ int(x) for x in pubdate ]

		pub_increase =  [ x + 1 for x in pubdate ]

		pubdate = pubdate + pub_increase

		#extract remaining fields to add to bib dictionary
		row1 = row[1:15]
		row1.append(pubdate)
		row1.append(row[16])
		
		#PHASE 2 and NON-fiction
		row1.append(authornotes)
		row1.append(series)

		#create dictionary
		if bibs.has_key(bibID):
			bibs[bibID][0].append(ISBN)

		else:
			ISBNlist = [[ISBN]] + row1
			bibs.setdefault(bibID,ISBNlist)

	return bibs

#compare TOMs - Polaris specific field
def compare_tom( match , bib1, bib2 ):
	if match == 0:
		return False
	
	if match == 1:
		if bib1 != bib2:
			return True
		else:
			return False

#compare string fields
def compare_string( match, bib1, bib2 , cutoff ):

	if (len(bib1) == 0) and (len(bib2) == 0):
		return False

	if match == 0:
		return False

	if match == 1:
		return (bib1 != bib2)
	
	if match == 2:
		rating = fuzz.ratio(bib1,bib2)
	elif match == 3:
		rating = fuzz.partial_ratio(bib1,bib2)
	elif match == 4:
		rating = fuzz.token_set_ratio(bib1,bib2)
	else: 
		return False
	return (rating < cutoff)

#compare sets - isbn and pubdate
def compare_set( match, bib1, bib2 , null_set):
	if match == 0:
		return False

	if match == 1: 
		match_set = set(bib1).intersection(bib2)

		if null_set == 1:
			if match_set:
				return False
			else:
				return True
		else: 
			if 'NULL' in match_set:
				return True
			elif match_set:
				return False
			else: 
				return True

#assign a weighting number to a bib record
def rate_bib( bib ):
	#zfill adds left padding on numbers - these have to be strings to construct the weight int as SCLENDS did

	if (len(bib[16]) > 6):
		tag008 = '2'
	else:
		tag008 = '1'
	
	tagcount = str(len(bib[0]) + len(bib[5]) + int(bib[6]) + int(bib[7]) + int(bib[8]) + int(bib[9]) + int(bib[10]) + int(bib[12])).zfill(3)

	isbn = str(len(bib[0])).zfill(2)
	tag24x = str(bib[6]).zfill(2)
	tag3xx = str(bib[7]).zfill(2)
	tag5xx = str(bib[8]).zfill(2)
	tag6xx = str(bib[9]).zfill(2)
	tag7xx = str(bib[10]).zfill(2)
	tag856 = str(bib[11]).zfill(2)
	tagmisc = str(bib[12]).zfill(2)
	
	tag300 = str(bib[13]).zfill(2)
	linkeditems = str(bib[14]).zfill(3)

	rating = tag008 + tagcount + isbn + tag24x + tag300 + tag5xx + tag6xx + tagmisc + tag7xx + tag3xx + linkeditems + tag856
	rating = int(rating)

	return rating

#this function is used to build the dictionary of dupes for weighting
def add_or_insert_into_dictionary(dictionary, k, v):

	if dictionary.has_key(k):
		dictionary[k].append(v)
	else:
		initial_value = [k,v]
		dictionary.setdefault(k, initial_value)