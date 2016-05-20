include ("cgui.lua")
include ("inventory/ui/inventoryitem.lua")
include ("inventory/ui/inventoryview.lua")
include ("inventory/ui/inventorymenu.lua")
include ("inventory/ui/myinventoryview.lua")
include ("inventory/ui/settingsview.lua")
include ("inventory/ui/upgradeview.lua")
include ("inventory/ui/itemclassadditiondialog.lua")
include ("inventory/ui/itemclassmodificationdialog.lua")
include ("inventory/ui/itemadditiondialog.lua")
include ("inventory/ui/inventoryinspectiondialog.lua")

if CInventory.Menu then
	CInventory.Menu:Remove ()
end
CInventory.Menu = nil

-- Inventory
function CInventory.OpenInventory (id)
	if CInventory.Inventories:ContainsInventory (id) then
		local inventory = CInventory.Inventories:GetInventory (id)
		inventory:AddRef ()
		return inventory
	end
	local inventory = CInventory.Inventories:CreateInventory (id)
	inventory:Open ()
	return inventory
end

-- Menu
function CInventory.IsMenuOpen ()
	if CInventory.Menu and
		CInventory.Menu:IsValid () and
		CInventory.Menu:IsVisible () then
		return true
	end
	return false
end

function CInventory.CloseMenu ()
	if not CInventory.IsMenuOpen () then
		return
	end
	CInventory.Menu:Close ()
end

function CInventory.OpenMenu ()
	if CInventory.IsMenuOpen () then
		return
	end
	if not CInventory.Menu then
		CInventory.Menu = CGUI.CreateDialog ("InventoryMenu")
	end
	CInventory.Menu:ShowDialog ()
end

-- Menu keybinds
hook.Add ("PlayerBindPress", "Inventory", function (ply, bind, pressed)
	if bind == "jpeg" and pressed then
		if not input.IsKeyDown (KEY_LSHIFT) then
			RunConsoleCommand ("inventory_toggle")
			return true
		end
	end
end)

concommand.Add ("inventory_toggle", function (_, _, _)
	if not CInventory.IsMenuOpen () then
		CInventory.OpenMenu ()
	else
		CInventory.CloseMenu ()
	end
end)

concommand.Add ("inventory_close", function (_, _, _)
	CInventory.CloseMenu ()
end)

concommand.Add ("inventory_open", function (_, _, _)
	CInventory.OpenMenu ()
end)

-- Networking
datastream.Hook ("inventory_items", function (_, _, _, tbl)
	if not CInventory.Inventories:ContainsInventory (tbl.ID) then
		return
	end
	local inventory = CInventory.Inventories:GetInventory (tbl.ID)
	inventory:ImportDatastream (tbl)
end)

datastream.Hook ("inventory_item_added", function (_, _, _, tbl)
	if not CInventory.Inventories:ContainsInventory (tbl.ID) then
		return
	end
	local inventory = CInventory.Inventories:GetInventory (tbl.ID)
	inventory:ImportDatastream (tbl)
end)

usermessage.Hook ("inventory_item_actions", function (umsg)
	local id = umsg:ReadString ()
	if not CInventory.Inventories:ContainsInventory (id) then
		return
	end
	local inventory = CInventory.Inventories:GetInventory (id)
	local itemid = umsg:ReadLong ()
	local item = inventory:GetItem (itemid)
	if not item then
		return
	end
	item:ImportActionsUsermessage (umsg)
end)

usermessage.Hook ("inventory_item_removed", function (umsg)
	local id = umsg:ReadString ()
	if not CInventory.Inventories:ContainsInventory (id) then
		return
	end
	local inventory = CInventory.Inventories:GetInventory (id)
	local itemid = umsg:ReadLong ()
	inventory:RemoveItem (inventory:GetItem (itemid))
end)

usermessage.Hook ("inventory_weight", function (umsg)
	local id = umsg:ReadString ()
	if not CInventory.Inventories:ContainsInventory (id) then
		return
	end
	local inventory = CInventory.Inventories:GetInventory (id)
	inventory:SetWeight (umsg:ReadFloat ())
	inventory:SetMaximumWeight (umsg:ReadFloat ())
	inventory:SetMaximumWeightBonus (umsg:ReadFloat ())
end)