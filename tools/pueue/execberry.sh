#!/bin/sh

#Pueue初期化
pueued -d
sleep 2  # 次のparallel設定を確実に実行するためのwait
pueue parallel 2

DIRS=(`ls -d scf*`)
echo ${DIRS[*]}

for i in ${DIRS[*]}
do
	echo $i
	pueue add -- "cd $i; mpiexec -n 2 ../../../../../../bin/phase ne=1 nk=2"
done

pueue wait  # 全タスクの終了を待ちます。（SCF計算）


DIRS=(`ls -d berry*`)
echo ${DIRS[*]}

for i in ${DIRS[*]}
do
	echo $i
	pueue add -- "cd $i; mpiexec -n 2 ../../../../../../bin/ekcal ne=2 nk=1"
done

pueue wait  # 全タスクの終了を待ちます。（電荷密度固定計算）

pueue shutdown

