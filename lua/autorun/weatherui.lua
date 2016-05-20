include ("cutil.lua")
include ("cgui.lua")

if SERVER then
	AddCSLuaFile ("autorun/weatherui.lua")

	include ("weatherui/sv_init.lua")
	
	concommand.Add ("weatherui_reload_sv", function (ply, _, _)
		if ply and not ply:IsSuperAdmin () then
			return
		end
		for _, ply in ipairs (player.GetAll ()) do
			ply:ConCommand ("weatherui_reload_cl")
		end
		include ("autorun/weatherui.lua")
	end)
elseif CLIENT then
	include ("weatherui/cl_init.lua")
	concommand.Add ("weatherui_reload_cl", function (ply, _, _)
		include ("autorun/weatherui.lua")
	end)
end