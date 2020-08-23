local widget, version = "ShowHide", 1
local LBO = LibStub("LibBlueOption-1.0")
if not LBO:NewWidget(widget, version) then return end

local function enable(self)
	self:SetHeight(self.shownHeight or 44)
end

local function disable(self)
	self:SetHeight(0.001)
end

LBO:RegisterWidget(widget, version, function(self, name)
	self.Enable = enable
	self.Disable = disable
	enable(self)
end)