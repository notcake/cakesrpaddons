CGUI.RegisterDialog ("InventoryItemClassAdditionDialog", function ()
	local self = CGUI.CreateDialog ("BaseDialog")
	self:SetTitle ("Create Item Class...")
	self:SetTall (296)
	
	self.GeneratorLabel = vgui.Create ("DLabel", self)
	self.GeneratorLabel:SetText ("Choose the type of item class:")
	self.Generator = vgui.Create ("DMultiChoice", self)
	self.Generator:SetEditable (false)
	
	for generator, _ in CInventory.ItemClasses:GetItemClassGeneratorIterator () do
		self.Generator:AddChoice (generator)
	end
	function self.Generator.OnSelect (choice, index, value)
		self.Generator.Text = value
	end
	self.Generator:ChooseOptionID (1)
	
	self.NameLabel = vgui.Create ("DLabel", self)
	self.NameLabel:SetText ("Name:")
	self.NameEntry = vgui.Create ("DTextEntry", self)
	self.NameEntry:SetText ("Best Item Evar")
	
	self.ClassLabel = vgui.Create ("DLabel", self)
	self.ClassLabel:SetText ("Classname (eg. prop_physics):")
	self.ClassEntry = vgui.Create ("DTextEntry", self)
	self.ModelLabel = vgui.Create ("DLabel", self)
	self.ModelLabel:SetText ("Model (can leave blank):")
	self.ModelEntry = vgui.Create ("DTextEntry", self)
	self.ModelEntry:SetText ("*")
	self.SkinLabel = vgui.Create ("DLabel", self)
	self.SkinLabel:SetText ("Skin (can leave blank):")
	self.SkinEntry = vgui.Create ("DTextEntry", self)
	self.SkinEntry:SetText ("*")
	
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
	self.OK:SetText ("Create")
	self.OK:AddEventListener ("Click", function (button)
		datastream.StreamToServer ("inventory_create_item_class", {
			Generator = self.Generator.Text,
			Name = self.NameEntry:GetText (),
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
	
	self:AddLayouter (function (self)
		self:SetSkin ("DarkRP")
	
		local x, y = 8, 32
		self.GeneratorLabel:SetPos (x, y)
		self.GeneratorLabel:SizeToContents ()
		y = y + self.GeneratorLabel:GetTall () + 8
		self.Generator:SetPos (x + 8, y)
		self.Generator:SetWide (self:GetWide () * 0.5)
		y = y + self.Generator:GetTall () + 8
		
		self.NameLabel:SetPos (x, y)
		self.NameLabel:SizeToContents ()
		self.NameEntry:SetPos (self:GetWide () * 0.5, y)
		self.NameEntry:SetWide (self:GetWide () * 0.5 - 8)
		y = y + self.NameEntry:GetTall () + 8
		
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
	
	return self
end)