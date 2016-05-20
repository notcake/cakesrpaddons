local UI = CGUI.UI
local PANEL = {}

function PANEL:Init ()
	self.LastClickTime = 0
	self.Disabled = false

	self.Icon = nil
end

function PANEL:DataLayout (listView)
	self:ApplySchemeSettings ()
	local height = self:GetTall ()
	local x = 0
	local w = listView:ColumnWidth (1)
	local Columns = listView:GetColumns ()
	if self.Icon then
		local Icon = UI.ImageCache:GetImage (self.Icon)
		local Spacing = (self:GetTall () - Icon:GetHeight ()) * 0.5
		x = x + Spacing + Icon:GetWidth () + 1
		w = w - Icon:GetWidth () - Spacing
	end
	for i = 1, #self.Columns do
		if Columns [i]:GetType () == "Checkbox" then
			self.Columns [i]:SetPos (x + (listView:ColumnWidth (i) - 14) * 0.5, (height - 14) * 0.5)
			self.Columns [i]:SetSize (14, 14)
		else
			self.Columns [i]:SetPos (x, 0)
		end
		if Columns [i]:GetType () == "Text" then
			self.Columns [i]:SetSize (w, height)
		end
		x = x + w
		w = listView:ColumnWidth (i + 1)
	end
end

function PANEL:GetIcon ()
	return self.Icon
end

function PANEL:GetText (i)
	return self.Columns [i or 1]:GetValue ()
end

function PANEL:IsDisabled ()
	return self.Disabled
end

function PANEL:Paint ()
	DListView_Line.Paint (self)
	
	if self.Icon then
		local Image = UI.ImageCache:GetImage (self.Icon)
		local Spacing = (self:GetTall () - Image:GetHeight ()) * 0.5
		Image:Draw (Spacing + 1, Spacing)
	end
end

function PANEL:Remove ()
	local listView = self:GetListView ()
	if listView then
		self:SetListView (nil)
		listView:RemoveLine (self:GetID ())
	end
	_R.Panel.Remove (self)
end

function PANEL:SetCheckState (i, checked)
	if self.Columns [i] then
		self.Columns [i]:SetValue (checked)
		return
	end
	self.Columns [i] = vgui.Create ("GCheckbox", self)
	if self.Disabled then
		self.Columns [i]:SetDisabled (self.Disabled)
	end
	self.Columns [i]:SetValue (checked)
	self.Columns [i]:AddEventListener ("CheckStateChanged", function (checkbox, checked)
		self:GetListView ():ItemChecked (self, i, checked)
	end)
end

function PANEL:SetDisabled (disabled)
	if disabled == nil then
		disabled = true
	end
	self.Disabled = disabled
	for _, Item in pairs (self.Columns) do
		if Item.SetDisabled then
			Item:SetDisabled (disabled)
		end
	end
end

function PANEL:SetIcon (icon)
	self.Icon = icon
end

function PANEL:SetText (text)
	self:SetColumnText (1, text)
end

-- Events
function PANEL:OnRightClick ()
	self:GetListView ():DoRightClick (self)
end

vgui.Register ("GListViewItem", PANEL, "DListView_Line")