include ("shared.lua")

language.Add ("Cleanup_bank_terminal", "Bank Terminals")
language.Add ("Cleaned_bank_terminal", "Cleaned up Bank Terminals")
language.Add ("SBoxLimit_bank_terminals", "You have hit the Bank Terminal limit!")
language.Add ("rp_bank_terminal", "Bank Terminal")

function ENT:Initialize ()
end

function ENT:Draw ()
	self.Entity:DrawModel ()
	
	local Pos = self:GetPos ()
	local Ang = self:GetAngles ()
	
	surface.SetFont ("HUDNumber5")
	local TextWidth = surface.GetTextSize ("Loans")
	
	Ang:RotateAroundAxis (Ang:Forward (), 90)	
	cam.Start3D2D (Pos + Ang:Forward () * 12.67, self:LocalToWorldAngles (Angle (0, 90, 85)), 0.11)
		surface.SetDrawColor (0, 0, 0, 255)
		surface.DrawRect (-88, -108, 176, 146)
		draw.DrawText ("Loans", "HUDNumber5", -TextWidth * 0.5, -64, Color (128, 255, 128, 255))
	cam.End3D2D()
end