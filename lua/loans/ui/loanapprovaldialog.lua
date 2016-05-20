CGUI.RegisterDialog ("LoanApprovalDialog", function (loan)
	local self = CGUI.CreateDialog ("BaseLoanDialog")
	self:SetTitle ("Approve loan...")
	self:SetTall (460)
	
	self.Loan = loan
	self.AmountEntry:SetText ("$ " .. tostring (loan:GetAmount ()))
	self.TimeEntry:SetText (loan:GetFormattedDuration ())
	self.InterestEntry:SetText (tostring (loan:GetInterest ()) .. " %")
	
	self.Description = vgui.Create ("DLabel", self)
	local description = loan:GetBorrower ():Name () .. " wishes to borrow $"
	description = description .. tostring (loan:GetAmount ()) .. " for " .. tostring (loan:GetDuration ())
	description = description .. " minutes at an overall interest rate of "
	description = description .. tostring (loan:GetInterest ()) .. "%. You will be repaid $"
	description = description .. tostring (loan:GetRepayAmount ()) .. " at the end. Change any "
	description = description .. "loan parameters you disagree with below:"
	self.Description:SetText (description)
	self.Description:SetWrap (true)
	
	self.BorrowerCommentsLabel = vgui.Create ("DLabel", self)
	self.BorrowerCommentsLabel:SetText (loan:GetBorrower ():Name () .. "'s comments:")
	
	self.BorrowerComments = vgui.Create ("DLabel", self)
	self.BorrowerComments:SetText (loan:GetBorrowerComments () or "(none)")
	self.BorrowerComments:SetWrap (true)
	self.BorrowerComments:SetContentAlignment (7)
	
	self.CommentsLabel = vgui.Create ("DLabel", self)
	self.CommentsLabel:SetText ("Comments:")
	
	self.CommentsEntry = vgui.Create ("DTextEntry", self)
	self.CommentsEntry:SetAllowNonAsciiCharacters (true)
	self.CommentsEntry:SetMultiline (true)
	
	self.OK:SetText ("Approve")
	self.OK:AddEventListener ("Click", function (button)
		if not self:Validate () then
			return
		end
	
		local tbl = {}
		if self.AmountEntry.Value ~= self.Loan:GetAmount () then
			tbl.Amount = self.AmountEntry.Value
		end
		if self.TimeEntry.Value ~= self.Loan:GetDuration () then
			tbl.Duration = self.TimeEntry.Value
		end
		if self.InterestEntry.Value ~= self.Loan:GetInterest () then
			tbl.Interest = self.InterestEntry.Value
		end
		tbl.ID = self.Loan:GetLoanID ()
		tbl.Comments = self.CommentsEntry:GetText ()
		datastream.StreamToServer ("loan_approve", tbl)
		self:Close ()
	end)
	
	self.NotEnoughMoney = vgui.Create ("DLabel", self)
	self.NotEnoughMoney:SetTextColor (Color (255, 128, 128, 255))
	self.NotEnoughMoney:SetText ("You do not have enough money to hand out a loan of this size.")
	self.NotEnoughMoney:SetWrap (true)
	
	self:AddEventListener ("AmountChanged", function (_, value)
		if not LocalPlayer ().DarkRPVars or
			not LocalPlayer ().DarkRPVars.money then
			return
		end
		self.OK:SetDisabled (LocalPlayer ().DarkRPVars.money < value)
		self.NotEnoughMoney:SetVisible (LocalPlayer ().DarkRPVars.money < value)
	end)
	
	self.Reject = vgui.Create ("GButton", self)
	self.Reject:SetSize (80, 28)
	self.Reject:SetText ("Reject")
	self.Reject:AddEventListener ("Click", function (button)
		RunConsoleCommand ("_loan_reject", tostring (self.Loan:GetLoanID ()))
		self:Close ()
	end)
	
	self:AddLayouter (function (self)
		self:SetSkin ("DarkRP")
		
		self.Description:SetPos (8, 28)
		self.Description:SetSize (self:GetWide () - 16, 48)
		
		local x, y = self.InterestFeedback:GetPos ()
		x = 8
		y = y + self.InterestFeedback:GetTall () + 4
		
		self.BorrowerCommentsLabel:SetPos (x, y)
		self.BorrowerCommentsLabel:SetWide (self:GetWide () - 16)
		y = y + self.BorrowerCommentsLabel:GetTall ()
		
		self.BorrowerComments:SetPos (x + 8, y)
		self.BorrowerComments:SetSize (self:GetWide () - 24, 64)
		y = y + self.BorrowerComments:GetTall () + 4
		
		self.CommentsLabel:SetPos (x, y)
		self.CommentsLabel:SetWide (self:GetWide () - 16)
		y = y + self.CommentsLabel:GetTall ()
		
		self.CommentsEntry:SetPos (x + 8, y)
		self.CommentsEntry:SetSize (self:GetWide () - 24, 64)
		y = y + self.CommentsEntry:GetTall () + 4
		
		self.NotEnoughMoney:SetPos (x, y)
		self.NotEnoughMoney:SetSize (self:GetWide () - 16, 32)
		
		local width = self.OK:GetWide () + 8 + self.Reject:GetWide ()
		local x = (self:GetWide () - width) * 0.5
		self.OK:SetPos (x, self:GetTall () - 8 - self.OK:GetTall ())
		self.Reject:SetPos (x + self.OK:GetWide () + 8, self:GetTall () - 8 - self.Reject:GetTall ())
		self.Cancel:SetVisible (false)
	end)
	
	function self:GetInterestText (amount)
		return "You will be paid $" .. amount .. " at the end."
	end
	
	function self:GetLayoutStartPos ()
		return 8, 84
	end
	
	if derma.GetSkinTable () ["DarkRP"] then
		function self:Paint ()
			CGUI.GetRenderer ("DarkRPFrame") (self)
		end
	end
	
	return self
end)