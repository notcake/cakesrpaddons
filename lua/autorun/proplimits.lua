include ("cutil.lua")
include ("cgui.lua")

include ("proplimits/sh_proplimits.lua")
if SERVER then
	AddCSLuaFile ("autorun/proplimits.lua")

	include ("proplimits/sv_proplimits.lua")
	
	concommand.Add ("proplimits_reload_sv", function (ply, _, _)
		if ply and not ply:IsSuperAdmin () then
			return
		end
		include ("autorun/proplimits.lua")
	end)
elseif CLIENT then
	include ("proplimits/cl_proplimits.lua")
	concommand.Add ("proplimits_reload_cl", function (ply, _, _)
		include ("autorun/proplimits.lua")
	end)
end