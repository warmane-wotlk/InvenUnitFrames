local MAJOR_VERSION, MINOR_VERSION = "LibAggro-1.0", 1

local lib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

lib.frame = lib.frame or CreateFrame("Frame")
lib.frame:UnregisterAllEvents()
lib.frame:Hide()
lib.frame.scandb = lib.frame.scandb or {}
lib.frame.checked = lib.frame.checked or {}

lib.callbacks = lib.callbacks or {}
lib.threatdb = lib.threatdb or {}
lib.aggrodb = lib.aggrodb or {}
lib.updateDelay = lib.updateDelay or 0.2

local _G = _G
local pairs = _G.pairs
local unpack = _G.unpack
local UnitGUID = _G.UnitGUID
local UnitIsEnemy = _G.UnitIsEnemy
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitThreatSituation = _G.UnitThreatSituation
local GetNumRaidMembers = _G.GetNumRaidMembers
local GetNumPartyMembers = _G.GetNumPartyMembers

local groupGUID = LibStub("LibGroupGUIDs-1.0")
local groupdata = groupGUID.groupdata

local units, unitguid, unitguid2 = {}

function lib:Register(func)
	if type(func) == "function" and not lib.callbacks[func] then
		lib.callbacks[func] = true
		if lib.frame:IsShown() then

		else
			lib.frame:Show()
		end
	end
end

function lib:Unregister(func)
	if func and lib.callbacks[func] then
		lib.callbacks[func] = nil
		if lib.frame:IsShown() then
			for p in pairs(lib.callbacks) do
				return
			end
			lib.frame:Hide()
		end
	end
end

function lib:GUIDHasAggro(guid)
	if guid and (lib.threatdb[guid] or lib.aggrodb[guid]) then
		return true
	end
	return nil
end

function lib:UnitHasAggro(unit)
	return lib:GUIDHasAggro(UnitGUID(unit or ""))
end

local function fire(guid)
	groupGUID:GUID2Unit(guid, units)
	for func in pairs(lib.callbacks) do
		func(lib.threatdb[guid] or lib.aggrodb[guid], guid, unpack(units))
	end
end

local function clearTable(tbl)
	for p in pairs(tbl) do
		tbl[p] = nil
	end
end

local function guidCheck(guid)
	return groupdata.raid[guid] or groupdata.party[guid]
end

local function checkaggro(unit)
	if UnitExists(unit) and not lib.frame.checked[UnitGUID(unit)] then
		lib.frame.checked[UnitGUID(unit)] = true
		if UnitIsEnemy("player", unit) then
			unit = unit.."target"
			unitguid = UnitGUID(unit)
			if unitguid and guidCheck(unitguid) and not UnitIsDeadOrGhost(unit) then
				lib.frame.scandb[unitguid] = true
			end
		end
	end
end

function lib:OnUpdate(timer)
	self.timer = (self.timer or 0) + timer
	if self.timer > lib.updateDelay then
		self.timer = 0
		self.numRaid, self.numParty = GetNumRaidMembers(), GetNumPartyMembers()
		if self.numRaid > 0 then
			for i = 1, self.numRaid do
				checkaggro("raid"..i.."target")
				checkaggro("raidpet"..i.."target")
			end
		else
			checkaggro("target")
			for i = 1, self.numParty do
				checkaggro("party"..i.."target")
				checkaggro("partypet"..i.."target")
			end
		end
		checkaggro("focus")
		checkaggro("mouseover")
		for guid, aggro in pairs(lib.aggrodb) do
			if guidCheck(guid) then
				if aggro ~= self.scandb[guid] then
					-- 어그로 손실 상태로 변경
					lib.aggrodb[guid] = self.scandb[guid]
					if not lib.threatdb[guid] then
						-- 어그로 콜백
						fire(guid)
					end
				end
				self.scandb[guid] = nil
			else
				lib.aggrodb[guid] = nil
				lib.threatdb[guid] = nil
			end
		end
		for guid, aggro in pairs(self.scandb) do
			if aggro ~= lib.aggrodb[guid] then
				-- 어그로 획득 상태로 변경
				lib.aggrodb[guid] = aggro
				if not lib.threatdb[guid] then
					-- 어그로 콜백
					fire(guid)
				end
			end
			self.scandb[guid] = nil
		end
		clearTable(self.checked)
	end
end

function lib:OnEvent(event, unit)
	if event == "PLAYER_ENTERING_WORLD" then
		clearTable(self.scandb)
		clearTable(lib.threatdb)
		clearTable(lib.aggrodb)
		lib.OnUpdate(self, 1)
		if GetNumRaidMembers() > 0 then
			for _, unit in pairs(groupdata.raid) do
				lib.OnEvent("UNIT_THREAT_SITUATION_UPDATE", unit)
			end
		else
			for _, unit in pairs(groupdata.party) do
				lib.OnEvent("UNIT_THREAT_SITUATION_UPDATE", unit)
			end
		end
	elseif event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED" then

	elseif event == "UNIT_THREAT_SITUATION_UPDATE" and unit then
		unitguid2 = UnitGUID(unit)
		if not unitguid2 then return end
		if guidCheck(unitguid2) then
			if (UnitThreatSituation(unit) or 0) > 1 and not UnitIsDeadOrGhost(unit) then
				if not lib.threatdb[unitguid2] then
					-- 어그로 확득 상태로 변경
					lib.threatdb[unitguid2] = true
					if not lib.aggrodb[unitguid2] then
						fire(unitguid2)
					end
				end
			elseif lib.threatdb[unitguid2] then
				-- 어그로 손실 상태로 변경
				lib.threatdb[unitguid2] = nil
				if not lib.aggrodb[unitguid2] then
					fire(unitguid2)
				end
			end
		else
			lib.aggrodb[unitguid2] = nil
			lib.threatdb[unitguid2] = nil
		end
	elseif event == "UNIT_HEALTH" and unit then
		unitguid2 = UnitGUID(unit)
		if not unitguid2 then return end
		if guidCheck(unitguid2) then
			if UnitIsDeadOrGhost(unit) and (lib.threatdb[unitguid2] or lib.aggrodb[unitguid2]) then
				lib.aggrodb[unitguid2] = nil
				lib.threatdb[unitguid2] = nil
				fire(unitguid2)
			end
		else
			lib.aggrodb[unitguid2] = nil
			lib.threatdb[unitguid2] = nil
		end
	end
end

function lib:OnShow()
	self.timer = 1
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
	lib.OnEvent(self, "PLAYER_ENTERING_WORLD")
end

function lib:OnHide()
	self:UnregisterAllEvents()
	clearTable(self.scandb)
	clearTable(self.checked)
	clearTable(lib.threatdb)
	clearTable(lib.aggrodb)
end

lib.frame:SetScript("OnUpdate", lib.OnUpdate)
lib.frame:SetScript("OnEvent", lib.OnEvent)
lib.frame:SetScript("OnShow", lib.OnShow)
lib.frame:SetScript("OnHide", lib.OnHide)

for p in pairs(lib.callbacks) do
	lib.frame:Show()
end