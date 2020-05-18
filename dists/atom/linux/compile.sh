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
    rm -rf ../game/WorldParty* $target
    mkdir -p $target
    if [ $2 == "compile-debug" ] || [ $2 == "compile-debug-execute" ]
    then
        fpc WorldParty.dpr -FE../game -FU$target -g -gl -dDEBUG_MODE -Si -Sg -Sc -v0Binwe
    else
        fpc WorldParty.dpr -FE../game -FU$target -O4 -Xs
    fi
    if [ -f $target/link.res ]
    then
        mv $target/link.res ../res/
    fi
fi
if [ -f ../game/WorldParty ]
then
    ../game/WorldParty -Benchmark if [ $2 == "compile-debug-execute" ] then -Debug fi
fi
