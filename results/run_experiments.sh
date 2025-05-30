#!/bin/zsh
for dataset in "datasets"/*_train.csv
do
    fname=$(echo $dataset | cut -d '/' -f 2)
    prefix=$(echo $fname | rev | cut -d '_' -f 2- | rev )
    echo $prefix 
    if [[ $prefix =~ .*[0-9]$ ]]; then
        echo 10
        for i in {1..10}
        do 
            { time egraphGP -d datasets/${prefix}_train.csv -t datasets/${prefix}_test.csv -g 50000 -a BestFirst -s 50 -k 1 --print-pareto +RTS -N1 >> results/egraph/${prefix}_$i ; } 2>> results/egraph/${prefix}_time
        done
    else
        echo 30
        for i in {1..30}
        do 
            { time egraphGP -d datasets/${prefix}_train.csv -t datasets/${prefix}_test.csv -g 50000 -a BestFirst -s 50 -k 1 --print-pareto +RTS -N1 >> results/egraph/${prefix}_$i ; } 2>> results/egraph/${prefix}_time
        done
    fi
done
