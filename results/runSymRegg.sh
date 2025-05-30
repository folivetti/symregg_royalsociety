#!/bin/bash
for i in {1..50}; do { time symregg -d datasets/$1.csv -a BestFirst -g 50000 -s $2 -k 1 --loss MSE --opt-iter 50 --opt-retries 2 --trace +RTS -N1 > results/easter/${1}_${2}/run_${i}.csv; } 2>> results/easter/${1}_${2}/time ; done
