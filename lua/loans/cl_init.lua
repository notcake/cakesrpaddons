CLoans = CLoans or {}

function CLoans.CanApproveLoans (ply)
	if ply.DarkRPVars then
		return ply:Team () == TEAM_BANKER
	end
	return true
end

include ("loans/loan.lua")

include ("loans/ui/baseloandialog.lua")
include ("loans/ui/loanapplicationdialog.lua")
include ("loans/ui/loanapprovaldialog.lua")
include ("loans/ui/loanacceptancedialog.lua")

include ("loans/ui/baseloanitemcontrol.lua")
include ("loans/ui/activeloanitemcontrol.lua")
include ("loans/ui/appliedloanitemcontrol.lua")

include ("loans/ui/mainloandialog.lua")
include ("loans/ui/activeloanview.lua")
include ("loans/ui/loanapprovalview.lua")