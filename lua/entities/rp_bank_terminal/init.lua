AddCSLuaFile ("cl_init.lua")
AddCSLuaFile ("shared.lua")
include ("shared.lua")

CreateConVar ("sbox_maxbank_terminals", 2)

--[[
	Usermessages:
		bank_terminal_open_ui	- Tells the client to show the bank terminal UI
]]

function ENT:Initialize()
	self:SetModel ("models/props_lab/monitor01a.mdl")
	self:PhysicsInit (SOLID_VPHYSICS)
	self:SetMoveType (MOVETYPE_VPHYSICS)
	self:SetSolid (SOLID_VPHYSICS)
	
	local phys = self.Entity:GetPhysicsObject ()
	if phys and
		phys:IsValid () then
		phys:Wake ()
	end
	self.Spawner = nil
	
	self:SetOverlayText ("Banking Terminal\nPress USE to apply for loans")
end

function ENT:GetSpawner ()
	return self.Spawner
end

function ENT:SetSpawner (ply)
	self.Spawner = ply
end

function ENT:SpawnFunction (ply, tr)
	-- Check limits
	if ply:GetCount ("bank_terminal") >= GetConVarNumber ("sbox_maxbank_terminals") and
		GetConVarNumber ("sbox_maxbank_terminals") >= 0 then
		ply:LimitHit ("bank_terminals")
		return nil
	end	

	if not tr.Hit then
		return
	end
	local pos = tr.HitPos + tr.HitNormal * 16
	local ent = ents.Create ("rp_bank_terminal")
	ent:SetPos (pos)
	ent:Spawn ()
	ent:Activate ()
	ent:SetSpawner (ply)
	
	ply:AddCount ("bank_terminal", ent)
	ply:AddCleanup ("bank_terminal", ent)
	return ent
end

function ENT:Use (activator, caller)
	if not activator or
		not activator:IsValid () or
		activator:GetClass () ~= "player" then
		return
	end
	umsg.Start ("bank_terminal_open_ui", activator)
	umsg.End ()
end