#!/bin/sh

phase=~/phase0_2021.02/bin/phase
file=data.txt

for i in `seq 560 10 991`
do
    c=`echo "scale=2; $i / 100.0" | bc`
    sed 's/$1/'$c'/g' nfinput.data > nfinp.data

    mpiexec -n 8 $phase ne=1 nk=8

    e=`grep TH output000 | tail -n 1 | cut -c 35-54`
    y=`echo "scale=10; ($e / 1 - -22.74) * 27.211386246" | bc`  #

    echo $c $y >> $file
    mv output000 output$i
done
