# InteractiveMenu
A Framework for creating Menu's in Cortex Command

KeyCodes can be found here

https://github.com/cortex-command-community/Cortex-Command-Community-Project-Data/wiki/SDL-Keycode-and-Scancode-enum-values-in-Lua

You can use the GUI Editor to design your Menu (Not tested with 1.0 release)

https://github.com/cortex-command-community/Cortex-Command-Community-Project-GUI-Editor

# How to include the Framework
at the top of your .lua file be sure to include

```bash
local igui = require("imenu/igui")
```

# How to Start
If your device and or actor has a script
You can mention this in your Create function
Example:
```bash
self.Menu = require("imenu/core")
self.Menu:Initialize(self)
```

In your update function be sure to include this

the Update argument requires a actor (doesn't work with devices)
```bash
self.Menu:Update(actor)
```

Documentation is W.I.P with the 1.0 system!
