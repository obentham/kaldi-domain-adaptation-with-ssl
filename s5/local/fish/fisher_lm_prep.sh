#!/bin/bash

tmpdir=`pwd`/data/local/fish_data
mkdir -p $tmpdir

find $fish/fe_03_p1_tran/data -name '*.txt' > $tmpdir/transcripts.flist

cat $tmpdir/transcripts.flist | xargs cat > $tmpdir/text.1

# remove comment lines that start with '#'
sed -i '/^#/ d' $tmpdir/text.1
# cut to remove speaker info at beginning of line
cut -f4- -d " " $tmpdir/text.1 > $tmpdir/text.2
# remove empty lines
sed -i '/^[[:space:]]*$/d' $tmpdir/text.2
# substitutions taken from fisher_data_prep.sh
cat $tmpdir/text.2 | grep -v '((' | \
    awk '{if (NF > 1){ print; }}' | \
    sed 's:\[laugh\]:[laughter]:g' | \
    sed 's:\[sigh\]:[noise]:g' | \
    sed 's:\[cough\]:[noise]:g' | \
    sed 's:\[sigh\]:[noise]:g' | \
    sed 's:\[mn\]:[noise]:g' | \
    sed 's:\[breath\]:[noise]:g' | \
    sed 's:\[lipsmack\]:[noise]:g' > $tmpdir/text.3

cp $tmpdir/text.3 $tmpdir/text
