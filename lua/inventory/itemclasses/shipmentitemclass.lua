local ShipmentItemClass = {}
ShipmentItemClass.__index = ShipmentItemClass
setmetatable (ShipmentItemClass, CInventory.ItemClass)
CInventory.ShipmentItemClass = CUtil.MakeConstructor (ShipmentItemClass)

function ShipmentItemClass:ctor (name, parameters)
	CInventory.ItemClass.ctor (self, name, parameters)
	
	self:RegisterAction ("Drop", "ShipmentDrop")
end

function ShipmentItemClass:ExportItemFile (item, tbl)
	tbl.Amount = item.Amount
end

function ShipmentItemClass:ImportItemFile (item, tbl)
	item.Amount = tbl.Amount or tbl.amount or 10
end

function ShipmentItemClass:GetEntityClass ()
	return "spawned_shipment"
end

function ShipmentItemClass:MatchesEntity (ent)
	local shipment = CustomShipments [ent.dt.contents]
	if not shipment then
		return false
	end
	return self.EntityClass:lower () == shipment.entity:lower () or
			self.EntityClass:lower () == ent:GetClass ():lower ()
end

function ShipmentItemClass:SetUpItem (item)
	if not item.EntityClass then
		item.EntityClass = self.EntityClass
	end
	if not item.Model then
		item.Model = "models/items/item_item_crate.mdl"
	end
	if not item.Amount then
		item.Amount = 10
	end
end

function ShipmentItemClass:SetUpItemFromEntity (item, ent)
	if ent:GetClass () == "spawned_shipment" then
		item.WeaponClass = CustomShipments [ent.dt.contents].entity
		item.EntityClass = CustomShipments [ent.dt.contents].entity
	else
		item.WeaponClass = ent:GetClass ()
		item.EntityClass = ent:GetClass ()
	end
	item.Amount = ent.dt.count
end