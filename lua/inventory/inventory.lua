local Inventory = {}
Inventory.__index = Inventory
CInventory.Inventory = CUtil.MakeConstructor (Inventory)

--[[
	Events
	
	ItemAdded
	ItemCountChanged
	ItemRemoved
	WeightChanged
]]

function Inventory:ctor (id)
	CUtil.EventProvider (self)
	self.RefCount = 1
	self.ID = id
	self.SavePath = nil

	self.Owner = nil
	self.OwnerName = "Server"
	self.OwnerID = nil
	
	self.Items = {}	
	self.ItemCount = 0
	self.MaximumWeight = nil		-- client only
	self.MaximumWeightBonus = 0
	self.Weight = 0
end

-- Reference counting
function Inventory:AddRef ()
	self.RefCount = self.RefCount + 1
end

function Inventory:Release ()
	self.RefCount = self.RefCount - 1
	if self.RefCount == 0 then
		self:DispatchEvent ("Unloaded")
		self:Save ()
	end
end

-- Clientside stuff
function Inventory:Close ()
	RunConsoleCommand ("_inventory_close", self:GetID ())
end

function Inventory:Open ()
	RunConsoleCommand ("_inventory_open", self:GetID ())
end

-- Networking
function Inventory:ExportDatastream ()
	local tbl = {}
	tbl.ID = self.ID
	tbl.Items = {}
	for _, v in pairs (self.Items) do
		tbl.Items [#tbl.Items + 1] = v:ExportDatastream ()
	end
	tbl.Weight = self:GetWeight ()
	tbl.MaximumWeight = self:GetMaximumWeight ()
	tbl.MaximumWeightBonus = self:GetMaximumWeightBonus ()
	return tbl
end

function Inventory:ExportFile ()
	local tbl = {}
	tbl.ID = self.ID
	tbl.Items = {}
	for _, v in pairs (self.Items) do
		tbl.Items [#tbl.Items + 1] = v:ExportFile ()
	end
	return tbl
end

function Inventory:ImportDatastream (tbl)
	for _, v in pairs (tbl.Items) do
		local item = self:GetItem (v.ID)
		if item then
			item:ImportDatastream (v)
		else
			item = CInventory.Item ()
			item:ImportDatastream (v)
			self:AddItem (item)
		end
	end
	if tbl.Weight and self.Weight ~= tbl.Weight then
		self.Weight = tbl.Weight
		self:DispatchEvent ("WeightChanged")
	end
	if tbl.MaximumWeight and self.MaximumWeight ~= tbl.MaximumWeight then
		self.MaximumWeight = tbl.MaximumWeight
		self:DispatchEvent ("WeightChanged")
	end
	if tbl.MaximumWeightBonus and self.MaximumWeightBonus ~= tbl.MaximumWeightBonus then
		self.MaximumWeightBonus = tbl.MaximumWeightBonus
		self:DispatchEvent ("WeightChanged")
	end
	self:RecalculateWeight ()
	return tbl
end

function Inventory:ImportFile (tbl)
	for _, v in pairs (tbl.items or tbl.Items or {}) do
		local item = CInventory.Item ()
		item:ImportFile (v)
		self:AddItem (item)
	end
end

-- General functions
function Inventory:AddItem (item)
	if self:ContainsItem (item) then
		return
	end
	local stack = false
	local stackitem = item
	if item:CanStack () then
		for _, v in pairs (self.Items) do
			if v:GetItemClass () == item:GetItemClass () then
				stack = true
				stackitem = v
				break
			end
		end
	end
	if stack then
		stackitem:AddCount (item:GetCount ())
	else
		item:SetInventory (self)
		item:SetID (self:GetNextItemID ())
		self.Items [item:GetID ()] = item
		self.ItemCount = self.ItemCount + 1
		item:AddEventListener ("CountChanged", tostring (self), function (item)
			self:DispatchEvent ("ItemCountChanged", item)
		end)
		self:DispatchEvent ("ItemAdded", item)
	end
	self.Weight = self.Weight + item:GetTotalWeight ()
	self:DispatchEvent ("ItemCountChanged", stackitem)
	self:DispatchEvent ("WeightChanged")
end

function Inventory:AddMaximumWeightBonus (weight)
	self.MaximumWeightBonus = self.MaximumWeightBonus + weight
	self:DispatchEvent ("WeightChanged")
end

function Inventory:CanAddItem (item)
	return self:CanAddWeight (item:GetTotalWeight ())
end

function Inventory:CanAddWeight (weight)
	return self:GetMaximumWeight () - self:GetWeight () >= weight
end

function Inventory:CanOpenInventory (steamid)
	return false
end

function Inventory:ContainsItem (item)
	return self.Items [item:GetID ()] == item and true or false
end

function Inventory:FindItem (name)
	name = name:lower ()
	for item in self:GetItemIterator () do
		if item:GetName ():lower () == name then
			return item
		end
	end
	return nil
end

function Inventory:GetID ()
	return self.ID
end

function Inventory:GetItem (id)
	return self.Items [id]
end

function Inventory:GetItemCount (id)
	return self.ItemCount
end

function Inventory:GetItemIterator ()
	local next, tbl, key = pairs (self.Items)
	return function ()
		key = next (tbl, key)
		return tbl [key]
	end
end

function Inventory:GetMaximumWeightBonus ()
	return self.MaximumWeightBonus
end

function Inventory:GetMaximumWeight ()
	return self.MaximumWeight or (CInventory.GetDefaultMaximumWeight () + self:GetMaximumWeightBonus ())
end

function Inventory:GetNextItemID ()
	return #self.Items + 1
end

function Inventory:GetOwnerEntity ()
	if not self.Owner or not self.Owner:IsValid () then
		return nil
	end
	return self.Owner
end

function Inventory:GetOwnerID ()
	return self.OwnerID
end

function Inventory:GetOwnerName ()
	return self.OwnerName
end

function Inventory:GetWeight ()
	return self.Weight
end

function Inventory:RecalculateWeight ()
	self.Weight = 0
	for _, item in pairs (self.Items) do
		self.Weight = self.Weight + item:GetTotalWeight ()
	end
	self:DispatchEvent ("WeightChanged")
end

function Inventory:RemoveItem (item)
	if not self:ContainsItem (item) then
		return
	end
	item:RemoveEventListener ("CountChanged", tostring (self))
	self:DispatchEvent ("ItemRemoved", item)
	self.Items [item:GetID ()] = nil
	self.ItemCount = self.ItemCount - 1
	self.Weight = self.Weight - item:GetTotalWeight ()
	self:DispatchEvent ("WeightChanged")
	item:SetInventory (nil)
end

function Inventory:SetID (id)
	self.ID = id
end

function Inventory:SetWeight (weight)
	self.Weight = weight
	self:DispatchEvent ("WeightChanged")
end

function Inventory:RemoveMaximumWeightBonus (weight)
	self.MaximumWeightBonus = self.MaximumWeightBonus - weight
	self:DispatchEvent ("WeightChanged")
end

function Inventory:SetMaximumWeight (weight)
	self.MaximumWeight = weight
	self:DispatchEvent ("WeightChanged")
end

function Inventory:SetMaximumWeightBonus (weight)
	self.MaximumWeightBonus = weight
	self:DispatchEvent ("WeightChanged")
end

function Inventory:SetOwner (ply)
	self.Owner = ply
	self.OwnerName = ply:Name ()
	self.OwnerID = ply:SteamID ()
end

-- Serialization
function Inventory:Load (path)
	self.SavePath = path or self.SavePath
	local data = file.Read (self.SavePath)
	if not data then
		return
	end
	self:ImportFile (util.KeyValuesToTable (data))
end

function Inventory:Save (path)
	self.SavePath = path or self.SavePath
	if not self.SavePath then
		return
	end
	file.Write (self.SavePath, util.TableToKeyValues (self:ExportFile ()))
end