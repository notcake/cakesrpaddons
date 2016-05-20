local InventoryCollection = {}
InventoryCollection.__index = InventoryCollection
CInventory.InventoryCollection = CUtil.MakeConstructor (InventoryCollection)

function InventoryCollection:ctor ()
	self.Inventories = {}
end

function InventoryCollection:AddInventory (inventory)
	self.Inventories [inventory:GetID ():lower ()] = inventory
	inventory:AddEventListener ("Unloaded", function (inventory)
		if CLIENT then
			RunConsoleCommand ("_inventory_close", inventory:GetID ())
		end
		self:RemoveInventory (inventory:GetID ())
	end)
end

function InventoryCollection:CreateInventory (id)
	local inventory = CInventory.Inventory ()
	inventory:SetID (id)
	self:AddInventory (inventory)
	return inventory
end

function InventoryCollection:ContainsInventory (id)
	return self.Inventories [id:lower ()] and true or false
end

function InventoryCollection:GetInventory (id)
	return self.Inventories [id:lower ()]
end

function InventoryCollection:GetInventoryIterator ()
	local next, tbl, key = pairs (self.Inventories)
	return function ()
		key = next (tbl, key)
		return key, tbl [key]
	end
end

if CLIENT then
	function InventoryCollection:GetLocalInventory ()
		return self:GetInventory (SinglePlayer () and "STEAM_0:0:0" or LocalPlayer ():SteamID ())
	end
end

function InventoryCollection:RecalculateWeights ()
	for k, v in pairs (self.Inventories) do
		v:RecalculateWeight ()
	end
end

function InventoryCollection:RemoveAll ()
	for _, inventory in pairs (self.Inventories) do
		inventory:Save ()
	end
	self.Inventories = {}
end

function InventoryCollection:RemoveInventory (id)
	self.Inventories [id:lower ()] = nil
end