local self = {}
WeatherControl.WeatherCycle = CUtil.MakeConstructor (self)

function self:ctor ()
	CUtil.EventProvider (self)
	self.Subscribers = CUtil.SubscriberList ()

	self.CurrentItem = nil
	self.CurrentID = nil
	self.CurrentEndTime = 0
	
	self.Items = {}
end

-- Serialization
function self:Load ()
	if CLIENT then
		return
	end
	local path = "weathercycle.txt"
	local data = file.Read (path)
	if not data then
		return
	end
	local tbl = util.KeyValuesToTable (data)
	local items = {}
	for k, v in pairs (tbl) do
		local item = WeatherControl.WeatherItem (v.type, tonumber (v.duration))
		items [tonumber (k)] = item
	end
	for _, item in ipairs (items) do
		self:AddWeatherItem (item)
	end
	
	self:Start (1)
end

function self:Save ()
	if CLIENT then
		return
	end
	local path = "weathercycle.txt"
	local data = {}
	for _, item in ipairs (self.Items) do
		data [#data + 1] = {
			Duration = item:GetDuration (),
			Type = item:GetType ()
		}
	end
	file.Write (path, util.TableToKeyValues (data))
end

function self:AddSubscriber (ply)
	self.Subscribers:AddPlayer (ply)
end

function self:AddWeatherItem (item)
	item:SetID (#self.Items + 1)
	self.Items [item:GetID ()] = item
	
	if SERVER then
		local filter = self.Subscribers:GetRecipientFilter ()
		if #filter > 0 then
			umsg.Start ("weatherui_item_added", filter)
				umsg.String (item:GetType ())
				umsg.Float (item:GetDuration ())
			umsg.End ()
		end
	end
	
	self:DispatchEvent ("ItemAdded", item)
	self:Save ()
end

function self:Clear ()
	self.Items = {}
	self:Stop ()
end

function self:GetCurrentItem ()
	return self.CurrentItem
end

function self:GetCurrentEndTime ()
	return self.CurrentEndTime
end

function self:GetItemCount ()
	return #self.Items
end

function self:GetWeatherItem (id)
	return self.Items [id]
end

function self:GetWeatherItemIterator ()
	local next, tbl, key = ipairs (self.Items)
	return function ()
		key = next (tbl, key)
		return tbl [key]
	end
end

function self:ModifyWeatherItem (id, type, duration)
	local item = self.Items [id]
	if not item then
		return
	end
	if not WeatherControl.WeatherTypes:GetWeatherType (type) then
		return
	end
	item:SetType (type)
	item:SetDuration (duration)
	
	if SERVER then
		local filter = self.Subscribers:GetRecipientFilter ()
		if #filter > 0 then
			umsg.Start ("weatherui_item_modified", filter)
				umsg.Long (item:GetID ())
				umsg.String (item:GetType ())
				umsg.Float (item:GetDuration ())
			umsg.End ()
		end
	end
	
	self:DispatchEvent ("ItemChanged", item, id)
	self:Save ()
end

function self:MoveWeatherItemDown (id)
	local item = self.Items [id]
	if not item or id == #self.Items then
		return
	end
	self:MoveWeatherItemUp (id + 1)
end

function self:MoveWeatherItemUp (id)
	local item = self.Items [id]
	if not item or id == 1 then
		return
	end
	local previous = self.Items [id - 1]
	previous:SetID (id)
	item:SetID (id - 1)
	self.Items [id] = previous
	self.Items [id - 1] = item
	
	if self.CurrentItem then
		self.CurrentItemID = self.CurrentItem:GetID ()
	end
	
	if SERVER then
		local filter = self.Subscribers:GetRecipientFilter ()
		if #filter > 0 then
			umsg.Start ("weatherui_item_moved_up", filter)
				umsg.Long (id)
			umsg.End ()
		end
	end
	
	self:DispatchEvent ("ItemMovedUp", item, id)
end

function self:RemoveSubscriber (ply)
	self.Subscribers:RemovePlayer (ply)
end

function self:RemoveWeatherItem (index)
	local item = self.Items [index]
	if not item then
		return
	end
	if self:GetCurrentItem () == item then
		self:Stop ()
	end
	table.remove (self.Items, index)
	for i = item:GetID (), #self.Items do
		self.Items [i]:SetID (i)
	end
	if self.CurrentItem then
		self.CurrentItemID = self.CurrentItem:GetID ()
	end
	
	if SERVER then
		local filter = self.Subscribers:GetRecipientFilter ()
		if #filter > 0 then
			umsg.Start ("weatherui_item_removed", filter)
				umsg.Long (item:GetID ())
			umsg.End ()
		end
	end
	
	self:DispatchEvent ("ItemRemoved", item)
	self:Save ()
end

function self:Start (id, duration)
	if self:GetCurrentItem () then
		self:Stop ()
	end
	local item = self.Items [id]
	if not item then
		return
	end
	local duration = duration or item:GetDuration ()
	self.CurrentItem = item
	self.CurrentItemID = item:GetID ()
	self.CurrentEndTime = CurTime () + duration
	
	if SERVER then
		item:Start ()
		timer.Create ("WeatherUI", duration, 1, function ()
			id = id + 1
			if id > #self.Items then
				id = 1
			end
			self:Start (id)
		end)
		local filter = self.Subscribers:GetRecipientFilter ()
		if #filter > 0 then
			umsg.Start ("weatherui_started", filter)
				umsg.Long (item:GetID ())
				umsg.Float (self.CurrentEndTime)
			umsg.End ()
		end
	end
	self:DispatchEvent ("Started", item)
end

function self:Stop ()
	if not self:GetCurrentItem () then
		return
	end
	if SERVER then
		self:GetCurrentItem ():Stop ()
	end
	self.CurrentItem = nil
	self.CurrentItemID = nil
	self.CurrentEndTime = 0
	
	if SERVER then
		local filter = self.Subscribers:GetRecipientFilter ()
		if #filter > 0 then
			umsg.Start ("weatherui_stopped", filter)
			umsg.End ()
		end
	end
	
	self:DispatchEvent ("Stopped")
	
	timer.Destroy ("WeatherUI")
end