local IUF = InvenUnitFrames

local _G = _G
local pairs = _G.pairs
local ipairs = _G.ipairs
local tinsert = _G.table.insert
local UnitAura = _G.UnitAura
local UnitIsFriend = _G.UnitIsFriend
local CreateFrame = _G.CreateFrame

local numBuff, numDebuff, auraName, auraIcon, auraCount, auraType, auraDuration, auraEndTime, auraCaster, auraStealable, auraSpellID
local button, auraWidth, prevAnchor, firstAura, lastAura, isFriend, buffAnchor, debuffAnchor, dispel, stealType, topAnchor, bottomAnchor
local playerUnits = { player = true, pet = true, vehicle = true }
local auraOffset = 2
local rpoint = {
	TOPLEFT = "BOTTOMLEFT", BOTTOMLEFT = "TOPLEFT", TOPRIGHT = "TOPLEFT",
	LEFT = "RIGHT", RIGHT = "LEFT", TOP = "BOTTOM",
}
local ignoreAura = {
	[57940] = true, -- 겨울손아귀의 정수
	[58045] = true, -- 겨울손아귀의 정수
	[64373] = true, -- 전투 중지
	[64805] = true, -- 다르나서스 이김
	[64808] = true, -- 엑소다르 이김
	[64809] = true, -- 놈리건 이김
	[64810] = true, -- 아이언포지 이김
	[64811] = true, -- 오그리마 이김
	[64812] = true, -- 센진 이김
	[64813] = true, -- 실버문 이김
	[64814] = true, -- 스톰윈드 이김
	[64815] = true, -- 썬더 블러프 이김
	[64816] = true, -- 언더시티 이김
	[69127] = true, -- 왕좌의 한기
	[71328] = true, -- 던전 재사용 대기시간
	[73816] = true, -- 헬스크림의 전쟁노래
	[73818] = true, -- 헬스크림의 전쟁노래
	[73819] = true, -- 헬스크림의 전쟁노래
	[73820] = true, -- 헬스크림의 전쟁노래
	[73821] = true, -- 헬스크림의 전쟁노래
	[73822] = true, -- 헬스크림의 전쟁노래
	[73762] = true, -- 린의 힘
	[73824] = true, -- 린의 힘
	[73825] = true, -- 린의 힘
	[73826] = true, -- 린의 힘
	[73827] = true, -- 린의 힘
	[73828] = true, -- 린의 힘
}
local ignoreUnitAura = {
	[02479] = true, -- 명예 점수 없음
	[11196] = true, -- 붕대 치료
	[24755] = true, -- 즐거운 할로윈
	[26013] = true, -- 탈영병
	[26218] = true, -- 겨우살이
	[26680] = true, -- 사랑 받음
	[36032] = true, -- 비전 작렬
	[41425] = true, -- 저체온증
	[43681] = true, -- 전투 불참
	[46705] = true, -- 명예 점수 없음
	[55711] = true, -- 약해진 심장
	[57723] = true, -- 소진
	[57724] = true, -- 만족함
	[69438] = true, -- 상품에 만족
	[71041] = true, -- 던전 탈영병
	[72144] = true, -- 주황색 역병 잔류물
	[77145] = true, -- 녹색 역병 잔류물
}
local skipIgnoreUnit = { player = true, target = true, focus = true, party = true }

local function clearTable(tbl)
	for p in pairs(tbl) do
		tbl[p] = nil
	end
end

local function auraOnUpdate(aura)
	if GameTooltip:IsOwned(aura) then
		GameTooltip:SetUnitAura(aura:GetParent().unit, aura:GetID(), aura.isBuff and "HELPFUL" or "HARMFUL")
	else
		aura:SetScript("OnUpdate", nil)
	end
end

local function auraOnEnter(aura)
	GameTooltip:SetOwner(aura, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:SetUnitAura(aura:GetParent().unit, aura:GetID(), aura.isBuff and "HELPFUL" or "HARMFUL")
	GameTooltip:Show()
	aura:SetScript("OnUpdate", auraOnUpdate)
end

local function auraOnLeave(aura)
	aura:SetScript("OnUpdate", nil)
	GameTooltip:Hide()
end

local function getAuraOption(aura, option)
	return aura:GetParent().db[(aura.isBuff and "buff" or "debuff")..option]
end

local function createAuraButton(object, isbuff)
	button = CreateFrame("Frame", nil, object)
	button:Hide()
	button:SetFrameLevel(object:GetFrameLevel() + 5)
	button:EnableMouse(true)
	button.isBuff = isbuff
	button:SetScript("OnEnter", auraOnEnter)
	button:SetScript("OnLeave", GameTooltip_Hide)
	button.bg = button:CreateTexture(nil, "BORDER")
	button.bg:SetTexture(0, 0, 0, 0.6)
	button.bg:SetAllPoints()
	button.icon = button:CreateTexture(nil, "ARTWORK")
	button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	button.icon:SetPoint("TOPLEFT", 1, -1)
	button.icon:SetPoint("BOTTOMRIGHT", -1, 1)
	button.count = button:CreateFontString(nil, "OVERLAY")
	button.count:SetJustifyH("RIGHT")
	button.count:SetPoint("BOTTOMRIGHT", 5, 0)
	button.cooldown = CreateFrame("Cooldown", nil, button)
	button.cooldown:SetFrameLevel(button:GetFrameLevel() + 1)
	button.cooldown:Hide()
	button.cooldown:SetAllPoints()
	button.cooldown:SetReverse(true)
	button.cooldown:SetDrawEdge(true)
	button.cooldown.noCooldownCount = true
	button.overlay = CreateFrame("Frame", nil, button)
	button.overlay:SetFrameLevel(button:GetFrameLevel() + 2)
	button.overlay:SetAllPoints()
	button.cooldown.timer = button.overlay:CreateFontString(nil, "OVERLAY")
	button.cooldown.timer:SetJustifyH("LEFT")
	button.cooldown.timer:SetPoint("TOPLEFT", 0, -1)
	IUF:SetFontString(
		button.cooldown.timer,
		getAuraOption(button, "CooldownTextFontFile"),
		getAuraOption(button, "CooldownTextFontSize"),
		getAuraOption(button, "CooldownTextFontAttribute"),
		getAuraOption(button, "CooldownTextFontShadow")
	)
	button.cooldown.timer:SetTextColor(1, 1, 0)
	IUF:SetFontString(button.count, STANDARD_TEXT_FONT, getAuraOption(button, "CountTextFontSize"), "THICKOUTLINE,MONOCHROME", nil)
	return button
end

local function auraTimerOnUpdate(cooldown, timer)
	cooldown.updateTimer = cooldown.updateTimer + timer
	if cooldown.updateTimer > 0.25 then
		cooldown.updateTimer = 0
		cooldown.leftTime = cooldown.endTime - GetTime()
		if cooldown.leftTime <= 60 then
			cooldown.timer:SetFormattedText("%d", cooldown.leftTime)
		elseif cooldown.leftTime < 600 then
			cooldown.timer:SetFormattedText("%dm", cooldown.leftTime / 60 + 0.5)
		else
			cooldown.timer:SetText(nil)
		end
	end
end

local function setAura(aura, icon, count, duration, endTime, size, showText, showCdTexture, isPlayer)
	aura.icon:SetTexture(icon)
	aura.count:SetText(count and count > 1 and count or nil)
	aura:SetWidth(size)
	aura:SetHeight(size)
	if duration and duration > 0 then
		if isPlayer and showText then
			aura.cooldown.updateTimer, aura.cooldown.endTime = 1, endTime
			aura.cooldown:SetScript("OnUpdate", auraTimerOnUpdate)
		else
			aura.cooldown:SetScript("OnUpdate", nil)
			aura.cooldown.timer:SetText(nil)
		end
		count = endTime - duration
		if aura.cooldown.startTime ~= count or aura.cooldown.duration ~= duration or not aura.cooldown:IsShown() then
			aura.cooldown.startTime, aura.cooldown.duration = count, duration
			aura.cooldown:SetCooldown(endTime - duration, duration)
		end
	else
		aura.cooldown:SetScript("OnUpdate", nil)
		aura.cooldown.startTime, aura.cooldown.duration = nil
		aura.cooldown.timer:SetText(nil)
		aura.cooldown:Hide()
	end
	if showCdTexture then
		aura.cooldown:SetAlpha(1)
	else
		aura.cooldown:SetAlpha(0)
	end
	aura:Show()
end

local maxWidth

local function setAuraPos(auras, num)
	if num and num > 0 then
		prevAnchor = auras[1]
		if auras.skipline then
			if auras.pos == "LEFT" then
				for i = 2, num do
					auras[i]:SetPoint("RIGHT", auras[i - 1], "LEFT", -auras.offset, 0)
				end
			elseif auras.pos == "RIGHT" then
				for i = 2, num do
					auras[i]:SetPoint("LEFT", auras[i - 1], "RIGHT", auras.offset, 0)
				end
			else
				for i = 2, num do
					auras[i]:SetPoint(auras.np, auras[i - 1], auras.np2 or rpoint[auras.np], auras.nx, auras.ny)
				end
			end
		else
			auraWidth = prevAnchor:GetWidth() + auras.offset
			if auras.pos == "LEFT" or auras.pos == "RIGHT" then
				maxWidth = auras.anchor:GetHeight() - auras.small / 3
			else
				maxWidth = auras.anchor:GetWidth() - auras.small / 2
			end
			for i = 2, num do
				if auraWidth >= maxWidth then
					auras[i]:SetPoint(auras.lp, prevAnchor, auras.lp2 or rpoint[auras.lp], auras.lx, auras.ly)
					prevAnchor = auras[i]
					auraWidth = 0
				else
					auras[i]:SetPoint(auras.np, auras[i - 1], auras.np2 or rpoint[auras.np], auras.nx, auras.ny)
				end
				auraWidth = auraWidth + auras[i]:GetWidth() + auras.offset
			end
		end
		return prevAnchor
	else
		return nil
	end
end

local function checkAnchor(object, anchor)
	if anchor == object or anchor == object.classBar or anchor == object.castingBar then
		return nil
	else
		return anchor
	end
end

local function setAuraAnchorPos(first, anchor, second, secondAnchor)
	if first[1] and first[1]:IsShown() then
		first[1]:SetPoint(first.lp, first.anchor, first.lp2 or rpoint[first.lp], first.lx, first.ly)
		if second and second[1] and second[1]:IsShown() then
			if first.pos == second.pos then
				second[1]:SetPoint(second.lp, anchor, second.lp2 or rpoint[second.lp], second.lx * 3, second.ly * 2)
				if first.pos == "TOP" then
					return checkAnchor(second[1]:GetParent(), secondAnchor), nil
				elseif first.pos == "BOTTOM" then
					return nil, checkAnchor(second[1]:GetParent(), secondAnchor)
				else
					return nil, nil
				end
			else
				second[1]:SetPoint(second.lp, second.anchor, second.lp2 or rpoint[second.lp], second.lx, second.ly)
				if first.pos == "TOP" then
					return checkAnchor(second[1]:GetParent(), anchor), checkAnchor(second[1]:GetParent(), secondAnchor)
				elseif first.pos == "BOTTOM" then
					return checkAnchor(second[1]:GetParent(), secondAnchor), checkAnchor(second[1]:GetParent(), anchor)
				else
					return nil, nil
				end
			end
		elseif first.pos == "TOP" then
			return checkAnchor(first[1]:GetParent(), anchor), nil
		elseif first.pos == "BOTTOM" then
			return nil, checkAnchor(first[1]:GetParent(), anchor)
		else
			return nil, nil
		end
	end
	return nil, nil
end

local function auraUpdate(object)
	if not object.checkAllShown then return end
	if object.isPreview then
		return IUF:SetPreviewAura(object)
	end
	isFriend = UnitIsFriend("player", object.unit)
	-- 해제 가능한 디버프 찾기
	if isFriend then
		dispel = select(5, UnitAura(object.unit, 1, "HARMFUL|RAID"))
		if dispel and dispel ~= "" then
			object.values.dispel = dispel
		else
			object.values.dispel = nil
		end
	end
	-- 버프 검색
	numBuff = 0
	if object.buff.num > 0 then
		dispel = nil
		for i = 1, 40 do
			if numBuff < object.buff.num then
				auraName, _, auraIcon, auraCount, auraType, auraDuration, auraEnumDebuffTime, auraCaster, auraStealable, _, auraSpellID = UnitAura(object.unit, i, object.buff.filter)
				if auraName then
					if ignoreAura[auraSpellID or -1] and object.objectType ~= "player" then
						-- Ignore Aura
					elseif isFriend and (not skipIgnoreUnit[object.objectType]) and ignoreUnitAura[auraSpellID or -1] then
						-- Ignore Unit Aura
					else
						-- Show Aura
						numBuff = numBuff + 1
						if object.buff[numBuff] then
							object.buff[numBuff]:ClearAllPoints()
						else
							object.buff[numBuff] = createAuraButton(object, true)
						end
						object.buff[numBuff]:SetID(i)
						if playerUnits[auraCaster or ""] or (auraStealable and not isFriend) then
							setAura(object.buff[numBuff], auraIcon, auraCount, auraDuration, auraEnumDebuffTime, object.buff.big, object.buff.cduse, object.buff.cdbigtexture, true)
						else
							setAura(object.buff[numBuff], auraIcon, auraCount, auraDuration, auraEnumDebuffTime, object.buff.small, object.buff.cduse, object.buff.cdsmalltexture)
						end
						if auraStealable and not isFriend then
							object.buff[numBuff].bg:SetTexture(1, 0, 0, 1)
						else
							object.buff[numBuff].bg:SetTexture(0, 0, 0, 0.6)
						end
					end
				else
					break
				end
			else
				break
			end
		end
		if not isFriend then
			if dispel and dispel ~= "" then
				object.values.dispel = dispel
			else
				object.values.dispel = nil
			end
		end
	elseif not isFriend then
		object.values.dispel = nil
	end
	for i = numBuff + 1, 40 do
		if object.buff[i] and object.buff[i]:IsShown() then
			object.buff[i]:Hide()
		else
			break
		end
	end
	buffAnchor = setAuraPos(object.buff, numBuff)
	-- 디버프 검색
	numDebuff = 0
	if object.debuff.num > 0 then
		for i = 1, 40 do
			if numDebuff < object.debuff.num then
				auraName, _, auraIcon, auraCount, auraType, auraDuration, auraEnumDebuffTime, auraCaster, _, _, auraSpellID = UnitAura(object.unit, i, object.debuff.filter)
				if auraName then
					if ignoreAura[auraSpellID or -1] and object.objectType ~= "player" then
						-- Ignore Aura
					elseif isFriend and (not skipIgnoreUnit[object.objectType]) and ignoreUnitAura[auraSpellID or -1] then
						-- Ignore Unit Aura
					else
						-- Show Aura
						numDebuff = numDebuff + 1
						if object.debuff[numDebuff] then
							object.debuff[numDebuff]:ClearAllPoints()
						else
							object.debuff[numDebuff] = createAuraButton(object)
						end
						object.debuff[numDebuff]:SetID(i)
						if playerUnits[auraCaster or ""] then
							setAura(object.debuff[numDebuff], auraIcon, auraCount, auraDuration, auraEnumDebuffTime, object.debuff.big, object.debuff.cduse, object.debuff.cdbigtexture, true)
						else
							setAura(object.debuff[numDebuff], auraIcon, auraCount, auraDuration, auraEnumDebuffTime, object.debuff.small, object.debuff.cduse, object.debuff.cdsmalltexture)
						end
					end
				else
					break
				end
			else
				break
			end
		end
	end
	for i = numDebuff + 1, 40 do
		if object.debuff[i] and object.debuff[i]:IsShown() then
			object.debuff[i]:Hide()
		else
			break
		end
	end
	debuffAnchor = setAuraPos(object.debuff, numDebuff)
	-- 버프/디버프 위치 배치
	if isFriend then
		if numBuff > 0 then
			topAnchor, bottomAnchor = setAuraAnchorPos(object.buff, buffAnchor, object.debuff, debuffAnchor)
		else
			topAnchor, bottomAnchor = setAuraAnchorPos(object.debuff, debuffAnchor)
		end
	elseif numDebuff > 0 then
		topAnchor, bottomAnchor = setAuraAnchorPos(object.debuff, debuffAnchor, object.buff, buffAnchor)
	elseif numBuff > 0 then
		topAnchor, bottomAnchor = setAuraAnchorPos(object.buff, buffAnchor)
	end
	if object.auraTopAnchor ~= topAnchor then
		object.auraTopAnchor = topAnchor
		if object.db.castingBarPos == "TOPAURA" then
			IUF:SetCastingBarPosition(object)
		end
	end
	if object.auraBottomAnchor ~= bottomAnchor then
		object.auraBottomAnchor = bottomAnchor
		if object.db.castingBarPos == "BOTTOMAURA" then
			IUF:SetCastingBarPosition(object)
		end
	end
end

IUF.callbacks.Aura = auraUpdate
IUF.handlers.UNIT_AURA = function(self) self.values.auraChanged = not self.values.auraChanged end
IUF:RegisterObjectValueHandler("auraChanged", "Aura")
IUF.CreateAuraButton = createAuraButton
IUF.SetAuraPos = setAuraPos
IUF.SetAuraAnchorPos = setAuraAnchorPos