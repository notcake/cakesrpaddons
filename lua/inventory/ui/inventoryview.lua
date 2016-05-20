--[[
	Events
	ItemSelected (control, item)
	ItemDeselected (control, item)
]]

CGUI.RegisterView ("InventoryView", function ()
	local self = CGUI.CreateControl ("BasePanel")
	self.Inventory = nil
	self.Selected = nil
	
	self.Items = vgui.Create ("DPanelList", self)
	self.Items:SetPos (0, 0)
	self.Items:EnableVerticalScrollbar (true)
	
	self.ItemsByID = {}
	
	self:AddLayouter (function (self)
		self.Items:SetSize (self:GetWide (), self:GetTall ())
	end)
	
	function self:AddInventoryItem (item)
		local ctrl = CGUI.CreateControl ("InventoryItem", item)
		ctrl:AddEventListener ("Selected", function (ctrl)
			if self.Selected == ctrl then
				return
			end
			if self.Selected and self.Selected:IsValid () then
				self:DispatchEvent ("ItemDeselected", self.Selected, self.Selected:GetItem ())
				self.Selected:Deselect ()
			end
			self.Selected = ctrl
			self:DispatchEvent ("ItemSelected", ctrl, ctrl:GetItem ())
		end)
		self.Items:AddItem (ctrl)
		self.ItemsByID [item:GetID ()] = ctrl
	end
	
	function self:CloseInventory ()
		if self.Selected and self.Selected:IsValid () then
			self:DispatchEvent ("ItemDeselected", self.Selected, self.Selected:GetItem ())
		end
		self.Selected = nil
		self.Items:Clear ()
		if self.Inventory then
			self.Inventory:RemoveEventListener ("ItemAdded", tostring (self))
			self.Inventory:RemoveEventListener ("ItemRemoved", tostring (self))
			self.Inventory:RemoveEventListener ("WeightChanged", tostring (self))
			self.Inventory:Release ()
			self.Inventory = nil
		end
	end
	
	function self:GetInventory ()
		return self.Inventory
	end
	
	function self:GetSelectedItem ()
		return self.Selected
	end
	
	function self:OpenInventory (id)
		if self.Inventory then
			self:CloseInventory ()
		end
		self.Inventory = CInventory.OpenInventory (id)
		for item in self.Inventory:GetItemIterator () do
			self:AddInventoryItem (item)
		end
		self.Inventory:AddEventListener ("ItemAdded", tostring (self), function (inventory, item)
			self:AddInventoryItem (item)
		end)
		self.Inventory:AddEventListener ("ItemRemoved", tostring (self), function (inventory, item)
			local ctrl = self.ItemsByID [item:GetID ()]
			self.Items:RemoveItem (ctrl)
			if self.Selected == ctrl then
				self:DispatchEvent ("ItemDeselected", ctrl, ctrl:GetItem ())
				self.Selected = nil
			end
			self.ItemsByID [item:GetID ()] = nil
		end)
		self.Inventory:AddEventListener ("WeightChanged", tostring (self), function (inventory)
			self:DispatchEvent ("WeightChanged", inventory)
		end)
	end
	
	function self:RunItemAction (action)
		if not self.Selected or not self.Selected:IsValid () then
			return
		end
		RunConsoleCommand ("_inventory_action", self.Inventory:GetID (), self.Selected:GetItem ():GetID (), action)
	end
	
	function self:Paint ()
		draw.RoundedBox (4, 0, 0, self:GetWide (), self:GetTall (), Color (64, 64, 64, 255))
	end
	
	self:PerformLayout ()
	return self
end)