#!/bin/bash

set -e -o pipefail

for x in 25 20 15 10 5 4; do
    nohup local/chain/chain_rescore_splits.sh --subset $x > chain_rescore_$x.log &
done
