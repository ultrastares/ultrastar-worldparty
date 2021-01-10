UltraStar WorldParty with Visual Studio Code
=================================================

To compile UltraStar WorldParty using Visual Studio Code editor (https://code.visualstudio.com/) you must install in it the OmniPascal extension (https://marketplace.visualstudio.com/items?itemName=Wosi.omnipascal).

You must also have installed Free Pascal in your system (https://www.freepascal.org). In Debian/Ubuntu you can do it using `sudo apt install fp-compiler-3.2.0`.

And finally, if you are in Debian/Ubuntu, you must execute './install.sh' to get the dependencies, compile and add a shorcut to execute the game. On other systems you must do the same manually.

After install all things you must copy tasks.json file to the .vscode folder in your root project path and merge the keybindings_worldparty.json with your own keybinding.json (more info https://code.visualstudio.com/docs/getstarted/keybindings). And now you can press:
- F9 to compile
- Ctrl+F9 to compile in debug mode
- F10 to compile and execute the game
- Ctrl+F10 to compile in debug mode and execute the game
- Ctrl+F11 to only execute without compile

If all works fine the executable will appear in game folder and link.res file will be copied to res folder.
