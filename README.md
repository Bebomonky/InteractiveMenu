# InteractiveMenu

Current Version: 1.0 Release

A Framework for creating Menu's in Cortex Command

KeyCodes can be found here

https://github.com/cortex-command-community/Cortex-Command-Community-Project-Data/wiki/SDL-Keycode-and-Scancode-enum-values-in-Lua

You can use the GUI Editor to design your Menu (Not tested with 1.0 release)

https://github.com/cortex-command-community/Cortex-Command-Community-Project-GUI-Editor

## REQUIRED
- You need [ExtensionMan](https://github.com/Bebomonky/CC_ExtensionMan) installed in order to run this.
- Game Version 6.2.2 and above

# Installation
- Extract and put the folder `imenu` in your main CC Directory

![explorer_jOhpfsYA5M](https://github.com/Bebomonky/InteractiveMenu/assets/64169768/8e3802f3-2007-4f89-962b-8400ebfb3117)

- Put Cursor.rte in your Mods folder

# How to include the library
The first step is to include this at the very top of your script

This script is a part of the library that you will use to design your menus!
```
local igui = require("imenu/igui")
```

### Create
There are multiple ways to use this library in a Create function.

Based on which method you choose also applys to your Update functions!
- Regular way is to just written like this
```
self.Menu = require("imenu/core")
self.Menu:Initialize(self)
```

- Since your menu is fresh everytime, we can do this to keep the same instance of that menu
```
--Same Instance
self.Menu = require("imenu/core")
self.Menu:Initialize(self)
self.Menu.ForceOpen = true
self.Menu.OneInstance = true
```

### Update
There are multiple ways to use this library in a Update function

Based on which method you choose also applys to your Create functions!
```
--If you want your menu to run once
if self:NumberValueExists("MyMenu") then
	self.Menu:MessageEntity(self, "MyMenu", actor)
	self:RemoveNumberValue("MyMenu")
end
```

```
--If you are using the same instance, do this instead! No need for check
self.Menu:MessageEntity(self, "MyMenu")
```

Right below MessageEntity, you have to make sure to include the Update function for the menu library

- the Update argument requires a actor (doesn't work with devices)
```
if self:NumberValueExists("MyMenu") then
	self.Menu:MessageEntity(self, "MyMenu", actor)
	self:RemoveNumberValue("MyMenu")
end

--or

self.Menu:MessageEntity(self, "MyMenu")

if self.Menu:Update(actor) then
	self.Menu.Main:Update(actor) --Your menu called before DrawCursor
	self.Menu:DrawCursor(screen)
end
```
`self.Menu:DrawCursor(screen)` is a function that draws the cursor, it is best to have it below all your menus!

Documentation is W.I.P with the 1.0 system!
