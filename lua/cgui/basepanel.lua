CGUI.RegisterControl ("BasePanel", function ()
	local self = vgui.Create ("DPanel")
	
	self.Layouters = {}
	CUtil.EventProvider (self)
	CUtil.TimerProvider (self)
	
	function self:AddLayouter (layouter)
		self.Layouters [#self.Layouters + 1] = layouter
	end
	
	function self:PerformLayout ()
		DPanel.PerformLayout (self)

		for _, layouter in pairs (self.Layouters) do
			layouter (self)
		end
	end
	
	function self:ShowDialog ()
		self:Center ()
		self:MakePopup ()
		self:SetVisible (true)
	end
	
	function self:Think ()
		self:ProcessTimers ()
		self:DispatchEvent ("Think")
	end
	
	self:SetSize (400, 120)
	self:PerformLayout ()
	return self
end)