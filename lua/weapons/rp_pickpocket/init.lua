AddCSLuaFile ("cl_init.lua")
AddCSLuaFile ("shared.lua")

include ("shared.lua")

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

function SWEP:Initialize ()
	self:SetWeaponHoldType ("normal")

	self.PickpocketTime = 10
	self.MaximumLookingAwayTime = 1.5
	self.MaximumTargetMovement = 32
	
	self.PickpocketTarget = nil
	self.PickpocketTargetPosition = Vector (0, 0, 0)
	self.Pickpocketting = false
	self:SetNetworkedBool ("Pickpocketting", false)
	self.PickpocketStartTime = 0
	self.PickpocketEndTime = 0
	
	self:SetLookingAway (false)
	self:SetNetworkedBool ("LookingAway", false)
	self.LookingAway = false
	self.LookingAwayStartTime = 0
end

function SWEP:CancelPickpocketting ()
	if not self:IsPickpocketting () then
		return
	end
	umsg.Start ("pickpocket_cancel", self:GetOwner ())
	umsg.End ()
	self:StopPickpocketting ()
end

function SWEP:Deploy ()
	self:GetOwner ():DrawWorldModel (false)
end

function SWEP:GetLookingAwayTime ()
	return CurTime () - self.LookingAwayStartTime
end

function SWEP:GetPickpocketTarget ()
	if not self.PickpocketTarget then
		return nil
	end
	if not self.PickpocketTarget:IsValid () then
		return nil
	end
	return self.PickpocketTarget
end

function SWEP:Holster ()
	return not self:IsPickpocketting ()
end

function SWEP:IsLookingAway ()
	return self.LookingAway
end

function SWEP:IsPickpocketting ()
	return self.Pickpocketting
end

function SWEP:OnCaught ()
	local owner = self:GetOwner ()
	local target = self:GetPickpocketTarget ()
	umsg.Start ("pickpocket_caught", owner)
		umsg.Entity (target)
	umsg.End ()
	if target:GetClass () == "player" then
		umsg.Start ("pickpocket_discovered", target)
			umsg.Entity (owner)
		umsg.End ()
		Notify (target, 4, 4, owner:Name () .. " tried to pickpocket you!")
	end
	self:SetNetworkedFloat ("CaughtTime", CurTime ())
	self:StopPickpocketting ()
end

function SWEP:OnSuccessfulPickpocket ()
	local owner = self:GetOwner ()
	local target = self:GetPickpocketTarget ()
	local amount = math.random (1, 125)
	
	-- cap amount
	local victimcash = 125
	if target.DarkRPVars and
		target.DarkRPVars.money then
		victimcash = target.DarkRPVars.money
	end
	if victimcash < 0 then
		amount = 0
	elseif victimcash < amount then
		amount = victimcash
	end
	
	umsg.Start ("pickpocket_success", owner)
		umsg.Entity (self:GetPickpocketTarget ())
		umsg.Long (amount)
	umsg.End ()
	if amount ~= 0 then
		if owner.AddMoney then
			owner:AddMoney (amount)
		end
		if target.AddMoney then
			target:AddMoney (-amount)
		end
	end
	self:StopPickpocketting ()
end

function SWEP:PrimaryAttack ()
	if self:IsPickpocketting () then
		return
	end
	if self:GetPickpocketTarget () then
		self:StartPickpocketting ()
	end
end

function SWEP:SetLookingAway (lookingAway)
	if self.LookingAway == lookingAway then
		return
	end
	self.LookingAway = lookingAway
	self.LookingAwayStartTime = CurTime ()
	self:SetNetworkedBool ("LookingAway", lookingAway)
end

function SWEP:SetPickpocketTarget (ply)
	if self.PickpocketTarget == ply then
		return
	end
	self.PickpocketTarget = ply
	if not ply then
		ply = ents.GetByIndex (-2)
	end
	self:SetNetworkedEntity ("PickpocketTarget", ply)
end

function SWEP:StartPickpocketting ()
	self.Pickpocketting = true
	self.PickpocketStartTime = CurTime ()
	self.PickpocketEndTime = CurTime () + self.PickpocketTime
	self:SetNetworkedFloat ("PickpocketStartTime", self.PickpocketStartTime)
	self:SetNetworkedFloat ("PickpocketEndTime", self.PickpocketEndTime)
	self:SetNetworkedBool ("Pickpocketting", true)
	
	self.PickpocketTargetPosition = self:GetPickpocketTarget ():GetPos ()
	self:SetLookingAway (false)
end

function SWEP:StopPickpocketting ()
	self.Pickpocketting = false
	self:SetNetworkedBool ("Pickpocketting", false)
	self:SetLookingAway (false)
end

function SWEP:Think ()
	local trace = self:GetOwner ():GetEyeTrace ()
	local trace_ent = nil
	if trace.Hit and
		trace.Entity and
		trace.Entity:IsValid () then
		if (trace.HitPos - self:GetPos ()):Length () < 128 then
			if trace.Entity:GetClass () == "player" then
				trace_ent = trace.Entity
			end
		end
	end
	if self:IsPickpocketting () then
		if CurTime () > self.PickpocketEndTime then
			self:OnSuccessfulPickpocket ()
		end
		
		-- Check if the target has moved too much
		local delta_pos = self:GetPickpocketTarget ():GetPos () - self.PickpocketTargetPosition
		delta_pos.z = 0
		if delta_pos:Length () > self.MaximumTargetMovement then
			if CurTime () - self.PickpocketStartTime < 1 then
				-- if the player has only just started, let him slide
				self:CancelPickpocketting ()
			else
				self:OnCaught ()
			end
		else
			-- Check if the player has stopped looking at the target
			if not trace_ent then
				if not self:IsLookingAway () then
					self:SetLookingAway (true)
				end
				if self:GetLookingAwayTime () > self.MaximumLookingAwayTime then
					self:CancelPickpocketting ()
				end
			else
				self:SetLookingAway (false)
			end
		end
	else
		self:SetPickpocketTarget (trace_ent)
	end
end