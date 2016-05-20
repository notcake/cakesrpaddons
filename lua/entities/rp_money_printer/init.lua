-- RRPX Money Printer reworked for DarkRP by philxyz
-- Heavily modified by !cake
AddCSLuaFile ("cl_init.lua")
AddCSLuaFile ("shared.lua")

AddCSLuaFile ("password.lua")
AddCSLuaFile ("settings.lua")
include ("shared.lua")

CreateConVar ("sbox_maxmoney_printers", 2)

--[[
	Internal Console Commands
		_money_printer_password (EntityIndex printer_ent_id, string password)
		_money_printer_set_overdrive (EntityIndex printer_ent_id, bool Overdrive)
		_money_printer_set_password (EntityIndex printer_ent_id, string password)
		_money_printer_set_store (EntityIndex printer_ent_id, bool Store)
		_money_printer_take_money (EntityIndex printer_ent_id)
		_money_printer_ui_closed (EntityIndex printer_ent_id)

	Usermessages:
		money_printer_ui_password_open	- Tells the client to open the money printer password entry UI
			Entity MoneyPrinter
		money_printer_ui_password_close	- Tells the client to close the money printer password entry UI
		money_printer_password_response - Tells the client whether the password they entered was valid
										  If there is no password, this is sent immediately with Valid = true.
			bool Valid
		money_printer_ui_open			- Tells the client to open the money printer UI
			Entity MoneyPrinter
			long Money
			bool ShouldStoreMoney
			bool InOverdrive
			string Password
		money_printer_ui_close			- Tells the client to close the money printer UI
		money_printer_mode				- Updates the money printer mode on the client's UI
			bool ShouldStoreMoney
			bool InOverdrive
		money_printer_money				- Updates the money printer's contents shown on the client's UI
			long Money
		money_printer_password			- Updates the money printer password shown on the client's UI
			string Password

	Printing cycle:
		1. Sparks for 3 seconds
		2. Stops sparking, spawns money
		3. 100 to 350 seconds later (random) it starts again
]]

local Settings = {}
Settings.StartupTime = 27
Settings.PrintingTime = 3
Settings.PrintingIntervalMinimum = 100
Settings.PrintingIntervalMaximum = 350

Settings.OverdriveAmount = 400

function ENT:Initialize()
	self:SetModel ("models/props_c17/consolebox01a.mdl")
	self:PhysicsInit (SOLID_VPHYSICS)
	self:SetMoveType (MOVETYPE_VPHYSICS)
	self:SetSolid (SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject ()
	if phys:IsValid () then
		phys:Wake ()
	end
	
	self.damage = 100
	self.IsMoneyPrinter = true

	self.Overheating = false
	self.Sparking = false
	
	self.Password = self.Password or nil
	
	-- Output modes
	self.StoreMoney = self.StoreMoney or false
	self.StoredMoney = self.StoredMoney or 0
	
	-- Operating modes
	self.Overdrive = self.Overdrive or false
	
	-- UI updates
	self.EventSubscribers = self.EventSubscribers or {}
	CUtil.TimerProvider (self)
	
	self:AddTimer ("NextPrintCycle", Settings.StartupTime, self.BeginPrintCycle)
end

-- UI updates and such
function ENT:AddEventSubscriber (ply)
	for _, v in pairs (self.EventSubscribers) do
		if v == ply then
			return
		end
	end
	self.EventSubscribers [#self.EventSubscribers + 1] = ply
end

function ENT:CullEventSubscribers ()
	local to_remove = {}
	for k, v in pairs (self.EventSubscribers) do
		if not v:IsValid () or
			not self:CanPlayerInteract (v) then
			to_remove [#to_remove + 1] = k
		end
	end
	for _, k in ipairs (to_remove) do
		self.EventSubscribers [k] = nil
	end
end

function ENT:GetEventSubscriberFilter (ply)
	local filter = RecipientFilter ()
	for _, v in pairs (self.EventSubscribers) do
		filter:AddPlayer (v)
	end
	return filter
end

function ENT:HasEventSubscribers ()
	for _, _ in pairs (self.EventSubscribers) do
		return true
	end
	return false
end

function ENT:IsPlayerSubscribed (ply)
	for k, v in pairs (self.EventSubscribers) do
		if v == ply then
			return true
		end
	end
	return false
end

function ENT:RemoveEventSubscriber (ply)
	for k, v in pairs (self.EventSubscribers) do
		if v == ply then
			self.EventSubscribers [k] = nil
			return
		end
	end
end
-- End of UI update code

function ENT:AddStoredMoney (amount)
	self.StoredMoney = self.StoredMoney + amount
	self:SendMoney ()
end

function ENT:BeginPrintCycle ()
	self:BeginSparking (Settings.PrintingTime)
	self:AddTimer ("PrintMoney", Settings.PrintingTime, self.PrintMoney)
end

function ENT:BeginSparking (duration)
	self.Sparking = true
	self:AddTimer ("Sparking", duration, function (self)
		self.Sparking = false
	end)
end

function ENT:BeginOverheating ()
	if self:IsOverheating () then
		return
	end
	self.Overheating = true
	
	local burntime = math.random (8, 18)
	self:Ignite (burntime, 0)
	self:AddTimer ("Burn", burntime, self.Fireball)

	self:Notify (self.dt.owning_ent, 1, 4, "Your money printer is overheating!")
end
ENT.BurstIntoFlames = ENT.BeginOverheating -- backwards compatibility

function ENT:CanPlayerInteract (ply)
	if not ply:Alive () then
		return false
	end
	
	local distance = (ply:GetPos () - self:GetPos ()):Length ()
	return distance < 96
end

-- Does the money printer destruction effects
function ENT:Destruct ()
	local vPoint = self:GetPos ()
	local effectdata = EffectData ()
	effectdata:SetStart (vPoint)
	effectdata:SetOrigin (vPoint)
	effectdata:SetScale (1)
	util.Effect ("Explosion", effectdata)
	self:Notify (self.dt.owning_ent, 1, 4, "Your money printer has exploded!")
end

function ENT:Fireball ()
	if not self:IsOnFire () then
		return
	end
	local dist = math.random (20, 280) -- Explosion radius
	self:Destruct ()
	for k, v in pairs (ents.FindInSphere (self:GetPos (), dist)) do
		if not v:IsPlayer () and not v.IsMoneyPrinter then
			v:Ignite (math.random (5, 22), 0)
		end
	end
	self:Remove ()
end

function ENT:GetPassword ()
	return self.Password or ""
end

function ENT:GetPrintAmount ()
	local amount = GetConVarNumber ("mprintamount")
	if amount == 0 then
		amount = 250
	end
	if self:IsInOverdrive () then
		amount = Settings.OverdriveAmount
	end
	return amount
end

function ENT:GetSavedFields ()
	return {
		"Overheating",
		"Sparking",
		"Password",
		"StoreMoney",
		"StoredMoney",
		"Overdrive"
	}
end

function ENT:GetRandomPrintCycleInterval ()
	local interval = math.random (Settings.PrintingIntervalMinimum, Settings.PrintingIntervalMaximum)
	if self:IsInOverdrive () then
		interval = interval * 0.5
	end
	return interval
end

function ENT:GetStoredMoney ()
	return self.StoredMoney
end

function ENT:IsInOverdrive ()
	return self.Overdrive
end

function ENT:IsOverheating ()
	return self.Overheating
end

function ENT:IsPassworded ()
	return self.Password ~= nil
end

function ENT:IsSparking ()
	return self.Sparking
end

function ENT:Notify (ply, a, b, message)
	if Notify then
		Notify (ply, a, b, message)
	else
		ply:PrintMessage (HUD_PRINTTALK, message)
	end
end

-- Destroys or ignites the money printer if it has taken 100 damage in total
function ENT:OnTakeDamage (dmg)
	if self:IsOverheating () then
		return
	end

	self.damage = (self.damage or 100) - dmg:GetDamage()
	if self.damage <= 0 then
		local rnd = math.random(1, 10)
		if rnd < 3 then
			self:BeginOverheating ()
		else
			self:Destruct ()
			self:Remove ()
		end
	end
end

function ENT:PrintMoney ()
	if self:IsOnFire () then
		return
	end
	local MoneyPos = self:GetPos ()

	if self:ShouldStartOverheating () then
		self:BeginOverheating ()
	end
	
	local amount = self:GetPrintAmount ()
	if DarkRPCreateMoneyBag and not self:ShouldStoreMoney () then
		DarkRPCreateMoneyBag (Vector (MoneyPos.x + 15, MoneyPos.y, MoneyPos.z + 15), amount)
	else
		self:AddStoredMoney (amount)
	end
	self:AddTimer ("NextPrintCycle", self:GetRandomPrintCycleInterval (), self.BeginPrintCycle)
end

function ENT:SetOverdriveEnabled (overdrive)
	self.Overdrive = overdrive
	self:SendMode ()
end

function ENT:SetPassword (password)
	if password and password:len () > 0 then
		self.Password = password
	else
		self.Password = nil
	end
	self:SendPassword ()
end

function ENT:SetSpawner (ply)
	self.dt.owning_ent = ply
end

function ENT:SetStoreMoney (store)
	self.StoreMoney = store
	self:SendMode ()
end

function ENT:SetStoredMoney (money)
	self.StoredMoney = money
	self:SendMoney ()
end

function ENT:ShouldStartOverheating ()
	local threshold = 1
	if self:IsInOverdrive () then
		threshold = threshold * 3
	end
	return math.random (1, 22) <= threshold
end

function ENT:ShouldStoreMoney ()
	return self.StoreMoney
end

function ENT:SpawnFunction (ply, tr)
	-- Check limits
	if ply:GetCount ("money_printer") >= GetConVarNumber ("sbox_maxmoney_printers") and
		GetConVarNumber ("sbox_maxmoney_printers") >= 0 then
		ply:LimitHit ("money_printers")
		return nil
	end	

	if not tr.Hit then
		return
	end
	local pos = tr.HitPos + tr.HitNormal * 16
	local ent = ents.Create ("rp_money_printer")
	ent:SetPos (pos)
	ent:Spawn ()
	ent:Activate ()
	ent:SetSpawner (ply)
	
	ply:AddCount ("money_printer", ent)
	ply:AddCleanup ("money_printer", ent)
	return ent
end

function ENT:StopOverheating ()
	self.Overheating = false
	self:Extinguish ()
	self:RemoveTimer ("Burn")

	self:Notify (self.dt.owning_ent, 1, 4, "Your money printer has stopped overheating!")
end

function ENT:Think ()
	self:ProcessTimers ()
	if not self:IsSparking () then
		return
	end

	local effectdata = EffectData ()
	effectdata:SetOrigin (self:GetPos ())
	effectdata:SetMagnitude (1)
	if self:IsInOverdrive () then
		effectdata:SetMagnitude (3)
	end
	effectdata:SetScale (1)
	effectdata:SetRadius (2)

	util.Effect ("Sparks", effectdata)
end

function ENT:Use (ply)
	if self:IsPlayerSubscribed (ply) then
		return
	end
	if self:IsPassworded () then
		umsg.Start ("money_printer_ui_password_open", ply)
			umsg.Entity (self)
		umsg.End ()
	else
		self:OpenPlayerSettingsUI (ply)
	end
end

function ENT:VerifyPassword (ply, password)
	local correct = self.Password == password
	umsg.Start ("money_printer_password_response", ply)
		umsg.Bool (correct)
	umsg.End ()
	if correct then
		self:AddTimer (nil, 0.5, function (self, ply)
			umsg.Start ("money_printer_ui_password_close", ply)
			umsg.End ()
			self:OpenPlayerSettingsUI (ply)
		end, ply)
	end
end

-- UI stuff
function ENT:OpenPlayerSettingsUI (ply)
	umsg.Start ("money_printer_ui_open", ply)
		umsg.Entity (self)
		umsg.Long (self:GetStoredMoney ())
		umsg.Bool (self:ShouldStoreMoney ())
		umsg.Bool (self:IsInOverdrive ())
		umsg.String (self:GetPassword () or "")
	umsg.End ()
	
	self:AddEventSubscriber (ply)
end

function ENT:SendMode (filter)
	if not filter then
		self:CullEventSubscribers ()
		if not self:HasEventSubscribers () then
			return
		end
		filter = self:GetEventSubscriberFilter ()
	end
	umsg.Start ("money_printer_mode", self:GetEventSubscriberFilter ())
		umsg.Bool (self:ShouldStoreMoney ())
		umsg.Bool (self:IsInOverdrive ())
	umsg.End ()
end

function ENT:SendMoney (filter)
	if not filter then
		self:CullEventSubscribers ()
		if not self:HasEventSubscribers () then
			return
		end
		filter = self:GetEventSubscriberFilter ()
	end
	umsg.Start ("money_printer_money", filter)
		umsg.Long (self:GetStoredMoney ())
	umsg.End ()
end

function ENT:SendPassword (filter)
	if not filter then
		self:CullEventSubscribers ()
		if not self:HasEventSubscribers () then
			return
		end
		filter = self:GetEventSubscriberFilter ()
	end
	umsg.Start ("money_printer_password", filter)
		umsg.String (self:GetPassword ())
	umsg.End ()
end

if SinglePlayer () then
	concommand.Add ("rp_money_printer_test", function ()
		for _, ent in ipairs (ents.FindByClass ("rp_money_printer")) do
			ent:BeginOverheating ()
		end
	end)
end

local function TryRunConsoleCommand (ent_id, ply, func)
	local ent = ents.GetByIndex (tonumber (ent_id) or - 2)
	if not ent or not ent:IsValid () or
		not ent:CanPlayerInteract (ply) then
		return
	end
	func (ent, ply)
end

concommand.Add ("_money_printer_password", function (ply, _, args)
	if #args < 1 then
		return
	end
	TryRunConsoleCommand (args [1], ply, function (self, ply)
		self:VerifyPassword (ply, tostring (args [2]))
	end)
end)

concommand.Add ("_money_printer_set_overdrive", function (ply, _, args)
	if #args < 2 then
		return
	end
	TryRunConsoleCommand (args [1], ply, function (self, ply)
		self:SetOverdriveEnabled (util.tobool (args [2]))
	end)
end)

concommand.Add ("_money_printer_set_password", function (ply, _, args)
	if #args < 2 then
		return
	end
	TryRunConsoleCommand (args [1], ply, function (self, ply)
		local password = args [2]:gsub ("[^1-9]", "")
		self:SetPassword (args [2])
	end)
end)

concommand.Add ("_money_printer_set_store", function (ply, _, args)
	if #args < 2 then
		return
	end
	TryRunConsoleCommand (args [1], ply, function (self, ply)
		self:SetStoreMoney (util.tobool (args [2]))
	end)
end)

concommand.Add ("_money_printer_take_money", function (ply, _, args)
	if #args < 1 then
		return
	end
	TryRunConsoleCommand (args [1], ply, function (self, ply)
		if ply.AddMoney then
			ply:AddMoney (self:GetStoredMoney ())
		end
		self:SetStoredMoney (0)
	end)
end)

concommand.Add ("_money_printer_ui_closed", function (ply, _, args)
	if #args < 1 then
		return
	end
	local ent = ents.GetByIndex (tonumber (args [1]) or - 2)
	if not ent or not ent:IsValid () then
		return
	end
	ent:RemoveEventSubscriber (ply)
end)

hook.Add ("PlayerDeath", "MoneyPrinterSettingsUI", function (ply)
	umsg.Start ("money_printer_ui_close", ply)
	umsg.End ()
end)