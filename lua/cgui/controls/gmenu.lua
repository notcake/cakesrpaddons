local PANEL = {}
local openMenus = {}

--[[
	Events
	
	MenuOpening (CMenu menu)
]]

local function CloseMenus ()
	for _, menu in pairs (openMenus) do
		menu:Hide ()
		openMenus [menu] = nil
	end
end

function PANEL:Init ()
	self.ClassName = "DMenu"
	
	self:SetVisible (false)
	
	local _, menuList = debug.getupvalue (RegisterDermaMenuForClose, 1)
	menuList [#menuList] = nil
	
	CGUI:AddEventListener ("Unload", tostring (self), function ()
		self:Remove ()
	end)
	
	CUtil.EventProvider (self)
end

function PANEL:AddItem (text, callback)
	local item = vgui.Create ("GMenuItem", self)
	item:SetParentMenu (self)
	item:SetText (text)
	if callback then
		item.DoClick = callback
	end
	self:AddPanel (item)
	
	return item
end

PANEL.AddOption = PANEL.AddItem

function PANEL:AddSeparator ()
    local item = vgui.Create ("DBevel", self)
    item:SetTall (2)
    item:SetAlpha (100)
    
    self:AddPanel (item)
	
	return item
end

PANEL.AddSpacer = PANEL.AddSeparator

function PANEL:CloseMenus ()
	CloseMenus ()
end

function PANEL:FindItem (text)
	for _, item in pairs (self.Panels) do
		if item:GetText () == text then
			return item
		end
	end
	return nil
end

function PANEL:Hide ()
	openMenus [self] = nil
	DMenu.Hide (self)
end

function PANEL:Open (...)
	openMenus [self] = self
	self:DispatchEvent ("MenuOpening", self)
	DMenu.Open (self, ...)
end

function PANEL:PerformLayout ()
	if self.animOpen.Running then
		return
	end
	local w, h = self:GetMinimumWidth (), 0
	
	for _, item in ipairs (self.Panels) do
		item:PerformLayout()
        w = math.max (w, item:GetWide ())
    end
	
	self:SetWide (w)
	
	for _, item in ipairs (self.Panels) do
		item:SetWide (w)
		item:SetPos (0, h)
		item:InvalidateLayout (true)
		
		if item:IsVisible () then
			h = h + item:GetTall ()
		end
	end
	
	self:SetTall (h)
end

function PANEL:Remove ()
	CGUI:RemoveEventListener ("Unload", tostring (self))
	_R.Panel.Remove (self)
end

vgui.Register ("GMenu", PANEL, "DMenu")

hook.Add ("VGUIMousePressed", "GMenus", function (panel, mouseCode)
	if panel and panel.ClassName == "DMenu" then
		return
	end
	
	panel = panel:GetParent ()
	if panel and panel.ClassName == "DMenu" then
		return
	end
	
	CloseMenus ()
end)

CGUI:AddEventListener ("Unload", function ()
	CloseMenus ()
end)