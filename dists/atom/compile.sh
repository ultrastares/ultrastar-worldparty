#!/bin/bash
cd "$1/src"
if [ $2 != "execute" ]
then
    rm -rf ../game/WorldParty* units/*.*o units/*.a units/*.ppu units/*.rsj
    fpc WorldParty.dpr -FE../game -FUunits -O4 -CfSSE3
fi
if [ -f units\link.res ]
then
    mv units/link.res ../res/
fi
if [ ! -f ../game/WorldParty ]
then
    if [ $2 == "compile-execute" ] || [ $2 == "execute" ]
    then
        start ../game/WorldParty -Benchmark
    fi
fi
