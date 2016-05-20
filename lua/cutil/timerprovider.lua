local TimerProvider = {}
TimerProvider.__index = TimerProvider

CUtil.TimerProvider = CUtil.MakeConstructor (TimerProvider)

function TimerProvider:ctor (host, getParentTimerProvider)
	if host then
		host.AddTimer = function (host, name, duration, callback, ...)
			return self:AddTimer (name, duration, callback, host, ...)
		end
		host.ProcessTimers = function (host, ...)
			return self:ProcessTimers (...)
		end
		host.RemoveTimer = function (host, ...)
			return self:RemoveTimer (...)
		end
	end

	self.Timers = {}
end

function TimerProvider:AddTimer (name, duration, callback, ...)
	name = name and tostring (name) or tostring (callback)
	local timer = nil
	timer = {
		Arguments = {...},
		Callback = function ()
			callback (unpack (timer.Arguments))
		end,
		End = CurTime () + duration
	}
	self.Timers [name] = timer
end

function TimerProvider:ProcessTimers ()
	local curtime = CurTime ()
	local finished = {}
	for name, timer in pairs (self.Timers) do
		if curtime >= timer.End then
			finished [#finished + 1] = name
		end
	end
	for k, v in ipairs (finished) do
		finished [k] = self.Timers [v]
		self:RemoveTimer (v)
	end
	for _, timer in ipairs (finished) do
		timer.Callback ()
	end
end

function TimerProvider:RemoveTimer (name)
	name = tostring (name)
	self.Timers [name] = nil
end