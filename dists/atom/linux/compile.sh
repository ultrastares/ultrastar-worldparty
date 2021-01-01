#!/bin/bash
cd "$1/src"
if [ $2 == "compile-so" ]
then
    echo "Not implemented"
    exit
fi
if [ $2 != "execute" ]
then
    processor=$(uname -m)
    platform=$(uname -s)
    target=../build/fpc-$processor-${platform,,}/
    if [ $2 == "compile" ] || [ $2 == "compile-execute" ]
    then
        name=WorldParty
        parameters=-O4 -Xs
    else
        name=WorldPartyDebug
        parameters=-g -gl -dDEBUG_MODE -Si -Sg -Sc -v0Binwe
    fi
    rm -rf $target ../game/$name
    mkdir -p $target
    fpc WorldParty.dpr -FE../game -FU$target -o$name
    if [ -f $target/link.res ]
    then
        mv $target/link.res ../res/
    fi
fi
if [ -f ../game/$name ] && [ $2 != "compile" ] && [ $2 != "compile-debug" ]
then
    ../game/$name -Benchmark
fi
