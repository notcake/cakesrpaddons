function CPropLimits.CreatePropLimitsDialog ()
	local Frame = vgui.Create ("DFrame")
	Frame:SetTitle ("Adjust prop limits...")
	Frame:SetSize (ScrW () * 0.5, ScrH () * 0.5)
	Frame:Center ()
	Frame:MakePopup ()
	Frame:SetVisible (false)
	
	Frame.DefaultLimit = "0"
	local DefaultLimitLabel = vgui.Create ("DLabel", Frame)
	Frame.DefaultLimitLabel = DefaultLimit
	DefaultLimitLabel:SetWide (Frame:GetWide ())
	DefaultLimitLabel:SetPos (8, 28)
	DefaultLimitLabel:SetText ("Limit for unlisted groups: unknown")
	
	local ChangeDefault = vgui.Create ("DButton", Frame)
	ChangeDefault:SetText ("Change")
	ChangeDefault:SetSize (80, 28)
	ChangeDefault:SetPos (Frame:GetWide () - 8 - ChangeDefault:GetWide (), 28)
	function ChangeDefault:DoClick ()
		local dialog = CGUI.CreateDialog ("BaseQuery")
		dialog:AddValidator (CGUI.GetValidator ("PositiveNumber"))
		dialog:AddValidator (CGUI.GetValidator ("Integer"))
		
		dialog:SetTitle ("Adjust default prop limit...")
		dialog:SetInputString (tostring (Frame.DefaultLimit))
		dialog:SetPrompt ("Enter the prop limit for unlisted groups:")
		dialog:SetSubmitText ("Change")
		
		dialog:AddEventListener ("Submit", function (self)
			local limit = tonumber (self:GetInputString ())
			CPropLimits.RequestDefaultLimitChange (limit)
			self:Close ()
		end)
		
		dialog:ShowDialog ()
	end
	
	local CloseButton = vgui.Create ("DButton", Frame)
	Frame.CloseButton = CloseButton
	CloseButton:SetSize (80, 28)
	CloseButton:SetPos (Frame:GetWide () - 8 - CloseButton:GetWide (), Frame:GetTall () - 8 - CloseButton:GetTall ())
	CloseButton:SetText ("Close")
	function CloseButton:DoClick ()
		Frame:Remove ()
	end
	
	local List = vgui.Create ("GListView", Frame)
	Frame.List = List
	List:SetPos (8, 64)
	List:SetSize (Frame:GetWide () - 16, Frame:GetTall () - 16 - 64 - CloseButton:GetTall ())
	List:AddColumn ("Group")
	List:AddColumn ("Limit")
	
	List.Menu = vgui.Create ("GMenu")
	List.Menu:AddOption ("Add", function ()
		CPropLimits.CreateAddGroupDialog (Frame.DefaultLimit):ShowDialog ()
	end)
	List.Menu:AddItem ("Change", function ()
		CPropLimits.CreateModifyGroupDialog (List:GetSelectedItem ().Group, Frame.Limits [List:GetSelectedItem ().Group].Line:GetText (), Frame.Limits [List:GetSelectedItem ().Group].Limit):ShowDialog ()
	end)
	List.Menu:AddItem ("Remove", function ()
		CPropLimits.RequestGroupLimitRemoval (List:GetSelectedItem ().Group)
	end)
	
	List.Menu:AddEventListener ("MenuOpening", function (self)
		local Selected = List:GetSelectedItem ()
		if Selected then
			self:FindItem ("Change"):SetDisabled (false)
			self:FindItem ("Remove"):SetDisabled (false)
		else
			self:FindItem ("Change"):SetDisabled (true)
			self:FindItem ("Remove"):SetDisabled (true)
		end
	end)
	
	function Frame:ClearLimits ()
		List:Clear ()
	end
	
	function Frame:ReceivedDefaultLimit (limit)
		self.DefaultLimit = limit
		DefaultLimitLabel:SetText ("Limit for unlisted groups: " .. tostring (limit))
	end
	
	function Frame:ReceivedGroupLimit (group, displayName, limit)
		local Line = nil
		if not self.Limits [group] then
			Line = self.List:AddLine (displayName)
			Line.Group = group
		
			self.Limits [group] = {
				Limit = limit,
				Line = Line
			}
		else
			Line = self.Limits [group].Line
			self.Limits [group].Limit = limit
		end
		Line:SetColumnText (2, tostring (limit))
	end
	
	function Frame:ReceivedGroupLimitRemoval (group)
		if not self.Limits [group] then
			return
		end
		self.Limits [group].Line:Remove ()
		self.Limits [group] = nil
	end
	
	Frame.Limits = {}
	
	CPropLimits.UI = Frame
end