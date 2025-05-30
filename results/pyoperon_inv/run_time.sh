for file in $(echo */); do
    echo -ne "$file "
    mlr --csv --fs ';' --headerless-csv-output cat --filename \
    then stats1 -a max -f time_sec -g filename \
    then stats1 -a mean -f time_sec_max \
    ${file}/run*.gz
done
