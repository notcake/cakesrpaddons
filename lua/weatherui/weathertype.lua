local self = {}
WeatherControl.WeatherType = CUtil.MakeConstructor (self)

function self:ctor (id, name)
	self.ID = id
	self.Name = name
end

function self:GetID ()
	return self.ID
end

function self:GetName ()
	return self.Name
end

function self:Start ()
	RunConsoleCommand ("weather_select", self.ID)
end

function self:Stop ()
	RunConsoleCommand ("weather_select", "sunny")
end