local self = {}
WeatherControl.WeatherTypeCollection = CUtil.MakeConstructor (self)

function self:ctor ()
	self.Types = {}
end

function self:AddWeatherType (type)
	self.Types [type:GetID ()] = type
end

function self:GetWeatherType (id)
	return self.Types [id]
end

function self:GetWeatherTypeIterator ()
	local next, tbl, key = pairs (self.Types)
	return function ()
		key = next (tbl, key)
		return tbl [key]
	end
end