#!/bin/bash

for i in {1..50}; do { time egraphGP -d datasets/RARpre.csv:::gobs:gbar,logX,logY,logXErr,logYErr:e_gobs:e_gbar -g 100 --nPop 500 --pm 0.5 --pc 0.8 --tournament-size 2 -s $1 -k 1 --distribution ROXY --opt-iter 50 --opt-retries 2 --trace +RTS -N1 > results/egraph-gp/rar_${1}/run_${i}.csv ; } 2>> results/egraph-gp/rar_${1}/time; done
