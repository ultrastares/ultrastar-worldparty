UltraStar WorldParty with Visual Studio Code
=================================================

To compile UltraStar WorldParty using Visual Studio Code editor (https://code.visualstudio.com/) you must install in it the Pascal extension (https://github.com/alefragnani/vscode-language-pascal).

You must also have installed Free Pascal in your system (https://www.freepascal.org).

After install all things you must copy tasks.json file to the .vscode folder in your root project path and merge the keybindings_worldparty.json with your own keybinding.json (more info https://code.visualstudio.com/docs/getstarted/keybindings). And now you can press:
- F9 to compile
- Ctrl+F9 to compile in debug mode
- F10 to compile and execute the game
- Ctrl+F10 to compile in debug mode and execute the game
- Ctrl+F11 to only execute without compile

If all works fine the executable will appear in game folder and link.res file will be copied to res folder.
