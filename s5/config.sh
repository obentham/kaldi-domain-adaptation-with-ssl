trainLM=true	# trains LM from train data if true, downloads librispeech LM if false
lm_url=www.openslr.org/resources/11

train=true	# set to false to disable the training-related scripts
             	# note: you probably only want to set --train false if you
	     	# are using at least --stage 1.

decode=true  	# set to false to disable the decoding-related scripts.

. ./cmd.sh 	## You'll want to change cmd.sh to something that will work on your system.
           	## This relates to the queue.
		
. utils/parse_options.sh	# e.g. this parses the --stage option if supplied.


# wsj options

export wsj0=/mnt/corpora/LDC93S6B/csr_1_senn
export wsj1=/mnt/corpora/LDC94S13B/csr_senn

export wsj_data=wsj_data
export wsj_lm=wsj_lm


# swbd options

export swbd=/home/data/ateam/switchboard

export swbd_data=swbd_data
export swbd_alignments=~/mnt_larocca2/data/swb_ms98_transcriptions

# fish options

export fish=/mnt/disk02/fisher_corpus

export fish_data=fish_data
export fish_lm=fish_lm

# lang options

export train_lang=wsj_lang_test_bd_fg
export test_lang=wsj_lang_test_bd_fg
export rescore_lang=fish_lang_final
