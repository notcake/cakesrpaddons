CGUI.RegisterDialog ("InventoryInspectionDialog", function ()
	local self = CGUI.CreateDialog ("BaseDialog")
	self:SetTitle ("Inventory Inspector")
	self:SetSize (ScrW () * 0.6, ScrH () * 0.6)
	
	self.View = CGUI.CreateView ("InventoryView")
	self.View:SetParent (self)
	self.View:AddEventListener ("WeightChanged", function (view, inventory)
		self:UpdateWeight ()
	end)
	
	self.AddButton = vgui.Create ("GButton", self)
	self.AddButton:SetSize (80, 48)
	self.AddButton:SetText ("Add Item")
	self.AddButton:AddEventListener ("Click", function (button)
		local inventory = self.View:GetInventory ()
		local dialog = CGUI.CreateDialog ("InventoryItemAdditionDialog", inventory)
		dialog:ShowDialog ()
	end)
	
	self.RemoveButton = vgui.Create ("GButton", self)
	self.RemoveButton:SetSize (80, 48)
	self.RemoveButton:SetText ("Remove Item")
	self.RemoveButton:AddEventListener ("Click", function (button)
		local selected = self.View:GetSelectedItem ()
		if not selected then
			return
		end
		local inventory = self.View:GetInventory ()
		local item = selected:GetItem ()
		RunConsoleCommand ("_inventory_remove_item", inventory:GetID (), item:GetID ())
	end)
	
	self.SetCountButton = vgui.Create ("GButton", self)
	self.SetCountButton:SetSize (80, 48)
	self.SetCountButton:SetText ("Set Quantity")
	self.SetCountButton:AddEventListener ("Click", function (button)
		local selected = self.View:GetSelectedItem ()
		if not selected then
			return
		end
		local inventory = self.View:GetInventory ()
		local item = selected:GetItem ()
		local dialog = CGUI.CreateDialog ("BaseQuery")
		dialog:SetSkin ("DarkRP")
		dialog:SetTitle ("Set item quantity...")
		dialog:SetPrompt ("Enter the new quantity:")
		dialog:SetSubmitText ("Change")
		dialog:SetInputString (tostring (item:GetCount ()))
		dialog:AddValidator (CGUI.GetValidator ("Number"))
		dialog:AddValidator (CGUI.GetValidator ("Integer"))
		dialog:AddValidator (CGUI.GetParametricValidator ("MinimumNumber", 1))
		
		dialog:AddEventListener ("Submit", function (self)
			RunConsoleCommand ("_inventory_set_count", inventory:GetID (), tostring (item:GetID ()), self:GetInputString ())
			self:Close ()
		end)
		
		dialog:ShowDialog ()
		
		if derma.GetSkinTable () ["DarkRP"] then
			function dialog:Paint ()
				CGUI.GetRenderer ("DarkRPFrame") (self)
			end
		end
	end)
	
	self.Weight = vgui.Create ("DLabel", self)
	self.Weight:SetFont ("TargetID")
	self.Weight:SetText ("0 / 0 lb")
	
	self:AddEventListener ("Close", function (self)
		self.View:CloseInventory ()
	end)
	
	self:AddLayouter (function (self)
		self:SetSkin ("DarkRP")
	
		local x, y = 8, 28
		self.View:SetPos (x, y)
		self.View:SetSize (self:GetWide () - 16, self:GetTall () - 38 - 56)
		y = y + self.View:GetTall () + 8
		
		self.AddButton:SetPos (x, y)
		x = x + self.AddButton:GetWide () + 8
		self.RemoveButton:SetPos (x, y)
		x = x + self.RemoveButton:GetWide () + 8
		self.SetCountButton:SetPos (x, y)
		
		self.Weight:SizeToContents ()
		self.Weight:SetPos (self:GetWide () - self.Weight:GetWide () - 16, self:GetTall () - self.Weight:GetTall () - 16)
	end)
	
	function self:OpenInventory (id)
		self.View:OpenInventory (id)
		self:UpdateWeight ()
	end
	
	if derma.GetSkinTable () ["DarkRP"] then
		function self:Paint ()
			CGUI.GetRenderer ("DarkRPFrame") (self)
		end
	end
	
	function self:UpdateWeight ()
		self.Weight:SetText (tostring (math.Round (self.View:GetInventory ():GetWeight (), 1)) .. " / " .. tostring (math.Round (self.View:GetInventory ():GetMaximumWeight (), 1)) .. " lb")
		self:PerformLayout ()
	end
	
	return self
end)