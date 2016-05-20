include ("shared.lua")
include ("cgui.lua")

include ("settings.lua")
include ("password.lua")

language.Add ("Cleanup_money_printer", "Money Printers")
language.Add ("Cleaned_money_printer", "Cleaned up Money Printers")
language.Add ("SBoxLimit_money_printers", "You have hit the Money Printer limit!")
language.Add ("rp_money_printer", "Money Printer")

function ENT:Initialize ()
end

function ENT:Draw ()
	self.Entity:DrawModel ()
	
	local Pos = self:GetPos ()
	local Ang = self:GetAngles ()
	
	local owner = self.dt.owning_ent
	owner = ValidEntity (owner) and owner:Nick () or "unknown"
	
	surface.SetFont ("HUDNumber5")
	local TextWidth = surface.GetTextSize ("Money printer")
	local TextWidth2 = surface.GetTextSize (owner)
	
	Ang:RotateAroundAxis (Ang:Up (), 90)
	
	cam.Start3D2D (Pos + Ang:Up () * 11.5, Ang, 0.11)
		draw.WordBox (2, -TextWidth * 0.5, -30, "Money printer", "HUDNumber5", Color (140, 0, 0, 100), Color (255,255,255,255))
		draw.WordBox (2, -TextWidth2 * 0.5, 18, owner, "HUDNumber5", Color (140, 0, 0, 100), Color (255,255,255,255))
	cam.End3D2D()
end

function ENT:Think ()
end
