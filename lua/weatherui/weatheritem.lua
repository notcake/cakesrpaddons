local self = {}
WeatherControl.WeatherItem = CUtil.MakeConstructor (self)

function self:ctor (type, duration)
	self.ID = 1

	self.Type = type
	self.Duration = duration
end

function self:GetDuration ()
	return self.Duration
end

function self:GetID ()
	return self.ID
end

function self:GetType ()
	return self.Type
end

function self:SetDuration (duration)
	self.Duration = duration
end

function self:SetID (id)
	self.ID = id
end

function self:SetType (type)
	self.Type = type
end

function self:Start ()
	WeatherControl.WeatherTypes:GetWeatherType (self:GetType ()):Start ()
end

function self:Stop ()
	WeatherControl.WeatherTypes:GetWeatherType (self:GetType ()):Stop ()
end