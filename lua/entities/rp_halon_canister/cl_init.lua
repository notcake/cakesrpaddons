include ("shared.lua")

language.Add ("Cleanup_halon_canister", "Halon Canisters")
language.Add ("Cleaned_halon_canister", "Cleaned up Halon Canisters")
language.Add ("SBoxLimit_halon_canisters", "You have hit the Halon Canister limit!")
language.Add ("rp_halon_canister", "Halon Canister")

function ENT:Draw ()
	self:DrawModel ()
end

function ENT:GetEmitterPos ()
	return self:LocalToWorld (Vector (0, 0, 28))
end

function ENT:Initialize ()
	self.DiffusionSpeed = 100
end

function ENT:IsEmitting ()
	return self:GetNetworkedBool ("Emitting")
end

function ENT:IsFading ()
	return self:GetNetworkedBool ("Fading")
end

function ENT:Think ()
	if self:IsEmitting () then
		local emitter = ParticleEmitter (self:GetPos ())
		local pos = Vector (math.Rand (-1,1), math.Rand (-1,1), math.Rand (-1,1)):GetNormalized ()
		local particle = emitter:Add ("particles/smokey", self:GetEmitterPos () + pos * math.Rand (0, 10))
		if particle then
			particle:SetVelocity (pos * math.Rand (10, self.DiffusionSpeed))
			particle:SetLifeTime (0)
			particle:SetDieTime (math.Rand (1, 5))
			particle:SetStartAlpha (math.Rand (200, 255))
			particle:SetStartAlpha (48)
			particle:SetEndAlpha (0)
			particle:SetStartSize (20)
			particle:SetEndSize (75)
			particle:SetRoll (math.Rand (0, 360))
			particle:SetRollDelta (math.Rand (-0.2, 0.2))
			particle:SetColor (153, 102, 51)
		end
	end
	if self:IsFading () then
		local starttime = self:GetNetworkedFloat ("FadeStart")
		local endtime = self:GetNetworkedFloat ("FadeEnd")
		local curtime = CurTime ()
		local alpha = (endtime - curtime) / (endtime - starttime) * 255
		if alpha < 0 then
			alpha = 0
		end
		self:SetColor (255, 255, 255, alpha)
	end
	self:NextThink (CurTime () + 0.5)
	return true
end