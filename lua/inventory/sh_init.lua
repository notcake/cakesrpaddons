include ("cutil.lua")
CInventory = CInventory or {}

include ("inventory/player_extension.lua")

include ("inventory/inventory.lua")
include ("inventory/inventorycollection.lua")
include ("inventory/item.lua")

-- Actions
include ("inventory/action.lua")
include ("inventory/actioncollection.lua")
CInventory.Actions = CInventory.ActionCollection ()

for _, v in ipairs (file.FindInLua ("inventory/actions/*.lua")) do
	AddCSLuaFile ("inventory/actions/" .. v)
	include ("inventory/actions/" .. v)
end

-- Item classes
include ("inventory/itemclass.lua")
include ("inventory/itemclassgenerator.lua")
include ("inventory/itemclasscollection.lua")
CInventory.ItemClasses = CInventory.ItemClassCollection ()

local AddCSLuaFile = AddCSLuaFile or function () end
for _, v in ipairs (file.FindInLua ("inventory/itemclasses/*.lua")) do
	AddCSLuaFile ("inventory/itemclasses/" .. v)
	include ("inventory/itemclasses/" .. v)
end
for _, v in ipairs (file.FindInLua ("inventory/itemclassgenerators/*.lua")) do
	AddCSLuaFile ("inventory/itemclassgenerators/" .. v)
	include ("inventory/itemclassgenerators/" .. v)
end

if CInventory.Inventories then
	CInventory.Inventories:RemoveAll ()
end
if CInventory.SaveSettings then
	CInventory.SaveSettings ()
end
CInventory.Inventories = CInventory.InventoryCollection ()

CInventory.DefaultItemWeight = 10
CInventory.DefaultMaximumWeight = 100
if CInventory.Unsaved == nil then
	CInventory.Unsaved = false
end

function CInventory.CanModifyInventories (ply)
	return ply:IsSuperAdmin ()
end

function CInventory.CanModifySettings (ply)
	return ply:IsSuperAdmin ()
end

function CInventory.GetDefaultMaximumWeight ()
	return CInventory.DefaultMaximumWeight
end

function CInventory.GetDefaultItemWeight ()
	return CInventory.DefaultItemWeight
end