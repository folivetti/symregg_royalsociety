#!/bin/bash

for i in {30..50}; do { time symregg -d datasets/RARpre.csv:::gobs:gbar,logX,logY,logXErr,logYErr:e_gobs:e_gbar -g 25000 -a BestFirst -s $1 -k 1 --loss ROXY --opt-iter 50 --opt-retries 2 --trace +RTS -N1 > results/easter/rar_${1}/run_${i}.csv ; } 2>> results/easter/rar_${1}/time; done
