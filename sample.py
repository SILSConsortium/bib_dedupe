from fuzzywuzzy import fuzz
from fuzzywuzzy import process
from dupefu import rate_bib
import random
import re


p1 = "SHATTERED JUSTICE"
p2 = "SHATTERED JUSTICE A SAVAGE MURDER AND THE DEATH OF THREE FAMILIES INNOCENCE"

p5 = "THE STORY OF ST JOHNS NEWFOUNDLAND"
p6 = "THE OLDEST CITY THE STORY OF ST JOHNS NEWFOUNDLAND"



print fuzz.ratio(p1,p2)

print fuzz.partial_ratio(p1,p2)

print fuzz.token_set_ratio(p1,p2)

print fuzz.ratio(p5,p6)

print fuzz.partial_ratio(p5,p6)

print fuzz.token_set_ratio(p5,p6)


