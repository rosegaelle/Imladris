# https://codegolf.stackexchange.com/questions/2602/draw-dice-results-in-ascii

from random import*
r=randrange(6)
C='*.'
s='-----\n|'+C[r<1]+'.'+C[r<3]+'|\n|'+C[r<5]
print (s+C[r&1]+s[::-1])

# @ToDo - refactor and add more...
