local Gradient = Material ("gui/gradient_down")

CGUI.RegisterControl ("WeatherItem", function (item)
	local self = CGUI.CreateControl ("BasePanel")
	self.Selected = false
	self.WeatherItem = item
	self:SetTall (64)
	
	self.Title = vgui.Create ("DLabel", self)
	self.Title:SetFont ("TargetID")
	self.Title:SetText ("None")
	
	self.Duration = vgui.Create ("DLabel", self)
	self.Duration:SetFont ("TargetID")
	self.Duration:SetText ("0:00:00")
	
	self:AddLayouter (function (self)
		local x, y = 8, 4
		self.Title:SetPos (x, y)
		self.Title:SetWide (self:GetWide () - 16)
		y = y + self.Title:GetTall ()
		
		self.Duration:SizeToContents ()
		self.Duration:SetPos (self:GetWide () - self.Duration:GetWide () - 4, self:GetTall () - self.Duration:GetTall ())
	end)
	
	function self:Deselect ()
		if not self.Selected then
			return
		end
		self.Selected = false
		self:DispatchEvent ("Deselected")
	end
	
	function self:GetWeatherItem ()
		return self.WeatherItem
	end
	
	function self:IsHovered ()
		if self.Hovered then
			return true
		end
		return false
	end
	
	function self:IsRunning ()
		return self:GetWeatherItem () and WeatherControl.WeatherCycle:GetCurrentItem () == self:GetWeatherItem ()
	end
	
	function self:IsSelected ()
		return self.Selected
	end
	
	function self:OnCursorEntered ()
		self:DispatchEvent ("MouseOver")
	end
	
	function self:OnCursorExited ()
		self:DispatchEvent ("MouseOut")
	end
	
	function self:OnMousePressed ()
		self:Select ()
	end
	
	function self:Paint ()
		if self:IsSelected () then
			draw.RoundedBox (4, 0, 0, self:GetWide (), self:GetTall (), Color (128, 128, 255, 128))
		elseif self:IsRunning () then
			draw.RoundedBox (4, 0, 0, self:GetWide (), self:GetTall (), Color (128, 224 + 31 * math.sin (2 * math.pi / 5 * CurTime ()), 128, 128))
		else
			draw.RoundedBox (4, 0, 0, self:GetWide (), self:GetTall (), Color (128, 128, 128, 128))
		end
		surface.SetDrawColor (255, 255, 255, 32)
		surface.SetMaterial (Gradient)
		surface.DrawTexturedRect (0, 0, self:GetWide (), self:GetTall ())
		
		if self:IsRunning () then
			local timeleft = WeatherControl.WeatherCycle:GetCurrentEndTime () - CurTime ()
			draw.DrawText (CUtil.FormatTime (timeleft), "TargetID", 32, self:GetTall () - 24, Color (192, 192, 192, 255))
		end
	end
	
	function self:PaintOver ()
		if self:IsHovered () then
			surface.SetDrawColor (255, 255, 255, 32)
			surface.SetMaterial (Gradient)
			surface.DrawTexturedRect (0, 0, self:GetWide (), self:GetTall ())
		end
	end
	
	function self:Select ()
		if self.Selected then
			return
		end
		self.Selected = true
		self:DispatchEvent ("Selected")
	end
	
	function self:SetWeatherItem (item)
		self.WeatherItem = item
		self:Update ()
	end
	
	function self:Update ()
		if not self.WeatherItem then
			self.Title:SetText ("None")
			self.Duration:SetText ("00:00:00")
		else
			self.Title:SetText (WeatherControl.WeatherTypes:GetWeatherType (self.WeatherItem:GetType ()):GetName ())
			local duration = self.WeatherItem:GetDuration ()
			local hours = "00" .. tostring (math.floor (duration / 3600))
			local minutes = "00" .. tostring (math.floor (duration / 60) % 60)
			local seconds = "00" .. tostring (math.floor (duration % 60))
			self.Duration:SetText (hours:Right (2) .. ":" .. minutes:Right (2) .. ":" .. seconds:Right (2))
		end
		self:PerformLayout ()
	end
	
	self:Update ()
	return self
end)