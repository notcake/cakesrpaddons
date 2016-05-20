local Client = {}
Client.__index = Client
CInventory.Client = CUtil.MakeConstructor (Client)

function Client:ctor (ply)
	CUtil.EventProvider (self)

	self.Player = ply
	self.Name = ply:Name ()
	self.SteamID = ply:SteamID ()
	
	self.LastUseTime = 0
	
	self.OpenInventories = {}
end

function Client:CanOpenInventory (id)
	id = id:lower ()
	if self:GetSteamID ():lower () == id then
		return true
	end
	if id == "shop" then
		return true
	end
	if CInventory.CanModifyInventories (self:GetPlayer ()) then
		if not file.Exists (CInventory.GetInventoryPath (id)) and
			not CInventory.Inventories:GetInventory (id) then
			return false, "No inventory with that ID exists"
		end
		return true
	end
	local inventory = CInventory.Inventories:GetInventory (id)
	if inventory and inventory:CanOpenInventory (self:GetSteamID ():lower ()) then
		return true
	end
	return false, "Access denied"
end

function Client:CanPressUse ()
	return CurTime () - self.LastUseTime > 1
end

function Client:CloseInventory (id)
	if not self:IsInventoryOpen (id) then
		return
	end
	local inventory = self.OpenInventories [id]
	inventory:RemoveEventListener ("ItemAdded", tostring (self))
	inventory:RemoveEventListener ("ItemCountChanged", tostring (self))
	inventory:RemoveEventListener ("ItemRemoved", tostring (self))
	inventory:RemoveEventListener ("WeightChanged", tostring (self))
	inventory:Release ()
	self.OpenInventories [id] = nil
end

function Client:GetName ()
	return self.Name
end

function Client:GetOpenInventoryIterator ()
	local next, tbl, key = pairs (self.OpenInventories)
	return function ()
		key = next (tbl, key)
		return tbl [key]
	end
end

function Client:GetPlayer ()
	return self.Player
end

function Client:GetSteamID ()
	return self.SteamID
end

function Client:IsInventoryOpen (id)
	return self.OpenInventories [id] and true or false
end

function Client:OnPressedUse ()
	self.LastUseTime = CurTime ()
end

function Client:OpenInventory (id)
	if self:IsInventoryOpen (id) then
		return self.OpenInventories [id]
	end
	if not self:CanOpenInventory (id) then
		return nil
	end
	local inventory = CInventory.LoadInventory (id)
	self.OpenInventories [id] = inventory
	
	inventory:AddEventListener ("ItemAdded", tostring (self), function (inventory, item)
		local tbl = {}
		tbl.ID = inventory:GetID ()
		tbl.Items = {item:ExportDatastream ()}
		datastream.StreamToClients (self:GetPlayer (), "inventory_items", tbl)
	end)
	
	inventory:AddEventListener ("ItemCountChanged", tostring (self), function (inventory, item)
		if item:GetCount () == 0 then
			return
		end
		local tbl = {}
		tbl.ID = inventory:GetID ()
		tbl.Items = {
			{
				ID = item:GetID (),
				Count = item:GetCount ()
			}
		}
		datastream.StreamToClients (self:GetPlayer (), "inventory_items", tbl)
	end)
	
	inventory:AddEventListener ("ItemRemoved", tostring (self), function (inventory, item)
		umsg.Start ("inventory_item_removed", self:GetPlayer ())
			umsg.String (inventory:GetID ())
			umsg.Long (item:GetID ())
		umsg.End ()
	end)
	
	inventory:AddEventListener ("WeightChanged", tostring (self), function (inventory)
		umsg.Start ("inventory_weight", self:GetPlayer ())
			umsg.String (inventory:GetID ())
			umsg.Float (inventory:GetWeight ())
			umsg.Float (inventory:GetMaximumWeight ())
			umsg.Float (inventory:GetMaximumWeightBonus ())
		umsg.End ()
	end)
	return inventory
end

function Client:Remove ()
	self:DispatchEvent ("Removed")
	
	local ids = {}
	for id, _ in pairs (self.OpenInventories) do
		ids [#ids + 1] = id
	end
	for _, id in ipairs (ids) do
		self:CloseInventory (id)
	end
end