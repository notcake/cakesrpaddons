local PANEL = {}

function PANEL:Init ()
	CUtil.EventProvider (self)
	
	self.SelectedIndex = 1
	self.SelectedText = ""
	self.SelectedValue = nil
end

function PANEL:FindOption (text)
	for k, v in pairs (self.Choices) do
		if v == text then
			return k
		end
	end
	return nil
end

function PANEL:GetSelectedIndex ()
	return self.SelectedIndex
end

function PANEL:GetSelectedText ()
	return self.SelectedText
end

function PANEL:GetSelectedValue ()
	return self.SelectedValue or self:GetSelectedText ()
end

function PANEL:GetText ()
	return self.TextEntry:GetText ()
end

function PANEL:OnSelect (index, text, value)
	self.SelectedIndex = index
	self.SelectedText = value
	self.SelectedValue = data
	
	self:DispatchEvent ("SelectionChanged", index, text, value)
end

vgui.Register ("GMultiChoice", PANEL, "DMultiChoice")