local E, L, V, P, G, _  = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');
local UFP = E:GetModule('UnitFramePlugin');
local LSM = LibStub("LibSharedMedia-3.0");
UF.LSM = LSM
--Cache global variables
--Lua functions
local random = random
--WoW API / Variables
local CreateFrame = CreateFrame
local UnitIsTapDenied = UnitIsTapDenied
local UnitReaction = UnitReaction
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local UnitIsDeadOrGhost = UnitIsDeadOrGhost

local _G = _G

function UFP:Construct_health_backdrop(frame)
	local health_backdrop = CreateFrame('StatusBar', nil, frame)
	UF['statusbars'][health_backdrop] = true
    health_backdrop:SetReverseFill(true)
	
	if frame.bg then
		frame.bg:SetAlpha(0)
	end
	if frame.backdrop.backdropTexture then frame.backdrop.backdropTexture:SetVertexColor(0,0,0,0) end
	frame.backdrop:SetBackdropColor(0,0,0,0)
	
	frame.PostUpdate = self.PostUpdateHealth

	return health_backdrop
end

function UFP:Configure_HealthBar(frame)
	local db = frame.db
	local health = frame.Health

	if not health.health_backdrop then health.health_backdrop  = UFP:Construct_health_backdrop(health) end
	
	--Position
	health.health_backdrop:ClearAllPoints()
	if frame.ORIENTATION == "LEFT" then
			health.health_backdrop:Point("TOPRIGHT", frame, "TOPRIGHT", -frame.BORDER - frame.SPACING - (frame.PVPINFO_WIDTH or 0), -frame.BORDER - frame.SPACING - frame.CLASSBAR_YOFFSET)
			
			if frame.USE_POWERBAR_OFFSET then
				health.health_backdrop:Point("TOPRIGHT", frame, "TOPRIGHT", -frame.BORDER - frame.SPACING - frame.POWERBAR_OFFSET, -frame.BORDER - frame.SPACING - frame.CLASSBAR_YOFFSET)
				health.health_backdrop:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", frame.PORTRAIT_WIDTH + frame.BORDER + frame.SPACING, frame.BORDER + frame.SPACING + frame.POWERBAR_OFFSET)
			elseif frame.POWERBAR_DETACHED or not frame.USE_POWERBAR or frame.USE_INSET_POWERBAR then
				health.health_backdrop:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", frame.PORTRAIT_WIDTH + frame.BORDER + frame.SPACING, frame.BORDER + frame.SPACING + frame.BOTTOM_OFFSET)
			elseif frame.USE_MINI_POWERBAR then
				health.health_backdrop:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", frame.PORTRAIT_WIDTH + frame.BORDER + frame.SPACING, frame.SPACING + (frame.POWERBAR_HEIGHT/2))
			else
				health.health_backdrop:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", frame.PORTRAIT_WIDTH + frame.BORDER + frame.SPACING, frame.BORDER + frame.SPACING + frame.BOTTOM_OFFSET)
			end
	elseif frame.ORIENTATION == "RIGHT" then
			health.health_backdrop:Point("TOPLEFT", frame, "TOPLEFT", frame.BORDER + frame.SPACING + (frame.PVPINFO_WIDTH or 0), -frame.BORDER - frame.SPACING - frame.CLASSBAR_YOFFSET)

			if frame.USE_POWERBAR_OFFSET then
				health.health_backdrop:Point("TOPLEFT", frame, "TOPLEFT", frame.BORDER + frame.SPACING + frame.POWERBAR_OFFSET, -frame.BORDER - frame.SPACING - frame.CLASSBAR_YOFFSET)
				health.health_backdrop:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -frame.PORTRAIT_WIDTH - frame.BORDER - frame.SPACING, frame.BORDER + frame.SPACING + frame.POWERBAR_OFFSET)
			elseif frame.POWERBAR_DETACHED or not frame.USE_POWERBAR or frame.USE_INSET_POWERBAR then
				health.health_backdrop:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -frame.PORTRAIT_WIDTH - frame.BORDER - frame.SPACING, frame.BORDER + frame.SPACING + frame.BOTTOM_OFFSET)
			elseif frame.USE_MINI_POWERBAR then
				health.health_backdrop:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -frame.PORTRAIT_WIDTH - frame.BORDER - frame.SPACING, frame.SPACING + (frame.POWERBAR_HEIGHT/2))
			else
				health.health_backdrop:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -frame.PORTRAIT_WIDTH - frame.BORDER - frame.SPACING, frame.BORDER + frame.SPACING + frame.BOTTOM_OFFSET)
			end
	elseif frame.ORIENTATION == "MIDDLE" then
			health.health_backdrop:Point("TOPRIGHT", frame, "TOPRIGHT", -frame.BORDER - frame.SPACING - (frame.PVPINFO_WIDTH or 0), -frame.BORDER - frame.SPACING - frame.CLASSBAR_YOFFSET)
			
			if frame.USE_POWERBAR_OFFSET then
				health.health_backdrop:Point("TOPRIGHT", frame, "TOPRIGHT", -frame.BORDER - frame.SPACING - frame.POWERBAR_OFFSET, -frame.BORDER - frame.SPACING - frame.CLASSBAR_YOFFSET)
				health.health_backdrop:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", frame.BORDER + frame.SPACING + frame.POWERBAR_OFFSET, frame.BORDER + frame.SPACING + frame.POWERBAR_OFFSET)
			elseif frame.POWERBAR_DETACHED or not frame.USE_POWERBAR or frame.USE_INSET_POWERBAR then
				health.health_backdrop:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", frame.BORDER + frame.SPACING, frame.BORDER + frame.SPACING + frame.BOTTOM_OFFSET)
			elseif frame.USE_MINI_POWERBAR then
				health.health_backdrop:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", frame.BORDER + frame.SPACING, frame.SPACING + (frame.POWERBAR_HEIGHT/2))
			else
				health.health_backdrop:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", frame.PORTRAIT_WIDTH + frame.BORDER + frame.SPACING, frame.BORDER + frame.SPACING + frame.BOTTOM_OFFSET)
			end
	end
	
	if db.health then
		--Party/Raid Frames allow to change statusbar orientation
		if db.health.orientation then
			health.health_backdrop:SetOrientation(db.health.orientation)
		end

		--Party/Raid Frames can toggle frequent updates
		if db.health.frequentUpdates then
			health.health_backdrop.frequentUpdates = db.health.frequentUpdates
		end
	end

	frame:UpdateElement("Health")
end

function UFP:PostUpdateHealth(unit, min, max)
	local parent = self:GetParent()

	if parent.isForced then
		min = random(1, max)
		self:SetValue(min)
		self.health_backdrop:SetValue(max-min)
		if self.backdrop.backdropTexture then self.backdrop.backdropTexture:SetVertexColor(0,0,0,0) end
		self.backdrop:SetBackdropColor(0,0,0,0)
	end

	if self.backdrop.backdropTexture then self.backdrop.backdropTexture:SetVertexColor(0,0,0,0) end
	self.backdrop:SetBackdropColor(0,0,0,0)
		
	self.health_backdrop:SetMinMaxValues(0,max)
  
 	if(disconnected) then
		self.health_backdrop:SetValue(0)
 	else
		self.health_backdrop:SetValue(max-min)
	end
	
	local colors = E.db['unitframe']['colors'];
	
	local UFP_colors = E.db['UFP']['unitframes']['health']['colors']
	local UFP_texture = E.db['UFP']['unitframes']['health']['texture']
	local transparent_statusbar = UFP_colors.transparent_statusbar
	local transparent_backdrope = UFP_colors.transparent_backdrope
	
	local statusbar = self
	local backdrope = self.health_backdrop
	if UFP_colors.invert_colors then
	    statusbar = self.health_backdrop
		backdrope = self
		transparent_statusbar = UFP_colors.transparent_backdrope
		transparent_backdrope = UFP_colors.transparent_statusbar
	end
	--	statusbar
	if (((colors.healthclass == true and colors.colorhealthbyvalue == true) or (colors.colorhealthbyvalue and parent.isForced)) and not UnitIsTapDenied(unit)) then
		local newr, newg, newb = ElvUF.ColorGradient(min, max, 1, 0, 0, 1, 1, 0, r, g, b)
		statusbar:SetStatusBarColor(newr, newg, newb, transparent_statusbar)
	elseif colors.healthclass then
		local reaction = UnitReaction(unit, 'player')
		local t
		if UnitIsPlayer(unit) then
			local _, class = UnitClass(unit)
			t = parent.colors.class[class]
		elseif reaction then
			t = parent.colors.reaction[reaction]
		end
		if t then
			statusbar:SetStatusBarColor(t[1], t[2], t[3], transparent_statusbar)
		end
	else 	
		statusbar:SetStatusBarColor(colors.health.r, colors.health.g, colors.health.b, transparent_statusbar)
	end
	-- backdrope
	if colors.useDeadBackdrop and UnitIsDeadOrGhost(unit) then
		local backdrop = colors.health_backdrop_dead
		backdrope:SetStatusBarColor(backdrop.r, backdrop.g, backdrop.b, transparent_backdrope) 
	elseif colors.classbackdrop then
		local reaction = UnitReaction(unit, 'player')
		local t
		if UnitIsPlayer(unit) then
			local _, class = UnitClass(unit)
			t = parent.colors.class[class]
		elseif reaction then
			t = parent.colors.reaction[reaction]
		end
		if t then
			backdrope:SetStatusBarColor(t[1], t[2], t[3], transparent_backdrope)
		end
	elseif colors.customhealthbackdrop then
		backdrope:SetStatusBarColor(colors.health_backdrop.r, colors.health_backdrop.g, colors.health_backdrop.b, transparent_backdrope) 
	else
		local r, b, g = P.general.backdropcolor
		backdrope:SetStatusBarColor(r, b, g, transparent_backdrope ) 
	end	


	if UFP_texture.use_texture then
		self:SetStatusBarTexture(LSM:Fetch("statusbar", UFP_texture.texture))	
	else
        self:SetStatusBarTexture(self:GetStatusBarColor())
	end
	
	if UFP_texture.use_Backdrope_texture then
		self.health_backdrop:SetStatusBarTexture(LSM:Fetch("statusbar", UFP_texture.backdrope_texture))		
	else
		self.health_backdrop:SetStatusBarTexture(self.health_backdrop:GetStatusBarColor())
	end
	
end

hooksecurefunc(UF, "Configure_HealthBar", UFP.Configure_HealthBar)
hooksecurefunc(UF, "PostUpdateHealth", UFP.PostUpdateHealth)