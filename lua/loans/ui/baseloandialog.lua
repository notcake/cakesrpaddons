CGUI.RegisterDialog ("BaseLoanDialog", function ()
	local self = CGUI.CreateDialog ("BaseDialog")
	self:SetTitle ("Loan")
	self:SetSize (300, 200)
	
	self.AmountLabel = vgui.Create ("DLabel", self)
	self.AmountLabel:SetText ("Amount:")
	
	self.AmountEntry = vgui.Create ("DTextEntry", self)
	self.AmountEntry:SetText ("1000")
	self.AmountEntry.Value = 1000
	self.AmountEntry.Validator = CGUI.ValidatorChain ()
	function self.AmountEntry.OnTextChanged (control)
		control:Validate ()
		self.InterestEntry:Validate ()
	end
	function self.AmountEntry.Validate (control)
		local value = control:GetText ():Trim ()
		local multiplier = 1
		if value:sub (1, 1) == "$" then
			value = value:sub (2):Trim ()
		end
		if value:Right (1) == "k" then
			multiplier = 1000
			value = value:sub (1, value:len () - 1):Trim ()
		end
		local valid = control.Validator:Validate (control, value)
		if valid then
			control.Value = tonumber (value) * multiplier
			self:DispatchEvent ("AmountChanged", control.Value)
		end
		return valid
	end
	self.AmountEntry.Validator:AddValidator (CGUI.GetValidator ("Number"))
	self.AmountEntry.Validator:AddValidator (CGUI.GetValidator ("PositiveNumber"))
	self.AmountEntry.Validator:AddValidator (CGUI.GetParametricValidator ("MinimumNumber", 1))
	
	self.AmountEntry.Validator:AddEventListener ("Validated", function (_, valid, error)
		if valid then
			self.AmountEntry:SetTextColor (Color (0, 128, 0, 255))
			self.AmountFeedback:SetText ("")
		else
			self.AmountEntry:SetTextColor (Color (128, 0, 0, 255))
			self.AmountFeedback:SetText (error)
		end
	end)
	
	self.AmountFeedback = vgui.Create ("DLabel", self)
	self.AmountFeedback:SetTextColor (Color (128, 0, 0, 255))
	
	self.TimeLabel = vgui.Create ("DLabel", self)
	self.TimeLabel:SetText ("Time:")
	
	self.TimeEntry = vgui.Create ("DTextEntry", self)
	self.TimeEntry:SetText ("0:30")
	self.TimeEntry.Validator = CGUI.ValidatorChain ()
	function self.TimeEntry:OnTextChanged ()
		self:Validate ()
	end
	function self.TimeEntry:Validate ()
		local value = self:GetText ()
		value = value:gsub (" ", "")
		return self.Validator:Validate (self, value)
	end
	self.TimeEntry.Validator:AddValidator (function (self, value)
		local parts = string.Explode (":", value)
		local hours = 0
		local minutes = 0
		if #parts == 1 then
			minutes = tonumber (parts [1])
		elseif #parts == 2 then
			hours = tonumber (parts [1])
			minutes = tonumber (parts [2])
		else
			return false, "Invalid time"
		end
		if parts [1]:sub (1, 1) == "-" then
			return false, "Loan time cannot be negative"
		end
		if not minutes or minutes < 0 then
			return false, "Invalid time"
		end
		if not hours or
			math.floor (hours) ~= hours or
			hours < 0 then
			return false, "Invalid time"
		end
		self.Value = hours * 60 + minutes
		return true
	end)
	self.TimeEntry.Validator:AddEventListener ("Validated", function (_, valid, error)
		if valid then
			self.TimeEntry:SetTextColor (Color (0, 128, 0, 255))
			self.TimeFeedback:SetText ("")
		else
			self.TimeEntry:SetTextColor (Color (128, 0, 0, 255))
			self.TimeFeedback:SetText (error)
		end
	end)
	
	self.TimeFeedback = vgui.Create ("DLabel", self)
	self.TimeFeedback:SetTextColor (Color (128, 0, 0, 255))
	
	self.InterestLabel = vgui.Create ("DLabel", self)
	self.InterestLabel:SetText ("Overall interest rate:")
	
	self.InterestEntry = vgui.Create ("DTextEntry", self)
	self.InterestEntry:SetText ("5 %")
	self.InterestEntry.Value = 5
	self.InterestEntry.Validator = CGUI.ValidatorChain ()
	function self.InterestEntry:OnTextChanged ()
		self:Validate ()
	end
	function self.InterestEntry:Validate ()
		local value = self:GetText ():Trim ()
		if value:Right (1) == "%" then
			value = value:sub (1, value:len () - 1):Trim ()
		end
		return self.Validator:Validate (self, value)
	end
	self.InterestEntry.Validator:AddValidator (CGUI.GetValidator ("Number"))
	self.InterestEntry.Validator:AddValidator (CGUI.GetValidator ("PositiveNumber"))
	self.InterestEntry.Validator:AddValidator (function (self, value)
		self.Value = tonumber (value)
		return true
	end)
	self.InterestEntry.Validator:AddEventListener ("Validated", function (_, valid, error)
		if valid then
			self.InterestEntry:SetTextColor (Color (0, 128, 0, 255))
			self.InterestFeedback:SetTextColor (Color (0, 96, 0, 255))
			self.InterestFeedback:SetText (self:GetInterestText (math.floor (self.AmountEntry.Value + self.AmountEntry.Value * self.InterestEntry.Value * 0.01)))
		else
			self.InterestEntry:SetTextColor (Color (128, 0, 0, 255))
			self.InterestFeedback:SetTextColor (Color (128, 0, 0, 255))
			self.InterestFeedback:SetText (error)
		end
	end)
	
	self.InterestFeedback = vgui.Create ("DLabel", self)
	self.InterestFeedback:SetTextColor (Color (128, 0, 0, 255))
	
	self.OK = vgui.Create ("GButton", self)
	self.OK:SetSize (80, 28)
	self.OK:SetText ("Submit")
	
	self.Cancel = vgui.Create ("GButton", self)
	self.Cancel:SetSize (80, 28)
	self.Cancel:SetText ("Cancel")
	self.Cancel:AddEventListener ("Click", function (button)
		self:Close ()
	end)
	
	self:AddLayouter (function (self)
		local x, y = self:GetLayoutStartPos ()
		
		self.AmountLabel:SetPos (x, y)
		self.AmountLabel:SetWide (self:GetWide () * 0.5)
		self.AmountEntry:SetPos (self:GetWide () * 0.6, y)
		self.AmountEntry:SetWide (self:GetWide () * 0.4 - 8)
		y = y + self.AmountEntry:GetTall ()
		self.AmountFeedback:SetPos (x + 8, y)
		self.AmountFeedback:SetWide (self:GetWide ())
		y = y + self.AmountFeedback:GetTall () + 4
		
		self.TimeLabel:SetPos (x, y)
		self.TimeLabel:SetWide (self:GetWide () * 0.5)
		self.TimeEntry:SetPos (self:GetWide () * 0.6, y)
		self.TimeEntry:SetWide (self:GetWide () * 0.4 - 8)
		y = y + self.TimeEntry:GetTall ()
		self.TimeFeedback:SetPos (x + 8, y)
		self.TimeFeedback:SetWide (self:GetWide ())
		y = y + self.TimeFeedback:GetTall () + 4
		
		self.InterestLabel:SetPos (x, y)
		self.InterestLabel:SetWide (self:GetWide () * 0.5)
		self.InterestEntry:SetPos (self:GetWide () * 0.6, y)
		self.InterestEntry:SetWide (self:GetWide () * 0.4 - 8)
		y = y + self.InterestEntry:GetTall ()
		self.InterestFeedback:SetPos (x + 8, y)
		self.InterestFeedback:SetWide (self:GetWide ())
		y = y + self.InterestFeedback:GetTall () + 4
		
		self.Cancel:SetPos (self:GetWide () - 8 - self.Cancel:GetWide (), self:GetTall () - 8 - self.Cancel:GetTall ())
		self.OK:SetPos (self:GetWide () - 16 - self.Cancel:GetWide () - self.OK:GetWide (), self:GetTall () - 8 - self.OK:GetTall ())
	end)
	
	self:AddEventListener ("Close", function (self)
		ApplicationDialog = nil
	end)
	
	function self:GetInterestText (amount)
		return "You will pay back $" .. tostring (amount) .. "."
	end
	
	function self:GetLayoutStartPos ()
		return 8, 28
	end
	
	function self:Submit ()
		local tbl = {}
		tbl.Amount = self.AmountEntry.Value
		tbl.Time = self.TimeEntry.Value
		tbl.Interest = self.InterestEntry.Value
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