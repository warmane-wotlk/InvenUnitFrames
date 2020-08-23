if select(2, UnitClass("player")) ~= "SHAMAN" then return end

local IUF = InvenUnitFrames
local _G = _G
local GetTime = _G.GetTime
local GetTotemInfo = _G.GetTotemInfo
local GetTotemTimeLeft = _G.GetTotemTimeLeft
local DestroyTotem = _G.DestroyTotem

local texture, width, duration, icon
local totemColor = { { 1, 0.25, 0.25 }, { 1, 1, 0 }, { 0, 0.6, 1 }, { 0, 0.8, 0 } }
local totemOrder = { 2, 1, 3, 4 }

local function classbarOnUpdate(self)
	self:SetScript("OnUpdate", nil)
	IUF:ClassBarSetup(self:GetParent())
end

function IUF:CreateClassBar(object)
	object.classBar = CreateFrame("Frame", nil, object)
	object.classBar:SetFrameLevel(object:GetFrameLevel() - 3)
	object.classBar:Hide()
	object.classBar.type = "SHAMAN"
	object.classBar.border = CreateFrame("Frame", nil, object.classBar)
	object.classBar.border:SetFrameLevel(object:GetFrameLevel() - 4)
	object.classBar.border:SetPoint("TOPLEFT", -1, 1)
	object.classBar.border:SetPoint("BOTTOMRIGHT", 1, -1)
	object.classBar.border:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeSize = 1,
	})
	object.classBar.border:SetBackdropColor(0, 0, 0, 0.2)
	object.classBar.border:SetBackdropBorderColor(0, 0, 0, 0.75)
	object.classBar.active = 0
	object.classBar.totems = {}
	local function totemBarOnUpdate(self, timer)
		self.timer = self.timer + timer
		if self.timer > 0.5 then
			self.timer = 0
			self = self:GetParent()
			self.left = GetTotemTimeLeft(self:GetID()) or 0
			self.bar:SetValue(self.left)
			if IUF.db.classBar.SHAMAN.showCD then
				if self.left > 60 then
					self.text:SetFormattedText("%dm", self.left / 60 + 0.5)
				elseif self.left > 0 then
					self.text:SetFormattedText("%d", self.left)
				else
					self.text:SetText(nil)
				end
			else
				self.text:SetText(nil)
			end
		end
	end
	local function totemBarOnClick(self)
		DestroyTotem(self:GetID())
	end
	for i = 1, 4 do
		object.classBar.totems[i] = CreateFrame("Button", nil, object.classBar)
		object.classBar.totems[i]:SetID(totemOrder[i])
		object.classBar.totems[i]:SetFrameLevel(object:GetFrameLevel() - 2)
		object.classBar.totems[i]:RegisterForClicks("RightButtonUp")
		object.classBar.totems[i]:SetScript("OnClick", totemBarOnClick)
		object.classBar.totems[i].bg = object.classBar.totems[i]:CreateTexture(nil, "BACKGROUND")
		object.classBar.totems[i].bg:SetAllPoints()
		object.classBar.totems[i].bg:SetAlpha(0.25)
		object.classBar.totems[i].icon = object.classBar.totems[i]:CreateTexture(nil, "OVERLAY")
		object.classBar.totems[i].icon:SetPoint("LEFT", 0, 0)
		object.classBar.totems[i].icon:SetTexCoord(0.03, 0.97, 0.03, 0.97)
		object.classBar.totems[i].bar = CreateFrame("StatusBar", nil, object.classBar.totems[i])
		object.classBar.totems[i].bar:SetFrameLevel(object:GetFrameLevel() - 1)
		object.classBar.totems[i].bar:SetPoint("TOPLEFT", object.classBar.totems[i].icon, "TOPRIGHT", 0, 0)
		object.classBar.totems[i].bar:SetPoint("BOTTOMRIGHT", object.classBar.totems[i], "BOTTOMRIGHT", 0, 0)
		object.classBar.totems[i].bar:Hide()
		object.classBar.totems[i].bar.timer = 0
		object.classBar.totems[i].bar:SetScript("OnUpdate", totemBarOnUpdate)
		object.classBar.totems[i].text = object.classBar.totems[i].bar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		object.classBar.totems[i].text:SetPoint("CENTER", 0, 1)
		if i == 1 then
			object.classBar.totems[i]:SetPoint("LEFT", object.classBar, "LEFT", 0, 0)
		else
			object.classBar.totems[i]:SetPoint("LEFT", object.classBar.totems[i - 1], "RIGHT", 1, 0)
		end
		if i ~= MAX_TOTEMS then
			texture = object.classBar.border:CreateTexture(nil, "OVERLAY")
			texture:SetPoint("TOPLEFT", object.classBar.totems[i], "TOPLEFT", 0, 0)
			texture:SetPoint("BOTTOMRIGHT", object.classBar.totems[i], "BOTTOMRIGHT", 1, 0)
			texture:SetTexture(0, 0, 0, 0.55)
		end
	end
	object.classBar.Update = function(self)
		self.active = 0
		for i = 1, 4 do
			duration, icon = select(4, GetTotemInfo(self.totems[i]:GetID()))
			self.totems[i].icon:SetTexture(icon)
			if duration > 0 then
				self.active = self.active + 1
				self.totems[i].bar:SetMinMaxValues(0, duration)
				totemBarOnUpdate(self.totems[i].bar, 1)
				self.totems[i].bar:Show()
			else
				self.totems[i].bar:Hide()
			end
		end
		if IUF.db.classBar.SHAMAN.active and self.active > 0 then
			self:SetHeight(IUF.db.classBar.SHAMAN.height)
			self:SetAlpha(1)
		else
			self:SetHeight(0.001)
			self:SetAlpha(0)
		end
		self:Show()
	end
	object.classBar:SetScript("OnEvent", function(self, event)
		if event == "PLAYER_ENTERING_WORLD" then
			IUF:ClassBarSetup(self)
		else
			self:Update()
		end
	end)
	object.classBar:SetScript("OnShow", function(self)
		self:SetScript("OnUpdate", classbarOnUpdate)
	end)
	object.classBar:RegisterEvent("PLAYER_TOTEM_UPDATE")
	object.classBar:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function IUF:ClassBarSetup(object)
	if object.classBar then
		texture = LibStub("LibSharedMedia-3.0"):Fetch("statusbar", self.db.classBar.SHAMAN.texture or "Smooth v2")
		width = (object.classBar:GetWidth() - 3) / 4
		for i = 1, 4 do
			object.classBar.totems[i]:SetWidth(width)
			object.classBar.totems[i]:SetHeight(self.db.classBar.SHAMAN.height)
			object.classBar.totems[i].icon:SetWidth(self.db.classBar.SHAMAN.height)
			object.classBar.totems[i].icon:SetHeight(self.db.classBar.SHAMAN.height)
			object.classBar.totems[i].bar:SetStatusBarTexture(texture)
			object.classBar.totems[i].bar:SetStatusBarColor(unpack(totemColor[totemOrder[i]]))
			object.classBar.totems[i].bg:SetTexture(texture)
			object.classBar.totems[i].bg:SetVertexColor(unpack(totemColor[totemOrder[i]]))
			self:SetFontString(object.classBar.totems[i].text, self.db.classBar.SHAMAN.fontFile, self.db.classBar.SHAMAN.fontSize, self.db.classBar.SHAMAN.fontAttribute, self.db.classBar.SHAMAN.fontShadow)
		end
		texture, width = nil
		object.classBar:Update()
		--[[
		if IUF.db.classBar.SHAMAN.showBlizzard then
			TotemFrame:SetAlpha(1)
			for i = 1, 4 do
				_G["TotemFrameTotem"..i]:EnableMouse(true)
			end
		else
			TotemFrame:SetAlpha(0)
			for i = 1, 4 do
				_G["TotemFrameTotem"..i]:EnableMouse(nil)
			end
		end
		]]
	end
end