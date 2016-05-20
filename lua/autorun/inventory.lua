include ("cutil.lua")
include ("cgui.lua")

include ("inventory/sh_init.lua")
if SERVER then
	AddCSLuaFile ("autorun/inventory.lua")
	AddCSLuaFile ("inventory/sh_init.lua")
	AddCSLuaFile ("inventory/cl_init.lua")

	include ("inventory/sv_init.lua")
	
	concommand.Add ("inventory_reload_sv", function (ply, _, _)
		if ply and not ply:IsSuperAdmin () then
			return
		end
		for _, ply in ipairs (player.GetAll ()) do
			ply:ConCommand ("inventory_reload_cl")
		end
		include ("autorun/inventory.lua")
	end)
elseif CLIENT then
	include ("inventory/cl_init.lua")
	concommand.Add ("inventory_reload_cl", function (ply, _, _)
		include ("autorun/inventory.lua")
	end)
end