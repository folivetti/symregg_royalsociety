#!/bin/bash
for i in {1..50}; do
    { time python tinyGP.py $1 datasets/$2.csv 2>/dev/null > results/tinyGP/${2}_${1}/run_$i.csv ; } 2>> results/tinyGP/${2}_${1}/time.log
done

