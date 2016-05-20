local ActionCollection = {}
ActionCollection.__index = ActionCollection
CInventory.ActionCollection = CUtil.MakeConstructor (ActionCollection)

function ActionCollection:ctor ()
	self.Actions = {}
end

function ActionCollection:CreateAction (name)
	local action = CInventory.Action (name)
	self.Actions [name:lower ()] = action
	return action
end

function ActionCollection:GetAction (name)
	return self.Actions [name:lower ()]
end