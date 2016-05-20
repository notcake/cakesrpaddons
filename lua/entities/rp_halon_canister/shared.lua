ENT.Type            = "anim"
ENT.Base            = "base_gmodentity"

ENT.PrintName       = "Halon Canister"
ENT.Author          = "!cake"
ENT.Contact         = "cakenotfound@googlemail.com"
ENT.Purpose         = "Prevents overheating and puts out fires. Breathing in the gas is inadvisable."
ENT.Instructions    = "Press use to deploy halon gas."

ENT.Spawnable       = false
ENT.AdminSpawnable  = false

cleanup.Register ("halon_canister")

function ENT:SetupDataTables ()
	self:DTVar ("Int", 0, "price")
	self:DTVar ("Entity", 1, "owning_ent")
end