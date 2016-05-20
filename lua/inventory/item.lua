local Item = {}
Item.__index = Item
CInventory.Item = CUtil.MakeConstructor (Item)

--[[
	Events
	WeightChanged
	ActionsUpdated	- run on the client when the action list is received or RequestActionList is called
]]

function Item:ctor ()
	CUtil.EventProvider (self)

	self.Inventory = nil
	self.ID = nil

	self.ItemClass = nil
	self.ItemClassID = nil
	
	self.Weight = nil
	self.EntityClass = nil
	self.Model = nil
	self.Image = nil
	self.Skin = 0
	
	self.Equipped = false
	
	self.Price = nil
	self.Count = 1
	
	-- client only data
	if CLIENT then
		self.Actions = {}
		self.ActionsReceived = false
		self.Name = nil
	end
end

-- Networking
function Item:ExportDatastream ()
	local tbl = {}
	tbl.ID = self.ID
	tbl.Weight = self:GetWeight ()
	if self.Count ~= 1 then
		tbl.Count = self.Count
	end
	if self.Image then
		tbl.Image = self.Image
	else
		tbl.Model = self:GetModel ():sub (8)	-- No need to send "models/" at the beginning
		if self.Skin ~= 0 then
			tbl.Skin = self.Skin
		end
	end
	tbl.Equipped = self.Equipped
	tbl.Price = self.Price
	tbl.Name = self.ItemClass and self.ItemClass:GetItemName (self) or self.ItemClassID
	return tbl
end

function Item:ExportFile ()
	local tbl = {}
	tbl.ID = self.ID
	tbl.Count = self.Count
	tbl.EntityClass = self.EntityClass
	tbl.Model = self.Model
	tbl.Skin = self.Skin
	tbl.Image = self.Image
	tbl.Weight = self:GetWeight ()
	tbl.Equipped = self.Equipped
	
	tbl.Price = self.Price
	
	tbl.ItemClassID = self.ItemClassID
	
	if self.ItemClass then
		self.ItemClass:ExportItemFile (self, tbl)
	end
	return tbl
end

function Item:ImportActionsUsermessage (umsg)
	self.Actions = {}
	
	local action = umsg:ReadString ()
	while action and action ~= "" do
		self.Actions [action:lower ()] = true
		action = umsg:ReadString ()
	end
	self.ActionsReceived = true
	self:DispatchEvent ("ActionsUpdated")
end

function Item:ImportDatastream (tbl)
	self.ID = tbl.ID or self.ID
	self.Weight = tbl.Weight or self.Weight
	if tbl.Count and tbl.Count ~= self.Count then
		self.Count = tbl.Count
		self:DispatchEvent ("CountChanged")
	end
	if tbl.Model then
		self.Model = "models/" .. tbl.Model
	end
	self.Skin = tbl.Skin or self.Skin
	self.Image = tbl.Image or self.Image
	self.Price = tbl.Price or self.Price
	self.Equipped = tbl.Equipped or self.Equipped
	
	self:DispatchEvent ("Updated")
	
	self.Name = tbl.Name or self.Name
end

function Item:ImportFile (tbl)
	self.ID = tbl.id or tbl.ID or self.ID
	self.Count = tbl.count or tbl.Count or self.Count
	self.EntityClass = tbl.entityclass or tbl.EntityClass or self.EntityClass
	self.Model = tbl.model or tbl.Model or self.Model
	self.Skin = tbl.skin or tbl.Skin or self.Skin
	self.Image = tbl.image or tbl.Image or self.Image
	
	self:SetEquipped (tobool (tbl.equipped))
	
	self.ItemClassID = tbl.itemclassid or tbl.ItemClassID or self.ItemClassID
	self.ItemClass = CInventory.ItemClasses:GetItemClass (self.ItemClassID)
	
	self.Price = tbl.price or tbl.Price or self.Price
	
	if self.ItemClass then
		self.ItemClass:ImportItemFile (self, tbl)
	else
		self.Weight = tbl.weight or tbl.Weight or self.Weight
	end
end

function Item:AddCount (count)
	self.Count = self.Count + count
	self:DispatchEvent ("CountChanged")
	self:DispatchEvent ("WeightChanged")
	
	if self:GetItemClass () then
		self:GetItemClass ():OnItemAddedToInventory (self:GetInventory (), self, count)
	end
end

function Item:CanPlayerPickUp (ply)
	return self.ItemClass:CanPlayerPickUp (self, ply)
end

function Item:CanRunAction (ply, action)
	if not self.ItemClass then
		if self.Actions then
			return self.Actions [action:lower ()] and true or false
		end
		return false
	end
	return self.ItemClass:CanRunAction (ply, self:GetInventory (), self, action)
end

function Item:CanStack ()
	if self.ItemClass then
		return self.ItemClass:IsStackable ()
	end
	return false
end

function Item:GetCount ()
	return self.Count
end

function Item:GetEntityClass ()
	if self.EntityClass then
		return self.EntityClass
	end
	if self.ItemClass then
		return self.ItemClass:GetEntityClass ()
	end
end

function Item:GetID (id)
	return self.ID
end

function Item:GetImage ()
	return self.Image
end

function Item:GetInventory ()
	return self.Inventory
end

function Item:GetItemClass ()
	return self.ItemClass
end

function Item:GetItemClassID ()
	return self.ItemClassID
end

function Item:GetModel ()
	if self.Model then
		return self.Model
	end
	if self.ItemClass then
		return self.ItemClass:GetModel ()
	end
	return ""
end

function Item:GetName ()
	if self.Name then
		return self.Name
	end
	if self.ItemClass then
		return self.ItemClass:GetItemName (self)
	end
	return self.ItemClassID or "Unknown"
end

function Item:GetSkin ()
	return self.Skin
end

function Item:GetTotalWeight ()
	return self:GetCount () * self:GetWeight ()
end

function Item:GetWeight ()
	if self.Weight then
		return self.Weight
	end
	if not self.ItemClass then
		return 0
	end
	return self.ItemClass:GetWeight (self)
end

function Item:IsEquipped ()
	return self.Equipped
end

function Item:RemoveCount (count)
	self.Count = self.Count - count
	self:DispatchEvent ("CountChanged")
	self:DispatchEvent ("WeightChanged")
	
	if self:GetItemClass () then
		self:GetItemClass ():OnItemRemovedFromInventory (self:GetInventory (), self, count)
	end
	
	if self.Count == 0
		and self.Inventory then
		self.Inventory:RemoveItem (self)
	end
end

if CLIENT then
	function Item:RequestActionList ()
		if self.ActionsReceived then
			self:DispatchEvent ("ActionsUpdated")
		end
		RunConsoleCommand ("_inventory_request_actions", self.Inventory:GetID (), tostring (self:GetID ()))
	end
end

function Item:RunAction (ply, action)
	if not self.ItemClass then
		return
	end
	return self.ItemClass:RunAction (ply, self:GetInventory (), self, action)
end

function Item:SetCount (count)
	if self.Count == count then
		return
	end
	local delta = count - self.Count
	self.Count = count
	self:DispatchEvent ("CountChanged")
	self:DispatchEvent ("WeightChanged")
	
	if self:GetItemClass () then
		if delta > 0 then
			self:GetItemClass ():OnItemAddedToInventory (self:GetInventory (), self, delta)
		else
			self:GetItemClass ():OnItemRemovedFromInventory (self:GetInventory (), self, -delta)
		end
	end
end

function Item:SetEntityClass (class)
	self.EntityClass = class
end

function Item:SetEquipped (equipped)
	if self.Equipped == equipped then
		return
	end
	self.Equipped = equipped
end

function Item:SetID (id)
	self.ID = id
end

function Item:SetInventory (inventory)
	if self.Inventory == inventory then
		return
	end
	if self.Inventory then
		self.Inventory:RemoveItem (self)
	end
	if self.ItemClass then
		if inventory then
			self.ItemClass:OnItemAddedToInventory (inventory, self, self:GetCount ())
		else
			self.ItemClass:OnItemRemovedFromInventory (self.Inventory, self, self:GetCount ())
		end
	end
	self.Inventory = inventory
end

function Item:SetItemClass (class)
	if self.ItemClass == class then
		return
	end
	self.ItemClass = class
	self.ItemClassID = class and class:GetName () or nil
	if class then
		class:SetUpItem (self)
	end
end

function Item:SetModel (model)
	self.Model = model
end

function Item:SetSkin (skin)
	self.Skin = skin
end