AddCSLuaFile ("cl_init.lua")
AddCSLuaFile ("shared.lua")

include ("shared.lua")

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

local lookup_table = {}
lookup_table ["0"] = ""
for i = 1, 9999 do
	lookup_table [util.CRC (i)] = i
end

function SWEP:Initialize ()
	self:SetWeaponHoldType ("slam")
	
	self:SetNetworkedBool ("Ironsights", false)
	self.Hint = ""
	self:SetNetworkedString ("Hint", "")
	self.StartValue = 1
	self.Negative = false
	self.Succeeded = false
	self.Failed = false
	
	CUtil.TimerProvider (self)
end

-- Do not destroy the weapon here; this is done elsewhere
function SWEP:AttachToObject (ent)	
	local pos = ent:GetPos ()
	local angles = ent:GetAngles ()
	local right, forward, up = ent:GetRight (), ent:GetForward (), ent:GetUp ()
	
	local cracker = ents.Create ("sent_keypadcracker")
	
	cracker.CurValue = self.StartValue
	cracker.Password = self:GetObjectPassword (ent)
	cracker.Negative = self.Negative
	cracker.Keypad = ent
	cracker.Cracking = true
	cracker:Spawn ()
	
	if ent:GetClass () == "rp_money_printer" then
		cracker:SetPos (ent:LocalToWorld (Vector (12, 0, 11)))
		cracker:SetAngles (ent:LocalToWorldAngles (Angle (0, 180, 0)))
	else
		cracker:SetPos (ent:LocalToWorld (Vector (1, -1, 2)))
		cracker:SetAngles (ent:LocalToWorldAngles (Angle (-90, 180, 0)))
	end
	
	constraint.Weld (ent, cracker, 0, 0, 1500, true) -- weld the cracker to the object (1500 force limit. gravgun grab will remove that, most bumps wont)
end

function SWEP:IsObjectCrackable (ent)
	local class = ent:GetClass ()
	if class == "sent_keypad" or
		class == "sent_wire_keypad" or
		class == "rp_money_printer" then
		return true
	end
	return false
end

function SWEP:IsObjectPassworded (ent)
	if ent:GetClass () == "rp_money_printer" then
		return ent:IsPassworded ()
	end
	return true
end

function SWEP:Equip (ply)
	self:UpdateClient (self.StartValue, self.Negative, self.Failed, self.Succeeded)
end

function SWEP:GetObjectName (ent)
	if ent:GetClass () == "rp_money_printer" then
		return "Money Printer"
	end
	return "Keypad"
end

function SWEP:GetObjectPassword (ent)
	if ent:GetClass () == "rp_money_printer" then
		return tonumber (ent:GetPassword () or "")
	end
	return lookup_table [ent.Pass]
end

function SWEP:GetTarget ()
	if not self:GetOwner () or
		not self:GetOwner ():IsValid () then
		return nil
	end
	local trace = self:GetOwner ():GetEyeTrace ()
	if not trace.Hit or
		not trace.Entity or
		not trace.Entity:IsValid () then
		return nil
	end
	local ent = trace.Entity
	if not self:IsObjectCrackable (ent) or
		not self:IsObjectPassworded (ent) then
		return nil
	end
	local dist = (trace.HitPos - trace.StartPos):Length ()
	if dist > 96 then
		return nil
	end
	return ent
end

function SWEP:Holster ()
	self:StopSequence (true)
	return true
end

function SWEP:LookupPassword (hash)
	return lookup_table [hash]
end

function SWEP:PrimaryAttack ()
	if self.InSequence then
		return true
	end
	
	local ent = self:GetTarget ()
	if not ent then
		return
	end
	
	-- check if the object is already being cracked
	-- if ent.BeingCracked then
	--	return
	-- end
	
	self.Keypad = ent
	self.InSequence = true
	
	-- C4 arming animation
	self:SendWeaponAnim (ACT_VM_PRIMARYATTACK)
	
	-- wait until the animation has ran for a while, then start the ironsights
	self:AddTimer ("Animation1", 2.4, function (self) 
		self.Owner:SetAnimation (PLAYER_ATTACK1) -- 3rd person attack animation
		self:SetNWBool ("Ironsights", true)
	end)
	
	-- after the weapon has moved to the ironsights position
	self:AddTimer ("Animation2", 2.4 + self.IronTime, function (self)
		-- prevent the primary attack sequence repeating itself
		self:SendWeaponAnim (ACT_VM_IDLE)
		
		-- start the cracking sequence, and remove the swep
		self:AttachToObject (ent)
		self:GetOwner ():StripWeapon (self:GetClass ())
	end)
	return true
end

function SWEP:SecondaryAttack ()
	umsg.Start ("keypad_cracker_togglegui", self:GetOwner ())
	umsg.End ()
	return true
end

function SWEP:SetHint (hint)
	hint = hint or ""
	if self.Hint == hint then
		return
	end
	self.Hint = hint
	self:SetNetworkedString ("Hint", hint or "")
end

-- stops the primary fire sequence
function SWEP:StopSequence (dont_send_anim)
	if not dont_send_anim then
		self:SendWeaponAnim (ACT_VM_IDLE)
	end

	self.Keypad = nil
	self:SetNWBool ("Ironsights", false)
	self.InSequence = false

	-- remove the 2 timers created in the primary fire sequence
	self:RemoveTimer ("Animation1")
	self:RemoveTimer ("Animation2")
end

function SWEP:Think ()
	self:ProcessTimers ()
	
	local ent = self:GetTarget ()	
	if self.InSequence then
		if not ent or ent ~= self.Keypad then
			-- Player is no longer looking at the keypad - abort
			self:StopSequence ()
		end
	end
	if self.InSequence or not ent then
		self:SetHint ("")
	else
		local name = self:GetObjectName (ent)
		if name == "Money Printer" then
			self:SetHint (name .. "\nLeft click to remove password")
		else
			self:SetHint (name .. "\nLeft click to crack")
		end
	end
end

function SWEP:SetCrackingData (StartValue, Negative)
	self.StartValue = StartValue
	self.Negative = Negative
end

function SWEP:UpdateClient (StartValue, Negative, Failed, Succeeded)	
	umsg.Start ("keypad_cracker_updateclient", self.Owner)
		umsg.Short (StartValue)
		umsg.Bool (Negative)
		umsg.Bool (Failed)
		umsg.Bool (Succeeded)
	umsg.End ()
end

concommand.Add ("keypad_cracker_setcrackingdata", function (ply, cmd, args)
	local weapon = ply:GetWeapon ("rp_keypad_cracker")
	if not weapon or
		not weapon:IsValid () or
		#args < 1 then
		return
	end
	if not tonumber (args [1]) then
		return
	end
	
	args [1] = math.Clamp (tonumber (args [1]), 1, 9999)
	
  -- tobool returns true, even when its false in this case. so must use this instead
	if args [2] == "false" then
		args [2] = false
	else
		args [2] = true
	end
	
	weapon:SetCrackingData (args [1], args [2])
end)