stage=0

. ./cmd.sh

if [ $stage -le 0 ]; then
    echo --------------------- stage 0: decode monophones
    for data in eval92 eval93 dev93 swbd; do
	steps/decode.sh --nj 8 --cmd "$decode_cmd" exp/mono/graph \
      	    data/test_${data} exp/mono/decode_${data}
    done
fi


if [ $stage -le 1 ]; then
    echo --------------------- stage 1: decode triphones tri1
    for data in eval92 eval93 dev93 swbd; do
	steps/decode.sh --nj 8 --cmd "$decode_cmd" exp/tri1/graph \
            data/test_${data} exp/tri1/decode_${data}
    done
fi

if [ $stage -le 2 ]; then
    echo --------------------- stage 2: decode triphones tri2b - LDA MLLT
    for data in eval92 eval93 dev93 swbd; do
	steps/decode.sh --nj 8 --cmd "$decode_cmd" exp/tri2b/graph \
       	    data/test_${data} exp/tri2b/decode_${data}
    done
fi

if [ $stage -le 3 ]; then
    echo --------------------- stage 3: decode triphones tri3b - LDA MLLT SAT
    for data in eval92 eval93 dev93 swbd; do
	steps/decode_fmllr.sh --nj 8 --cmd "$decode_cmd" exp/tri3b/graph \
       	    data/test_${data} exp/tri3b/decode_${data}
    done
fi

if [ $stage -le 4 ]; then
    echo --------------------- stage 4: decode triphones tri3b - LDA MLLT SAT
    for data in eval92 eval93 dev93 swbd; do
	# last 2 lines in this command aren't right
	steps/nnet3/decode.sh \
            --acwt 1.0 --post-decode-acwt 10.0 \
            --extra-left-context 0 --extra-right-context 0 \
            --extra-left-context-initial 0 \
            --extra-right-context-final 0 \
            --frames-per-chunk 140 \
            --nj 8 --cmd "$decode_cmd"  --num-threads 4 \
            --online-ivector-dir exp/nnet3${nnet3_affix}/ivectors_${data}_hires \
            $tree_dir/graph_${lmtype} data/${data}_hires ${dir}/decode_${lmtype}_${data_affix}
    done
    
fi
