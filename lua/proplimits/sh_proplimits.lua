CPropLimits = CPropLimits or {}
CPropLimits.DefaultLimit = CPropLimits.DefaultLimit or 100
CPropLimits.Groups = CPropLimits.Groups or {}

-- Admin mod-specific stuff
function CPropLimits.GetPlayerGroup (ply)
	-- Obtain the player's group through whatever admin mod is present
	return ply:GetUserGroup ()
end
-- End admin mod-specific stuff

function CPropLimits.CanPlayerAdjustLimits (ply)
	if not ply then
		return true
	end
	return ply:IsAdmin ()
end

function CPropLimits.CanPlayerViewLimits (ply)
	if not ply then
		return true
	end
	return ply:IsAdmin ()
end

function CPropLimits.CanPlayerSpawn (ply, class)
	class = class or "props"
	local limit = CPropLimits.GetGroupLimit (CPropLimits.GetPlayerGroup (ply))
	if limit == -1 then
		return true
	end
	local count = ply:GetCount (class)
	return count < limit
end

function CPropLimits.GetDefaultLimit ()
	return CPropLimits.DefaultLimit
end

function CPropLimits.GetGroupLimit (group)
	return CPropLimits.Groups [group:lower ()] or CPropLimits.DefaultLimit
end

function CPropLimits.GetPlayerLimit (ply)
	return CPropLimits.GetGroupLimit (CPropLimits.GetPlayerGroup (ply))
end

--[[
	Returns groupName, limit pairs
	Usage:
		for group, limit in CPropLimits.GetLimitIterator () do
			...
		end
]]
function CPropLimits.GetLimitIterator ()
	local next, tbl, key = pairs (CPropLimits.Groups)
	return function ()
		key = next (tbl, key)
		return key, tbl [key]
	end
end