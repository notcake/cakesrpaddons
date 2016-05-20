local ItemClassCollection = {}
ItemClassCollection.__index = ItemClassCollection
CInventory.ItemClassCollection = CUtil.MakeConstructor (ItemClassCollection)

--[[
	Events
	ItemClassesReceived					- only called on the client
	WeightChanged (collection, class)
]]

function ItemClassCollection:ctor ()
	CUtil.EventProvider (self)
	
	self.ItemClasses = {}				-- this is a set of strings on the client and a map of ItemClasses on the server
	self.ItemClassGenerators = {}
	
	self.EntityClasses = {}
end

function ItemClassCollection:CategorizeItemClass (class)
	if class:GetEntityClass () == "^" then
		return
	end
	local entityclass = self.EntityClasses [class:GetEntityClass ()] 
	if not entityclass then
		entityclass = {}
		self.EntityClasses [class:GetEntityClass ()] = entityclass
	end
	local model = entityclass [class:GetModel ()]
	if not model then
		model = {}
		entityclass [class:GetModel ()] = model
	end
	local skin = model [class:GetSkin ()]
	if not skin then
		skin = {}
		model [class:GetSkin ()] = skin
	end
	skin [#skin + 1] = class
end

function ItemClassCollection:CreateItemClass (generatorname, name, parameters)
	local generator = self.ItemClassGenerators [generatorname]
	if not generator then
		return nil
	end
	local class = generator:CreateItemClass (name, parameters)
	class:SetGenerator (generatorname)
	self:RegisterItemClass (class)
	return class
end

function ItemClassCollection:CreateGenerator (name)
	local generator = CInventory.ItemClassGenerator (name)
	self.ItemClassGenerators [name] = generator
	return generator
end

function ItemClassCollection:CreateItemFromEntity (ent, class)
	local itemclass = class or self:FindClassForEntity (ent)
	if not itemclass then
		return
	end
	local item = CInventory.Item ()
	item:SetModel (ent:GetModel ())
	item:SetSkin (ent:GetSkin ())
	item:SetEntityClass (ent:GetClass ())
	
	item:SetItemClass (itemclass)
	itemclass:SetUpItemFromEntity (item, ent)
	return item
end

function ItemClassCollection:ContainsClass (name)
	return self.ItemClasses [name] and true or false
end

function ItemClassCollection:ContainsGenerator (name)
	return self.ItemClassGenerators [name] and true or false
end

function ItemClassCollection:DecategorizeItemClass (class)
	local entityclass = class:GetEntityClass ()
	local model = class:GetModel ()
	local skin = class:GetSkin ()
	
	if self.EntityClasses [entityclass] then
		local models = self.EntityClasses [entityclass]
		if models [model] then
			local skins = models [model]
			if skins [skin] then
				local classes = skins [skin]
				for k, v in pairs (classes) do
					if v == class then
						classes [k] = nil
						break
					end
				end
			end
		end
	end
end

function ItemClassCollection:FindClassesForClass (classes, class, model, skin)
	if not classes then
		return nil
	end
	local class = self:FindClassesForModel (classes [class], model, skin)
	if class then
		return class
	end
	return self:FindClassesForClass (classes ["*"], model, skin)
end

function ItemClassCollection:FindClassesForEntity (ent)
	return self:FindClassesForClass (self.EntityClasses, ent:GetClass (), ent:GetModel (), tostring (ent:GetSkin ()))
end

function ItemClassCollection:FindClassForEntity (ent)
	local classes = self:FindClassesForEntity (ent)
	if not classes then
		return nil
	end
	for _, class in pairs (classes) do
		if class:MatchesEntity (ent) then
			return class
		end
	end
	return nil
end

function ItemClassCollection:FindClassesForModel (models, model, skin)
	if not models then
		return nil
	end
	local class = self:FindClassesForSkin (models [model], skin)
	if class then
		return class
	end
	return self:FindClassesForSkin (models ["*"], skin)
end

function ItemClassCollection:FindClassesForSkin (skins, skin)
	if not skins then
		return nil
	end
	if skins [skin] then
		return skins [skin]
	end
	if skins ["*"] then
		return skins ["*"]
	end
	return nil
end

function ItemClassCollection:GetItemClass (name)
	return self.ItemClasses [name]
end

function ItemClassCollection:GetItemClassIterator ()
	local next, tbl, key = pairs (self.ItemClasses)
	return function ()
		key = next (tbl, key)
		return key, tbl [key]
	end
end

function ItemClassCollection:GetItemClassGeneratorIterator ()
	local next, tbl, key = pairs (self.ItemClassGenerators)
	return function ()
		key = next (tbl, key)
		return key, tbl [key]
	end
end

function ItemClassCollection:RegisterItemClass (class)
	self.ItemClasses [class:GetName ()] = class
	
	self:CategorizeItemClass (class)
	
	class:AddEventListener ("WeightChanged", function (class)
		self:DispatchEvent ("WeightChanged", class)
	end)
end

function ItemClassCollection:RemoveItemClass (name)
	if not self.ItemClasses [name] then
		return
	end
	self:DecategorizeItemClass (self.ItemClasses [name])
	self.ItemClasses [name] = nil
	self:SaveClasses ()
end

if CLIENT then
	function ItemClassCollection:RequestItemClasses ()
		RunConsoleCommand ("_inventory_request_classes")
	end
end

-- Serialization
function ItemClassCollection:LoadClasses ()
	local data = file.Read ("inventory/settings/items.txt")
	if not data then
		return
	end
	local tbl = util.KeyValuesToTable (data)
	for _, class in pairs (tbl) do
		local itemclass = self:GetItemClass (class.name)
		if itemclass then
			self:DecategorizeItemClass (itemclass)
			itemclass:ApplyParameters (class)
			self:CategorizeItemClass (itemclass)
		else
			self:CreateItemClass (class.generator, class.name, class)
		end
	end
end

function ItemClassCollection:SaveClasses ()
	local tbl = {}
	for _, class in pairs (self.ItemClasses) do
		tbl [#tbl + 1] = class:ExportFile ()
	end
	file.Write ("inventory/settings/items.txt", util.TableToKeyValues (tbl))
end

datastream.Hook ("inventory_item_classes", function (_, _, _, tbl)
	CInventory.ItemClasses.ItemClasses = {}
	for _, class in ipairs (tbl.Classes) do
		CInventory.ItemClasses.ItemClasses [class] = true
	end
	CInventory.ItemClasses:DispatchEvent ("ItemClassesReceived")
end)

datastream.Hook ("inventory_create_item_class", function (ply, _, _, _, tbl)
	if not CInventory.CanModifySettings (ply) then
		return
	end
	if not tbl.Name or tbl.Name == "" then
		return
	end
	local item = CInventory.ItemClasses:GetItemClass (tbl.Name)
	if not item then
		item = CInventory.ItemClasses:CreateItemClass (tbl.Generator, tbl.Name, tbl)
	end
	if not item then
		return
	end
	CInventory.ItemClasses:DecategorizeItemClass (item)
	item:SetEntityClass (tbl.Class)
	item:SetModel (tbl.Model)
	item:SetSkin (tbl.Skin)
	item:SetWeight (tbl.Weight)
	item:SetStackable (tbl.Stackable)
	CInventory.ItemClasses:CategorizeItemClass (item)
	
	CInventory.ItemClasses:SaveClasses ()
end)