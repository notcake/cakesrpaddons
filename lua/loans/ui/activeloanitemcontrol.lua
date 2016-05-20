CGUI.RegisterControl ("ActiveLoanItem", function (loan)
	local self = CGUI.CreateControl ("BaseLoanItem", loan)
	
	self:AddEventListener ("LoanUpdated", function (self)
		if self:GetLoan ():GetBorrower () == LocalPlayer () then
			if self:GetLoan ():IsAwaitingBankerApproval () then
				self.Title:SetText ("$ " .. tostring (self:GetLoan ():GetAmount ()) .. " (No lender)")
			else
				self.Title:SetText ("From " .. self:GetLoan ():GetLenderName ())
			end
		else
			self.Title:SetText ("To " .. self:GetLoan ():GetBorrowerName ())
		end
		if self:GetLoan ():IsAwaitingBankerApproval () then
			self.State:SetText ("Waiting for banker...")
		elseif self:GetLoan ():IsInProgress () then
			self.State:SetText ("$" .. tostring (self:GetLoan ():GetAmount ()) .. " for " .. tostring (self:GetLoan ():GetDuration ()) .. " minutes at " .. tostring (self:GetLoan ():GetInterest ()) .. "% overall interest")
		else
			self.State:SetText ("Waiting for your acceptance...")
		end
	end)
	return self
end)