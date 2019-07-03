#!/bin/bash

# given a directory, lowercases all .gz files in it

dir=$1

for file in $(find $dir -type f -name "*.gz"); do
    gunzip $file
done

for file in $(find $dir -type f -name "*.arpa"); do
    cat $file | awk '{print tolower($0)}' | gzip -c -f > ${file}.gz
done
