local self = _R.Entity

function self:TryCall (name, ...)
	if self [name] then
		return self [name] (self, ...)
	end
end