ENT.Type            = "anim"
ENT.Base            = "base_gmodentity"

ENT.PrintName       = "Banking Terminal"
ENT.Author          = "!cake"
ENT.Contact         = "cakenotfound@googlemail.com"
ENT.Purpose         = "Borrow and lend money here."
ENT.Instructions    = "Press use to open the banking menu."

ENT.Spawnable       = false
ENT.AdminSpawnable  = false

cleanup.Register ("bank_terminal")

function ENT:SetupDataTables ()
	self:DTVar ("Int", 0, "price")
	self:DTVar ("Entity", 1, "owning_ent")
end