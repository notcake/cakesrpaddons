--[[
	Prop limits menu
]]
if CPropLimits.UI then
	CPropLimits.UI:Remove ()
	CPropLimits.UI = nil
end

function CPropLimits.RequestDefaultLimitChange (limit)
	RunConsoleCommand ("proplimit_set_default_limit", limit)
end

function CPropLimits.RequestGroupLimitChange (group, limit)
	RunConsoleCommand ("proplimit_set_group_limit", group, limit)
end

function CPropLimits.RequestGroupLimitRemoval (group)
	RunConsoleCommand ("proplimit_remove_group_limit", group)
end

function CPropLimits.RequestLimits ()
	RunConsoleCommand ("_proplimit_request_list")
end

-- Events to be overridden by the UI
function CPropLimits.OnReceivedDefaultLimit (limit)
end

function CPropLimits.OnReceivedGroupLimit (group, displayName, limit)
end

function CPropLimits.OnReceivedGroupLimitRemoval (group)
end

function CPropLimits.OnReceivedGroupMatches (groups)
end

-- Load derma dialogs
include ("proplimits/dialogs/menu.lua")
include ("proplimits/dialogs/add_group.lua")
include ("proplimits/dialogs/modify_group.lua")

function CPropLimits.ShowMenu ()
	if not CPropLimits.UI or 
		not CPropLimits.UI:IsValid () then
		CPropLimits.CreatePropLimitsDialog ()
	end
	CPropLimits.RequestLimits ()
	
	CPropLimits.UI:SetVisible (true)
	function CPropLimits.OnReceivedDefaultLimit (limit)
		if CPropLimits.UI and
			CPropLimits.UI:IsValid () then
			CPropLimits.UI:ReceivedDefaultLimit (limit)
		end
	end
	
	function CPropLimits.OnReceivedGroupLimit (group, displayName, limit)
		if CPropLimits.UI and
			CPropLimits.UI:IsValid () then
			CPropLimits.UI:ReceivedGroupLimit (group, displayName, limit)
		end
	end
	
	function CPropLimits.OnReceivedGroupLimitRemoval (group)
		if CPropLimits.UI and
			CPropLimits.UI:IsValid () then
			CPropLimits.UI:ReceivedGroupLimitRemoval (group)
		end
	end
end

concommand.Add ("proplimit_menu", function (ply, _, _)
	if not CPropLimits.CanPlayerAdjustLimits (ply) then
		chat.AddText ("You are not allowed to adjust prop limits.")
	end
	CPropLimits.ShowMenu ()
end)

usermessage.Hook ("proplimit_default", function (umsg)
	local limit = umsg:ReadLong ()
	CPropLimits.DefaultLimit = limit
	
	CPropLimits.OnReceivedDefaultLimit (limit)
end)

usermessage.Hook ("proplimit_group", function (umsg)
	local group = umsg:ReadString ()
	local displayName = umsg:ReadString ()
	local limit = umsg:ReadLong ()
	CPropLimits.Groups [group] = limit
	
	CPropLimits.OnReceivedGroupLimit (group, displayName, limit)
end)

usermessage.Hook ("proplimit_group_removed", function (umsg)
	local group = umsg:ReadString ()
	CPropLimits.Groups [group] = nil
	
	CPropLimits.OnReceivedGroupLimitRemoval (group)
end)

usermessage.Hook ("proplimit_group_match", function (umsg)
	local groups = {}
	local group = umsg:ReadString ()
	local displayName = umsg:ReadString ()
	while group ~= "" do
		groups [group] = displayName
		group = umsg:ReadString ()
		displayName = umsg:ReadString ()
	end
	CPropLimits.OnReceivedGroupMatches (groups)
end)