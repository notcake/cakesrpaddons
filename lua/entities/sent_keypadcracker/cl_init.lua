include ("shared.lua")

surface.CreateFont ("Trebuchet", 26, 500, true, false, "Trebuchet26")

function ENT:Draw ()
	local Broken = self.Entity:GetNWBool ("Cracker_Broken") -- is the cracker "broken"?
	local Value = self.Entity:GetNWString ("Cracker_Display") -- the current value its working on
	local Finished = self.Entity:GetNWBool ("Cracker_Finished") -- is it finished?
	local Cracking = self.Entity:GetNWBool ("Cracker_Cracking") -- is it currently cracking (false when you pull it off the keypad)
	
	local Colour = Color (200, 200, 200, 255)
	self.Entity:SetModelScale (Vector (0.5, 0.5, 0.5))
	self.Entity:DrawModel ()
	
	if Broken then
		return
	end
	if not Finished and not Cracking then
		Colour = Color (150, 50, 50, 255)
	end
	if Finished then
		Colour = Color (50, 150, 50, 255)
	end

	local offset = Vector (2, 1.1, 4.45)
	local pos = self.Entity:GetPos () + (self.Entity:GetForward () * offset.x) + (self.Entity:GetRight () * offset.y) + (self.Entity:GetUp () * offset.z)
	local ang = self.Entity:GetAngles ()
	local rot = Angle (0,-90,0)
  
	ang:RotateAroundAxis (ang:Right (), 	rot.p)
	ang:RotateAroundAxis (ang:Up (), 		rot.y)
	ang:RotateAroundAxis (ang:Forward (),	rot.r)
	
	cam.Start3D2D (pos, ang, 0.05)
		draw.DrawText (Value, "Trebuchet26", 24.8, -3.4, Colour, TEXT_ALIGN_CENTER)
	cam.End3D2D ()
end