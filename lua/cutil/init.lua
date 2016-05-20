CUtil = CUtil or {}

function CUtil.ForEachArray (tbl, callback)
	for _, v in pairs (tbl) do
		callback (v)
	end
end

function CUtil.ForEach (tbl, callback)
	for k, v in pairs (tbl) do
		callback (k, v)
	end
end

function CUtil.FormatTime (time)
	local seconds = "00" .. tostring (math.floor (time % 60))
	local minutes = "00" .. tostring (math.floor (time / 60) % 60)
	local hours = "00" .. tostring (math.floor (time / 60 / 60))
	return hours:Right (2) .. ":" .. minutes:Right (2) .. ":" .. seconds:Right (2)
end

function CUtil.MakeConstructor (metatable)
	metatable.__index = metatable.__index or metatable
	return function (...)
		local object = {}
		setmetatable (object, metatable)
		object:ctor (...)
		return object
	end
end

local includes = {
	"cutil/eventprovider.lua",
	"cutil/subscriberlist.lua",
	"cutil/timerprovider.lua"
}

if SERVER then
	AddCSLuaFile ("cutil/init.lua")
	CUtil.ForEachArray (includes, AddCSLuaFile)
end
CUtil.ForEachArray (includes, include)