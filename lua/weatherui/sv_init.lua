include ("weatherui/sh_init.lua")

AddCSLuaFile ("weatherui/sh_init.lua")
AddCSLuaFile ("weatherui/cl_init.lua")

for _, v in ipairs (file.FindInLua ("weatherui/ui/*.lua")) do
	AddCSLuaFile ("weatherui/ui/" .. v)
end

WeatherControl.WeatherCycle:Load ()
timer.Simple (5, function ()
	timer.Simple (5, function ()
		WeatherControl.WeatherCycle:Start (1)
	end)
end)

--[[
	Internal Console Commands
		_weatherui_request_weathers
		_weatherui_ui_closed
		
	Datastreams
		weatherui_weathers
]]

concommand.Add ("_weatherui_request_weathers", function (ply, _, _)
	if not WeatherControl.CanControlWeather (ply) then
		return
	end
	WeatherControl.WeatherCycle:AddSubscriber (ply)
	for item in WeatherControl.WeatherCycle:GetWeatherItemIterator () do
		umsg.Start ("weatherui_item_added", ply)
			umsg.String (item:GetType ())
			umsg.Float (item:GetDuration ())
		umsg.End ()
	end
	local current = WeatherControl.WeatherCycle:GetCurrentItem ()
	if current then
		umsg.Start ("weatherui_started", filter)
			umsg.Long (current:GetID ())
			umsg.Float (WeatherControl.WeatherCycle:GetCurrentEndTime ())
		umsg.End ()
	end
end)

concommand.Add ("_weatherui_ui_closed", function (ply, _, _)
	WeatherControl.WeatherCycle:RemoveSubscriber (ply)
end)

concommand.Add ("_weatherui_modify_weather", function (ply, _, args)
	if #args < 3 then
		return
	end
	if not WeatherControl.CanControlWeather (ply) then
		return
	end
	local id = tonumber (args [1])
	local type = args [2]
	local duration = tonumber (args [3])
	if not id then
		return
	end
	if not duration or duration < 0 then
		return
	end
	WeatherControl.WeatherCycle:ModifyWeatherItem (id, type, duration)
end)

concommand.Add ("_weatherui_add_weather", function (ply, _, args)
	if #args < 2 then
		return
	end
	if not WeatherControl.CanControlWeather (ply) then
		return
	end
	local type = args [1]
	local duration = tonumber (args [2])
	if not duration or duration < 0 then
		return
	end
	local item = WeatherControl.WeatherItem (type, duration)
	WeatherControl.WeatherCycle:AddWeatherItem (item)
end)

concommand.Add ("_weatherui_remove", function (ply, _, args)
	if #args < 1 then
		return
	end
	if not WeatherControl.CanControlWeather (ply) then
		return
	end
	local id = tonumber (args [1])
	if not id then
		return
	end
	WeatherControl.WeatherCycle:RemoveWeatherItem (id)
end)

concommand.Add ("_weatherui_move_up", function (ply, _, args)
	if #args < 1 then
		return
	end
	if not WeatherControl.CanControlWeather (ply) then
		return
	end
	local id = tonumber (args [1])
	if not id then
		return
	end
	WeatherControl.WeatherCycle:MoveWeatherItemUp (id)
end)

concommand.Add ("_weatherui_move_down", function (ply, _, args)
	if #args < 1 then
		return
	end
	if not WeatherControl.CanControlWeather (ply) then
		return
	end
	local id = tonumber (args [1])
	if not id then
		return
	end
	WeatherControl.WeatherCycle:MoveWeatherItemDown (id)
end)

concommand.Add ("_weatherui_start", function (ply, _, args)
	if #args < 1 then
		return
	end
	if not WeatherControl.CanControlWeather (ply) then
		return
	end
	local id = tonumber (args [1])
	if not id then
		return
	end
	WeatherControl.WeatherCycle:Start (id)
end)

concommand.Add ("_weatherui_stop", function (ply, _, args)
	if not WeatherControl.CanControlWeather (ply) then
		return
	end
	WeatherControl.WeatherCycle:Stop ()
end)