#!/bin/bash

# PARALLEL EXECUTION
ne=1
nk=8

# LATTICE CONSTANT
start=264  # /100 (Angstrom)
end=311
step=2

origin=-68.0 # エネルギー原点
natom=2  # 原子数
volratio=1.0  # Bravais格子と基本格子の体積比(fcc:4 bcc:2)

# ELEMENTS
parameters () {
    cat <<EOF
Mn  25  Mn_ggapbe_paw_02.pp
Fe  26  Fe_ggapbe_paw_02.pp
Co  27  Co_ggapbe_paw_01.pp
EOF
}

readonly hartree2eV=27.211386245988

if [ `uname` = "Windows_NT" ]; then  # busybox
    np=`echo "$ne $nk * p" | dc`  # number of process
else
    np=`echo "$ne * $nk" | bc`
fi

loopElem () {  # OUTER LOOP
    while read -r line
    do
	elem=`  echo "$line" | sed -E 's/[ \t]+/\t/g' | cut -f1`
	an=`    echo "$line" | sed -E 's/[ \t]+/\t/g' | cut -f2`
	ppfile=`echo "$line" | sed -E 's/[ \t]+/\t/g' | cut -f3`
	echo $elem $an $ppfile
	file_volume=volume$elem.txt
	file_stress=stress$elem.txt

	loopLattice
    done
}

loopLattice () {  # INNER SUBROUTINE
    for j in `seq $start $step $end`
    do
	if [ `uname` = "Windows_NT" ]; then  # busybox
	    a=`echo "$j 100.0 / p" | dc`
	    v=`echo "$a $a $a * * $volratio / p" | dc`  # volume
	else
	    a=`echo "scale=2; $j / 100.0" | bc`
	    v=`echo "scale=10; $a*$a*$a / $volratio" | bc`  # volume
	fi
	sed 's/$1/'$a'/g' nfinput.data | sed 's/$2/'$elem'/g' | sed 's/$3/'$an'/g' > nfinp.data
	sed 's/$ppfile/'$ppfile'/g' file_names.tmpl > file_names.data

	mpiexec -n $np phase ne=$ne nk=$nk < /dev/null

	e=`grep TH output000 | tail -n 1 | cut -c 35-54`  # energy (hartree)
	s=`grep -A 1 'STRESS TENSOR$' output000 | tail -n 1 | sed -E 's/[ ]+/\t/g' | cut -f2`  # stress
	if [ `uname` = "Windows_NT" ]; then  # busybox
	    y=`echo "$e $natom / $origin - $hartree2eV * p" | dc`
	else
	    y=`echo "scale=10; ($e / $natom - $origin) * $hartree2eV" | bc`  # energy (eV)
	fi
	echo $v $y >> $file_volume
	echo $a $s >> $file_stress
	mv output000 output$elem$j
    done
}

parameters | loopElem
