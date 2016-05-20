CGUI = CGUI or {}
CGUI.Controls = CGUI.Controls or {}
CGUI.Dialogs = CGUI.Dialogs or {}
CGUI.Renderers = CGUI.Renderers or {}
CGUI.Views = CGUI.Views or {}
CGUI.ParametricValidators = CGUI.ParametricValidators or {}
CGUI.Validators = CGUI.Validators or {}

if CGUI.DispatchEvent then
	CGUI:DispatchEvent ("Unload")
end

function CGUI.CreateControl (name, ...)
	local creator = CGUI.Controls [name]
	return creator and creator (...) or nil
end

function CGUI.CreateDialog (name, ...)
	local creator = CGUI.Dialogs [name]
	return creator and creator (...) or nil
end

function CGUI.CreateView (name, ...)
	local creator = CGUI.Views [name]
	return creator and creator (...) or nil
end

function CGUI.GetParametricValidator (name, ...)
	return CGUI.ParametricValidators [name] (...)
end

function CGUI.GetRenderer (name)
	return CGUI.Renderers [name]
end

function CGUI.GetValidator (name)
	return CGUI.Validators [name]
end

function CGUI.RegisterControl (name, creator)
	CGUI.Controls [name] = creator
end

function CGUI.RegisterDialog (name, creator)
	CGUI.Dialogs [name] = creator
end

function CGUI.RegisterParametricValidator (name, validatorFactory)
	CGUI.ParametricValidators [name] = validatorFactory
end

function CGUI.RegisterRenderer (name, renderer)
	CGUI.Renderers [name] = renderer
end

function CGUI.RegisterValidator (name, validator)
	CGUI.Validators [name] = validator
end

function CGUI.RegisterView (name, creator)
	CGUI.Views [name] = creator
end

CUtil.EventProvider (CGUI)
include ("cgui/validatorchain.lua")

include ("cgui/basepanel.lua")
include ("cgui/basedialog.lua")
include ("cgui/basequery.lua")
include ("cgui/number_validators.lua")
include ("cgui/renderers.lua")

for _, v in ipairs (file.FindInLua ("cgui/controls/*.lua")) do
	include ("cgui/controls/" .. v)
end