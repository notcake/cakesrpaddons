include ("cutil.lua")
include ("cgui.lua")

if SERVER then
	AddCSLuaFile ("autorun/loans.lua")
	include ("loans/sv_init.lua")
	
	concommand.Add ("loans_reload_sv", function (ply, _, _)
		if ply and not ply:IsSuperAdmin () then
			return
		end
		include ("autorun/loans.lua")
	end)
elseif CLIENT then
	include ("loans/cl_init.lua")
	
	concommand.Add ("loans_reload_cl", function (ply, _, _)
		include ("autorun/loans.lua")
	end)
end