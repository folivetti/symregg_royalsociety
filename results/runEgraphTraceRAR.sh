#!/bin/bash

for i in {1..50}; do { time egraphSearch -d datasets/RARpre.csv:::gobs:gbar,logX,logY,logXErr,logYErr:e_gobs:e_gbar -g 25000 -a BestFirst -s $1 -k 1 --distribution ROXY --opt-iter 50 --opt-retries 2 --trace +RTS -N1 > results/egraph-trace/rar_${1}/run_${i}.csv ; } 2>> results/egraph-trace/rar_${1}/time; done
