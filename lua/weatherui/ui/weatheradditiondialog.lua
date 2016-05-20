CGUI.RegisterDialog ("WeatherAdditionDialog", function ()
	local self = CGUI.CreateDialog ("BaseWeatherDialog")
	self:SetTitle ("Add weather...")
	
	self.OK:SetText ("Add")
	self.OK:AddEventListener ("Click", function (button)
		if self.Duration:Validate () then
			RunConsoleCommand ("_weatherui_add_weather", self.MultiChoice:GetSelectedValue (), self.Duration:GetValue ())
			self:Close ()
		end
	end)
	
	return self
end)