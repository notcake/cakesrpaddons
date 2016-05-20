local View = nil
CGUI.RegisterDialog ("InventoryItemClassModificationDialog", function ()
	local self = CGUI.CreateDialog ("BaseDialog")
	self:SetTitle ("Modify Item Class...")
	self:SetTall (296)
	self.Selected = nil
	
	self.ItemClassLabel = vgui.Create ("DLabel", self)
	self.ItemClassLabel:SetText ("Choose the item class:")
	self.ItemClassChoice = vgui.Create ("DMultiChoice", self)
	self.ItemClassChoice:SetEditable (false)
	
	function self.ItemClassChoice.OnSelect (choice, index, value)
		self.Selected = value
		RunConsoleCommand ("_inventory_request_item_class", self.Selected)
	end
	
	self.RemoveButton = vgui.Create ("GButton", self)
	self.RemoveButton:SetSize (80, 24)
	self.RemoveButton:SetText ("Remove")
	self.RemoveButton:AddEventListener ("Click", function (button)
		RunConsoleCommand ("_inventory_remove_class", self.Selected)
		RunConsoleCommand ("_inventory_request_classes")
		self.ClassEntry:SetText ("")
		self.ModelEntry:SetText ("")
		self.SkinEntry:SetText ("")
	end)
	
	self.ClassLabel = vgui.Create ("DLabel", self)
	self.ClassLabel:SetText ("Classname:")
	self.ClassEntry = vgui.Create ("DTextEntry", self)
	self.ModelLabel = vgui.Create ("DLabel", self)
	self.ModelLabel:SetText ("Model:")
	self.ModelEntry = vgui.Create ("DTextEntry", self)
	self.SkinLabel = vgui.Create ("DLabel", self)
	self.SkinLabel:SetText ("Skin:")
	self.SkinEntry = vgui.Create ("DTextEntry", self)
	
	self.Stackable = vgui.Create ("GCheckbox", self)
	self.Stackable:SetTall (16)
	self.Stackable:SetText ("Stackable")
	
	self.Weight = vgui.Create ("DNumSlider", self)
	self.Weight:SetText ("Weight")
	self.Weight:SetMin (0)
	self.Weight:SetMax (200)
	self.Weight:SetValue (10)
	
	self.OK = vgui.Create ("GButton", self)
	self.OK:SetSize (80, 28)
	self.OK:SetText ("Save")
	self.OK:AddEventListener ("Click", function (button)
		datastream.StreamToServer ("inventory_create_item_class", {
			Name = self.Selected,
			Class = self.ClassEntry:GetText (),
			Model = self.ModelEntry:GetText (),
			Skin = self.SkinEntry:GetText (),
			Weight = self.Weight:GetValue (),
			Stackable = self.Stackable:IsChecked ()
		})
		self:Close ()
	end)
	self.Cancel = vgui.Create ("GButton", self)
	self.Cancel:SetSize (80, 28)
	self.Cancel:SetText ("Cancel")
	self.Cancel:AddEventListener ("Click", function (button)
		self:Close ()
	end)
	
	CInventory.ItemClasses:AddEventListener ("ItemClassesReceived", tostring (self), function (collection)
		self.ItemClassChoice:Clear ()
		for class, _ in collection:GetItemClassIterator () do
			self.ItemClassChoice:AddChoice (class)
		end
	end)
	
	self:AddEventListener ("Close", function (self)
		CInventory.ItemClasses:RemoveEventListener ("ItemClassesReceived", tostring (self))
	end)
	
	self:AddLayouter (function (self)
		self:SetSkin ("DarkRP")
	
		local x, y = 8, 32
		self.ItemClassLabel:SetPos (x, y)
		self.ItemClassLabel:SizeToContents ()
		y = y + self.ItemClassLabel:GetTall () + 8
		self.ItemClassChoice:SetPos (x + 8, y)
		self.ItemClassChoice:SetWide (self:GetWide () - 32 - self.RemoveButton:GetWide ())
		
		self.RemoveButton:SetPos (self:GetWide () - 8 - self.RemoveButton:GetWide (), y - 2)
		y = y + self.ItemClassChoice:GetTall () + 8
		
		self.ClassLabel:SetPos (x, y)
		self.ClassLabel:SizeToContents ()
		self.ClassEntry:SetPos (self:GetWide () * 0.5, y)
		self.ClassEntry:SetWide (self:GetWide () * 0.5 - 8)
		y = y + self.ModelEntry:GetTall () + 8
		
		self.ModelLabel:SetPos (x, y)
		self.ModelLabel:SizeToContents ()
		self.ModelEntry:SetPos (self:GetWide () * 0.5, y)
		self.ModelEntry:SetWide (self:GetWide () * 0.5 - 8)
		y = y + self.ModelEntry:GetTall () + 8
		
		self.SkinLabel:SetPos (x, y)
		self.SkinLabel:SizeToContents ()
		self.SkinEntry:SetPos (self:GetWide () * 0.5, y)
		self.SkinEntry:SetWide (self:GetWide () * 0.5 - 8)
		y = y + self.ModelEntry:GetTall () + 8
		
		self.Stackable:SetPos (x, y)
		self.Stackable:SetWide (self:GetWide () - 16)
		y = y + self.Stackable:GetTall () + 8
		
		self.Weight:SetPos (x, y)
		self.Weight:SetWide (self:GetWide () - 16)
		y = y + self.Weight:GetTall () + 8
		
		self.Cancel:SetPos (self:GetWide () - 8 - self.Cancel:GetWide (), self:GetTall () - 8 - self.Cancel:GetTall ())
		self.OK:SetPos (self:GetWide () - 16 - self.Cancel:GetWide () - self.OK:GetWide (), self:GetTall () - 8 - self.OK:GetTall ())
	end)
	
	if derma.GetSkinTable () ["DarkRP"] then
		function self:Paint ()
			CGUI.GetRenderer ("DarkRPFrame") (self)
		end
	end
	
	CInventory.ItemClasses:RequestItemClasses ()
	
	View = self
	return self
end)

datastream.Hook ("inventory_item_class", function (_, _, _, tbl)
	if not View or not View:IsValid () then return end
	if View.Selected ~= tbl.Name then return end
	tbl = tbl.Class
	View.ModelEntry:SetText (tbl.Model)
	View.ClassEntry:SetText (tbl.EntityClass)
	View.SkinEntry:SetText (tbl.Skin)
	View.Weight:SetValue (tbl.Weight)
	View.Stackable:SetChecked (tbl.Stackable)
end)