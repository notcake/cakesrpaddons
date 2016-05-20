CGUI.RegisterRenderer ("DarkRPFrame", function (self, alpha)
	local w, h = self:GetSize()
	alpha = alpha or 232
	local color = Color (GetConVarNumber ("backgroundr"), GetConVarNumber ("backgroundg"), GetConVarNumber ("backgroundb"), alpha)
	draw.RoundedBox (8, 0, 0, w, h, color)
	
	surface.SetDrawColor (GetConVarNumber ("Healthforegroundr"), GetConVarNumber ("Healthforegroundg"), GetConVarNumber ("Healthforegroundb"), GetConVarNumber ("Healthforegrounda"))
	surface.DrawLine (0, 20, w, 20)
end)

CGUI.RegisterRenderer ("DarkRPKeypadFrame", function (self, alpha)
	local w, h = self:GetSize()
	alpha = alpha or 232
	local color = Color (GetConVarNumber ("backgroundr"), GetConVarNumber ("backgroundg"), GetConVarNumber ("backgroundb"), alpha)
	draw.RoundedBox (16, 0, 0, w, h, color)
end)