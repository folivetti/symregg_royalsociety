#!/bin/bash

threshold=${1} # set threshold or use -0.2 as default
folder=${2}

echo "runnumber,evals,expression,mse"

# simulate 50 random orders of fitting 50000 expressions 
for idx in $(seq 1 50)
do
    # input format:
    # database_nvar1_len_9_fitted.txt.gz;abs(abs(x1) ^ p1 + p2) ^ p3 * p4;5.351581739392477e-5;[-5.466993749830685, 0.00016567854815110051, -0.18291628212214361, 0.6290807494549304];21472;21471;138;34;0;75;1.8964345409999999
        mlr --csv --implicit-csv-header --headerless-csv-output --fs ';' --from "${folder}/ranked_mse_len10.txt.gz" \
        cut -f 2,3 \
        then sample -k 50000 \
        then shuffle \
        then cat -n \
        then filter "\$3 < ${threshold}" \
        then head -n 1
done | mlr --implicit-csv-header --headerless-csv-output --csv --ifs ';' --ofs ',' sort -n 1 then cat -n
