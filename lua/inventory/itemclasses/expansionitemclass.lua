local ExpansionItemClass = {}
ExpansionItemClass.__index = ExpansionItemClass
setmetatable (ExpansionItemClass, CInventory.ItemClass)
CInventory.ExpansionItemClass = CUtil.MakeConstructor (ExpansionItemClass)

function ExpansionItemClass:ctor (name, parameters)
	CInventory.ItemClass.ctor (self, name, parameters)
	
	self:AddEventListener ("WeightChanged", function (self, oldweight, newweight)
		local increase = newweight - oldweight
		for _, inventory in CInventory.Inventories:GetInventoryIterator () do
			for item in inventory:GetItemIterator () do
				if item:GetItemClass () == self then
					inventory:AddMaximumWeightBonus (increase * item:GetCount ())
				end
			end
		end
	end)
end

function ExpansionItemClass:GetItemName (item)
	return self:GetName ()
end

function ExpansionItemClass:GetWeight ()
	return 0
end

function ExpansionItemClass:OnItemAddedToInventory (inventory, item, count)
	inventory:AddMaximumWeightBonus (count * self.Weight)
end

function ExpansionItemClass:OnItemRemovedFromInventory (inventory, item, count)
	inventory:RemoveMaximumWeightBonus (count * self.Weight)
end