local IUF = InvenUnitFrames
local callbacks = IUF.callbacks

local _G = _G
local type = _G.type
local pairs = _G.pairs
local ipairs = _G.ipairs
local select = _G.select
local unpack = _G.unpack
local max = _G.math.max
local min = _G.math.min
local tinsert = _G.table.insert
local UnitName = _G.UnitName
local UnitClass = _G.UnitClass
local UnitFactionGroup = _G.UnitFactionGroup
local UnitSelectionColor = _G.UnitSelectionColor
local HasPetUI = _G.HasPetUI
local GetThreatStatusColor = _G.GetThreatStatusColor

local classificationText = { ["worldboss"] = "보스", ["rareelite"] = "희귀 정예", ["elite"] = "정예", ["rare"] = "희귀", ["trivial"] = "민간인" }
local classificationColor = { ["worldboss"] = { 1, 0.2, 0.2 }, ["rareelite"] = { 1, 0, 0.65 }, ["elite"] = { 1, 1, 0 }, ["rare"] = { 0.96, 0, 1 }, ["trivial"] = { 0.72, 0.72, 0.72 } }
local creatureIcons = {
	["야수"] = "Interface\\Icons\\Ability_Mount_JungleTiger", ["Beast"] = "Interface\\Icons\\Ability_Mount_JungleTiger",
	["악마"] = "Interface\\Icons\\Achievement_Boss_Kiljaedan", ["Demon"] = "Interface\\Icons\\Achievement_Boss_Kiljaedan",
	["용족"] = "Interface\\Icons\\Achievement_Boss_Sartharion_01", ["Dragonkin"] = "Interface\\Icons\\Achievement_Boss_Sartharion_01",
	["정령"] = "Interface\\Icons\\Spell_Frost_SummonWaterElemental", ["Elemental"] = "Interface\\Icons\\Spell_Frost_SummonWaterElemental",
	["거인"] = "Interface\\Icons\\Achievement_Dungeon_UlduarRaid_IronSentinel_01", ["Giant"] = "Interface\\Icons\\Achievement_Dungeon_UlduarRaid_IronSentinel_01",
	["인간형"] = "Interface\\Icons\\Achievement_Leader_King_Varian_Wrynn", ["Humanoid"] = "Interface\\Icons\\Achievement_Leader_King_Varian_Wrynn",
	["기계"] = "Interface\\Icons\\INV_Misc_Head_ClockworkGnome_01", ["Mechanical"] = "Interface\\Icons\\INV_Misc_Head_ClockworkGnome_01",
	["언데드"] = "Interface\\Icons\\INV_Misc_Head_Undead_01", ["Undead"] = "Interface\\Icons\\INV_Misc_Head_Undead_01",
}

local function lookupTable(tbl, v)
	for _, f in pairs(tbl) do
		if f == v then
			return true
		end
	end
	return nil
end

local function shortValue(value)
	if value > 1000000 then
		return ("%d만"):format(value / 10000)
	else
		return value
	end
end

local function shortValue2(value)
	if value >= 1000000 then
		return ("%.1fm"):format(value / 1000000)
	elseif value >= 1000 then
		return ("%.1fk"):format(value / 1000)
	else
		return value
	end
end

local statusBarValueFunc = {
	-- [퍼센트%]
	function(p, v)
		if v == 0 then
			return ""
		else
			return ("%d%%"):format(p / v * 100)
		end
	end,
	-- [현재]/[최대]
	function(p, v) return shortValue(p).."/"..shortValue(v) end,
	-- [현재 짧게]/[최대 짧게]
	function(p, v) return shortValue2(p).."/"..shortValue2(v) end,
	-- [현재]/[최대] [퍼센트%]
	function(p, v)
		if v == 0 then
			return shortValue(p).."/0"
		else
			return ("%s %d%%"):format(shortValue(p).."/"..shortValue(v), p / v * 100)
		end
	end,
	-- [현재 짧게]/[최대 짧게] [퍼센트%]
	function(p, v)
		if v == 0 then
			return shortValue2(p).."/0"
		else
			return ("%s %d%%"):format(shortValue2(p).."/"..shortValue2(v), p / v * 100)
		end
	end,
	-- [퍼센트%] [현재]/[최대]
	function(p, v)
		if v == 0 then
			return shortValue(p).."/0"
		else
			return ("%d%% %s"):format(p / v * 100, shortValue(p).."/"..shortValue(v))
		end
	end,
	-- [퍼센트%] [현재 짧게]/[최대 짧게]
	function(p, v)
		if v == 0 then
			return shortValue2(p).."/0"
		else
			return ("%d%% %s"):format(p / v * 100, shortValue2(p).."/"..shortValue2(v))
		end
	end,
	-- [손실]
	function(p, v) return shortValue(v - p) end,
	-- [손실 짧게]
	function(p, v) return shortValue2(v - p) end,
	-- [현재]
	function(p) return shortValue(p) end,
	-- [현재 짧게]
	function(p) return shortValue2(p) end,
	-- [최대]
	function(p, v) return shortValue(v) end,
	-- [최대 짧게]
	function(p, v) return shortValue2(v) end,
	-- [현재 실수치]/[최대 실수치]
	function(p, v) return p.."/"..v end,
	-- [현재 실수치]/[최대 실수치] [퍼센트%]
	function(p, v)
		if v == 0 then
			return p.."/0"
		else
			return ("%d/%d %d%%"):format(p, v, p / v * 100)
		end
	end,
	-- [퍼센트%] [현재 실수치]/[최대 실수치]
	function(p, v)
		if v == 0 then
			return p.."/0"
		else
			return ("%d%% %d/%d"):format(p / v * 100, p, v)
		end
	end,
	-- [현재 실수치]
	function(p, v) return p end,
	-- [최대 실수치]
	function(p, v) return v end,
}

function IUF:SetStatusBarValue(fontString, valueType, value, valuemax)
	if statusBarValueFunc[valueType or 0] then
		fontString:SetText(statusBarValueFunc[valueType](value, valuemax))
	else
		fontString:SetText(nil)
	end
end

function IUF:HasStatusBarDisplay(display)
	if statusBarValueFunc[display or 0] then
		return true
	else
		return nil
	end
end

function IUF:RegisterObjectValueHandler(key, ...)
	if type(key) == "string" then
		self.valueHandler[key] = self.valueHandler[key] or {}
		local callback
		for i = 1, select("#", ...) do
			callback = select(i, ...)
			if type(callback) == "string" and type(callbacks[callback]) == "function" and not lookupTable(self.valueHandler[key], callback) then
				tinsert(self.valueHandler[key], callback)
			end
		end
	end
end

function IUF:TriggerCallback(object, callback)
	if object.shown then
		if object.needElement then
			object.needElement = nil
			self:CreateObjectElements(object)
			self:SetObjectSkin(object)
		end
		callbacks[callback](object)
	else
		object.valuesChanged = true
	end
end

function IUF:UpdateAllCallbacks(object)
	if object.shown then
		object.valuesChanged = nil
		if object.needElement then
			object.needElement = nil
			IUF:CreateObjectElements(object)
			IUF:SetObjectSkin(object)
		else
			for method, func in pairs(callbacks) do
				if method ~= "Update" and method ~= "UpdateAllCombo" and type(func) == "function" then
					func(object)
				end
			end
		end
	end
end

function callbacks:Update()
	if self.values.guid then
		IUF:UpdateObject(self)
	end
	for _, fade in ipairs(self.fadeBars) do
		fade:Hide()
	end
end

function callbacks:Portrait()
	if self.portrait:IsShown() then
		if self.portrait.show3dModel and self.values.connect and self.values.visible then
			self.portrait.model3d:ClearModel()
			self.portrait.model3d:SetUnit(self.unit)
			self.portrait.model3d:SetCamera(0)
			self.portrait.model3d:Show()
			self.portrait.model2d:Hide()
		else
			SetPortraitTexture(self.portrait.model2d, self.unit)
			self.portrait.model2d:SetDesaturated(self.offlineIcon:IsShown())
			self.portrait.model2d:Show()
			self.portrait.model3d:Hide()
		end
	end
end

local namevalue

function callbacks:Name()
	if self.nameText:IsShown() then
		if self.values.vehicle and (self.objectType == "party" or (self.objectType == "player" and not IUF.db.units.pet.active)) then
			namevalue = UnitName(self.realunit)
		else
			namevalue = self.values.name
		end
		if self.values.group then
			namevalue = namevalue.."|cffffffff("..self.values.group..")|r"
		end
		self.nameText:SetText(namevalue)
	else
		self.nameText:SetText(nil)
	end
end

function callbacks:NameColor()
	if self.values.tapped then
		self.nameText:SetTextColor(0.76, 0.76, 0.76)
	elseif self.vehicleunit and self.values.vehicle then
		self.nameText:SetTextColor(unpack(IUF.colordb.class.PET))
	elseif self.nameText.classColor and IUF.colordb.class[self.values.class or ""] then
		self.nameText:SetTextColor(unpack(IUF.colordb.class[self.values.class]))
	elseif IUF.db.skin == "Blizzard" then
		self.nameText:SetTextColor(1, 0.82, 0)
	else
		self.nameText:SetTextColor(1, 1, 1)
	end
end

function callbacks:Level()
	if self.levelText:IsShown() then
		if self.values.role then
			self.levelText:SetText("*")
			while self.levelText:GetWidth() < self.roleIcon:GetWidth() do
				self.levelText:SetFormattedText("%s%s", self.levelText:GetText(), "*")
			end
		elseif self.values.level and self.values.level > 0 then
			color = GetQuestDifficultyColor(self.values.level)
			self.levelText:SetTextColor(color.r, color.g, color.b)
			if self.values.elite then
				self.levelText:SetText(self.values.level.."+")
			else
				self.levelText:SetText(self.values.level)
			end
		else
			self.levelText:SetText("??")
			if self.objectType == "party" or self.objectType == "partypet" or self.objectType == "pet" then
				self.levelText:SetTextColor(1, 1, 1)
			else
				self.levelText:SetTextColor(1, 0.1, 0.1)
			end
		end
	else
		self.levelText:SetText(nil)
	end
end

function callbacks:Role()
	if self.values.role then
		self.roleIcon:Show()
		self.levelText:SetAlpha(0)
		if self.values.role == 1 then
			-- Tanker
			self.roleIcon:SetTexCoord(0.5, 0.75, 0, 1)
		elseif self.values.role == 2 then
			-- Healer
			self.roleIcon:SetTexCoord(0.75, 1, 0, 1)
		else
			-- Dealer
			self.roleIcon:SetTexCoord(0.25, 0.5, 0, 1)
		end
	else
		self.roleIcon:Hide()
		self.levelText:SetAlpha(1)
	end
end

function callbacks:Class()
	if self.classIcon.use then
		self.classIcon:Show()
		self.creatureIcon:Hide()
		if CLASS_BUTTONS[self.values.class or ""] then
			if self.classIcon.isCircle then
				self.classIcon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
			else
				self.classIcon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")
			end
			self.classIcon:SetWidth(self.classIcon:GetHeight())
			self.classIcon:SetTexCoord(unpack(CLASS_BUTTONS[self.values.class]))
			if IUF.db.skin == "Blizzard" then
				if self.texture1:GetTexture() then
					self.texture1:Show()
				else
					self.classIcon:SetTexture("")
				end
			end
		else
			self.classIcon:SetTexture("")
			if IUF.db.skin == "Blizzard" then
				self.texture1:Hide()
			end
			if self.happiness and not self.happiness.use then
				if HasPetUI() then
					self.classIcon:SetWidth(self.classIcon:GetHeight())
					self.happiness:Update()
					self.happiness:ClearAllPoints()
					self.happiness:SetAllPoints(self.classIcon)
					self.happiness:Show()
				else
					self.classIcon:SetWidth(0.001)
					self.happiness:Hide()
				end
			elseif self.values.creature and creatureIcons[self.values.creature] and IUF.db.skin ~= "Blizzard" then
				self.classIcon:SetWidth(self.classIcon:GetHeight())
				self.creatureIcon:SetTexture(creatureIcons[self.values.creature])
				self.creatureIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
				self.creatureIcon:Show()
			else
				self.classIcon:SetWidth(0.0001)
			end
		end
	else
		self.classIcon:SetTexCoord(0, 0, 0, 0)
		self.classIcon:SetWidth(0.0001)
		self.classIcon:Show()
		self.classIcon:Hide()
		self.creatureIcon:Hide()
		if IUF.db.skin == "Blizzard" then
			self.texture1:Hide()
		end
		if self.happiness and not self.happiness.use then
			self.happiness:Hide()
		end
	end
	if self.classText:IsShown() then
		if self.values.player and self.values.class and RAID_CLASS_COLORS[self.values.class] then
			color = RAID_CLASS_COLORS[self.values.class]
			self.classText:SetTextColor(color.r, color.g, color.b)
			self.classText:SetText(self.values.classtext or UnitClass(self.unit or ""))
		elseif self.happiness and not self.classIcon.use then
			if HasPetUI() then
				self.classText:SetText(" ")
				self.happiness:SetHeight(self.classText:GetHeight() * 1.4)
				self.happiness:SetWidth(self.happiness:GetHeight())
				while self.classText:GetWidth() < self.happiness:GetHeight() do
					self.classText:SetFormattedText("%s%s", self.classText:GetText(), " ")
				end
				self.happiness:Update()
				self.happiness:ClearAllPoints()
				self.happiness:SetPoint("LEFT", self.classText, "LEFT", 0, -1)
				self.happiness:Show()
			else
				self.happiness:Hide()
				self.classText:SetText(nil)
			end
		elseif self.values.classification and classificationText[self.values.classification] then
			self.classText:SetTextColor(unpack(classificationColor[self.values.classification]))
			if self.values.creature then
				self.classText:SetFormattedText("%s |cffffffff%s|r", classificationText[self.values.classification], self.values.creature)
			else
				self.classText:SetText(classificationText[self.values.classification])
			end
		elseif self.values.creature then
			self.classText:SetFormattedText("|cffffffff%s|r", self.values.creature)
		else
			self.classText:SetText(nil)
		end
	else
		self.classText:SetText(nil)
	end
	if self.happiness and self.happiness.use then
		if HasPetUI() then
			self.happiness:SetWidth(self.happiness:GetHeight())
			self.happiness:Update()
			self.happiness:Show()
		else
			self.happiness:SetWidth(0.0001)
			self.happiness.tex:SetTexCoord(0, 0, 0, 0)
			self.happiness:Show()
		end
	end
end

function callbacks:Race()
	--self.raceText:SetText(nil)
end

local op, tp

local function updateAnchorWidth(object)
	if object:IsVisible() then
		op = object:GetLeft()
		if op then
			tp = min(object.healthText4:GetText() and object.healthText4:GetLeft() or op, object.powerText4:GetText() and object.powerText5:GetLeft() or op)
			object.leftAnchorFrame:SetWidth(max(op - tp, 0) + 1)
		else
			object.leftAnchorFrame:SetWidth(1)
		end
		op = object:GetRight()
		if op then
			tp = max(object.healthText5:GetText() and object.healthText5:GetRight() or op, object.powerText5:GetText() and object.powerText5:GetRight() or op)
			object.rightAnchorFrame:SetWidth(max(tp - op, 0) + 1)
		else
			object.rightAnchorFrame:SetWidth(1)
		end
	else
		object.leftAnchorFrame:SetWidth(1)
		object.rightAnchorFrame:SetWidth(1)
	end
end

local function updateStatusText(text, value, valuemax, combat)
	if text.display and text:IsShown() then
		if text.combat then
			if combat or IUF.inCombat then
				IUF:SetStatusBarValue(text, text.display, value, valuemax)
				return true
			end
		else
			IUF:SetStatusBarValue(text, text.display, value, valuemax)
			return true
		end
	end
	text:SetText(nil)
	return nil
end

function callbacks:Health()
	if self.healthBar:SetBar(self.values.health, self.values.healthmax) then
		for i = 1, 5 do
			updateStatusText(self["healthText"..i], self.values.health, self.values.healthmax, self.values.combat)
		end
		updateAnchorWidth(self)
	end
end

function callbacks:Power()
	if self.powerBar:SetBar(self.values.power, self.values.powermax) then
		for i = 1, 5 do
			updateStatusText(self["powerText"..i], self.values.power, self.values.powermax, self.values.combat)
		end
		updateAnchorWidth(self)
	end
end

function callbacks:HealthColor()
	if self.vehicleunit and self.values.vehicle then
		self.healthBar:SetColor(unpack(IUF.colordb.class.PET))
	elseif IUF.colordb.class[self.values.faction or ""] then
		if self.healthBar.classColor and IUF.colordb.class[self.values.class or ""] and self.values.class ~= "PET" and IUF.db.useEnemyClassColor then
			self.healthBar:SetColor(unpack(IUF.colordb.class[self.values.class]))
		else
			self.healthBar:SetColor(unpack(IUF.colordb.class[self.values.faction]))
		end
	elseif self.healthBar.classColor and IUF.colordb.class[self.values.class or ""] then
		self.healthBar:SetColor(unpack(IUF.colordb.class[self.values.class]))
	else
		self.healthBar:SetColor(unpack(IUF.colordb.class.FRIEND))
	end
end

function callbacks:PowerColor()
	if self.powerBar:IsShown() then
		self.powerBar.fadeTex.value = 0
		self.powerBar:SetColor(unpack(IUF.colordb.power[self.values.powertype or 0] or IUF.colordb.power[0]))
	end
end

function callbacks:Combo()
	if self.comboFrame and self.comboFrame:IsShown() then
		if self.values.combo then
			for i = 1, 5 do
				if i > self.values.combo then
					self.comboFrame[i]:Hide()
				elseif not self.comboFrame[i]:IsShown() then
					self.comboFrame[i]:Show()
					self.comboFrame[i].fadeInfo.mode = "IN"
					self.comboFrame[i].fadeInfo.timeToFade = COMBOFRAME_HIGHLIGHT_FADE_IN
					self.comboFrame[i].fadeInfo.finishedFunc = ComboPointShineFadeIn
					self.comboFrame[i].fadeInfo.finishedArg1 = self.comboFrame[i].shine
					UIFrameFade(self.comboFrame[i].highlight, self.comboFrame[i].fadeInfo)
				end
			end
		else
			for i = 1, 5 do
				self.comboFrame[i]:Hide()
			end
		end
	end
end

function callbacks:UpdateAllCombo()
	if self.realunit == "player" then
		for object in pairs(IUF.visibleObject) do
			IUF.handlers.UNIT_COMBO_POINTS(object)
		end
	end
end

function callbacks:RaidIcon()
	if self.raidIcon.use then
		if self.values.raidtarget then
			SetRaidTargetIconTexture(self.raidIcon, self.values.raidtarget)
			self.raidIcon:SetWidth(self.raidIcon:GetHeight())
		else
			self.raidIcon:SetWidth(0.001)
		end
		self.raidIcon:Show()
	else
		self.raidIcon:Hide()
	end
end

function callbacks:CombatIcon()
	if self.combatIcon.use then
		if self.values.combat then
			self.combatIcon:SetTexCoord(0.5, 1, 0, 0.48)
			self.combatIcon:SetWidth(self.combatIcon:GetHeight())
		elseif self.values.resting then
			self.combatIcon:SetTexCoord(0, 0.5, 0, 0.421875)
			self.combatIcon:SetWidth(self.combatIcon:GetHeight())
		else
			self.combatIcon:SetWidth(0.001)
		end
		self.combatIcon:Show()
	else
		self.combatIcon:Hide()
	end
end

function callbacks:PvPIcon()
	if self.pvpIcon.use then
		self.pvpIcon:Show()
		if self.values.pvp then
			self.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..(self.values.pvp == 1 and "Horde" or "Alliance"))
			self.pvpIcon:SetWidth(self.pvpIcon:GetHeight())
			if self.pvpTimer then
				self.pvpTimer:Show()
			end
		else
			self.pvpIcon:SetWidth(0.001)
			if self.pvpTimer then
				self.pvpTimer:Hide()
			end
		end
	else
		self.pvpIcon:Hide()
		if self.pvpTimer then
			self.pvpTimer:Hide()
		end
	end
end

function callbacks:LeaderIcon()
	if self.leaderIcon.use then
		self.leaderIcon:Show()
		if self.values.leader then
			self.leaderIcon:SetTexture("Interface\\GroupFrame\\UI-Group-"..(self.values.leader == 1 and "Leader" or "Assistant").."Icon")
			self.leaderIcon:SetWidth(self.leaderIcon:GetHeight())
		else
			self.leaderIcon:SetWidth(0.0001)
		end
	else
		self.leaderIcon:Hide()
	end
end

function callbacks:LootIcon()
	if self.lootIcon.use then
		self.lootIcon:Show()
		if self.values.looter then
			self.lootIcon:SetWidth(self.lootIcon:GetHeight())
		else
			self.lootIcon:SetWidth(0.0001)
		end
	else
		self.lootIcon:Hide()
	end
end

function callbacks:OfflineIcon()
	if self.portrait:IsShown() and not self.values.connect then
		self.portrait.model2d:SetDesaturated(true)
		self.offlineIcon:Show()
	else
		self.portrait.model2d:SetDesaturated(nil)
		self.offlineIcon:Hide()
	end
end

function callbacks:State()
	if self.stateText:IsShown() then
		if self.values.connect then
			if self.values.ghost then
				self.stateText:SetText("유령")
			elseif self.values.dead then
				self.stateText:SetText("죽음")
			elseif self.values.tapped then
				self.stateText:SetText("선점")
			elseif self.values.afk then
				self.stateText:SetText("자리")
			elseif self.values.threatvalue and self.values.threatvalue > 0 then
				self.stateText:SetFormattedText("%d%%", self.values.threatvalue)
			else
				self.stateText:SetText(nil)
			end
		else
			self.stateText:SetText("오프")
		end
	else
		self.stateText:SetText(nil)
	end
end

function callbacks:StateColor()
	if self.stateText:IsShown() then
		if self.values.dead or self.values.ghost or not self.values.connect then
			self.stateText:SetTextColor(0.58, 0.58, 0.58)
		elseif self.values.tapped then
			self.stateText:SetTextColor(0.76, 0.76, 0.76)
		elseif self.values.threatvalue and self.values.threatvalue > 0 then
			self.stateText:SetTextColor(GetThreatStatusColor(self.values.threatstatus))
		else
			self.stateText:SetTextColor(1, 1, 1)
		end
	end
	if self.portrait:IsShown() then
		if self.values.dead or self.values.ghost or not self.values.connect then
			self.portrait.border:SetVertexColor(0.58, 0.58, 0.58)
		elseif self.values.tapped then
			self.portrait.border:SetVertexColor(0.76, 0.76, 0.76)
		else
			self.portrait.border:SetVertexColor(1, 1, 1)
		end
	end
end

function callbacks:Elite()
	if self.eliteFrame then
		if IUF.db.skin == "Blizzard" then
			if self.overlay1.setting then
				-- none
			elseif self.eliteFrame.use then
				if self.objectType == "player" or self.values.classification == "worldboss" or self.values.classification == "elite" then
					self.overlay1:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite")
					self.overlay2:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite")
					self.overlay3:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite")
				elseif self.values.classification == "rareelite" then
					self.overlay1:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite")
					self.overlay2:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite")
					self.overlay3:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite")
				elseif self.values.classification == "rare" then
					self.overlay1:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare")
					self.overlay2:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare")
					self.overlay3:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare")
				else
					self.overlay1:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame")
					self.overlay2:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame")
					self.overlay3:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame")
				end
			else
				self.overlay1:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame")
				self.overlay2:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame")
				self.overlay3:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame")
			end
		elseif self.eliteFrame.use then
			if self.objectType == "player" or self.values.classification == "worldboss" or self.values.classification == "elite" then
				self.eliteFrame.tex:SetTexture("Interface\\AddOns\\InvenUnitFrames\\Texture\\Elite")
				self.eliteFrame.tex:SetVertexColor(1, 1, 0)
				self.eliteFrame:Show()
			elseif self.values.classification == "rareelite" then
				self.eliteFrame.tex:SetTexture("Interface\\AddOns\\InvenUnitFrames\\Texture\\Elite")
				self.eliteFrame.tex:SetVertexColor(1, 1, 1)
				self.eliteFrame:Show()
			elseif self.values.classification == "rare" then
				self.eliteFrame.tex:SetTexture("Interface\\AddOns\\InvenUnitFrames\\Texture\\Rare")
				self.eliteFrame.tex:SetVertexColor(1, 1, 1)
				self.eliteFrame:Show()
			else
				self.eliteFrame.tex:SetTexture(nil)
				self.eliteFrame:Hide()
			end
		else
			self.eliteFrame.tex:SetTexture(nil)
			self.eliteFrame:Hide()
		end
	end
end

function callbacks:PetAlpha()
	if self.objectType == "pet" or self.objectType == "partypet" then
		if self.values.connect then
			self:SetAlpha(1)
		else
			self:SetAlpha(0)
		end
	end
end

function callbacks:Aggro()
	if self.aggroBorder then
		if self.values.aggro then
			if self.portrait:IsShown() and IUF.db.skin ~= "Nivaya" then
				IUF:RegisterFlash(self.portrait.aggro)
			else
				IUF:UnregisterFlash(self.portrait.aggro)
			end
			IUF:RegisterFlash(self.aggroBorder)
		else
			IUF:UnregisterFlash(self.portrait.aggro)
			IUF:UnregisterFlash(self.aggroBorder)
		end
	end
end

function callbacks:BarFill()
	if IUF.db.skin == "Blizzard" and self.background2:IsShown() then
		if self.values.tapped then
			self.background2:SetVertexColor(0.5, 0.5, 0.5)
		else
			self.background2:SetVertexColor(UnitSelectionColor(self.unit))
		end
	end
end

function callbacks:Dispel()
	if IUF.db.dispel.active and self.values.dispel and DebuffTypeColor[self.values.dispel] then
		self.dispelFrame:ClearAllPoints()
		if self.highlightfunc then
			self.highlightfunc(self.dispelFrame, self)
		else
			self.dispelFrame:SetAllPoints(self)
		end
		self.dispelFrame:SetVertexColor(DebuffTypeColor[self.values.dispel].r, DebuffTypeColor[self.values.dispel].g, DebuffTypeColor[self.values.dispel].b)
		self.dispelFrame:Show()
	else
		self.dispelFrame:Hide()
	end
end

local spellRankText = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX", "XXI", "XXII", "XXIII", "XXIV", "XXV", "XXVI", "XXVII", "XXVIII", "XXIX", "XXX"}
local rankNumber

function callbacks:CastingBar()
	if self.castingBar.use and self.values.castingEndTime then
		self.castingBar:Hide()
		self.castingBar:SetHeight(self.castingBar.height)
		self.castingBar.icon:SetTexture(self.values.castingIcon)
		self.castingBar.icon:SetHeight(self.castingBar.icon:GetWidth())
		self.castingBar.bar.isChannel = self.values.castingIsChannel
		self.castingBar.bar.startTime = self.values.castingStartTime / 1000
		self.castingBar.bar.endTime = self.values.castingEndTime / 1000
		self.castingBar.bar:SetMinMaxValues(self.castingBar.bar.startTime, self.castingBar.bar.endTime)
		callbacks.CastingBarColor(self)
		if self.castingBar.text:IsShown() then
			rankNumber = tonumber((self.values.castingRank or ""):match("(%d+)") or "")
			if rankNumber and spellRankText[rankNumber] then
				self.castingBar.text:SetFormattedText("%s %s", self.values.castingName, spellRankText[rankNumber])
			elseif (self.values.castingRank or ""):len() > 1 then
				self.castingBar.text:SetFormattedText("%s (%s)", self.values.castingName, self.values.castingRank)
			else
				self.castingBar.text:SetText(self.values.castingName)
			end
		end
		self.castingBar.bar.time:SetText(nil)
		self.castingBar:SetAlpha(1)
		self.castingBar.bar:Show()
	else
		self.castingBar.bar:Hide()
		self.castingBar.icon:SetTexture(nil)
		self.castingBar.icon:SetHeight(0.001)
		self.castingBar:SetAlpha(0)
		self.castingBar:SetHeight(0.001)
		self.castingBar.bar.isChannel, self.castingBar.bar.startTime, self.castingBar.bar.endTime = nil
	end
	self.castingBar:Show()
end

function callbacks:CastingBarColor()
	if self.values.castingIsShield then
		self.castingBar.bar:SetStatusBarColor(unpack(IUF.colordb.casting.SHIELD))
	elseif self.castingBar.bar.isChannel then
		self.castingBar.bar:SetStatusBarColor(unpack(IUF.colordb.casting.CHANNEL))
	else
		self.castingBar.bar:SetStatusBarColor(unpack(IUF.colordb.casting.NORMAL))
	end
end