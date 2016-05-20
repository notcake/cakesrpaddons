include ("shared.lua")

SWEP.Slot 				= 1
SWEP.SlotPos 			= 5
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false
SWEP.ViewModelFOV		= 70
SWEP.ViewModelFlip		= false

function SWEP:Initialize ()
	self:SetWeaponHoldType ("slam")
end

--[[
	Nicked from the css swep base
	Name: GetViewModelPosition
	Desc: Allows you to re-position the view model
]]
function SWEP:GetViewModelPosition (pos, ang)
	if not self.IronSightsPos then
		return pos, ang
	end

	local bIron = self.Weapon:GetNetworkedBool ("Ironsights")
	if bIron ~= self.bLastIron then
		self.bLastIron = bIron 
		self.fIronTime = CurTime ()
		if not bIron then 
			self.SwayScale 	= 0.3
			self.BobScale 	= 0.1
		else 
			self.SwayScale 	= 1.0
			self.BobScale 	= 1.0
		end
	end
	
	local fIronTime = self.fIronTime or 0
	if not bIron and fIronTime < CurTime () - self.IronTime then 
		return pos, ang 
	end
	
	local Mul = 1.0
	if fIronTime > CurTime () - self.IronTime then
		Mul = math.Clamp ((CurTime () - fIronTime) / self.IronTime, 0, 1)
		
		if not bIron then
			Mul = 1 - Mul
		end
	end

	local Offset = self.IronSightsPos
	
	if self.IronSightsAng then
		ang = ang * 1
		ang:RotateAroundAxis (ang:Right (), 	self.IronSightsAng.p * Mul)
		ang:RotateAroundAxis (ang:Up (), 		self.IronSightsAng.y * Mul)
		ang:RotateAroundAxis (ang:Forward (), 	self.IronSightsAng.r * Mul)
	end
	
	local Right 	= ang:Right ()
	local Up 		= ang:Up ()
	local Forward 	= ang:Forward ()
	
	pos = pos + Offset.x * Right * Mul
	pos = pos + Offset.y * Forward * Mul
	pos = pos + Offset.z * Up * Mul

	return pos, ang
end

function SWEP:DrawHUD ()
	local font = "TargetID"
	local hint = self:GetHint ()
	draw.DrawText (hint, font, ScrW () * 0.5 + 1, ScrH () * 0.5 + 1, Color (0, 64, 0, 255), TEXT_ALIGN_CENTER)
	draw.DrawText (hint, font, ScrW () * 0.5, ScrH () * 0.5, Color (96, 255, 96, 255), TEXT_ALIGN_CENTER)
end

function SWEP:GetHint ()
	return self:GetNetworkedString ("Hint") or ""
end

-- Horrible mess of derma and viewmodel code below.

-- global variables
KPC.DisplayOnViewmodel = false
KPC.ViewmodelOffset = Vector( 0.2, 2.1, 0.2 )
KPC.AdvOptionsOpen = false
KPC.MenuX = (ScrW()/2) - 125
KPC.MenuY = (ScrH()/2) - 125

-- Save And Load For The Player's Config
local function SaveCrackerConfig()
	
	-- glon cannot encode panels, so need to exclude this from the saved data
	local menu = KPC.Config
	KPC.Config = nil
	
	local encodedData = glon.encode( KPC )
	file.Write( "keypad_cracker_config.txt", encodedData )
	
	-- put the panel back where it was
	KPC.Config = menu
end

local function LoadCrackerConfig()
	
	if file.Exists( "keypad_cracker_config.txt" ) then
		
		local encodedData = file.Read( "keypad_cracker_config.txt" )
		local decodedData = glon.decode( encodedData )
		
		if type( decodedData ) == "table" then
			
			KPC.DisplayOnViewmodel 	= decodedData.DisplayOnViewmodel 	or KPC.DisplayOnViewmodel
			KPC.ViewmodelOffset 	= decodedData.ViewmodelOffset 		or KPC.ViewmodelOffset
			KPC.AdvOptionsOpen		= decodedData.AdvOptionsOpen		or KPC.AdvOptionsOpen
			KPC.MenuX 				= decodedData.MenuX 				or KPC.MenuX
			KPC.MenuY 				= decodedData.MenuY 				or KPC.MenuY
		end
	end
end
LoadCrackerConfig()	-- call it now

local function InterceptMouseReleased( panel )
	
	panel._OnMouseReleased = panel.OnMouseReleased
	panel.OnMouseReleased = function( self, mcode, ... )
		
		if self._OnMouseReleased then
			self:_OnMouseReleased( mcode, unpack( arg ) )
		end
		
		KPC.Config.GUIMousePress( mcode )
	end
end



KPC.Config = vgui.Create("DFrame")

-- fields
KPC.Config.Value = 1
KPC.Config.Negative = false
KPC.Config.Failed = false
KPC.Config.Succeeded = false
KPC.Config.FailureColor = Color(150, 50, 50, 255)
KPC.Config.SuccessColor = Color(50, 150, 50, 255)
KPC.Config.DefaultColor = Color(200, 200, 200, 255)
KPC.Config.CursorX, KPC.Config.CursorY = ScrW()/2, ScrH()/2
KPC.Config.Expanded = KPC.AdvOptionsOpen
KPC.Config.ExpandedHeight = 150
KPC.Config.CompactHeight = 110

-- config
KPC.Config:SetSize(250, KPC.Config.CompactHeight)
if KPC.Config.Expanded then KPC.Config:SetTall( KPC.Config.ExpandedHeight ) end

KPC.Config:SetPos( KPC.MenuX, KPC.MenuY )
KPC.Config:Center()
KPC.Config:SetTitle("")
KPC.Config:SetDeleteOnClose(false)
KPC.Config:ShowCloseButton(false)
KPC.Config:SetDraggable(true)
KPC.Config:SetScreenLock(true)
KPC.Config:SetVisible(false)



-- functions
KPC.Config.Paint = function( self )
	
	draw.RoundedBox(8, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 100))
	draw.SimpleTextOutlined( "Crack Master 3000         ", "Trebuchet20", 8, 4, Color( 255, 128, 50, 200 ), 
							 TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 1, Color(0, 0, 0, 255) )
end
-- because the numberslider can call its ValueChanged function many times. the SWEP is only updated with the new values on a Right Click
KPC.Config.GUIMousePress = function( code )
	
	if code == MOUSE_RIGHT then
		
		-- update the serverside SWEP
		RunConsoleCommand("keypad_cracker_setcrackingdata", tostring(KPC.Config.Value), tostring(KPC.Config.Negative))
		
		-- store the cursor position
		KPC.Config.CursorX = gui.MouseX()
		KPC.Config.CursorY = gui.MouseY()
		
		-- hide the gui
		KPC.Config:SetVisible(false)
		
		-- save the config
		SaveCrackerConfig()
		
		-- remove this hook, so it can only exist while the player is using the gui
		hook.Remove("GUIMousePressed", "Cracking.Crackers")
		
	end
end
KPC.Config.ToggleExpanded = function( self, value )
	
	if value != nil then
		self.Expanded = value
	else
		self.Expanded = !self.Expanded
	end
	
	if self.Expanded then
		self:SetTall( self.ExpandedHeight )
	else
		self:SetTall( self.CompactHeight )
	end
end
KPC.Config._OnMouseReleased = KPC.Config.OnMouseReleased
KPC.Config.OnMouseReleased = function( self, code )
	
	self:_OnMouseReleased( code )
	self.GUIMousePress( code )
end
	

-- A number slider to change the cracking start value
local slider = vgui.Create("DNumSlider", KPC.Config)
slider:SetPos(10, 40)
slider:SetSize(230, 50)
slider:SetText("")
slider:SetValue(KPC.Config.Value) 	
slider:SetDecimals(0)
slider:SetMinMax(1, 9999)
slider.ValueChanged = function( self )

	-- update "Value" with the sliders value
	KPC.Config.Value = self:GetValue() 
	KPC.Config.Succeeded = false
	KPC.Config.Failed = false
	
	slider:InvalidateLayout()
end

-- the slider wasnt updating when you used the textbox, so i haxed up this to make it update ( someone let me know if i've missed the proper way to do this )
local STA = slider:GetTextArea()
STA.OnEnter = function( self )
	slider:SetValue( math.Clamp(tonumber( self:GetValue() ), slider.Wang:GetMin(), slider.Wang:GetMax()) )
	self:SetValue( tostring(slider:GetValue()) )
end

-- A button, click it to change the cracking direction
local button = vgui.Create("DButton", KPC.Config)
button:SetSize( 80, 20 )
button:SetPos( 85, 40 )
button:SetText("Sweep Up")
button.DoClick = function()
	
	-- invert this boolean
	KPC.Config.Negative = !KPC.Config.Negative
	
	-- change the button text
	if KPC.Config.Negative then 
		button:SetText("Sweep Down")
	else
		button:SetText("Sweep Up")
	end

end

local advCheckBox = vgui.Create( "DCheckBoxLabel", KPC.Config )
advCheckBox:SetSize( 230, 16 )
advCheckBox:SetPos( 10, 84 )
advCheckBox:SetText( "Advanced Options" )
advCheckBox:SetValue( KPC.AdvOptionsOpen )
advCheckBox.OnChange = function( self, value )
	KPC.AdvOptionsOpen = value
	KPC.Config:ToggleExpanded( value )
end

local visCheckBox = vgui.Create("DCheckBoxLabel", KPC.Config )
visCheckBox:SetSize( 100, 16 )
visCheckBox:SetPos( 10, 122 )
visCheckBox:SetText( "Show Numbers" )
visCheckBox:SetValue( KPC.DisplayOnViewmodel )
visCheckBox.OnChange = function( self, value )
	KPC.DisplayOnViewmodel = value
end

local numberWangX = vgui.Create("DNumberWang", KPC.Config)
numberWangX:SetSize( 40, 20 )
numberWangX:SetPos( 110, 120 )
numberWangX:SetMinMax( -5, 5 )
numberWangX:SetDecimals(2)
numberWangX:SetValue( KPC.ViewmodelOffset.x )
numberWangX.OnValueChanged = function( self, value )
	
	value = math.Clamp( tonumber(value), self:GetMin(), self:GetMax() )
	
	KPC.ViewmodelOffset = Vector( value,
								  KPC.ViewmodelOffset.y,
								  KPC.ViewmodelOffset.z )
end

local numberWangY = vgui.Create("DNumberWang", KPC.Config)
numberWangY:SetSize( 40, 20 )
numberWangY:SetPos( 155, 120 )
numberWangY:SetMinMax( -5, 5 )
numberWangY:SetDecimals(2)
numberWangY:SetValue( KPC.ViewmodelOffset.y )
numberWangY.OnValueChanged = function( self, value )
	
	value = math.Clamp( tonumber(value), self:GetMin(), self:GetMax() )
	
	KPC.ViewmodelOffset = Vector( KPC.ViewmodelOffset.x,
								  value,
								  KPC.ViewmodelOffset.z )
end

local numberWangZ = vgui.Create("DNumberWang", KPC.Config)
numberWangZ:SetSize( 40, 20 )
numberWangZ:SetPos( 200, 120 )
numberWangZ:SetMinMax( -5, 5 )
numberWangZ:SetDecimals(2)
numberWangZ:SetValue( KPC.ViewmodelOffset.z )
numberWangZ.OnValueChanged = function( self, value )
	
	value = math.Clamp( tonumber(value), self:GetMin(), self:GetMax() )
	
	KPC.ViewmodelOffset = Vector( KPC.ViewmodelOffset.x,
								  KPC.ViewmodelOffset.y,
								  value )
end
	

KPC.Config.Slider = slider
KPC.Config.Button = button
KPC.Config.advCheckBox = advCheckBox
KPC.Config.visCheckBox = visCheckBox
KPC.Config.WangX = numberWangX
KPC.Config.WangY = numberWangY
KPC.Config.WangZ = numberWangZ

InterceptMouseReleased( slider )
InterceptMouseReleased( button )
InterceptMouseReleased( advCheckBox )
InterceptMouseReleased( advCheckBox.Label )
InterceptMouseReleased( visCheckBox )
InterceptMouseReleased( visCheckBox.Label )
InterceptMouseReleased( numberWangX )
InterceptMouseReleased( numberWangY )
InterceptMouseReleased( numberWangZ )



usermessage.Hook("keypad_cracker_togglegui", function(msg)
	
	if !KPC.Config then return end
	
	KPC.Config:SetVisible(true)
	KPC.Config:MakePopup()
	
	input.SetCursorPos( KPC.Config.CursorX, KPC.Config.CursorY )
	hook.Add("GUIMousePressed", "Cracking.Crackers", KPC.Config.GUIMousePress)
end)

-- this usermessage hook is triggered when you right click. it creates the vgui to configure the swep
usermessage.Hook("keypad_cracker_updateclient", function(msg)
	
	if !KPC.Config then return end
	
	-- starting number and direction passed by the usermessage
	local Value, Negative = msg:ReadShort(), msg:ReadBool()
	local Failed, Succeeded = msg:ReadBool(), msg:ReadBool()
	
	KPC.Config.Slider:SetValue(Value)
	
	if Negative then
		KPC.Config.Button:SetText("Sweep Down")
	else
		KPC.Config.Button:SetText("Sweep Up")
	end
	
	KPC.Config.Value = Value
	KPC.Config.Negative = Negative
	KPC.Config.Failed = Failed
	KPC.Config.Succeeded = Succeeded
	
end)

surface.CreateFont ("Trebuchet", 24, 500, true, false, "KPC_ViewModelFont")
function SWEP:ViewModelDrawn ()
	if not KPC.DisplayOnViewmodel then
		return
	end
	
	-- get the viewmodel entity
	local VM = LocalPlayer():GetViewModel()
	
  -- get these 2 attachments on the c4 model,  the upper right and lower left of the c4 screen
	local Att1, Att2 = VM:LookupAttachment("controlpanel0_ur"), VM:LookupAttachment("controlpanel0_ll")
	
  -- this function returns an AngPos Table, (a table containing the angle and position of the attachment)
	local LL = VM:GetAttachment(Att2) -- lower left
	
	local offset = Vector(KPC.ViewmodelOffset.x, KPC.ViewmodelOffset.y, KPC.ViewmodelOffset.z)
	offset:Rotate( LL.Ang )
	LL.Pos = LL.Pos + offset
	
	cam.Start3D2D(LL.Pos, LL.Ang, 0.05)
		
		local startValue = 1
		local color = Color( 200, 200, 200, 255 )
		
		if KPC.Config then
			
			startValue = KPC.Config.Value
			color = KPC.Config.DefaultColor
			
			if KPC.Config.Failed then
				color = KPC.Config.FailureColor
			elseif KPC.Config.Succeeded then
				color = KPC.Config.SuccessColor
			end
		end
		draw.DrawText (tostring (startValue), "KPC_ViewModelFont", 25, 12.5, color, TEXT_ALIGN_CENTER)
	cam.End3D2D ()
end