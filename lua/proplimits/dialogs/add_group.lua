function CPropLimits.CreateAddGroupDialog (defaultLimit)
	local Frame = CGUI.CreateDialog ("BaseQuery")
	Frame:SetTitle ("Add group...")
	Frame:SetPrompt ("Enter the prop limit:")
	Frame:SetInputString (tostring (defaultLimit))
	Frame:SetSize (400, 400)
	
	function Frame.TextEntry:OnEnter ()
		if not Frame:Validate () then
			return
		end
		Frame.GroupTextEntry:RequestFocus ()
		Frame.GroupTextEntry:SetCaretPos (Frame.GroupTextEntry:GetText ():len ())
	end
	
	Frame.GroupPrompt = vgui.Create ("DLabel", Frame)
	Frame.GroupPrompt:SetPos (8, 90)
	Frame.GroupPrompt:SetText ("Search for and select a group:")
	
	Frame.GroupTextEntry = vgui.Create ("DTextEntry", Frame)
	Frame.GroupTextEntry:SetPos (8, 108)
	function Frame.GroupTextEntry:OnTextChanged ()
		RunConsoleCommand ("_proplimit_match_group", Frame.GroupTextEntry:GetText ())
	end
	
	Frame.GroupList = vgui.Create ("GListView", Frame)
	Frame.GroupList:SetPos (8, 136)
	Frame.GroupList:AddColumn ("Groups")
	Frame.GroupList:SetMultiSelect (false)
	
	Frame:AddValidator (CGUI.GetValidator ("PositiveNumber"))
	Frame:AddValidator (CGUI.GetValidator ("Integer"))
	
	Frame:AddLayouter (function ()
		Frame.GroupPrompt:SetWide (Frame:GetWide () - 16)
		Frame.GroupTextEntry:SetWide (Frame:GetWide () - 16)
		
		local _, y = Frame.GroupList:GetPos ()
		Frame.GroupList:SetSize (Frame:GetWide () - 16, Frame:GetTall () - 16 - y - Frame.OK:GetTall ())
	end)
	
	Frame:AddEventListener ("Submit", function (self)
		if not self.GroupList:GetSelectedItem () then
			return
		end
		CPropLimits.RequestGroupLimitChange (self.GroupList:GetSelectedItem ().Group, tostring (self:GetInputString ()))
		self:Close ()
	end)

	function CPropLimits.OnReceivedGroupMatches (groups)
		if not Frame or
			not Frame:IsValid () then
			return
		end
		Frame.GroupList:Clear ()
		for group, displayName in pairs (groups) do
			local Line = Frame.GroupList:AddLine (displayName)
			Line.Group = group
		end
	end
	return Frame
end