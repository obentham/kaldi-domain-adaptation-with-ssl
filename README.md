# Domain Adaptation using Semi-Supervised Learning for Speech Recognition

## Datasets

| name        | code | domain            | data                  | hours | train LM? |
|-------------|------|-------------------|-----------------------|------:|-----------|
| WSJ         | wsj  | news broadcast    | text and audio        | 79    | yes       |
| Switchboard | swbd | spontaneous phone | audio (text for eval) | 260   | NO!       |
| Fisher      | fish | spontaneous phone | text                  | N/A   | yes       |

## Procedure

1. Run Kaldi to generate baseline alignments prior to starting Pytorch-Kaldi

2. Create 4 LMs, one trained on wsj (lm_wsj), one trained on fish (lm_fish), one trained on both (lm_both), and one trained on swbd (lm_swbd) as an upper bound/gold standard.

3. For each LM, train a Pytorch-Kaldi system on wsj, saving model at specific increments

4.
