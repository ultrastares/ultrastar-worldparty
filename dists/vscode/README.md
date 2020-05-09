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

## Configure code formatter engine and global path

If you don't configure anything a notification will appear when your edit your first .pas file asking you about define "pascal.formatter.engine". 
To fix it you must enter in VSCode settings, type "pascal" in the top search box.
Then select ptop in Pascal > Formatter: Engine and add the path to Pascal > Formater: Engine Path. You can find it in the same route that your fpc executable, for example in Windows was in the default folder `C:\FPC\[number_of_your_version]\bin\i386-win32\ptop.exe`

**But don't use it to format any file** because this project use a different format. Maybe in the future we could add our formatter config.

And the other notifications it's about code navigation. You can follow the instructions to install all things to activate it or press the "Dont' show again" button, it's your choice :).