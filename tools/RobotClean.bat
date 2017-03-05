@echo off
REM
REM It cleans temp files from project 
REM

echo Cleaning files from compiler
del /Q "..\src\WorldParty.res"
del /Q /S "..\*.lps"
RD /Q /S "..\build"
RD /Q /S "..\src\backup"

echo Cleaning files from installer
RD /Q /S "..\installer\dist"

echo Cleaning files from game
del /Q "..\game\error.log" "..\game\avatar.db" "..\game\ultrastar.db" "..\game\cover.db" "..\game\config.ini" "..\game\WorldParty.exe" 

echo Cleaning files from editor
del /Q /S "..\*.bak"

echo Done
