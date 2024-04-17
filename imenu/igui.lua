local igui = {}
--[[
* We require the entity (aka the actor, to be passed in the update, so that we can consistantly get the player screen)
! These are all default values, do not modify them
? You have to set the parent, after the name or it won't work
? TextAlignment is W.I.P for everything ( left = 0, center = 1, right = 2 )
? ControlTypes don't do anything for now (or never)

TODO Tooltip shown on mouse position
]]

-- PUBLIC FUNCTIONS ------------------------------------------------------------

function igui.CollectionBox()
	local cbox = {}
	cbox.Child = {}

	--String
	util.AccessorFunc(cbox, "Name", "Name", 1)
	util.AccessorFunc(cbox, "Title", "Title", 1)

	--Number
	util.AccessorFunc(cbox, "Color", "Color", 2)
	util.AccessorFunc(cbox, "OutlineColor", "OutlineColor", 2)
	util.AccessorFunc(cbox, "OutlineThickness", "OutlineThickness", 2)
	--Bool
	util.AccessorFunc(cbox, "Visible", "Visible", 3)
	util.AccessorFunc(cbox, "SmallText", "SmallText", 3)
	util.AccessorFunc(cbox, "DrawAfterParent", "DrawAfterParent", 3)

	--Vector
	util.AccessorFunc(cbox, "Pos", "Pos", 4)
	util.AccessorFunc(cbox, "Size", "Size", 4)

	cbox.ControlType = "COLLECTIONBOX"
	cbox.Name = cbox.Name or "CollectionBox"
	cbox.Title = "Title Text"
	cbox.Color = 146
	cbox.OutlineColor = 71
	cbox.OutlineThickness = 0
	cbox.Visible = true
	cbox.SmallText = true
	cbox.DrawAfterParent = true
	cbox.Pos = Vector()
	cbox.Size = Vector(80, 50)

	cbox.Think = nil

	cbox.SetParent = function(self, parent)
		self.Parent = parent
		for i, child in pairs(parent.Child) do
			if child.Name == self.Name then
				parent.Child[i] = nil
			end
		end
		table.insert(parent.Child, self)
	end

	cbox.GetParent = function(self)
		return self.Parent
	end

	cbox.Update = function(self, entity)
		if not self.Visible then return end
		if not table.IsEmpty(self.Child) then
			for i, child in pairs(self.Child) do
				if child.DrawAfterParent == false then
					child:Update(entity)
				end
			end
		end
		local screen = ActivityMan:GetActivity():ScreenOfPlayer(entity:GetController().Player)
		local pos = ((self.Parent and self.Parent.Pos + self.Pos) or self.Pos) / FrameMan.ResolutionMultiplier
		local world_pos = CameraMan:GetOffset(screen) + pos
		local text_pos = world_pos
		local thickness = self.OutlineThickness
		if entity:IsPlayerControlled() then
			if thickness ~= 0 then
				PrimitiveMan:DrawBoxFillPrimitive(screen, world_pos - Vector(thickness, thickness), world_pos + self.Size + Vector(thickness, thickness), self.OutlineColor)
			end
			PrimitiveMan:DrawBoxFillPrimitive(screen, world_pos, world_pos + self.Size, self.Color)
			PrimitiveMan:DrawTextPrimitive(screen, text_pos, self.Title, self.SmallText, 0)
		end

		if entity:IsPlayerControlled() and self.Think then
			self.Think(entity, screen)
		end

		if not table.IsEmpty(self.Child) then
			for i, child in pairs(self.Child) do
				if child.DrawAfterParent == true then
					child:Update(entity)
				end
			end
		end
	end

	return cbox
end

function igui.Button()
	local button = {}
	button.Child = {}

	--String
	util.AccessorFunc(button, "Name", "Name", 1)
	util.AccessorFunc(button, "Text", "Text", 1)
	util.AccessorFunc(button, "Tooltip", "Tooltip", 1)

	--Number
	util.AccessorFunc(button, "TextAlignment", "TextAlignment", 2)
	util.AccessorFunc(button, "Color", "Color", 2)
	util.AccessorFunc(button, "OutlineColor", "OutlineColor", 2)
	util.AccessorFunc(button, "OutlineThickness", "OutlineThickness", 2)

	--Bool
	util.AccessorFunc(button, "Visible", "Visible", 3)
	util.AccessorFunc(button, "Clickable", "Clickable", 3)
	util.AccessorFunc(button, "SmallText", "SmallText", 3)
	util.AccessorFunc(button, "DrawAfterParent", "DrawAfterParent", 3)

	--Vector
	util.AccessorFunc(button, "Pos", "Pos", 4)
	util.AccessorFunc(button, "Size", "Size", 4)
	util.AccessorFunc(button, "TextPos", "TextPos", 4)

	button.ControlType = "BUTTON"
	button.Name = button.Name or "Button"
	button.Text = ""
	button.Tooltip = ""
	button.TextAlignment = 1
	button.Color = 146
	button.OutlineColor = 71
	button.OutlineThickness = 0
	button.Visible = true
	button.Clickable = true
	button.SmallText = true
	button.DrawAfterParent = true
	button.Pos = Vector()
	button.Size = Vector(80, 50)
	button.TextPos = Vector()

	button.IsHovered = false
	button.Think = nil

	button.SetParent = function(self, parent)
		self.Parent = parent
		for i, child in pairs(parent.Child) do
			if child.Name == self.Name then
				parent.Child[i] = nil
			end
		end
		table.insert(parent.Child, self)
	end

	button.GetParent = function(self)
		return self.Parent
	end

	button.Update = function(self, entity)
		if not self.Visible then return end
		if not table.IsEmpty(self.Child) then
			for i, child in pairs(self.Child) do
				if child.DrawAfterParent == false then
					child:Update(entity)
				end
			end
		end
		local screen = ActivityMan:GetActivity():ScreenOfPlayer(entity:GetController().Player)
		local pos = ((self.Parent and self.Parent.Pos + self.Pos) or self.Pos) / FrameMan.ResolutionMultiplier
		local world_pos = CameraMan:GetOffset(screen) + pos
		local text_pos = world_pos

		self.IsHovered = false
		if cursor_inside(pos, self.Size) then
			self.IsHovered = true
		end

		if self.Clickable and self.IsHovered then
			if UInputMan:MouseButtonPressed(MouseButtons.MOUSE_LEFT) and self.LeftClick then self.LeftClick(entity) end
			if UInputMan:MouseButtonPressed(MouseButtons.MOUSE_MIDDLE) and self.MiddleClick then self.MiddleClick(entity) end
			if UInputMan:MouseButtonPressed(MouseButtons.MOUSE_RIGHT) and self.RightClick then self.RightClick(entity) end

			if UInputMan:MouseButtonHeld(MouseButtons.MOUSE_LEFT) and self.LeftHeld then self.LeftHeld(entity) end
			if UInputMan:MouseButtonHeld(MouseButtons.MOUSE_MIDDLE) and self.MiddleHeld then self.MiddleHeld(entity) end
			if UInputMan:MouseButtonHeld(MouseButtons.MOUSE_RIGHT) and self.RightHeld then self.RightHeld(entity) end

			if UInputMan:MouseButtonReleased(MouseButtons.MOUSE_LEFT) and self.LeftRelease then self.LeftRelease(entity) end
			if UInputMan:MouseButtonReleased(MouseButtons.MOUSE_MIDDLE) and self.MiddleRelease then self.MiddleRelease(entity) end
			if UInputMan:MouseButtonReleased(MouseButtons.MOUSE_RIGHT) and self.RightRelease then self.RightRelease(entity) end
		end

		--Center
		if self.TextAlignment == 1 then text_pos = text_pos + self.Size / 2 + Vector(0, -5) end

		if entity:IsPlayerControlled() then
			local thickness = self.OutlineThickness
			if thickness ~= 0 then
				PrimitiveMan:DrawBoxFillPrimitive(screen, world_pos - Vector(thickness, thickness), world_pos + self.Size + Vector(thickness, thickness), self.OutlineColor)
			end
			PrimitiveMan:DrawBoxFillPrimitive(screen, world_pos, world_pos + self.Size, self.Color)

			PrimitiveMan:DrawTextPrimitive(screen, self.TextPos + text_pos, self.Text, self.SmallText, self.TextAlignment or 0)

			if self.Tooltip ~= "" then
				PrimitiveMan:DrawTextPrimitive(screen, UInputMan:GetMousePos(), self.Tooltip, true, 0)
			end

			if (self.Think) then
				self.Think(entity, screen)
			end
		end

		if not table.IsEmpty(self.Child) then
			for i, child in pairs(self.Child) do
				if child.DrawAfterParent == true then
					child:Update(entity)
				end
			end
		end
	end

	return button
end

function igui.ProgressBar()
	local pbar = {}

	--String
	util.AccessorFunc(pbar, "Name", "Name", 1)
	util.AccessorFunc(pbar, "Text", "Text", 1)
	util.AccessorFunc(pbar, "Tooltip", "Tooltip", 1)

	--Number
	util.AccessorFunc(pbar, "FGColor", "FGColor", 2)
	util.AccessorFunc(pbar, "BGColor", "BGColor", 2)
	util.AccessorFunc(pbar, "OutlineColor", "OutlineColor", 2)
	util.AccessorFunc(pbar, "MaxHeight", "MaxHeight", 2)
	util.AccessorFunc(pbar, "Fraction", "Fraction", 2)
	util.AccessorFunc(pbar, "OutlineThickness", "OutlineThickness", 2)

	--Bool
	util.AccessorFunc(pbar, "Visible", "Visible", 3)
	util.AccessorFunc(pbar, "SmallText", "SmallText", 3)
	util.AccessorFunc(pbar, "DrawAfterParent", "DrawAfterParent", 3)

	--Vector
	util.AccessorFunc(pbar, "Pos", "Pos", 4)
	util.AccessorFunc(pbar, "Size", "Size", 4)

	pbar.ControlType = "PROGRESSBAR"
	pbar.Name = pbar.Name or "ProgressBar"
	pbar.Text = ""
	pbar.Tooltip = ""
	pbar.FGColor = 117
	pbar.BGColor = 146
	pbar.OutlineColor = 144
	pbar.MaxHeight = 10
	pbar.OutlineThickness = 2
	pbar.Visible = true
	pbar.SmallText = true
	pbar.DrawAfterParent = true
	pbar.Pos = Vector()
	pbar.Size = Vector(100, 10)

	local min = 0
	local max = 1
	local completed = false

	pbar.OnComplete = nil
	pbar.Think = nil
	pbar.OnProgress = nil

	pbar.SetParent = function(self, parent)
		self.Parent = parent
		for i, child in pairs(parent.Child) do
			if child.Name == self.Name then
				parent.Child[i] = nil
			end
		end
		table.insert(parent.Child, self)
	end

	pbar.GetParent = function(self)
		return self.Parent
	end

	pbar.GetCompleted = function(self)
		return completed
	end

	pbar.SetFraction = function(self, value)
		min = value
	end

	pbar.GetFraction = function(self)
		return min
	end

	pbar.Update = function(self, entity)
		if not self.Visible then return end
		local screen = ActivityMan:GetActivity():ScreenOfPlayer(entity:GetController().Player)
		local pos = ((self.Parent and self.Parent.Pos + self.Pos) or self.Pos) / FrameMan.ResolutionMultiplier
		local world_pos = CameraMan:GetOffset(screen) + pos
		local text_pos = world_pos
		local factor = math.min(min, max)
		local bottomRightPos = world_pos + self.Size + Vector(0, 0.5)
		local bottomRightPos2 = world_pos + Vector(self.Size.X * factor, self.Size.Y)
		local thickness = self.OutlineThickness
		if entity:IsPlayerControlled() then
			if thickness ~= 0 then
				PrimitiveMan:DrawBoxFillPrimitive(screen, world_pos - Vector(thickness, thickness), bottomRightPos + Vector(thickness, thickness), self.OutlineColor)
			end
			PrimitiveMan:DrawBoxFillPrimitive(screen, world_pos, bottomRightPos, self.BGColor)
			if min ~= 0 then
				PrimitiveMan:DrawBoxFillPrimitive(screen, world_pos, bottomRightPos2, self.FGColor)
			end
			PrimitiveMan:DrawTextPrimitive(screen, text_pos, self.Text, self.SmallText, 0)
		end
		if not completed then
			if min >= max then
				completed = true
				if (self.OnComplete) then
					self.OnComplete(entity)
					min = 0
					completed = false
				end
			end
		end
		if entity:IsPlayerControlled() and self.Think then
			self.Think(entity, screen)
		end
		if self.OnProgress then
			self.OnProgress(entity, screen)
		end
	end

	return pbar
end

function igui.Label()
	local label = {}

	--String
	util.AccessorFunc(label, "Name", "Name", 1)
	util.AccessorFunc(label, "Text", "Text", 1)

	--Bool
	util.AccessorFunc(label, "Visible", "Visible", 3)
	util.AccessorFunc(label, "SmallText", "SmallText", 3)
	util.AccessorFunc(label, "DrawAfterParent", "DrawAfterParent", 3)

	--Vector
	util.AccessorFunc(label, "Pos", "Pos", 4)

	label.ControlType = "LABEL"
	label.Name = label.Name or "Label"
	label.Text = "Label"
	label.Visible = true
	label.SmallText = true
	label.DrawAfterParent = true
	label.Pos = Vector()

	label.Think = nil

	label.SetParent = function(self, parent)
		self.Parent = parent
		for i, child in pairs(parent.Child) do
			if child.Name == self.Name then
				parent.Child[i] = nil
			end
		end
		table.insert(parent.Child, self)
	end

	label.GetParent = function(self)
		return self.Parent
	end

	label.Update = function(self, entity)
		if not self.Visible then return end
		local screen = ActivityMan:GetActivity():ScreenOfPlayer(entity:GetController().Player)
		local pos = ((self.Parent and self.Parent.Pos + self.Pos) or self.Pos) / FrameMan.ResolutionMultiplier
		local world_pos = CameraMan:GetOffset(screen) + pos
		if entity:IsPlayerControlled() then
			PrimitiveMan:DrawTextPrimitive(screen, world_pos, self.Text, self.SmallText, 0)
			if (self.Think) then
				self.Think(entity, screen)
			end
		end
	end
	return label
end

--[[---------------------------------------------------------
	Name: RemoveChild(parent_child, child_name )
	Desc: Look for children that doesn't have this name and remove it
-----------------------------------------------------------]]
function igui.RemoveChild(parent_child, child_name)
	if type(child_name) == "string" then
		for i, child in pairs(parent_child) do
			if child.Name == child_name then
				parent_child[i] = nil
			end
		end
		return
	end
	for i, child in pairs(parent_child) do
		for j, name in pairs(child_name) do
			if child.Name == name then
				parent_child[i] = nil
			end
		end
	end
end

-- PRIVATE FUNCTIONS -----------------------------------------------------------

function cursor_inside(el_pos, size)
	local el_x = el_pos.X
	local el_y = el_pos.Y

	local el_width = size.X
	local el_height = size.Y

	local mouse_pos = UInputMan:GetMousePos() / FrameMan.ResolutionMultiplier
	local mouse_x = mouse_pos.X
	local mouse_y = mouse_pos.Y

	return (mouse_x >= el_x) and (mouse_x < el_x + el_width) and (mouse_y >= el_y) and (mouse_y < el_y + el_height)
end

-- MODULE END ------------------------------------------------------------------

return igui