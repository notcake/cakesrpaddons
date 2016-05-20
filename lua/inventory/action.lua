local Action = {}
Action.__index = Action
CInventory.Action = CUtil.MakeConstructor (Action)

function Action:ctor (name)
	self.Name = name
end

function Action:CanRun (ply, inventory, item)
	return false
end

function Action:GetName ()
	return self.Name
end

function Action:Run (ply, inventory, item)
end

function Action:SetName (name)
	self.Name = name
end