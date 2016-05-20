if CUtil then
	return
end

if SERVER then
	AddCSLuaFile ("cutil.lua")
end

include ("cutil/init.lua")

if SERVER then
	concommand.Add ("cutil_reload_sv", function (ply, _, _)
		if ply and not ply:IsSuperAdmin () then
			return
		end
		include ("cutil/init.lua")
	end)
elseif CLIENT then
	concommand.Add ("cutil_reload_cl", function ()
		include ("cutil/init.lua")
	end)
end