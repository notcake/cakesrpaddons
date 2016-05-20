local ApplicationDialog = nil

CGUI.RegisterDialog ("LoanApplicationDialog", function ()
	if ApplicationDialog then
		return ApplicationDialog
	end

	local self = CGUI.CreateDialog ("BaseLoanDialog")
	self:SetTitle ("Apply for a loan...")
	self:SetSize (300, 300)
	
	self.CommentsLabel = vgui.Create ("DLabel", self)
	self.CommentsLabel:SetText ("Comments:")
	
	self.CommentsEntry = vgui.Create ("DTextEntry", self)
	self.CommentsEntry:SetAllowNonAsciiCharacters (true)
	self.CommentsEntry:SetMultiline (true)
	
	self.OK:AddEventListener ("Click", function (button)
		if self:Validate () then
			self:Submit ()
			self:Close ()
		end
	end)
	
	self:AddEventListener ("Close", function (self)
		ApplicationDialog = nil
	end)
	
	self:AddLayouter (function (self)
		self:SetSkin ("DarkRP")
		
		local x, y = self.InterestFeedback:GetPos ()
		x = 8
		y = y + self.InterestFeedback:GetTall () + 4
		self.CommentsLabel:SetPos (x, y)
		y = y + self.CommentsLabel:GetTall ()
		self.CommentsEntry:SetPos (x, y)
		self.CommentsEntry:SetSize (self:GetWide () - 16, self:GetTall () - y - 16 - self.OK:GetTall ())
	end)
	
	if derma.GetSkinTable () ["DarkRP"] then
		function self:Paint ()
			CGUI.GetRenderer ("DarkRPFrame") (self)
		end
	end
	
	function self:Submit ()
		local tbl = {}
		tbl.Amount = self.AmountEntry.Value
		tbl.Duration = self.TimeEntry.Value
		tbl.Interest = self.InterestEntry.Value
		tbl.Comments = self.CommentsEntry:GetText ()
		datastream.StreamToServer ("loan_apply", tbl)
	end
	
	function self:Validate ()
		local amount_valid = self.AmountEntry:Validate ()
		local time_valid = self.TimeEntry:Validate ()
		local interest_valid = self.InterestEntry:Validate ()
		if amount_valid and time_valid and interest_valid then
			return true
		end
		return false
	end
	
	self:AddTimer (nil, 0, self.Validate)
	return self
end)