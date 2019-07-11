#!/bin/bash

text=data/local/fish_data/text
lexicon=data/local/wsj_dict/lexicon.txt

dir=data/local/fish_lm
mkdir -p $dir

export LC_ALL=C
export PATH=$PATH:$KALDI_ROOT/tools/kaldi_lm

cleantext=$dir/text.no_oov

cat $text | awk -v lex=$lexicon 'BEGIN{while((getline<lex) >0){ seen[$1]=1; } }
  {for(n=1; n<=NF;n++) {if (seen[$n]) {printf("%s ", $n);} else {printf("<unk> ");}} printf("\n");}'\
  > $cleantext || exit 1;

cat $cleantext | awk '{for(n=2;n<=NF;n++) print $n; }' | sort | uniq -c | \
  sort -nr > $dir/word.counts || exit 1;

# Get counts from acoustic training transcripts, and add  one-count
# for each word in the lexicon (but not silence, we don't want it
# in the LM-- we'll add it optionally later).
cat $cleantext | awk '{for(n=2;n<=NF;n++) print $n; }' | \
  cat - <(grep -w -v '!SIL' $lexicon | awk '{print $1}') | \
  sort | uniq -c | sort -nr > $dir/unigram.counts || exit 1;

# note: we probably won't really make use of <unk> as there aren't any OOVs
cat $dir/unigram.counts  | awk '{print $2}' | get_word_map.pl "<s>" "</s>" "<unk>" > $dir/word_map \
  || exit 1;

cat $cleantext | awk -v wmap=$dir/word_map 'BEGIN{while((getline<wmap)>0)map[$1]=$2;}
  {for(n=2;n<=NF;n++) {printf map[$n]; if(n<NF){printf " ";} else {print "";}}}' | gzip -c >$dir/train.gz || exit 1;

train_lm.sh --arpa --lmtype 3gram-mincount $dir || exit 1;

