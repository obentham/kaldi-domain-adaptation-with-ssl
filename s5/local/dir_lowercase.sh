#!/bin/bash

# given a directory, lowercases all files in it

dir=$1

for file in $(find $dir -type f); do
    cat $file | awk '{print tolower($0)}' > $dir/lowercase_temp.txt
    cat $dir/lowercase_temp.txt > $file
    rm -f $dir/lowercase_temp.txt
done
