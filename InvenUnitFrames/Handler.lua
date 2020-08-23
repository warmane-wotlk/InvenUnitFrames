local IUF = InvenUnitFrames
local handlers = IUF.handlers
handlers:Hide()

local _G = _G
local type = _G.type
local pairs = _G.pairs
local ipairs = _G.ipairs
local select = _G.select
local tinsert = _G.table.insert
local IsResting = _G.IsResting
local UnitExists = _G.UnitExists
local UnitIsUnit = _G.UnitIsUnit
local UnitGUID = _G.UnitGUID
local UnitIsVisible = _G.UnitIsVisible
local UnitIsAFK = _G.UnitIsAFK
local UnitName = _G.UnitName
local UnitIsPlayer = _G.UnitIsPlayer
local UnitClass = _G.UnitClass
local UnitLevel = _G.UnitLevel
local UnitClassification = _G.UnitClassification
local UnitCanAttack = _G.UnitCanAttack
local UnitHealth = _G.UnitHealth
local UnitHealthMax = _G.UnitHealthMax
local UnitPower = _G.UnitPower
local UnitPowerMax = _G.UnitPowerMax
local UnitPowerType = _G.UnitPowerType
local UnitIsDead = _G.UnitIsDead
local UnitIsGhost = _G.UnitIsGhost
local UnitIsPVP = _G.UnitIsPVP
local UnitIsEnemy = _G.UnitIsEnemy
local UnitIsPVPFreeForAll = _G.UnitIsPVPFreeForAll
local UnitHasVehicleUI = _G.UnitHasVehicleUI
local UnitIsConnected =_G.UnitIsConnected
local UnitIsTapped = _G.UnitIsTapped
local UnitPlayerControlled = _G.UnitPlayerControlled
local UnitIsTappedByPlayer = _G.UnitIsTappedByPlayer
local UnitIsTappedByAllThreatList = _G.UnitIsTappedByAllThreatList
local UnitGroupRolesAssigned = _G.UnitGroupRolesAssigned
local UnitAffectingCombat = _G.UnitAffectingCombat
local UnitDetailedThreatSituation = _G.UnitDetailedThreatSituation
local UnitIsPartyLeader = _G.UnitIsPartyLeader
local GetPetHappiness = _G.GetPetHappiness
local GetComboPoints = _G.GetComboPoints
local GetLootMethod = _G.GetLootMethod
local GetRaidRosterInfo = _G.GetRaidRosterInfo
local GetRaidTargetIndex = _G.GetRaidTargetIndex
local GetNumRaidMembers = _G.GetNumRaidMembers
local GetNumPartyMembers = _G.GetNumPartyMembers
local UnitCastingInfo = _G.UnitCastingInfo
local UnitChannelInfo = _G.UnitChannelInfo
local UnitCreatureType = _G.UnitCreatureType

local Aggro = LibStub("LibAggro-1.0", true)
local groupGUID = LibStub("LibGroupGUIDs-1.0", true)

local targetFrame, targetUnit
local updateEvents = { "OnUpdate", "UNIT_NAME_UPDATE", "UNIT_MAXHEALTH", "UNIT_HEALTH", "UNIT_DISPLAYPOWER", "RAID_TARGET_UPDATE", "PLAYER_UPDATE_RESTING", "UNIT_HAPPINESS", "UNIT_SPELLCAST_START", "UNIT_AURA", "UNIT_COMBO_POINTS", "PLAYER_UPDATE_RESTING" }

--[[
UNIT_LEVEL
UNIT_CLASSIFICATION_CHANGED
UNIT_FACTION
]]

local creatureTypes = {
	["야수"] = true, ["Beast"] = true,
	["악마"] = true, ["Demon"] = true,
	["용족"] = true, ["Dragonkin"] = true,
	["정령"] = true, ["Elemental"] = true,
	["거인"] = true, ["Giant"] = true,
	["인간형"] = true, ["Humanoid"] = true,
	["기계"] = true, ["Mechanical"] = true,
	["언데드"] = true, ["Undead"] = true,
}
local factionGroups = { ["Horde"] = 1, ["Alliance"] = 2 }

function IUF:UpdateObject(object)
	if object.unit and UnitExists(object.unit) then
		handlers.PLAYER_ENTERING_WORLD(object)
		IUF:RefreshObject(object)
	end
end

function IUF:UpdateAllObject()
	for _, object in pairs(self.units) do
		self:UpdateObject(object)
	end
end

function IUF:RegisterHandlerEvents()
	self:RegisterObjectValueHandler("guid", "Update", "Portrait")
	self:RegisterObjectValueHandler("connect", "Portrait", "OfflineIcon", "State", "StateColor", "PetAlpha")
	self:RegisterObjectValueHandler("modelfile", "Portrait")
	self:RegisterObjectValueHandler("visible", "Portrait")
	self:RegisterObjectValueHandler("name", "Name")
	self:RegisterObjectValueHandler("group", "Name")
	self:RegisterObjectValueHandler("class", "Class", "NameColor", "HealthColor")
	self:RegisterObjectValueHandler("creature", "Class")
	self:RegisterObjectValueHandler("faction", "NameColor", "HealthColor", "BarFill")
	self:RegisterObjectValueHandler("vehicle", "NameColor", "HealthColor", "UpdateAllCombo")
	self:RegisterObjectValueHandler("player", "Class", "BarFill")
	self:RegisterObjectValueHandler("happiness", "Class")
	self:RegisterObjectValueHandler("classification", "Class", "Elite")
	self:RegisterObjectValueHandler("race", "Race")
	self:RegisterObjectValueHandler("level", "Level")
	self:RegisterObjectValueHandler("elite", "Level")
	self:RegisterObjectValueHandler("health", "Health")
	self:RegisterObjectValueHandler("healthmax", "Health")
	self:RegisterObjectValueHandler("powertype", "PowerColor")
	self:RegisterObjectValueHandler("power", "Power")
	self:RegisterObjectValueHandler("powermax", "Power")
	self:RegisterObjectValueHandler("afk", "State")
	self:RegisterObjectValueHandler("dead", "State", "StateColor")
	self:RegisterObjectValueHandler("ghost", "State", "StateColor")
	self:RegisterObjectValueHandler("tapped", "NameColor", "BarFill", "State", "StateColor")
	self:RegisterObjectValueHandler("aggro", "Aggro")
	self:RegisterObjectValueHandler("threatvalue", "State")
	self:RegisterObjectValueHandler("threatstatus", "StateColor")
	self:RegisterObjectValueHandler("combat", "CombatIcon", "Health", "Power")
	self:RegisterObjectValueHandler("resting", "CombatIcon")
	self:RegisterObjectValueHandler("raidtarget", "RaidIcon")
	self:RegisterObjectValueHandler("leader", "LeaderIcon")
	self:RegisterObjectValueHandler("looter", "LootIcon")
	self:RegisterObjectValueHandler("pvp", "PvPIcon", "BarFill")
	self:RegisterObjectValueHandler("castingEndTime", "CastingBar")
	self:RegisterObjectValueHandler("castingIsShield", "CastingBarColor")
	self:RegisterObjectValueHandler("castingIsChannel", "CastingBarColor")
	self:RegisterObjectValueHandler("dispel", "Dispel")
	self:RegisterObjectValueHandler("role", "Role", "Level")
	self:RegisterObjectValueHandler("combo", "Combo")
	handlers:RegisterEvent("PLAYER_ENTERING_WORLD")
	handlers:RegisterEvent("UNIT_MANA")
	handlers:RegisterEvent("UNIT_MAXMANA")
	handlers:RegisterEvent("UNIT_RAGE")
	handlers:RegisterEvent("UNIT_MAXRAGE")
	handlers:RegisterEvent("UNIT_FOCUS")
	handlers:RegisterEvent("UNIT_MAXFOCUS")
	handlers:RegisterEvent("UNIT_ENERGY")
	handlers:RegisterEvent("UNIT_MAXENERGY")
	handlers:RegisterEvent("UNIT_RUNIC_POWER")
	handlers:RegisterEvent("UNIT_MAXRUNIC_POWER")
	handlers:RegisterEvent("UNIT_ENTERED_VEHICLE")
	handlers:RegisterEvent("UNIT_EXITED_VEHICLE")
	handlers:RegisterEvent("UNIT_LEVEL")
	handlers:RegisterEvent("UNIT_CLASSIFICATION_CHANGED")
	handlers:RegisterEvent("UNIT_FACTION")
	handlers:RegisterEvent("UNIT_PET")
	handlers:RegisterEvent("PLAYER_TARGET_CHANGED")
	handlers:RegisterEvent("PLAYER_FOCUS_CHANGED")
	handlers:RegisterEvent("UNIT_PORTRAIT_UPDATE")
	handlers:RegisterEvent("UNIT_MODEL_CHANGED")
	handlers:RegisterEvent("PARTY_MEMBERS_CHANGED")
	handlers:RegisterEvent("RAID_ROSTER_UPDATE")
	handlers:RegisterEvent("UNIT_SPELLCAST_DELAYED")
	handlers:RegisterEvent("UNIT_SPELLCAST_STOP")
	handlers:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
	handlers:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
	handlers:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
	handlers:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
	handlers:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
	handlers:RegisterEvent("UNIT_COMBO_POINTS")
	handlers:RegisterEvent("UNIT_AURA")
	for _, event in ipairs(updateEvents) do
		if event ~= "OnUpdate" then
			handlers:RegisterEvent(event)
		end
	end
	if self.RegisterClassBarHandlerEvents then
		self:RegisterClassBarHandlerEvents()
	end
	if Aggro then
		Aggro:Register(function() end)
	end
	handlers:Show()
end

function IUF:RegisterUpdateEvent(event, func, isUpdate)
	if type(event) == "string" and type(func) == "function" then
		if not(handlers:IsEventRegistered(event) or event == "OnUpdate") then
			handlers:RegisterEvent(event)
			if isUpdate then
				tinsert(updateEvents, event)
			end
		end
		if handlers[event] then
			hooksecurefunc(handlers[event], func)
		else
			handlers[event] = func
		end
		for _, callback in pairs(self.callbacks) do
			if func == callback then
				return
			end
		end
		tinsert(self.callbacks, func)
	end
end

local vehicleParty = { partypet1 = "party1", partypet2 = "party2", partypet3 = "party3", partypet4 = "party4" }
local partyVehicle = { party1 = "partypet1", party2 = "partypet2", party3 = "partypet3", party4 = "partypet4" }

function IUF:GetEventUnitObject(unit)
	if unit == "player" then
		if UnitHasVehicleUI(unit) then
			return self.units.pet
		else
			return self.units.player
		end
	elseif unit == "pet" then
		if UnitHasVehicleUI("player") then
			return self.units.player
		else
			return self.units.pet
		end
	elseif vehicleParty[unit] then
		if UnitHasVehicleUI(vehicleParty[unit]) then
			return self.units[vehicleParty[unit]]
		else
			return self.units[unit]
		end
	elseif partyVehicle[unit] then
		if UnitHasVehicleUI(unit) then
			return nil
		else
			return self.units[unit]
		end
	else
		return self.units[unit]
	end
end

handlers:SetScript("OnEvent", function(self, event, unit, ...)
	if event == "UNIT_COMBO_POINTS" then
		for object in pairs(IUF.visibleObject) do
			handlers[event](object)
		end
	elseif unit then
		if event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" or event == "UNIT_PET" then
			if unit == "player" or (IUF.units[unit] and IUF.units[unit].objectType == "party") then
				if UnitHasVehicleUI(unit) then
					IUF:UpdateObject(IUF.units[unit])
				elseif IUF.units[unit].petunit and IUF.units[IUF.units[unit].petunit] then
					IUF:UpdateObject(IUF.units[IUF.units[unit].petunit])
				end
			end
			if event == "UNIT_PET" and unit == "player" then
				handlers.UNIT_HAPPINESS(IUF.units.pet)
			end
		elseif event == "UNIT_HAPPINESS" then
			handlers.UNIT_HAPPINESS(IUF.units.pet)
		elseif handlers[event] and IUF.links[unit] and IUF.visibleObject[IUF.links[unit]] then
			handlers[event](IUF.links[unit], ...)
		end
	elseif event == "PLAYER_UPDATE_RESTING" then
		if IUF.units.player then
			handlers[event](IUF.units.player)
		end
	elseif event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" then
		self.unit = event == "PLAYER_TARGET_CHANGED" and "target" or "focus"
		for i = 1, 3 do
			if IUF.units[self.unit] then
				IUF.units[self.unit].values.combo = nil
				if UnitExists(self.unit) then
					handlers.PLAYER_ENTERING_WORLD(IUF.units[self.unit])
				end
			end
			self.unit = self.unit.."target"
		end
	elseif handlers[event] then
		for object in pairs(IUF.visibleObject) do
			if UnitExists(object.unit or "") then
				handlers[event](object)
			end
		end
		if event == "PARTY_MEMBERS_CHANGED" then
			for unit, object in pairs(IUF.units) do
				if unit:find("party") and UnitExists(object.unit or "") then
					IUF:UpdateObject(object)
				end
			end
		end
	end
end)

handlers:SetScript("OnUpdate", function(self, timer)
	self.timer = (self.timer or 0) + timer
	if self.timer > 0.2 then
		self.timer = 0
		for object in pairs(IUF.visibleObject) do
			if object.needAutoUpdate then
				handlers.PLAYER_ENTERING_WORLD(object)
			else
				handlers.OnUpdate(object)
				if object.values.guid and (object.values.guid == IUF.units.player.values.guid or object.values.guid == IUF.playerGUID) then
					handlers.UNIT_DISPLAYPOWER(object)
				end
			end
		end
		if IUF.units.player.watch and IUF.ClassBarOnUpdate then
			IUF:ClassBarOnUpdate(IUF.units.player)
		end
	end
end)

function handlers:OnUpdate()
	self.values.guid = UnitGUID(self.unit)
	self.values.connect = UnitIsConnected(self.realunit)
	self.values.combat = UnitAffectingCombat(self.unit)
	self.values.visible = UnitIsVisible(self.unit)
	self.values.tapped = UnitIsTapped(self.unit) and not UnitPlayerControlled(self.unit) and not UnitIsTappedByPlayer(self.unit) and not UnitIsTappedByAllThreatList(self.unit)
	self.values.afk = (UnitIsAFK(self.unit) or UnitIsAFK(self.realunit)) and 1 or nil
	if self.realunit == "target" then
		if self.values.combat and self.values.attack and not self.values.player then
			self.values.threatstatus, self.values.threatvalue = select(2, UnitDetailedThreatSituation("player", "target"))
		else
			self.values.threatstatus, self.values.threatvalue = nil
		end
	end
	if Aggro and self.values.guid and Aggro:GUIDHasAggro(self.values.guid) and self.values.combat and not self.values.attack and not(self.values.dead or self.values.ghost) then
		self.values.aggro = 1
	else
		self.values.aggro = nil
	end
end

function handlers:PLAYER_ENTERING_WORLD()
	self.values.vehicle = UnitHasVehicleUI(self.realunit) and 1 or nil
	for _, event in ipairs(updateEvents) do
		handlers[event](self)
	end
	if self.needAutoUpdate then
		if UnitExists(self.unit or "") then
			handlers:SetUnit(self.unit)
			handlers:Show()
			self.values.modelfile = handlers:GetModel()
		end
	else
		handlers.RAID_ROSTER_UPDATE(self)
		if self.feedbackFrame then
			self.feedbackFrame:Hide()
			self.feedbackFrame.feedbackText:SetText(nil)
			self.feedbackFrame.feedbackStartTime = nil
		end
	end
end

function handlers:UNIT_COMBAT(...)
	if self.showCombatFeedback and self.feedbackFrame then
		CombatFeedback_OnCombatEvent(self.feedbackFrame, ...)
		self.feedbackFrame:Show()
	end
end

local feedbackUnit = { player = true, target = true }

function IUF:RegsiterCombatFeedback()
	for unit in pairs(feedbackUnit) do
		if type(self.units[unit].db.portrait) == "string" and self.units[unit].db.portrait:find("^return") then
			self.units[unit].showCombatFeedback = self.units[unit].db.combatFeedback
		else
			self.units[unit].showCombatFeedback = nil
		end
		if self.units[unit].feedbackFrame then
			self.units[unit].feedbackFrame:Hide()
			self.units[unit].feedbackFrame.feedbackText:SetText(nil)
			self.units[unit].feedbackFrame.feedbackStartTime = nil
			self.units[unit].feedbackFrame.feedbackFontHeight = self.units[unit].db.combatFeedbackFontSize
		end
	end
	if self.units.player.showCombatFeedback or self.units.target.showCombatFeedback then
		handlers:RegisterEvent("UNIT_COMBAT")
	else
		handlers:UnregisterEvent("UNIT_COMBAT")
	end
end

function handlers:UNIT_PORTRAIT_UPDATE()
	self.values.modelfile = not self.values.modelfile
	for object in pairs(IUF.visibleObject) do
		if object.needAutoUpdate and UnitIsUnit(self.unit, object.unit or "") then
			object.values.modelfile = not object.values.modelfile
		end
	end
end

local unitName, unitRealm

function handlers:UNIT_NAME_UPDATE()
	if IUF.db.skin == "Blizzard" and self.objectType == "party" then
		unitName, unitRealm = UnitName(self.unit)
		if unitName then
			if unitRealm and unitRealm ~= "" then
				self.values.name = unitName.."-"..unitRealm
			else
				self.values.name = unitName
			end
		else
			self.values.name = UNKNOWNOBJECT
		end
	else
		self.values.name = UnitName(self.unit) or UNKNOWNOBJECT
	end
	self.values.level = UnitLevel(self.unit) or -1
	self.values.attack = UnitCanAttack("player", self.unit)
	self.values.player = UnitIsPlayer(self.unit)
	if self.values.player then
		self.values.classification = nil
		self.values.elite = nil
		self.values.class = select(2, UnitClass(self.unit)) or "PET"
		self.values.creature = nil
	else
		self.values.classification = UnitClassification(self.unit)
		self.values.elite = (self.values.classification or ""):find("elite$") and 1 or nil
		self.values.class = "PET"
		if creatureTypes[UnitCreatureType(self.unit) or ""] then
			self.values.creature = UnitCreatureType(self.unit)
		else
			self.values.creature = nil
		end
	end
	if UnitIsPVPFreeForAll(self.unit) or UnitIsPVP(self.unit) then
		self.values.pvp = factionGroups[UnitFactionGroup(self.unit) or ""] or nil
	else
		self.values.pvp = nil
	end
	if UnitIsFriend("player", self.unit) then
		if self.values.player then
			self.values.faction = nil
		else
			self.values.faction = "FRIEND"
		end
	elseif UnitIsEnemy("player", self.unit) then
		self.values.faction = "ENEMY"
	elseif self.values.player then
		self.values.faction = nil
	else
		self.values.faction = "NEUTRAL"
	end
end

function handlers:UNIT_HEALTH()
	self.values.health = UnitHealth(self.unit)
	self.values.dead = UnitIsDead(self.unit)
	self.values.ghost = UnitIsGhost(self.unit)
end

function handlers:UNIT_MAXHEALTH()
	self.values.healthmax = UnitHealthMax(self.unit)
end

function handlers:UNIT_DISPLAYPOWER()
	self.values.powertype = UnitPowerType(self.unit)
	self.values.powermax = UnitPowerMax(self.unit)
	self.values.power = UnitPower(self.unit)
end

function handlers:UNIT_MANA()
	self.values.power = UnitPower(self.unit)
end

function handlers:UNIT_MAXMANA()
	self.values.powermax = UnitPowerMax(self.unit)
end

function handlers:RAID_TARGET_UPDATE()
	self.values.raidtarget = UnitExists(self.unit) and GetRaidTargetIndex(self.unit) or nil
end

function handlers:UNIT_ENTERED_VEHICLE()
	if UnitHasVehicleUI(self.realunit) and self.unit then
		self.values.vehicle = 1
		if IUF.units[self.unit] and IUF.units[self.unit].unit then
			handlers.PLAYER_ENTERING_WORLD(IUF.units[self.unit])
		end
	end
end

function handlers:UNIT_EXITED_VEHICLE()
	self.values.vehicle = nil
	if self.petunit and IUF.units[self.petunit] and IUF.units[self.petunit].unit then
		handlers.PLAYER_ENTERING_WORLD(IUF.units[self.petunit])
	end
end

function handlers:UNIT_PET()
	if self.petunit and IUF.units[self.petunit] and IUF.units[self.petunit].unit then
		handlers.PLAYER_ENTERING_WORLD(IUF.units[self.petunit])
	end
end

function handlers:PLAYER_UPDATE_RESTING()
	if self.objectType == "player" then
		self.values.resting = IsResting()
	else
		self.values.resting = nil
	end
end

function handlers:UNIT_HAPPINESS()
	if self.objectType == "pet" then
		self.values.happiness = GetPetHappiness()
	end
end

function handlers:UNIT_COMBO_POINTS()
	self.values.combo = GetComboPoints(UnitHasVehicleUI("player") and "vehicle" or "player", self.unit)
end

local endTime

function handlers:UNIT_SPELLCAST_START()
	if UnitCastingInfo(self.unit) then
		self.values.castingIsChannel = nil
		self.values.castingName, self.values.castingRank, _, self.values.castingIcon, self.values.castingStartTime, endTime, _, _, self.values.castingIsShield = UnitCastingInfo(self.unit)
		self.values.castingEndTime = endTime
	elseif UnitChannelInfo(self.unit) then
		self.values.castingIsChannel = true
		self.values.castingName, self.values.castingRank, _, self.values.castingIcon, self.values.castingStartTime, endTime, _, _, self.values.castingIsShield = UnitChannelInfo(self.unit)
		self.values.castingEndTime = endTime
	else
		handlers.UNIT_SPELLCAST_STOP(self)
	end
end

function handlers:UNIT_SPELLCAST_STOP()
	self.values.castingIsChannel, self.values.castingName, self.values.castingRank, self.values.castingIcon, self.values.castingStartTime, self.values.castingIsShield, self.values.castingEndTime = nil
end

function handlers:UNIT_SPELLCAST_INTERRUPTIBLE()
	self.values.castingIsShield = nil
end

function handlers:UNIT_SPELLCAST_NOT_INTERRUPTIBLE()
	self.values.castingIsShield = true
end

local raidIndex, raidRank, raidGroup, roleIsTank, roleIsHeal, roleIsDPS

function handlers:RAID_ROSTER_UPDATE()
	if UnitInRaid(self.realunit) and GetNumRaidMembers() > 0 then
		self.values.role = nil
		if groupGUID and self.values.guid and groupGUID.groupdata.raid[self.values.guid] then
			raidIndex = tonumber(groupGUID.groupdata.raid[self.values.guid]:match("^raid(%d+)$") or "") or nil
			if raidIndex then
				raidRank, raidGroup, _, _, _, _, _, _, _, self.values.looter = select(2, GetRaidRosterInfo(raidIndex))
				if raidRank == 2 then
					self.values.leader = 1
				elseif raidRank == 1 then
					self.values.leader = 2
				else
					self.values.leader = nil
				end
				if self.objectType == "player" or self.objectType == "target" or self.objectType == "focus" then
					self.values.group = raidGroup
				else
					self.values.group = nil
				end
				return
			end
		end
		self.values.group, self.values.leader, self.values.looter = nil
	elseif (self.realunit == "player" or UnitInParty(self.realunit)) and GetNumPartyMembers() > 0 then
		if self.objectType == "player" or self.objectType == "party" then
			roleIsTank, roleIsHeal, roleIsDPS = UnitGroupRolesAssigned(self.realunit)
			if roleIsTank then
				self.values.role = 1
			elseif roleIsHeal then
				self.values.role = 2
			elseif roleIsDPS then
				self.values.role = 3
			else
				self.values.role = nil
			end
		else
			self.values.role = nil
		end
		if UnitIsPartyLeader(self.realunit) then
			self.values.leader = 1
			self.values.looter = GetLootMethod() == "master" and 1 or nil
		else
			self.values.leader, self.values.looter = nil
		end
		self.values.group = nil
	else
		self.values.group, self.values.leader, self.values.looter, self.values.role = nil
	end
end

handlers.UNIT_LEVEL = handlers.UNIT_NAME_UPDATE
handlers.UNIT_FACTION = handlers.UNIT_NAME_UPDATE
handlers.UNIT_CLASSIFICATION_CHANGED = handlers.UNIT_NAME_UPDATE
handlers.UNIT_MODEL_CHANGED = handlers.UNIT_PORTRAIT_UPDATE
handlers.PARTY_MEMBERS_CHANGED = handlers.RAID_ROSTER_UPDATE
handlers.UNIT_RAGE = handlers.UNIT_MANA
handlers.UNIT_FOCUS = handlers.UNIT_MANA
handlers.UNIT_ENERGY = handlers.UNIT_MANA
handlers.UNIT_RUNIC_POWER = handlers.UNIT_MANA
handlers.UNIT_MAXRAGE = handlers.UNIT_MAXMANA
handlers.UNIT_MAXFOCUS = handlers.UNIT_MAXMANA
handlers.UNIT_MAXENERGY = handlers.UNIT_MAXMANA
handlers.UNIT_MAXRUNIC_POWER = handlers.UNIT_MAXMANA
handlers.UNIT_SPELLCAST_DELAYED = handlers.UNIT_SPELLCAST_START
handlers.UNIT_SPELLCAST_CHANNEL_START = handlers.UNIT_SPELLCAST_START
handlers.UNIT_SPELLCAST_CHANNEL_UPDATE = handlers.UNIT_SPELLCAST_START
handlers.UNIT_SPELLCAST_CHANNEL_STOP = handlers.UNIT_SPELLCAST_STOP

local refreshFrame = CreateFrame("Frame")
refreshFrame.object = {}
refreshFrame:Hide()
refreshFrame:SetScript("OnUpdate", function(self, timer)
	self.timer = self.timer + timer
	if self.timer > 0.5 then
		self.timer, self.count = 0, 0
		for object, count in pairs(self.object) do
			if object.unit and UnitExists(object.unit) then
				IUF.handlers.PLAYER_ENTERING_WORLD(object)
				self.object[object] = count - 1
				if self.object[object] > 0 then
					self.count = self.count + 1
				else
					self.object[object] = nil
				end
			else
				self.object[object] = nil
			end
		end
		if self.count <= 0 then
			self:Hide()
		end
	end
end)

function IUF:RefreshObject(object)
	if not object.needAutoUpdate then
		refreshFrame.object[object] = 2
		refreshFrame.timer = 0
		refreshFrame:Show()
	end
end