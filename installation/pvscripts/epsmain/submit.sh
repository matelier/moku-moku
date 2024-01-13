#!/bin/sh
cd __TARGETDIR__
__MPIEXEC__ -np __NP__ __EPSILON__ ne=__NP__ nk=1 < /dev/null > errLog 2>&1
