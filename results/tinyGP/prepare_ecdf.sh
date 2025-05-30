#!/bin/bash

threshold=${1:--0.2} # set threshold or use -0.2 as default
folder=${2}

echo "runnumber,filename,evals,generation,individual_index,expression,fitness,nodes"

for file in ${folder}/run*.csv
do
    # input format:
    # generation,individual_index,expression,fitness,nodes
    # 0,0,1/(abs(abs(x0)**(-0.7205905638782937))**(x0)),-51865321.93687708,6

    # cat -n adds line number as first field
    mlr --headerless-csv-output --csv --fs ',' --from ${file} \
        cat -n --filename \
        then put '$fitness_num = $fitness=="-inf" ? -1e30 : $fitness' \
        then filter "\$fitness_num > ${threshold}" \
        then head -n 1
done | mlr --implicit-csv-header --headerless-csv-output --csv --fs ',' sort -n 2 then cat -n

