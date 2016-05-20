--[[
	Internal Console Commands
		_inventory_open				- run when the player opens an inventory, used to hook events and causes the server to send the whole inventory
			string ID
		_inventory_close			- run when the player closes an inventory, used to unhook events
			string ID
		_inventory_inspect			- run when an admin wants to modify and inventory
			string ID
		_inventory_request_actions	- requests a list of valid actions for the specified item
			string InventoryID
			long ItemID
		_inventory_remove_item
			string InventoryID
			long ItemID
		_inventory_set_count
			string InventoryID
			long ItemID
			long Count
			
	Client to Server Datastreams
		inventory_add_item
			string InventoryID
			string ItemClass
			long Quantity
			
	Server to Client Datastreams
		inventory_items
			[Items]
				
	Usermessages
		inventory_inspection_response
			string ID					- inventory ID
			string Error				- empty string on success
		inventory_item_actions
			string InventoryID
			long ItemID
			string Action1
			string Action2
			...
			string Terminator			- empty string
		inventory_item_removed
			string InventoryID
			long ItemID
		inventory_settings
			float MaximumWeight			- default maximum weight for inventories
		inventory_weight
			string ID
			float Weight				- total weight of items in the inventory
			float MaximumWeight			- maximum weight of the inventory
			float MaximumWeightBonus	- how much of that maximum is from bonuses
]]
resource.AddFile ("materials/gui/silkicons/basket.vmt")
resource.AddFile ("materials/gui/silkicons/basket.vtf")
AddCSLuaFile ("inventory/inventory.lua")
AddCSLuaFile ("inventory/inventorycollection.lua")
AddCSLuaFile ("inventory/item.lua")
AddCSLuaFile ("inventory/itemclass.lua")
AddCSLuaFile ("inventory/itemclassgenerator.lua")
AddCSLuaFile ("inventory/itemclasscollection.lua")
AddCSLuaFile ("inventory/action.lua")
AddCSLuaFile ("inventory/actioncollection.lua")
AddCSLuaFile ("inventory/player_extension.lua")
AddCSLuaFile ("inventory/ui/inventoryitem.lua")
AddCSLuaFile ("inventory/ui/inventoryview.lua")
AddCSLuaFile ("inventory/ui/inventorymenu.lua")
AddCSLuaFile ("inventory/ui/myinventoryview.lua")
AddCSLuaFile ("inventory/ui/settingsview.lua")
AddCSLuaFile ("inventory/ui/upgradeview.lua")
AddCSLuaFile ("inventory/ui/itemclassadditiondialog.lua")
AddCSLuaFile ("inventory/ui/itemclassmodificationdialog.lua")
AddCSLuaFile ("inventory/ui/itemadditiondialog.lua")
AddCSLuaFile ("inventory/ui/inventoryinspectiondialog.lua")
include ("inventory/client.lua")
include ("inventory/clientcollection.lua")
include ("inventory/entity_extension.lua")
CInventory.Clients = CInventory.ClientCollection ()
CInventory.ItemClasses:LoadClasses ()
CInventory.ItemClasses:AddEventListener ("WeightChanged", function ()
	for _, inventory in CInventory.Inventories:GetInventoryIterator () do
		inventory:RecalculateWeight ()
	end
end)

function CInventory.GetInventoryPath (id)
	return "inventory/" .. id:gsub ("[:/\\]", "_") .. ".txt"
end

function CInventory.LoadInventory (id)
	if CInventory.Inventories:ContainsInventory (id) then
		local inventory = CInventory.Inventories:GetInventory (id)
		inventory:AddRef ()
		return inventory
	end
	local inventory = CInventory.Inventories:CreateInventory (id)
	inventory:Load (CInventory.GetInventoryPath (id))
	return inventory
end

function CInventory.MessagePlayer (ply, text)
	if not ply or not ply:IsValid () then
		return
	end
	if TalkToPerson then
		TalkToPerson (ply, Color (255, 128, 128, 255), text)
	else
		ply:PrintMessage (HUD_PRINTTALK, text)
	end
end

function CInventory.SetDefaultMaximumWeight (weight)
	CInventory.DefaultMaximumWeight = weight
	CInventory.Unsaved = true
	
	for id, inventory in CInventory.Inventories:GetInventoryIterator () do
		inventory:DispatchEvent ("WeightChanged")
	end
end

-- Settings serialization
function CInventory.LoadSettings ()
	local data = file.Read ("inventory/settings/settings.txt")
	if not data then return end
	local tbl = util.KeyValuesToTable (data)
	CInventory.SetDefaultMaximumWeight (tbl.defaultmaximumweight or tbl.DefaultMaximumWeight or 100)
	CInventory.Unsaved = false
end

function CInventory.SaveSettings ()
	if not CInventory.Unsaved then
		return
	end
	local tbl = {}
	tbl.DefaultMaximumWeight = CInventory.GetDefaultMaximumWeight ()
	file.Write ("inventory/settings/settings.txt", util.TableToKeyValues (tbl))
end

-- Initialize
CInventory.LoadSettings ()
CInventory.Clients:Initialize ()

hook.Add ("PlayerSay", "CInventory", function (ply, text, teamonly)
	text = text:lower ():Trim ()
	if text == "/inv" or text == "!inv" then
		ply:ConCommand ("inventory_toggle")
		return ""
	elseif text == "/holster" or text == "!holster" then
		ply:ConCommand ("_inventory_holster")
		return ""
	end
end)

hook.Add ("PlayerUse", "CInventory", function (ply, ent)
	local client = CInventory.Clients:GetClient (ply)
	if ply:KeyDown (IN_SPEED) then
		if not client:CanPressUse () then
			return false
		end
		client:OnPressedUse ()
		
		local inventory = client:OpenInventory (ply:SteamID ())
		local item = CInventory.ItemClasses:CreateItemFromEntity (ent)
		if not item or not item:CanPlayerPickUp (ply) then
			CInventory.MessagePlayer (ply, "You can't pick that item up!")
			return false
		end
		if ent.CanPlayerPickUp and not ent:CanPlayerPickUp (ply) then
			CInventory.MessagePlayer (ply, "You can't pick that item up!")
			return false		
		end
		if not inventory:CanAddWeight (item:GetTotalWeight ()) then
			CInventory.MessagePlayer (ply, "Your inventory is too full to hold that item!")
			return false
		end
		local isowner = true
		if ent.CPPIGetOwner and
			ent:CPPIGetOwner () then
			isowner = false
			local owner = ent:CPPIGetOwner ()
			if not owner or owner == ply then
				isowner = true
			end
		end
		if not isowner then
			if ent.dt and ent.dt.owning_ent then
				isowner = ent.dt.owning_ent == ply
			end
		end
		if not isowner then
			CInventory.MessagePlayer (ply, "You don't own that item!")
			return false
		end
		inventory:AddItem (item)
		CInventory.MessagePlayer (ply, "You put the " .. item:GetName () .. " into your inventory.")
		ent:Remove ()
		return false
	end
end)

hook.Add ("ShutDown", "CInventory", function ()
	if CInventory.Inventories then
		CInventory.Inventories:RemoveAll ()
	end
	CInventory.SaveSettings ()
end)

concommand.Add ("_inventory_open", function (ply, _, args)
	if #args < 1 then
		return
	end
	local client = CInventory.Clients:GetClient (ply)
	local inventory = client:OpenInventory (args [1])
	
	if not inventory then
		return
	end
	datastream.StreamToClients (ply, "inventory_items", inventory:ExportDatastream ())
end)

concommand.Add ("_inventory_close", function (ply, _, args)
	if #args < 1 then
		return
	end
	local client = CInventory.Clients:GetClient (ply)
	client:CloseInventory (args [1])
end)

concommand.Add ("_inventory_action", function (ply, _, args)
	if #args < 3 then
		return
	end
	local client = CInventory.Clients:GetClient (ply)
	if not client:IsInventoryOpen (args [1]) then
		return
	end
	local inventory = CInventory.Inventories:GetInventory (args [1])
	local item = inventory:GetItem (tonumber (args [2]))
	if not item then
		return
	end
	if item:CanRunAction (ply, args [3]) then
		item:RunAction (ply, args [3])
	end
end)

concommand.Add ("_inventory_remove_class", function (ply, _, args)
	if not CInventory.CanModifySettings (ply) then
		return
	end
	CInventory.ItemClasses:RemoveItemClass (args [1])
end)

concommand.Add ("_inventory_request_classes", function (ply, _, _)
	if not CInventory.CanModifySettings (ply) then
		return
	end
	local tbl = {}
	tbl.Classes = {}
	for class, _ in CInventory.ItemClasses:GetItemClassIterator () do
		tbl.Classes [#tbl.Classes + 1] = class
	end
	datastream.StreamToClients (ply, "inventory_item_classes", tbl)
end)

concommand.Add ("_inventory_request_item_class", function (ply, _, args)
	if not CInventory.CanModifySettings (ply) then
		return
	end
	if #args < 1 then
		return
	end
	local class = CInventory.ItemClasses:GetItemClass (args [1])
	if not class then
		return
	end
	local tbl = {}
	tbl.Name = args [1]
	tbl.Class = class:ExportDatastream ()
	datastream.StreamToClients (ply, "inventory_item_class", tbl)
end)

concommand.Add ("_inventory_request_settings", function (ply, _, _)
	if not CInventory.CanModifySettings (ply) then
		return
	end
	umsg.Start ("inventory_settings", ply)
		umsg.Float (CInventory.GetDefaultMaximumWeight ())
	umsg.End ()
end)

concommand.Add ("_inventory_set_max_weight", function (ply, _, args)
	if not CInventory.CanModifySettings (ply) then
		return
	end
	if #args < 1 then
		return
	end
	local weight = tonumber (args [1])
	if not weight then
		return
	end
	CInventory.SetDefaultMaximumWeight (weight)
end)

concommand.Add ("_inventory_buy_space", function (ply, _, args)
	local inventory = CInventory.Inventories:GetInventory (ply:SteamID ())
	if not inventory then
		return
	end
	local item = inventory:FindItem ("Small Inventory Expansion")
	local canbuy = false
	if not item or item:GetCount () < 4 then
		canbuy = true
	end
	if ply.CanAfford then
		if not ply:CanAfford (1000) then
			canbuy = false
		end
		ply:AddMoney (-1000)
	end
	if canbuy then
		local item = CInventory.Item ()
		item:SetItemClass (CInventory.ItemClasses:GetItemClass ("Small Inventory Expansion"))
		inventory:AddItem (item)
	end
end)

concommand.Add ("_inventory_holster", function (ply)
	local inventory = CInventory.Inventories:GetInventory (ply:SteamID ())
	if not inventory then
		return
	end
	local weapon = ply:GetActiveWeapon ()
	if not weapon or not weapon:IsValid () then
		return
	end
	local classes = CInventory.ItemClasses:FindClassesForClass (CInventory.ItemClasses.EntityClasses, "spawned_weapon", weapon:GetModel (), weapon:GetSkin ())
	for k, v in pairs (classes) do
		if v:MatchesEntity (weapon) then
			local item = CInventory.ItemClasses:CreateItemFromEntity (weapon, v)
			if inventory:CanAddItem (item) then
				inventory:AddItem (item)
				weapon:Remove ()
			else
				CInventory.MessagePlayer (ply, "Your inventory is too full.")
			end
			break
		end
	end
end)

concommand.Add ("_inventory_request_actions", function (ply, _, args)
	if #args < 2 then
		return
	end
	local client = CInventory.Clients:GetClient (ply)
	if not client:IsInventoryOpen (args [1]) then
		return
	end
	local inventory = CInventory.Inventories:GetInventory (args [1])
	local item = inventory:GetItem (tonumber (args [2]))
	if not item then
		return
	end
	local actions = {}
	if item:GetItemClass () then
		for action, _ in item:GetItemClass ():GetActionIterator () do
			actions [#actions + 1] = action
		end
	end
	umsg.Start ("inventory_item_actions", ply)
		umsg.String (inventory:GetID ())
		umsg.Long (item:GetID ())
		for _, action in ipairs (actions) do
			umsg.String (action)
		end
		umsg.String ("")
	umsg.End ()
end)

-- Administration
concommand.Add ("_inventory_inspect", function (ply, _, args)
	if #args < 1 then
		return
	end
	local client = CInventory.Clients:GetClient (ply)
	local canopen, error = client:CanOpenInventory (args [1])
	umsg.Start ("inventory_inspection_response", ply)
		umsg.String (args [1])
		if canopen then
			umsg.String ("")
		else
			umsg.String (error)
		end
	umsg.End ()
end)

datastream.Hook ("inventory_add_item", function (ply, _, _, _, tbl)
	if not CInventory.CanModifyInventories (ply) then
		return
	end
	local client = CInventory.Clients:GetClient (ply)
	if not client:IsInventoryOpen (tbl.InventoryID) then
		return
	end
	local inventory = CInventory.Inventories:GetInventory (tbl.InventoryID)
	if tbl.Model == "" then
		tbl.Model = nil
	end
	local itemclass = CInventory.ItemClasses:GetItemClass (tbl.ItemClass)
	if not itemclass then
		return
	end
	local count = tonumber (tbl.Count)
	if not count or count < 0 then
		return
	end
	local item = CInventory.Item ()
	item:SetItemClass (itemclass)
	item:SetCount (count)
	inventory:AddItem (item)
end)

concommand.Add ("_inventory_remove_item", function (ply, _, args)
	if #args < 2 then
		return
	end
	if not CInventory.CanModifyInventories (ply) then
		return
	end
	local client = CInventory.Clients:GetClient (ply)
	if not client:IsInventoryOpen (args [1]) then
		return
	end
	local inventory = CInventory.Inventories:GetInventory (args [1])
	local item = inventory:GetItem (tonumber (args [2]))
	if not item then
		return
	end
	inventory:RemoveItem (item)
end)

concommand.Add ("_inventory_set_count", function (ply, _, args)
	if #args < 3 then
		return
	end
	if not CInventory.CanModifyInventories (ply) then
		return
	end
	local client = CInventory.Clients:GetClient (ply)
	if not client:IsInventoryOpen (args [1]) then
		return
	end
	local inventory = CInventory.Inventories:GetInventory (args [1])
	local item = inventory:GetItem (tonumber (args [2]))
	if not item then
		return
	end
	local count = tonumber (args [3])
	if not count then
		return
	end
	count = math.floor (count)
	if count < 0 then
		count = 1
	end
	item:SetCount (count)
end)