local IUF = InvenUnitFrames
local Heal = CreateFrame("Frame", "InvenUnitFrames_Heal", IUF)
Heal:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
Heal:RegisterEvent("ADDON_LOADED")
IUF.modules.Heal = Heal

local _G = _G
local select = _G.select
local CreateFrame = _G.CreateFrame

local HealComm = LibStub("LibHealComm-4.0")
local directHeal = HealComm.DIRECT_HEALS
local amount

function Heal:ADDON_LOADED()
	self:UnregisterEvent("ADDON_LOADED")
	self.firstRun = true
	self:SetActive()
end

function Heal:CreateHealBar(object)
	object.healthBar.extra.healBar = CreateFrame("StatusBar", nil, object.healthBar)
	object.healthBar.extra.healBar:SetFrameLevel(object.healthBar:GetFrameLevel())
	object.healthBar.extra.healBar:SetAllPoints()
	object.healthBar.extra.healBar:SetAlpha(IUF.db.heal.alpha)
	object.healthBar:SetupExtraBar("healBar")
	object.healthBar.extra.healBar:SetValue(0)
end

function Heal:Setup(object)
	if object == nil then
		for _, obj in pairs(IUF.units) do
			self:Setup(obj)
		end
	elseif object.healthBar and object.healthBar.extra.healBar then
		object.healthBar.extra.healBar:SetAlpha(IUF.db.heal.alpha)
	end
end

function IUF.callbacks:Heal()
	if self.values.heal and self.values.health and self.healthBar then
		if self.values.heal > 0 then
			if not self.healthBar.extra.healBar then
				Heal:CreateHealBar(self)
			end
			self.healthBar.extra.healBar:SetValue(self.values.heal + self.values.health)
		elseif self.healthBar.extra.healBar then
			self.healthBar.extra.healBar:SetValue(0)
		end
	end
end

function IUF.callbacks:HealUpdate()
	Heal:UpdateObjectHeal(self)
end

function Heal:GetHealAmount(guid)
	if IUF.db.heal.active and guid then
		return ((HealComm:GetOthersHealAmount(guid, directHeal) or 0) + (IUF.db.heal.player and HealComm:GetHealAmount(guid, directHeal, nil, IUF.playerGUID) or 0) * HealComm:GetHealModifier(guid) or 1)
	else
		return 0
	end
end

function Heal:UpdateGUIDHeal(guid)
	amount = self:GetHealAmount(guid)
	for object in pairs(IUF.visibleObject) do
		if object.values.guid == guid then
			object.values.heal = amount
		end
	end
end

function Heal:UpdateObjectHeal(object)
	object.values.heal = self:GetHealAmount(object.values.guid)
end

function Heal:SetActive()
	if IUF.db.heal.active then
		if not self.active then
			self.active = true
			HealComm.RegisterCallback(self, "HealComm_HealStarted", "HealUpdated")
			HealComm.RegisterCallback(self, "HealComm_HealUpdated", "HealUpdated")
			HealComm.RegisterCallback(self, "HealComm_HealDelayed", "HealUpdated")
			HealComm.RegisterCallback(self, "HealComm_HealStopped", "HealUpdated")
			HealComm.RegisterCallback(self, "HealComm_ModifierChanged", "ModifierChange")
			if self.firstRun then
				self.firstRun = nil
				IUF:RegisterObjectValueHandler("guid", "HealUpdate")
				IUF:RegisterObjectValueHandler("toggle", "HealUpdate")
				IUF:RegisterObjectValueHandler("heal", "Heal")
				IUF:RegisterObjectValueHandler("health", "Heal")
			end
		end
		for _, object in pairs(IUF.units) do
			self:UpdateObjectHeal(object)
		end
	elseif self.active then
		self.active = nil
		HealComm.UnregisterCallback(self, "HealComm_HealStarted")
		HealComm.UnregisterCallback(self, "HealComm_HealUpdated")
		HealComm.UnregisterCallback(self, "HealComm_HealDelayed")
		HealComm.UnregisterCallback(self, "HealComm_HealStopped")
		HealComm.UnregisterCallback(self, "HealComm_ModifierChanged")
		if not self.firstRun then
			for _, object in pairs(IUF.units) do
				object.values.heal = 0
			end
		end
	end
end

function Heal:HealUpdated(_, _, _, healType, _, ...)
	if healType == directHeal then
		for i = 1, select("#", ...) do
			self:UpdateGUIDHeal(select(i, ...))
		end
	end
end

function Heal:ModifierChange(_, guid)
	self:UpdateGUIDHeal(guid)
end