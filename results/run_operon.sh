#!/bin/bash
for file in beer.csv beerlaw.csv nikuradse_1.csv nikuradse_2.csv supernovae.csv; do
    fn="../datasets/$file"
    for maxlen in 5 7;  do
        mkdir -p operon/${file%.csv}_$maxlen/

        for i in $(seq 1 50); do
            echo "file: $fn"
            # { time python tinyGP.py $1 datasets/$2.csv 2>/dev/null > results/tinyGP/${2}_${1}/run_$i.csv ; } 2>> results/tinyGP/${2}_${1}/time.log
            targetvar=$(head -n 1 $fn | awk -F ',' 'BEGIN {RS="\r\n"} {print $NF}') # RS because the files have windows EOL
            inputs=$(head -n 1 $fn | sed "s/\r//g" | sed "s/,$targetvar//g")
            echo "target: _${targetvar}_"
            echo "inputs: _${inputs}_"
            lines=$(wc -l $fn | awk '{ print $1 }')
            echo "lines: $lines"
            ~/operon_current/build/cli/operon_nsgp \
                --dataset $fn \
                --target $targetvar \
                --train 0:$(( $lines - 1))\
                --objective mse\
                --maxlength ${maxlen} \
                --maxdepth ${maxlen} \
                --creator-maxlength $maxlen \
                --creator-maxdepth $maxlen \
                --linear-scaling=false \
                --population-size 1000 \
                --pool-size 1000 \
                --generations 50 \
                --male-selector=tournament:5 --female-selector=tournament:5 \
                --iterations 100 \
                --evaluations 5000000 \
                --enable-symbols add,sub,mul,div,powabs \
                --disable-symbols log,exp,aq \
                --show-pareto-front \
                > operon/${file%.csv}_$maxlen/run_$i.txt
        done
    done
done