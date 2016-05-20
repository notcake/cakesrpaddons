local typeids = {
	"sunny",
	"dark",
	"cloudy",
	"rain",
	"darkrain",
	"heavyrain",
	"sunnyrain"
}
local typenames = {
	"Sunny",
	"Dark",
	"Cloudy",
	"Rain",
	"Rain (Dark)",
	"Heavy Rain",
	"Rain (Sunny)"
}

for i = 1, #typeids do
	WeatherControl.WeatherTypes:AddWeatherType (WeatherControl.WeatherType (typeids [i], typenames [i]))
end

local Random = WeatherControl.WeatherType ("random", "Random")
function Random:Start ()
	local count = #typeids
	local id = typeids [math.random (1, count)]
	RunConsoleCommand ("weather_select", id)
end

WeatherControl.WeatherTypes:AddWeatherType (Random)