if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then return end

local IUF = InvenUnitFrames
local _G = _G
local unpack = _G.unpack
local GetTime = _G.GetTime
local GetRuneType = _G.GetRuneType
local GetRuneCooldown = _G.GetRuneCooldown
local runeMatch = {}
local runeColor = {
	{ 1, 0.25, 0.25 },	-- Blood
	{ 0.2, 1, 0.2 },	-- Unholy
	{ 0, 0.6, 1 },		-- Frost
	{ 0.8, 0.1, 1 }		-- Death
}

local texture, width, start, duration, ready, runeType, ctime

local function classbarOnUpdate(self)
	self:SetScript("OnUpdate", nil)
	IUF:ClassBarSetup(self:GetParent())
end

local function runeShine(self)
	self.shine:Show()
	self.shine.info.mode = "IN"
	self.shine.info.timeToFade = 0.5
	self.shine.info.finishedFunc = UIFrameFadeOut
	self.shine.info.finishedArg1 = self.shine
	self.shine.info.finishedArg2 = 0.5
	UIFrameFade(self.shine, self.shine.info)
end

local function runeCooldownUpdate(self)
	start, duration, ready = GetRuneCooldown(self:GetID())
	if ready or start == nil or start == 0 then
		self:SetMinMaxValues(0, 1)
		self:SetValue(1)
		self.text:SetText(nil)
		if self:GetScript("OnUpdate") then
			self:SetScript("OnUpdate", nil)
		end
	else
		ctime = GetTime()
		self:SetMinMaxValues(start, start + duration)
		self:SetValue(ctime)
		if IUF.db.classBar.DEATHKNIGHT.showCD then
			self.text:SetFormattedText("%d", duration - ctime + start + 0.5)
		else
			self.text:SetText(nil)
		end
		if not self:GetScript("OnUpdate") then
			self:SetScript("OnUpdate", runeCooldownUpdate)
		end
	end
end

local function runeTypeUpdate(self)
	self.type = GetRuneType(self:GetID())
	if self.type and runeColor[self.type] then
		self:SetStatusBarColor(unpack(runeColor[self.type]))
		self.bg:SetVertexColor(unpack(runeColor[self.type]))
	end
end

function IUF:CreateClassBar(object)
	object.classBar = CreateFrame("Frame", nil, object)
	object.classBar:SetFrameLevel(object:GetFrameLevel() - 2)
	object.classBar:Hide()
	object.classBar.type = "DEATHKNIGHT"
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
	object.classBar.runes = {}
	for i = 1, 6 do
		object.classBar.runes[i] = CreateFrame("StatusBar", nil, object.classBar)
		object.classBar.runes[i]:SetFrameLevel(object:GetFrameLevel() - 1)
		object.classBar.runes[i].bg = object.classBar.runes[i]:CreateTexture(nil, "BACKGROUND")
		object.classBar.runes[i].bg:SetAllPoints()
		object.classBar.runes[i].bg:SetAlpha(0.25)
		object.classBar.runes[i].shine = object.classBar.runes[i]:CreateTexture(nil, "OVERLAY")
		object.classBar.runes[i].shine:Hide()
		object.classBar.runes[i].shine:SetPoint("CENTER", 0, 0)
		object.classBar.runes[i].shine:SetBlendMode("ADD")
		object.classBar.runes[i].shine:SetTexture("Interface\\ComboFrame\\ComboPoint")
		object.classBar.runes[i].shine:SetTexCoord(0.5625, 1, 0, 1)
		object.classBar.runes[i].shine.info = {}
		object.classBar.runes[i].text = object.classBar.runes[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		object.classBar.runes[i].text:SetPoint("CENTER", 0, 1)
		if i == 1 then
			object.classBar.runes[i]:SetPoint("LEFT", object.classBar, "LEFT", 0, 0)
		else
			object.classBar.runes[i]:SetPoint("LEFT", object.classBar.runes[i - 1], "RIGHT", 1, 0)
		end
		if i < 3 then
			object.classBar.runes[i]:SetID(i)
			runeMatch[i] = i
		elseif i < 5 then
			object.classBar.runes[i]:SetID(i + 2)
			runeMatch[i + 2] = i
		else
			object.classBar.runes[i]:SetID(i - 2)
			runeMatch[i - 2] = i
		end
		if i ~= 6 then
			texture = object.classBar.border:CreateTexture(nil, "OVERLAY")
			texture:SetPoint("TOPLEFT", object.classBar.runes[i], "TOPLEFT", 0, 0)
			texture:SetPoint("BOTTOMRIGHT", object.classBar.runes[i], "BOTTOMRIGHT", 1, 0)
			texture:SetTexture(0, 0, 0, 0.55)
		end
	end
	texture = nil
	object.classBar:SetScript("OnEvent", function(self, event, rune, usable)
		if event == "PLAYER_ENTERING_WORLD" then
			IUF:ClassBarSetup(self)
		elseif rune and runeMatch[rune] then
			runeCooldownUpdate(self.runes[runeMatch[rune]])
			if event == "RUNE_TYPE_UPDATE" then
				runeTypeUpdate(self.runes[runeMatch[rune]])
			elseif event == "RUNE_POWER_UPDATE" and usable then
				runeShine(self.runes[runeMatch[rune]])
			end
		else
			for i = 1, 6 do
				runeCooldownUpdate(self.runes[i])
				runeTypeUpdate(self.runes[i])
			end
		end
	end)
	object.classBar:RegisterEvent("RUNE_POWER_UPDATE")
	object.classBar:RegisterEvent("RUNE_TYPE_UPDATE")
	object.classBar:RegisterEvent("PLAYER_ENTERING_WORLD")
	object.classBar:RegisterEvent("PLAYER_ALIVE")
	object.classBar:RegisterEvent("PLAYER_DEAD")
	object.classBar:RegisterEvent("PLAYER_UNGHOST")
	object.classBar:SetScript("OnShow", function(self)
		self:SetScript("OnUpdate", classbarOnUpdate)
	end)
end

function IUF:ClassBarSetup(object)
	if object.classBar then
		texture = LibStub("LibSharedMedia-3.0"):Fetch("statusbar", self.db.classBar.DEATHKNIGHT.texture or "Smooth v2")
		width = (object.classBar:GetWidth() - 5) / 6
		for i = 1, 6 do
			object.classBar.runes[i]:SetWidth(width)
			object.classBar.runes[i]:SetHeight(self.db.classBar.DEATHKNIGHT.height)
			object.classBar.runes[i]:SetStatusBarTexture(texture)
			object.classBar.runes[i].bg:SetTexture(texture)
			object.classBar.runes[i].shine:SetWidth(self.db.classBar.DEATHKNIGHT.height * 4)
			object.classBar.runes[i].shine:SetHeight(self.db.classBar.DEATHKNIGHT.height * 4)
			self:SetFontString(object.classBar.runes[i].text, self.db.classBar.DEATHKNIGHT.fontFile, self.db.classBar.DEATHKNIGHT.fontSize, self.db.classBar.DEATHKNIGHT.fontAttribute, self.db.classBar.DEATHKNIGHT.fontShadow)
			runeTypeUpdate(object.classBar.runes[i])
		end
		texture, width = nil
		if IUF.db.classBar.DEATHKNIGHT.active then
			object.classBar:SetHeight(self.db.classBar.DEATHKNIGHT.height)
			object.classBar:SetAlpha(1)
		else
			object.classBar:SetHeight(0.001)
			object.classBar:SetAlpha(0)
		end
		if IUF.db.classBar.DEATHKNIGHT.showBlizzard then
			RuneFrame:SetAlpha(1)
			for i = 1, 6 do
				_G["RuneButtonIndividual"..i]:EnableMouse(true)
			end
		else
			RuneFrame:SetAlpha(0)
			for i = 1, 6 do
				_G["RuneButtonIndividual"..i]:EnableMouse(nil)
			end
		end
		object.classBar:Show()
	end
end