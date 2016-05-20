local PANEL = {}

--[[
	Events
	
	Clicked
]]

function PANEL:Init ()
	self.Disabled = false
	
	self.BackgroundColor = Color (255, 255, 255, 0)
	self:SetText ("")
	
	CUtil.EventProvider (self)
end

function PANEL:GetBackgroundColor ()
	return self.BackgroundColor
end
		
function PANEL:Paint ()
	local x, y = self:GetPos ()
	local w, h = self:GetSize ()
	
	surface.SetFont (self:GetFont ())
	local _, height = surface.GetTextSize (self:GetText ())
	draw.RoundedBox (16, 0, 0, w, h, self:GetBackgroundColor ())
	if self:IsPressed () then
		draw.RoundedBox (16, 0, 0, w, h, Color (64, 64, 64, 216))
		draw.DrawText (self:GetText (), self:GetFont (), w * 0.5, (h - height) * 0.5, Color (0, 0, 0, 255), TEXT_ALIGN_CENTER)
	else
		if self.Hovered then
			draw.RoundedBox (16, 0, 0, w, h, Color (255, 255, 255, 128))
		else
			draw.RoundedBox (16, 0, 0, w, h, Color (255, 255, 255, 64))
		end
		draw.DrawText (self:GetText (), self:GetFont (), w * 0.5 - 1, (h - height) * 0.5 - 1, Color (0, 0, 0, 255), TEXT_ALIGN_CENTER)
	end
	return true
end

function PANEL:SetBackgroundColor (color)
	self.BackgroundColor = color
end

vgui.Register ("GFlatButton", PANEL, "GButton")