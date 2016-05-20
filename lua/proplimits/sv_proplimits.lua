--[[
	Console Commands:
		proplimit_list
		proplimit_set_default_limit
		proplimit_remove_group_limit
		proplimit_set_group_limit
	Internal Console Commands:
		_proplimit_request_list
		_proplimit_match_group

	Usermessages:
		proplimit_default
			long Limit					- The prop limit for unknown groups
		proplimit_group
			string GroupName			- Name of the group
			string GroupDisplayName		- Displayed name of the group
			long Limit					- The prop limit for this group
		proplimit_group_removed
			string GroupName			- Name of the group
		proplimit_group_match
			string GroupName			- Name of the found group
			string GroupDisplayName		- Displayed name of the found group
			...
			string Terminator			- Empty string ("")
			string Terminator2			- Empty string ("")
]]

if CPropLimits.IsUnsaved and
	CPropLimits.IsUnsaved () then
	CPropLimits.SaveLimits ()
end
CPropLimits.Loading = false
CPropLimits.Unsaved = false

-- Clientside lua files
AddCSLuaFile ("proplimits/sh_proplimits.lua")
AddCSLuaFile ("proplimits/cl_proplimits.lua")
AddCSLuaFile ("proplimits/dialogs/add_group.lua")
AddCSLuaFile ("proplimits/dialogs/menu.lua")
AddCSLuaFile ("proplimits/dialogs/modify_group.lua")

-- Admin mod-specific stuff
function CPropLimits.GetGroupDisplayName (group)
	return group
end

--[[
	returns groupName, groupDisplayName pairs
	Usage:
		for group, displayName in CPropLimits.GetGroupIterator () do
			...
		end
]]
function CPropLimits.GetGroupIterator ()
	local next, tbl, key = pairs (ULib.ucl.groups)
	return function ()
		key = next (tbl, key)
		return key, key
	end
end

-- End of admin mod-specific stuff

function CPropLimits.RemoveGroupLimit (group)
	if not CPropLimits.Groups [group:lower ()] then
		return false
	end
	CPropLimits.Groups [group:lower ()] = nil
	if CPropLimits.Loading then
		return
	end
	CPropLimits.Unsaved = true
	
	-- Remove to prevent saving every time
	CPropLimits.SaveLimits ()
end

function CPropLimits.SetDefaultLimit (limit)
	CPropLimits.DefaultLimit = limit
	if CPropLimits.Loading then
		return
	end
	CPropLimits.Unsaved = true
	
	-- Remove to prevent saving every time
	CPropLimits.SaveLimits ()
end

function CPropLimits.SetGroupLimit (group, limit)
	CPropLimits.Groups [group:lower ()] = limit
	if CPropLimits.Loading then
		return
	end
	CPropLimits.Unsaved = true
	
	-- Remove to prevent saving every time
	CPropLimits.SaveLimits ()
end

-- Serialization
function CPropLimits.IsUnsaved ()
	return CPropLimits.Unsaved
end

function CPropLimits.LoadLimits ()
	local txt = file.Read ("cproplimits/proplimits.txt")
	if not txt then
		CPropLimits.Unsaved = false
		return
	end
	
	local tbl = util.KeyValuesToTable (txt)
	CPropLimits.Loading = true
	CPropLimits.DefaultLimit = tonumber (tbl.default)
	for group, limit in pairs (tbl.groups) do
		CPropLimits.SetGroupLimit (group, tonumber (limit))
	end
	
	CPropLimits.Loading = false
	CPropLimits.Unsaved = false
end

function CPropLimits.SaveLimits ()
	CPropLimits.Unsaved = false
	
	local txt = "PropLimits {"
	txt = txt .. "\t\"default\"\t\"" .. tostring (CPropLimits.DefaultLimit) .. "\"\n"
	txt = txt .. "\t\"groups\"\t {\n"
		for group, limit in CPropLimits.GetLimitIterator () do
			txt = txt .. "\t\t\"" .. group:lower () .. "\"\t\"" .. tostring (limit) .. "\"\n"
		end
	txt = txt .. "\t}\n"
	txt = txt .. "}"
	
	file.Write ("cproplimits/proplimits.txt", txt)
end

-- Console interface
local function PrintToPlayer (ply, msg)
	if not ply then
		Msg (msg .. "\n")
	end
	if not ply:IsValid () then
		return
	end
	ply:PrintMessage (HUD_PRINTCONSOLE, msg)
end

concommand.Add ("proplimit_list", function (ply, _, _)
	if not CPropLimits.CanPlayerViewLimits (ply) then
		return
	end
	PrintToPlayer ("Prop limits:")
	for group, limit in CPropLimits.GetLimitIterator () do
		PrintToPlayer ("    " .. group .. ": " .. tostring (limit))
	end
	PrintToPlayer ("For unlisted groups: " .. tostring (CPropLimits.GetDefaultLimit ()))
end)

concommand.Add ("proplimit_set_default_limit", function (ply, _, args)
	if not CPropLimits.CanPlayerAdjustLimits (ply) then
		PrintToPlayer (ply, "You are not allowed to adjust prop limits.")
		return
	end
	if #args < 1 then
		PrintToPlayer (ply, "Usage: proplimit_set_default_limit <number>")
		return
	end
	local limit = tonumber (args [1])
	if not limit then
		PrintToPlayer (ply, "Usage: proplimit_set_default_limit <number>")
		return
	end
	CPropLimits.SetDefaultLimit (limit)
	PrintToPlayer (ply, "Default prop limit set to " .. tostring (limit) .. ".")
	
	umsg.Start ("proplimit_default", ply)
		umsg.Long (CPropLimits.GetDefaultLimit ())
	umsg.End ()
end)

concommand.Add ("proplimit_remove_group_limit", function (ply, _, args)
	if not CPropLimits.CanPlayerAdjustLimits (ply) then
		PrintToPlayer (ply, "You are not allowed to adjust prop limits.")
		return
	end
	if #args < 1 then
		PrintToPlayer (ply, "Usage: proplimit_remove_group_limit <group>")
		return
	end
	local group = args [1]
	CPropLimits.RemoveGroupLimit (group)
	PrintToPlayer (ply, "Players in the " .. group .. " group will now have the default prop limit.")
	
	umsg.Start ("proplimit_group_removed", ply)
		umsg.String (group)
	umsg.End ()
end)

concommand.Add ("proplimit_set_group_limit", function (ply, _, args)
	if not CPropLimits.CanPlayerAdjustLimits (ply) then
		PrintToPlayer (ply, "You are not allowed to adjust prop limits.")
		return
	end
	if #args < 2 then
		PrintToPlayer (ply, "Usage: proplimit_set_group_limit <group> <number>")
		return
	end
	local group = args [1]
	local limit = tonumber (args [2])
	if not limit then
		PrintToPlayer (ply, "Usage: proplimit_set_group_limit <group> <number>")
		return
	end
	CPropLimits.SetGroupLimit (group, limit)
	PrintToPlayer (ply, "Prop limit for " .. group .. " set to " .. tostring (limit) .. ".")
	
	umsg.Start ("proplimit_group", ply)
		umsg.String (group)
		umsg.String (CPropLimits.GetGroupDisplayName (group))
		umsg.Long (limit)
	umsg.End ()
end)

-- Hooks
hook.Add ("PlayerSpawnProp", "CPropLimits", function (ply, mdl)
	if not CPropLimits.CanPlayerSpawn (ply, "props") then
		-- Notify player
		ply:PrintMessage (HUD_PRINTTALK, "You have hit your prop limit of " .. tostring (CPropLimits.GetPlayerLimit (ply)) .. ".")
		return false
	end
end)

hook.Add ("Shutdown", "CPropLimits", function ()
	if not CPropLimits.IsUnsaved () then
		CPropLimits.SaveLimits ()
	end
end)

-- Internal
concommand.Add ("_proplimit_request_list", function (ply, _, _)
	if not CPropLimits.CanPlayerViewLimits (ply) then
		return
	end
	
	umsg.Start ("proplimit_default", ply)
		umsg.Long (CPropLimits.GetDefaultLimit ())
	umsg.End ()
	
	for group, limit in CPropLimits.GetLimitIterator () do
		umsg.Start ("proplimit_group", ply)
			umsg.String (group)
			umsg.String (CPropLimits.GetGroupDisplayName (group))
			umsg.Long (limit)
		umsg.End ()
	end
end)

concommand.Add ("_proplimit_match_group", function (ply, _, args)
	if not CPropLimits.CanPlayerAdjustLimits (ply) then
		return
	end
	if #args < 1 then
		return
	end
	
	local pattern = args [1]:lower ()
	umsg.Start ("proplimit_group_match", ply)
	local count = 0
	for group, displayName in CPropLimits.GetGroupIterator () do
		if group:lower ():find (pattern) or
			displayName:lower ():find (pattern) then
			count = count + 1
			umsg.String (group)
			umsg.String (displayName)
			if count >= 10 then
				break
			end
		end
	end
	umsg.String ("")
	umsg.String ("")
	umsg.End ()
end)

-- Startup
CPropLimits.LoadLimits ()