#!/bin/bash
cd "$1/src"
if [ $2 != "execute" ]
then
    processor=$(uname -m)
    platform=$(uname -s)
    target=../build/fpc-$processor-${platform,,}/
    rm -rf ../game/WorldParty* $target
    mkdir -p $target
    if [ $2 == "compile-debug" ] || [ $2 == "compile-debug-execute" ]
    then
        fpc WorldParty.dpr -FE../game -FU$target -g -gh -gl -dDEBUG_MODE -Si -Sg -Sc -v0Binwe
    else
        fpc WorldParty.dpr -FE../game -FU$target -O4 -Xs
    fi
    if [ -f $target/link.res ]
    then
        mv $target/link.res ../res/
    fi
fi
if [ -f ../game/WorldParty ] && [ $2 != "compile-debug" ] && [ $2 != "compile" ]
then
    if [ $2 == "compile-debug-execute" ]
    then
        ../game/WorldParty -Benchmark -Debug
    else
        ../game/WorldParty -Benchmark
    fi
fi
