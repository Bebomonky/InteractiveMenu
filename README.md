# InteractiveMenu
A Framework for creating Menu's in Cortex Command

KeyCodes can be found here

https://github.com/cortex-command-community/Cortex-Command-Community-Project-Data/wiki/SDL-Keycode-and-Scancode-enum-values-in-Lua

You can use the GUI Editor to design your Menu

Only CollectionBox, Button, Label requires manual Labor

https://github.com/cortex-command-community/Cortex-Command-Community-Project-GUI-Editor

# How to include the Framework
At the top of your Menu file, be sure to include

```bash
package.path = package.path .. ";Mods/[B]InteractiveMenu.rte/Script/?.lua";
require("InteractiveMenu")
```

# How to Start
If your device and or actor has a script
You can mention it at the top of your file
Example:
```bash
package.path = package.path .. ";Mods/yourmod.rte/PATH/?.lua";
require("MyMenuFile")
```

Initialize your table within your menu file below the require
Example: `InteractiveMenu.InitializeCoreTable("MyMenu")`

# Current Functions
Create and Update must be included into your device and or actor's script
Example:

```bash
function Create(self)
	InteractiveMenu.yourtable.Create(self)
end
```
```bash
function Create(self)
	InteractiveMenu.yourtable.Update(self, actor)
end
```

`PATH` is for your `CreateMOSRotating` Example: `"modname.rte/MyMouse"`

`mouse` is for the name your `mouse` Example: `"MyMouseName"`, you can then call it by doing `self["MyMouseName"]`

`menu` is for the name of your `menu`, this will be your table, you can then call it by doing `self["MyMenuTable"]`

You must include these function in your `InteractiveMenu.yourtable.Update(self, actor)`


```bash
InteractiveMenu.yourtable.Menu(self, actor, menu)
```

This function must be at the very bottom of your .Update Function
```bash
InteractiveMenu.PersistentMenu(self, actor, mouse, menu)
```

This function must be below your .Menu function
```bash
InteractiveMenu.CreateMenuCursor(self, actor, mouse, PATH)
```

You can include one of these functions to get out of the menu (Recommended to use `SwitchToActor` if you are going to have a CloseButton)

```bash
InteractiveMenu.Destroy(self, mouse)
```
```bash
InteractiveMenu.Delete(self, mouse)
```

Ensure that your menu is created once!
Example:

```
InteractiveMenu.yourtable.Update = function(self, actor, device)
		if device:GetNumberValue("MyNumberValue") == 1 then
			device:SetNumberValue("MyNumberValue", 0)
			InteractiveMenu.Engineer.Menu(self, actor, menu)
			InteractiveMenu.CreateMenuCursor(self, actor, mouse, PATH)
		end
		InteractiveMenu.PersistentMenu(self, actor, mouse, menu)
end
```
or
```
InteractiveMenu.yourtable.Update = function(self, actor)
		if UInputMan:KeyPressed(Key.KeyCode) then
			InteractiveMenu.Engineer.Menu(self, actor, menu)
			InteractiveMenu.CreateMenuCursor(self, actor, mouse, PATH)
		end
		InteractiveMenu.PersistentMenu(self, actor, mouse, menu)
end
```
