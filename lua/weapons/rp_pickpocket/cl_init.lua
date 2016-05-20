include ("shared.lua")

SWEP.Slot 				= 1
SWEP.SlotPos 			= 5
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true
SWEP.ViewModelFOV		= 70
SWEP.ViewModelFlip		= false

function SWEP:Initialize ()
	self:SetWeaponHoldType ("normal")
end

function SWEP:DrawHUD ()
	local font = "TargetID"
	local target = self:GetPickpocketTarget ()
	local name = ""
	if target then
		name = target:GetClass ()
		if target.Name then
			name = target:Name ()
		end
	end
	
	-- Draw redness
	local delta_caught_time = CurTime () - self:GetNetworkedFloat ("CaughtTime")
	if delta_caught_time < 2 then
		local alpha = 192 * (2 - delta_caught_time) * 0.5
		surface.SetDrawColor (255, 0, 0, alpha)
		surface.DrawRect (0, 0, ScrW (), ScrH ())
	end
	
	-- Draw text
	if self:IsPickpocketting () then
		local progress = self:GetPickpocketProgress ()
		if progress >= 1 then
			progress = 0
		end
		local width = ScrW () * 0.2
		local height = width * 0.15
		local x = (ScrW () - width) * 0.5
		local y = ScrH () * 0.55
		draw.RoundedBox (4, x, y, width, height, Color (128, 128, 128, 255 * progress * 3))
		
		width = (width - 8) * progress
		draw.RoundedBox (4, x + 4, y + 4, width, height - 8, Color (128, 255, 128, 255 * progress * 3))
		
		if self:IsLookingAway () then
			local message = "You must be looking at your target and in range to pickpocket successfully!"
			draw.DrawText (message, font, ScrW () * 0.5 + 1, ScrH () * 0.5 + 1, Color (64, 0, 0, 255), TEXT_ALIGN_CENTER)
			draw.DrawText (message, font, ScrW () * 0.5, ScrH () * 0.5, Color (255, 96, 96, 255), TEXT_ALIGN_CENTER)
		else
			local message = "Pickpocketting " .. name .. "..."
			draw.DrawText (message, font, ScrW () * 0.5 + 1, ScrH () * 0.5 + 1, Color (0, 0, 0, 255), TEXT_ALIGN_CENTER)
			draw.DrawText (message, font, ScrW () * 0.5, ScrH () * 0.5, Color (255, 255, 255, 255), TEXT_ALIGN_CENTER)
		end
	elseif target then
		local message = "Left click to start pickpocketting " .. name .. "\nRight click to try to steal an item"
		draw.DrawText (message, font, ScrW () * 0.5 + 1, ScrH () * 0.5 + 1, Color (0, 64, 0, 255), TEXT_ALIGN_CENTER)
		draw.DrawText (message, font, ScrW () * 0.5, ScrH () * 0.5, Color (192, 255, 192, 255), TEXT_ALIGN_CENTER)
	end
end

function SWEP:GetPickpocketProgress ()
	local start_time = self:GetNetworkedFloat ("PickpocketStartTime")
	local end_time = self:GetNetworkedFloat ("PickpocketEndTime")
	local length = end_time - start_time
	return (CurTime () - start_time) / length
end

function SWEP:GetPickpocketTarget ()
	local target = self:GetNetworkedEntity ("PickpocketTarget")
	if not target or
		not target:IsValid () then
		return nil
	end
	return target
end

function SWEP:IsLookingAway ()
	return self:GetNetworkedBool ("LookingAway")
end

function SWEP:IsPickpocketting ()
	return self:GetNetworkedBool ("Pickpocketting")
end

usermessage.Hook ("pickpocket_cancel", function (umsg)
	surface.PlaySound ("resource/warning.wav")
end)

usermessage.Hook ("pickpocket_caught", function (umsg)
	local target = umsg:ReadEntity ()
	local name = target:GetClass ()
	if target.Name then
		name = target:Name ()
	end
	chat.AddText (Color (255, 0, 0, 255), name .. " caught you pickpocketting!")
	surface.PlaySound ("ambient/alarms/klaxon1.wav")
end)

usermessage.Hook ("pickpocket_discovered", function (umsg)
	local thief = umsg:ReadEntity ()
	local name = thief:GetClass ()
	if thief.Name then
		name = thief:Name ()
	end
	chat.AddText (Color (255, 0, 0, 255), name .. " was trying to steal from you!")
	surface.PlaySound ("ambient/alarms/klaxon1.wav")
end)

usermessage.Hook ("pickpocket_success", function (umsg)
	local target = umsg:ReadEntity ()
	local amount = umsg:ReadLong ()
	local name = target:GetClass ()
	if target.Name then
		name = target:Name ()
	end
	if amount >= 0 then
		chat.AddText (Color (128, 255, 128, 255), "You stole $" .. tostring (amount) .. " from " .. name .. ".")
	elseif amount < 0 then
		chat.AddText (Color (128, 255, 128, 255), "You stole $" .. tostring (-amount) .. "'s worth of debt from " .. name .. ".")
	else
		chat.AddText (Color (128, 255, 128, 255), name .. " had no money on them!")
	end
	surface.PlaySound ("garrysmod/content_downloaded.wav")
end)