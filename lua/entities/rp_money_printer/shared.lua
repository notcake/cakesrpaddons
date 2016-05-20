ENT.Type			= "anim"
ENT.Base			= "base_gmodentity"
ENT.PrintName		= "Money Printer"
ENT.Author			= "Render Case, philxyz and !cake"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

cleanup.Register ("money_printer")

function ENT:SetupDataTables ()
	self:DTVar ("Int", 0, "price")
	self:DTVar ("Entity", 1, "owning_ent")
end