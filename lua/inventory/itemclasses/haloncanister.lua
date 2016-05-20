local self = {}
self.__index = self
setmetatable (self, CInventory.ItemClass)

function self:ctor (name, parameters)
	CInventory.ItemClass.ctor (self, name, parameters)
	
	self:RegisterAction ("Drop")
	self:RegisterAction ("Use")
end

CInventory.ItemClasses:RegisterItemClass (CUtil.MakeConstructor (self) ("Halon Canister"))