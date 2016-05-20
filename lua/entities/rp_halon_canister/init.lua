AddCSLuaFile ("cl_init.lua")
AddCSLuaFile ("shared.lua")
include ("shared.lua")

CreateConVar ("sbox_maxhalon_canisters", 2)

local function ExtinguishMoneyPrinter (ent)
	ent:StopOverheating ()
end

local function IsMoneyPrinterOverheating (ent)
	if ent.IsOverheating then
		return ent:IsOverheating ()
	end
	return false
end

function ENT:Initialize()
	self:SetModel ("models/props_junk/propane_tank001a.mdl")
	self:PhysicsInit (SOLID_VPHYSICS)
	self:SetMoveType (MOVETYPE_VPHYSICS)
	self:SetSolid (SOLID_VPHYSICS)
	
	local phys = self.Entity:GetPhysicsObject ()
	if phys and
		phys:IsValid () then
		phys:Wake ()
	end
	self.EffectRange = 192
	self.Emitting = false
	self.Sound = nil
	self.SoundName = "PhysicsCannister.ThrusterLoop"	-- Gas hissing noise
	self.Spawner = nil
	
	self.Activated = false
	
	self.Charges = 1

	self:UpdateOverlayText ()
	
	CUtil.TimerProvider (self)
end

function ENT:BeginEmitting (duration)
	self.Emitting = true
	self:SetNetworkedBool ("Emitting", true)
	
	if not self.Sound then
		self.Sound = CreateSound (self, self.SoundName)
	end
	self.Sound:PlayEx (2, 100)
	
	self:UpdateOverlayText ()
	self.Charges = self.Charges - 1
	
	self:AddTimer ("Emission", 10, function (self)
		self.Emitting = false
		self:SetNetworkedBool ("Emitting", false)
		
		if self.Sound then
			self.Sound:ChangeVolume (0, 0.25)
		end
		
		self:UpdateOverlayText ()
		
		if self.Charges < 1 then
			self:BeginFadeOut ()
		end
	end)
end

function ENT:BeginFadeOut ()
	local duration = 3
	self:SetNetworkedFloat ("FadeStart", CurTime ())
	self:SetNetworkedFloat ("FadeEnd", CurTime () + duration)
	self:SetNetworkedBool ("Fading", true)
	
	self:AddTimer (nil, duration + 0.2, self.Remove)
end

function ENT:CanPlayerPickUp (ply)
	return self:GetCharges () > 0
end

function ENT:ExtinguishThink ()
	local ents = ents.FindInSphere (self:GetPos (), self.EffectRange)
	if self:IsEmitting () then
		for _, ent in ipairs (ents) do
			if ent.IsMoneyPrinter then
				if IsMoneyPrinterOverheating (ent) then
					ExtinguishMoneyPrinter (ent)
				end
			end
			if ent:IsOnFire () then
				ent:Extinguish ()
			end
			if ent:GetClass () == "player" then
				ent:TakeDamage (5, self, self)
			end
		end
	elseif self:GetCharges () > 0 then
		for _, ent in ipairs (ents) do
			if ent:IsOnFire () or
				(ent.IsMoneyPrinter and
				IsMoneyPrinterOverheating (ent)) then
				self:BeginEmitting ()
			end
		end
	end
end

function ENT:GetCharges ()
	return self.Charges
end

function ENT:GetSpawner ()
	return self.Spawner
end

function ENT:IsActivated ()
	return self.Activated
end

function ENT:IsEmitting ()
	return self.Emitting
end

function ENT:OnInventorySpawned (action)
	if action:lower () == "use" then
		self:SetActivated (true)
	end
end

function ENT:OnRemove ()
	if self.Sound then
		self.Sound:Stop ()
		self.Sound = nil
	end
end

function ENT:SetActivated (activated)
	self.Activated = activated
end

function ENT:SetSpawner (ply)
	self.Spawner = ply
end

function ENT:SpawnFunction (ply, tr)
	-- Check limits
	if ply:GetCount ("halon_canister") >= GetConVarNumber ("sbox_maxhalon_canisters") and
		GetConVarNumber ("sbox_maxhalon_canisters") >= 0 then
		ply:LimitHit ("halon_canisters")
		return nil
	end	

	if not tr.Hit then
		return
	end
	local pos = tr.HitPos + tr.HitNormal * 16
	local ent = ents.Create ("rp_halon_canister")
	ent:SetPos (pos)
	ent:Spawn ()
	ent:Activate ()
	ent:SetSpawner (ply)
	
	ply:AddCount ("halon_canister", ent)
	ply:AddCleanup ("halon_canister", ent)
	return ent
end

function ENT:Think ()
	self:ProcessTimers ()
		if self:IsActivated () then
		self:ExtinguishThink ()
		
		if self:GetNetworkedBool ("Fading") then
			local starttime = self:GetNetworkedFloat ("FadeStart")
			local endtime = self:GetNetworkedFloat ("FadeEnd")
			local curtime = CurTime ()
			local alpha = (endtime - curtime) / (endtime - starttime) * 255
			if alpha < 0 then
				alpha = 0
			end
			self:SetColor (255, 255, 255, alpha)
		end
	end
	self:NextThink (CurTime () + 0.5)
	return true
end

function ENT:UpdateOverlayText ()
	if self:IsEmitting () then
		self:SetOverlayText ("Halon Canister\nEmitting halon gas...")
	elseif self:GetCharges () > 0 then
		self:SetOverlayText ("Halon Canister\nPress USE to deploy")
	else
		self:SetOverlayText ("Halon Canister\nDepleted")
	end
end

function ENT:Use (activator, caller)
	if self:IsEmitting () then
		return
	end
	if self:IsActivated () and self.Charges > 0 then
		self:BeginEmitting ()
	end
end