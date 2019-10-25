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
    wer = float(arr[1])
    method = src[2]
    if 'chain' in method:
        #print('\n',arr,'\n',src,'\n',wer,'\n',method,'\n')
        dir_info = src[4].split('_')
        #print(dir_info)
        lang = dir_info[1]
        test_set = dir_info[-1]
        temp.append(wer)
        temp.append(method)
        if 'newgraph' in dir_info:
            lang += '_ng'
        temp.append(lang)
        temp.append(test_set)
        # print(temp[2],'\t',temp[0],'\t',temp[1],'\t',)
        out.append(temp)

# order is: wer model lang set
    
out = sorted(out, key=itemgetter(0))

space_added = False
for line in out:
    if line[3] in ['eval92', 'eval92.si']:
#        if not space_added:
#            space_added = True
#            print()
        print(line[0], '\t', line[1], '\t', line[2], '\t', line[3])

space_added = False
for line in out:
    if line[3] in ['eval93', 'eval93.si']:
        if not space_added:
            space_added = True
            print()
        print(line[0], '\t', line[1], '\t', line[2], '\t', line[3])

space_added = False
for line in out:
    if line[3] in ['dev93', 'dev93.si']:
        if not space_added:
            space_added = True
            print()
        print(line[0], '\t', line[1], '\t', line[2], '\t', line[3])

space_added = False
for line in out:
    if line[3] in ['swbd', 'swbd.si']:
        if not space_added:
            space_added = True
            print()
        print(line[0], '\t', line[1], '\t', line[2], '\t', line[3])
