local WeaponItemClass = {}
WeaponItemClass.__index = WeaponItemClass
setmetatable (WeaponItemClass, CInventory.ItemClass)
CInventory.WeaponItemClass = CUtil.MakeConstructor (WeaponItemClass)

function WeaponItemClass:ctor (name, parameters)
	CInventory.ItemClass.ctor (self, name, parameters)
	
	self:RegisterAction ("Drop", "WeaponDrop")
	self:RegisterAction ("Equip", "Equip")
end

function WeaponItemClass:GetEntityClass ()
	return "spawned_weapon"
end

function WeaponItemClass:MatchesEntity (ent)
	if ent.weaponclass and
		self.EntityClass:lower () == ent.weaponclass:lower () then
		return true
	end
	if self.EntityClass:lower () == ent:GetClass ():lower () then
		return true
	end
	return false
end

function WeaponItemClass:SetUpItem (item)
	if not item.EntityClass then
		item.EntityClass = self.EntityClass
	end
	if not item.Model then
		local weapon = weapons.Get (self.EntityClass)
		if weapon then
			item.Model = weapon.WorldModel
		end
	end
end

function WeaponItemClass:SetUpItemFromEntity (item, ent)
	if ent:GetClass () == "spawned_weapon" then
		item.WeaponClass = ent.weaponclass
		item.EntityClass = ent.weaponclass
	else
		item.WeaponClass = ent:GetClass ()
		item.EntityClass = ent:GetClass ()
		item.Model = ent.WorldModel or ent:GetModel ()
	end
end