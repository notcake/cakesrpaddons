include ("cutil.lua")

WeatherControl = WeatherControl or {}
local AddCSLuaFile = AddCSLuaFile or function () end
local files = {
	"weatherui/weathertype.lua",
	"weatherui/weathertypecollection.lua",
	"weatherui/weathercycle.lua",
	"weatherui/weatheritem.lua"
}
for _, v in ipairs (files) do
	AddCSLuaFile (v)
	include (v)
end

WeatherControl.WeatherTypes = WeatherControl.WeatherTypeCollection ()
WeatherControl.WeatherCycle = WeatherControl.WeatherCycle ()

files = file.FindInLua ("weatherui/weathers/*.lua")
for _, v in ipairs (files) do
	AddCSLuaFile ("weatherui/weathers/" .. v)
	include ("weatherui/weathers/" .. v)
end

function WeatherControl.CanControlWeather (ply)
	return ply:IsAdmin ()
end

function WeatherControl.GetWeather ()
	return GetGlobalString ("weather")
end