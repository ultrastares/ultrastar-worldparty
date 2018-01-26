#!/bin/bash
cd "$1/src"
if [ $2 != "execute" ]
then
    processor=$(uname -m)
    platform=$(uname -s)
    target=../build/fpc-$processor-${platform,,}/
    mkdir -p $target
    rm -rf ../game/WorldParty* $target/*.*o $target/*.a $target/*.ppu $target/*.rsj
    fpc WorldParty.dpr -FE../game -FU$target -O4 -CfSSE3
fi
if [ -f $target/link.res ]
then
    mv $target/link.res ../res/
fi
if [ -f ../game/WorldParty ]
then
    if [ $2 == "compile-execute" ] || [ $2 == "execute" ]
    then
        ../game/WorldParty -Benchmark
    fi
fi
