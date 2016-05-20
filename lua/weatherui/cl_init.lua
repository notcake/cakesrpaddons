include ("cgui.lua")

include ("weatherui/sh_init.lua")
include ("weatherui/ui/weatheritem.lua")
include ("weatherui/ui/weatherview.lua")
include ("weatherui/ui/weatherui.lua")
include ("weatherui/ui/baseweatherdialog.lua")
include ("weatherui/ui/weatheradditiondialog.lua")
include ("weatherui/ui/weathermodificationdialog.lua")

local UI = nil
concommand.Add ("weatherui", function (_, _, _)
	if not UI or not UI:IsValid () then
		UI = CGUI.CreateDialog ("WeatherUI")
	end
	UI:ShowDialog ()
	WeatherControl.WeatherCycle:Clear ()
	RunConsoleCommand ("_weatherui_request_weathers")
end)

usermessage.Hook ("weatherui_item_added", function (umsg)
	local type = umsg:ReadString ()
	local duration = umsg:ReadFloat ()
	local item = WeatherControl.WeatherItem (type, duration)
	WeatherControl.WeatherCycle:AddWeatherItem (item)
end)

usermessage.Hook ("weatherui_item_modified", function (umsg)
	local id = umsg:ReadLong ()
	local type = umsg:ReadString ()
	local duration = umsg:ReadFloat ()
	WeatherControl.WeatherCycle:ModifyWeatherItem (id, type, duration)
end)

usermessage.Hook ("weatherui_item_removed", function (umsg)
	local id = umsg:ReadLong ()
	WeatherControl.WeatherCycle:RemoveWeatherItem (id)
end)

usermessage.Hook ("weatherui_item_moved_up", function (umsg)
	local id = umsg:ReadLong ()
	WeatherControl.WeatherCycle:MoveWeatherItemUp (id)
end)

usermessage.Hook ("weatherui_started", function (umsg)
	local id = umsg:ReadLong ()
	local endtime = umsg:ReadFloat ()
	WeatherControl.WeatherCycle:Start (id, endtime - CurTime ())
end)

usermessage.Hook ("weatherui_stopped", function (umsg)
	WeatherControl.WeatherCycle:Stop ()
end)