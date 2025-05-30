#!/bin/bash
for i in {1..50}; do { time egraphSearch -d datasets/$1.csv -a BestFirst -g 50000 -s $2 -k 1 --distribution MSE --opt-iter 50 --opt-retries 2 --trace +RTS -N1 > results/egraph-trace/${1}_${2}/run_${i}.csv; } 2>> results/egraph-trace/${1}_${2}/time ; done
