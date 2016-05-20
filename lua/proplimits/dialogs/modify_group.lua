function CPropLimits.CreateModifyGroupDialog (group, displayName, limit)
	local Frame = CGUI.CreateDialog ("BaseQuery")
	Frame:AddValidator (CGUI.GetValidator ("PositiveNumber"))
	Frame:AddValidator (CGUI.GetValidator ("Integer"))
		
	Frame:SetTitle ("Adjust prop limit for " .. displayName .. "...")
	Frame:SetInputString (tostring (limit))
	Frame:SetPrompt ("Enter the prop limit for the " .. displayName .. " group:")
	Frame:SetSubmitText ("Change")
	
	Frame:AddEventListener ("Submit", function (self)
		local limit = tonumber (self:GetInputString ())
		CPropLimits.RequestGroupLimitChange (group, limit)
		self:Close ()
	end)
		
	return Frame
end