#!/bin/bash

set -e -o pipefail

stage=0
nj=30

subset=

test_sets="test_dev93 test_eval92 test_eval93 test_swbd"

gmm=tri3b        # this is the source gmm-dir that we'll use for alignments; it
                 # should have alignments for the specified training data.
num_threads_ubm=32

# Options which are not passed through to run_ivector_common.sh
affix=1f   #affix for TDNN+LSTM directory e.g. "1a" or "1b", in case we change the configuration.

# LSTM/chain options
train_stage=-10
xent_regularize=0.1

# training chunk-options
chunk_width=140,100,160
# we don't need extra left/right context for TDNN systems.
chunk_left_context=0
chunk_right_context=0

# training options
srand=0
remove_egs=true

#decode options
test_online_decoding=false  # if true, it will run the last decoding stage.

. ./config.sh
. ./cmd.sh
. ./path.sh
. ./utils/parse_options.sh

train_set=train_si284_${subset}k
nnet3_affix=_$subset

# End configuration section.
echo "--------------------- running chain rescore for ${train_set}"
echo "$0 $@"  # Print the command line for logging

gmm_dir=exp/${gmm}
ali_dir=exp/${gmm}_ali_${train_set}_sp
lat_dir=exp/chain${nnet3_affix}/${gmm}_${train_set}_sp_lats
dir=exp/chain${nnet3_affix}/tdnn${affix}_sp
train_data_dir=data/${train_set}_sp_hires
train_ivector_dir=exp/nnet3${nnet3_affix}/ivectors_${train_set}_sp_hires
lores_train_data_dir=data/${train_set}_sp

# note: you don't necessarily have to change the treedir name
# each time you do a new experiment-- only if you change the
# configuration in a way that affects the tree.
tree_dir=exp/chain${nnet3_affix}/tree_a_sp
# the 'lang' directory is created by this script.
# If you create such a directory with a non-standard topology
# you should probably name it differently.
lang=data/lang_chain${nnet3_affix}

utils/lang/check_phones_compatible.sh \
    data/$rescore_lang/phones.txt $lang/phones.txt
utils/mkgraph.sh \
    --self-loop-scale 1.0 data/$rescore_lang \
    $tree_dir $tree_dir/graph_$rescore_lang || exit 1;

frames_per_chunk=$(echo $chunk_width | cut -d, -f1)
rm $dir/.error 2>/dev/null || true

for data in $test_sets; do
    (
	data_affix=$(echo $data | sed s/test_//)
	nspk=$(wc -l <data/${data}_hires/spk2utt)
	for lmtype in $rescore_lang; do
            steps/nnet3/decode.sh \
		--acwt 1.0 --post-decode-acwt 10.0 \
		--extra-left-context 0 --extra-right-context 0 \
		--extra-left-context-initial 0 \
		--extra-right-context-final 0 \
		--frames-per-chunk $frames_per_chunk \
		--nj $nspk --cmd "$decode_cmd"  --num-threads 4 \
		--online-ivector-dir exp/nnet3${nnet3_affix}/ivectors_${data}_hires \
		$tree_dir/graph_${lmtype} data/${data}_hires ${dir}/decode_${lmtype}_newgraph_${data_affix} || exit 1
	done
    ) &
done
  
exit 0;

for data in $test_sets; do
    (
	data_affix=$(echo $data | sed s/test_//)
	steps/lmrescore.sh \
            --self-loop-scale 1.0 \
            --cmd "$decode_cmd" data/$test_lang data/$rescore_lang \
            data/${data}_hires ${dir}/decode_${test_lang}_${data_affix} \
	    ${dir}/decode_${rescore_lang}_${data_affix} || exit 1
    ) &
done

exit 0;
