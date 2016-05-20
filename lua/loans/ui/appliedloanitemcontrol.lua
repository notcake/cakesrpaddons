CGUI.RegisterControl ("AppliedLoanItem", function ()
	local self = CGUI.CreateControl ("BaseLoanItem")
	
	self:AddEventListener ("LoanUpdated", function (self)
		self.Title:SetText (self:GetLoan ():GetBorrowerName ())
		self.State:SetText ("$" .. tostring (self:GetLoan ():GetAmount ()) .. " for " .. tostring (self:GetLoan ():GetDuration ()) .. " minutes at " .. tostring (self:GetLoan ():GetInterest ()) .. "% overall interest")
	end)
	return self
end)