@echo off
cd %1\src
rm -rf units\*.*o units\*.a units\*.ppu units\*.rsj
fpc WorldParty.dpr -FE../game -FUunits
if exist "units\link.res" (
    mv units\link.res ..\res\
)
if %2=="execute" (
    start ../game/WorldParty
)
