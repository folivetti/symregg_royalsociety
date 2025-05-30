#!/bin/bash

threshold=${1}
folder=${2}

echo "runnumber,filename,evals,expression,param,fitness"

for file in ${folder}/run*.csv
do
    # input format (without header):
    # expression,params,fitness
    # ((x0 / (x0 + x0)) - Recip(x0)),,5.6535388116891605


    # cat -n adds line number as first field
    mlr --headerless-csv-output --headerless-csv-input --csv --fs ',' --from ${file} \
        --prepipex "head -n-2" \
        rename 1,expression,2,params,3,fitness \
        then cat -n --filename \
        then filter "\$fitness < ${threshold}" \
        then head -n 1
done | mlr --implicit-csv-header --headerless-csv-output --csv --fs ',' sort -n 2 then cat -n


#         then put '$fitness_num = $fitness=="-inf" ? -1e30 : $fitness' \
