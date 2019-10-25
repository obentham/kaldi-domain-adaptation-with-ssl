# Domain Adaptation using Semi-Supervised Learning for Speech Recognition

## Datasets

| name        | code | domain  | description       | data           | hours | utts    |
|-------------|------|---------|-------------------|----------------|------:|--------:|
| WSJ         | wsj  | general | news broadcast    | text and audio | 82    | 37,416  |
| Switchboard | swbd | target  | spontaneous phone | audio          | 260   | 264,151 |
| Fisher      | fish | target  | spontaneous phone | text           | N/A   | 762,396 |

## Procedure

<div style="text-align:center">
<img src="images/kaldi_ssl_da_hyp.png" alt="kaldi_ssl_da_hyp.png" width="85%"/>
</div><br>

1. Create 2 LMs, one trained on wsj (wsj_lm), and one trained on fish (fish_lm).

2. Run Kaldi to generate baseline alignments prior to starting Pytorch-Kaldi, trained with wsj_lm.

3. For each LM (only wsj_lm now), train a Pytorch-Kaldi system on wsj for each split (described below). Although only training on a single LM, decode both wsj and swbd with both LMs to generate the solid lines in the graph above.

4. At each of the 3 splits, assign pseudo-transcriptions to a batch of the swbd train data using each of the 2 LMs. This will result in 3 splits x 2 LMs = 6 SSL training experiments (see diagram below).

5. Train model again using incorporated swbd data, decoding with both LMs, reassigning transcriptions to swbd, and incorporating more swbd batches at consistent intervals to generate the dotted lines in the graph above.

6. The aim is to hopefully find the red 'x' in the graph above, the point where SSL would have no effect on the model accuracy, establishing a minimum quantity of data required to benefit from SSL domain adaptation.

## Setup

<!--<div style="text-align:center"><img src="images/kaldi_ssl_da_flowchart1.png" alt="kaldi_ssl_da_flowchart1.png" width="70%"/></div>-->
<div style="text-align:center"><img src="images/kaldi_ssl_da_flowchart2.png" alt="kaldi_ssl_da_flowchart2.png" width="90%"/></div><br>
For now, I'm training baseline model on wsj using wsj_lm, might look into doing it with fish_lm later. Along with split{1, 2, 3} that will be used for SSL, I need to train a model on many splits of wsj, since the x-axis of the curve above is amount of wsj train data. The wsj subsets that I'm going with for now are:


| wsj             | utts  | hours |
|-----------------|------:|------:|
| train_si284_1k  | 1000  | 2.1   |
| train_si284_2k  | 2000  | 4.4   |
| train_si284_3k  |	3000  | 6.4   |
| train_si284_4k  |	4000  | 8.6   |
| train_si284_5k  |	5000  | 10.7  |
| train_si284_10k |	10000 | 20.9  |
| train_si284_15k |	15000 | 32.9  |
| train_si284_20k |	20000 | 44.1  |
| train_si284_25k |	25000 | 55.2  |
| train_si284_30k |	30000 | 66.0  |
| train_si284     | 37416 | 81.5  |

## Results

top number is wsj_lang, bottom number is fish_lang

### baseline.0

| <td colspan=3>**eval92** <td colspan=3>**eval93** <td colspan=3>**dev93** <td colspan=3>**swbd.0**   
|----------|--------:|---------:|------------:|--------:|---------:|------------:|--------:|---------:|------------:|--------:|---------:|------------:|
|          | **wsj** | **fish** | **fish_ng** | **wsj** | **fish** | **fish_ng** | **wsj** | **fish** | **fish_ng** | **wsj** | **fish** | **fish_ng** |
| **4k**   | 8.84  | 12.93 | 15.18 | 13.19 | 18.10 | 21.28 | 11.99 | 17.22 | 20.03 | 98.39 | 98.49 | 98.31* |
| **5k**   | 8.02  | 12.14 | 14.19 | 11.67 | 16.58 | 19.62 | 10.84 | 15.59 | 18.60 | 96.26 | 94.98 | 94.76* |
| **10k**  | 6.56  | 9.23  | 10.75 | 9.03  | 12.70 | 14.65 | 9.29  | 12.73 | 14.31 | 90.18 | 87.75 | 86.95* |
| **15k**  | 6.19  | 8.98  | 10.09 | 7.60  | 11.82 | 13.82 | 8.53  | 11.88 | 13.65 | 89.14 | 86.59 | 85.98* |
| **20k**  | 5.98  | 8.86  | 9.82  | 7.23  | 10.73 | 12.56 | 8.35  | 11.59 | 13.11 | 87.19 | 84.25 | 83.74* |
| **25k**  | **5.81**  | 8.49  | 9.65  | 7.20  | 10.38 | 11.90 | 8.16  | 11.48 | 12.81 | 76.84 | 73.89 | **72.96*** |
| **30k**  | 5.91  | 8.32  | 9.46  | **7.03**  | 10.12 | 11.67 | 8.04  | 10.86 | 12.55 | 83.46 | 82.06 | 79.91* |
| **37k**  | 5.98  | -     | -     | 7.34  | -     | -     | **7.99**  | -     | -     | 80.51 | -     | -     |

### baseline.1

| <td colspan=3>**eval92** <td colspan=3>**eval93** <td colspan=3>**dev93** <td colspan=3>**swbd.0**   
|----------|--------:|---------:|------------:|--------:|---------:|------------:|--------:|---------:|------------:|--------:|---------:|------------:|
|          | **wsj** | **fish** | **fish_ng** | **wsj** | **fish** | **fish_ng** | **wsj** | **fish** | **fish_ng** | **wsj** | **fish** | **fish_ng** |
| **5k**   |  7.91 | 11.68 | 13.74 | 11.39 | 17.29 | 20.02 | 11.20 | 15.93 | 18.30 | 99.66 | 99.61 | 99.49 |
| **10k**  |  6.37 |  9.04 | 10.53 |  8.78 | 12.96 | 15.31 |  9.43 | 12.89 | 14.71 | 89.49 | 87.04 | 86.56 |
| **15k**  |  5.93 |  8.89 | 10.19 |  7.74 | 11.13 | 12.96 |  8.52 | 11.64 | 13.38 | 86.92 | 83.75 | 83.58 |
| **20k**  |  6.05 |  8.77 |  9.74 |  7.34 | 10.84 | 12.25 |  **8.26** | 11.83 | 13.37 | 86.79 | 83.99 | 83.58 |
| **25k**  |  6.05 |  8.93 |  9.70 |  **7.17** | 10.47 | 12.25 |  **8.26** | 11.68 | 13.02 | 75.84 | 72.86 | **72.14** |
| **30k**  |  **5.82** |  8.72 |  9.51 |  7.26 | 10.58 | 12.25 |  8.40 | 11.42 | 12.87 | 78.68 | 76.38 | 75.13 |


### ssl

these are all done using the fish_ng decoding results marked with a * in the last column above

| | **swbd.0** | **swbd.1** | **swbd.2** | **swbd.3** | **swbd.4** | **swbd.5** | **swbd.6** | **swbd.7** | **swbd.8** | **swbd.9** |
|----------|--------:|---------:|--------:|---------:|--------:|---------:|--------:|---------:|--------:|---------:|
| **2k**   |	   |       |	   |       |	   |       |	   |       |	   |       |
| **3k**   |	   |       |	   |       |	   |       |	   |       |	   |       |
| **4k**   |	   |       |	   |       |	   |       |	   |       |	   |       |
| **5k**   |	   |       |	   |       |	   |       |	   |       |	   |       |
| **10k**  |	   |       |	   |       |	   |       |	   |       |	   |       |
| **15k**  |	   |       |	   |       |	   |       |	   |       |	   |       |
| **20k**  |	   |       |	   |       |	   |       |	   |       |	   |       |
| **25k**  |       |       |       |       |       |       |       |       |	   |       |
| **30k**  |       |       |       |       |       |       |       |       |	   |       |

## Miscellaneous

 steps/lmrescore.sh --cmd "$decode_cmd" data/$test_lang data/$rescore_lang data/test_${data} exp/tri1/decode-${test_lang}-${data} exp/tri1/decode-${rescore_lang}-${data}
