@echo off
cd %1\src
rm -rf units\*.*o units\*.a units\*.ppu units\*.rsj
fpc WorldParty.dpr -FE../game -FUunits
mv units\link.res ..\res\
IF %2=="execute" (
    start ../game/WorldParty
)
