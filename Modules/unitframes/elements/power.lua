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

local _G = _G

local oUF = ElvUF or oUF

function UFP:Construct_power_backdrop(frame)

	local power_backdrop = CreateFrame('StatusBar', nil, frame)
	UF['statusbars'][power_backdrop] = true
    power_backdrop:SetReverseFill(true)
	
	power_backdrop.colorClass = nil
	power_backdrop.colorReaction = nil
	power_backdrop.colorPower = nil
	
	if frame.bg then
		frame.bg:SetAlpha(0)
	end
	if frame.backdrop.backdropTexture then frame.backdrop.backdropTexture:SetVertexColor(0,0,0,0) end
	frame.backdrop:SetBackdropColor(0,0,0,0)
	
	frame.power_backdrop = Power
	frame.PostUpdate = self.PostUpdatePower
	
	return power_backdrop
end
local x=nil
function UFP:Configure_Power(frame)
	if not frame.VARIABLES_SET then return end
	local db = frame.db
	local power = frame.Power
	power.origParent = frame
	
	if frame.USE_POWERBAR then		
		
		if not power.power_backdrop then power.power_backdrop  = UFP:Construct_power_backdrop(power) end
		
		if not frame:IsElementEnabled('Power') then
			frame:EnableElement('Power')
			power.power_backdrop:EnableElement('Power')
			power.power_backdrop:Show()
		end
		
		--local x=nil
		if x == nil then
		for k , v in pairs(power.power_backdrop) do print(tostring(k).."  "..tostring(v)) end
		end
		x=1	
		--Position
		power.power_backdrop:ClearAllPoints()
		if frame.POWERBAR_DETACHED then
			power.power_backdrop:Width(frame.POWERBAR_WIDTH - ((frame.BORDER + frame.SPACING)*2))
			power.power_backdrop:Height(frame.POWERBAR_HEIGHT - ((frame.BORDER + frame.SPACING)*2))
			if not power.Holder or (power.Holder and not power.Holder.mover) then
				power.power_backdrop:ClearAllPoints()
				power.power_backdrop:Point("BOTTOMLEFT", power.Holder, "BOTTOMLEFT", frame.BORDER+frame.SPACING, frame.BORDER+frame.SPACING)
			else
				power.power_backdrop:ClearAllPoints()
				power.power_backdrop:Point("BOTTOMLEFT", power.Holder, "BOTTOMLEFT", frame.BORDER+frame.SPACING, frame.BORDER+frame.SPACING)
			end
		elseif frame.USE_POWERBAR_OFFSET then
			if frame.ORIENTATION == "LEFT" then
				power.power_backdrop:Point("TOPRIGHT", frame.Health, "TOPRIGHT", frame.POWERBAR_OFFSET, -frame.POWERBAR_OFFSET)
				power.power_backdrop:Point("BOTTOMLEFT", frame.Health, "BOTTOMLEFT", frame.POWERBAR_OFFSET, -frame.POWERBAR_OFFSET)
			elseif frame.ORIENTATION == "MIDDLE" then
				power.power_backdrop:Point("TOPLEFT", frame, "TOPLEFT", frame.BORDER + frame.SPACING, -frame.POWERBAR_OFFSET -frame.CLASSBAR_YOFFSET)
				power.power_backdrop:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -frame.BORDER - frame.SPACING, frame.BORDER)
			else
				power.power_backdrop:Point("TOPLEFT", frame.Health, "TOPLEFT", -frame.POWERBAR_OFFSET, -frame.POWERBAR_OFFSET)
				power.power_backdrop:Point("BOTTOMRIGHT", frame.Health, "BOTTOMRIGHT", -frame.POWERBAR_OFFSET, -frame.POWERBAR_OFFSET)
			end
		elseif frame.USE_INSET_POWERBAR then
			power.power_backdrop:Height(frame.POWERBAR_HEIGHT  - ((frame.BORDER + frame.SPACING)*2))
			power.power_backdrop:Point("BOTTOMLEFT", frame.Health, "BOTTOMLEFT", frame.BORDER + (frame.BORDER*2), frame.BORDER + (frame.BORDER*2))
			power.power_backdrop:Point("BOTTOMRIGHT", frame.Health, "BOTTOMRIGHT", -(frame.BORDER + (frame.BORDER*2)), frame.BORDER + (frame.BORDER*2))
		elseif frame.USE_MINI_POWERBAR then
            power.power_backdrop:Height(frame.POWERBAR_HEIGHT  - ((frame.BORDER + frame.SPACING)*2))
			if frame.ORIENTATION == "LEFT" then
				power.power_backdrop:Width(frame.POWERBAR_WIDTH - frame.BORDER*2)
				power.power_backdrop:Point("RIGHT", frame, "BOTTOMRIGHT", -(frame.BORDER*2 + 4), ((frame.POWERBAR_HEIGHT-frame.BORDER)/2))
			elseif frame.ORIENTATION == "RIGHT" then
				power.power_backdrop:Width(frame.POWERBAR_WIDTH - frame.BORDER*2)
				power.power_backdrop:Point("LEFT", frame, "BOTTOMLEFT", (frame.BORDER*2 + 4), ((frame.POWERBAR_HEIGHT-frame.BORDER)/2))
			else
				power.power_backdrop:Point("LEFT", frame, "BOTTOMLEFT", (frame.BORDER*2 + 4), ((frame.POWERBAR_HEIGHT-frame.BORDER)/2))
				power.power_backdrop:Point("RIGHT", frame, "BOTTOMRIGHT", -(frame.BORDER*2 + 4 + (frame.PVPINFO_WIDTH or 0)), ((frame.POWERBAR_HEIGHT-frame.BORDER)/2))
			end
		else
			power.power_backdrop:Point("TOPRIGHT", frame.Health.backdrop, "BOTTOMRIGHT", -frame.BORDER,  -frame.SPACING*3)
			power.power_backdrop:Point("TOPLEFT", frame.Health.backdrop, "BOTTOMLEFT", frame.BORDER, -frame.SPACING*3)
			power.power_backdrop:Height(frame.POWERBAR_HEIGHT  - ((frame.BORDER + frame.SPACING)*2))
		end
		
		local UFP_colors = E.db['UFP']['unitframes']['power']['colors']
		local UFP_texture = E.db['UFP']['unitframes']['power']['texture']
		local transparent_statusbar = UFP_colors.transparent_statusbar
		local transparent_backdrope = UFP_colors.transparent_backdrope
		local backdropcolor = UFP_colors.backdropcolor
		local r,b,g,a = power:GetStatusBarColor()

		
		if UFP_texture.use_texture then	
			power:SetStatusBarTexture(LSM:Fetch("statusbar", UFP_texture.texture))	
		else
			power:SetStatusBarTexture(power:GetStatusBarColor())
		end
		
		if UFP_texture.use_Backdrope_texture then
			power.power_backdrop:SetStatusBarTexture(LSM:Fetch("statusbar", UFP_texture.backdrope_texture))
		else
			power.power_backdrop:SetStatusBarTexture(power.power_backdrop:GetStatusBarColor())	
		end
	elseif frame:IsElementEnabled('Power') then
		frame:DisableElement('Power')
		power.power_backdrop:Hide()
	end
end

local tokens = { [0] = "MANA", "RAGE", "FOCUS", "ENERGY", "RUNIC_POWER" }
--local tokens = { [0] = "MANA", [1] = "RAGE",[2] = "FOCUS", [3] = "ENERGY", [6] = "RUNIC_POWER", [18] = "PAIN", [17] = "FURY", [8] = "LUNAR_POWER", [13] = "INSANITY", [11] ="MAELSTROM"}
function UFP:PostUpdatePower(unit, cur, min, max)

	local parent = self.origParent or self:GetParent()
	
	local colors = E.db['unitframe']['colors'];
	local UFP_colors = E.db['UFP']['unitframes']['power']['colors']
	local UFP_texture = E.db['UFP']['unitframes']['power']['texture']
	local transparent_statusbar = UFP_colors.transparent_statusbar
	local transparent_backdrope = UFP_colors.transparent_backdrope
	local backdropcolor = UFP_colors.backdropcolor
	local r,b,g,a = self:GetStatusBarColor()

		
	if parent.isForced then
		local pType = random(0,4)--1,2,3,6,18,17,8,13,11)
		local color = ElvUF['colors'].power[tokens[pType]]

		min = random(1, max)
		self:SetValue(min)
		self.power_backdrop:SetValue(max-min)
		
		if self.backdrop.backdropTexture then self.backdrop.backdropTexture:SetVertexColor(0,0,0,0) end
		self.backdrop:SetBackdropColor(0,0,0,0)
		
		if UFP_colors.invert_colors then
			if not self.colorClass then self.power_backdrop:SetStatusBarColor(color[1], color[2], color[3], transparent_statusbar) end
			self:SetStatusBarColor(backdropcolor.r, backdropcolor.b, backdropcolor.g, transparent_backdrope)
		else
			if not self.colorClass then self:SetStatusBarColor(color[1], color[2], color[3], transparent_statusbar) end
			self.power_backdrop:SetStatusBarColor(backdropcolor.r, backdropcolor.b, backdropcolor.g, transparent_backdrope)
		end
		
		if UFP_texture.use_texture then	
			self:SetStatusBarTexture(LSM:Fetch("statusbar", UFP_texture.texture))	
		else
			self:SetStatusBarTexture(self:GetStatusBarColor())
		end
		
		if UFP_texture.use_Backdrope_texture then
			self.power_backdrop:SetStatusBarTexture(LSM:Fetch("statusbar", UFP_texture.backdrope_texture))
		else
			self.power_backdrop:SetStatusBarTexture(self.power_backdrop:GetStatusBarColor())	
		end
	end
	
	if self.backdrop.backdropTexture then self.backdrop.backdropTexture:SetVertexColor(0,0,0,0) end
	self.backdrop:SetBackdropColor(0,0,0,0)
		
	self.power_backdrop:SetMinMaxValues(min or 0, max)
  
 	if(disconnected) then
		self.power_backdrop:SetValue(cur or max)
 	else
		self.power_backdrop:SetValue(max-cur)
	end

	if UFP_colors.invert_colors then
		self:SetStatusBarColor(backdropcolor.r, backdropcolor.b, backdropcolor.g, transparent_backdrope)
		self.power_backdrop:SetStatusBarColor(r,b,g, transparent_statusbar)
	else
		self:SetStatusBarColor(r,b,g, transparent_statusbar)
		self.power_backdrop:SetStatusBarColor(backdropcolor.r, backdropcolor.b, backdropcolor.g, transparent_backdrope)
	end
	--[[
	if UFP_texture.use_texture then	
		self:SetStatusBarTexture(LSM:Fetch("statusbar", UFP_texture.texture))	
	else
        self:SetStatusBarTexture(self:GetStatusBarColor())
	end
	
	if UFP_texture.use_Backdrope_texture then
		self.power_backdrop:SetStatusBarTexture(LSM:Fetch("statusbar", UFP_texture.backdrope_texture))
	else
		self.power_backdrop:SetStatusBarTexture(self.power_backdrop:GetStatusBarColor())	
	end]]
end

hooksecurefunc(UF, "Configure_Power", UFP.Configure_Power)
hooksecurefunc(UF, "PostUpdatePower", UFP.PostUpdatePower)