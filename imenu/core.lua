local imenu = {}

function imenu:Create()
	local members = {}
	setmetatable(members, self)

	self.__index = self

	return members
end

-- PUBLIC FUNCTIONS ------------------------------------------------------------

function imenu:Initialize(entity)
	local act = ActivityMan:GetActivity()
	if act == nil then ConsoleMan:PrintString("A activity is required to be running in order to setup menu!"  .. "Warning! \xD5 ") return end
	-- Don't change these
	self.Activity = act
	self.MaxCursorDist = Vector(FrameMan.PlayerScreenWidth * 0.5 - 6, FrameMan.PlayerScreenHeight * 0.5 - 6)
	self.HUDHandler = require("Activities/Utility/HUDHandler")

	self.Open = false --If you want your menu to be automatically opened, do it in a update function, check if it's being controlled
	self.Close = true --It's closed by default
	self.ForceOpen = false --Will force everything to run once
	self.Cursor_Bitmap = "Cursor.rte/imenu Cursor"
	self.EntityCurrentlyControlled = false
	self.OneInstance = false
	self.KeepMenuOpen = false
end

--[[---------------------------------------------------------
	Name: MessageEntity( entity, message, parent )
	Desc: When the entity wants to send a message, MessageEntity will use that to send a message back.
		It's best to call this one at a time or use ForceOpen (though the menu will be opened automatically!)
	Note: You can use this on anything that can retrieve Messages. (unless forcefully blacklisted)
		If the entity is a device, you would want to use parent so we can check if it's playerControlled for ForceOpen
-----------------------------------------------------------]]

function imenu:MessageEntity(entity, message, parent)
	assert(entity, "The entity is nil")

	if isBlacklisted(entity) then return end

	if not self.DrawPos then
		self.DrawPos = parent and Vector(parent.Pos.X, parent.Pos.Y) or Vector(entity.Pos.X, entity.Pos.Y)
	end

	if self.ForceOpen then
		local playerControlled = parent and parent:IsPlayerControlled() or entity:IsPlayerControlled()
		if playerControlled then
			if not self.EntityCurrentlyControlled then
				self.Open, self.KeepMenuOpen = instance(entity, message, self.OneInstance, self.Open, self.KeepMenuOpen)
				self.EntityCurrentlyControlled = true
			end
			return
		end
		self.EntityCurrentlyControlled = false
		if self.OneInstance then return end
		self.Open = false
		return
	end

	if not self.Open then
		entity:SendMessage(message)
	end
	self.Close = false
	--We force it to be true regardless just for incase
	self.Open = not self.Open --Do it after so the entity has time to setup everything (Does that theory work lol?)
end

--[[---------------------------------------------------------
	Name: Update( entity )
	Desc: Draws everything
	Note: Draw function requires a entity to be passed.
		The reason is due to cursor consistancy (Subject to change)
-----------------------------------------------------------]]
function imenu:Update(entity)
	if shouldDisplay(self, entity) then return end

	local ctrl = entity:GetController()
	local screen = ActivityMan:GetActivity():ScreenOfPlayer(ctrl.Player)

	--Cursor creation, update
	if not self.Cursor then self.Cursor = cursorData(entity.Pos, self.Cursor_Bitmap) end

	--Don't move cursor if pie menu is active
	--if not ctrl:IsState(Controller.PIE_MENU_ACTIVE) then
	Cursor(screen, self.Cursor, ctrl)

	--Actor movement disabled, static camera
	Camera(self.DrawPos, entity)

	--Cursor draws above all
	PrimitiveMan:DrawBitmapPrimitive(screen, self.Cursor[1].Pos, self.Cursor[1], 0, 0)
end

--[[---------------------------------------------------------
	Name: Remove()
	Desc: Removes the menu that is active
		We set certain values regardless, because we are removing it!
-----------------------------------------------------------]]
function imenu:Remove()
	if self.ForceOpen then
		self.Cursor = nil
		return
	end
	self.Close = true
	self.Open = false
	self.Cursor = nil
end

-- PRIVATE FUNCTIONS -----------------------------------------------------------


--[[---------------------------------------------------------
	Name: instance( entity, message, oneInstance, isOpen, stayedOpen )
	Desc: For each MessageEntity() call, should the instance stay or should it be recreated everytime?
-----------------------------------------------------------]]
function instance(entity, message, oneInstance, isOpen, stayedOpen)
	stayedOpen = stayedOpen
	isOpen = isOpen
	if oneInstance then
		if not stayedOpen then
			entity:SendMessage(message)
			isOpen = true
			stayedOpen = true
		end
		return isOpen, stayedOpen
	end
	entity:SendMessage(message)
	isOpen = true

	return isOpen, stayedOpen
end

function cursorData(entity_pos, bitmap)
	local mouse = UInputMan:GetMousePos() --entity_pos
	local mid = entity_pos
	local res = Vector(FrameMan.PlayerScreenWidth, FrameMan.PlayerScreenHeight)

	local cursor = CreateMOSParticle(bitmap or "Cursor.rte/imenu Cursor")
	local cursor_mos = ToMOSprite(cursor)
	cursor.Size = Vector(cursor_mos:GetSpriteWidth(), cursor_mos:GetSpriteHeight())
	cursor.Pos = mouse
	cursor.HitsMOs = false
	cursor.GetsHitByMOs = false
	return {cursor, mouse, mid, res}
end

function Cursor(screen, cursor, ctrl)
	cursor[2] = UInputMan:GetMousePos() + CameraMan:GetOffset(screen) + cursor[1].Size / 2

	-- Don't let the cursor leave the screen
	if cursor[2].X - cursor[3].X < -cursor[4].X then
		cursor[2].X = cursor[3].X - cursor[4].X
	end

	if cursor[2].Y - cursor[3].Y < -cursor[4].Y then
		cursor[2].Y = cursor[3].Y - cursor[4].Y
	end

	if cursor[2].X - cursor[3].X > cursor[4].X - 10 then
		cursor[2].X = cursor[3].X + cursor[4].X - 10
	end

	if cursor[2].Y - cursor[3].Y > cursor[4].Y - 10 then
		cursor[2].Y = cursor[3].Y + cursor[4].Y - 10
	end

	cursor[1].Pos = cursor[2]
end

--[[---------------------------------------------------------
	Name: isBlacklisted( entity )
	Desc: We can't allow entitys that cannot be controlled.
		We do this because it's more consistant to make menu's for controllable entitys!
-----------------------------------------------------------]]
function isBlacklisted(entity)
	if (entity.ClassName == "MOSRotating" or entity.ClassName == "MOSParticle" or entity.ClassName == "MOPixel" or entity.ClassName == "AEmitter") then
		ConsoleMan:PrintString("The entity's classname: " .. entity.ClassName .. " is not supported!" .. "Warning! \xD5 ")
		return true
	end
	return false
end

--[[---------------------------------------------------------
	Name: shouldDisplay( self, entity )
	Desc: true or false statements on should the menu be displayed
-----------------------------------------------------------]]
function shouldDisplay(self, entity)
	if self.ForceOpen then
		--Just to be sure, we don't want to cursor to still exist if we don't control it
		if entity.Health <= 0 or not entity:IsPlayerControlled() then self.Cursor = nil; return true end
		return false
	end
	if entity.Health <= 0 or not entity:IsPlayerControlled() then self:Remove() return true end
	if self.Close then return true end
	if not self.Open then self:Remove() return true end
end

--[[---------------------------------------------------------
	Name: Camera()
	Desc: Sets everything to a static position (disables entity movement)
-----------------------------------------------------------]]
function Camera(drawPos, entity)
	local ctrl = entity:GetController()
	local states = {
		Controller.MOVE_UP, Controller.MOVE_DOWN, Controller.BODY_JUMPSTART, Controller.BODY_JUMP, Controller.BODY_CROUCH, Controller.MOVE_LEFT, Controller.MOVE_RIGHT,
		Controller.MOVE_IDLE, Controller.MOVE_FAST, Controller.AIM_UP, Controller.AIM_DOWN, Controller.AIM_SHARP, Controller.WEAPON_FIRE, Controller.WEAPON_RELOAD,
	}
	for _, input in ipairs(states) do
		ctrl:SetState(input, false)
	end

	if SceneMan:ShortestDistance(drawPos, Vector(entity.Pos.X, entity.Pos.Y), false):MagnitudeIsGreaterThan(2) then
		drawPos = Vector(entity.Pos.X, entity.Pos.Y)
	end
	CameraMan:SetScrollTarget(drawPos, 0.5, ActivityMan:GetActivity():ScreenOfPlayer(ctrl.Player))
end

-- MODULE END ------------------------------------------------------------------

return imenu:Create()