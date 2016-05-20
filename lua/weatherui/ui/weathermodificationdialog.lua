CGUI.RegisterDialog ("WeatherModificationDialog", function (weather)
	local self = CGUI.CreateDialog ("BaseWeatherDialog")
	self:SetTitle ("Modify weather...")
	self.WeatherItem = weather
	
	self.MultiChoice:ChooseOptionID (self.MultiChoice:FindOption (WeatherControl.WeatherTypes:GetWeatherType (weather:GetType ()):GetName ()))
	self.Duration:SetText (CUtil.FormatTime (weather:GetDuration ()))
	
	self.OK:SetText ("Change")
	self.OK:AddEventListener ("Click", function (button)
		if self.Duration:Validate () then
			RunConsoleCommand ("_weatherui_modify_weather", tostring (self.WeatherItem:GetID ()), self.MultiChoice:GetSelectedValue (), self.Duration:GetValue ())
			self:Close ()
		end
	end)
	
	return self
end)