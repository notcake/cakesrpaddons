local EventProvider = {}
EventProvider.__index = EventProvider
CUtil.EventProvider = CUtil.MakeConstructor (EventProvider)

function EventProvider:ctor (host, getParentEventProvider)
	if host then
		host.AddEventListener = function (host, ...)
			return self:AddEventListener (...)
		end
		host.DispatchEvent = function (host, eventName, ...)
			return self:DispatchEvent (eventName, host, ...)
		end
		host.RemoveEventListener = function (host, ...)
			return self:RemoveEventListener (...)
		end
		host.SuppressEvents = function (host, ...)
			return self:SuppressEvents (...)
		end
	end

	self.EventListeners = {}
	self.ShouldSuppressEvents = false
	self.GetParentEventProvider = getParentEventProvider
end

function EventProvider:AddEventListener (eventName, nameOrCallback, callback)
	if not callback then
		callback = nameOrCallback
	end
	if not self.EventListeners [eventName] then
		self.EventListeners [eventName] = {}
	end
	self.EventListeners [eventName] [nameOrCallback] = callback
end

function EventProvider:DispatchEvent (eventName, ...)
	if self.ShouldSuppressEvents then
		return
	end
	local a, b, c = nil, nil, nil
	if self.EventListeners [eventName] then
		for callbackName, callback in pairs (self.EventListeners [eventName]) do
			local success, r0, r1, r2 = pcall (callback, ...)
			if not success then
				ErrorNoHalt ("Error in hook " .. eventName .. ": " .. tostring (callbackName) .. ": " .. tostring (r0))
			else
				a = a or r0
				b = b or r1
				c = c or r2
			end
		end
	end
	
	if self.GetParentEventProvider then
		local Parent = self:GetParentEventProvider ()
		if Parent then
			local success, r0, r1, r2 = pcall (Parent.DispatchEvent, Parent, eventName, ...)
			if not success then
				ErrorNoHalt ("Error in hook " .. eventName .. ": Parent: " .. tostring (r0))
			else
				a = a or r0
				b = b or r1
				c = c or r2
			end
		end
	end
	return a, b, c
end

function EventProvider:RemoveEventListener (eventName, nameOrCallback)
	if not self.EventListeners [eventName] then
		return
	end
	self.EventListeners [eventName] [nameOrCallback] = nil
	if next (self.EventListeners [eventName]) == nil then
		self.EventListeners [eventName] = nil
	end
end

function EventProvider:SuppressEvents (suppress)
	self.ShouldSuppressEvents = suppress
end