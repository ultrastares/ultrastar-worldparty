UltraStar Deluxe WorldParty with Atom (by Github)
=================================================

To compile USDX WorldParty using Atom editor developed by Github (https://atom.io) you must install in it at least this two packages:
- Pascal language support in Atom (language-pascal https://atom.io/packages/language-pascal) to syntax highlighting.
- Atom Build package (atom-build https://github.com/noseglid/atom-build) to compile (and optionally execute) the project.

You must also have installed Free Pascal in your system (https://www.freepascal.org).

After install all things you must copy, depend of your system, the .atom-build.json file to the root project path. Restart Atom and now you can press:
- F9 to compile
- Ctrl+F9 to compile in debug mode
- F10 to compile and execute the game
- Ctrñ+F10 to compile in debug mode and execute the game
- Ctrl+F11 to only execute without compile

If all works fine the executable will appear in game folder and link.res file will be copied to res folder.
