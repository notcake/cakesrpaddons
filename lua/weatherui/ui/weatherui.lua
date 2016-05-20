CGUI.RegisterDialog ("WeatherUI", function ()
	local self = CGUI.CreateDialog ("BaseDialog")
	self:SetTitle ("Weather Control Panel")
	self:SetSize (ScrW () * 0.5, ScrH () * 0.7)
	
	self.CurrentLabel = vgui.Create ("DLabel", self)
	self.CurrentLabel:SetText ("Current Weather:")
	self.CurrentLabel:SizeToContents ()
	
	self.CurrentWeather = CGUI.CreateControl ("WeatherItem")
	self.CurrentWeather:SetParent (self)
	self.CurrentWeather:Select ()
	
	self.WeatherView = CGUI.CreateControl ("WeatherView")
	self.WeatherView:SetParent (self)
	self.WeatherView:AddEventListener ("SelectionChanged", function (_, selected)
		self:UpdateButtons ()
	end)
	
	self.Up = vgui.Create ("GButton", self)
	self.Up:SetSize (36, 28)
	self.Up:SetText ("Up")
	self.Up:SetDisabled (true)
	self.Up:AddEventListener ("Click", function (button)
		RunConsoleCommand ("_weatherui_move_up", tostring (self.WeatherView:GetSelectedItem ():GetWeatherItem ():GetID ()))
	end)
	
	self.Down = vgui.Create ("GButton", self)
	self.Down:SetSize (36, 28)
	self.Down:SetText ("Down")
	self.Down:SetDisabled (true)
	self.Down:AddEventListener ("Click", function (button)
		RunConsoleCommand ("_weatherui_move_down", tostring (self.WeatherView:GetSelectedItem ():GetWeatherItem ():GetID ()))
	end)
	
	self.Start = vgui.Create ("GButton", self)
	self.Start:SetSize (80, 28)
	self.Start:SetText ("Start")
	self.Start:SetDisabled (true)
	self.Start:AddEventListener ("Click", function (button)
		RunConsoleCommand ("_weatherui_start", tostring (self.WeatherView:GetSelectedItem ():GetWeatherItem ():GetID ()))
	end)
	
	self.Stop = vgui.Create ("GButton", self)
	self.Stop:SetSize (80, 28)
	self.Stop:SetText ("Stop")
	self.Stop:AddEventListener ("Click", function (button)
		RunConsoleCommand ("_weatherui_stop")
	end)
	
	self.AddButton = vgui.Create ("GButton", self)
	self.AddButton:SetSize (80, 28)
	self.AddButton:SetText ("Add")
	self.AddButton:AddEventListener ("Click", function (button)
		CGUI.CreateDialog ("WeatherAdditionDialog"):ShowDialog ()
	end)
	
	self.ModifyButton = vgui.Create ("GButton", self)
	self.ModifyButton:SetSize (80, 28)
	self.ModifyButton:SetText ("Modify")
	self.ModifyButton:AddEventListener ("Click", function (button)
		CGUI.CreateDialog ("WeatherModificationDialog", self.WeatherView:GetSelectedItem ():GetWeatherItem ()):ShowDialog ()
	end)
	
	self.RemoveButton = vgui.Create ("GButton", self)
	self.RemoveButton:SetSize (80, 28)
	self.RemoveButton:SetText ("Remove")
	self.RemoveButton:SetDisabled (true)
	self.RemoveButton:AddEventListener ("Click", function (button)
		RunConsoleCommand ("_weatherui_remove", tostring (self.WeatherView:GetSelectedItem ():GetWeatherItem ():GetID ()))
	end)
	
	self:AddLayouter (function (self)
		local x, y = 8, 28
		self.CurrentLabel:SetPos (x, y)
		y = y + self.CurrentLabel:GetTall () + 8
		
		self.CurrentWeather:SetPos (x + 8, y)
		self.CurrentWeather:SetWide (self:GetWide () - 24)
		y = y + self.CurrentWeather:GetTall () + 8
		
		self.Start:SetPos (x, self:GetTall () - 8 - self.Start:GetTall ())
		self.Stop:SetPos (x + self.Start:GetWide () + 8, self:GetTall () - 8 - self.Stop:GetTall ())
		self.RemoveButton:SetPos (self:GetWide () - 8 - self.RemoveButton:GetWide (), self:GetTall () - 8 - self.RemoveButton:GetTall ())
		self.ModifyButton:SetPos (self:GetWide () - 16 - self.RemoveButton:GetWide () - self.ModifyButton:GetWide (), self:GetTall () - 8 - self.ModifyButton:GetTall ())
		self.AddButton:SetPos (self:GetWide () - 24 - self.RemoveButton:GetWide () - self.ModifyButton:GetWide () - self.AddButton:GetWide (), self:GetTall () - 8 - self.AddButton:GetTall ())
		
		self.WeatherView:SetPos (x, y)
		self.WeatherView:SetSize (self:GetWide () - 24 - self.Up:GetWide (), self:GetTall () - y - 16 - self.AddButton:GetTall ())
		
		local mid = y + 0.5 * self.WeatherView:GetTall ()
		self.Up:SetPos (self:GetWide () - self.Up:GetWide () - 8, mid - 8 - self.Up:GetTall ())
		self.Down:SetPos (self:GetWide () - self.Down:GetWide () - 8, mid + 8)
	end)
	
	self:AddEventListener ("Close", function (self)
		RunConsoleCommand ("_weatherui_ui_closed")
		
		WeatherControl.WeatherCycle:RemoveEventListener ("ItemAdded", tostring (self))
		WeatherControl.WeatherCycle:RemoveEventListener ("ItemChanged", tostring (self))
		WeatherControl.WeatherCycle:RemoveEventListener ("ItemRemoved", tostring (self))
		WeatherControl.WeatherCycle:RemoveEventListener ("ItemMovedUp", tostring (self))
		WeatherControl.WeatherCycle:RemoveEventListener ("Started", tostring (self))
		WeatherControl.WeatherCycle:RemoveEventListener ("Stopped", tostring (self))
	end)
	
	function self:UpdateButtons ()
		local selected = self.WeatherView:GetSelectedItem ()
		if selected then
			self.Up:SetDisabled (selected:GetWeatherItem ():GetID () == 1)
			self.Down:SetDisabled (selected:GetWeatherItem ():GetID () == WeatherControl.WeatherCycle:GetItemCount ())
			self.Start:SetDisabled (false)
			self.ModifyButton:SetDisabled (false)
			self.RemoveButton:SetDisabled (false)
		else
			self.Up:SetDisabled (true)
			self.Down:SetDisabled (true)
			self.Start:SetDisabled (true)
			self.ModifyButton:SetDisabled (true)
			self.RemoveButton:SetDisabled (true)
		end
	end
	
	WeatherControl.WeatherCycle:AddEventListener ("ItemAdded", tostring (self), function (_, item)
		self.WeatherView:AddItem (item)
	end)
	
	WeatherControl.WeatherCycle:AddEventListener ("ItemChanged", tostring (self), function (_, item)
		self.WeatherView:UpdateItem (item)
	end)
	
	WeatherControl.WeatherCycle:AddEventListener ("ItemRemoved", tostring (self), function (_, item)
		self.WeatherView:RemoveItem (item)
	end)
	
	WeatherControl.WeatherCycle:AddEventListener ("ItemMovedUp", tostring (self), function (_, item, id)
		self.WeatherView:MoveItemUp (id)
		self:UpdateButtons ()
	end)
	
	WeatherControl.WeatherCycle:AddEventListener ("Started", tostring (self), function (_, item)
		self.CurrentWeather:SetWeatherItem (item)
	end)
	
	WeatherControl.WeatherCycle:AddEventListener ("Stopped", tostring (self), function (_, item)
		self.CurrentWeather:SetWeatherItem (nil)
	end)
	
	return self
end)