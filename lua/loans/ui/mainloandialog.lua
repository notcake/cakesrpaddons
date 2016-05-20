local LoanDialog = nil

CGUI.RegisterDialog ("LoanDialog", function ()
	local self = CGUI.CreateDialog ("BaseDialog")
	self:SetTitle ("Secure Banking Solutions")
	self:SetSize (ScrW () * 0.5, ScrH () * 0.5)
	
	self.Tabs = vgui.Create ("DPropertySheet", self)
	self.Tabs:AddSheet ("My loans", CGUI.CreateView ("ActiveLoanView"), "gui/silkicons/money", false, false, "View your outstanding loans")
	
	if CLoans.CanApproveLoans (LocalPlayer ()) then
		self.Tabs:AddSheet ("Accept loans", CGUI.CreateView ("LoanApprovalView"), "gui/silkicons/money_dollar", false, false, "Accept loan applications")
	end
	
	self:AddLayouter (function (self)
		self:SetSkin ("DarkRP")
	
		self.Tabs:SetPos (8, 28)
		self.Tabs:SetSize (self:GetWide () - 16, self:GetTall () - 36)
	end)
	
	self:AddEventListener ("Close", function (self)
		RunConsoleCommand ("_loan_ui_closed")
		LoanDialog = nil
	end)
	
	if derma.GetSkinTable () ["DarkRP"] then
		function self:Paint ()
			CGUI.GetRenderer ("DarkRPFrame") (self)
		end
	end
	
	return self
end)

usermessage.Hook ("bank_terminal_open_ui", function (umsg)
	if not LoanDialog then
		LoanDialog = CGUI.CreateDialog ("LoanDialog")
		RunConsoleCommand ("_loan_ui_opened")
	end
	LoanDialog:ShowDialog ()
end)