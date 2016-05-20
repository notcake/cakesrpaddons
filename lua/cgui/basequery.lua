CGUI.RegisterDialog ("BaseQuery", function ()
	local Dialog = CGUI.CreateDialog ("BaseDialog")
	
	Dialog.Validators = {}
	
	Dialog.Prompt = vgui.Create ("DLabel")
	Dialog.Prompt:SetParent (Dialog)
	Dialog.Prompt:SetPos (8, 28)
	Dialog.Prompt:SetText ("Enter text:")
	
	Dialog.TextEntry = vgui.Create ("DTextEntry", Dialog)
	Dialog.TextEntry:SetPos (8, 48)
	
	function Dialog.TextEntry:OnEnter ()
		Dialog.OK:DoClick ()
	end
	
	function Dialog.TextEntry:OnTextChanged ()
		Dialog:Validate ()
	end
	
	Dialog.Feedback = vgui.Create ("DLabel", Dialog)
	Dialog.Feedback:SetPos (8, 68)
	Dialog.Feedback:SetText ("")
	Dialog.Feedback:SetTextColor (Color (0, 128, 0, 255))
	
	Dialog.OK = vgui.Create ("DButton", Dialog)
	Dialog.OK:SetSize (80, 28)
	Dialog.OK:SetText ("OK")
	
	function Dialog.OK:DoClick ()
		if not Dialog:Validate () then
			return
		end
		Dialog:DispatchEvent ("Submit")
	end
	
	Dialog.Cancel = vgui.Create ("DButton", Dialog)
	Dialog.Cancel:SetSize (80, 28)
	Dialog.Cancel:SetText ("Cancel")
	
	function Dialog.Cancel:DoClick ()
		Dialog:DispatchEvent ("Cancel")
		Dialog:Remove ()
	end
	
	function Dialog.btnClose:DoClick ()
		Dialog:DispatchEvent ("Cancel")
		Dialog:Remove ()
	end
	
	function Dialog:AddValidator (validator)
		self.Validators [#self.Validators + 1] = validator
	end
	
	function Dialog:GetInputString ()
		return self.TextEntry:GetText ()
	end
	
	function Dialog:SetErrorMessage (message)
		if not message then
			self.TextEntry:SetTextColor (Color (0, 128, 0, 255))
			self.Feedback:SetText ("")
			return
		end
		self.TextEntry:SetTextColor (Color (128, 0, 0, 255))
		self.Feedback:SetTextColor (Color (128, 0, 0, 255))
		self.Feedback:SetText (message)
	end
	
	function Dialog:SetFeedbackText (message)
		self.Feedback:SetText (message or "")
	end
	
	function Dialog:SetFeedbackTextColor (r, g, b, a)
		local color = r
		if type (r) ~= "table" then
			color = Color (r or 0, g or 0, b or 0, a or 255)
		end
		self.Feedback:SetTextColor (color)
	end
	
	function Dialog:SetInputString (text)
		self.TextEntry:SetText (text or "")
	end
	
	function Dialog:SetPrompt (text)
		self.Prompt:SetText (text or "")
	end
	
	function Dialog:SetSubmitText (text)
		self.OK:SetText (text or "")
	end
	
	function Dialog:ShowDialog ()
		self:Center ()
		self:MakePopup ()
		self:SetVisible (true)
		
		self.TextEntry:RequestFocus ()
		self.TextEntry:SetCaretPos (self.TextEntry:GetText ():len ())
		
		self:AddTimer (nil, 0, self.Validate)
	end
	
	function Dialog:Validate ()
		for _, validator in ipairs (self.Validators) do
			local valid, message = validator (self, self:GetInputString ())
			if valid == false then
				self:SetErrorMessage (message)
				return false
			end
		end
		self:SetErrorMessage (nil)
		return true
	end
	
	Dialog:AddLayouter (function (self)
		self.Prompt:SetWide (self:GetWide () - 16)
		self.TextEntry:SetWide (self:GetWide () - 16)
		self.Feedback:SetWide (self:GetWide () - 16)
		
		self.Cancel:SetPos (self:GetWide () - 8 - self.Cancel:GetWide (), self:GetTall () - 8 - self.Cancel:GetTall ())
		self.OK:SetPos (self:GetWide () - 16 - self.Cancel:GetWide () - self.OK:GetWide (), self:GetTall () - 8 - self.OK:GetTall ())
	end)
	
	Dialog:SetSize (400, 124)
	Dialog:PerformLayout ()
	return Dialog
end)