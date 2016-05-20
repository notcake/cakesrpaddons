local ClientCollection = {}
ClientCollection.__index = ClientCollection
CInventory.ClientCollection = CUtil.MakeConstructor (ClientCollection)

function ClientCollection:ctor ()
	CUtil.EventProvider (self)
	
	self.Clients = {}
	
	hook.Add ("PlayerInitialSpawn", "CInventory", function (ply)
		self:AddPlayer (ply)
	end)
	
	-- Don't do this on a listen server
	if not GetConVar ("sensitivity") then
		hook.Add ("EntityRemoved", "CInventory", function (ply)
			if not ply:IsPlayer () then
				return
			end
			self:RemovePlayer (ply)
		end)
	end
	
	CInventory.ItemClasses:AddEventListener ("WeightChanged", function (itemclasses, itemclass)
		for _, client in pairs (self.Clients) do
			for inventory in client:GetOpenInventoryIterator () do
				local tbl = {}
				tbl.ID = inventory:GetID ()
				tbl.Items = {}
				for item in inventory:GetItemIterator () do
					if item:GetItemClass () == itemclass then
						tbl.Items [#tbl.Items + 1] = {
							ID = item:GetID (),
							Weight = item:GetWeight ()
						}
					end
				end
				datastream.StreamToClients (client:GetPlayer (), "inventory_items", tbl)
			end
		end
	end)
end

function ClientCollection:AddClient (client)
	self.Clients [client:GetPlayer ()] = client
	local inventory = CInventory.LoadInventory (client:GetPlayer ():SteamID ())
	inventory:SetOwner (client:GetPlayer ())
	
	self:DispatchEvent ("ClientAdded", client)
end

function ClientCollection:AddPlayer (ply)
	if self:ContainsPlayer (ply) then
		return
	end
	self:AddClient (CInventory.Client (ply))
end

function ClientCollection:ContainsPlayer (ply)
	return self.Clients [ply] and true or false
end

function ClientCollection:GetClient (ply)
	return self.Clients [ply]
end

function ClientCollection:Initialize ()
	for _, ply in pairs (player.GetAll ()) do
		if not self:ContainsPlayer (ply) then
			self:AddPlayer (ply)
		end
	end
end

function ClientCollection:Remove (client)
	if not client then
		return
	end
	client:Remove ()
	self.Clients [client:GetPlayer ()] = nil
	
	self:DispatchEvent ("ClientRemoved", client)
end

function ClientCollection:RemovePlayer (ply)
	if not ply or not ply:IsValid () then
		return
	end
	self:Remove (self:GetClient (ply))
	CInventory.Inventories:GetInventory (ply:SteamID ()):Release ()
end