local PasswordDialog = nil
surface.CreateFont ("Trebuchet", 28, 400, true, false, "PasswordAcceptedFont")
surface.CreateFont ("Trebuchet", 36, 400, true, false, "PasswordCommandButtonFont")
surface.CreateFont ("Trebuchet", 56, 400, true, false, "PasswordButtonFont")

CGUI.RegisterDialog ("MoneyPrinterPasswordDialog", function ()
	local Dialog = CGUI.CreateDialog ("BaseDialog")
	
	Dialog.lblTitle:SetVisible (false)
	Dialog.btnClose:SetVisible (false)
	
	Dialog.Printer = nil
	Dialog:SetSize (272, 440)
	
	Dialog.CanEnterDigits = true
	Dialog.Password = ""
	
	Dialog.Display = vgui.Create ("Label", Dialog)
	Dialog.Display:SetPos (16, 16)
	Dialog.Display:SetSize (240, 72)
	Dialog.Display:SetText ("")
	Dialog.Display.TextColor = Color (0, 255, 0, 255)
	Dialog.Display.Font = ""
	
	function Dialog.Display:GetFont ()
		return self.Font
	end
	
	function Dialog.Display:GetTextColor ()
		return self.TextColor
	end
	
	function Dialog.Display:SetTextColor (color)
		self.TextColor = color
	end
	
	function Dialog.Display:Paint ()
		local x, y = self:GetPos ()
		local w, h = self:GetSize ()
		
		draw.RoundedBox (8, 0, 0, w, h, Color (32, 32, 32, 216))
		draw.DrawText (self:GetText (), self:GetFont (), w * 0.5, 8, self:GetTextColor (), TEXT_ALIGN_CENTER)
		
		return true
	end
	
	function Dialog.Display:SetFont (font)
		self.Font = font
	end
	
	Dialog.Display:SetFont ("PasswordButtonFont")
	
	Dialog.Buttons = {}
	for i = 1, 9 do
		local index = i - 1
		local button = vgui.Create ("GFlatButton", Dialog)
		Dialog.Buttons [i] = button
		button:SetSize (72, 72)
		button:SetPos (16 + index % 3 * (72 + 12), 104 + math.floor (index / 3) * (72 + 12))
		button:SetText (tostring (i))
		button:SetFont ("PasswordButtonFont")
		button.Key1 = KEY_0 + i
		button.Key2 = KEY_PAD_0 + i
		
		function button:IsPressed ()
			if self.Depressed then
				return true
			end
			return input.IsKeyDown (self.Key1) or input.IsKeyDown (self.Key2)
		end
		
		button:AddEventListener ("Click", function (self)
			Dialog:PushDigit (self:GetText ())
			surface.PlaySound ("buttons/button15.wav")
		end)
	end
	
	Dialog.OK = vgui.Create ("GFlatButton", Dialog)
	Dialog.OK:SetParent (Dialog)
	Dialog.OK:SetPos (16, 360)
	Dialog.OK:SetSize (112, 64)
	Dialog.OK:SetBackgroundColor (Color (0, 255, 0, 255))
	Dialog.OK:SetText ("Enter")
	Dialog.OK:SetFont ("PasswordCommandButtonFont")
		
	function Dialog.OK:IsPressed ()
		if self.Depressed then
			return true
		end
		return input.IsKeyDown (KEY_ENTER)
	end
	
	Dialog.OK:AddEventListener ("Click", "Submit", function (self)
		surface.PlaySound ("buttons/button15.wav")
		Dialog:Submit ()
	end)
	
	Dialog.Cancel = vgui.Create ("GFlatButton", Dialog)
	Dialog.Cancel:SetPos (146, 360)
	Dialog.Cancel:SetSize (112, 64)
	Dialog.Cancel:SetBackgroundColor (Color (255, 0, 0, 255))
	Dialog.Cancel:SetText ("Cancel")
	Dialog.Cancel:SetFont ("PasswordCommandButtonFont")
		
	function Dialog.Cancel:IsDepressed ()
		if self.Depressed then
			return true
		end
		return input.IsKeyDown (KEY_ESCAPE)
	end
	
	Dialog.Cancel:AddEventListener ("Click", function (self)
		surface.PlaySound ("buttons/button15.wav")
		Dialog:Close ()
	end)
	
	Dialog:AddLayouter (function (self)
		self:SetSkin ("DarkRP")
	end)
	
	Dialog:AddEventListener ("Close", function (self)
		RunConsoleCommand ("gameui_allowescape")
		PasswordDialog = nil
	end)
	
	function Dialog:BeginBusyAnimation ()
		if self:IsBusy () then
			return
		end
		self.Busy = true
		self:ShowMovingDots ()
	end
	
	function Dialog:CanSubmit ()
		return true
	end
	
	function Dialog:ClearPassword ()
		self.Password = ""
	end
	
	function Dialog:EndBusyAnimation ()
		self.Busy = false
		self:RemoveTimer ("Busy")
	end
	
	function Dialog:GetDisplayText ()
		return self.Display:GetText ()
	end
	
	function Dialog:GetPassword ()
		return self.Password
	end
	
	function Dialog:GetPrinter ()
		return self.Printer
	end
	
	function Dialog:IsBusy ()
		return self.Busy
	end
	
	function Dialog:OnKeyCodePressed (keycode)
		if keycode >= KEY_0 and
			keycode <= KEY_9 then
			keycode = keycode - KEY_0
			surface.PlaySound ("buttons/button15.wav")
			self:PushDigit (tostring (keycode))
		elseif keycode >= KEY_PAD_0 and
			keycode <= KEY_PAD_9 then
			keycode = keycode - KEY_PAD_0
			surface.PlaySound ("buttons/button15.wav")
			self:PushDigit (tostring (keycode))
		elseif keycode == KEY_ENTER then
			surface.PlaySound ("buttons/button15.wav")
			self:Submit ()
		end
	end
	
	function Dialog:Paint ()
		CGUI.GetRenderer ("DarkRPKeypadFrame") (self)
		return true
	end
	
	function Dialog:PushDigit (digit)
		if self.CanEnterDigits then
			self.Password = self.Password .. tostring (digit)
			if self.Password:len () > 4 then
				self.Password = self.Password:sub (2)
			end
			self:SetDisplayText (self.Password)
		end
	end
	
	function Dialog:SetCanSubmit (can_submit)
		function self:CanSubmit ()
			return can_submit
		end
	end
	
	function Dialog:SetDisplayText (text)
		return self.Display:SetText (text)
	end
	
	function Dialog:SetDisplayTextColor (color)
		return self.Display:SetTextColor (color)
	end
	
	function Dialog:SetDisplayTextFont (font)
		return self.Display:SetFont (font)
	end
	
	function Dialog:SetPrinter (printer)
		self.Printer = printer
	end
	
	function Dialog:ShowMovingDots ()
		if self:GetDisplayText () == "" then
			self:SetDisplayText (".")
		elseif self:GetDisplayText () == "." then
			self:SetDisplayText ("..")
		elseif self:GetDisplayText () == ".." then
			self:SetDisplayText ("...")
		elseif self:GetDisplayText () == "..." then
			self:SetDisplayText ("")
		else
			self:SetDisplayText ("")
		end
		self:AddTimer ("Busy", 0.4, self.ShowMovingDots)
	end
	
	function Dialog:Submit ()
		if not self:CanSubmit () then
			return
		end
		self.CanEnterDigits = false
		self:BeginBusyAnimation ()
		
		RunConsoleCommand ("_money_printer_password", self:GetPrinter ():EntIndex (), self:GetPassword ())
	end
	
	Dialog:SetKeyboardInputEnabled (true)
	
	return Dialog
end)

usermessage.Hook ("money_printer_ui_password_open", function (umsg)
	local printer = umsg:ReadEntity ()
	if not PasswordDialog then
		PasswordDialog = CGUI.CreateDialog ("MoneyPrinterPasswordDialog")
		PasswordDialog:SetPrinter (printer)
		PasswordDialog:ShowDialog ()
	end
end)

usermessage.Hook ("money_printer_ui_password_close", function (umsg)
	if PasswordDialog then
		PasswordDialog:Close ()
	end
end)

usermessage.Hook ("money_printer_password_response", function (umsg)
	local valid = umsg:ReadBool ()
	if not PasswordDialog then
		return
	end
	PasswordDialog:EndBusyAnimation ()
	PasswordDialog:SetCanSubmit (false)
	if valid then
		surface.PlaySound ("buttons/button9.wav")
		PasswordDialog:SetDisplayText ("ACCESS\nGRANTED")
		PasswordDialog:SetDisplayTextFont ("PasswordAcceptedFont")
	else
		surface.PlaySound ("buttons/button8.wav")
		
		PasswordDialog:ClearPassword ()
		PasswordDialog:SetDisplayText ("INVALID")
		PasswordDialog:SetDisplayTextColor (Color (255, 0, 0, 255))
		PasswordDialog:AddTimer (nil, 1, function ()
			PasswordDialog.CanEnterDigits = true
			PasswordDialog:SetDisplayText ("")
			PasswordDialog:SetDisplayTextColor (Color (0, 255, 0, 255))
			PasswordDialog:SetCanSubmit (true)
		end)
	end
end)