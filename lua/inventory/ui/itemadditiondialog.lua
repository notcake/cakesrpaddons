CGUI.RegisterDialog ("InventoryItemAdditionDialog", function (inventory)
	local self = CGUI.CreateDialog ("BaseDialog")
	self.Inventory = inventory
	self:SetSize (300, 132)
	self:SetTitle ("Add an item...")
	
	self.ClassLabel = vgui.Create ("DLabel", self)
	self.ClassLabel:SetText ("Item type:")
	
	self.ItemClassChoice = vgui.Create ("DMultiChoice", self)
	self.ItemClassChoice:SetEditable (false)
	function self.ItemClassChoice.OnSelect (control, index, value)
		control.Text = value
	end
	
	self.QuantityLabel = vgui.Create ("DLabel", self)
	self.QuantityLabel:SetText ("Quantity")
	
	self.Quantity = vgui.Create ("DNumberWang", self)
	self.Quantity:SetValue (1)
	self.Quantity:SetDecimals (0)
	
	self.OK = vgui.Create ("GButton", self)
	self.OK:SetText ("Add")
	self.OK:SetSize (80, 28)
	self.OK:AddEventListener ("Click", function (button)
		local itemclass = self.ItemClassChoice.Text or ""
		if itemclass == "" then
			return
		end
		local tbl = {
			InventoryID = inventory:GetID (),
			ItemClass = itemclass,
			Count = self.Quantity:GetValue ()
		}
		datastream.StreamToServer ("inventory_add_item", tbl)
		self:Close ()
	end)
	
	self.Cancel = vgui.Create ("GButton", self)
	self.Cancel:SetText ("Cancel")
	self.Cancel:SetSize (80, 28)
	self.Cancel:AddEventListener ("Click", function (button)
		self:Close ()
	end)
	
	CInventory.ItemClasses:AddEventListener ("ItemClassesReceived", tostring (self), function (collection)
		self.ItemClassChoice:Clear ()
		for class, _ in collection:GetItemClassIterator () do
			self.ItemClassChoice:AddChoice (class)
		end
		CInventory.ItemClasses:RemoveEventListener ("ItemClassesReceived", tostring (self))
	end)
	
	self:AddEventListener ("Close", function (self)
		CInventory.ItemClasses:RemoveEventListener ("ItemClassesReceived", tostring (self))
	end)
	
	self:AddLayouter (function (self)
		self:SetSkin ("DarkRP")
	
		local x, y = 8, 32
		self.ClassLabel:SetPos (x, y)
		self.ItemClassChoice:SetPos (self:GetWide () * 0.5, y)
		self.ItemClassChoice:SetWide (self:GetWide () * 0.5 - 8)
		y = y + self.ClassLabel:GetTall () + 8
		
		self.QuantityLabel:SetPos (x, y)
		self.Quantity:SetPos (self:GetWide () * 0.5, y)
		self.Quantity:SetWide (self:GetWide () * 0.5 - 8)
		
		self.Cancel:SetPos (self:GetWide () - 8 - self.Cancel:GetWide (), self:GetTall () - 8 - self.Cancel:GetTall ())
		self.OK:SetPos (self:GetWide () - 16 - self.Cancel:GetWide () - self.OK:GetWide (), self:GetTall () - 8 - self.OK:GetTall ())
	end)
	
	if derma.GetSkinTable () ["DarkRP"] then
		function self:Paint ()
			CGUI.GetRenderer ("DarkRPFrame") (self)
		end
	end
	
	CInventory.ItemClasses:RequestItemClasses ()
	return self
end)