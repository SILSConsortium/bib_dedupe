from fuzzywuzzy import fuzz
from fuzzywuzzy import process
from dupefu import rate_bib
import random
import re


p1 = "WIND AT MY BACK THE COMPLETE FOURTH SEASON DISC 01(4)99"
p2 = "WIND AT MY BACK THE COMPLETE FIFTH SEASON DISC 01(4)99"

p5 = "THE STORY OF ST JOHNS NEWFOUNDLAND"
p6 = "THE OLDEST CITY THE STORY OF ST JOHNS NEWFOUNDLAND"


print(fuzz.ratio(p1,p2))

print(fuzz.partial_ratio(p1,p2))

print(fuzz.token_set_ratio(p1,p2))

print(fuzz.ratio(p5,p6))

print(fuzz.partial_ratio(p5,p6))

print(fuzz.token_set_ratio(p5,p6))


