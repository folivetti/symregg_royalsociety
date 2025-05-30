#!/bin/bash

threshold=${1:--0.2} # set threshold or use -0.2 as default
folder=${2}
lenlimit=${3:-10} # default limit 10

echo "runnumber,filename,evals,gen,mse,len,expression"

for file in ${folder}/run*.txt.gz
do
    # input format (without header):
    # generation;mse;?;expression
    # 50;0.0001972715836018324;4.5745388367883653e-41;((0.626131415367 * X1) ^ ((0.332004338503 * X1) ^ ((-0.049369096756) * X1)))
    # cat -n adds line number as first field
        mlr --csv --headerless-csv-output --fs ';' --from $file \
        then cat -n --filename \
        then filter "\$MSE < ${threshold}" \
        then filter "\$AdjustedLenght <= ${lenlimit}" \
        then head -n 1
done | mlr --implicit-csv-header --csv --ifs ';' --ofs ',' sort -n 2 then cat -n


#         then put '$fitness_num = $fitness=="-inf" ? -1e30 : $fitness' \
