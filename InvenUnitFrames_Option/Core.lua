local IUF = InvenUnitFrames
local Option = IUF.optionFrame
Option:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
Option:RegisterEvent("ADDON_LOADED")
Option:SetScript("OnShow", nil)

local _G = _G
local type = _G.type
local pairs = _G.pairs
local ipairs = _G.ipairs
local select = _G.select
local max = _G.math.max
local tinsert = _G.table.insert
local tremove = _G.table.remove
local CreateFrame = _G.CreateFrame
local LBO = LibStub("LibBlueOption-1.0")
local SM = LibStub("LibSharedMedia-3.0")
local defaultFontFile = SM.DefaultMedia.font
local defaultStatusBarTexture = "Smooth v2"

local mainMenu, unitMenu, basicMenu, classBarMenu
local unitLink = {
	["플레이어"] = "player",
	["소환수"] = "pet",
	["소환수의 대상"] = "pettarget",
	["대상"] = "target",
	["대상의 대상"] = "targettarget",
	["대상의 대상의 대상"] = "targettargettarget",
	["주시대상"] = "focus",
	["주시대상의 대상"] = "focustarget",
	["주시대상의 대상의 대상"] = "focustargettarget",
	["파티"] = "party",
	["파티 소환수"] = "partypet",
	["파티의 대상"] = "partytarget",
	["보스"] = "boss",
}

local function showDetailMenu(idx)
	if Option.selected == idx then return end
	Option.selected = idx
	Option.selectedMenu, Option.unit = nil
	Option.basicMenu:Hide()
	Option.detail:Hide()
	Option.unitMenu:Hide()
	Option.classBarMenu:Hide()
	if idx == 1 then
		-- 전체 설정창 토글
		Option.basicMenu:Show()
		if not Option.basicMenu:GetValue() then
			Option.basicMenu:SetValue(1)
		end
	elseif mainMenu[idx].name and unitLink[mainMenu[idx].name] then
		-- 유닛 설정창 토글
		Option.unit = unitLink[mainMenu[idx].name]
		Option.unitMenu:Show()
		if not Option.unitMenu:GetValue() then
			Option.unitMenu:SetValue(1)
		end
	elseif mainMenu[idx].name == "직업 특수바" then
		Option.classBarMenu:Show()
		if not Option.classBarMenu:GetValue() then
			Option.classBarMenu:SetValue(1)
		end
	else
		-- 일반 설정창 토글
		for i, menu in pairs(Option.detail.menus) do
			if i == idx then
				Option.selectedMenu = menu
				if menu.optionName and Option["Create"..menu.optionName.."Menu"] then
					Option["Create"..menu.optionName.."Menu"](Option, menu.options, menu.content)
					menu.optionName = nil
				end
				menu:Show()
			else
				menu:Hide()
			end
		end
		Option.detail:Show()
	end
end

local function toggleMenu(menus, idx)
	Option.selectedMenu = nil
	for i, menu in pairs(menus) do
		if i == idx then
			Option.selectedMenu = menu
			if menu.optionName and Option["Create"..menu.optionName.."Menu"] then
				Option["Create"..menu.optionName.."Menu"](Option, menu.options, menu.content)
				menu.optionName = nil
			end
			menu:Show()
		else
			menu:Hide()
		end
	end

end

local function toggleBasicMenu(idx)
	toggleMenu(Option.basicMenu.menus, idx)
end

local function toggleUnitMenu(idx)
	toggleMenu(Option.unitMenu.menus, idx)
end

local function toggleClassBarMenu(idx)
	toggleMenu(Option.classBarMenu.menus, idx)
end

mainMenu = {
	{ name = "전체", desc = "유닛 프레임의 기본적인 설정을 합니다.", func = showDetailMenu, needMenu = true },
	{ name = "색상", desc = "유닛 프레임에 사용될 각종 색상을 설정합니다.", func = showDetailMenu, option = "Color" },
	{ name = "플레이어", desc = "플레이어 프레임을 설정합니다.", func = showDetailMenu, needMenu = true },
	{ name = "소환수", desc = "소환수 프레임을 설정합니다.", func = showDetailMenu, needMenu = true },
	{ name = "소환수의 대상", desc = "소환수의 대상 프레임을 설정합니다.", func = showDetailMenu, needMenu = true },
	{ name = "대상", desc = "대상 프레임을 설정합니다.", func = showDetailMenu, needMenu = true },
	{ name = "대상의 대상", desc = "대상의 대상 프레임을 설정합니다.", func = showDetailMenu, needMenu = true },
	{ name = "대상의 대상의 대상", desc = "대상의 대상의 대상 프레임을 설정합니다.", func = showDetailMenu, needMenu = true },
	{ name = "주시대상", desc = "주시대상 프레임을 설정합니다.", func = showDetailMenu, needMenu = true },
	{ name = "주시대상의 대상", desc = "주시대상의 대상 프레임을 설정합니다.", func = showDetailMenu, needMenu = true },
	{ name = "주시대상의 대상의 대상", desc = "주시대상의 대상의 대상 프레임을 설정합니다.", func = showDetailMenu, needMenu = true },
	{ name = "파티", desc = "파티 프레임을 설정합니다.", func = showDetailMenu, needMenu = true },
	{ name = "파티 소환수", desc = "파티 소환수 프레임을 설정합니다.", func = showDetailMenu, needMenu = true },
	{ name = "파티의 대상", desc = "파티의 대상 프레임을 설정합니다.", func = showDetailMenu, needMenu = true },
	{ name = "보스", desc = "보스 프레임을 설정합니다.", func = showDetailMenu, needMenu = true },
	{ name = "해제 가능한 디버프", desc = "해제 가능한 디버프가 걸렸을 경우 프레임을 하이라이트합니다.", func = showDetailMenu, option = "Dispel" },
	{ name = "예상 치유량", desc = "체력바 표시되는 예상 치유량을 설정합니다.", func = showDetailMenu, option = "Heal" },
	{ name = "직업 특수바", desc = "드루이드 마나바, 주술사 토템 타이머, 죽음의 기사 룬바를 설정합니다.", func = showDetailMenu, needMenu = true },
}

basicMenu = {
	{ name = "기본 설정", func = toggleBasicMenu, option = "Basic" },
	{ name = "프로필", func = toggleBasicMenu, option = "Profile" },
	{ name = "바 모양", func = toggleBasicMenu, option = "BasicStatusBar" },
	{ name = "글꼴", func = toggleBasicMenu, option = "BasicFont" },
	{ name = "주시대상 키 설정", func = toggleBasicMenu, option = "FocusKey" },
}

unitMenu = {
	{ name = "기본", func = toggleUnitMenu, option = "UnitBasic" },
	{ name = "체력바", func = toggleUnitMenu, option = "UnitHealth" },
	{ name = "체력 글자", func = toggleUnitMenu, option = "UnitHealthText" },
	{ name = "마나바", func = toggleUnitMenu, option = "UnitMana" },
	{ name = "마나 글자", func = toggleUnitMenu, option = "UnitManaText" },
	{ name = "시전바", func = toggleUnitMenu, option = "UnitCastingBar" },
	{ name = "버프", func = toggleUnitMenu, option = "UnitBuff" },
	{ name = "디버프", func = toggleUnitMenu, option = "UnitDebuff" },
	{ name = "글자", func = toggleUnitMenu, option = "UnitText" },
}

classBarMenu = {
	{ name = "드루이드 마나바", func = toggleClassBarMenu, option = "DruidManaBar" },
	{ name = "주술사 토템 타이머", func = toggleClassBarMenu, option = "ShamanTotemTimer" },
	{ name = "죽음의 기사 룬바", func = toggleClassBarMenu, option = "DeathKnightRuneBar" },
}

local partyUnitList = {
	party = { "party1", "party2", "party3", "party4" },
	partypet = { "partypet1", "partypet2", "partypet3", "partypet4" },
	partytarget = { "party1target", "party2target", "party3target", "party4target" },
	boss = { "boss1", "boss2", "boss3", "boss4" },
}
local unitsdb = {
	player = IUF.units.player.db,
	pet = IUF.units.pet.db,
	pettarget = IUF.units.pettarget.db,
	target = IUF.units.target.db,
	targettarget = IUF.units.targettarget.db,
	targettargettarget = IUF.units.targettargettarget.db,
	focus = IUF.units.focus.db,
	focustarget = IUF.units.focustarget.db,
	focustargettarget = IUF.units.focustargettarget.db,
	party = IUF.units.party1.db,
	partypet = IUF.units.partypet1.db,
	partytarget = IUF.units.party1target.db,
	boss = IUF.units.boss1.db,
}
local barTextTypes = {
	"표시 안함", "[퍼센트%]", "[현재]/[최대]", "[현재 짧게]/[최대 짧게]",
	"[현재]/[최대] [퍼센트%]", "[현재 짧게]/[최대 짧게] [퍼센트%]",
	"[퍼센트%] [현재]/[최대]", "[퍼센트%] [현재 짧게]/[최대 짧게]",
	"[손실]", "[손실 짧게]", "[현재]", "[현재 짧게]", "[최대]","[최대 짧게]",
	"[현재 실수치]/[최대 실수치]", "[현재 실수치]/[최대 실수치] [퍼센트%]",
	"[퍼센트%] [현재 실수치]/[최대 실수치]", "[현재 실수치]", "[최대 실수치]",
}
local barTextList = { "좌측", "중앙", "우측", "좌측 외부", "우측 외부" }
local fontAttribute = { "없음", "외곽선", "굵은 외곽선", "예리하게", "예리한 외곽선", "예리한 굵은 외곽선" }
local fontAttributeSet = {
	["외곽선"] = "OUTLINE",
	["OUTLINE"] = "외곽선",
	["굵은 외곽선"] = "THICKOUTLINE",
	["THICKOUTLINE"] = "굵은 외곽선",
	["예리하게"] = "MONOCHROME",
	["MONOCHROME"] = "예리하게",
	["예리한 외곽선"] = "OUTLINE,MONOCHROME",
	["OUTLINE,MONOCHROME"] = "예리한 외곽선",
	["예리한 굵은 외곽선"] = "THICKOUTLINE,MONOCHROME",
	["THICKOUTLINE,MONOCHROME"] = "예리한 굵은 외곽선",
}
local auraFiltering = {
	[1] = "",	[""] = 1,
	[2] = "PLAYER",	["PLAYER"] = 2,
	[3] = "|RAID",	["|RAID"] = 3,
}
local buffFilteringList = { "모두 표시", "내가 시전한것만", "시전 가능한것만" }
local debuffFilteringList = { "모두 표시", "내가 시전한것만", "해제 가능한것만" }
local auraPositionList = { "위쪽", "아래쪽", "왼쪽", "오른쪽" }
local auraPositions = {
	[1] = "TOP",	TOP = 1,
	[2] = "BOTTOM",	BOTTOM = 2,
	[3] = "LEFT",	LEFT = 3,
	[4] = "RIGHT",	RIGHT = 4,
}

function Option:ADDON_LOADED()
	self:UnregisterEvent("ADDON_LOADED")
	self:SetScript("OnHide", function() IUF:CollectGarbage() end)
	-- 타이틀 만들기
	self.title = self:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	self.title:SetPoint("TOPLEFT", 10, -10)
	self.title:SetText(self.name)
	self.version = self:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	self.version:SetPoint("LEFT", self.title, "RIGHT", 2, 0)
	self.version:SetText("v"..IUF.version)
	-- 세부 메뉴의 유효성 검사
	local function menuCheck(menu)
		for p, v in pairs(menu) do
			if v.option and type(Option["Create"..v.option.."Menu"]) ~= "function" then
				tremove(menu, p)
				menuCheck(menu)
				break
			end
		end
	end
	menuCheck(mainMenu)
	menuCheck(basicMenu)
	menuCheck(unitMenu)
	menuCheck(classBarMenu)
	-- 메인 메뉴 만들기
	self.mainMenu = LBO:CreateWidget("Menu", self, mainMenu)
	self.mainMenu:SetPoint("TOPLEFT", self.title, "BOTTOMLEFT", 0, -5)
	self.mainMenu:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 10, 10)
	self.mainMenu:SetWidth(140)
	-- 세부 메뉴 생성
	self.detail = CreateFrame("Frame", nil, self)
	self.detail:Hide()
	self.detail:SetBackdrop(self.mainMenu:GetBackdrop())
	self.detail:SetBackdropBorderColor(0.6, 0.6, 0.6)
	self.detail:SetPoint("TOPLEFT", self.mainMenu, "TOPRIGHT", 3, 0)
	self.detail:SetPoint("BOTTOMRIGHT", -10, 10)
	self.detail.menus = {}
	for i = 1, #mainMenu do
		if not mainMenu[i].needMenu then
			self.detail.menus[i] = LBO:CreateWidget("ScrollFrame", self.detail)
			self.detail.menus[i]:Hide()
			self.detail.menus[i]:SetPoint("TOPLEFT", 5, -5)
			self.detail.menus[i]:SetPoint("BOTTOMRIGHT", -5, 5)
			self.detail.menus[i]:SetID(i)
			self.detail.menus[i].name = mainMenu[i].name
			self.detail.menus[i].optionName = mainMenu[i].option
			self.detail.menus[i].options = {}
		end
	end
	-- 전체 메뉴 만들기
	self.basicMenu, self.basicDetail = self:CreateTabMenu("basic", basicMenu)
	-- 유닛 메뉴 만들기
	self.unitMenu, self.unitDetail = self:CreateTabMenu("unit", unitMenu)
	-- 직업 특수 바 메뉴 만들기
	self.classBarMenu, self.classBarDetail = self:CreateTabMenu("classBar", classBarMenu)
	-- 미리보기 버튼 만들기
	self.previewButton = LBO:CreateWidget("Button", self, IUF.previewMode and "미리보기 끄기" or "미리보기 켜기", "미리보기를 켜거나 끕니다.", nil, nil, true,
		function(_, mode)
			IUF:SetPreviewMode(mode)
		end,
	nil, not IUF.previewMode)
	self.previewButton:SetWidth(100)
	self.previewButton:SetPoint("BOTTOMRIGHT", self.detail, "TOPRIGHT", 0, -10)
	-- 초기 메뉴 열기
	self.mainMenu:SetValue(1)
end

function Option:CreateTabMenu(name, menuTable)
	local m = LBO:CreateWidget("Tab", self, menuTable)
	m:Hide()
	m:SetPoint("TOPLEFT", self.mainMenu, "TOPRIGHT", 3, 5)
	m:SetPoint("TOPRIGHT", self, "TOPRIGHT", -10, -10)
	m.menus = {}
	local d = CreateFrame("Frame", nil, m)
	d:SetBackdrop(self.mainMenu:GetBackdrop())
	d:SetBackdropBorderColor(0.6, 0.6, 0.6)
	d:SetPoint("TOPLEFT", m, "BOTTOMLEFT", 0, 5)
	d:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -10, 10)
	for i = 1, #menuTable do
		m.menus[i] = LBO:CreateWidget("ScrollFrame", d)
		m.menus[i]:Hide()
		m.menus[i]:SetPoint("TOPLEFT", 5, -5)
		m.menus[i]:SetPoint("BOTTOMRIGHT", -5, 5)
		m.menus[i]:SetID(i)
		m.menus[i].name = menuTable[i].name
		m.menus[i].optionName = menuTable[i].option
		m.menus[i].options = {}
	end
	return m, d
end

function Option:Message(msg)
	if type(msg) == "string" and msg:len() > 1 then
		ChatFrame1:AddMessage("|cffffff00IUF:|r "..msg:trim(), 1, 1, 1)
	end
end

local function setCoreValueObject(object, method, ...)
	IUF[method](IUF, object, ...)
	if object.preview then
		IUF[method](IUF, object.preview, ...)
	end
end

local function setCoreValue(objectType, method, ...)
	if partyUnitList[objectType] then
		for i = 1, #partyUnitList[objectType] do
			if IUF.units[partyUnitList[objectType][i]] then
				setCoreValueObject(IUF.units[partyUnitList[objectType][i]], method, ...)
			end
		end
	elseif IUF.units[objectType] then
		setCoreValueObject(IUF.units[objectType], method, ...)
	end
end

local function setObjectValueObject(object, method, ...)
	if type(object[method]) == "function" then
		object[method](object, ...)
	else
		object[method] = ...
	end
	if object.preview then
		if type(object.preview[method]) == "function" then
			object.preview[method](object.preview, ...)
		else
			object.preview[method] = ...
		end
	end
end

local function setObjectValue(objectType, method, ...)
	if partyUnitList[objectType] then
		for i = 1, #partyUnitList[objectType] do
			if IUF.units[partyUnitList[objectType][i]] then
				setObjectValueObject(IUF.units[partyUnitList[objectType][i]], method, ...)
			end
		end
	elseif IUF.units[objectType] then
		setObjectValueObject(IUF.units[objectType], method, ...)
	end
end

local function setObjectElementValueObject(object, element, method, ...)
	if object[element] then
		if type(object[element][method]) == "function" then
			object[element][method](object[element], ...)
		else
			object[element][method] = ...
		end
	end
	if object.preview and object.preview[element] then
		if type(object.preview[element][method]) == "function" then
			object.preview[element][method](object.preview[element], ...)
		else
			object.preview[element][method] = ...
		end
	end
end

local function setObjectElementValue(objectType, element, method, ...)
	if partyUnitList[objectType] then
		for i = 1, #partyUnitList[objectType] do
			if IUF.units[partyUnitList[objectType][i]] then
				setObjectElementValueObject(IUF.units[partyUnitList[objectType][i]], element, method, ...)
			end
		end
	elseif IUF.units[objectType] then
		setObjectElementValueObject(IUF.units[objectType], element, method, ...)
	end
end

local function setObjectHandlerUpdate(objectType, handler, ...)
	if IUF.handlers[handler] then
		if partyUnitList[objectType] then
			for i = 1, #partyUnitList[objectType] do
				if IUF.units[partyUnitList[objectType][i]] and not IUF.units[partyUnitList[objectType][i]].needAutoUpdate then
					IUF.handlers[handler](IUF.units[partyUnitList[objectType][i]], ...)
				end
			end
		elseif IUF.units[objectType] and not IUF.units[objectType].needAutoUpdate then
			IUF.handlers[handler](IUF.units[objectType], ...)
		end
	end
end

local function updateElementSkin(objectType, element)
	if partyUnitList[objectType] then
		for i = 1, #partyUnitList[objectType] do
			if IUF.units[partyUnitList[objectType][i]] then
				IUF:SetObjectElementSkin(IUF.units[partyUnitList[objectType][i]], element)
				if IUF.units[partyUnitList[objectType][i]].preview then
					IUF:SetObjectElementSkin(IUF.units[partyUnitList[objectType][i]].preview, element)
				end
			end
		end
	elseif IUF.units[objectType] then
		IUF:SetObjectElementSkin(IUF.units[objectType], element)
		if IUF.units[objectType].preview then
			IUF:SetObjectElementSkin(IUF.units[objectType].preview, element)
		end
	end
end

local function updateFontStringObject(object, element)
	if object[element] then
		IUF:SetFontString(object[element], object.db[element.."FontFile"], object.db[element.."FontSize"], object.db[element.."FontAttribute"], object.db[element.."FontShadow"])
	end
	if object.preview and object.preview[element] then
		IUF:SetFontString(object.preview[element], object.db[element.."FontFile"], object.db[element.."FontSize"], object.db[element.."FontAttribute"], object.db[element.."FontShadow"])
	end
end

local function updateFontString(objectType, element)
	if partyUnitList[objectType] then
		for i = 1, #partyUnitList[objectType] do
			if IUF.units[partyUnitList[objectType][i]] then
				updateFontStringObject(IUF.units[partyUnitList[objectType][i]], element)
			end
		end
	elseif IUF.units[objectType] then
		updateFontStringObject(IUF.units[objectType], element)
	end
end

local function notActiveParentObject()
	if Option.unit then
		Option.parentUnit = IUF.units[partyUnitList[Option.unit] and partyUnitList[Option.unit][1] or Option.unit].parent
		if Option.parentUnit then
			return not IUF.db.units[IUF.units[Option.parentUnit].objectType].active
		end
	end
	return nil
end

local function notActiveObject()
	if Option.unit then
		if IUF.db.units[Option.unit].active then
			Option.parentUnit = IUF.units[partyUnitList[Option.unit] and partyUnitList[Option.unit][1] or Option.unit].parent
			if Option.parentUnit then
				return not IUF.db.units[IUF.units[Option.parentUnit].objectType].active
			else
				return nil
			end
		else
			return true
		end
		return not IUF.db.units[Option.unit].active
	else
		return true
	end
end

local most, mvalue, mcount = {}

local function getMostOptionValue(...)
	for i = 1, select("#", ...) do
		mcount = select(i, ...)
		for unit, db in pairs(unitsdb) do
			mvalue = db[mcount] or false
			most[mvalue] = (most[mvalue] or 0) + 1
		end
	end
	mcount, mvalue = 0
	for p, v in pairs(most) do
		if v > mcount then
			mvalue, mcount = p, v
		end
		most[p] = nil
	end
	return mvalue, mcount
end

function Option:CreateBasicMenu(menu, parent)
	menu.skin = LBO:CreateWidget("DropDown", parent, "스킨", "프레임의 스킨을 설정합니다.", nil, nil, true,
		function() return IUF.db.skinName, IUF.skinDB.list end,
		function(v)
			v = IUF.skinDB.name[v]
			if v and IUF.db.skin ~= v then
				Option:SetSkin(v)
				LBO:Refresh()
			end
		end
	)
	menu.skin:SetPoint("TOPLEFT", 5, -5)
	menu.skin.button:SetScript("PreClick", function()
		IUF:LoadAllSkinAddOns()
		sort(IUF.skinDB.list, function(a, b)
			if a:find("^기본") then
				if b:find("^기본") then
					return a < b
				else
					return true
				end
			elseif b:find("^기본") then
				return false
			else
				return a < b
			end
		end)
	end)
	menu.tooltip = LBO:CreateWidget("DropDown", parent, "툴팁", "툴팁 표시에 관한 설정을 합니다.", nil, nil, nil, function() return IUF.db.tooltip, { "항상", "전투중이 아닐때", "전투중에만", "표시 안함" } end, function(v) IUF.db.tooltip = v end)
	menu.tooltip:SetPoint("TOPRIGHT", -5, -5)
	menu.lock = LBO:CreateWidget("CheckBox", parent, "프레임 고정", "프레임을 잠가 이동하지 못하게 합니다. 주시대상 프레임은 Alt+드래그로 계속해서 이동할 수 있습니다.", nil, nil, nil, function() return IUF.db.lock end, function(v) IUF.db.lock = v end)
	menu.lock:SetPoint("TOP", menu.skin, "BOTTOM", 0, -10)
	menu.highlight = LBO:CreateWidget("Slider", parent, "하이라이트 투명도", "프레임에 마우스를 올렸을때 표시되는 하이라이트의 투명도를 설정합니다. 0%로 설정하면 하이라이트가 표시되지 않습니다.", nil, nil, nil,
		function() return IUF.db.highlightAlpha * 100, 0, 100, 1, "%" end,
		function(v)
			IUF.db.highlightAlpha = v / 100
			IUF.highlightFrame.tex:SetAlpha(IUF.db.highlightAlpha)
		end
	)
	menu.highlight:SetPoint("TOP", menu.tooltip, "BOTTOM", 0, -10)
	menu.reset = LBO:CreateWidget("Button", parent, "설정 초기화", "모든 유닛 프레임의 상세 설정을 초기값으로 되돌립니다.", nil, nil, true,
		function()
			Option:ClearSetting()
			LBO:Refresh()
		end
	)
	menu.reset:SetPoint("TOP", menu.lock, "BOTTOM", 0, 0)
	menu.resetLoc = LBO:CreateWidget("Button", parent, "위치 초기화", "모든 유닛 프레임의 위치를 초기값으로 되돌립니다.", nil, nil, true,
		function()
			Option:ClearLocation()
		end
	)
	menu.resetLoc:SetPoint("TOP", menu.highlight, "BOTTOM", 0, 0)
	menu.scale = LBO:CreateWidget("Slider", parent, "전체 크기", "모든 유닛 프레임의 크기를 설정합니다.", nil, nil, true,
		function() return IUF.db.scale * 100, 50, 150, 1, "%" end,
		function(v)
			IUF.db.scale = v / 100
			IUF:SetScale(IUF.db.scale)
		end
	)
	menu.scale:SetPoint("TOP", menu.reset, "BOTTOM", 0, 0)
	menu.mapButtonShown = LBO:CreateWidget("CheckBox", parent, "미니맵 버튼 보이기", "미니맵 버튼을 보이거나 숨깁니다.", nil, nil, nil,
		function() return InvenUnitFramesDB.minimapButton.show end,
		function(v)
			InvenUnitFramesDB.minimapButton.show = v
			if v then
				InvenUnitFramesMapButton:Show()
			else
				InvenUnitFramesMapButton:Hide()
			end
			LBO:Refresh()
		end
	)
	menu.mapButtonShown:SetPoint("TOP", menu.scale, "BOTTOM", 0, 0)
	menu.mapButtonDrag = LBO:CreateWidget("CheckBox", parent, "미니맵 버튼 고정", "미니맵 버튼을 잠가 이동하지 못하게합니다.", nil,
		function() return not InvenUnitFramesDB.minimapButton.show end, nil,
		function() return not InvenUnitFramesDB.minimapButton.dragable end,
		function(v)
			InvenUnitFramesDB.minimapButton.dragable = not v
		end
	)
	menu.mapButtonDrag:SetPoint("TOP", menu.resetLoc, "BOTTOM", 0, -44)

	menu.hideInRaid = LBO:CreateWidget("CheckBox", parent, "공격대 참여시 파티 프레임 숨김", "공격대 참여시 파티 프레임을 숨겨줍니다.", nil , nil, true,
		function() return IUF.db.hideInRaid end,
		function(v)
			IUF.db.hideInRaid = v
			setCoreValue("party", "SetActiveObject")
		end
	)
	menu.hideInRaid:SetPoint("TOP", menu.mapButtonShown, "BOTTOM", 0, 0)
end

function Option:CreateProfileMenu(menu, parent)
	local profiles = {}
	local function sortfunc(a, b)
		if a == "Default" then
			return true
		elseif b == "Default" then
			return false
		else
			return a < b
		end
	end
	local function returnProfiles()
		for p in pairs(profiles) do
			profiles[p] = nil
		end
		for key in pairs(InvenUnitFramesDB.profiles) do
			tinsert(profiles, key)
		end
		sort(profiles, sortfunc)
		return profiles
	end
	menu.select = LBO:CreateWidget("DropDown", parent, "프로필 선택", "프로필을 선택합니다.", nil, nil, true,
		function() return InvenUnitFramesDB.profile[IUF.dbKey], returnProfiles() end,
		function(v)
			if InvenUnitFramesDB.profile[IUF.dbKey] ~= v then
				Option:Message(("%s|1으로;로; 프로필이 변경되었습니다."):format(v))
				IUF:SelectProfile(v)
				LBO:Refresh()
			end
		end
	)
	menu.select:SetPoint("TOPLEFT", 5, -5)
	menu.reset = LBO:CreateWidget("Button", parent, "프로필 초기화", "현재 프로필을 초기화합니다.", nil, nil, true, function() IUF:ResetProfile(InvenUnitFramesDB.profile[IUF.dbKey]) end)
	menu.reset:SetPoint("TOPRIGHT", -5, -5)
	menu.copyTargetProfile = "Default"
	menu.copyTarget = LBO:CreateWidget("DropDown", parent, nil, "새로운 프로필을 만듭니다.", nil, nil, true,
		function() return menu.copyTargetProfile, returnProfiles() end,
		function(v)
			menu.copyTargetProfile = v
		end
	)
	menu.copyTarget:SetWidth(130)
	menu.copyTarget:SetPoint("TOPRIGHT", menu.reset, "BOTTOMRIGHT", 0, 0)
	menu.copy = LBO:CreateWidget("EditBox", parent, "새 프로필 만들기", "새로운 프로필을 만듭니다.", nil, nil, true, nil,
		function(v)
			if v and v:len() > 0 then
				if InvenUnitFramesDB.profiles[v] then
					Option:Message(("%s|1은;는; 이미 존재하는 프로필이기 때문에 새로 만들 수 없습니다."):format(v))
				else
					IUF:CreateNewProfile(v, menu.copyTargetProfile)
					Option:Message(("%s|1으로;로; 새 프로필을 만들었습니다."):format(v))
					LBO:Refresh()
				end
			end
		end
	)
	menu.copy:SetWidth(0)
	menu.copy:SetPoint("TOPLEFT", menu.select, "BOTTOMLEFT", 0, -8)
	menu.copy:SetPoint("RIGHT", menu.copyTarget, "LEFT", 0, 0)
	local delprofiles = {}
	local function returnDeletableProfiles()
		for p in pairs(delprofiles) do
			delprofiles[p] = nil
		end
		for key in pairs(InvenUnitFramesDB.profiles) do
			if key ~= "Default" then
				tinsert(delprofiles, key)
			end
		end
		sort(delprofiles, sortfunc)
		return delprofiles
	end
	menu.delete = LBO:CreateWidget("DropDown", parent, "프로필 삭제", "선택된 프로필을 삭제합니다.", nil, function() return #(returnDeletableProfiles()) == 0 end, true,
		function() return "", returnDeletableProfiles() end,
		function(v)
			IUF:DeleteProfile(v)
			Option:Message(("%s 프로필이 삭제되었습니다."):format(v))
			if v == copyTarget then
				copyTarget = "Default"
			end
			LBO:Refresh()
		end
	)
	menu.delete:SetPoint("TOPLEFT", menu.copy, "BOTTOMLEFT", 0, 0)
end

function Option:CreateBasicStatusBarMenu(menu, parent)
	menu.barAll = LBO:CreateWidget("Media", parent, "전체 바 모양", "모든 유닛 프레임의 바 모양을 일괄 설정합니다.", nil, nil, nil,
		function()
			return getMostOptionValue("healthBarTexture", "powerBarTexture", "castingBarTexture") or "Smooth v2", "statusbar"
		end,
		function(v)
			local f = SM:Fetch("statusbar", v)
			for unit in pairs(IUF.db.units) do
				unitsdb[unit].healthBarTexture = v
				unitsdb[unit].powerBarTexture = v
				unitsdb[unit].castingBarTexture = v
				setObjectElementValue(unit, "healthBar", "SetTexture", f)
				setObjectElementValue(unit, "powerBar", "SetTexture", f)
				updateElementSkin(unit, "castingBar")
				setCoreValue(unit, "TriggerCallback", "CastingBar")
			end
			LBO:Refresh()
		end
	)
	menu.barAll:SetPoint("TOPLEFT", 5, -5)
	menu.barHealth = LBO:CreateWidget("Media", parent, "전체 체력바 모양", "모든 유닛 프레임의 체력바 모양을 일괄 설정합니다.", nil, nil, nil,
		function()
			return getMostOptionValue("healthBarTexture") or "Smooth v2", "statusbar"
		end,
		function(v)
			local f = SM:Fetch("statusbar", v)
			for unit in pairs(IUF.db.units) do
				unitsdb[unit].healthBarTexture = v
				setObjectElementValue(unit, "healthBar", "SetTexture", f)
			end
			LBO:Refresh()
		end
	)
	menu.barHealth:SetPoint("TOPRIGHT", -5, -5)
	menu.barPower = LBO:CreateWidget("Media", parent, "전체 마나바 모양", "모든 유닛 프레임의 마나바 모양을 일괄 설정합니다.", nil, nil, nil,
		function()
			return getMostOptionValue("powerBarTexture") or "Smooth v2", "statusbar"
		end,
		function(v)
			local f = SM:Fetch("statusbar", v)
			for unit in pairs(IUF.db.units) do
				unitsdb[unit].powerBarTexture = v
				setObjectElementValue(unit, "powerBar", "SetTexture", f)
			end
			LBO:Refresh()
		end
	)
	menu.barPower:SetPoint("TOP", menu.barAll, "BOTTOM", 0, -5)
	menu.barCasting = LBO:CreateWidget("Media", parent, "전체 시전바 모양", "모든 유닛 프레임의 시전바 모양을 일괄 설정합니다.", nil, nil, nil,
		function()
			return getMostOptionValue("castingBarTexture") or "Smooth v2", "statusbar"
		end,
		function(v)
			for unit in pairs(IUF.db.units) do
				unitsdb[unit].castingBarTexture = v
				updateElementSkin(unit, "castingBar")
				setCoreValue(unit, "TriggerCallback", "CastingBar")
			end
			LBO:Refresh()
		end
	)
	menu.barCasting:SetPoint("TOP", menu.barHealth, "BOTTOM", 0, -5)
	menu.classColor = LBO:CreateWidget("CheckBox", parent, "직업별 체력바 색상", "체력바 색상에 직업별 색상을 사용합니다.", nil, nil, nil,
		function()
			return getMostOptionValue("healthBarClassColor")
		end,
		function(v)
			for unit in pairs(IUF.db.units) do
				unitsdb[unit].healthBarClassColor = v
				for _, object in pairs(IUF.units) do
					if not object.needElement then
						object.healthBar.classColor = v
						IUF.callbacks.HealthColor(object)
					end
				end
			end
			LBO:Refresh()
		end
	)
	menu.classColor:SetPoint("TOP", menu.barPower, "BOTTOM", 0, 0)
	menu.classColorEnemy = LBO:CreateWidget("CheckBox", parent, "상대 진영 플레이어도 직업 색상으로 표시", "상대 진영 플레이어에게도 직업별 체력바 색상을 사용합니다.", nil,
		function()
			return not getMostOptionValue("healthBarClassColor")
		end, nil,
		function()
			return IUF.db.useEnemyClassColor
		end,
		function(v)
			IUF.db.useEnemyClassColor = v
			for unit in pairs(unitsdb) do
				setCoreValue(unit, "TriggerCallback", "HealthColor")
			end
		end
	)
	menu.classColorEnemy:SetPoint("TOP", menu.classColor, "BOTTOM", 0, 15)

	menu.barAnimation = LBO:CreateWidget("CheckBox", parent, "바 애니메이션 사용", "바의 감소를 부드럽게 표현합니다.", nil, nil, nil,
		function()
			return IUF.db.barAnimation
		end,
		function(v)
			IUF.db.barAnimation = v
		end
	)
	menu.barAnimation:SetPoint("TOP", menu.barCasting, "BOTTOM", 0, 0)
end

function Option:CreateBasicFontMenu(menu, parent)
	self.fontElements = { castingBarText = true, castingBarTime = true }
	local function addFontObject(tbl)
		for p in pairs(tbl) do
			if type(p) == "string" and p:find("(.+)FontFile$") then
				Option.fontElements[p:gsub("FontFile$", "")] = true
			end
		end
	end
	addFontObject(IUF.overrideSkin)
	for _, db in pairs(IUF.overrideUnitSkin) do
		addFontObject(db)
	end
	self.fontFiles, self.fontAttributes, self.fontShadows = {}, {}, {}
	for p in pairs(self.fontElements) do
		tinsert(self.fontFiles, p.."FontFile")
		tinsert(self.fontAttributes, p.."FontAttribute")
		tinsert(self.fontShadows, p.."FontShadow")
	end
	local textFontList = { "이름", "레벨", "상태", "시전바", "체력", "마나" }
	local textFontElement = {
		["이름"] = { "nameText" },
		["레벨"] = { "levelText" },
		["상태"] = { "stateText" },
		["시전바"] = { "castingBarText", "castingBarTime" },
		["체력"] = { "healthText1", "healthText2", "healthText3", "healthText4", "healthText5" },
		["마나"] = { "powerText1", "powerText2", "powerText3", "powerText4", "powerText5" },
	}
	local textFontFiles, textFontAttributes, textFontShadows, textFontHeights = {}, {}, {}, {}
	for p, t in pairs(textFontElement) do
		textFontFiles[p], textFontAttributes[p], textFontShadows[p], textFontHeights[p] = {}, {}, {}, {}
		for i, v in pairs(t) do
			tinsert(textFontFiles[p], v.."FontFile")
			tinsert(textFontAttributes[p], v.."FontAttribute")
			tinsert(textFontShadows[p], v.."FontShadow")
			tinsert(textFontHeights[p], v.."FontHeight")
		end
	end
	local function getFontValue(name)
		if name then
			return getMostOptionValue(unpack(textFontFiles[name])), nil, getMostOptionValue(unpack(textFontAttributes[name])), getMostOptionValue(unpack(textFontShadows[name])), true
		else
			return getMostOptionValue(unpack(Option.fontFiles)), nil, getMostOptionValue(unpack(Option.fontAttributes)), getMostOptionValue(unpack(Option.fontShadows)), true
		end
	end
	local function updateFontValue(element, file, attribute, shadow)
		for unit, db in pairs(unitsdb) do
			db[element.."FontFile"] = file
			db[element.."FontAttribute"] = attribute
			db[element.."FontShadow"] = shadow
			if element == "castingBarText" or element == "castingBarTime" then
				updateElementSkin(unit, "castingBar")
				setCoreValue(unit, "TriggerCallback", "CastingBar")
			else
				updateElementSkin(unit, element)
			end
		end
	end
	menu.fontAll = LBO:CreateWidget("Font", parent, "전체 글꼴", "모든 유닛 프레임의 글꼴을 일괄 설정합니다.", nil, nil, nil, getFontValue,
		function(file, _, attribute, shadow)
			for element in pairs(Option.fontElements) do
				updateFontValue(element, file, attribute, shadow)
			end
		end
	)
	menu.fontAll:SetPoint("TOPLEFT", 5, -5)
	local function setFontValue(file, _, attribute, shadow, name)
		for _, element in pairs(textFontElement[name]) do
			for unit, db in pairs(unitsdb) do
				updateFontValue(element, file, attribute, shadow)
			end
		end
	end
	for i, name in ipairs(textFontList) do
		menu["font"..i] = LBO:CreateWidget("Font", parent, "전체 "..name.." 글꼴", "모든 유닛 프레임의 "..name.." 글꼴을 일괄 설정합니다.", nil, nil, nil, getFontValue, setFontValue, name)
		if i == 1 then
			menu.font1:SetPoint("TOP", menu.fontAll, "BOTTOM", 0, -10)
		elseif i == 2 then
			menu.font2:SetPoint("TOPRIGHT", -5, -60)
		else
			menu["font"..i]:SetPoint("TOP", menu["font"..(i - 2)], "BOTTOM", 0, -10)
		end
	end
end

function Option:CreateFocusKeyMenu(menu, parent)
	menu.desc = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	menu.desc:SetPoint("TOPLEFT", 5, -5)
	menu.desc:SetPoint("TOPRIGHT", -5, -5)
	menu.desc:SetJustifyH("LEFT")
	menu.desc:SetJustifyV("TOP")
	menu.desc:SetHeight(90)
	menu.desc:SetText(" 모든 외부 유닛 프레임 애드온들은 메뉴에 있는 주시대상 설정 및 해제 메뉴를 사용할 수 없습니다. 인벤 유닛 프레임도 예외일 수 없기 때문에 아래에 설정한 기능키와 마우스 버튼 조합으로 주시대상을 설정 및 해제하게 됩니다.\n 주시대상이 아닌 다른 유닛 프레임을 설정한 조합으로 클릭하면 주시대상으로 설정되고 주시대상 프레임을 클릭하면 주시대상이 해제됩니다.")
	local modList = { "사용 안함", "Shift", "Ctrl", "Alt", "Shift+Ctrl", "Shift+Alt", "Alt+Ctrl" }
	menu.modkey = LBO:CreateWidget("DropDown", parent, "기능키", nil, nil, nil, true,
		function()
			menu.setting:update()
			return IUF.db.focusKey.mod + 1, modList
		end,
		function(v)
			IUF.db.focusKey.mod = v - 1
			LBO:Refresh()
			for _, object in pairs(IUF.units) do
				IUF:RegisterFocusKey(object)
			end
		end
	)
	menu.modkey:SetPoint("TOPLEFT", menu.desc, "BOTTOMLEFT", 0, 0)
	local buttonList = { "좌측 버튼", "우측 버튼", "가운데 버튼", "4번 버튼", "5번 버튼", "6번 버튼", "7번 버튼", "8번 버튼", "9번 버튼", "10번 버튼" }
	menu.button = LBO:CreateWidget("DropDown", parent, "마우스 버튼", nil, nil, function() return IUF.db.focusKey.mod == 0 end, true,
		function()
			menu.setting:update()
			return IUF.db.focusKey.button, buttonList
		end,
		function(v)
			IUF.db.focusKey.button = v
			for _, object in pairs(IUF.units) do
				IUF:RegisterFocusKey(object)
			end
		end
	)
	menu.button:SetPoint("TOPRIGHT", menu.desc, "BOTTOMRIGHT", 0, 0)
	menu.setting = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	menu.setting:SetPoint("TOPLEFT", menu.modkey, "BOTTOMLEFT", 0, -12)
	menu.setting:SetPoint("TOPRIGHT", menu.button, "BOTTOMRIGHT", 0, -12)
	menu.setting:SetJustifyH("CENTER")
	menu.setting:SetHeight(40)
	menu.setting.update = function(self)
		if IUF.db.focusKey.mod == 0 then
			self:SetText("주시대상 설정 및 해제를 사용하지 않습니다.")
		else
			self:SetFormattedText("|cffffff00%s + 마우스 %s|r|1으로;로; 주시대상을 설정 및 해제합니다.", modList[IUF.db.focusKey.mod + 1]:gsub("%+", " + "), buttonList[IUF.db.focusKey.button])
		end
	end
end

function Option:CreateColorMenu(menu, parent)
	local function getColor(colortype, colorsubtype)
		return unpack(IUF.colordb[colortype][colorsubtype])
	end
	local function setColor(r, g, b, colortype, colorsubtype, updatefunc)
		IUF.colordb[colortype][colorsubtype][1] = r
		IUF.colordb[colortype][colorsubtype][2] = g
		IUF.colordb[colortype][colorsubtype][3] = b
		if type(updatefunc) == "function" then
			updatefunc()
		end
	end
	menu.class = LBO:CreateWidget("Heading", parent, "직업 색상")
	menu.class:SetPoint("TOPLEFT", 5, 10)
	menu.class:SetPoint("TOPRIGHT", -5, 10)
	menu.class:SetScale(1.2)
	local classOrder = { "WARRIOR", "ROGUE", "PRIEST", "MAGE", "WARLOCK", "HUNTER", "DRUID", "SHAMAN", "PALADIN", "DEATHKNIGHT", "PET", "FRIEND", "NEUTRAL", "ENEMY" }
	local classNames = {
		WARRIOR = "전사", ROGUE = "도적", PRIEST = "사제", MAGE = "마법사", WARLOCK = "흑마법사",
		HUNTER = "사냥꾼", DRUID = "드루이드", SHAMAN = "주술사", PALADIN = "성기사", DEATHKNIGHT = "죽음의 기사",
		PET = "소환수", FRIEND = "우호적 대상", NEUTRAL = "중립적 대상", ENEMY = "적대적 대상",
	}
	local function classColorUpdate()
		for _, object in pairs(IUF.units) do
			if not object.needElement then
				IUF.callbacks.NameColor(object)
				IUF.callbacks.HealthColor(object)
			end
			if object.preview then
				IUF.callbacks.NameColor(object.preview)
				IUF.callbacks.HealthColor(object.preview)
			end
		end
	end
	menu.classReset = LBO:CreateWidget("Button", parent, "초기화", "모든 직업 색상 설정을 초기화합니다.", nil, nil, nil,
		function()
			IUF.colordb.class.FRIEND[1] = 0
			IUF.colordb.class.FRIEND[2] = 1
			IUF.colordb.class.FRIEND[3] = 0
			IUF.colordb.class.NEUTRAL[1] = 1
			IUF.colordb.class.NEUTRAL[2] = 1
			IUF.colordb.class.NEUTRAL[3] = 0
			IUF.colordb.class.ENEMY[1] = 1
			IUF.colordb.class.ENEMY[2] = 0.12
			IUF.colordb.class.ENEMY[3] = 0.12
			IUF.colordb.class.PET[1] = 0
			IUF.colordb.class.PET[2] = 1
			IUF.colordb.class.PET[3] = 0
			for class, color in pairs(RAID_CLASS_COLORS) do
				if IUF.colordb.class[class] then
					IUF.colordb.class[class][1] = color.r
					IUF.colordb.class[class][2] = color.g
					IUF.colordb.class[class][3] = color.b
				end
			end
			LBO:Refresh()
			classColorUpdate()
		end
	)
	menu.classReset:SetPoint("RIGHT", menu.class, "RIGHT", 0, 0)
	menu.classReset:SetScale(0.9)
	menu.classReset:SetWidth(60)
	for i, class in ipairs(classOrder) do
		menu["class"..i] = LBO:CreateWidget("ColorPicker", parent, classNames[class], classNames[class].."의 색상을 설정합니다", nil, nil, nil, getColor, setColor, "class", class, classColorUpdate)
		menu["class"..i]:SetWidth(90)
		if i == 1 then
			menu["class"..i]:SetPoint("TOPLEFT", 5, -16)
		elseif i == 2 then
			menu["class"..i]:SetPoint("TOP", 0, -16)
		elseif i == 3 then
			menu["class"..i]:SetPoint("TOPRIGHT", -5, -16)
		else
			menu["class"..i]:SetPoint("TOP", menu["class"..(i - 3)], "BOTTOM", 0, 12)
		end
	end
	menu.power = LBO:CreateWidget("Heading", parent, "파워 색상")
	menu.power:SetPoint("TOPLEFT", 5, -146)
	menu.power:SetPoint("TOPRIGHT", -5, -146)
	menu.power:SetScale(1.2)
	local function powerColorUpdate()
		for _, object in pairs(IUF.units) do
			if not object.needElement then
				IUF.callbacks.PowerColor(object)
				if object.classBar and IUF.ClassBarSetup then
					IUF:ClassBarSetup(object)
				end
			end
			if object.preview then
				IUF.callbacks.PowerColor(object.preview)
			end
		end
	end
	menu.powerReset = LBO:CreateWidget("Button", parent, "초기화", "모든 파워 색상 설정을 초기화합니다.", nil, nil, nil,
		function()
			for power, color in pairs(IUF.colordb.power) do
				if PowerBarColor[power] then
					color[1] = PowerBarColor[power].r
					color[2] = PowerBarColor[power].g
					color[3] = PowerBarColor[power].b
				end
			end
			LBO:Refresh()
			powerColorUpdate()
		end
	)
	menu.powerReset:SetPoint("RIGHT", menu.power, "RIGHT", 0, 0)
	menu.powerReset:SetScale(0.9)
	menu.powerReset:SetWidth(60)
	local powerOrder = { 0, 1, 3, 6, 2 }
	local powerNames = { [0] = "마나", [1] = "분노", [3] = "기력", [6] = "룬 마력", [2] = "집중력" }
	for i, power in ipairs(powerOrder) do
		menu["power"..i] = LBO:CreateWidget("ColorPicker", parent, powerNames[power], powerNames[power].."의 색상을 설정합니다", nil, nil, nil, getColor, setColor, "power", power, powerColorUpdate)
		menu["power"..i]:SetWidth(90)
		if i == 1 then
			menu["power"..i]:SetPoint("TOPLEFT", menu.power, "BOTTOMLEFT", 0, 26)
		elseif i == 2 then
			menu["power"..i]:SetPoint("TOP", menu.power, "BOTTOM", 0, 26)
		elseif i == 3 then
			menu["power"..i]:SetPoint("TOPRIGHT", menu.power, "BOTTOMRIGHT", 0, 26)
		else
			menu["power"..i]:SetPoint("TOP", menu["power"..(i - 3)], "BOTTOM", 0, 12)
		end
	end
	menu.casting = LBO:CreateWidget("Heading", parent, "시전바 색상")
	menu.casting:SetPoint("TOPLEFT", 5, -216)
	menu.casting:SetPoint("TOPRIGHT", -5, -216)
	menu.casting:SetScale(1.2)
	local function castingColorUpdate()
		for object in pairs(IUF.visibleObject) do
			if not object.needElement then
				IUF.callbacks.CastingBarColor(object)
			end
			if object.preview then
				IUF.callbacks.CastingBarColor(object.preview)
			end
		end
	end
	menu.castingReset = LBO:CreateWidget("Button", parent, "초기화", "시전바 색상 설정을 초기화합니다.", nil, nil, nil,
		function()
			IUF.colordb.casting.NORMAL[1] = 1
			IUF.colordb.casting.NORMAL[2] = 0.7
			IUF.colordb.casting.NORMAL[3] = 0
			IUF.colordb.casting.SHIELD[1] = 1
			IUF.colordb.casting.SHIELD[2] = 0
			IUF.colordb.casting.SHIELD[3] = 0
			IUF.colordb.casting.CHANNEL[1] = 0.4
			IUF.colordb.casting.CHANNEL[2] = 0.6
			IUF.colordb.casting.CHANNEL[3] = 0.8
			LBO:Refresh()
			castingColorUpdate()
		end
	)
	menu.castingReset:SetPoint("RIGHT", menu.casting, "RIGHT", 0, 0)
	menu.castingReset:SetScale(0.9)
	menu.castingReset:SetWidth(60)
	local castingOrder = { "NORMAL", "CHANNEL", "SHIELD" }
	local castingNames = { "일반", "정신 집중", "차단 불가능" }
	for i, casting in ipairs(castingOrder) do
		menu["casting"..i] = LBO:CreateWidget("ColorPicker", parent, castingNames[i], castingNames[i].."의 색상을 설정합니다", nil, nil, nil, getColor, setColor, "casting", casting, castingColorUpdate)
		menu["casting"..i]:SetWidth(90)
		if i == 1 then
			menu["casting"..i]:SetPoint("TOPLEFT", menu.casting, "BOTTOMLEFT", 0, 26)
		elseif i == 2 then
			menu["casting"..i]:SetPoint("TOP", menu.casting, "BOTTOM", 0, 26)
		elseif i == 3 then
			menu["casting"..i]:SetPoint("TOPRIGHT", menu.casting, "BOTTOMRIGHT", 0, 26)
		else
			menu["casting"..i]:SetPoint("TOP", menu["casting"..(i - 3)], "BOTTOM", 0, 12)
		end
	end
	menu.etc = LBO:CreateWidget("Heading", parent, "연계 점수 색상")
	menu.etc:SetPoint("TOPLEFT", 5, -260)
	menu.etc:SetPoint("TOPRIGHT", -5, -260)
	menu.etc:SetScale(1.2)
	local function comboColorUpdate()
		for _, object in pairs(IUF.units) do
			if object.comboFrame then
				for i = 1, 5 do
					object.comboFrame[i].highlight:SetVertexColor(unpack(IUF.colordb.combo))
				end
			end
			if object.preview and object.preview.comboFrame then
				for i = 1, 5 do
					object.preview.comboFrame[i].highlight:SetVertexColor(unpack(IUF.colordb.combo))
				end
			end
		end
	end
	menu.etcReset = LBO:CreateWidget("Button", parent, "초기화", "연계 점수 색상 설정을 초기화합니다.", nil, nil, nil,
		function()
			IUF.colordb.combo[1] = 1
			IUF.colordb.combo[2] = 1
			IUF.colordb.combo[3] = 0
			LBO:Refresh()
			comboColorUpdate()
		end
	)
	menu.etcReset:SetPoint("RIGHT", menu.etc, "RIGHT", 0, 0)
	menu.etcReset:SetScale(0.9)
	menu.etcReset:SetWidth(60)
	menu.combo = LBO:CreateWidget("ColorPicker", parent, "연계 점수", "연계 점수의 색상을 설정합니다.", nil, nil, nil,
		function() return unpack(IUF.colordb.combo) end,
		function(r, g, b)
			IUF.colordb.combo[1] = r
			IUF.colordb.combo[2] = g
			IUF.colordb.combo[3] = b
			comboColorUpdate()
		end
	)
	menu.combo:SetPoint("TOPLEFT", menu.etc, "BOTTOMLEFT", 0, 26)
end

function Option:CreateBlizzardMenu(menu, parent)
	menu.hiddenBlizzard = LBO:CreateWidget("CheckBox", parent, "와우 기본 시전바 숨기기", "와우 기본 시전바를 보이거나 숨깁니다.", nil, nil, nil,
		function()
			return unitsdb.player.hiddenBlizzardCastingBar
		end,
		function(v)
			unitsdb.player.hiddenBlizzardCastingBar = v
			if v then
				CastingBarFrame.showCastbar = nil
				PetCastingBarFrame.showCastbar = nil
			else
				CastingBarFrame.showCastbar = true
				PetCastingBarFrame.showCastbar = true
			end
			CastingBarFrame_UpdateIsShown(CastingBarFrame)
			CastingBarFrame_UpdateIsShown(PetCastingBarFrame)
		end
	)
	menu.hiddenBlizzard:SetPoint("TOPLEFT", 5, -5)

	menu.showTotem = LBO:CreateWidget("CheckBox", parent, "와우 기본 토템 타이머 보이기", "와우 기본 토템 타이머를 보이게 합니다. 일부 와우 기본 토템 타이머를 재사용하는 애드온 사용 시 체크하세요", nil, nil, nil,
		function() return IUF.db.classBar.SHAMAN.showBlizzard end,
		function(v)
			IUF.db.classBar.SHAMAN.showBlizzard = v
			if IUF.units.player.classBar and IUF.units.player.classBar.type == "SHAMAN" then
				IUF:ClassBarSetup(IUF.units.player)
			end
		end
	)
	menu.showTotem:SetPoint("TOPLEFT", 5, -42)
	menu.showRune = LBO:CreateWidget("CheckBox", parent, "와우 기본 룬바 보이기", "와우 기본 룬바를 보이게 합니다. 일부 와우 기본 룬바를 재사용하는 애드온 사용 시 체크하세요", nil, nil, nil,
		function() return IUF.db.classBar.DEATHKNIGHT.showBlizzard end,
		function(v)
			IUF.db.classBar.DEATHKNIGHT.showBlizzard = v
			if IUF.units.player.classBar and IUF.units.player.classBar.type == "DEATHKNIGHT" then
				IUF:ClassBarSetup(IUF.units.player)
			end
		end
	)
	menu.showRune:SetPoint("TOPRIGHT", -5, -42)

end

function Option:CreateUnitBasicMenu(menu, parent)
	menu.active = LBO:CreateWidget("CheckBox", parent, "활성화", "프레임을 사용합니다.", nil, notActiveParentObject, true,
		function() return IUF.db.units[Option.unit].active end,
		function(v)
			IUF.db.units[Option.unit].active = v
			setCoreValue(Option.unit, "SetActiveObject")
			if IUF.previewMode then
				IUF:SetPreviewMode(true)
			end
			LBO:Refresh()
		end
	)
	menu.active:SetPoint("TOPLEFT", 5, -5)
	menu.skinType = LBO:CreateWidget("DropDown", parent, "형태", "프레임의 형태를 변경합니다.", nil, notActiveParentObject, true,
		function()
			return IUF.db.units[Option.unit].skin.override or "기본값", Option:GetSkinTypes(Option.unit)
		end,
		function(v)
			v = v ~= "기본값" and v or nil
			if v ~= IUF.db.units[Option.unit].skin.override then
				IUF.db.units[Option.unit].skin.override = v
				setCoreValue(Option.unit, "SetObjectSkin")
				LBO:Refresh()
			end
		end
	)
	menu.skinType:SetPoint("TOPRIGHT", -5, -5)
	menu.reset = LBO:CreateWidget("Button", parent, "설정 초기화", "현재 프레임의 모든 설정을 초기값으로 되돌립니다.", nil, notActiveObject, true,
		function()
			local update = nil
			for p in pairs(IUF.db.units[Option.unit].skin) do
				IUF.db.units[Option.unit].skin[p] = nil
				update = true
			end
			if update then
				setCoreValue(Option.unit, "SetObjectSkin")
				LBO:Refresh()
			end
		end
	)
	menu.reset:SetPoint("TOP", menu.active, "BOTTOM", 0, -5)
	menu.resetPos = LBO:CreateWidget("Button", parent, "위치 초기화", "현재 프레임의 위치를 초기값으로 되돌립니다.", nil, notActiveObject, true,
		function()
			if IUF.db.units[Option.unit].pos[1] then
				IUF.db.units[Option.unit].pos[1], IUF.db.units[Option.unit].pos[2] = nil
				setCoreValue(Option.unit, "SetObjectPoint")
			end
			menu.pos_x:Setup()
			menu.pos_y:Setup()
		end
	)
	menu.resetPos:SetPoint("TOP", menu.skinType, "BOTTOM", 0, -5)
	menu.pos_x = LBO:CreateWidget("EditBox", parent, "위치 X", "프레임의 가로 위치를 설정합니다.", nil, notActiveObject, true,
		function()
			return tonumber(("%.2f"):format(IUF:GetObjectPoint(Option.unit)))
		end,
		function(v)
			IUF.db.units[Option.unit].pos[1], IUF.db.units[Option.unit].pos[2] = IUF:GetObjectPoint(Option.unit)
			IUF.db.units[Option.unit].pos[1] = v
			setCoreValue(Option.unit, "SetObjectPoint")
		end
	)
	menu.pos_x:SetNumeric(true)
	menu.pos_x:SetPoint("TOP", menu.reset, "BOTTOM", 0, 10)
	menu.pos_y = LBO:CreateWidget("EditBox", parent, "위치 Y", "프레임의 세로 위치를 설정합니다.", nil, notActiveObject, true,
		function()
			return -tonumber(("%.2f"):format(select(2, IUF:GetObjectPoint(Option.unit))))
		end,
		function(v)
			IUF.db.units[Option.unit].pos[1] = IUF:GetObjectPoint(Option.unit)
			IUF.db.units[Option.unit].pos[2] = -v
			setCoreValue(Option.unit, "SetObjectPoint")
		end
	)
	menu.pos_y:SetNumeric(true)
	menu.pos_y:SetPoint("TOP", menu.resetPos, "BOTTOM", 0, 10)
	self.xPos, self.yPos = menu.pos_x, menu.pos_y
	menu.width = LBO:CreateWidget("Slider", parent, "너비", "프레임의 너비를 설정합니다.", nil, notActiveObject, true,
		function()
			return unitsdb[Option.unit].width, floor(unitsdb[Option.unit].height * 1.5), unitsdb[Option.unit].height * 10, 1, "픽셀"
		end,
		function(v)
			unitsdb[Option.unit].width = v
			setObjectValue(Option.unit, "SetWidth", v)
			setCoreValue(Option.unit, "UpdateSkinAura")
		end
	)
	menu.width:SetPoint("TOP", menu.pos_x, "BOTTOM", 0, 0)
	menu.scale = LBO:CreateWidget("Slider", parent, "크기", "프레임의 크기를 설정합니다.", nil, notActiveObject, true,
		function()
			return floor(unitsdb[Option.unit].scale * 100), 40, 160, 1, "%"
		end,
		function(v)
			unitsdb[Option.unit].scale = v / 100
			setObjectValue(Option.unit, "SetScale", v / 100)
			setCoreValue(Option.unit, "SetObjectPoint")
		end
	)
	menu.scale:SetPoint("TOP", menu.pos_y, "BOTTOM", 0, 0)
	menu.pvp = LBO:CreateWidget("CheckBox", parent, "PvP 아이콘 표시", "PvP 상태 활성화시 아이콘을 표시합니다.",
		function()
			if Option.unit then
				return not(type(unitsdb[Option.unit].pvpIcon) == "string" and unitsdb[Option.unit].pvpIcon:find("^return"))
			else
				return nil
			end
		end, notActiveObject, nil,
		function()
			return unitsdb[Option.unit].pvpIconUse
		end,
		function(v)
			unitsdb[Option.unit].pvpIconUse = v
			setObjectElementValue(Option.unit, "pvpIcon", "use", v)
			setCoreValue(Option.unit, "TriggerCallback", "PvPIcon")
		end
	)
	menu.pvp:SetPoint("TOP", menu.width, "BOTTOM", 0, 0)
	menu.elite = LBO:CreateWidget("CheckBox", parent, "정예 텍스쳐 표시", "정예일 경우 금테를 표시합니다.",
		function()
			if Option.unit then
				if IUF.db.skin == "Blizzard" then
					if type(unitsdb[Option.unit].overlay1) == "string" and unitsdb[Option.unit].overlay1:find("self:SetTexture") then
						return true
					else
						return nil
					end
				elseif type(unitsdb[Option.unit].eliteFrame) == "string" and unitsdb[Option.unit].eliteFrame:find("^return") then
					return nil
				else
					return true
				end
			else
				return true
			end
		end, notActiveObject, nil,
		function()
			return unitsdb[Option.unit].eliteFrameUse
		end,
		function(v)
			unitsdb[Option.unit].eliteFrameUse = v
			setObjectElementValue(Option.unit, "eliteFrame", "use", v)
			setCoreValue(Option.unit, "TriggerCallback", "Elite")
		end
	)
	menu.elite:SetPoint("TOP", menu.scale, "BOTTOM", 0, 0)
	menu.model3d = LBO:CreateWidget("CheckBox", parent, "3D 모델 초상화", "3D 모델 초상화를 사용합니다.",
		function()
			if Option.unit and type(unitsdb[Option.unit].portrait) == "string" and unitsdb[Option.unit].portrait:find("^return") then
				return nil
			else
				return true
			end
		end, notActiveObject, nil,
		function()
			return unitsdb[Option.unit].portrait3DModel
		end,
		function(v)
			unitsdb[Option.unit].portrait3DModel = v
			setObjectElementValue(Option.unit, "portrait", "show3dModel", v)
			setCoreValue(Option.unit, "TriggerCallback", "Portrait")
		end
	)
	menu.model3d:SetPoint("TOP", menu.pvp, "BOTTOM", 0, 0)
	local function checkFeedback()
		if (Option.unit == "player" or Option.unit == "target") and type(unitsdb[Option.unit].portrait) == "string" and unitsdb[Option.unit].portrait:find("^return") then
			return nil
		else
			return true
		end
	end
	menu.feedback = LBO:CreateWidget("CheckBox", parent, "전투 피드백 텍스트 표시", "전투 피드백 텍스트(데미지, 힐)를 표시합니다.", checkFeedback, notActiveObject, nil,
		function()
			return unitsdb[Option.unit].combatFeedback
		end,
		function(v)
			unitsdb[Option.unit].combatFeedback = v
			IUF:RegsiterCombatFeedback()
			LBO:Refresh()
		end
	)
	menu.feedback:SetPoint("TOP", menu.model3d, "BOTTOM", 0, 0)
	menu.feedbackFontSize = LBO:CreateWidget("Slider", parent, "전투 피드백 글꼴 크기", "전투 피드백 텍스트의 글꼴 크기를 설정합니다.", checkFeedback,
		function()
			if notActiveObject() then
				return true
			elseif unitsdb[Option.unit].combatFeedback then
				return nil
			else
				return true
			end
		end, nil,
		function()
			return unitsdb[Option.unit].combatFeedbackFontSize, 7, 34, 1, "포인트"
		end,
		function(v)
			unitsdb[Option.unit].combatFeedbackFontSize = v
			IUF:RegsiterCombatFeedback()
		end
	)
	menu.feedbackFontSize:SetPoint("TOP", menu.elite, "BOTTOM", 0, -44)
	menu.partyOffset = LBO:CreateWidget("Slider", parent, "파티 프레임 간격", "파티 프레임 사이의 간격을 설정합니다.",
		function() return Option.unit ~= "party" end, notActiveObject, true,
		function() return unitsdb[Option.unit].partyOffset, 0, 200, 1, "픽셀" end,
		function(v)
			unitsdb[Option.unit].partyOffset = v
			setCoreValue(Option.unit, "SetObjectPoint")
		end
	)
	menu.partyOffset:SetPoint("TOP", menu.elite, "BOTTOM", 0, 0)
	menu.hideInRaid = LBO:CreateWidget("CheckBox", parent, "공격대 참여시 숨김", "공격대 참여시 파티 프레임을 숨겨줍니다.",
		function() return Option.unit ~= "party" end, notActiveObject, true,
		function() return IUF.db.hideInRaid end,
		function(v)
			IUF.db.hideInRaid = v
			setCoreValue(Option.unit, "SetActiveObject")
		end
	)
	menu.hideInRaid:SetPoint("TOP", menu.partyOffset, "BOTTOM", 0, 0)
	menu.bossOffset = LBO:CreateWidget("Slider", parent, "보스 프레임 간격", "보스 프레임 사이의 간격을 설정합니다.",
		function() return Option.unit ~= "boss" end, notActiveObject, true,
		function() return unitsdb[Option.unit].bossOffset, 0, 200, 1, "픽셀" end,
		function(v)
			unitsdb[Option.unit].bossOffset = v
			setCoreValue(Option.unit, "SetObjectPoint")
		end
	)
	menu.bossOffset:SetPoint("TOP", menu.elite, "BOTTOM", 0, 0)
end

function Option:CreateUnitHealthMenu(menu, parent)
	menu.texture = LBO:CreateWidget("Media", parent, "바 모양", "체력바 텍스쳐 모양을 설정합니다.", nil, notActiveObject, nil,
		function()
			return unitsdb[Option.unit].healthBarTexture or defaultStatusBarTexture, "StatusBar"
		end,
		function(v)
			unitsdb[Option.unit].healthBarTexture = v
			setObjectElementValue(Option.unit, "healthBar", "SetTexture", SM:Fetch("statusbar", v))
		end
	)
	menu.texture:SetPoint("TOPLEFT", 5, -5)

	menu.barAnimation = LBO:CreateWidget("CheckBox", parent, "바 애니메이션 사용", "체력바의 감소를 부드럽게 표현합니다.", nil, notActiveObject, nil,
		function()
			return IUF.db.barAnimation
		end,
		function(v)
			IUF.db.barAnimation = v
		end
	)
	menu.barAnimation:SetPoint("TOPRIGHT", -5, -12)
	menu.classColor = LBO:CreateWidget("CheckBox", parent, "직업 별 색상 사용", "체력바 색상에 직업별 색상을 사용합니다.", nil, notActiveObject, nil,
		function()
			return unitsdb[Option.unit].healthBarClassColor
		end,
		function(v)
			unitsdb[Option.unit].healthBarClassColor = v
			setObjectElementValue(Option.unit, "healthBar", "classColor", v)
			setCoreValue(Option.unit, "TriggerCallback", "HealthColor")
			LBO:Refresh()
		end
	)
	menu.classColor:SetPoint("TOP", menu.texture, "BOTTOM", 0, -10)
	menu.classColorEnemy = LBO:CreateWidget("CheckBox", parent, "상대 진영 플레이어도 직업 색상으로 표시", "상대 진영 플레이어에게도 직업별 체력바 색상을 사용합니다.", nil,
		function()
			if not notActiveObject() then
				return Option.unit and (not unitsdb[Option.unit].healthBarClassColor)
			else
				return true
			end
		end, nil,
		function()
			return IUF.db.useEnemyClassColor
		end,
		function(v)
			IUF.db.useEnemyClassColor = v
			for unit in pairs(unitsdb) do
				setCoreValue(unit, "TriggerCallback", "HealthColor")
			end
		end
	)
	menu.classColorEnemy:SetPoint("TOP", menu.classColor, "BOTTOM", 0, 15)
end

function Option:CreateUnitHealthTextMenu(menu, parent)
	menu.clearAll = LBO:CreateWidget("Button", parent, "모두 숨김", "설정된 체력 표시 방식을 모두 숨깁니다.", nil, notActiveObject, nil,
		function()
			for i = 1, 5 do
				unitsdb[Option.unit]["healthText"..i] = false
				unitsdb[Option.unit]["healthText"..i.."InCombat"] = false
				setObjectElementValue(Option.unit, "healthText"..i, "combat", nil)
				updateElementSkin(Option.unit, "healthText"..i)
			end
			setCoreValue(Option.unit, "TriggerCallback", "Health")
			LBO:Refresh()
		end
	)
	menu.clearAll:SetPoint("TOPLEFT", 5, 0)
	menu.resetAll = LBO:CreateWidget("Button", parent, "초기화", "설정된 체력 표시 방식을 초기값으로 되돌립니다.", nil, notActiveObject, nil,
		function()
			for i = 1, 5 do
				IUF.db.units[Option.unit].skin["healthText"..i] = nil
				IUF.db.units[Option.unit].skin["healthText"..i.."InCombat"] = nil
				IUF.db.units[Option.unit].skin["healthText"..i.."FontFile"] = nil
				IUF.db.units[Option.unit].skin["healthText"..i.."FontSize"] = nil
				IUF.db.units[Option.unit].skin["healthText"..i.."FontAttribute"] = nil
				IUF.db.units[Option.unit].skin["healthText"..i.."FontShadow"] = nil
				updateFontString(Option.unit, "healthText"..i)
				setObjectElementValue(Option.unit, "healthText"..i, "combat", unitsdb[Option.unit]["healthText"..i.."InCombat"])
				updateElementSkin(Option.unit, "healthText"..i)
			end
			setCoreValue(Option.unit, "TriggerCallback", "Health")
			LBO:Refresh()
		end
	)
	menu.resetAll:SetPoint("TOPRIGHT", -5, 0)
	local function getTextType(id)
		if unitsdb[Option.unit]["healthText"..id] and barTextTypes[unitsdb[Option.unit]["healthText"..id] + 1] then
			return unitsdb[Option.unit]["healthText"..id] + 1, barTextTypes
		else
			return 1, barTextTypes
		end
	end
	local function setTextType(v, id, menu)
		v = v - 1
		if IUF:HasStatusBarDisplay(v) then
			unitsdb[Option.unit]["healthText"..id] = v
		else
			unitsdb[Option.unit]["healthText"..id] = false
		end
		updateElementSkin(Option.unit, "healthText"..id)
		setCoreValue(Option.unit, "TriggerCallback", "Health")
		LBO:Refresh()
	end
	local function getTextCombat(id)
		return unitsdb[Option.unit]["healthText"..id.."InCombat"]
	end
	local function setTextCombat(v, id)
		unitsdb[Option.unit]["healthText"..id.."InCombat"] = v
		setObjectElementValue(Option.unit, "healthText"..id, "combat", v)
		setCoreValue(Option.unit, "TriggerCallback", "Health")
	end
	local function getTextFont(id)
		return unitsdb[Option.unit]["healthText"..id.."FontFile"], unitsdb[Option.unit]["healthText"..id.."FontSize"], unitsdb[Option.unit]["healthText"..id.."FontAttribute"], unitsdb[Option.unit]["healthText"..id.."FontShadow"]
	end
	local function setTextFont(file, size, attribute, shadow, id)
		unitsdb[Option.unit]["healthText"..id.."FontFile"] = file
		unitsdb[Option.unit]["healthText"..id.."FontSize"] = size
		unitsdb[Option.unit]["healthText"..id.."FontAttribute"] = attribute
		unitsdb[Option.unit]["healthText"..id.."FontShadow"] = shadow
		updateFontString(Option.unit, "healthText"..id)
	end
	local function disableTextFont(id)
		if notActiveObject() then
			return true
		elseif Option.unit and IUF:HasStatusBarDisplay(unitsdb[Option.unit]["healthText"..id]) then
			return false
		else
			return true
		end
	end
	for i, name in ipairs(barTextList) do
		menu["text"..i] = LBO:CreateWidget("Heading", parent, "체력바 "..name, nil, nil, notActiveObject)
		menu["text"..i]:SetScale(1.1)
		menu["text"..i]:SetPoint("TOPLEFT", menu["text"..(i - 1)], "BOTTOMLEFT", 0, -80)
		menu["text"..i]:SetPoint("TOPRIGHT", menu["text"..(i - 1)], "BOTTOMRIGHT", 0, -80)
		menu["textType"..i] = LBO:CreateWidget("DropDown", parent, "표시 방식", "체력바 "..name.." 글자의 표시 방식을 설정합니다.", nil, notActiveObject, nil, getTextType, setTextType, i)
		menu["textType"..i]:SetPoint("TOPLEFT", menu["text"..i], "BOTTOMLEFT", 0, 18)
		menu["textInCombat"..i] = LBO:CreateWidget("CheckBox", parent, "전투 중에만 표시", "체력바 "..name.." 글자를 전투 중에만 표시합니다.", nil, disableTextFont, nil, getTextCombat, setTextCombat, i)
		menu["textInCombat"..i]:SetPoint("TOPRIGHT", menu["text"..i], "BOTTOMRIGHT", 0, 18)
		menu["textFont"..i] = LBO:CreateWidget("Font", parent, "글꼴", "체력바 "..name.."의 글꼴을 설정합니다.", nil, disableTextFont, nil, getTextFont, setTextFont, i)
		menu["textFont"..i]:SetPoint("TOP", menu["textType"..i], "BOTTOM", 0, -5)
	end
	menu.text1:ClearAllPoints()
	menu.text1:SetPoint("TOPLEFT", 5, -30)
	menu.text1:SetPoint("TOPRIGHT", -5, -30)
end

function Option:CreateUnitManaMenu(menu, parent)
	menu.texture = LBO:CreateWidget("Media", parent, "바 모양", "마나바 텍스쳐 모양을 설정합니다.", nil, notActiveObject, nil,
		function()
			return unitsdb[Option.unit].powerBarTexture or defaultStatusBarTexture, "StatusBar"
		end,
		function(v)
			unitsdb[Option.unit].powerBarTexture = v
			setObjectElementValue(Option.unit, "powerBar", "SetTexture", SM:Fetch("statusbar", v))
		end
	)
	menu.texture:SetPoint("TOPLEFT", 5, -5)
	menu.barAnimation = LBO:CreateWidget("CheckBox", parent, "바 애니메이션 사용", "마나바의 감소를 부드럽게 표현합니다.", nil, notActiveObject, nil,
		function() return IUF.db.barAnimation end,
		function(v) IUF.db.barAnimation = v end
	)
	menu.barAnimation:SetPoint("TOPRIGHT", -5, -12)
	menu.barHeight = LBO:CreateWidget("Slider", parent, "마나바 비율", "마나바 비율을 설정합니다.",
		function()
			if Option.unit then
				return type(unitsdb[Option.unit].powerBarHeight) ~= "number"
			end
		end, notActiveObject, nil,
		function() return (unitsdb[Option.unit].powerBarHeight or 0.5) * 100, 0, 100, 1, "%" end,
		function(v)
			unitsdb[Option.unit].powerBarHeight = v / 100
			updateElementSkin(Option.unit, "healthBar")
			updateElementSkin(Option.unit, "powerBar")
		end
	)
	menu.barHeight:SetPoint("TOP", menu.texture, "BOTTOM", 0, -10)
end

function Option:CreateUnitManaTextMenu(menu, parent)
	menu.clearAll = LBO:CreateWidget("Button", parent, "모두 숨김", "설정된 마나 표시 방식을 모두 숨깁니다.", nil, notActiveObject, nil,
		function()
			for i = 1, 5 do
				unitsdb[Option.unit]["powerText"..i] = false
				unitsdb[Option.unit]["powerText"..i.."InCombat"] = false
				setObjectElementValue(Option.unit, "powerText"..i, "combat", nil)
				updateElementSkin(Option.unit, "powerText"..i)
			end
			setCoreValue(Option.unit, "TriggerCallback", "Power")
			LBO:Refresh()
		end
	)
	menu.clearAll:SetPoint("TOPLEFT", 5, 0)
	menu.resetAll = LBO:CreateWidget("Button", parent, "초기화", "설정된 마나 표시 방식을 초기값으로 되돌립니다.", nil, notActiveObject, nil,
		function()
			for i = 1, 5 do
				IUF.db.units[Option.unit].skin["powerText"..i] = nil
				IUF.db.units[Option.unit].skin["powerText"..i.."InCombat"] = nil
				IUF.db.units[Option.unit].skin["powerText"..i.."FontFile"] = nil
				IUF.db.units[Option.unit].skin["powerText"..i.."FontSize"] = nil
				IUF.db.units[Option.unit].skin["powerText"..i.."FontAttribute"] = nil
				IUF.db.units[Option.unit].skin["powerText"..i.."FontShadow"] = nil
				updateFontString(Option.unit, "powerText"..i)
				setObjectElementValue(Option.unit, "powerText"..i, "combat", unitsdb[Option.unit]["powerText"..i.."InCombat"])
				updateElementSkin(Option.unit, "powerText"..i)
			end
			setCoreValue(Option.unit, "TriggerCallback", "Power")
			LBO:Refresh()
		end
	)
	menu.resetAll:SetPoint("TOPRIGHT", -5, 0)
	local function getTextType(id)
		if unitsdb[Option.unit]["powerText"..id] and barTextTypes[unitsdb[Option.unit]["powerText"..id] + 1] then
			return unitsdb[Option.unit]["powerText"..id] + 1, barTextTypes
		else
			return 1, barTextTypes
		end
	end
	local function setTextType(v, id, menu)
		v = v - 1
		if IUF:HasStatusBarDisplay(v) then
			unitsdb[Option.unit]["powerText"..id] = v
		else
			unitsdb[Option.unit]["powerText"..id] = false
		end
		updateElementSkin(Option.unit, "powerText"..id)
		setCoreValue(Option.unit, "TriggerCallback", "Power")
		LBO:Refresh()
	end
	local function getTextCombat(id)
		return unitsdb[Option.unit]["powerText"..id.."InCombat"]
	end
	local function setTextCombat(v, id)
		unitsdb[Option.unit]["powerText"..id.."InCombat"] = v
		setObjectElementValue(Option.unit, "powerText"..id, "combat", v)
		setCoreValue(Option.unit, "TriggerCallback", "Power")
	end
	local function getTextFont(id)
		return unitsdb[Option.unit]["powerText"..id.."FontFile"], unitsdb[Option.unit]["powerText"..id.."FontSize"], unitsdb[Option.unit]["powerText"..id.."FontAttribute"], unitsdb[Option.unit]["powerText"..id.."FontShadow"]
	end
	local function setTextFont(file, size, attribute, shadow, id)
		unitsdb[Option.unit]["powerText"..id.."FontFile"] = file
		unitsdb[Option.unit]["powerText"..id.."FontSize"] = size
		unitsdb[Option.unit]["powerText"..id.."FontAttribute"] = attribute
		unitsdb[Option.unit]["powerText"..id.."FontShadow"] = shadow
		updateFontString(Option.unit, "powerText"..id)
	end
	local function disableTextFont(id)
		if notActiveObject() then
			return true
		elseif Option.unit and IUF:HasStatusBarDisplay(unitsdb[Option.unit]["powerText"..id]) then
			return false
		else
			return true
		end
	end
	for i, name in ipairs(barTextList) do
		menu["text"..i] = LBO:CreateWidget("Heading", parent, "마나바 "..name, nil, nil, notActiveObject)
		menu["text"..i]:SetScale(1.1)
		menu["text"..i]:SetPoint("TOPLEFT", menu["text"..(i - 1)], "BOTTOMLEFT", 0, -80)
		menu["text"..i]:SetPoint("TOPRIGHT", menu["text"..(i - 1)], "BOTTOMRIGHT", 0, -80)
		menu["textType"..i] = LBO:CreateWidget("DropDown", parent, "표시 방식", "마나바 "..name.." 글자의 표시 방식을 설정합니다.", nil, notActiveObject, nil, getTextType, setTextType, i)
		menu["textType"..i]:SetPoint("TOPLEFT", menu["text"..i], "BOTTOMLEFT", 0, 18)
		menu["textInCombat"..i] = LBO:CreateWidget("CheckBox", parent, "전투 중에만 표시", "마나바 "..name.." 글자를 전투 중에만 표시합니다.", nil, disableTextFont, nil, getTextCombat, setTextCombat, i)
		menu["textInCombat"..i]:SetPoint("TOPRIGHT", menu["text"..i], "BOTTOMRIGHT", 0, 18)
		menu["textFont"..i] = LBO:CreateWidget("Font", parent, "글꼴", "마나바 "..name.."의 글꼴을 설정합니다.", nil, disableTextFont, nil, getTextFont, setTextFont, i)
		menu["textFont"..i]:SetPoint("TOP", menu["textType"..i], "BOTTOM", 0, -5)
	end
	menu.text1:ClearAllPoints()
	menu.text1:SetPoint("TOPLEFT", 5, -30)
	menu.text1:SetPoint("TOPRIGHT", -5, -30)
end

function Option:CreateUnitCastingBarMenu(menu, parent)
	menu.use = LBO:CreateWidget("CheckBox", parent, "시전바 보기", "프레임에 시전바 표시 여부를 설정합니다.", nil, notActiveObject, nil,
		function()
			return unitsdb[Option.unit].castingBarUse
		end,
		function(v)
			unitsdb[Option.unit].castingBarUse = v
			setObjectElementValue(Option.unit, "castingBar", "use", v)
			if v then
				setObjectHandlerUpdate(Option.unit, "UNIT_SPELLCAST_START")
			end
			setCoreValue(Option.unit, "TriggerCallback", "CastingBar")
			LBO:Refresh()
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, -5)
	menu.hiddenBlizzard = LBO:CreateWidget("CheckBox", parent, "와우 기본 시전바 숨기기", "와우 기본 시전바를 보이거나 숨깁니다.",
		function()
			return Option.unit ~= "player"
		end, nil, nil,
		function()
			return unitsdb[Option.unit].hiddenBlizzardCastingBar
		end,
		function(v)
			unitsdb[Option.unit].hiddenBlizzardCastingBar = v
			if v then
				CastingBarFrame.showCastbar = nil
				PetCastingBarFrame.showCastbar = nil
			else
				CastingBarFrame.showCastbar = true
				PetCastingBarFrame.showCastbar = true
			end
			CastingBarFrame_UpdateIsShown(CastingBarFrame)
			CastingBarFrame_UpdateIsShown(PetCastingBarFrame)
		end
	)
	menu.hiddenBlizzard:SetPoint("TOPRIGHT", -5, -5)
	local function isnotCastingBarUse()
		if notActiveObject() then
			return true
		else
			return not unitsdb[Option.unit].castingBarUse
		end
	end
	menu.texture = LBO:CreateWidget("Media", parent, "바 모양", "시전바의 모양을 설정합니다.", nil, isnotCastingBarUse, nil,
		function()
			return unitsdb[Option.unit].castingBarTexture or defaultStatusBarTexture, "statusbar"
		end,
		function(v)
			unitsdb[Option.unit].castingBarTexture = v
			updateElementSkin(Option.unit, "castingBar")
			setCoreValue(Option.unit, "TriggerCallback", "CastingBar")
		end
	)
	menu.texture:SetPoint("TOP", menu.use, "BOTTOM", 0, 5)
	local castingBarPosLink = { "TOPAURA", "TOP", "BOTTOM", "BOTTOMAURA" }
	local castingBarPos = { "제일 상단", "프레임 상단", "프레임 하단", "제일 하단" }
	local castingBarPosID = {}
	for p, v in pairs(castingBarPosLink) do
		castingBarPosID[v] = p
	end
	menu.pos = LBO:CreateWidget("DropDown", parent, "위치", "시전바의 위치를 설정합니다.", nil, isnotCastingBarUse, nil,
		function()
			return castingBarPosID[unitsdb[Option.unit].castingBarPos or "BOTTOM"] or 2, castingBarPos
		end,
		function(v)
			unitsdb[Option.unit].castingBarPos = castingBarPosLink[v]
			updateElementSkin(Option.unit, "castingBar")
			setCoreValue(Option.unit, "TriggerCallback", "CastingBar")
		end
	)
	menu.pos:SetPoint("TOP", menu.hiddenBlizzard, "BOTTOM", 0, 5)
	menu.height = LBO:CreateWidget("Slider", parent, "높이", "시전바의 높이를 설정합니다.", nil, isnotCastingBarUse, nil,
		function()
			return unitsdb[Option.unit].castingBarHeight, 1, 30, 1, "픽셀"
		end,
		function(v)
			unitsdb[Option.unit].castingBarHeight = v
			updateElementSkin(Option.unit, "castingBar")
			setCoreValue(Option.unit, "TriggerCallback", "CastingBar")
		end
	)
	menu.height:SetPoint("TOP", menu.texture, "BOTTOM", 0, -5)
	menu.textUse = LBO:CreateWidget("CheckBox", parent, "주문 이름 표시", "시전중인 주문 이름을 표시합니다.", nil, isnotCastingBarUse, nil,
		function()
			return unitsdb[Option.unit].castingBarTextUse
		end,
		function(v)
			unitsdb[Option.unit].castingBarTextUse = v
			updateElementSkin(Option.unit, "castingBar")
			setCoreValue(Option.unit, "TriggerCallback", "CastingBar")
			LBO:Refresh()
		end
	)
	menu.textUse:SetPoint("TOP", menu.height, "BOTTOM", 0, 0)
	menu.textFont = LBO:CreateWidget("Font", parent, "주문 이름 글꼴", "시전 중인 주문 이름의 글꼴을 설정합니다.", nil,
		function()
			if not isnotCastingBarUse() then
				return not unitsdb[Option.unit].castingBarTextUse
			else
				return true
			end
		end, nil,
		function()
			return unitsdb[Option.unit].castingBarTextFontFile, unitsdb[Option.unit].castingBarTextFontSize, unitsdb[Option.unit].castingBarTextFontAttribute, unitsdb[Option.unit].castingBarTextFontShadow
		end,
		function(file, size, attribute, shadow)
			unitsdb[Option.unit].castingBarTextFontFile = file
			unitsdb[Option.unit].castingBarTextFontSize = size
			unitsdb[Option.unit].castingBarTextFontAttribute = attribute
			unitsdb[Option.unit].castingBarTextFontShadow = shadow
			updateFontString(Option.unit, "castingBarText")
			updateElementSkin(Option.unit, "castingBar")
			setCoreValue(Option.unit, "TriggerCallback", "CastingBar")
		end
	)
	menu.textFont:SetPoint("TOP", menu.textUse, "BOTTOM", 0, 5)
	menu.timerUse = LBO:CreateWidget("CheckBox", parent, "남은 시간 표시", "시전 중인 주문의 남은 시간을 표시합니다.", nil, isnotCastingBarUse, nil,
		function()
			return unitsdb[Option.unit].castingBarTimeUse
		end,
		function(v)
			unitsdb[Option.unit].castingBarTimeUse = v
			updateElementSkin(Option.unit, "castingBar")
			setCoreValue(Option.unit, "TriggerCallback", "CastingBar")
			LBO:Refresh()
		end
	)
	menu.timerUse:SetPoint("TOPLEFT", menu.pos, "BOTTOMLEFT", 0, -49)
	menu.timerFont = LBO:CreateWidget("Font", parent, "남은 시간 글꼴", "시전 중인 주문의 남은 시간의 글꼴을 설정합니다.", nil,
		function()
			if not isnotCastingBarUse() then
				return not unitsdb[Option.unit].castingBarTimeUse
			else
				return true
			end
		end, nil,
		function()
			return unitsdb[Option.unit].castingBarTimeFontFile, unitsdb[Option.unit].castingBarTimeFontSize, unitsdb[Option.unit].castingBarTimeFontAttribute, unitsdb[Option.unit].castingBarTimeFontShadow
		end,
		function(file, size, attribute, shadow)
			unitsdb[Option.unit].castingBarTimeFontFile = file
			unitsdb[Option.unit].castingBarTimeFontSize = size
			unitsdb[Option.unit].castingBarTimeFontAttribute = attribute
			unitsdb[Option.unit].castingBarTimeFontShadow = shadow
			updateFontString(Option.unit, "castingBarTime")
			updateElementSkin(Option.unit, "castingBar")
			setCoreValue(Option.unit, "TriggerCallback", "CastingBar")
		end
	)
	menu.timerFont:SetPoint("TOP", menu.timerUse, "BOTTOM", 0, 5)
end

function Option:CreateUnitBuffMenu(menu, parent)
	menu.use = LBO:CreateWidget("CheckBox", parent, "버프 보기", "버프의 표시 여부를 설정합니다.", nil, notActiveObject, nil,
		function() return unitsdb[Option.unit].buffUse end,
		function(v)
			unitsdb[Option.unit].buffUse = v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
			LBO:Refresh()
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, -5)
	local function isnotBuffUse()
		if notActiveObject() then
			return true
		else
			return not unitsdb[Option.unit].buffUse
		end
	end

	menu.important = LBO:CreateWidget("CheckBox", parent, "중요 버프만 보기", "중요 버프만 표기", nil, isnotBuffUse, nil,
		function() return not unitsdb[Option.unit].buffImportant end,
		function(v)
			unitsdb[Option.unit].buffImportant = not v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
		end
	)
	menu.important:SetPoint("TOPLEFT", 85, -5)

	menu.num = LBO:CreateWidget("Slider", parent, "표시할 버프 수", "표시할 버프 수를 설정합니다.", nil, isnotBuffUse, nil,
		function() return unitsdb[Option.unit].buffNum, 0, 40, 1, "개" end,
		function(v)
			unitsdb[Option.unit].buffNum = v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
		end
	)
	menu.num:SetPoint("TOPRIGHT", -5, -5)
	menu.pos = LBO:CreateWidget("DropDown", parent, "버프 위치", "버프가 표시될 위치를 설정합니다.", nil, isnotBuffUse, nil,
		function()
			return auraPositions[unitsdb[Option.unit].buffPos or "TOP"] or 1, auraPositionList
		end,
		function(v)
			unitsdb[Option.unit].buffPos = auraPositions[v] or "TOP"
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
		end
	)
	menu.pos:SetPoint("TOP", menu.use, "BOTTOM", 0, -10)
	menu.filter = LBO:CreateWidget("DropDown", parent, "버프 필터링", "버프 필터링에 대한 설정을 합니다.", nil, isnotBuffUse, nil,
		function() return auraFiltering[unitsdb[Option.unit].buffFilter or ""] or 1, buffFilteringList end,
		function(v)
			unitsdb[Option.unit].buffFilter = auraFiltering[v or 1] or ""
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
		end
	)
	menu.filter:SetPoint("TOP", menu.num, "BOTTOM", 0, -10)
	menu.small = LBO:CreateWidget("Slider", parent, "버프 크기", "내가 시전하지 않은 버프의 크기를 설정합니다.", nil, isnotBuffUse, nil,
		function()
			return unitsdb[Option.unit].buffSmallSize, 10, 40, 1, "픽셀"
		end,
		function(v)
			unitsdb[Option.unit].buffSmallSize = v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
		end
	)
	menu.small:SetPoint("TOP", menu.pos, "BOTTOM", 0, -10)
	menu.countSize = LBO:CreateWidget("Slider", parent, "중첩 횟수 글꼴 크기", "중첩 횟수의 글꼴 크기를 설정합니다.", nil, isnotBuffUse, nil,
		function()
			return unitsdb[Option.unit].buffCountTextFontSize, 7, 37, 1, "포인트"
		end,
		function(v)
			unitsdb[Option.unit].buffCountTextFontSize = v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
		end
	)
	menu.countSize:SetPoint("TOP", menu.filter, "BOTTOM", 0, -10)
	menu.smallTexture = LBO:CreateWidget("CheckBox", parent, "쿨다운 텍스쳐 보기", "내가 시전하지 않은 버프의 시계 모양 텍스터를 보이거나 숨깁니다.", nil, isnotBuffUse, nil,
		function() return not unitsdb[Option.unit].buffHiddenSmallCooldownTexture end,
		function(v)
			unitsdb[Option.unit].buffHiddenSmallCooldownTexture = not v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
		end
	)
	menu.smallTexture:SetPoint("TOP", menu.small, "BOTTOM", 0, 5)
	menu.line = LBO:CreateWidget("CheckBox", parent, "자동 줄바꿈", "프레임의 크기에 따라 자동으로 줄 바꿈을 합니다.", nil, isnotBuffUse, nil,
		function() return not unitsdb[Option.unit].buffSkipLine end,
		function(v)
			unitsdb[Option.unit].buffSkipLine = not v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
		end
	)
	menu.line:SetPoint("TOP", menu.countSize, "BOTTOM", 0, 5)
	local function isnotMyBuff()
		return Option.unit ~= "player" and Option.unit ~= "target" and Option.unit ~= "focus" and Option.unit ~= "party" and Option.unit ~= "boss"
	end
	menu.mybuff = LBO:CreateWidget("Heading", parent, "내가 시전한 버프", nil, isnotMyBuff, isnotBuffUse)
	menu.mybuff:SetScale(1.2)
	menu.mybuff:SetPoint("TOPLEFT", menu.small, "BOTTOMLEFT", 0, -22)
	menu.mybuff:SetPoint("TOPRIGHT", menu.countSize, "BOTTOMRIGHT", 0, -22)
	menu.big = LBO:CreateWidget("Slider", parent, "내가 시전한 버프 확대", "내가 시전한 버프를 더 크게 표시합니다.", isnotMyBuff, isnotBuffUse, nil,
		function()
			return unitsdb[Option.unit].buffBigScale * 100, 100, 200, 1, "%"
		end,
		function(v)
			unitsdb[Option.unit].buffBigScale = v / 100
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
		end
	)
	menu.big:SetPoint("TOPLEFT", menu.mybuff, "BOTTOMLEFT", 0, 10)
	menu.bigTexture = LBO:CreateWidget("CheckBox", parent, "쿨다운 텍스쳐 보기", "내가 시전한 버프의 시계 모양 텍스터를 보이거나 숨깁니다.", isnotMyBuff, isnotBuffUse, nil,
		function() return not unitsdb[Option.unit].buffHiddenBigCooldownTexture end,
		function(v)
			unitsdb[Option.unit].buffHiddenBigCooldownTexture = not v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
		end
	)
	menu.bigTexture:SetPoint("TOPRIGHT", menu.mybuff, "BOTTOMRIGHT", 0, 10)
	menu.cdUse = LBO:CreateWidget("CheckBox", parent, "남은 시간 보기", "내가 시전한 버프의 남은 시간을 표시합니다. (10분 미만의 시간만 표시됩니다)", isnotMyBuff, isnotBuffUse, nil,
		function() return unitsdb[Option.unit].buffCooldownTextUse end,
		function(v)
			unitsdb[Option.unit].buffCooldownTextUse = v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
			LBO:Refresh()
		end
	)
	menu.cdUse:SetPoint("TOP", menu.big, "BOTTOM", 0, -5)
	menu.cd = LBO:CreateWidget("Font", parent, "남은 시간 글꼴", "내가 시전한 버프의 남은 시간 글꼴을 설정합니다.", isnotMyBuff,
		function()
			if not isnotMyBuff() then
				return not unitsdb[Option.unit].buffCooldownTextUse
			else
				return true
			end
		end, nil,
		function()
			return unitsdb[Option.unit].buffCooldownTextFontFile, unitsdb[Option.unit].buffCooldownTextFontSize, unitsdb[Option.unit].buffCooldownTextFontAttribute, unitsdb[Option.unit].buffCooldownTextFontShadow
		end,
		function(file, size, attribute, shadow)
			unitsdb[Option.unit].buffCooldownTextFontFile = file
			unitsdb[Option.unit].buffCooldownTextFontSize = size
			unitsdb[Option.unit].buffCooldownTextFontAttribute = attribute
			unitsdb[Option.unit].buffCooldownTextFontShadow = shadow
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
		end
	)
	menu.cd:SetPoint("TOPRIGHT", menu.bigTexture, "BOTTOMRIGHT", 0, 2)
end

function Option:CreateUnitDebuffMenu(menu, parent)
	menu.use = LBO:CreateWidget("CheckBox", parent, "디버프 보기", "디버프의 표시 여부를 설정합니다.", nil, notActiveObject, nil,
		function() return unitsdb[Option.unit].debuffUse end,
		function(v)
			unitsdb[Option.unit].debuffUse = v
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
			LBO:Refresh()
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, -5)
	local function isnotDebuffUse()
		if notActiveObject() then
			return true
		else
			return not unitsdb[Option.unit].debuffUse
		end
	end
	menu.important = LBO:CreateWidget("CheckBox", parent, "중요 디버프만 보기", "중요 디버프만 표기", nil, isnotDebuffUse, nil,
		function() return not unitsdb[Option.unit].debuffImportant end,
		function(v)
			unitsdb[Option.unit].debuffImportant = not v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
		end
	)
	menu.important:SetPoint("TOPLEFT", 85, -5)
	menu.num = LBO:CreateWidget("Slider", parent, "표시할 디버프 수", "표시할 디버프 수를 설정합니다.", nil, isnotDebuffUse, nil,
		function() return unitsdb[Option.unit].debuffNum, 0, 40, 1, "개" end,
		function(v)
			unitsdb[Option.unit].debuffNum = v
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
		end
	)
	menu.num:SetPoint("TOPRIGHT", -5, -5)
	menu.pos = LBO:CreateWidget("DropDown", parent, "디버프 위치", "디버프가 표시될 위치를 설정합니다.", nil, isnotDebuffUse, nil,
		function()
			return auraPositions[unitsdb[Option.unit].debuffPos or "TOP"] or 1, auraPositionList
		end,
		function(v)
			unitsdb[Option.unit].debuffPos = auraPositions[v] or "TOP"
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
		end
	)
	menu.pos:SetPoint("TOP", menu.use, "BOTTOM", 0, -10)
	menu.filter = LBO:CreateWidget("DropDown", parent, "디버프 필터링", "디버프 필터링에 대한 설정을 합니다.", nil, isnotDebuffUse, nil,
		function() return auraFiltering[unitsdb[Option.unit].debuffFilter or ""] or 1, debuffFilteringList end,
		function(v)
			unitsdb[Option.unit].debuffFilter = auraFiltering[v or 1] or ""
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
		end
	)
	menu.filter:SetPoint("TOP", menu.num, "BOTTOM", 0, -10)
	menu.small = LBO:CreateWidget("Slider", parent, "디버프 크기", "내가 시전하지 않은 디버프의 크기를 설정합니다.", nil, isnotDebuffUse, nil,
		function()
			return unitsdb[Option.unit].debuffSmallSize, 10, 40, 1, "픽셀"
		end,
		function(v)
			unitsdb[Option.unit].debuffSmallSize = v
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
		end
	)
	menu.small:SetPoint("TOP", menu.pos, "BOTTOM", 0, -10)
	menu.countSize = LBO:CreateWidget("Slider", parent, "중첩 횟수 글꼴 크기", "중첩 횟수의 글꼴 크기를 설정합니다.", nil, isnotBuffUse, nil,
		function()
			return unitsdb[Option.unit].debuffCountTextFontSize, 7, 37, 1, "포인트"
		end,
		function(v)
			unitsdb[Option.unit].debuffCountTextFontSize = v
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
		end
	)
	menu.countSize:SetPoint("TOP", menu.filter, "BOTTOM", 0, -10)
	menu.smallTexture = LBO:CreateWidget("CheckBox", parent, "쿨다운 텍스쳐 보기", "내가 시전하지 않은 디버프의 시계 모양 텍스터를 보이거나 숨깁니다.", nil, isnotDebuffUse, nil,
		function() return not unitsdb[Option.unit].debuffHiddenSmallCooldownTexture end,
		function(v)
			unitsdb[Option.unit].debuffHiddenSmallCooldownTexture = not v
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
		end
	)
	menu.smallTexture:SetPoint("TOP", menu.small, "BOTTOM", 0, 5)
	menu.line = LBO:CreateWidget("CheckBox", parent, "자동 줄바꿈", "프레임의 크기에 따라 자동으로 줄 바꿈을 합니다.", nil, isnotDebuffUse, nil,
		function() return not unitsdb[Option.unit].debuffSkipLine end,
		function(v)
			unitsdb[Option.unit].debuffSkipLine = not v
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
		end
	)
	menu.line:SetPoint("TOP", menu.countSize, "BOTTOM", 0, 5)
	local function isnotMyDebuff()
		if notActiveObject() then
			return true
		else
			return Option.unit ~= "player" and Option.unit ~= "target" and Option.unit ~= "focus" and Option.unit ~= "party" and Option.unit ~= "boss"
		end
	end
	menu.mydebuff = LBO:CreateWidget("Heading", parent, "내가 시전한/받은 디버프", nil, isnotMyDebuff, isnotDebuffUse)
	menu.mydebuff:SetScale(1.2)
	menu.mydebuff:SetPoint("TOPLEFT", menu.small, "BOTTOMLEFT", 0, -22)
	menu.mydebuff:SetPoint("TOPRIGHT", menu.countSize, "BOTTOMRIGHT", 0, -22)
	menu.big = LBO:CreateWidget("Slider", parent, "내가 시전한/받은 디버프 확대", "내가 시전한/받은 디버프를 더 크게 표시합니다.", isnotMyDebuff, isnotDebuffUse, nil,
		function()
			return unitsdb[Option.unit].debuffBigScale * 100, 100, 200, 1, "%"
		end,
		function(v)
			unitsdb[Option.unit].debuffBigScale = v / 100
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
		end
	)
	menu.big:SetPoint("TOPLEFT", menu.mydebuff, "BOTTOMLEFT", 0, 10)
	menu.bigTexture = LBO:CreateWidget("CheckBox", parent, "쿨다운 텍스쳐 보기", "내가 시전한/받은 디버프의 시계 모양 텍스터를 보이거나 숨깁니다.", isnotMyDebuff, isnotDebuffUse, nil,
		function() return not unitsdb[Option.unit].debuffHiddenBigCooldownTexture end,
		function(v)
			unitsdb[Option.unit].debuffHiddenBigCooldownTexture = not v
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
		end
	)
	menu.bigTexture:SetPoint("TOPRIGHT", menu.mydebuff, "BOTTOMRIGHT", 0, 10)
	menu.cdUse = LBO:CreateWidget("CheckBox", parent, "남은 시간 보기", "내가 시전한/받은 디버프의 남은 시간을 표시합니다. (10분 미만의 시간만 표시됩니다)", isnotMyDebuff, isnotDebuffUse, nil,
		function() return unitsdb[Option.unit].debuffCooldownTextUse end,
		function(v)
			unitsdb[Option.unit].debuffCooldownTextUse = v
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
			LBO:Refresh()
		end
	)
	menu.cdUse:SetPoint("TOP", menu.big, "BOTTOM", 0, -5)
	menu.cd = LBO:CreateWidget("Font", parent, "남은 시간 글꼴", "내가 시전한/받은 디버프의 남은 시간 글꼴을 설정합니다.", isnotMyDebuff,
		function()
			if not isnotMyDebuff() then
				return not unitsdb[Option.unit].debuffCooldownTextUse
			else
				return true
			end
		end, nil,
		function()
			return unitsdb[Option.unit].debuffCooldownTextFontFile, unitsdb[Option.unit].debuffCooldownTextFontSize, unitsdb[Option.unit].debuffCooldownTextFontAttribute, unitsdb[Option.unit].debuffCooldownTextFontShadow
		end,
		function(file, size, attribute, shadow)
			unitsdb[Option.unit].debuffCooldownTextFontFile = file
			unitsdb[Option.unit].debuffCooldownTextFontSize = size
			unitsdb[Option.unit].debuffCooldownTextFontAttribute = attribute
			unitsdb[Option.unit].debuffCooldownTextFontShadow = shadow
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
		end
	)
	menu.cd:SetPoint("TOPRIGHT", menu.bigTexture, "BOTTOMRIGHT", 0, 2)
end

function Option:CreateUnitTextMenu(menu, parent)
	local function hideTextOption(key)
		if Option.unit and type(unitsdb[Option.unit][key]) == "string" and unitsdb[Option.unit][key]:find("^return ") then
			return nil
		else
			return true
		end
	end
	local function getFont(key)
		return unitsdb[Option.unit][key.."FontFile"], unitsdb[Option.unit][key.."FontSize"], unitsdb[Option.unit][key.."FontAttribute"], unitsdb[Option.unit][key.."FontShadow"]
	end
	local function setFont(file, size, attribute, shadow, key)
		unitsdb[Option.unit][key.."FontFile"] = file
		unitsdb[Option.unit][key.."FontSize"] = size
		unitsdb[Option.unit][key.."FontAttribute"] = attribute
		unitsdb[Option.unit][key.."FontShadow"] = shadow
		updateFontString(Option.unit, key)
	end
	menu.name = LBO:CreateWidget("Font", parent, "이름 글꼴", "이름 글자의 글꼴을 설정합니다.", hideTextOption, notActiveObject, nil, getFont, setFont, "nameText")
	menu.name:SetPoint("TOPLEFT", 5, -5)
	menu.classColor = LBO:CreateWidget("CheckBox", parent, "직업별 이름 글자 색상", "직업별 이름 글자 색상을 사용합니다.", hideTextOption, notActiveObject, nil,
		function() return unitsdb[Option.unit].nameTextClassColor end,
		function(v)
			unitsdb[Option.unit].nameTextClassColor = v
			setObjectElementValue(Option.unit, "nameText", "classColor", v)
			setCoreValue(Option.unit, "TriggerCallback", "NameColor")
		end,
	"nameText")
	menu.classColor:SetPoint("TOPRIGHT", -5, -5)
	menu.level = LBO:CreateWidget("Font", parent, "레벨 글꼴", "레벨 글자의 글꼴을 설정합니다.", hideTextOption, notActiveObject, nil, getFont, setFont, "levelText")
	menu.level:SetPoint("TOP", menu.name, "BOTTOM", 0, -10)
	menu.state = LBO:CreateWidget("Font", parent, "상태 글꼴", "자리비움, 오프라인 등을 표시하는 상태 글자의 글꼴을 설정합니다.", hideTextOption, notActiveObject, nil, getFont, setFont, "stateText")
	menu.state:SetPoint("TOP", menu.classColor, "BOTTOM", 0, -10)
	menu.class = LBO:CreateWidget("Font", parent, "직업 글꼴", "직업 글자의 글꼴을 설정합니다.", hideTextOption, notActiveObject, nil, getFont, setFont, "classText")
	menu.class:SetPoint("TOP", menu.level, "BOTTOM", 0, -10)
end

function Option:CreateDispelMenu(menu, parent)
	menu.use = LBO:CreateWidget("CheckBox", parent, "해제 가능한 디버프 하이라이트 사용하기", "해제 가능한 디버프에 걸렸을 경우 프레임을 하이라이트 해줍니다.", nil, nil, nil,
		function() return IUF.db.dispel.active end,
		function(v)
			IUF.db.dispel.active = v
			for unit in pairs(IUF.db.units) do
				setCoreValue(unit, "TriggerCallback", "Dispel")
			end
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, 5)
	menu.alpha = LBO:CreateWidget("Slider", parent, "투명도", "디버프 하이라이트 투명도를 설정합니다.", nil, nil, nil,
		function() return IUF.db.dispel.alpha * 100, 0, 100, 1, "%" end,
		function(v)
			IUF.db.dispel.alpha = v / 100
			for unit in pairs(IUF.db.units) do
				setObjectElementValue(unit, "dispelFrame", "SetAlpha", IUF.db.dispel.alpha)
			end
		end
	)
	menu.alpha:SetPoint("TOP", menu.use, "BOTTOM", 0, 0)

end

local function notActivePlayerUnit()
	return not IUF.db.units.player.active
end

function Option:CreateDruidManaBarMenu(menu, parent)
	menu.use = LBO:CreateWidget("CheckBox", parent, "드루이드 마나바 사용하기", "드루이드 마나바의 사용 여부를 설정합니다.", nil, notActivePlayerUnit, nil,
		function() return IUF.db.classBar.DRUID.active end,
		function(v)
			IUF.db.classBar.DRUID.active = v
			LBO:Refresh()
			if IUF.units.player.classBar and IUF.units.player.classBar.type == "DRUID" then
				setCoreValue("player", "TriggerCallback", "DruidMana")
			end
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, -5)
	local function notActiveDruidManaBar()
		if IUF.db.units.player.active then
			return not IUF.db.classBar.DRUID.active
		else
			return true
		end
	end
	menu.height = LBO:CreateWidget("Slider", parent, "높이", "드루이드 마나바의 높이를 설정합니다.", nil, notActiveDruidManaBar, nil,
		function() return IUF.db.classBar.DRUID.height, 2, 40, 1, "픽셀" end,
		function(v)
			IUF.db.classBar.DRUID.height = v
			if IUF.units.player.classBar and IUF.units.player.classBar.type == "DRUID" and IUF.units.player.classBar:IsShown() then
				IUF.units.player.classBar:SetHeight(v)
			end
		end
	)
	menu.height:SetPoint("TOPRIGHT", -5, -5)
	menu.texture = LBO:CreateWidget("Media", parent, "바 모양", "드루이드 마나바 모양을 설정합니다.", nil, notActiveDruidManaBar, nil,
		function() return IUF.db.classBar.DRUID.texture, "statusbar" end,
		function(v)
			IUF.db.classBar.DRUID.texture = v
			if IUF.units.player.classBar and IUF.units.player.classBar.type == "DRUID" then
				IUF:ClassBarSetup(IUF.units.player)
			end
		end
	)
	menu.texture:SetPoint("TOP", menu.use, "BOTTOM", 0, -5)
	menu.pos = LBO:CreateWidget("DropDown", parent, "위치", "드루이드 마나바의 위치를 설정합니다.", nil, notActiveDruidManaBar, nil,
		function() return IUF.db.classBar.DRUID.pos == "TOP" and 1 or 2, { "위쪽", "아래쪽" } end,
		function(v)
			IUF.db.classBar.DRUID.pos = v == 1 and "TOP" or "BOTTOM"
			if IUF.units.player.classBar and IUF.units.player.classBar.type == "DRUID" then
				IUF:SetObjectElementSkin(IUF.units.player, "classBar")
			end
		end
	)
	menu.pos:SetPoint("TOP", menu.height, "BOTTOM", 0, -5)
	menu.textType = LBO:CreateWidget("DropDown", parent, "바 문자 표시 방식", "드루이드 마나바 문자의 표시 방식을 설정합니다.", nil, notActiveDruidManaBar, nil,
		function() return IUF.db.classBar.DRUID.textType + 1, barTextTypes end,
		function(v)
			IUF.db.classBar.DRUID.textType = v - 1
			if IUF.units.player.classBar and IUF.units.player.classBar.type == "DRUID" then
				IUF:ClassBarSetup(IUF.units.player)
			end
			LBO:Refresh()
		end
	)
	menu.textType:SetPoint("TOP", menu.texture, "BOTTOM", 0, -5)
	menu.textFont = LBO:CreateWidget("Font", parent, "글꼴", "드루이드 마나바 문자의 글꼴을 설정합니다.", nil,
		function()
			if not notActiveDruidManaBar() then
				if type(IUF.db.classBar.DRUID.textType) == "number" and IUF.db.classBar.DRUID.textType > 0 then
					return false
				end
			end
			return true
		end, nil,
		function()
			return IUF.db.classBar.DRUID.fontFile, IUF.db.classBar.DRUID.fontSize, IUF.db.classBar.DRUID.fontAttribute, IUF.db.classBar.DRUID.fontShadow
		end,
		function(file, size, attribute, shadow)
			IUF.db.classBar.DRUID.fontFile = file
			IUF.db.classBar.DRUID.fontSize = size
			IUF.db.classBar.DRUID.fontAttribute = attribute
			IUF.db.classBar.DRUID.fontShadow = shadow
			if IUF.units.player.classBar and IUF.units.player.classBar.type == "DRUID" then
				IUF:ClassBarSetup(IUF.units.player)
			end
		end
	)
	menu.textFont:SetPoint("TOP", menu.pos, "BOTTOM", 0, -5)
end

function Option:CreateShamanTotemTimerMenu(menu, parent)
	menu.use = LBO:CreateWidget("CheckBox", parent, "주술사 토템 타이머 사용하기", "주술사 토템 타이머의 사용 여부를 설정합니다.", nil, notActivePlayerUnit, nil,
		function() return IUF.db.classBar.SHAMAN.active end,
		function(v)
			IUF.db.classBar.SHAMAN.active = v
			LBO:Refresh()
			if IUF.units.player.classBar and IUF.units.player.classBar.type == "SHAMAN" then
				IUF:ClassBarSetup(IUF.units.player)
			end
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, -5)
	local function notActiveShamanTotemBar()
		if IUF.db.units.player.active then
			return not IUF.db.classBar.SHAMAN.active
		else
			return true
		end
	end
	menu.height = LBO:CreateWidget("Slider", parent, "높이", "주술사 토템 타이머의 높이를 설정합니다.", nil, notActiveShamanTotemBar, nil,
		function() return IUF.db.classBar.SHAMAN.height, 2, 40, 1, "픽셀" end,
		function(v)
			IUF.db.classBar.SHAMAN.height = v
			if IUF.units.player.classBar and IUF.units.player.classBar.type == "SHAMAN" and IUF.units.player.classBar:IsShown() then
				IUF.units.player.classBar:SetHeight(v)
			end
		end
	)
	menu.height:SetPoint("TOPRIGHT", -5, -5)
	menu.texture = LBO:CreateWidget("Media", parent, "바 모양", "주술사 토템 타이머 모양을 설정합니다.", nil, notActiveShamanTotemBar, nil,
		function() return IUF.db.classBar.SHAMAN.texture, "statusbar" end,
		function(v)
			IUF.db.classBar.SHAMAN.texture = v
			if IUF.units.player.classBar and IUF.units.player.classBar.type == "SHAMAN" then
				IUF:ClassBarSetup(IUF.units.player)
			end
		end
	)
	menu.texture:SetPoint("TOP", menu.use, "BOTTOM", 0, -5)
	menu.pos = LBO:CreateWidget("DropDown", parent, "위치", "주술사 토템 타이머의 위치를 설정합니다.", nil, notActiveShamanTotemBar, nil,
		function() return IUF.db.classBar.SHAMAN.pos == "TOP" and 1 or 2, { "위쪽", "아래쪽" } end,
		function(v)
			IUF.db.classBar.SHAMAN.pos = v == 1 and "TOP" or "BOTTOM"
			if IUF.units.player.classBar and IUF.units.player.classBar.type == "SHAMAN" then
				IUF:SetObjectElementSkin(IUF.units.player, "classBar")
			end
		end
	)
	menu.pos:SetPoint("TOP", menu.height, "BOTTOM", 0, -5)
	menu.showCD = LBO:CreateWidget("CheckBox", parent, "토템 지속 시간 보기", "주술사 토템 타이머의 지속 시간을 표시합니다.", nil, notActiveShamanTotemBar, nil,
		function() return IUF.db.classBar.SHAMAN.showCD end,
		function(v)
			IUF.db.classBar.SHAMAN.showCD = v
			LBO:Refresh()
		end
	)
	menu.showCD:SetPoint("TOP", menu.texture, "BOTTOM", 0, -12)
	menu.textFont = LBO:CreateWidget("Font", parent, "글꼴", "주술사 토템 타이머의 글꼴을 설정합니다.", nil,
		function()
			if not notActiveShamanTotemBar() then
				return not IUF.db.classBar.SHAMAN.showCD
			else
				return true
			end
		end, nil,
		function()
			return IUF.db.classBar.SHAMAN.fontFile, IUF.db.classBar.SHAMAN.fontSize, IUF.db.classBar.SHAMAN.fontAttribute, IUF.db.classBar.SHAMAN.fontShadow
		end,
		function(file, size, attribute, shadow)
			IUF.db.classBar.SHAMAN.fontFile = file
			IUF.db.classBar.SHAMAN.fontSize = size
			IUF.db.classBar.SHAMAN.fontAttribute = attribute
			IUF.db.classBar.SHAMAN.fontShadow = shadow
			if IUF.units.player.classBar and IUF.units.player.classBar.type == "SHAMAN" then
				IUF:ClassBarSetup(IUF.units.player)
			end
		end
	)
	menu.textFont:SetPoint("TOP", menu.pos, "BOTTOM", 0, -5)
end

function Option:CreateDeathKnightRuneBarMenu(menu, parent)
	menu.use = LBO:CreateWidget("CheckBox", parent, "죽음의 기사 룬바 사용하기", "죽음의 기사 룬바의 사용 여부를 설정합니다.", nil, notActivePlayerUnit, nil,
		function() return IUF.db.classBar.DEATHKNIGHT.active end,
		function(v)
			IUF.db.classBar.DEATHKNIGHT.active = v
			LBO:Refresh()
			if IUF.units.player.classBar and IUF.units.player.classBar.type == "DEATHKNIGHT" then
				IUF:ClassBarSetup(IUF.units.player)
			end
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, -5)
	local function notActiveDeathKnightRuneBar()
		if IUF.db.units.player.active then
			return not IUF.db.classBar.DEATHKNIGHT.active
		else
			return true
		end
	end
	menu.height = LBO:CreateWidget("Slider", parent, "높이", "죽음의 기사 룬바의 높이를 설정합니다.", nil, notActiveDeathKnightRuneBar, nil,
		function() return IUF.db.classBar.DEATHKNIGHT.height, 2, 40, 1, "픽셀" end,
		function(v)
			IUF.db.classBar.DEATHKNIGHT.height = v
			if IUF.units.player.classBar and IUF.units.player.classBar.type == "DEATHKNIGHT" and IUF.units.player.classBar:IsShown() then
				IUF.units.player.classBar:SetHeight(v)
			end
		end
	)
	menu.height:SetPoint("TOPRIGHT", -5, -5)
	menu.texture = LBO:CreateWidget("Media", parent, "바 모양", "죽음의 기사 룬바 모양을 설정합니다.", nil, notActiveDeathKnightRuneBar, nil,
		function() return IUF.db.classBar.DEATHKNIGHT.texture, "statusbar" end,
		function(v)
			IUF.db.classBar.DEATHKNIGHT.texture = v
			if IUF.units.player.classBar and IUF.units.player.classBar.type == "DEATHKNIGHT" then
				IUF:ClassBarSetup(IUF.units.player)
			end
		end
	)
	menu.texture:SetPoint("TOP", menu.use, "BOTTOM", 0, -5)
	menu.pos = LBO:CreateWidget("DropDown", parent, "위치", "죽음의 기사 룬바의 위치를 설정합니다.", nil, notActiveDeathKnightRuneBar, nil,
		function() return IUF.db.classBar.DEATHKNIGHT.pos == "TOP" and 1 or 2, { "위쪽", "아래쪽" } end,
		function(v)
			IUF.db.classBar.DEATHKNIGHT.pos = v == 1 and "TOP" or "BOTTOM"
			if IUF.units.player.classBar and IUF.units.player.classBar.type == "DEATHKNIGHT" then
				IUF:SetObjectElementSkin(IUF.units.player, "classBar")
			end
		end
	)
	menu.pos:SetPoint("TOP", menu.height, "BOTTOM", 0, -5)
	menu.showCD = LBO:CreateWidget("CheckBox", parent, "룬 재사용 대기 시간 보기", "죽음의 기사 룬의 재사용 대기 시간을 표시합니다.", nil, notActiveDeathKnightRuneBar, nil,
		function() return IUF.db.classBar.DEATHKNIGHT.showCD end,
		function(v)
			IUF.db.classBar.DEATHKNIGHT.showCD = v
			LBO:Refresh()
		end
	)
	menu.showCD:SetPoint("TOP", menu.texture, "BOTTOM", 0, -12)
	menu.textFont = LBO:CreateWidget("Font", parent, "글꼴", "죽음의 기사 룬바의 글꼴을 설정합니다.", nil,
		function()
			if not notActiveDeathKnightRuneBar() then
				return not IUF.db.classBar.DEATHKNIGHT.showCD
			else
				return true
			end
		end, nil,
		function()
			return IUF.db.classBar.DEATHKNIGHT.fontFile, IUF.db.classBar.DEATHKNIGHT.fontSize, IUF.db.classBar.DEATHKNIGHT.fontAttribute, IUF.db.classBar.DEATHKNIGHT.fontShadow
		end,
		function(file, size, attribute, shadow)
			IUF.db.classBar.DEATHKNIGHT.fontFile = file
			IUF.db.classBar.DEATHKNIGHT.fontSize = size
			IUF.db.classBar.DEATHKNIGHT.fontAttribute = attribute
			IUF.db.classBar.DEATHKNIGHT.fontShadow = shadow
			if IUF.units.player.classBar and IUF.units.player.classBar.type == "DEATHKNIGHT" then
				IUF:ClassBarSetup(IUF.units.player)
			end
		end
	)
	menu.textFont:SetPoint("TOP", menu.pos, "BOTTOM", 0, -5)



	menu.showBlizzard = LBO:CreateWidget("CheckBox", parent, "와우 기본 룬바 보이기", "와우 기본 룬바를 보이게 합니다. 일부 와우 기본 룬바를 재사용하는 애드온 사용 시 체크하세요", nil, nil, nil,
		function() return IUF.db.classBar.DEATHKNIGHT.showBlizzard end,
		function(v)
			IUF.db.classBar.DEATHKNIGHT.showBlizzard = v
			if IUF.units.player.classBar and IUF.units.player.classBar.type == "DEATHKNIGHT" then
				IUF:ClassBarSetup(IUF.units.player)
			end
		end
	)
	menu.showBlizzard:SetPoint("TOP", menu.showCD, "BOTTOM", 0, 0)
end

if IUF:HasModule("Heal") then
	function Option:CreateHealMenu(menu, parent)
		menu.use = LBO:CreateWidget("CheckBox", parent, "예상 치유량 보기", "체력바에 예상 치유량을 표시합니다.", nil, nil, nil,
			function() return IUF.db.heal.active end,
			function(v)
				IUF.db.heal.active = v
				if IUF:LoadModule("Heal") then
					IUF.modules.Heal:SetActive()
				end
				LBO:Refresh()
			end
		)
		menu.use:SetPoint("TOPLEFT", 5, 5)
		local function notActive()
			return not IUF.db.heal.active
		end
		menu.player = LBO:CreateWidget("CheckBox", parent, "자신의 치유량 합산", "예상 치유량에 자신의 치유량도 표시합니다.", nil, notActive, nil,
			function() return IUF.db.heal.player end,
			function(v)
				IUF.db.heal.player = v
				if IUF.modules.Heal then
					for _, object in pairs(IUF.units) do
						IUF.modules.Heal:UpdateObjectHeal(object)
					end
				end
			end
		)
		menu.player:SetPoint("TOP", menu.use, "BOTTOM", 0, 0)
		menu.alpha = LBO:CreateWidget("Slider", parent, "투명도", "예상 치유량 바의 투명도를 설정합니다.", nil, notActive, nil,
			function() return IUF.db.heal.alpha * 100, 0, 80, 1, "%" end,
			function(v)
				IUF.db.heal.alpha = v / 100
				if IUF.modules.Heal then
					IUF.modules.Heal:Setup()
				end
			end
		)
		menu.alpha:SetPoint("TOPRIGHT", -5, -39)
	end
end