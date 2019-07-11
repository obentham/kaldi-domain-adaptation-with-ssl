
find -name 'best_wer' | xargs grep 'wer' | column -t -s ' ' | \
    awk '{print $1,"\t",$2}' | python3 ./best_wer.py
