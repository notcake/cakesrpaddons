CGUI = CGUI or {}

AddCSLuaFile ("cgui/cl_init.lua")

AddCSLuaFile ("cgui/validatorchain.lua")

AddCSLuaFile ("cgui/basepanel.lua")
AddCSLuaFile ("cgui/basedialog.lua")
AddCSLuaFile ("cgui/basequery.lua")
AddCSLuaFile ("cgui/number_validators.lua")
AddCSLuaFile ("cgui/renderers.lua")

for _, v in ipairs (file.FindInLua ("cgui/controls/*.lua")) do
	AddCSLuaFile ("cgui/controls/" .. v)
end