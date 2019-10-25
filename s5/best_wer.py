#!/usr/bin/env python

import sys
import re
import pprint
from operator import itemgetter

pp = pprint.PrettyPrinter(indent=4)

out = []
for line in sys.stdin:
    temp = []
    arr = line.strip('\n').split()
    src = arr[0].split('/')
    temp.append(arr[1])
    temp.append(src[2])
    temp.append(src[3])
    # print(temp[2],'\t',temp[0],'\t',temp[1],'\t',)
    out.append(temp)

out = sorted(out, key=itemgetter(0))
    
# print(out)
pp.pprint(out)
