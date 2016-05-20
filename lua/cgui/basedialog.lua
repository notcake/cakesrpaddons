CGUI.RegisterDialog ("BaseDialog", function ()
	local self = vgui.Create ("DFrame")
	self:SetDraggable (true)
	self:SetTitle ("Title")
	
	self.Layouters = {}
	CUtil.EventProvider (self)
	CUtil.TimerProvider (self)
	
	function self:AddLayouter (layouter)
		self.Layouters [#self.Layouters + 1] = layouter
	end
	
	function self:Close ()
		self:DispatchEvent ("Close")
		if self:GetDeleteOnClose () then
			self:Remove ()
		else
			self:SetVisible (false)
		end
	end
	
	function self:PerformLayout ()
		DFrame.PerformLayout (self)

		for _, layouter in pairs (self.Layouters) do
			layouter (self)
		end
	end
	
	function self:Remove ()
		self:DispatchEvent ("Destroyed")
		_R.Panel.Remove (self)
	end
	
	function self:ShowDialog ()
		self:Center ()
		self:MakePopup ()
		self:SetVisible (true)
	end
	
	function self:Think ()
		DFrame.Think (self)
		
		self:ProcessTimers ()
		self:DispatchEvent ("Think")
	end
	
	self:SetSize (400, 120)
	self:PerformLayout ()
	return self
end)