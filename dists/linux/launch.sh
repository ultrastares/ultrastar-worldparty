#!/bin/sh
# Launch script for UltraStar Deluxe
# Set $DEBUGGER to launch the game with a debugger.

# Change to game directory
GAMEPATH="`readlink -f "$0"`"
cd "`dirname "$GAMEPATH"`"

# Set path to libraries and binary
BIN=./WorldParty
LIBPATH=./lib

# Run the game, (optionally) with the debugger
LD_LIBRARY_PATH="$LIBPATH:$LD_LIBRARY_PATH" $DEBUGGER $BIN $@

#Generate a launcher in desktop
cat prueba > "/usr/share/applications/Ultrastar Deluxe WorldParty.Desktop"

# Get the game's exit code, and return it.
e=$?
exit $e
