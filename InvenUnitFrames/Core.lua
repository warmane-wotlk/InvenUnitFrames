local IUF = CreateFrame("Frame", "InvenUnitFrames", UIParent)
IUF:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
IUF:RegisterEvent("ADDON_LOADED")
IUF.units, IUF.links, IUF.objectOrder, IUF.visibleObject = {}, {}, {}, {}
IUF.handlers, IUF.callbacks, IUF.valueHandler = CreateFrame("PlayerModel"), {}, {}

local _G = _G
local type = _G.type
local pairs = _G.pairs
local ipairs = _G.ipairs
local select = _G.select
local tremove = _G.table.remove
local InCombatLockdown = _G.InCombatLockdown
local GetNumRaidMembers = _G.GetNumRaidMembers
local collectgarbage = _G.collectgarbage

local Broker = LibStub("LibDataBroker-1.1")
local MapButton = LibStub("LibMapButton-1.1")

function IUF:ADDON_LOADED()
	self:UnregisterEvent("ADDON_LOADED")
	if InvenUnitFramesOptionFrame then return end
	-- 옵션 프레임 생성
	self.optionFrame = CreateFrame("Frame", "InvenUnitFramesOptionFrame", InterfaceOptionsFramePanelContainer)
	self.optionFrame:Hide()
	self.optionFrame.name = "인벤 유닛 프레임"
	self.optionFrame:SetScript("OnShow", function(self)
		self:SetScript("OnShow", nil)
		InvenUnitFrames:LoadModule("Option")
	end)
	InterfaceOptions_AddCategory(self.optionFrame)
	-- 슬래쉬 커맨드 등록
	SLASH_INVENUNITFRAMES1 = "/iuf"
	SLASH_INVENUNITFRAMES2 = "/인벤유닛"
	SLASH_INVENUNITFRAMES3 = "/인벤유니트"
	SLASH_INVENUNITFRAMES4 = "/인벤유닛프레임"
	SLASH_INVENUNITFRAMES5 = "/인벤유니트프레임"
	SLASH_INVENUNITFRAMES6 = "/invenunitframe"
	SLASH_INVENUNITFRAMES7 = "/invenunitframes"
	SLASH_INVENUNITFRAMES8 = "/ㅑㅕㄹ"
	SlashCmdList["INVENUNITFRAMES"] = function() InterfaceOptionsFrame_OpenToCategory(InvenUnitFrames.optionFrame) end
	-- LDB 정의
	Broker:NewDataObject("InvenUnitFrames", {
		type = "launcher",
		text = "IUF",
		OnClick = function(_, button) IUF:OnClick(button) end,
		icon = "Interface\\AddOns\\InvenUnitFrames\\Texture\\Icon.tga",
		OnTooltipShow = function(tooltip)
			if tooltip and tooltip.AddLine then
				IUF:OnTooltip(tooltip)
			end
		end,
		OnLeave = GameTooltip_Hide,
	})
	self:Show()
	self:SetAllPoints()
	self:RegisterEvent("PLAYER_LOGIN")
end

function IUF:PLAYER_LOGIN()
	self:UnregisterEvent("PLAYER_LOGIN")
	if self.playerClass then return end
	self.isLoading = true
	self.playerGUID = UnitGUID("player")
	self.playerClass = select(2, UnitClass("player"))
	self:SearchModules()
	self:InitDB()
	if type(self.db.skin) ~= "string" or not self:LoadSkinAddOn(self.db.skin) then
		self.db.skin = "Default"
	end
	if self.db.skin == "DefaultSquare" then
		if type(IUF.SetDefaultSkinSquare) == "function" then
			IUF:SetDefaultSkinSquare(true)
		else
			self.db.skin = "Default"
		end
	end
	self.db.skinName = self.skinDB.idx[self.db.skin]
	self:SetScale(self.db.scale)
	-- 미니맵 버튼, 미니맵 메뉴 생성
	MapButton:CreateButton(self, "InvenUnitFramesMapButton", "Interface\\AddOns\\InvenUnitFrames\\Texture\\Icon.tga", 190, InvenUnitFramesDB.minimapButton)
	-- 하이라이트 프레임 만들기(툴팁 기능도 수행함)
	self.highlightFrame = CreateFrame("Frame", nil, UIParent)
	self.highlightFrame:Hide()
	self.highlightFrame:SetFrameStrata("BACKGROUND")
	self.highlightFrame:SetToplevel(true)
	self.highlightFrame.tex = self.highlightFrame:CreateTexture(nil, "OVERLAY")
	self.highlightFrame.tex:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
	self.highlightFrame.tex:SetBlendMode("ADD")
	self.highlightFrame.tex:SetAllPoints()
	self.highlightFrame.tex:SetAlpha(IUF.db.highlightAlpha)
	-- 유닛 프레임 생성 시작
	self:CreateObject("player")
	self:CreateObject("pet", "player")
	self:CreateObject("pettarget", "player")
	self:CreateObject("target")
	self:CreateObject("targettarget", "target")
	self:CreateObject("targettargettarget", "target")
	self:CreateObject("focus")
	self:CreateObject("focustarget", "focus")
	self:CreateObject("focustargettarget", "focus")
	for i = 1, 4 do
		self:CreateObject("party"..i)
		self:CreateObject("partypet"..i, "party"..i)
		self:CreateObject("party"..i.."target", "party"..i)
		self:CreateObject("boss"..i)
	end
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("PLAYER_FOCUS_CHANGED")
	self:RegisterEvent("UNIT_FACTION")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:Hide()
	self:Show()
	for _, unit in ipairs(self.objectOrder) do
		self.units[unit]:SetLocation()
		self:SetActiveObject(self.units[unit])
	end
	self:RegisterHandlerEvents()
	self:EnableModules()
	self.isLoading = nil
end

function IUF:OnClick(button)
	if button == "RightButton" then
		-- nothing
	elseif InterfaceOptionsFramePanelContainer.displayedPanel == IUF.optionFrame then
		InterfaceOptionsFrameOkay_OnClick()
	else
		InterfaceOptionsFrame_OpenToCategory(IUF.optionFrame)
	end
end

function IUF:OnTooltip(tooltip)
	tooltip = tooltip or GameTooltip
	tooltip:AddLine("인벤 유닛 프레임 v"..IUF.version)
	tooltip:AddLine("http://wow.inven.co.kr", 1, 1, 1)
	tooltip:AddLine("클릭: 설정창 열기", 1, 1, 0)
end

function IUF:CollectGarbage()
	collectgarbage()
end

local function targettingSound(unit)
	if UnitExists(unit) then
		if UnitIsEnemy(unit, "player") then
			PlaySound("igCreatureAggroSelect")
		elseif UnitIsFriend("player", unit) then
			PlaySound("igCharacterNPCSelect")
		else
			PlaySound("igCreatureNeutralSelect")
		end
	else
		PlaySound("INTERFACESOUND_LOSTTARGETUNIT")
	end
end

function IUF:PLAYER_TARGET_CHANGED()
	targettingSound("target")
end

function IUF:PLAYER_FOCUS_CHANGED()
	targettingSound("focus")
end

function IUF:UNIT_FACTION(unit)
	if unit == "player" then
		if UnitIsPVPFreeForAll("player") or UnitIsPVP("player") then
			if not self.playerIsPVP then
				self.playerIsPVP = true
				PlaySound("igPVPUpdate")
			end
		else
			self.playerIsPVP = nil
		end
	end
end

local function updatePlayerInCombat()
	for object in pairs(IUF.visibleObject) do
		if not (object.needAutoUpdate or object.needElement) then
			IUF.callbacks.Health(object)
			IUF.callbacks.Power(object)
		end
	end
end

function IUF:PLAYER_REGEN_ENABLED()
	self.inCombat = nil
	updatePlayerInCombat()
	CombatFeedback_StopFullscreenStatus()
end

function IUF:PLAYER_REGEN_DISABLED()
	self.inCombat = true
	updatePlayerInCombat()
	if self.SetPreviewMode and self.previewMode then
		self:SetPreviewMode(nil)
	end
	if GetCVarBool("screenEdgeFlash") then
		CombatFeedback_StartFullscreenStatus()
	end
end

-- 블리자드 유닛 프레임 숨김
MAX_TARGET_BUFFS = 0
MAX_TARGET_DEBUFFS = 0
local frame
local function hideFrame(...)
	for i = 1, select("#", ...) do
		frame = select(i, ...)
		frame:DisableDrawLayer("OVERLAY")
		frame:DisableDrawLayer("ARTWORK")
		frame:DisableDrawLayer("BORDER")
		frame:DisableDrawLayer("BACKGROUND")
		frame:EnableMouse(nil)
		frame:EnableMouseWheel(nil)
		frame:SetAlpha(0)
		frame.EnableMouse = frame.IsShown
		frame.EnableMouseWheel = frame.IsShown
		frame.SetAlpha = frame.IsShown
		hideFrame(frame:GetChildren())
	end
end
hideFrame(PlayerFrame, TargetFrame, ComboFrame, FocusFrame, PartyMemberFrame1, PartyMemberFrame2, PartyMemberFrame3, PartyMemberFrame4, PartyMemberBackground, Boss1TargetFrame, Boss2TargetFrame, Boss3TargetFrame, Boss4TargetFrame)
-- taint 오류 방지를 위해 주시 대상 설정 메뉴 숨김
for _, menu in pairs(UnitPopupMenus) do
	for idx, name in pairs(menu) do
		if name == "SET_FOCUS" then
			tremove(menu, idx)
			break
		end
	end
end