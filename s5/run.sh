#!/bin/bash

#
# run using
#     nohup ./run.sh > run.log &
#
# to skip preprocessing and begin training, use:
#     nohup ./run.sh --stage 7 > run.log &
# 
# Corpora:
#   WSJ
#     train_si284
#     test_dev93
#     test_eval92
#     test_eval93
#   SWBD
#     train_swbd_data
# 

stage=0

. ./path.sh
. ./config.sh

set -e # exit on error

# data preparation.
if [ $stage -le 0 ]; then
    echo --------------------- stage 0: import data
    echo --------------------- wsj
    local/wsj/wsj_data_prep.sh $wsj0/??-{?,??}.? $wsj1/??-{?,??}.?  || exit 1;
    local/gz_lowercase.sh data/local/wsj_lm
    
    echo --------------------- swbd
    local/swbd1/swbd1_data_download.sh || exit 1;
fi

if [ $stage -le 1 ]; then
    echo --------------------- stage 1: create dictionary
    local/wsj/wsj_prepare_dict.sh || exit 1;
    chmod -R 777 data/local/dict_wsj
    local/dir_lowercase.sh data/local/dict_wsj || exit 1;
    
    #local/swbd1/swbd1_prepare_dict.sh || exit 1;
    #local/dir_lowercase.sh data/local/dict_swbd || exit 1;
fi

if [ $stage -le 2 ]; then
    echo --------------------- stage 2: prepare lang
    utils/prepare_lang.sh data/local/dict_wsj \
        "<unk>" data/local/lang_tmp data/lang || exit 1;
fi

if [ $stage -le 3 ]; then
    echo --------------------- stage 3: create train, dev, test, and ssl sets
    echo --------------------- wsj
    local/wsj/wsj_format_data.sh || exit 1;
    
    echo --------------------- swbd
    local/swbd1/swbd1_data_prep.sh $swbd || exit 1;
fi

if [ $stage -le 4 ]; then
    echo --------------------- stage 4: extend dict and train LM on wsj train data
    # bd = big dictionary
    local/wsj/wsj_extend_dict.sh --dict-suffix "_wsj" $wsj1/13-32.1 && \
	utils/prepare_lang.sh data/local/dict_wsj_larger \
	"<unk>" data/local/lang_tmp_wsj_larger data/lang_wsj_bd && \
	local/wsj/wsj_train_lms.sh --dict-suffix "_wsj" && \
	local/wsj/wsj_format_local_lms.sh --lang-suffix "_wsj"
    echo --------------------- finished extending dict and training LM
fi

if [ $stage -le 5 ]; then
    echo --------------------- stage 5: convert data to mfcc features
    # make sure bit rate and sample rate line up

    # Now make MFCC features.
    # mfccdir should be some place with a largish disk where you
    # want to store MFCC features.
    for x in swbd test_eval92 test_eval93 test_dev93 train_si284; do
	steps/make_mfcc.sh --cmd "$train_cmd" --nj 20 data/$x exp/make_mfcc/$x || exit 1;
	utils/fix_data_dir.sh data/$x
	steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x || exit 1;
    done
fi

if [ $stage -le 6 ]; then
    echo --------------------- stage 6: create subsets of train_si284 and swbd

    # 10 different sized subsets selected from 37,416 si284 utterances
    for x in 1 2 3 4 5 10 15 20 25 30; do
	utils/subset_data_dir.sh --first data/train_si284 ${x}000 data/train_si284_${x}k || exit 1;
    done

    # split 264151 utt swbd set into 262151 utt ssl set and 2000 utt test set
    utils/subset_data_dir.sh --first data/swbd 262151 data/ssl_swbd || exit 1;
    utils/subset_data_dir.sh --last data/swbd 2000 data/test_swbd || exit 1;

    echo --------------------- finished preprocessing data, ready to begin training
fi

if [ $stage -le 7 ]; then
    echo --------------------- stage 7: monophones

    steps/train_mono.sh --nj 10 --cmd "$train_cmd" data/train_si284_2k \
	data/$train_lang exp/mono || exit 1;

    utils/mkgraph.sh data/$test_lang exp/mono exp/mono/graph || exit 1;

    (
	for data in eval92 eval93 dev93 swbd; do
	    steps/decode.sh --nj 8 --cmd "$decode_cmd" exp/mono/graph \
      	        data/test_${data} exp/mono/decode_${data}
	done
    ) &
fi

if [ $stage -le 8 ]; then
    echo --------------------- stage 8: triphones tri1

    steps/align_si.sh --nj 10 --cmd "$train_cmd" data/train_si284_4k \
        data/$train_lang exp/mono exp/mono_ali || exit 1;

    steps/train_deltas.sh --cmd "$train_cmd" 2000 10000 data/train_si284_4k \
	data/$train_lang exp/mono_ali exp/tri1 || exit 1;

    utils/mkgraph.sh data/$test_lang exp/tri1 exp/tri1/graph || exit 1;

    (
	for data in eval92 eval93 dev93 swbd; do
	    steps/decode.sh --nj 8 --cmd "$decode_cmd" exp/tri1/graph \
                data/test_${data} exp/tri1/decode_${data}
	done
    ) &
fi

if [ $stage -le 9 ]; then
    echo --------------------- stage 9: triphones tri2b - LDA MLLT

    steps/align_si.sh --nj 10 --cmd "$train_cmd" data/train_si284_10k \
	data/$train_lang exp/tri1 exp/tri1_ali || exit 1;

    steps/train_lda_mllt.sh --cmd "$train_cmd" \
	--splice-opts "--left-context=3 --right-context=3" 2500 15000 \
	data/train_si284_10k data/$train_lang exp/tri1_ali exp/tri2b || exit 1;

    utils/mkgraph.sh data/$test_lang exp/tri2b exp/tri2b/graph || exit 1;

    (
	for data in eval92 eval93 dev93 swbd; do
	    steps/decode.sh --nj 8 --cmd "$decode_cmd" exp/tri2b/graph \
		data/test_${data} exp/tri2b/decode_${data}
	done
    ) &
fi

if [ $stage -le 10 ]; then
    echo --------------------- stage 10: triphones tri3b - LDA MLLT SAT

    steps/align_si.sh --nj 10 --cmd "$train_cmd" data/train_si284 \
	data/$train_lang exp/tri2b exp/tri2b_ali || exit 1;

    steps/train_sat.sh --cmd "$train_cmd" 4200 40000 data/train_si284 \
	data/$train_lang exp/tri2b_ali exp/tri3b || exit 1;

    utils/mkgraph.sh data/$test_lang exp/tri3b exp/tri3b/graph || exit 1;

    (
	for data in eval92 eval93 dev93 swbd; do
	    steps/decode_fmllr.sh --nj 8 --cmd "$decode_cmd" exp/tri3b/graph \
		data/test_${data} exp/tri3b/decode_${data}
	done
    ) &

    cp -r data data_after_tri3b
    cp -r exp exp_after_tri3b
fi

if [ $stage -le 11 ]; then
    echo --------------------- stage 11: chain model

    steps/align_fmllr.sh --nj 20 --cmd "$train_cmd" data/train_si284 \
	data/$train_lang exp/tri3b exp/tri3b_ali || exit 1;

    local/chain/run_tdnn.sh
fi
