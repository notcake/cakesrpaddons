local Loan = {}
Loan.__index = Loan
local NextLoanID = 1

CLoans.Loan = CUtil.MakeConstructor (Loan)

--[[
	Loan states:
		0 - Applied
		1 - Replied
		2 - In progress (accepted)
		
	Events
		Accepted
		Approved
		Declined
		Finished
		Rejected
		Removed
	
	Bankers APPROVE or REJECT the loan
	Borrowers ACCEPT or DECLINE the loan
]]

function Loan:ctor ()
	CUtil.EventProvider (self)

	self.LoanID = NextLoanID
	NextLoanID = NextLoanID + 1

	self.Lender = nil
	self.LenderName = nil
	self.LenderID = nil
	self.Borrower = nil
	self.BorrowerName = nil
	self.BorrowerID = nil
	
	self.Amount = 0
	self.Duration = 0
	self.Interest = 0
	
	self.AmountChanged = false
	self.DurationChanged = false
	self.InterestChanged = false
	
	self.BorrowerComments = nil
	self.LenderComments = nil
	
	self.EndTime = nil
	
	self.State = 0
end

-- Serialization
function Loan:Export ()
	local tbl = {}
	tbl.ID = self.LoanID
	tbl.Borrower = self.Borrower
	tbl.BorrowerName = self.BorrowerName
	tbl.Lender = self.Lender
	tbl.LenderName = self.LenderName
	tbl.Amount = self.Amount
	tbl.Duration = self.Duration
	tbl.Interest = self.Interest
	
	tbl.State = self.State
	
	tbl.LenderComments = self.LenderComments
	tbl.BorrowerComments = self.BorrowerComments
	
	tbl.EndTime = self.EndTime
	return tbl
end

-- Import initial loan application data
function Loan:ImportApplication (ply, tbl)
	self.Borrower = ply
	self.BorrowerName = ply:Name ()
	self.BorrowerID = ply:SteamID ()
	
	self.Amount = math.floor (tbl.Amount > 0 and tbl.Amount or 1)
	self.Duration = tbl.Duration >= 0 and tbl.Duration or 30
	self.Interest = tbl.Interest >= 0 and tbl.Interest or 0
	self.BorrowerComments = tbl.Comments
end

-- Import datastreamed loan data from the server
function Loan:ImportDatastream (tbl)
	self.LoanID = tbl.ID
	
	self.Borrower = tbl.Borrower
	self.BorrowerName = tbl.BorrowerName
	self.BorrowerID = self.Borrower:SteamID ()
	self.Lender = tbl.Lender
	self.LenderName = tbl.LenderName
	if self.Lender then
		self.LenderID = self.Lender:SteamID ()
	end
	self.Amount = tbl.Amount
	self.Duration = tbl.Duration
	self.Interest = tbl.Interest
	self.BorrowerComments = tbl.BorrowerComments
	self.LenderComments = tbl.LenderComments
	
	self.EndTime = tbl.EndTime
	
	self.State = tbl.State
end

-- End of serialization

function Loan:Accept ()
	self.State = 2
	
	self.EndTime = CurTime () + self:GetDuration () * 60
	self:DispatchEvent ("Accepted")
end

function Loan:Approve (ply, tbl)
	self.State = 1
	
	self.Lender = ply
	self.LenderName = ply:Name ()
	self.LenderID = ply:SteamID ()
	
	if tbl.Amount and math.floor (tbl.Amount) > 0 then
		self.Amount = math.floor (tbl.Amount)
		self.AmountChanged = true
	end
	
	if tbl.Duration and tbl.Duration > 0 then
		self.Duration = tbl.Duration
		self.DurationChanged = true
	end
	
	if tbl.Interest and tbl.Interest >= 0 then
		self.Interest = tbl.Interest
		self.InterestChanged = true
	end
	
	self.LenderComments = tbl.Comments
	self:DispatchEvent ("Approved", ply)
end

function Loan:CanApprove (ply, tbl)
	local amount = self.Amount
	
	if tbl.Amount and math.floor (tbl.Amount) > 0 then
		amount = math.floor (tbl.Amount)
	end
	return CLoans.CanPlayerAfford (ply, amount)
end

function Loan:Cancel ()
	self:DispatchEvent ("Cancel")
	self:Remove ()
end

function Loan:Decline ()
	self:DispatchEvent ("Declined")
	self:Remove ()
end

function Loan:Finish ()
	self:DispatchEvent ("Finished")
	self:Remove ()
end

function Loan:GetAmount ()
	return self.Amount
end

function Loan:GetBorrower ()
	return self.Borrower
end

function Loan:GetBorrowerID ()
	return self.BorrowerID
end

function Loan:GetBorrowerName ()
	return self.BorrowerName
end

function Loan:GetBorrowerComments ()
	return self.BorrowerComments
end

function Loan:GetDuration ()
	return self.Duration
end

function Loan:GetFormattedDuration ()
	return tostring (math.floor (self.Duration / 60)) .. ":" .. tostring (self.Duration % 60)
end

function Loan:GetFormattedTimeLeft ()
	local timeleft = self:GetTimeLeft ()
	local hours = math.floor (timeleft / 3600)
	timeleft = timeleft - hours * 3600
	hours = tostring (hours)
	local minutes = "0" .. tostring (math.floor (timeleft / 60))
	local seconds = "0" .. tostring (math.floor (timeleft % 60))
	return hours .. ":" .. minutes:Right (2) .. ":" .. seconds:Right (2)
end

function Loan:GetInterest ()
	return self.Interest
end

function Loan:GetLender ()
	return self.Lender
end

function Loan:GetLenderID ()
	return self.LenderID
end

function Loan:GetLenderName ()
	return self.LenderName
end

function Loan:GetLenderComments ()
	return self.LenderComments
end

function Loan:GetLoanID ()
	return self.LoanID	
end

function Loan:GetRepayAmount ()
	return math.Round (self.Amount * (1 + self:GetInterest () * 0.01))
end

function Loan:GetTimeLeft ()
	local timeleft = self.EndTime - CurTime ()
	if timeleft < 0 then
		timeleft = 0
	end
	return timeleft
end

function Loan:IsDue ()
	if not self.EndTime then
		return false
	end
	return CurTime () >= self.EndTime
end

function Loan:IsInProgress ()
	return self.State == 2
end

function Loan:IsApproved ()
	return self.State >= 1
end

function Loan:IsAwaitingBankerApproval ()
	return self.State == 0
end

function Loan:IsAwaitingPlayerAcceptance ()
	return self.State == 1
end

function Loan:Reject (ply)
	self:DispatchEvent ("Rejected", ply)
	self:Remove ()
end

function Loan:Remove ()
	self:DispatchEvent ("Removed")
end