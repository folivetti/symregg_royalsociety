#!/bin/bash
for i in {1..50}; do { time egraphGP -d datasets/$1.csv -g 100 --nPop 500 --pm 0.4 --pc 0.8 --tournament-size 2 -s $2 -k 1 --distribution MSE --opt-iter 50 --opt-retries 2 --trace +RTS -N1 > results/egraph-gp/${1}_${2}/run_${i}.csv; } 2>> results/egraph-gp/${1}_${2}/time ; done
