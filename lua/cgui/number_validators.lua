CGUI.RegisterValidator ("Number", function (dialog, input)
	local number = tonumber (input)
	if not number then
		return false, "You must enter a valid number."
	end
	return true
end)

CGUI.RegisterValidator ("PositiveNumber", function (dialog, input)
	local valid, message = CGUI.GetValidator ("Number") (dialog, input)
	if not valid then
		return valid, message
	end
	local number = tonumber (input)
	if number < 0 then
		return false, "You cannot enter a negative number."
	end
	return true
end)

CGUI.RegisterValidator ("Integer", function (dialog, input)
	local valid, message = CGUI.GetValidator ("Number") (dialog, input)
	if not valid then
		return valid, message
	end
	local number = tonumber (input)
	if math.floor (number) ~= number then
		return false, "You must enter a whole number."
	end
	return true
end)

CGUI.RegisterParametricValidator ("MinimumNumber", function (minimum)
	return function (dialog, input)
		local valid, message = CGUI.GetValidator ("Number") (dialog, input)
		if not valid then
			return valid, message
		end
		local number = tonumber (input)
		if number < minimum then
			return false, "You must enter a value that is at least " .. tostring (minimum) .. "."
		end
		return true
	end	
end)

CGUI.RegisterParametricValidator ("MaximumNumber", function (minimum)
	return function (dialog, input)
		local valid, message = CGUI.GetValidator ("Number") (dialog, input)
		if not valid then
			return valid, message
		end
		local number = tonumber (input)
		if number > minimum then
			return false, "You must enter a value that is at most " .. tostring (minimum) .. "."
		end
		return true
	end	
end)