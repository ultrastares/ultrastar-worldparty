@echo off
cd %1\src
if %2=="compile-dll" (
    rm -rf ..\game\webs\*.dll  ..\build
    mkdir ..\build
    fpc webSDK\ultrastares.dpr -o..\game\webs\ultrastares.dll -FU..\build -O4 -MObjFPC
    exit
)
if not %2=="execute" (
    rm -rf ..\game\WorldParty* ..\build
    mkdir ..\build
    if not %2=="compile-debug" if not %2=="compile-debug-execute" (
        fpc WorldParty.dpr -FE..\game -FU..\build -O4 -Xs
    )
    if not %2=="compile" if not %2=="compile-execute" (
        fpc WorldParty.dpr -FE..\game -FU..\build -g -gl -gh -dDEBUG_MODE
    )
    if exist "..\build\link.res" (
        move /Y ..\build\link.res ..\res\link.res
    )
)
if exist "..\game\WorldParty.exe" (
    if not %2=="compile" if not %2=="compile-debug" start "" ../game/WorldParty -Benchmark
)
echo %2
