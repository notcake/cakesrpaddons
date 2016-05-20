local ItemClass = {}
ItemClass.__index = ItemClass
CInventory.ItemClass = ItemClass

function ItemClass:ctor (name, parameters)
	CUtil.EventProvider (self)

	self.Name = name
	self.Generator = nil
	
	self.Actions = {}
	
	self.EntityClass = "*"
	self.Model = "*"
	self.Skin = "*"
	self.Weight = 0
	self.Stackable = false
	
	self:ApplyParameters (parameters)
end

-- Serialization
function ItemClass:ExportDatastream ()
	local tbl = {}
	tbl.Name = self.Name
	tbl.EntityClass = self.EntityClass
	tbl.Model = self.Model
	tbl.Skin = self.Skin
	tbl.Weight = self.Weight
	tbl.Stackable = self.Stackable
	return tbl
end

-- Serialization
function ItemClass:ExportFile ()
	local tbl = {}
	tbl.Generator = self:GetGenerator ()
	tbl.Name = self.Name
	tbl.EntityClass = self.EntityClass
	tbl.Model = self.Model
	tbl.Skin = self.Skin
	tbl.Weight = self.Weight
	tbl.Stackable = tostring (self.Stackable)
	return tbl
end

function ItemClass:ExportItemFile (item, tbl)
end

function ItemClass:ImportFile (tbl)
	self.Name = tbl.name
	self.EntityClass = tbl.entityclass or "*"
	self.Model = tbl.model or "*"
	self.Skin = tbl.skin or "*"
	self.Weight = tonumber (tbl.weight) or 10
	self.Stackable = tbl.stackable or false
end

function ItemClass:ImportItemFile (item, tbl)
end

function ItemClass:ApplyParameters (parameters)
	if not parameters then
		return
	end
	self.EntityClass = parameters.EntityClass or parameters.entityclass or self.EntityClass
	self.Model = parameters.Model or parameters.model or self.Model
	self.Skin = parameters.Skin or parameters.skin or self.Skin
	self.Weight = parameters.Weight or parameters.weight or 0
	if parameters.stackable ~= nil then
		self.Stackable = util.tobool (tostring (parameters.stackable):lower ())
	end
end

function ItemClass:CanPlayerPickUp (item, ply)
	return true
end

function ItemClass:CanRunAction (ply, inventory, item, action)
	local action = self:GetAction (action)
	if not action then
		return
	end
	return action:CanRun (ply, inventory, item)
end

function ItemClass:GetAction (name)
	return self.Actions [name]
end

function ItemClass:GetActionIterator ()
	local next, tbl, key = pairs (self.Actions)
	return function ()
		key = next (tbl, key)
		return key, tbl [key]
	end
end

function ItemClass:GetEntityClass ()
	return self.EntityClass
end

function ItemClass:GetGenerator ()
	return self.Generator
end

function ItemClass:GetItemName ()
	return self.Name
end

function ItemClass:GetModel ()
	return self.Model
end

function ItemClass:GetName ()
	return self.Name
end

function ItemClass:GetSkin ()
	return self.Skin
end

function ItemClass:GetWeight ()
	return self.Weight
end

function ItemClass:IsStackable ()
	return self.Stackable
end

function ItemClass:MatchesEntity (ent)
	return true
end

function ItemClass:OnItemAddedToInventory (inventory, item, count)
end

function ItemClass:OnItemRemovedFromInventory (inventory, item, count)
end

function ItemClass:RegisterAction (name, action)
	self.Actions [name] = CInventory.Actions:GetAction (action or name)
end

function ItemClass:RunAction (ply, inventory, item, action)
	local action = self:GetAction (action)
	if not action then
		return
	end
	action:Run (ply, inventory, item)
end

function ItemClass:SetEntityClass (class)
	self.EntityClass = class
end

function ItemClass:SetGenerator (name)
	self.Generator = name
end

function ItemClass:SetModel (model)
	self.Model = model
end

function ItemClass:SetName (name)
	self.Name = name
end

function ItemClass:SetSkin (skin)
	self.Skin = skin
end

function ItemClass:SetStackable (stackable)
	self.Stackable = stackable
end

function ItemClass:SetUpEntityFromItem (entity, item)
end

function ItemClass:SetUpItem (item)
end

function ItemClass:SetUpItemFromEntity (item, entity)
end

function ItemClass:SetWeight (weight)
	if self.Weight == weight then
		return
	end
	local oldweight = self.Weight
	self.Weight = weight
	self:DispatchEvent ("WeightChanged", oldweight, weight)
end