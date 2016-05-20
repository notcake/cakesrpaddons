if CGUI then
	return
end

include ("cutil.lua")

if SERVER then
	AddCSLuaFile ("cgui.lua")
	include ("cgui/sv_init.lua")
	
	concommand.Add ("cgui_reload_sv", function (ply, _, _)
		if ply and not ply:IsSuperAdmin () then
			return
		end
		include ("cgui/sv_init.lua")
	end)
elseif CLIENT then
	include ("cgui/cl_init.lua")
	concommand.Add ("cgui_reload_cl", function (ply, _, _)
		include ("cgui/cl_init.lua")
	end)
end