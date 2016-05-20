local PANEL = {}

--[[
	Events
	
	Clicked
]]

function PANEL:Init ()
	self.Disabled = false
	
	self.Font = "Default"
	self:SetText ("")
	
	CUtil.EventProvider (self)
end

function PANEL:ApplySchemeSettings ()
	local font = self:GetFont ()
    derma.SkinHook ("Scheme", "Button", self)
	self:SetFont (font)
	
	if IsValid (self.m_Image) then
		self.m_Image:Center()
		self.m_Image:AlignLeft( 4 )
		
		self:SetTextInset (self.m_Image:GetWide() + 8, 0 )
		self:SetContentAlignment (4)
	end
end

function PANEL:GetFont ()
	return self.Font
end

function PANEL:IsPressed ()
	return self.Depressed
end

function PANEL:IsDisabled ()
	return self.Disabled
end

PANEL.GetDisabled = PANEL.IsDisabled

function PANEL:SetDisabled (disabled)
	if disabled == nil then
		disabled = true
	end
	self.Disabled = disabled
	self:ApplySchemeSettings ()
end

function PANEL:SetFont (font)
	self.Font = font
	_R.Panel.SetFont (self, font)
end

-- Events
function PANEL:DoClick ()
	if self.Disabled then
		return
	end
	self:DispatchEvent ("Click")
end

vgui.Register ("GButton", PANEL, "DButton")