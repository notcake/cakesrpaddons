local View = nil

CGUI.RegisterView ("InventoryUpgradesView", function ()
	local self = CGUI.CreateControl ("BasePanel")
	self.LastVisibleTime = 0
	self.MaximumWeight = 0
	
	self.Description = vgui.Create ("DLabel", self)
	self.Description:SetText ("Is your inventory full? You can buy more inventory space here!\nSmall Inventory Expansions add 15 lbs to your inventory capacity.\nYou may only buy a maximum of 4 small inventory expansions.")
	self.Description:SetWrap (true)
	
	self.Buy = vgui.Create ("GButton", self)
	self.Buy:SetText ("Buy Small Inventory Expansion ($1000)")
	self.Buy:AddEventListener ("Click", function (button)
		RunConsoleCommand ("_inventory_buy_space")
	end)
	
	self.Description2 = vgui.Create ("DLabel", self)
	self.Description2:SetText ("Larger inventory expansions are also available.\nYou may acquire these by donating money to help keep the server alive.\nYour donations may take up to 2 days to process.\nLarge Inventory Expansions add 70 lbs to your inventory capacity.")
	self.Description2:SetWrap (true)
	
	self.Buy2 = vgui.Create ("GButton", self)
	self.Buy2:SetText ("Donate")
	self.Buy2:AddEventListener ("Click", function (button)
	end)
	
	self:AddLayouter (function (self)
		local x, y = 8, 8
		self.Description:SetPos (x, y)
		self.Description:SetSize (self:GetWide (), 48)
		y = y + self.Description:GetTall () + 8
		
		self.Buy:SetPos (x + 32, y)
		self.Buy:SetSize (320, 32)
		y = y + self.Buy:GetTall () + 16
		
		self.Description2:SetPos (x, y)
		self.Description2:SetSize (self:GetWide (), 64)
		y = y + self.Description2:GetTall () + 8
		
		self.Buy2:SetPos (x + 32, y)
		self.Buy2:SetSize (320, 32)
		y = y + self.Buy2:GetTall () + 16	

		self:UpdateButtons ()
	end)
	
	function self:UpdateButtons ()
		local canbuy = false
		if LocalPlayer ().DarkRPVars and
			LocalPlayer ().DarkRPVars.money > 1000 then
			local item = CInventory.Inventories:GetLocalInventory ():FindItem ("Small Inventory Expansion")
			if not item or item:GetCount () < 4 then
				canbuy = true
			end
		end
		self.Buy:SetDisabled (not canbuy)
	end
	
	CInventory.Inventories:GetLocalInventory ():AddEventListener ("ItemCountChanged", function ()
		self:UpdateButtons ()
	end)
	
	View = self
	return self
end)