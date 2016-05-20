local SettingsDialog = nil
surface.CreateFont ("Trebuchet", 22, 400, true, false, "MoneyPrinterButton")
surface.CreateFont ("Trebuchet", 22, 400, true, false, "MoneyPrinterSmallText")
surface.CreateFont ("Trebuchet", 24, 400, true, false, "MoneyPrinterText")
surface.CreateFont ("Trebuchet", 64, 400, true, false, "MoneyPrinterMoney")

CGUI.RegisterDialog ("MoneyPrinterSettingsDialog", function ()
	local Dialog = CGUI.CreateDialog ("BaseDialog")
	Dialog:SetSize (600, 364)
	Dialog:SetTitle ("Medium Money Printer")
	
	Dialog.Printer = nil
	Dialog.Money = nil
	Dialog.Overdrive = nil
	Dialog.ShouldStoreMoney = nil
	Dialog.Password = nil
	
	local font = "TargetID"
	
	Dialog.StoredLabel = vgui.Create ("DLabel", Dialog)
	Dialog.StoredLabel:SetText ("Stored cash:")
	Dialog.StoredLabel:SetPos (24, 48)
	Dialog.StoredLabel:SetFont ("MoneyPrinterText")
	Dialog.StoredLabel:SizeToContents ()
	
	Dialog.StoredNumber = vgui.Create ("DLabel", Dialog)
	Dialog.StoredNumber:SetText ("$0")
	Dialog.StoredNumber:SetFont ("MoneyPrinterMoney")
	Dialog.StoredNumber:SetPos (96, 48)
	Dialog.StoredNumber:SetTextColor (Color (0, 96, 0, 255))
	
	Dialog.TakeButton = vgui.Create ("GButton", Dialog)
	Dialog.TakeButton:SetSize (160, 48)
	Dialog.TakeButton:SetText ("Take")
	Dialog.TakeButton:SetFont ("MoneyPrinterButton")
	Dialog.TakeButton:SetDisabled (true)
	
	function Dialog.TakeButton:DoClick ()
		surface.PlaySound ("buttons/button15.wav")
		RunConsoleCommand ("_money_printer_take_money", Dialog:GetPrinter ():EntIndex ())
	end
	
	Dialog.OverdriveLabel = vgui.Create ("DLabel", Dialog)
	Dialog.OverdriveLabel:SetText ("Overdrive: ")
	Dialog.OverdriveLabel:SetFont ("MoneyPrinterText")
	Dialog.OverdriveLabel:SizeToContents ()
	
	Dialog.OverdriveState = vgui.Create ("DLabel", Dialog)
	Dialog.OverdriveState:SetText ("Off")
	Dialog.OverdriveState:SetFont ("MoneyPrinterText")
	Dialog.OverdriveState:SizeToContents ()
	
	Dialog.OverdriveDescription = vgui.Create ("DLabel", Dialog)
	Dialog.OverdriveDescription:SetText ("Prints $400 per cycle\nRuns at 2x speed\nOverheating is 3x more likely")
	Dialog.OverdriveDescription:SetFont ("MoneyPrinterSmallText")
	Dialog.OverdriveDescription:SetAlpha (128)
	Dialog.OverdriveDescription:SizeToContents ()
	
	Dialog.OverdriveButton = vgui.Create ("GButton", Dialog)
	Dialog.OverdriveButton:SetText ("Enable Overdrive")
	Dialog.OverdriveButton:SetFont ("MoneyPrinterButton")
	Dialog.OverdriveButton:SetSize (160, 48)
	
	Dialog.OverdriveButton:AddEventListener ("Click", function (self)
		surface.PlaySound ("buttons/button15.wav")
		RunConsoleCommand ("_money_printer_set_overdrive", tostring (Dialog:GetPrinter ():EntIndex ()), tostring (not Dialog.Overdrive))
	end)
	
	Dialog.PrintingModeLabel = vgui.Create ("DLabel", Dialog)
	Dialog.PrintingModeLabel:SetText ("Printing mode:")
	Dialog.PrintingModeLabel:SetFont ("MoneyPrinterText")
	Dialog.PrintingModeLabel:SizeToContents ()
	
	Dialog.PrintingMode = vgui.Create ("DLabel", Dialog)
	Dialog.PrintingMode:SetText ("External")
	Dialog.PrintingMode:SetFont ("MoneyPrinterText")
	Dialog.PrintingMode:SetTextColor (Color (224, 224, 224, 255))
	Dialog.PrintingMode:SizeToContents ()
	
	Dialog.PrintingModeDescription = vgui.Create ("DLabel", Dialog)
	Dialog.PrintingModeDescription:SetText ("Printed cash is stored inside the machine")
	Dialog.PrintingModeDescription:SetFont ("MoneyPrinterSmallText")
	Dialog.PrintingModeDescription:SizeToContents ()
	
	Dialog.PrintingModeButton = vgui.Create ("GButton", Dialog)
	Dialog.PrintingModeButton:SetText ("External Printing")
	Dialog.PrintingModeButton:SetFont ("MoneyPrinterButton")
	Dialog.PrintingModeButton:SetSize (160, 48)
	
	Dialog.PrintingModeButton:AddEventListener ("Click", function (self)
		surface.PlaySound ("buttons/button15.wav")
		RunConsoleCommand ("_money_printer_set_store", tostring (Dialog:GetPrinter ():EntIndex ()), tostring (not Dialog.ShouldStoreMoney))
	end)
	
	Dialog.PasswordLabel = vgui.Create ("DLabel", Dialog)
	Dialog.PasswordLabel:SetText ("Password: ")
	Dialog.PasswordLabel:SetFont ("MoneyPrinterText")
	Dialog.PasswordLabel:SizeToContents ()
	
	Dialog.PasswordString = vgui.Create ("DLabel", Dialog)
	Dialog.PasswordString:SetText ("None")
	Dialog.PasswordString:SetTextColor (Color (128, 128, 128, 255))
	Dialog.PasswordString:SetFont ("MoneyPrinterText")
	Dialog.PasswordString:SizeToContents ()
	
	Dialog.PasswordButton = vgui.Create ("GButton", Dialog)
	Dialog.PasswordButton:SetText ("Change")
	Dialog.PasswordButton:SetFont ("MoneyPrinterButton")
	Dialog.PasswordButton:SetSize (160, 48)
	
	Dialog.PasswordButton:AddEventListener ("Click", function (self)
		local PasswordPrompt = CGUI.CreateDialog ("BaseQuery")
		PasswordPrompt:SetTitle ("Change password...")
		PasswordPrompt:SetPrompt ("Enter the new password:")
		PasswordPrompt:SetInputString (Dialog.Password)
		PasswordPrompt:SetSubmitText ("Change")
		
		PasswordPrompt:SetSkin ("DarkRP")
		
		if derma.GetSkinTable () ["DarkRP"] then
			function PasswordPrompt:Paint ()
				CGUI.GetRenderer ("DarkRPFrame") (self)
			end
		end
		
		PasswordPrompt:AddValidator (function (_, str)
			if str:find ("[^1-9]") then
				return false, "Your password can only contain the digits 1 to 9!"
			end
			if str:len () > 4 then
				return false, "Your password cannot be more than 4 digits."
			end
		end)
		
		PasswordPrompt:AddEventListener ("Submit", function (self)
			surface.PlaySound ("buttons/button15.wav")
			RunConsoleCommand ("_money_printer_set_password", tostring (Dialog:GetPrinter ():EntIndex ()), self:GetInputString ())
			self:Close ()
		end)
		
		PasswordPrompt:ShowDialog ()
	end)
	
	Dialog:AddLayouter (function (self)
		Dialog:SetSkin ("DarkRP")
	
		local x = 8
		local y = 28
		self.StoredLabel:SetPos (x, y)
		self.StoredNumber:SetPos (x + self.StoredLabel:GetWide () + 16, y - 12)
		self.StoredNumber:SetWide (self:GetWide ())
		self.StoredNumber:SizeToContents ()
		self.TakeButton:SetPos (self:GetWide () - 8 - self.TakeButton:GetWide (), y)
		y = y + self.StoredNumber:GetTall ()
		
		y = y + 16
		
		x = 8
		self.OverdriveLabel:SetPos (x, y)
		self.OverdriveState:SetPos (x + self.OverdriveLabel:GetWide () + 8, y)
		self.OverdriveState:SetWide (self:GetWide ())
		self.OverdriveButton:SetPos (self:GetWide () - 8 - self.OverdriveButton:GetWide (), y)
		y = y + self.OverdriveLabel:GetTall ()
		self.OverdriveDescription:SetPos (x + 24, y)
		y = y + self.OverdriveDescription:GetTall ()
		
		y = y + 32
		
		self.PrintingModeLabel:SetPos (x, y)
		self.PrintingMode:SetPos (x + self.PrintingModeLabel:GetWide () + 8, y)
		self.PrintingMode:SetWide (self:GetWide ())
		self.PrintingModeButton:SetPos (self:GetWide () - 8 - self.PrintingModeButton:GetWide (), y)
		y = y + self.PrintingModeLabel:GetTall ()
		self.PrintingModeDescription:SetPos (x + 24, y)
		self.PrintingModeDescription:SetWide (self:GetWide ())
		y = y + self.PrintingModeDescription:GetTall ()
		
		y = y + 32
		
		self.PasswordLabel:SetPos (x, y)
		self.PasswordString:SetPos (x + self.PasswordLabel:GetWide () + 8, y)
		
		self.PasswordButton:SetPos (self:GetWide () - 8 - self.PasswordButton:GetWide (), y)
	end)
	
	Dialog:AddEventListener ("Close", function (self)
		if self:GetPrinter () then
			RunConsoleCommand ("_money_printer_ui_closed", self:GetPrinter ():EntIndex ())
		end
		SettingsDialog = nil
	end)
	
	function Dialog:GetPrinter ()
		return self.Printer
	end
	
	if derma.GetSkinTable () ["DarkRP"] then
		function Dialog:Paint ()
			CGUI.GetRenderer ("DarkRPFrame") (self)
		end
	end
	
	function Dialog:SetMoney (money)
		if self.Money == money then
			return
		end
		self.Money = money
		self.StoredNumber:SetText ("$ " .. tostring (money))
		self.StoredNumber:SizeToContents ()
		self.TakeButton:SetDisabled (money == 0)
		
		self.StoredNumber:SetTextColor (Color (128, 255, 128, 255))
		self:AddTimer (nil, 0.2, function (self)
			self.StoredNumber:SetTextColor (Color (0, 96, 0, 255))
		end)
	end
	
	function Dialog:SetOverdrive (overdrive)
		if self.Overdrive == overdrive then
			return
		end
		self.Overdrive = overdrive
		if overdrive then
			self.OverdriveState:SetText ("On")
			self.OverdriveState:SetTextColor (Color (128, 255, 128, 255))
			
			local color = self.OverdriveDescription:GetTextColor ()
			self.OverdriveDescription:SetTextColor (Color (255, 255, 255))
			self.OverdriveDescription:SetAlpha (255)
			self:AddTimer (nil, 0.2, function (self)
				self.OverdriveState:SetTextColor (Color (0, 96, 0, 255))
				self.OverdriveDescription:SetTextColor (color)
			end)
			
			self.OverdriveButton:SetText ("Disable Overdrive")
		else
			self.OverdriveState:SetText ("Off")
			self.OverdriveState:SetTextColor (Color (255, 0, 0, 255))
			self.OverdriveDescription:SetAlpha (64)
			
			self:AddTimer (nil, 0.2, function (self)
				self.OverdriveState:SetTextColor (Color (128, 0, 0, 255))
				self.OverdriveDescription:SetTextColor (color)
			end)
			
			self.OverdriveButton:SetText ("Enable Overdrive")
		end
	end
	
	function Dialog:SetPassword (password)
		if password == "" then
			password = nil
		end
		if self.Password == password then
			return
		end
		self.Password = password
		if not password then
			self.PasswordString:SetText ("None")
			self.PasswordString:SetTextColor (Color (255, 255, 255, 255))
			self:AddTimer (nil, 0.2, function (self)
				self.PasswordString:SetTextColor (Color (128, 128, 128, 255))
			end)
		else
			self.PasswordString:SetText (password)
			self.PasswordString:SetTextColor (Color (128, 255, 128, 255))
			self:AddTimer (nil, 0.2, function (self)
				self.PasswordString:SetTextColor (Color (0, 96, 0, 255))
			end)
		end
	end
	
	function Dialog:SetPrinter (printer)
		self.Printer = printer
	end
	
	function Dialog:SetShouldStore (store)
		if self.ShouldStoreMoney == store then
			return
		end
		self.ShouldStoreMoney = store
		if store then
			self.PrintingMode:SetText ("Internal")
			self.PrintingModeDescription:SetText ("Printed money is stored inside the machine")
			self.PrintingModeButton:SetText ("External Printing")
		else
			self.PrintingMode:SetText ("External")
			self.PrintingModeDescription:SetText ("Printed money is immediately released")
			self.PrintingModeButton:SetText ("Internal Printing")
		end
		
		local modecolor = self.PrintingMode:GetTextColor ()
		local descriptioncolor = self.PrintingModeDescription:GetTextColor ()
		self.PrintingMode:SetTextColor (Color (255, 255, 255, 255))
		self.PrintingModeDescription:SetTextColor (Color (255, 255, 255, 255))
		self:AddTimer (nil, 0.2, function (self)
			self.PrintingMode:SetTextColor (modecolor)
			self.PrintingModeDescription:SetTextColor (descriptioncolor)
		end)
	end
	
	Dialog:PerformLayout ()	
	return Dialog
end)

usermessage.Hook ("money_printer_ui_open", function (umsg)
	local printer = umsg:ReadEntity ()
	if not SettingsDialog then
		SettingsDialog = CGUI.CreateDialog ("MoneyPrinterSettingsDialog")
		SettingsDialog:SetPrinter (printer)
	end
	SettingsDialog:SetMoney (umsg:ReadLong ())
	SettingsDialog:SetShouldStore (umsg:ReadBool ())
	SettingsDialog:SetOverdrive (umsg:ReadBool ())
	SettingsDialog:SetPassword (umsg:ReadString ())
	SettingsDialog:ShowDialog ()
end)

usermessage.Hook ("money_printer_ui_close", function (umsg)
	if not SettingsDialog then
		return
	end
	SettingsDialog:Close ()
	SettingsDialog = nil
end)

usermessage.Hook ("money_printer_mode", function (umsg)
	local store = umsg:ReadBool ()
	local overdrive = umsg:ReadBool ()
	if not SettingsDialog then
		return
	end
	SettingsDialog:SetShouldStore (store)
	SettingsDialog:SetOverdrive (overdrive)
end)

usermessage.Hook ("money_printer_money", function (umsg)
	local money = umsg:ReadLong ()
	if not SettingsDialog then
		return
	end
	SettingsDialog:SetMoney (money)
end)

usermessage.Hook ("money_printer_password", function (umsg)
	local password = umsg:ReadString ()
	if not SettingsDialog then
		return
	end
	SettingsDialog:SetPassword (password)
end)