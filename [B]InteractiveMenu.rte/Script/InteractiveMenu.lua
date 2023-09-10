InteractiveMenu = {}
InteractiveBox = {}

--Create the Table i.e InteractiveMenu.Child
function InteractiveMenu.InitializeCoreTable(Child)
	InteractiveMenu[Child] = {}
end

-----------------------------------------------------------------------------------------
-- Cursor
-----------------------------------------------------------------------------------------
function InteractiveMenu.CreateMenuCursor(self, actor, mouse, PATH)
	self.INCursor = CreateActor("[B]InteractiveMenu.rte/Interactive Static Actor")
	self.INCursor.Pos = actor.Pos
	self.INCursor.Team = actor.Team
	
	self.INCursor.IgnoresTeamHits = true
	self.INCursor.HUDVisible = false

	MovableMan:AddActor(self.INCursor)
	ActivityMan:GetActivity():SwitchToActor(self.INCursor, actor.Team, actor.Team)

	self.Mouse = self.INCursor.Pos
	self.Mid = self.INCursor.Pos
	self.ResX2 = FrameMan.PlayerScreenWidth / 2
	self.ResY2 = FrameMan.PlayerScreenHeight / 2

	self[mouse] = CreateMOSRotating(PATH)
	self[mouse].Pos = self.Mouse + Vector(4.5, 10)
	self[mouse].HitsMOs = false
	self[mouse].GetsHitByMOs = false
end

function InteractiveMenu.UpdateMenuCursor(self, actor)
	self.INCursor.Pos = actor.Pos -- Never leave the actor that we are controlling!

	if self.Mouse == nil then return end

	--If User has Mouse then we mouse, if not we Xbox the 360
	if self.INCursor:GetController():IsMouseControlled() == true then
		self.Mouse = self.Mouse + UInputMan:GetMouseMovement(ActivityMan:GetActivity():ScreenOfPlayer(actor:GetController().Player))
	else
		if self.INCursor:GetController():IsState(Controller.MOVE_LEFT) then
			self.Mouse = self.Mouse + Vector(-5,0)
		end

		if self.INCursor:GetController():IsState(Controller.MOVE_RIGHT) then
			self.Mouse = self.Mouse + Vector(5,0)
		end

		if self.INCursor:GetController():IsState(Controller.MOVE_UP) then
			self.Mouse = self.Mouse + Vector(0,-5)
		end

		if self.INCursor:GetController():IsState(Controller.MOVE_DOWN) then
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
	mouse.Pos = self.Mouse + Vector(5, 12)
	PrimitiveMan:DrawBitmapPrimitive(ActivityMan:GetActivity():ScreenOfPlayer(actor:GetController().Player), mouse.Pos, mouse, 0, 0)
end

function InteractiveMenu.FreezeActor(self, actor)
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

-----------------------------------------------------------------------------------------
-- Table Information
-----------------------------------------------------------------------------------------
function InteractiveMenu.InitializeTable(self, table)

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
					Child.PosX = Child.PosX + Parent.PosX * Resolution.X
                    Child.PosY = Child.PosY + Parent.PosY * Resolution.Y

					--[[
					local ChildPos = Vector(Child.PosX, Child.PosY)
                    InteractiveBox[Child.Name] = Box(ChildPos, Child.Width, Child.Height)
					]]

					if SettingsMan.PrintDebugInfo then
						print("Child: " .. Child.Name .. " Pos: {" .. Child.PosX .. ", " .. Child.PosY .. "}")
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
        return error("expected box string &name" .. " '" .. Name .. "' (a nil value)")
    end
end

function InteractiveMenu.PersistentMenu(self, actor, mouse, table)
	if self.INCursor and IsActor(self.INCursor) then
		self.INCursor = ToActor(self.INCursor)

		if self.INCursor then
			if self.INCursor:IsPlayerControlled() then
				if actor.Health <= 0 then -- For some reason this is better than self:Dead()
					InteractiveMenu.Delete(self, mouse)
				end
			else
				InteractiveMenu.Delete(self, mouse)
				self.Activity:SwitchToActor(actor, actor.Team, actor.Team)
			end
		end

		if self[mouse] then
			InteractiveMenu.UpdateMenuCursor(self, actor)
			InteractiveMenu.UpdateMenu(self, actor, self[mouse], table)
			InteractiveMenu.FreezeActor(self, actor)
			InteractiveMenu.DrawMenuCursor(self, actor, self[mouse])
		end
	end
end

function InteractiveMenu.Destroy(self, mouse)
    if self.INCursor and not self.INCursor.ToDelete then
        self.INCursor.ToDelete = true
        self[mouse].ToDelete = true
        self.Mouse = nil
    end
end

function InteractiveMenu.Delete(self, mouse) 
    if not self.INCursor.ToDelete then
        self.INCursor.ToDelete = true
        self[mouse].ToDelete = true
        self.Mouse = nil
    end
end

-----------------------------------------------------------------------------------------
-- GUI
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
		local MenuErrorMessage2 = "\nNOTICE: Make sure that you have created your table above 'InteractiveMenu.TableChecker()'"
		error(MenuErrorMessage1 .. MenuErrorMessage2)
	end
	return Root, Button, Label
end

function InteractiveMenu.ScreenPos(self, PosX, PosY)
	local Screen = Vector(
		CameraMan:GetOffset(self.Team).X + PosX,
		CameraMan:GetOffset(self.Team).Y + PosY
	)
	return Screen
end

function InteractiveMenu.UpdateMenu(self, actor, mouse, table)
	for _, Parent in ipairs(self[table]) do
		local Frame = InteractiveBox[Parent.Name]

		local RootBox = Parent.ControlType == "COLLECTIONBOX"

		if RootBox then
			local cornerX, cornerY = Frame.Corner.X, Frame.Corner.Y
			local width, height = Frame.Width, Frame.Height
			local topleftPos = InteractiveMenu.ScreenPos(self, cornerX, cornerY)
			local bottomRightPos = topleftPos + Vector(width - 4.5, height - 4.5)
			if Parent.Visible then
				PrimitiveMan:DrawBoxFillPrimitive(ActivityMan:GetActivity():ScreenOfPlayer(actor:GetController().Player), topleftPos, bottomRightPos, Parent.Color)
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
					local topleftPos = InteractiveMenu.ScreenPos(self, cornerX, cornerY)
					local bottomRightPos = topleftPos + Vector(width - 4.5, height - 4.5)
					if Child.Visible then
						PrimitiveMan:DrawBoxFillPrimitive(ActivityMan:GetActivity():ScreenOfPlayer(actor:GetController().Player), topleftPos, bottomRightPos, Child.Color)
					end
					Panel = Box(topleftPos, width, height )

                    if CButton then
                        if Panel:IsWithinBox(mouse.Pos - Vector(0.2,2.621)) then
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
                                PrimitiveMan:DrawTextPrimitive(ActivityMan:GetActivity():ScreenOfPlayer(actor:GetController().Player), Panel.Corner + ToolTipPos, Child.ToolTip, Child.isSmall, 0)
                            end
                            if Child.Color2 then
                                PrimitiveMan:DrawBoxFillPrimitive(ActivityMan:GetActivity():ScreenOfPlayer(actor:GetController().Player), topleftPos, bottomRightPos, Child.Color2)
                            end
                        else
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
                            local Clicked = self.INCursor:GetController():IsState(Controller.WEAPON_FIRE)
                            if (Clicked and Child.OnClick) and not self.ConfirmClick then
                                Child.OnClick()
                                self.ConfirmClick = true
                            elseif not Clicked then
                                self.ConfirmClick = false
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
						local TexPos = InteractiveMenu.ScreenPos(self, Child.PosX, Child.PosY)
						PrimitiveMan:DrawTextPrimitive(ActivityMan:GetActivity():ScreenOfPlayer(actor:GetController().Player), TexPos, Child.Text, Child.isSmall, 0)
					end
				end
			end
		end
	end
end

--[[
--? E L E M E N T S
--? You only need to call these Elements once, it'll do some checks to prevent it from falling apart
Name - string
PosX - number
PosY - number
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

function InteractiveMenu.Button(N, X, Y, W, H, PALETTE1, PALETTE2, CLICKABLE, VISIBLE, TIP, DIRECT, SMALL, ONE_TIME_FUNCTION, CALLBACK)
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
		OnClick = ONE_TIME_FUNCTION,
		CallBack = CALLBACK
	}
end

function InteractiveMenu.Label(N, X, Y, TXT, SMALL, VISIBLE, CALLBACK)
	return {
		ControlType = "LABEL",
		Name = N,
		PosX = X,
		PosY = Y,
		Text = TXT,
		isSmall = SMALL,
		Visible = VISIBLE,
		CallBack = CALLBACK,
	}
end