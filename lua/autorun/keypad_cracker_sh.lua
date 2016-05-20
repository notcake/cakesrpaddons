KPC = {} -- kentucky pwned chicken :V    a table to hold whatever shizz I need for the system
KPC.Rate = 50 -- how many numbers the crackers try each second	10000 / Rate   will give you the worst case crack time

if SERVER then	
	hook.Add ("WeaponEquip", "CrackerPickup", function (weapon)
		if weapon:GetClass () ~= "rp_keypad_cracker" then
			return
		end
		
		-- put everything inside this timer so it's called on the next frame.
		timer.Simple (0, function () 
			if not weapon:IsValid () then
				return
			end
			weapon:GetOwner ():SelectWeapon (weapon:GetClass ())
		end)
	end)
end