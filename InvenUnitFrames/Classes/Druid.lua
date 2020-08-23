if select(2, UnitClass("player")) ~= "DRUID" then return end

local IUF = InvenUnitFrames
local _G = _G
local unpack = _G.unpack
local UnitPower = _G.UnitPower
local UnitPowerMax = _G.UnitPowerMax

function IUF:CreateClassBar(object)
	object.classBar = self:CreateStatusBar(object)
	if not(object:GetFrameLevel() and object:GetFrameLevel() > 3) then
		object:SetFrameLevel(4)
	end
	object.classBar:SetFrameLevel(object:GetFrameLevel() - 1)
	object.classBar.type = "DRUID"
	object.classBar.fadeTex:SetFrameLevel(object:GetFrameLevel() - 2)
	object.classBar.border = CreateFrame("Frame", nil, object.classBar)
	object.classBar.border:SetFrameLevel(object:GetFrameLevel() - 3)
	object.classBar.border:SetPoint("TOPLEFT", -1, 1)
	object.classBar.border:SetPoint("BOTTOMRIGHT", 1, -1)
	object.classBar.border:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeSize = 1,
	})
	object.classBar.border:SetBackdropColor(0, 0, 0, 0.2)
	object.classBar.border:SetBackdropBorderColor(0, 0, 0, 0.75)
	object.classBar:SetBar(0, 1, true)
	object.classBar.text = object.classBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	object.classBar.text:SetPoint("CENTER", 0, 1)
end

function IUF:ClassBarSetup(object)
	if object.classBar then
		object.classBar:SetTexture(LibStub("LibSharedMedia-3.0"):Fetch("statusbar", self.db.classBar.DRUID.texture or "Smooth v2"))
		object.classBar:SetColor(unpack(self.colordb.power[0]))
		self:SetFontString(object.classBar.text, self.db.classBar.DRUID.fontFile, self.db.classBar.DRUID.fontSize, self.db.classBar.DRUID.fontAttribute, self.db.classBar.DRUID.fontShadow)
		self.callbacks.DruidMana(object)
	end
end

function IUF:RegisterClassBarHandlerEvents()
	self:RegisterObjectValueHandler("vehicle", "DruidMana")
	self:RegisterObjectValueHandler("powertype", "DruidMana")
	self:RegisterObjectValueHandler("mana", "DruidMana")
	self:RegisterObjectValueHandler("manamax", "DruidMana")
end

function IUF:ClassBarOnUpdate(object)
	if not(object.values.powertype == 0 and object.values.vehicle) then
		object.values.manamax, object.values.mana = UnitPowerMax("player", 0), UnitPower("player", 0)
	end
end

function IUF.callbacks:DruidMana()
	if self.classBar then
		if self.values.powertype == 0 or self.values.vehicle or not IUF.db.classBar.DRUID.active then
			self.classBar:SetHeight(0.001)
			self.classBar:SetAlpha(0)
		elseif self.classBar:SetBar(self.values.mana, self.values.manamax, true) then
			IUF:SetStatusBarValue(self.classBar.text, IUF.db.classBar.DRUID.textType, self.values.mana, self.values.manamax)
			self.classBar:SetHeight(IUF.db.classBar.DRUID.height)
			self.classBar:SetAlpha(1)
		else
			self.classBar:SetHeight(0.001)
			self.classBar:SetAlpha(0)
		end
		self.classBar:Show()
	end
end