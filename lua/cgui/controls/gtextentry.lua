local PANEL = {}function PANEL:Init ()	CUtil.EventProvider (self)	self.FeedbackLabel = nil	self.Value = nil		self.Validator = CGUI.ValidatorChain (self)	self.Validator:AddEventListener ("Validated", function (_, valid, error)		if self.FeedbackLabel then			if error then				self.FeedbackLabel:SetText (error)				self.FeedbackLabel:SetTextColor (Color (128, 0, 0, 255))				self:SetTextColor (Color (128, 0, 0, 255))			else				self.FeedbackLabel:SetText ("")				self.FeedbackLabel:SetTextColor (Color (0, 128, 0, 255))				self:SetTextColor (Color (0, 128, 0, 255))			end		end		self:DispatchEvent ("Validated", valid, error)	end)		self:Validate ()endfunction PANEL:ApplySchemeSettings ()	DTextEntry.ApplySchemeSettings (self)	self:Validate ()endfunction PANEL:GetFeedbackLabel ()	return self.FeedbackLabelendfunction PANEL:GetValue ()	return self.Valueendfunction PANEL:OnEnter ()	self:Validate ()	self:DispatchEvent ("Enter")endfunction PANEL:OnTextChanged ()	self:Validate ()	self:DispatchEvent ("TextChanged", self:GetText ())endfunction PANEL:SetFeedbackLabel (feedback)	if self.FeedbackLabel == feedback then		return	end	self.FeedbackLabel = feedback	if self.FeedbackLabel then		self:Validate ()	endendfunction PANEL:SetValue (value)	self.Value = valueendfunction PANEL:Validate ()	return self.Validator:Validate (self:GetText ())endvgui.Register ("GTextEntry", PANEL, "DTextEntry")