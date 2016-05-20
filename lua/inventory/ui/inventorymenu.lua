CGUI.RegisterDialog ("InventoryMenu", function ()
	local self = CGUI.CreateDialog ("BaseDialog")
	self:SetDeleteOnClose (false)
	self:SetTitle ("Inventory")
	self:SetSize (ScrW () * 0.7, ScrH () * 0.7)
	
	self.Tabs = vgui.Create ("DPropertySheet", self)
	self.Tabs:SetPos (4, 24)
	
	self.Tabs:AddSheet ("My Inventory", CGUI.CreateView ("MyInventoryView"), "gui/silkicons/basket", false, false, "View your inventory")
	self.Tabs:AddSheet ("Upgrades", CGUI.CreateView ("InventoryUpgradesView"), "gui/silkicons/basket", false, false, "Buy upgrades")
	if CInventory.CanModifySettings (LocalPlayer ()) then
		self.Tabs:AddSheet ("Administration", CGUI.CreateView ("InventorySettingsView"), "gui/silkicons/wrench", false, false, "Configure the inventory system and edit inventories")
	end
	
	self:AddLayouter (function (self)
		self:SetSkin ("DarkRP")
	
		self.Tabs:SetSize (self:GetWide () - 8, self:GetTall () - 28)
	end)
	
	function self:OnKeyCodePressed (code)
		if code == KEY_F5 then
			self:Close ()
		end
	end
	
	if derma.GetSkinTable () ["DarkRP"] then
		function self:Paint ()
			CGUI.GetRenderer ("DarkRPFrame") (self)
		end
	end
	
	return self
end)