AddCSLuaFile ("cl_init.lua")
AddCSLuaFile ("shared.lua")
include ("shared.lua")

resource.AddFile ("sound/cracker/c4_plant.wav")

-- sounds emitted by the entity, add more if you wish, a random one is selected automatically
local BreakSounds = {
						"weapons/stunstick/spark1.wav",
						"weapons/stunstick/spark2.wav",
						"weapons/stunstick/spark3.wav"
					}
local AttachSounds = {
						"cracker/c4_plant.wav"
					}
local FinishSounds = {
						"buttons/button9.wav"
					}

function ENT:Initialize ()
	self:SetModel ("models/weapons/w_c4_planted.mdl")
	self:SetAngles (Angle (0,0,0))
	self:PhysicsInitBox (Vector (-3, -6, 0), Vector (3, 6, 5)) -- create a box for the physics. since were scaling down the model
	
	local phys = self:GetPhysicsObject ()
	if phys:IsValid () then
		phys:Wake ()
		phys:SetMass (2) -- if the keypad is unfrozen, then it needs to be light enough not to pull on it
	end
	
	self.CurValue = self.CurValue or 1
	self.Cracking = self.Cracking or false
	
	self.HP = 50 -- the entities health, if this drops to 0 then it "Breaks" (stops working + falls off the keypad)
	self.Broken = false 
	self.Finished = false -- when the cracker has found the right code, this changes to true
	
	self:SetNWString ("Owner", "Shared")
	
	self:SetNWString ("Cracker_Display", tostring (self.CurValue))
	self:SetNWBool ("Cracker_Broken", self.Broken)
	self:SetNWBool ("Cracker_Finished", self.Finished)
	self:SetNWBool ("Cracker_Cracking", self.Cracking)
	
	-- check if the cracker has a keypad entity
	if self.Keypad then
		self:EmitRandomSound (AttachSounds, 75, math.random (95, 105))
			
		self.Keypad.BeingCracked = true
		self:SetAngles (self.Entity.Keypad:GetAngles () + Angle (270, 180, 0)) -- angle the cracker so it faces the right way
		
		local password = self:GetTargetPassword ()
		if not password then
			self.Entity:SetNWString ("Cracker_Display", "Error")
			
			self.Entity.Cracking = false
			self.Entity:SetNWBool ("Cracker_Cracking", false)
		end
	else
		self.Entity:SetNWString ("Cracker_Display", "Error")
	end
	
	-- make the entity not collide with players (collides just like weapons)
	self.Entity:SetCollisionGroup (COLLISION_GROUP_WEAPON)
end

function ENT:Break ()
	if self.Broken then
		return
	end
	
	self:SetNWBool ("Cracker_Cracking", false)
	self:SetNWBool ("Cracker_Broken", true)
	self.Broken = true
	self.Cracking = false
	
	if self.Keypad then
		self.Keypad.BeingCracked = false
	end
	
	self.Entity:EmitRandomSound (BreakSounds, 75, math.random (95, 105))
	
	-- break the weld to the keypad
	constraint.RemoveConstraints (self, "Weld")
end

-- Plays a random sound from the given table
function ENT:EmitRandomSound (SoundTable, volume, pitch)
	self.Entity:EmitSound (SoundTable [math.random (1, #SoundTable)], volume, pitch)
end

function ENT:GetTargetPassword ()
	if self.Keypad.GetPassword then
		return tonumber (self.Keypad:GetPassword ())
	end
	return self.Password
end

function ENT:OnTakeDamage (dmginfo)
	-- react physically to damage
	self:TakePhysicsDamage (dmginfo)
	
	if self.Broken then
		return
	end
	
	-- subtract the damage from the HP
	self.HP = self.HP - math.floor (dmginfo:GetDamage ())
	
	-- if the hp is now 0 or less, then it "Breaks" 
	if self.HP <= 0 then
		self:Break ()
	end
end

-- called when the cracker finds the correct value
function ENT:Success (Value)
	self.Finished = true
	self:SetNWBool ("Cracker_Finished", true)
	
	self.Cracking = false
	self:SetNWBool ("Cracker_Cracking", false)
	self:SetNWString ("Cracker_Display", tostring (Value))
	
	self:EmitRandomSound (FinishSounds, 75, math.random (95, 105))
	
	if self.Keypad:GetClass () == "rp_money_printer" then
		self.Keypad:SetPassword ("")
	end
end

function ENT:Think ()
	local rate = math.Clamp (KPC.Rate, 1, 9999)
	-- calculate how many value to try this frame
	local timeDiff = CurTime () - (self.Entity.LastThinkTime or CurTime ())
	local valuesThisFrame = timeDiff * rate
	
	self.Entity.ValuesToTry = self.Entity.ValuesToTry or 0
	self.Entity.ValuesToTry = (self.Entity.ValuesToTry or 0) + valuesThisFrame
	
	if self.Keypad and
		self.Cracking and
		not self.Entity.Finished then
		
		local password = self:GetTargetPassword ()
		if not password then
			self:Success ("")
			return true
		end
		for i = 1, self.ValuesToTry do
			self.Entity.ValuesToTry = self.Entity.ValuesToTry - 1
			
			-- compare the current value on the cracker, with the passcode
			if self.CurValue == password then
				self:Success (self.CurValue)
				return true
			end
					
			-- if not then increment the CurValue ready for the next think/cycle
			if self.Entity.Negative then 
				self.Entity.CurValue = self.Entity.CurValue - 1
			else
				self.Entity.CurValue = self.Entity.CurValue + 1
			end
			
			-- if the value has reached the end of the number range, then move it back to the start/end 
			if self.Entity.CurValue >= 10000 then self.Entity.CurValue = 1 end
			if self.Entity.CurValue <= 0 then self.Entity.CurValue = 9999 end
		end
			
		-- set this networked var so that the clientside can see the progress
		self.Entity:SetNWString ("Cracker_Display", tostring (self.Entity.CurValue))
	end
	
	if not self.Keypad then
		return true
	end
	
	local Weld = constraint.FindConstraint (self.Entity, "Weld")
	if not Weld or
		not Weld.Ent1 or
		not Weld.Ent1:IsValid () or
		Weld.Ent1 ~= self.Entity.Keypad then
		self:EmitRandomSound (BreakSounds, 75, math.random (95, 105))
		
		self.Cracking = false
		self:SetNWBool ("Cracker_Cracking", false)
		
		self.Keypad.BeingCracked = nil
		self.Keypad = nil
	end
	
	self.LastThinkTime = CurTime ()

	self:NextThink (CurTime ()) 
	return true
end

function ENT:Use (user) 
	if self.Fading then
		return
	end
	
	-- if the cracker was cracking a keypad, we need to unmark the keypad for use again
	if self.Keypad then 
		self.Keypad.BeingCracked = false
	end
	
  -- what happens when its broken
	if self.Broken then 
	  -- set the renderFX to fade slow
		self:SetKeyValue ("renderfx", 5)
	  
	  -- play a break sound
		self:EmitRandomSound (BreakSounds, 75, math.random (95, 105))		
		
	  -- remove itself after fading away 
		timer.Simple (8, function () 
			if self:IsValid () then
				self:Remove () 
			end 
		end) 
		
	  -- so the use cant be called again
		self.Entity.Fading = true
		return
	end

  -- if it wasnt broken then this section is ran
	-- give the player the cracker swep, and remove the entitiy ( appear as if they just picked it up )
	user:Give ("rp_keypad_cracker")
	
	-- store these 2 values... after the entity is removed we wont be able to reference them
	local StartValue, Negative = self.Entity.CurValue, self.Entity.Negative
	local Succeeded, Failed = self.Entity.Finished, (not self.Entity.Cracking and not self.Entity.Finished)
	
	-- after a short delay,  (enough time for the weapon to become valid)
	timer.Simple (0, function ()
		local weapon = user:GetWeapon ("rp_keypad_cracker")
		if not weapon:IsValid () then
			return
		end
		
		-- gives the appearence of synchronisity between the weapon and the entity
		weapon.StartValue = StartValue
		weapon.Negative = Negative
		weapon.Failed = Failed
		weapon.Succeeded = Succeeded
		weapon:UpdateClient (StartValue, Negative, Failed, Succeeded)
	end)
	
	-- remove the entity
	self.Entity:Remove()
	
end

function ENT:OnRemove ()
	if self.Keypad then
		self.Keypad.BeingCracked = nil
	end
end