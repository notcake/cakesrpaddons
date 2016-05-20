CGUI.RegisterControl ("BaseLoanItem", function ()
	local self = CGUI.CreateControl ("BasePanel")
	self:SetTall (72)
	self.Selected = false
	self.Pressed = false
	
	self.Title = vgui.Create ("DLabel", self)
	self.Title:SetFont ("TargetID")
	self.Title:SetText ("$")
	
	self.State = vgui.Create ("DLabel", self)
	self.State:SetFont ("TargetID")
	self.State:SetText ("No lender")
	
	function self:Deselect ()
		self:DispatchEvent ("Deselect")
		self.Selected = false
	end
	
	function self:GetBackgroundColor ()
		if not self.Loan then
			return Color (255, 255, 255, 255)
		end
		if self.Loan:IsInProgress () then
			return Color (32, 48, 32, 255)
		elseif self.Loan:IsApproved () then
			return Color (128, 64, 32, 255)
		else
			return Color (96, 32, 32, 255)
		end
	end
	
	function self:GetLoan ()
		return self.Loan
	end
	
	function self:IsPressed ()
		return self.Pressed
	end
	
	function self:IsSelected ()
		return self.Selected
	end
	
	function self:OnMousePressed ()
		self:Select ()
		
		self.Pressed = true
		self:MouseCapture (true)
		for _, pnl in pairs (self:GetTable ()) do
			if type (pnl) == "Panel" and pnl ~= self then
				local x, y = pnl:GetPos ()
				pnl:SetPos (x + 2, y + 2)
			end
		end
	end
	
	function self:OnMouseReleased ()
		self.Pressed = false
		self:MouseCapture (false)
		for _, pnl in pairs (self:GetTable ()) do
			if type (pnl) == "Panel" and pnl ~= self then
				local x, y = pnl:GetPos ()
				pnl:SetPos (x - 2, y - 2)
			end
		end
		
		if self.Hovered then
			self:DispatchEvent ("Click")
		end
	end
	
	function self:Paint ()
		local w, h = self:GetSize ()
		h = h - 2
		
		if self:IsSelected () then
			draw.RoundedBox (4, 0, 0, w, h, Color (96, 96, 255, 255))
			draw.RoundedBox (4, 2, 2, w - 4, h - 4, self:GetBackgroundColor ())
		else
			draw.RoundedBox (4, 0, 0, w, h, self:GetBackgroundColor ())
		end
		if self:GetLoan () and
			self:GetLoan ():IsInProgress () then
			local timeleft = "Due in " .. self:GetLoan ():GetFormattedTimeLeft ()
			draw.DrawText (timeleft, "TargetID", self:GetWide () - 128, self:GetTall () * 0.5, Color (255, 192, 192, 255), TEXT_ALIGN_LEFT)
		end
		if self.Pressed then
			draw.RoundedBox (4, 0, 0, w, h, Color (0, 0, 0, 64))
		elseif self.Hovered then
			draw.RoundedBox (4, 0, 0, w, h, Color (255, 255, 255, 16))
		end
	end
	
	function self:Select ()
		if self:IsSelected () then
			return
		end
		self.Selected = true
		self:DispatchEvent ("Select")
	end
	
	function self:SetLoan (loan)
		self.Loan = loan
		self.Title:SetText ("$" .. loan:GetAmount ())
		self:DispatchEvent ("LoanUpdated")
	end
	
	self:AddLayouter (function (self)
		local x, y = 8, 8
		self.Title:SetPos (x, y)
		self.Title:SetWide (self:GetWide ())
		y = y + self.Title:GetTall () + 8
		self.State:SetPos (x, y)
		self.State:SetWide (self:GetWide ())
	end)
	
	return self
end)