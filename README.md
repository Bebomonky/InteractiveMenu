# InteractiveMenu
A Framework for creating Menu's in Cortex Command

# How to include the Framework
At the top of your Menu file, be sure to include

```bash
dofile("[B]InteractiveMenu.rte/Script/InteractiveMenu.lua")
```
# How to Start
If your device and or actor has a script
You can mention it at the top of your file
Example: `dofile("modname.rte/path/Menu.lua")`

Initialize your table within your menu file below the dofile
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

```bash
InteractiveMenu.PersistentMenu(self, actor, mouse, menu)
```

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
		if device:GetNumberValue("MyNumberValue") == 1 then
			device:SetNumberValue("MyNumberValue", 0)
			InteractiveMenu.Engineer.Menu(self, actor, menu)
			InteractiveMenu.CreateMenuCursor(self, actor, mouse, PATH)
		end
```
or
```
		if UInputMan:KeyPressed(Key.KeyCode) then
			InteractiveMenu.Engineer.Menu(self, actor, menu)
			InteractiveMenu.CreateMenuCursor(self, actor, mouse, PATH)
		end
```

KeyCodes can be found here
```bash
https://github.com/cortex-command-community/Cortex-Command-Community-Project-Data/wiki/SDL-Keycode-and-Scancode-enum-values-in-Lua
```
