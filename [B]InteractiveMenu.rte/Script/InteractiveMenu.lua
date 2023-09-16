InteractiveMenu = {}

--Create the Table i.e InteractiveMenu.Child
function InteractiveMenu.InitializeCoreTable(Child)
	InteractiveMenu[Child] = {}
end

-----------------------------------------------------------------------------------------
-- Cursor
-----------------------------------------------------------------------------------------
function InteractiveMenu.CreateCursor(self, actor, mouse, PATH)
	self.Mouse = actor.Pos
	self.Mid = actor.Pos
	self.ResX2 = FrameMan.PlayerScreenWidth / 1.5
	self.ResY2 = FrameMan.PlayerScreenHeight / 1.5

	self[mouse] = CreateMOSRotating(PATH)
	self[mouse].Pos = self.Mouse + Vector(4.5, 10)
	self[mouse].HitsMOs = false
	self[mouse].GetsHitByMOs = false
end
function InteractiveMenu.UpdateCursor(self, actor)
	if self.Mouse == nil then return end

	--If User has Mouse then we mouse, if not we Xbox the 360
	if actor:GetController():IsMouseControlled() == true then
		self.Mouse = self.Mouse + UInputMan:GetMouseMovement(InteractiveMenu.GetScreen(actor))
	else
		if actor:GetController():IsState(Controller.MOVE_LEFT) then
			self.Mouse = self.Mouse + Vector(-5,0)
		end

		if actor:GetController():IsState(Controller.MOVE_RIGHT) then
			self.Mouse = self.Mouse + Vector(5,0)
		end

		if actor:GetController():IsState(Controller.MOVE_UP) then
			self.Mouse = self.Mouse + Vector(0,-5)
		end

		if actor:GetController():IsState(Controller.MOVE_DOWN) then
			self.Mouse = self.Mouse + Vector(0,5)
		end
	end

	-- Don't let the cursor leave the screen
	if self.Mouse.X - self.Mid.X < -self.ResX2 then
		self.Mouse.X = self.Mid.X - self.ResX2
	end

	if self.Mouse.Y - self.Mid.Y < -self.ResY2 then
		self.Mouse.Y = self.Mid.Y - self.ResY2
	end

	if self.Mouse.X - self.Mid.X > self.ResX2 - 10 then
		self.Mouse.X = self.Mid.X + self.ResX2 - 10
	end

	if self.Mouse.Y - self.Mid.Y > self.ResY2 - 10 then
		self.Mouse.Y = self.Mid.Y + self.ResY2 - 10
	end
end

function InteractiveMenu.DrawMenuCursor(self, actor, mouse)
	if self.Mouse == nil then return end
	mouse.Pos = self.Mouse + Vector(5, 10)
	PrimitiveMan:DrawBitmapPrimitive(InteractiveMenu.GetScreen(actor), mouse.Pos, mouse, 0, 0)
end
-----------------------------------------------------------------------------------------
-- Menu
-----------------------------------------------------------------------------------------
function InteractiveMenu.CreateMenu(self, actor, mouse, PATH, table)
	InteractiveMenu.CreateCursor(self, actor, mouse, PATH)

    InteractiveMenu.TableChecker(self, table)
end
function InteractiveMenu.UpdateMenu(self, actor, mouse, table)
	if actor:IsPlayerControlled() then
		if not self.Mouse then return end

		if actor.Health <= 0 then -- For some reason this is better than self:Dead()
			InteractiveMenu.Delete(self, mouse)
		end
		
		if self[mouse] then
			InteractiveMenu.UpdateCursor(self, actor)
			InteractiveMenu.PersistentMenu(self, actor, self[mouse], table)
			InteractiveMenu.FreezeActor(actor)
			--InteractiveMenu.FreezeCamera(actor)
			InteractiveMenu.DrawMenuCursor(self, actor, self[mouse])
		end
	end
end
-----------------------------------------------------------------------------------------
-- Player
-----------------------------------------------------------------------------------------
function InteractiveMenu.FreezeActor(actor)
	local ControlState = {
		Controller.MOVE_UP,
		Controller.MOVE_DOWN,
		Controller.BODY_JUMPSTART,
		Controller.BODY_JUMP,
		Controller.BODY_CROUCH,
		Controller.MOVE_LEFT,
		Controller.MOVE_RIGHT,
		Controller.MOVE_IDLE,
		Controller.MOVE_FAST,
		Controller.AIM_UP,
		Controller.AIM_DOWN,
		Controller.AIM_SHARP,
		Controller.WEAPON_FIRE,
		Controller.WEAPON_RELOAD,
	}
	for _, input in ipairs(ControlState) do
		actor:GetController():SetState(input, false)
	end
end
function InteractiveMenu.Player()
	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		if ActivityMan:GetActivity():PlayerActive(player) and ActivityMan:GetActivity():PlayerHuman(player) then
			return player
		end
	end
end
function InteractiveMenu.GetScreen(actor)
	local ctrl = actor:GetController()
	local Player = InteractiveMenu.Player()
	return ActivityMan:GetActivity():ScreenOfPlayer(ctrl.Player)
end
-----------------------------------------------------------------------------------------
-- Table Information
-----------------------------------------------------------------------------------------
function InteractiveMenu.TableChecker(self, table)
	if self[table] then
		InteractiveMenu.InitializeTable(self, table)
		if SettingsMan.PrintDebugInfo then
			local MenuSuccessMessage1 = "Your " .. table .. " Has been Initialized!"
			print(MenuSuccessMessage1)
		end
	else
		local MenuErrorMessage1 = "Your" .. " '" .. table .. "' " .. "has failed to be initialized"
		local MenuErrorMessage2 = "\nNOTICE: Is your table nil? Does it exist?'"
		error(MenuErrorMessage1 .. MenuErrorMessage2)
	end
end
function InteractiveMenu.InitializeTable(self, table)
    InteractiveBox = {}
	if SettingsMan.PrintDebugInfo then
		print("\n--------------------------------------------------------\nYour Resolution: {" .. FrameMan.PlayerScreenWidth .. ", " .. FrameMan.PlayerScreenHeight .. "}\n--------------------------------------------------------")
	end

	local Resolution = Vector(FrameMan.PlayerScreenWidth / 1280, FrameMan.PlayerScreenHeight / 720)

    for _, Parent in ipairs(self[table]) do
        InteractiveBox[Parent.Name] = {}

        local ParentPos = Vector(Parent.PosX, Parent.PosY)

		ParentPos.X = ParentPos.X * Resolution.X
		ParentPos.Y = ParentPos.Y * Resolution.Y
		
        local ParentWidth = Parent.Width
        local ParentHeight = Parent.Height 

        InteractiveBox[Parent.Name] = Box(ParentPos, ParentWidth, ParentHeight)

		if SettingsMan.PrintDebugInfo then
			print("Parent: " .. Parent.Name .. " Pos: " .. tostring(ParentPos) .. " Size: {" .. ParentWidth .. ", " .. ParentHeight .. "}")
		end
        if Parent.Child then
            for _, Child in ipairs(Parent.Child) do

                local Frame = InteractiveBox[Parent.Name]

                local CBox = Child.ControlType == "COLLECTIONBOX"
                local CButton = Child.ControlType == "BUTTON"
                local CLabel = Child.ControlType == "LABEL"

                if CBox or CButton then
                    local ChildPos = Vector(Child.PosX, Child.PosY)
                    local ChildWidth = Child.Width
                    local ChildHeight = Child.Height

                    local NewPos = ParentPos + ChildPos
                    InteractiveBox[Child.Name] = Box(NewPos, ChildWidth, ChildHeight)

					if SettingsMan.PrintDebugInfo then
						print("Child: " .. Child.Name .. " Pos: " .. tostring(ChildPos) .. " Size: {" .. ChildWidth .. ", " .. ChildHeight .. "}")
					end
                end
				if CLabel then
					local ChildPos = Vector(Child.BoxPosX, Child.BoxPosY)
                    local ChildWidth = Child.Width
                    local ChildHeight = Child.Height

                    local NewPos = ParentPos + ChildPos
                    InteractiveBox[Child.Name] = Box(NewPos, ChildWidth, ChildHeight)

					if SettingsMan.PrintDebugInfo then
						print("Child: " .. Child.Name .. " Text Pos: " .. tostring(Vector(Child.TextPosX, Child.TextPosY)) .. " Box Pos: " .. tostring(ChildPos) .. " Box Size: {" .. ChildWidth .. ", " .. ChildHeight .. "}")
					end
				end
            end
        end
    end
end
function InteractiveMenu.GetBoxName(Name)
    if InteractiveBox[Name] then
        return InteractiveBox[Name]
    else
        return error("expected box string &name" .. " '" .. tostring(Name) .. "' (a nil value)")
    end
end
function InteractiveMenu.GetChildName(self, table, ChildName)
	for _, Parent in ipairs(self[table]) do
		if Parent.Child then
			for _, Child in ipairs(Parent.Child) do
                if Child.Name == ChildName then
                    return Child
                end
            end
        end
    end
    return error("expected child string &name" .. " '" .. tostring(ChildName) .. "' (a nil value)")
end
-----------------------------------------------------------------------------------------
-- GUI
-----------------------------------------------------------------------------------------
function InteractiveMenu.ScreenPos(self, actor, PosX, PosY)
	local Screen = InteractiveMenu.GetScreen(actor)
	local Offset = Vector(
		CameraMan:GetOffset(Screen).X + PosX,
		CameraMan:GetOffset(Screen).Y + PosY
	)
	return Offset
end
function InteractiveMenu.PersistentMenu(self, actor, mouse, table)
	for _, Parent in ipairs(self[table]) do
		local Frame = InteractiveBox[Parent.Name]

		local RootBox = Parent.ControlType == "COLLECTIONBOX"

		if RootBox then
			local cornerX, cornerY = Frame.Corner.X, Frame.Corner.Y
			local width, height = Frame.Width, Frame.Height
			local topleftPos = InteractiveMenu.ScreenPos(self, actor, cornerX, cornerY)
			local bottomRightPos = topleftPos + Vector(width - 4.5, height - 4.5)
			if Parent.Visible then
				PrimitiveMan:DrawBoxFillPrimitive(InteractiveMenu.GetScreen(actor), topleftPos, bottomRightPos, Parent.Color)
			end
			Frame = Box(topleftPos, width, height )
		end
		if Parent.Child then
			for _, Child in ipairs(Parent.Child) do

				local Panel = InteractiveBox[Child.Name]
				local CBox = Child.ControlType == "COLLECTIONBOX"
				local CButton = Child.ControlType == "BUTTON"
				local CLabel = Child.ControlType == "LABEL"

				--If we only need to Draw the Box we do this
				if CBox or CButton then
					local cornerX, cornerY = Panel.Corner.X, Panel.Corner.Y
					local width, height = Panel.Width, Panel.Height
					local topleftPos = InteractiveMenu.ScreenPos(self, actor, cornerX, cornerY)
					local bottomRightPos = topleftPos + Vector(width - 4.5, height - 4.5)
					if Child.Visible then
						PrimitiveMan:DrawBoxFillPrimitive(InteractiveMenu.GetScreen(actor), topleftPos, bottomRightPos, Child.Color)
                        Panel = Box(topleftPos, width, height ) --! Reverse this if it causes an issue!
                    else
                        Panel = nil
                    end

                    if CButton then
                        if Child.Visible then
                            if Panel:IsWithinBox(mouse.Pos - Vector(0,1)) then
                                Child.OnHover = true
                                if Child.IsClickable then
                                    Child.Clicked = true
                                end
                                if Child.ToolTip then
                                    local ToolTipPos = Vector(0, 0)
                                    local Anchor = string.lower(Child.AnchorTip)
                                    if Anchor == "up" then
                                        ToolTipPos = Vector(Panel.Width * 0.02, -9)
                                    elseif Anchor == "down" then
                                        ToolTipPos = Vector(Panel.Width * 0.02, Panel.Height - 3)
                                    elseif Anchor == "left" then
                                        ToolTipPos = Vector(-32, Panel.Height * 0.3)
                                    elseif Anchor == "right" then
                                        ToolTipPos = Vector(Panel.Width - 2, Panel.Height * 0.3)
                                    end
                                    PrimitiveMan:DrawTextPrimitive(InteractiveMenu.GetScreen(actor), Panel.Corner + ToolTipPos, Child.ToolTip, Child.isSmall, 0)
                                end
                                if Child.Color2 then
                                    PrimitiveMan:DrawBoxFillPrimitive(InteractiveMenu.GetScreen(actor), topleftPos, bottomRightPos, Child.Color2)
                                end
                            else
                                Child.OnHover = false
                                if Child.IsClickable then
                                    if Child.Clicked then
                                        Child.Clicked = false
                                    end
                                end
                            end
                            if Child.CallBack then
                                Child.CallBack()
                            end
                            if Child.Clicked then
                                local Clicked = actor:GetController():IsState(Controller.WEAPON_FIRE)
                                if (Clicked and Child.OnClick) and not self.ConfirmClick then
                                    Child.OnClick()
                                    self.ConfirmClick = true
                                elseif not Clicked then
                                    self.ConfirmClick = false
                                end
                            end
                        end
                    end
				end

				--If we only need to Draw the Text we do this
				if CLabel then
					if Child.Visible then
						if Child.CallBack then
							Child.Text = Child.CallBack()
						end
						local TextPos = Vector(Child.TextPosX, Child.TextPosY)
						local BoxPos = InteractiveMenu.ScreenPos(self, actor, Panel.Corner.X, Panel.Corner.Y)
						--PrimitiveMan:DrawBoxFillPrimitive(InteractiveMenu.GetScreen(actor), BoxPos, BoxPos + Vector(Panel.Width - 4.5, Panel.Height - 4.5), 0)
						PrimitiveMan:DrawTextPrimitive(InteractiveMenu.GetScreen(actor), BoxPos + TextPos, Child.Text, Child.isSmall, 0)
					end
				end
			end
		end
	end
end
function InteractiveMenu.Destroy(self, mouse)
    if self[mouse] and not self[mouse].ToDelete then
		self[mouse].ToDelete = true
		self.Mouse = nil
	end
end

function InteractiveMenu.Delete(self, mouse) 
    if self[mouse] and not self[mouse].ToDelete then
		self[mouse].ToDelete = true
		self.Mouse = nil
	end
end
--[[
--? E L E M E N T S
--? You only need to call these Elements once, it'll do some checks to prevent it from falling apart
Name - string
PosX - number
PosY - number
X1 - TextPosX - number
X2 - TextPosY - number
Y1 - BoxPosX - number
Y2 - BoxPosY - number
Width - number
Height - number
PALETTE -- number (Palette Index)
PALETTE2 -- Change Color on Hover [Only for Buttons]
Text - string
ToolTip - string
DIRECT - string ("Up", "down", "left", "right" Anchoring your ToolTip)
isSmall - bool
Visible - bool
IsClickable - bool
Clicked - bool (Default to false) [Only for Buttons]

Child - Subtables (Root is our main)
--? F U N C T I O N S
ONE_TIME_FUNCTION -- Happens once everytime
CALLBACK -- Always Updating
]]

function InteractiveMenu.Root(N, X, Y, W, H, PALETTE, VISIBLE, Table)
	return {
		ControlType = "COLLECTIONBOX",
		Name = N,
		PosX = X,
		PosY = Y,
		Width = W,
		Height = H,
		Color = PALETTE,
		Visible = VISIBLE,
		Child = Table,
	}
end

function InteractiveMenu.Box(N, X, Y, W, H, PALETTE, VISIBLE)
	return {
		ControlType = "COLLECTIONBOX",
		Name = N,
		PosX = X,
		PosY = Y,
		Width = W,
		Height = H,
		Color = PALETTE,
		Visible = VISIBLE,
	}
end

function InteractiveMenu.Button(N, X, Y, W, H, PALETTE1, PALETTE2, CLICKABLE, VISIBLE, TIP, DIRECT, SMALL, HOVER, ONE_TIME_FUNCTION, CALLBACK)
	return {
		ControlType = "BUTTON",
		Name = N,
		PosX = X,
		PosY = Y,
		Width = W,
		Height = H,
		Color = PALETTE1,
        Color2 = PALETTE2,
		IsClickable = CLICKABLE,
		Clicked = false,
		Visible = VISIBLE,
		ToolTip = TIP,
		AnchorTip = DIRECT,
		isSmall = SMALL,
        OnHover = HOVER,
		OnClick = ONE_TIME_FUNCTION,
		CallBack = CALLBACK
	}
end

function InteractiveMenu.Label(N, X1, Y1, X2, Y2, W, H, TXT, SMALL, VISIBLE, CALLBACK)
	return {
		ControlType = "LABEL",
		Name = N,
		TextPosX = X1,
		TextPosY = Y1,
		BoxPosX = X2,
		BoxPosY = Y2,
		Width = W,
		Height = H,
		Text = TXT,
		isSmall = SMALL,
		Visible = VISIBLE,
		CallBack = CALLBACK,
	}
end