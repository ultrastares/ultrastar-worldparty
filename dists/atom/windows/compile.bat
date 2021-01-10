@echo off
cd %1\src
if %2==compile-dll (
    rm -rf ..\game\webs\*.dll  ..\build
    mkdir ..\build
    fpc webSDK\ultrastares.dpr -o..\game\webs\ultrastares.dll -FU..\build -O4 -MObjFPC
    exit
)
if not %2==execute if not %2==execute-debug (
    if not %2==compile-debug if not %2==compile-debug-execute (
        set name=WorldParty
        set parameters=-O4 -Xs
    )
    if not %2==compile if not %2==compile-execute (
        set name=WorldPartyDebug
        set parameters=-g -gl -dDEBUG_MODE
    )
    call rm -rf ..\build ..\game\%%name%%.exe
    mkdir ..\build
    call fpc WorldParty.dpr -FE..\game -FU..\build %%parameters%% -o%%name%%.exe
    if exist ..\build\link.res (
        move /Y ..\build\link.res ..\res\link.res
    )
)
if not %2==compile if not %2==compile-debug (
    if exist ..\game\%name%.exe  start "" ../game/%name% -Benchmark
)
echo %2
