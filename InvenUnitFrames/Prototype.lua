local IUF = InvenUnitFrames

local _G = _G
local type = _G.type
local select = _G.select
local unpack = _G.unpack
local min = _G.math.min
local max = _G.math.max
local tonumber = _G.tonumber
local tinsert = _G.table.insert
local UnitExists = _G.UnitExists
local UnitName = _G.UnitName
local UnitGUID = _G.UnitGUID
local UnitIsPlayer = _G.UnitIsPlayer
local UnitClass = _G.UnitClass
local GetTime = _G.GetTime
local InCombatLockdown = _G.InCombatLockdown

local skinFile
local frameLevel = 4
local objectMenuHandler = {
	player = PlayerFrameDropDown,
	pet = PetFrameDropDown,
	target = TargetFrameDropDown,
	--focus = FocusFrameDropDown,
	party1 = PartyMemberFrame1DropDown,
	party2 = PartyMemberFrame2DropDown,
	party3 = PartyMemberFrame3DropDown,
	party4 = PartyMemberFrame4DropDown,
}

local objectValueStorage = {}

local function getobjectvalue(self, key)
	return objectValueStorage[self][key]
end

local function setnewobjectvalue(self, key, value)
	if value == true then
		value = 1
	elseif value == false then
		value = nil
	end
	if objectValueStorage[self][key] ~= value then
		objectValueStorage[self][key] = value
		if IUF.valueHandler[key] then
			if self.parent.shown and self.parent.watch then
				if self.parent.valuesChanged then
					self.parent.valuesChanged = nil
					IUF:UpdateAllCallbacks(self.parent)
				else
					for _, callback in ipairs(IUF.valueHandler[key]) do
						IUF:TriggerCallback(self.parent, callback, key, value)
					end
				end
			else
				self.parent.valuesChanged = true
			end
		end
	end
end

local function getdbvalue(self, key)
	if IUF.db.units[self.type].skin[key] ~= nil then
		return IUF.db.units[self.type].skin[key]
	elseif IUF.skins[IUF.db.skin] then
		skinFile = IUF.skins[IUF.db.skin == "DefaultSquare" and "Default" or IUF.db.skin]
		if IUF.db.units[self.type].skin.override and skinFile[IUF.db.units[self.type].skin.override] then
			if skinFile[IUF.db.units[self.type].skin.override][key] ~= nil then
				return skinFile[IUF.db.units[self.type].skin.override][key]
			elseif skinFile[IUF.db.units[self.type].skin.override].default and skinFile[skinFile[IUF.db.units[self.type].skin.override].default] and skinFile[skinFile[IUF.db.units[self.type].skin.override].default][key] ~= nil then
				return skinFile[skinFile[IUF.db.units[self.type].skin.override].default][key]
			end
		elseif skinFile[self.type] then
			if skinFile[self.type][key] ~= nil then
				return skinFile[self.type][key]
			elseif skinFile[self.type].default and skinFile[skinFile[self.type].default] and skinFile[skinFile[self.type].default][key] ~= nil then
				return skinFile[skinFile[self.type].default][key]
			end
		end
		if skinFile.base and skinFile.base[key] ~= nil then
			return skinFile.base[key]
		end
	end
	if IUF.overrideUnitSkin[self.type] and IUF.overrideUnitSkin[self.type][key] ~= nil then
		return IUF.overrideUnitSkin[self.type][key]
	end
	return IUF.overrideSkin[key]
end

local function setdbvalue(self, key, value)
	value = value or false
	if IUF.db.units[self.type].skin[key] ~= value then
		if (getdbvalue(self, key) or false) == value then
			IUF.db.units[self.type].skin[key] = nil
		else
			IUF.db.units[self.type].skin[key] = value
		end
	end
end

local valuesMetaTable = { __index = getobjectvalue, __newindex = setnewobjectvalue }
local dbMetaTable = { __index = getdbvalue, __newindex = setdbvalue }

local function setSafeAttribute(object, name, value)
	if object:GetAttribute(name) ~= value then
		object:SetAttribute(name, value)
	end
end

local function setManyAttributes(object, ...)
	for i = 1, select('#', ...), 2 do
		setSafeAttribute(object, select(i, ...))
	end
end

local function objectOnShow(object)
	object.shown = true
	IUF.visibleObject[object] = object.realunit
	--IUF.handlers.OnUpdate(object)
	if object.valuesChanged then
		IUF:UpdateAllCallbacks(object)
	elseif object.portrait then
		IUF.callbacks.Portrait(object)
	end
	object.values.toggle = not object.values.toggle
end

local function objectOnHide(object)
	object.values.aggro = nil
	object.shown = nil
	object.UpdateTooltip = nil
	IUF.visibleObject[object] = nil
end

local function objectOnEnter(object)
	IUF.highlightFrame:ClearAllPoints()
	if object.highlightfunc then
		object.highlightfunc(IUF.highlightFrame, object)
	else
		IUF.highlightFrame:SetAllPoints(object)
	end
	IUF.highlightFrame:Show()
	IUF:UpdateUnitTooltip(object)
end

local function objectOnLeave(object)
	IUF.highlightFrame:Hide()
	IUF:HideUnitTooltip(object)
end

local function objectAttributeChanged(object, name, value)
	-- 유니트 변경시 업데이트
	if name == "unit" then
		object.unit = value
		for unit, obj in pairs(IUF.links) do
			if obj == object then
				IUF.links[unit] = nil
				break
			end
		end
		if value then
			IUF.links[value] = object
			if UnitExists(value) then
				IUF:UpdateObject(object)
			end
		end
	end
end

local function objectToggleMenu(object)
	GameTooltip:Hide()
	ToggleDropDownMenu(1, nil, object.menuFrame, "cursor")
end

local function objectSetLocation(object)
	if not InCombatLockdown() then
		object:SetWidth(object.db.width)
		object:SetHeight(object.db.height)
		object:SetScale(object.db.scale)
		IUF:SetObjectPoint(object)
	end
end

function IUF:CreateObject(unit, parent)
	-- 유니트 오브젝트 생성
	if type(unit) ~= "string" or unit:len() < 2 or self.units[unit] then return end
	unit = unit:lower()
	local frameName = ("InvenUnitFrames_%s%s"):format(unit:sub(1, 1):upper(), unit:sub(2):gsub("target", "Target"))
	local frameParent = (parent and self.units[parent]) and self.units[parent] or self
	local object = CreateFrame("Button", frameName, frameParent, "SecureUnitButtonTemplate,SecureHandlerStateTemplate")
	tinsert(self.objectOrder, unit)
	object.buff, object.debuff = {}, {}
	object.values = setmetatable({ parent = object }, valuesMetaTable)
	objectValueStorage[object.values] = {}
	object:SetClampedToScreen(true)
	object:SetFrameStrata("BACKGROUND")
	object:SetFrameLevel(frameLevel)
	frameLevel = frameLevel + 7
	object:RegisterForClicks("AnyUp")
	object.SetSafeAttribute = setSafeAttribute
	object.SetManyAttributes = setManyAttributes
	object:SetManyAttributes("unit", unit, "type1", "target", "type2", "menu", "realunit", unit)
	object.unit = unit
	object.realunit = unit
	object.objectType = unit:gsub("(%d+)", "")
	object.objectIndex = tonumber(unit:match("(%d+)") or "")
	object.parent = parent
	object.db = setmetatable({ type = object.objectType }, dbMetaTable)
	object.needElement = true
	object:HookScript("OnAttributeChanged", objectAttributeChanged)
	object:SetScript("OnShow", objectOnShow)
	object:SetScript("OnHide", objectOnHide)
	object:SetScript("OnEnter", objectOnEnter)
	object:SetScript("OnLeave", objectOnLeave)
	self.links[unit] = object
	if unit == "player" or unit == "pet" then
		-- 플레이어가 탈것 탑승
		object:SetAttribute("vehicleunit", unit == "player" and "pet" or "player")
		object:SetAttribute("_onstate-vehicleui", "self:SetAttribute('unit', self:GetAttribute(newstate == 'vehicle' and 'vehicleunit' or 'realunit'))")
		RegisterStateDriver(object, "vehicleui", "[vehicleui]vehicle;none")
		object.petunit = "pet"
	elseif object.objectType == "party" then
		-- 파티원이 탈것 탑승
		object:SetAttribute("vehicleunit", unit:gsub("party", "partypet") or nil)
		object:SetAttribute("_onstate-vehicleui", "self:SetAttribute('unit', self:GetAttribute(newstate == 'vehicle' and 'vehicleunit' or 'realunit'))")
		RegisterStateDriver(object, "vehicleui", "[@"..unit..",unithasvehicleui]vehicle;none")
		object.petunit = object:GetAttribute("vehicleunit")
		object:SetAttribute("_onstate-hideraid", "self:SetAttribute('unitsuffix', newstate == 'hide' and 'none' or nil)")
	elseif object.objectType == "partypet" then
		-- 파티원이 탈것 탑승시 펫 프레임 숨김
		object:SetAttribute("vehicleunit", unit:gsub("pet", "") or nil)
		object:SetAttribute("_onstate-vehicleui", "self:SetAttribute('unitsuffix', newstate == 'vehicle' and 'hide' or nil)")
		RegisterStateDriver(object, "vehicleui", "[@"..unit:gsub("pet", "")..",unithasvehicleui]vehicle;none")
	elseif unit:find("(.+)target$") or object.objectType == "boss" then
		object.needAutoUpdate = true
	end
	if object.unit == object.petunit then
		object.petunit = nil
	end
	object.vehicleunit = object:GetAttribute("vehicleunit") or nil
	object:Show()
	self:RegisterMoving(object)
	self:RegisterFocusKey(object)
	self.units[unit] = object
	object.SetLocation = objectSetLocation
	if objectMenuHandler[unit] then
		object.menu = objectToggleMenu
		object.menuFrame = objectMenuHandler[unit]
		objectMenuHandler[unit] = nil
	end
	return object
end

function IUF:SetActiveObject(object)
	if not (object.isPreview or InCombatLockdown()) then
		if self.db.units[object.objectType].active then
			object.watch = true
			RegisterUnitWatch(object)
			if object.objectType == "party" then
				RegisterStateDriver(object, "hideraid", self.db.hideInRaid and "[@raid1,exists]hide;show" or "show")
				if self.db.hideInRaid and GetNumRaidMembers() > 0 then
					object:SetAttribute("unitsuffix", "none")
					object:Hide()
				else
					object:SetAttribute("unitsuffix", nil)
					if UnitExists(object:GetAttribute("unit") or "") then
						object:Show()
					else
						object:Hide()
					end
				end
			elseif UnitExists(object:GetAttribute("unit") or "") then
				object:Show()
			else
				object:Hide()
			end
			if not object.needElement then
				self:UpdateObject(object)
			end
		else
			object.watch = nil
			UnregisterUnitWatch(object)
			object:Hide()
		end
	end
end

local modifilters = { "SHIFT-", "CTRL-", "ALT-", "CTRL-SHIFT-", "ALT-SHIFT-", "ALT-CTRL" }

function IUF:RegisterFocusKey(object)
	if object._focus_modifier and object._focus_button then
		object:SetManyAttributes(
			("%stype%d"):format(modifilters[object._focus_modifier], object._focus_button), nil,
			("%smacrotext%d"):format(modifilters[object._focus_modifier], object._focus_button), nil
		)
	end
	if modifilters[self.db.focusKey.mod or 0] then
		object._focus_modifier = self.db.focusKey.mod
		object._focus_button = self.db.focusKey.button
		object:SetManyAttributes(
			("%stype%d"):format(modifilters[self.db.focusKey.mod], self.db.focusKey.button), "macro",
			("%smacrotext%d"):format(modifilters[self.db.focusKey.mod], self.db.focusKey.button),
			object.objectType == "focus" and "/clearfocus" or "/focus [@mouseover]"
		)
	else
		object._focus_modifier, object._focus_button = nil
	end
end

local function statusBarOnHide(bar)
	bar.fadeTex.value = 0
	bar.fadeTex:Hide()
end

local function statusBarOnFadeUpdate(fade, timer)
	fade.timer = fade.timer - timer
	if fade.timer > 0 then
		fade.percent = fade.timer / fade.fadeTime
		fade:SetAlpha(fade.percent)
		fade:SetValue(fade.current + fade.distance * fade.percent)
	else
		fade:Hide()
	end
end

local function statusBarSetValue(bar, value, valuemax, force)
	if (force or bar:IsShown()) and value and valuemax then
		value = min(value, valuemax)
		bar:SetMinMaxValues(0, valuemax)
		bar:SetValue(value)
		if IUF.db.barAnimation and bar.fadeTex.valuemax == valuemax and bar.fadeTex.value > value then
			bar.fadeTex:SetMinMaxValues(0, valuemax)
			bar.fadeTex:SetValue(bar.fadeTex.value)
			bar.fadeTex:SetAlpha(1)
			bar.fadeTex.distance = bar.fadeTex.value - value
			bar.fadeTex.current = value
			bar.fadeTex.timer = bar.fadeTex.fadeTime
			bar.fadeTex:Show()
		end
		bar.fadeTex.value, bar.fadeTex.valuemax = value, valuemax
		for _, ebar in pairs(bar.extra) do
			if ebar:GetObjectType() == "StatusBar" then
				ebar:SetMinMaxValues(0, valuemax)
			end
		end
		return true
	else
		bar.fadeTex:Hide()
		return nil
	end
end

local function statusBarSetColor(bar, r, g, b)
	bar:SetStatusBarColor(r, g, b)
	bar.fadeTex:SetStatusBarColor(r, g, b)
	bar.backgroundTex:SetVertexColor(r, g, b)
	for _, ebar in pairs(bar.extra) do
		if ebar:GetObjectType() == "StatusBar" then
			ebar:SetStatusBarColor(r, g, b)
		elseif ebar:GetObjectType() == "Texture" then
			ebar:SetTexture(r, g, b)
		end
	end
end

local prev_r, prev_g, prev_b

local function statusBarSetTexture(bar, ...)
	prev_r, prev_g, prev_b = bar:GetStatusBarColor()
	bar:SetStatusBarTexture(...)
	bar.fadeTex:SetStatusBarTexture(...)
	bar.backgroundTex:SetTexture(...)
	for _, ebar in pairs(bar.extra) do
		if ebar:GetObjectType() == "StatusBar" then
			ebar:SetStatusBarTexture(...)
		elseif ebar:GetObjectType() == "Texture" then
			ebar:SetTexture(...)
		end
	end
	statusBarSetColor(bar, prev_r, prev_g, prev_b)
end

local function statusBarSetupExtraBar(bar, ebar)
	if bar.extra and bar.extra[ebar] then
		prev_r, prev_g, prev_b = bar:GetStatusBarColor()
		if bar.extra[ebar]:GetObjectType() == "StatusBar" then
			bar.extra[ebar]:SetStatusBarTexture(bar:GetStatusBarTexture():GetTexture())
			bar.extra[ebar]:SetStatusBarColor(prev_r, prev_g, prev_b)
			bar.extra[ebar]:SetMinMaxValues(bar:GetMinMaxValues())
		elseif bar.extra[ebar]:GetObjectType() == "Texture" then
			bar.extra[ebar]:SetTexture(bar:GetStatusBarTexture())
			bar.extra[ebar]:SetVertexColor(prev_r, prev_g, prev_b)
		end
	end
end

function IUF:CreateStatusBar(parent)
	-- StatusBar 만들기
	local bar = CreateFrame("StatusBar", nil, parent)
	bar:SetFrameLevel(parent:GetFrameLevel() + 2)
	bar:SetMinMaxValues(0, 1)
	bar:SetValue(1)
	bar.backgroundTex = bar:CreateTexture(nil, "BACKGROUND")
	bar.backgroundTex:SetAllPoints()
	bar.backgroundTex:SetAlpha(0.2)
	bar.backgroundTex2 = bar:CreateTexture(nil, "BACKGROUND")
	bar.backgroundTex2:SetTexture(0, 0, 0, 0.4)
	bar.backgroundTex2:SetAllPoints()
	bar.fadeTex = CreateFrame("StatusBar", nil, bar)
	bar.fadeTex.fadeTime = 0.4
	bar.fadeTex:SetFrameLevel(parent:GetFrameLevel() + 1)
	bar.fadeTex:SetMinMaxValues(0, 1)
	bar.fadeTex:SetValue(1)
	bar.fadeTex:SetAllPoints()
	bar.fadeTex:SetAlpha(0)
	bar.fadeTex:Hide()
	bar.fadeTex:SetScript("OnUpdate", statusBarOnFadeUpdate)
	bar.extra = {}
	bar.SetupExtraBar = statusBarSetupExtraBar
	bar:SetScript("OnHide", statusBarOnHide)
	bar.SetBar = statusBarSetValue
	bar.SetTexture = statusBarSetTexture
	bar.SetColor = statusBarSetColor
	tinsert(parent.fadeBars, bar.fadeTex)
	return bar
end

local ctime
local castingBarBackdrop = { bgFile = "Interface\\Tooltips\\UI-Tooltip-Background" }

local function castingBarOnUpdate(bar)
	if bar.startTime then
		ctime = GetTime()
		if ctime > bar.endTime then
			bar:GetParent():SetAlpha(0)
		else
			bar.spark:ClearAllPoints()
			if bar.isChannel then
				bar:SetValue(bar.startTime + bar.endTime - ctime)
				bar.spark:SetPoint("CENTER", bar, "LEFT", (bar.endTime - ctime) * (bar:GetWidth() / (bar.endTime - bar.startTime)), 0)
			else
				bar:SetValue(ctime)
				bar.spark:SetPoint("CENTER", bar, "LEFT", (ctime - bar.startTime) * (bar:GetWidth() / (bar.endTime - bar.startTime)), 0)
			end
			if bar.time:IsShown() then
				bar.time:SetFormattedText("%.1f", bar.endTime - ctime)
			end
		end
	end
end

function IUF:CreateCastingBar(object)
	object.castingBar = CreateFrame("Frame", nil, object)
	object.castingBar:Hide()
	object.castingBar:SetBackdrop(castingBarBackdrop)
	object.castingBar:SetFrameLevel(object:GetFrameLevel() + 10)
	object.castingBar:SetBackdropColor(0.1, 0.22, 0.35, 1)
	object.castingBar.icon = object.castingBar:CreateTexture(nil, "OVERLAY")
	object.castingBar.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	object.castingBar.icon:SetPoint("TOPLEFT", 1, 0)
	object.castingBarIcon = object.castingBar.icon
	object.castingBar.bar = CreateFrame("StatusBar", nil, object.castingBar)
	object.castingBar.bar:SetScript("OnUpdate", castingBarOnUpdate)
	object.castingBar.bar:SetFrameLevel(object:GetFrameLevel() + 11)
	object.castingBar.bar:SetPoint("TOPLEFT", object.castingBar.icon, "TOPRIGHT", 0, 0)
	object.castingBar.bar:SetPoint("BOTTOMRIGHT", -1, 1)
	object.castingBar.bar.spark = object.castingBar.bar:CreateTexture(nil, "OVERLAY")
	object.castingBar.bar.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	object.castingBar.bar.spark:SetBlendMode("ADD")
	object.castingBar.bar.spark:SetWidth(20)
	object.castingBar.bar.time = object.castingBar.bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	object.castingBar.bar.time:SetPoint("RIGHT", -1, 1)
	object.castingBarTime = object.castingBar.bar.time
	object.castingBar.text = object.castingBar.bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	object.castingBar.text:SetPoint("LEFT", 1, 1)
	object.castingBar.text:SetPoint("RIGHT", object.castingBar.bar.time, "LEFT", 0, 0)
	object.castingBar.text:SetJustifyH("LEFT")
	object.castingBarText = object.castingBar.text
end

function IUF:SetCastingBarPosition(object)
	if object.castingBar then
		object.castingBar:ClearAllPoints()
		if object.db.castingBarPos == "TOPAURA" then
			object.castingBar:SetPoint("LEFT", object.topAnchorFrame, "LEFT")
			object.castingBar:SetPoint("RIGHT", object.topAnchorFrame, "RIGHT")
			if object.auraTopAnchor then
				if select(2, object.auraTopAnchor:GetPoint()) == object.castingBar then
					BluePrint("Hack!")
				end
				object.castingBar:SetPoint("BOTTOM", object.auraTopAnchor, "TOP", 0, 3)
			elseif object.classBar and IUF.db.classBar[IUF.playerClass] and IUF.db.classBar[IUF.playerClass].pos == "TOP" then
				object.castingBar:SetPoint("BOTTOM", object.classBar, "TOP", 0, 1)
			else
				object.castingBar:SetPoint("BOTTOM", object.topAnchorFrame, "TOP")
			end
		elseif object.db.castingBarPos == "TOP" then
			object.castingBar:SetPoint("LEFT", object.topAnchorFrame, "LEFT")
			object.castingBar:SetPoint("RIGHT", object.topAnchorFrame, "RIGHT")
			if object.classBar and IUF.db.classBar[IUF.playerClass] and IUF.db.classBar[IUF.playerClass].pos == "TOP" then
				object.castingBar:SetPoint("BOTTOM", object.classBar, "TOP", 0, 1)
			else
				object.castingBar:SetPoint("BOTTOM", object.topAnchorFrame, "TOP")
			end
		elseif object.db.castingBarPos == "BOTTOMAURA" then
			object.castingBar:SetPoint("LEFT", object.bottomAnchorFrame, "LEFT")
			object.castingBar:SetPoint("RIGHT", object.bottomAnchorFrame, "RIGHT")
			if object.auraBottomAnchor then

				for name, frame in pairs(object) do
					if frame == object.auraBottomAnchor and name ~= "auraBottomAnchor" then
						BluePrint(name)
						break
					end
				end

				object.castingBar:SetPoint("TOP", object.auraBottomAnchor, "BOTTOM", 0, -3)
			elseif object.classBar and IUF.db.classBar[IUF.playerClass] and IUF.db.classBar[IUF.playerClass].pos == "BOTTOM" then
				object.castingBar:SetPoint("TOP", object.classBar, "BOTTOM")
			else
				object.castingBar:SetPoint("TOP", object.bottomAnchorFrame, "BOTTOM", 0, -1)
			end
		else
			object.castingBar:SetPoint("LEFT", object.bottomAnchorFrame, "LEFT")
			object.castingBar:SetPoint("RIGHT", object.bottomAnchorFrame, "RIGHT")
			if object.classBar and IUF.db.classBar[IUF.playerClass] and IUF.db.classBar[IUF.playerClass].pos == "BOTTOM" then
				object.castingBar:SetPoint("TOP", object.classBar, "BOTTOM", 0, -1)
			else
				object.castingBar:SetPoint("TOP", object.bottomAnchorFrame, "BOTTOM")
			end
		end
	end
end

function IUF:UpdateUnitTooltip(object)
	if self.objectType then
		object = self
		self = IUF
	end
	if object.objectType then
		GameTooltip_SetDefaultAnchor(GameTooltip, object)
		if object.isPreview then
			object.UpdateTooltip = nil
			GameTooltip:AddLine("Inven Unit Frames", 1, 1, 1)
		elseif object.unit and UnitExists(object.unit) then
			if (IUF.db.tooltip == 1 or (IUF.db.tooltip == 2 and not InCombatLockdown()) or (IUF.db.tooltip == 3 and InCombatLockdown())) then
				UnitFrame_UpdateTooltip(object)
			else
				return IUF:HideUnitTooltip(object)
			end
		else
			return IUF:HideUnitTooltip(object)
		end
		if IUF.previewMode then
			if object.isPreview then
				GameTooltip:AddLine("<"..object.values.name..">")
			elseif object.preview then
				GameTooltip:AddLine("<"..object.preview.values.name..">")
			elseif object == IUF.units.player then
				GameTooltip:AddLine("<플레이어>")
			end
		end
		if IUF.db.lock and (object.objectType == "focus" or object.objectType == "boss") then
			GameTooltip:AddLine("Alt+드래그로 이동 가능")
		end
		GameTooltip:Show()
	else
		IUF:HideUnitTooltip(object)
	end
end

function IUF:HideUnitTooltip(object)
	object.UpdateTooltip = nil
	GameTooltip:Hide()
end

local aggroBorderCoord = {
	[1] = { 0, 0.125, 0, 0.125 },
	[2] = { 0.875, 1, 0, 0.125 },
	[3] = { 0, 0.125, 0.875, 1 },
	[4] = { 0.875, 1, 0.875, 1 },
	[5] = { 0.125, 0.875, 0, 0.125 },
	[6] = { 0.125, 0.875, 0.875, 1 },
	[7] = { 0, 0.125, 0.125, 0.875 },
	[8] = { 0.875, 1, 0.125, 0.875 },
}

function IUF:CreateAggroBorder(object)
	object.aggroBorder = CreateFrame("Frame", nil, object)
	object.aggroBorder:SetFrameLevel(object.textFrame:GetFrameLevel())
	for i = 1, 8 do
		object.aggroBorder[i] = object.aggroBorder:CreateTexture(nil, "BACKGROUND")
		object.aggroBorder[i]:SetTexture("Interface\\AddOns\\InvenUnitFrames\\Texture\\AggroBorder2")
		object.aggroBorder[i]:SetTexCoord(unpack(aggroBorderCoord[i]))
		object.aggroBorder[i]:SetVertexColor(1, 0, 0)
		object.aggroBorder[i]:SetBlendMode("ADD")
		if i < 5 then
			object.aggroBorder[i]:SetWidth(6)
			object.aggroBorder[i]:SetHeight(6)
		end
	end
	object.aggroBorder[1]:SetPoint("TOPLEFT", 0, 0)
	object.aggroBorder[2]:SetPoint("TOPRIGHT", 0, 0)
	object.aggroBorder[3]:SetPoint("BOTTOMLEFT", 0, 0)
	object.aggroBorder[4]:SetPoint("BOTTOMRIGHT", 0, 0)
	object.aggroBorder[5]:SetPoint("TOPLEFT", object.aggroBorder[1], "TOPRIGHT", 0, 0)
	object.aggroBorder[5]:SetPoint("BOTTOMRIGHT", object.aggroBorder[2], "BOTTOMLEFT", 0, 0)
	object.aggroBorder[6]:SetPoint("TOPLEFT", object.aggroBorder[3], "TOPRIGHT", 0, 0)
	object.aggroBorder[6]:SetPoint("BOTTOMRIGHT", object.aggroBorder[4], "BOTTOMLEFT", 0, 0)
	object.aggroBorder[7]:SetPoint("TOPLEFT", object.aggroBorder[1], "BOTTOMLEFT", 0, 0)
	object.aggroBorder[7]:SetPoint("BOTTOMRIGHT", object.aggroBorder[3], "TOPRIGHT", 0, 0)
	object.aggroBorder[8]:SetPoint("TOPLEFT", object.aggroBorder[2], "BOTTOMLEFT", 0, 0)
	object.aggroBorder[8]:SetPoint("BOTTOMRIGHT", object.aggroBorder[4], "TOPRIGHT", 0, 0)
end

local flashFrame = CreateFrame("Frame", nil, UIParent)
flashFrame:Hide()
flashFrame.frames = {}
flashFrame.mode, flashFrame.timer = 1, 0
flashFrame.fadeIn, flashFrame.fadeInStop = 0.5, 0.4
flashFrame.fadeOut, flashFrame.fadeOutStop = 0.5, 0
flashFrame:SetScript("OnUpdate", function(self, timer)
	self.timer = self.timer + timer
	if self.mode == 1 then
		if self.timer < self.fadeIn then
			for frame in pairs(self.frames) do
				frame:SetAlpha(self.timer / self.fadeIn)
			end
		else
			self.mode, self.timer = 2, 0
			for frame in pairs(self.frames) do
				frame:SetAlpha(1)
			end
		end
	elseif self.mode == 2 then
		if self.timer > self.fadeInStop then
			self.mode, self.timer = 3, 0
		end
	elseif self.mode == 3 then
		if self.timer < self.fadeOut then
			for frame in pairs(self.frames) do
				frame:SetAlpha(1 - self.timer / self.fadeOut)
			end
		else
			self.mode, self.timer = 4, 0
			for frame in pairs(self.frames) do
				frame:SetAlpha(0)
			end
		end
	else
		if self.timer > self.fadeOutStop then
			self.mode, self.timer = 1, 0
		end
	end
end)

function IUF:RegisterFlash(frame)
	frame:Show()
	if not flashFrame.frames[frame] then
		flashFrame.frames[frame] = true
		if not flashFrame:IsShown() then
			flashFrame:Show()
		end
	end
end

function IUF:UnregisterFlash(frame)
	frame:Hide()
	if flashFrame.frames[frame] then
		flashFrame.frames[frame] = nil
		for _ in pairs(flashFrame.frames) do
			return
		end
		flashFrame:Hide()
	end
end