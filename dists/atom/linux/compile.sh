#!/bin/bash
cd "$1/src"
if [ $2 == "compile-so" ]
then
    echo "Not implemented"
    exit
fi
if [[ $2 =~ debug ]]
then
    name=WorldPartyDebug
    parameters="-g -gl -dDEBUG_MODE"
else
    name=WorldParty
    parameters="-O4 -Xs"
fi
if [[ $2 =~ compile ]]
then
    if [[ $2 =~ snap ]] && [ ! -f config-linux.inc ]
    then
        cp ../dists/linux/config-ubuntu.inc config-linux.inc
        cp ../dists/linux/paths-ubuntu.inc paths.inc
    fi
    target=../build/fpc-$(uname -m)-$(uname -s)/
    rm -rf $target ../game/$name
    mkdir -p $target
    fpc WorldParty.dpr -FE../game -FU$target $parameters -o$name
    if [ -f $target/link.res ]
    then
        mv $target/link.res ../res/
    fi
fi
if [ -f ../game/$name ] && [[ $2 =~ execute ]]
then
    ../game/$name -Benchmark
fi
echo $2
