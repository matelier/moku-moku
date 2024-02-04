#!/bin/sh
#計算ディレクトリを作ります。
nc=50
ic=5.00
dc=0.25
for v in `seq 1 $nc`; do
  c=$( echo \($v-1\)*$dc+$ic | bc -l )
  mkdir -p c$c
  cp -r file_names.data c$c/
  sed "s/__C__/${c}/g" nfinp.data > c$c/nfinp.data
done

#pueueを利用して、計算実行します。
DIRS=(`ls -d c*`)
echo ${DIRS[*]}

pueued -d
sleep 2  # 次のparallel設定を確実に実行するためのwait
pueue parallel 4

for i in ${DIRS[*]}
do
	echo $i
	pueue add -- "cd $i; mpiexec -n 1 ../../../../../bin/phase"
done

pueue wait  # 全タスクの終了を待ちます。
pueue shutdown

#計算結果をまとめます。
for i in ${DIRS[*]}
do
	c=`echo $i | cut -c 2-`
	echo -n $c >> nfefn.data
	tail -n 1 $i/nfefn.data >> nfefn.data
done

