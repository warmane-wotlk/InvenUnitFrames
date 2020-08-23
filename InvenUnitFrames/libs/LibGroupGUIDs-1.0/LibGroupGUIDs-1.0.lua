local MAJOR_VERSION, MINOR_VERSION = "LibGroupGUIDs-1.0", 2
if not LibStub then error(MAJOR_VERSION .. " requires LibStub.") end
local lib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

lib.frame = lib.frame or CreateFrame("Frame")
lib.frame:UnregisterAllEvents()

local _G = getfenv(0)
local type = _G.type
local pairs = _G.pairs
local unpack = _G.unpack
local tinsert = _G.table.insert
local UnitName = _G.UnitName
local UnitGUID = _G.UnitGUID
local UnitIsPlayer = _G.UnitIsPlayer
local GetUnitName = _G.GetUnitName
local returnTable, numRaid, numParty, temp = {}

lib.groupdata = lib.groupdata or {}
lib.groupdata.base = lib.groupdata.base or {}
lib.groupdata.party = lib.groupdata.party or {}
lib.groupdata.raid = lib.groupdata.raid or {}

local function clearTable(tbl)
	for p in pairs(tbl) do
		tbl[p] = nil
	end
end

function lib:GUID2Unit(guid, tbl)
	tbl = type(tbl) == "table" and tbl or returnTable
	clearTable(tbl)
	if guid then
		if lib.groupdata.raid[guid] then
			tinsert(tbl, lib.groupdata.raid[guid])
		end
		if lib.groupdata.party[guid] then
			tinsert(tbl, lib.groupdata.party[guid])
		end
		if lib.groupdata.base[guid] then
			tinsert(tbl, lib.groupdata.base[guid])
		end
	end
	return unpack(tbl)
end

function lib:IsPartyGUID(guid)
	return guid and lib.groupdata.party[guid] or nil
end

function lib:IsRaidGUID(guid)
	return guid and lib.groupdata.raid[guid] or nil
end

function lib:InRaid()
	for p in pairs(lib.groupdata.raid) do
		return true
	end
	return nil
end

local function saveguid(unit, utype)
	if lib.groupdata[utype] then
		temp = UnitGUID(unit)
		if temp then
			lib.groupdata[utype][temp] = unit
			temp = UnitName(unit)
			if type(temp) == "string" and temp:len() > 2 and temp ~= COMBATLOG_UNKNOWN_UNIT then
				temp = GetUnitName(unit)
				if temp then
					if lib.groupdata[utype][temp] then
						if UnitIsPlayer(unit) then
							lib.groupdata[utype][temp] = unit
						end
					else
						lib.groupdata[utype][temp] = unit
					end
				end
			end
			temp = nil
		end
	end
end

local function updateTargetFocus()
	clearTable(lib.groupdata.base)
	saveguid("target", "base")
	saveguid("focus", "base")
end

local function updateGroupRoster()
	clearTable(lib.groupdata.party)
	clearTable(lib.groupdata.raid)
	numRaid, numParty = GetNumRaidMembers() or 0, GetNumPartyMembers() or 0
	saveguid("player", "party")
	saveguid("pet", "party")
	for i = 1, numParty do
		saveguid("party"..i, "party")
		saveguid("partypet"..i, "party")
	end
	for i = 1, numRaid do
		saveguid("raid"..i, "raid")
		saveguid("raidpet"..i, "raid")
	end
end

local function eventhandler(self, event, unit)
	if event == "UNIT_NAME_UPDATE" and unit then
		if unit == "target" or unit == "focus" then
			saveguid(unit, "base")
		elseif unit:find("party") then
			saveguid(unit, "party")
		elseif unit:find("raid") then
			saveguid(unit, "raid")
		end
	elseif event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" then
		updateTargetFocus()
	elseif event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
		updateTargetFocus()
		updateGroupRoster()
	else
		updateGroupRoster()
	end
end

lib.frame:SetScript("OnEvent", eventhandler)
lib.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
lib.frame:RegisterEvent("RAID_ROSTER_UPDATE")
lib.frame:RegisterEvent("PARTY_MEMBERS_CHANGED")
lib.frame:RegisterEvent("UNIT_PET")
lib.frame:RegisterEvent("PLAYER_TARGET_CHANGED")
lib.frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
lib.frame:RegisterEvent("UNIT_NAME_UPDATE")

if IsLoggedIn() then
	eventhandler(lib.frame, "PLAYER_LOGIN")
else
	lib.frame:RegisterEvent("PLAYER_LOGIN")
end