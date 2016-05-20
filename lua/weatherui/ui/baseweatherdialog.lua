CGUI.RegisterDialog ("BaseWeatherDialog", function ()
	local self = CGUI.CreateDialog ("BaseDialog")
	self:SetTitle ("Add weather...")
	
	self.TypeLabel = vgui.Create ("DLabel", self)
	self.TypeLabel:SetText ("Type:")
	
	self.MultiChoice = vgui.Create ("GMultiChoice", self)
	for type in WeatherControl.WeatherTypes:GetWeatherTypeIterator () do
		self.MultiChoice:AddChoice (type:GetName (), type:GetID ())
	end
	self.MultiChoice:ChooseOptionID (1)
	self.MultiChoice:SetEditable (false)
	
	self.DurationLabel = vgui.Create ("DLabel", self)
	self.DurationLabel:SetText ("Duration:")
	
	self.Duration = vgui.Create ("GTextEntry", self)
	self.Duration:SetText ("0:30:00")
	self.Duration:AddValidator (function (text)
		text = text:gsub (" ", "")
		local bits = string.Explode (":", text)
		if #bits == 0 or #bits > 3 then
			return false, "Not a valid time."
		end
		for k, v in pairs (bits) do
			bits [k] = tonumber (bits [k])
			if not bits [k] or bits [k] < 0 then
				return false, "Not a valid time."
			end
		end
		local seconds = 0
		if #bits == 3 then
			seconds = bits [3] + 60 * bits [2] + 60 * 60 * bits [1]
		elseif #bits == 2 then
			seconds = bits [2] + 60 * bits [1]
		else
			seconds = bits [1]
		end
		self.Duration:SetValue (seconds)
		return true
	end)
	
	self.Feedback = vgui.Create ("DLabel", self)
	self.Duration:SetFeedbackLabel (self.Feedback)
	
	self.OK = vgui.Create ("GButton", self)
	self.OK:SetSize (80, 28)
	self.OK:SetText ("Add")
	
	self.Cancel = vgui.Create ("GButton", self)
	self.Cancel:SetSize (80, 28)
	self.Cancel:SetText ("Cancel")
	self.Cancel:AddEventListener ("Click", function (button)
		self:Close ()
	end)
	
	self:AddLayouter (function (self)
		local x, y = 8, 28
		self.TypeLabel:SetPos (x, y)
		self.MultiChoice:SetPos (x + self.TypeLabel:GetWide (), y)
		self.MultiChoice:SetWide (self:GetWide () - x - self.TypeLabel:GetWide () - 8)
		y = y + self.MultiChoice:GetTall () + 8
		
		self.DurationLabel:SetPos (x, y)
		self.Duration:SetPos (x + self.DurationLabel:GetWide (), y)
		self.Duration:SetWide (self:GetWide () - x - self.DurationLabel:GetWide () - 8)
		y = y + self.Duration:GetTall ()
		
		self.Feedback:SetPos (x, y)
		self.Feedback:SetWide (self:GetWide () - 16)
		
		self.Cancel:SetPos (self:GetWide () - 8 - self.Cancel:GetWide (), self:GetTall () - 8 - self.Cancel:GetTall ())
		self.OK:SetPos (self:GetWide () - 16 - self.Cancel:GetWide () - self.OK:GetWide (), self:GetTall () - 8 - self.OK:GetTall ())
	end)
	
	return self
end)