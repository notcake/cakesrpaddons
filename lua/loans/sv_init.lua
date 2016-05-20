CLoans = CLoans or {}
CLoans.Loans = CLoans.Loans or {}
CLoans.UIPlayers = {}

--[[
	Internal Console Commands:
		_loan_ui_opened
		_loan_ui_closed
		_loan_accept
			long ID					- loan ID
		_loan_decline
			long ID					- loan ID
		_loan_reject
			long ID					- loan ID
	
	Usermessages:
		bank_terminal_open_ui		- tells client to open the loan UI
		loan_application_removed	- removes a loan from the acceptance tab
			long ID
		loan_removed				- removes a loan from the active loans tab
			long ID
	
	Client to Server Datastreams:
		loan_apply
			Amount					- amount of cash
			Time					- time in minutes
			Interest				- interest rate
			Comments				- comments
			
		loan_approve
			ID						- loan ID
			(Amount)				- if changed
			(Time)					- if changed
			(Interest)				- if changed
			Comments				- comments
	
	Server to Client Datastreams:
		loan_info				- loans in progress
			[Loans]
				<Loan>
		loan_application		- loan applications from others
			[Loans]
				<Loan>
]]

function CLoans.AddLoan (loan)
	CLoans.Loans [loan:GetLoanID ()] = loan
	
	local tbl = {loan:Export ()}
	if CLoans.ShouldUpdatePlayer (loan:GetBorrower ()) then
		datastream.StreamToClients (loan:GetBorrower (), "loan_info", tbl)
	end
	local lenders = CLoans.GetLenders (CLoans.ShouldUpdatePlayer)
	if #lenders > 0 then
		datastream.StreamToClients (loan:GetBorrower (), "loan_application", tbl)
	end
	
	loan:AddEventListener ("Accepted", function (loan)
		datastream.StreamToClients ({loan:GetBorrower (), loan:GetLender ()}, "loan_info", {loan:Export ()})
		CLoans.AddPlayerMoney (loan:GetBorrowerID (), loan:GetAmount ())
		
		CLoans.MessagePlayer (loan:GetBorrower (), Color (128, 255, 128, 255), "You have accepted the loan offer from " .. loan:GetLenderName () .. ".")
		CLoans.MessagePlayer (loan:GetLender (), Color (128, 255, 128, 255), loan:GetBorrowerName () .. " has accepted your loan offer.")
	end)
	loan:AddEventListener ("Approved", function (loan, ply)
		local lenders = CLoans.GetLenders (CLoans.ShouldUpdatePlayer)
		if #lenders > 0 then
			umsg.Start ("loan_application_removed", lenders)
				umsg.Long (loan:GetLoanID ())
			umsg.End ()
		end
		datastream.StreamToClients ({loan:GetLender (), loan:GetBorrower ()}, "loan_info", {loan:Export ()})
		CLoans.AddPlayerMoney (loan:GetLenderID (), -loan:GetAmount ())
		
		CLoans.MessagePlayer (loan:GetLender (), Color (128, 255, 128, 255), "You have approved " .. loan:GetBorrowerName () .. "'s loan application for $" .. tostring (loan:GetAmount ()) .. ".")
		CLoans.MessagePlayer (loan:GetBorrower (), Color (128, 255, 128, 255), loan:GetLenderName() .. " has approved your loan application for $" .. tostring (loan:GetAmount ()) .. ".")
	end)
	loan:AddEventListener ("Declined", function (loan)
		umsg.Start ("loan_removed", {loan:GetBorrower (), loan:GetLender ()})
			umsg.Long (loan:GetLoanID ())
		umsg.End ()
		CLoans.MessagePlayer (loan:GetBorrower (), Color (128, 255, 128, 255), "You have declined the loan offer from " .. loan:GetLenderName () .. ".")
		CLoans.MessagePlayer (loan:GetLender (), Color (128, 255, 128, 255), loan:GetBorrowerName () .. " has declined your loan offer.")
		
		-- Do not refund the banker here, it gets done in the Remove event.
	end)
	loan:AddEventListener ("Finished", function (loan)
		CLoans.MessagePlayer (loan:GetBorrower (), Color (128, 255, 128, 255), "Your loan has ended and you have repaid " .. loan:GetLenderName () .. " $" .. tostring (loan:GetRepayAmount ()) .. ".")
		CLoans.MessagePlayer (loan:GetLender (), Color (128, 255, 128, 255), "Your loan to " .. loan:GetBorrowerName () .. " has ended and you have been repaid $" .. tostring (loan:GetRepayAmount ()) .. ".")
		
		-- Do not exchange money here, it gets done in the Remove event.
	end)
	loan:AddEventListener ("Rejected", function (loan, ply)
		CLoans.MessagePlayer (loan:GetBorrower (), Color (128, 255, 128, 255), ply:Name () .. " has rejected your loan application for $" .. tostring (loan:GetAmount ()) .. ".")
		CLoans.MessagePlayer (ply, Color (128, 255, 128, 255), "You have rejected ".. loan:GetBorrowerName () .. "'s loan application.")
	end)
	loan:AddEventListener ("Removed", function (loan)
		if loan:IsAwaitingBankerApproval () then
			local lenders = CLoans.GetLenders (CLoans.ShouldUpdatePlayer)
			if #lenders > 0 then
				umsg.Start ("loan_application_removed", lenders)
					umsg.Long (loan:GetLoanID ())
				umsg.End ()
			end
		end
		if CLoans.ShouldUpdatePlayer (loan:GetBorrower ())then
			umsg.Start ("loan_removed", loan:GetBorrower ())
				umsg.Long (loan:GetLoanID ())
			umsg.End ()
		end
		if CLoans.ShouldUpdatePlayer (loan:GetLender ())then
			umsg.Start ("loan_removed", loan:GetLender ())
				umsg.Long (loan:GetLoanID ())
			umsg.End ()
		end
		if loan:IsInProgress () then
			CLoans.AddPlayerMoney (loan:GetBorrowerID (), -loan:GetRepayAmount ())
			CLoans.AddPlayerMoney (loan:GetLenderID (), loan:GetRepayAmount ())
		elseif loan:IsAwaitingPlayerAcceptance () then
			CLoans.AddPlayerMoney (loan:GetLenderID (), loan:GetAmount ())
		end
		CLoans.Loans [loan:GetLoanID ()] = nil
	end)
end

function CLoans.AddPlayerMoney (steamid, money)
	local ply = CLoans.GetPlayerBySteamID (steamid)
	if ply and ply.AddMoney then
		ply:AddMoney (money)
	elseif DB then
		local _ValidEntity = ValidEntity
		ply = {
			SetDarkRPVar = function (ply, name, value)
				ply.Money = value
			end,
			SteamID = function (ply) return steamid end
		}
		ValidEntity = function () return true end
		
		DB.RetrieveMoney (ply)
		DB.StoreMoney (ply, ply.Money + money)
		
		ValidEntity = _ValidEntity
	end
end

function CLoans.CanApproveLoans (ply)
	if ply.DarkRPVars then
		return ply:Team () == TEAM_BANKER
	end
	return true
end

function CLoans.CanPlayerAfford (ply, amount)
	if ply.CanAfford then
		return ply:CanAfford (amount)
	end
	return true
end

function CLoans.GetLoans (filter)
	local loans = {}
	filter = filter or function (loan) return true end
	for _, loan in pairs (CLoans.Loans) do
		if filter (loan) then
			loans [#loans + 1] = loan
		end
	end
	return loans
end

function CLoans.GetLenders (filter)
	local lenders = {}
	filter = filter or function (ply) return true end
	for _, ply in pairs (player.GetAll ()) do
		if CLoans.CanApproveLoans (ply) and
			filter (ply) then
			lenders [#lenders + 1] = ply
		end
	end
	return lenders
end

function CLoans.GetPlayerBySteamID (id)
	for _, ply in ipairs (player.GetAll ()) do
		if ply:SteamID () == id then
			return ply
		end
	end
	return nil
end

function CLoans.GetPlayerMoney (ply)
	if ply.DarkRPVars and
		ply.DarkRPVars.money then
		return ply.DarkRPVars.money
	end
	return 0
end

function CLoans.MessagePlayer (ply, color, text)
	if not ply or not ply:IsValid () then
		return
	end
	if TalkToPerson then
		TalkToPerson (ply, color, text)
	else
		ply:PrintMessage (HUD_PRINTTALK, text)
	end
end

function CLoans.ShouldUpdatePlayer (ply)
	return CLoans.UIPlayers [ply] or false
end

resource.AddFile ("materials/gui/silkicons/money.vmt")
resource.AddFile ("materials/gui/silkicons/money.vtf")
resource.AddFile ("materials/gui/silkicons/money_dollar.vmt")
resource.AddFile ("materials/gui/silkicons/money_dollar.vtf")

AddCSLuaFile ("loans/cl_init.lua")
AddCSLuaFile ("loans/loan.lua")

AddCSLuaFile ("loans/ui/baseloandialog.lua")
AddCSLuaFile ("loans/ui/loanapplicationdialog.lua")
AddCSLuaFile ("loans/ui/loanapprovaldialog.lua")
AddCSLuaFile ("loans/ui/loanacceptancedialog.lua")

AddCSLuaFile ("loans/ui/baseloanitemcontrol.lua")
AddCSLuaFile ("loans/ui/activeloanitemcontrol.lua")
AddCSLuaFile ("loans/ui/appliedloanitemcontrol.lua")

AddCSLuaFile ("loans/ui/mainloandialog.lua")
AddCSLuaFile ("loans/ui/activeloanview.lua")
AddCSLuaFile ("loans/ui/loanapprovalview.lua")
include ("loans/loan.lua")

timer.Create ("Loans", 1, 0, function ()
	local done = {}
	for _, loan in pairs (CLoans.Loans) do
		if loan:IsDue () then
			done [#done + 1] = loan
		end
	end
	for _, loan in ipairs (done) do
		loan:Finish ()
	end
end)

hook.Add ("EntityRemoved", "Loans", function (ply)
	if not ply:IsPlayer () then
		return
	end
	CLoans.UIPlayers [ply] = nil
	local loans = CLoans.GetLoans (function (loan)
		return loan:GetLender () == ply or loan:GetBorrower () == ply and not loan:IsInProgress ()
	end)
	for _, loan in ipairs (loans) do
		loan:Remove ()
	end
end)

hook.Add ("ShutDown", "Loans", function ()
	local loans = CLoans.GetLoans ()
	for _, loan in ipairs (loans) do
		loan:Remove ()
	end
end)

datastream.Hook ("loan_apply", function (ply, _, _, _, tbl)
	local loan = CLoans.Loan ()
	loan:ImportApplication (ply, tbl)
	
	CLoans.AddLoan (loan)
end)

datastream.Hook ("loan_approve", function (ply, _, _, _, tbl)
	local loan = CLoans.Loans [tbl.ID]
	if not loan then
		return
	end
	if not loan:CanApprove (ply, tbl) then
		CLoans.MessagePlayer (ply, Color (128, 255, 128, 255), "You do not have enough money to hand out a loan of this size.")
		return
	end
	loan:Approve (ply, tbl)
end)

concommand.Add ("_loan_ui_closed", function (ply, _, _)
	CLoans.UIPlayers [ply] = nil
end)

concommand.Add ("_loan_ui_opened", function (ply, _, _)
	CLoans.UIPlayers [ply] = true
	
	local loans = CLoans.GetLoans (function (loan)
		return loan:GetBorrower () == ply or loan:GetLender () == ply
	end)
	for k, v in ipairs (loans) do
		loans [k] = v:Export ()
	end
	datastream.StreamToClients (ply, "loan_info", loans)
	loans = CLoans.GetLoans (function (loan) return not loan:IsApproved () end)
	for k, v in ipairs (loans) do
		loans [k] = v:Export ()
	end
	datastream.StreamToClients (ply, "loan_application", loans)
end)

-- Banker concommands
concommand.Add ("_loan_reject", function (ply, _, args)
	if #args < 1 then
		return
	end
	local id = tonumber (args [1])
	if not id or not CLoans.Loans [id] then
		return
	end
	if not CLoans.CanApproveLoans (ply) or not
		CLoans.Loans [id]:IsAwaitingBankerApproval () then
		return
	end
	CLoans.Loans [id]:Reject (ply)
end)

-- Borrower concommands
concommand.Add ("_loan_accept", function (ply, _, args)
	if #args < 1 then
		return
	end
	local id = tonumber (args [1])
	if not id or not CLoans.Loans [id] then
		return
	end
	local loan = CLoans.Loans [id]
	if not loan:IsAwaitingPlayerAcceptance () or
		loan:GetBorrower () ~= ply then
		return
	end
	CLoans.Loans [id]:Accept (ply)
end)

concommand.Add ("_loan_cancel", function (ply, _, args)
	if #args < 1 then
		return
	end
	local id = tonumber (args [1])
	if not id or not CLoans.Loans [id] then
		return
	end
	local loan = CLoans.Loans [id]
	if not loan:IsAwaitingBankerApproval () or
		loan:GetBorrower () ~= ply then
		return
	end
	CLoans.Loans [id]:Cancel (ply)
end)

concommand.Add ("_loan_decline", function (ply, _, args)
	if #args < 1 then
		return
	end
	local id = tonumber (args [1])
	if not id or not CLoans.Loans [id] then
		return
	end
	local loan = CLoans.Loans [id]
	if not loan:IsAwaitingPlayerAcceptance () or
		loan:GetBorrower () ~= ply then
		return
	end
	CLoans.Loans [id]:Decline (ply)
end)