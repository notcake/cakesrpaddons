CGUI.RegisterView ("MyInventoryView", function ()
	local self = CGUI.CreateControl ("BasePanel")
	self.LastVisibleTime = 0
	
	self.PlayerView = vgui.Create ("DModelPanel", self)
	self.PlayerView:SetAnimated (true)
	self.PlayerView:SetFOV (90)
	self.PlayerView:SetAnimSpeed (1)
	
	self.PlayerInfo = vgui.Create ("DLabel", self)
	self.PlayerInfo:SetFont ("TargetID")
	
	self.View = CGUI.CreateView ("InventoryView")
	self.View:SetParent (self)
	self.View:OpenInventory (SinglePlayer () and "STEAM_0:0:0" or LocalPlayer ():SteamID ())
	self.View:AddEventListener ("WeightChanged", function (view, inventory)
		self.Weight:SetText (tostring (math.Round (inventory:GetWeight (), 1)) .. " / " .. tostring (math.Round (inventory:GetMaximumWeight (), 1)) .. " lb")
		self:PerformLayout ()
	end)
	self.View:AddEventListener ("ItemSelected", function (view, control, item)
		item:AddEventListener ("ActionsUpdated", "InventoryView", function (item)
			self:UpdateButtons ()
		end)
		item:RequestActionList ()
	end)
	self.View:AddEventListener ("ItemDeselected", function (view, control, item)
		item:RemoveEventListener ("ActionsUpdated", "InventoryView")
	end)
	
	self.Drop = vgui.Create ("GButton", self)
	self.Drop:SetSize (80, 36)
	self.Drop:SetText ("Drop")
	self.Drop:AddEventListener ("Click", function (button)
		self.View:RunItemAction ("Drop")
	end)
	
	self.Equip = vgui.Create ("GButton", self)
	self.Equip:SetSize (80, 36)
	self.Equip:SetText ("Equip")
	self.Equip:AddEventListener ("Click", function (button)
		self.View:RunItemAction ("Equip")
	end)
	
	self.Holster = vgui.Create ("GButton", self)
	self.Holster:SetSize (80, 36)
	self.Holster:SetText ("Holster")
	self.Holster:AddEventListener ("Click", function (button)
		RunConsoleCommand ("_inventory_holster")
	end)
	
	self.Use = vgui.Create ("GButton", self)
	self.Use:SetSize (80, 36)
	self.Use:SetText ("Use")
	self.Use:AddEventListener ("Click", function (button)
		self.View:RunItemAction ("Use")
	end)
	
	self.Weight = vgui.Create ("DLabel", self)
	self.Weight:SetText ("0 / 0 lb")
	self.Weight:SetFont ("TargetID")
	
	self:AddLayouter (function (self)
		self.PlayerView:SetPos (4, 4)
		self.PlayerView:SetSize (self:GetWide () * 0.3 - 2, self:GetTall () * 0.5)
		
		self.PlayerInfo:SetPos (16, self.PlayerView:GetTall () + 8)
		self.PlayerInfo:SizeToContents ()
	
		self.View:SetPos (self:GetWide () * 0.3 + 2, 4)
		self.View:SetSize (self:GetWide () * 0.7 - 6, self:GetTall () - 56)
		
		self.Drop:SetPos (self:GetWide () * 0.3 + 2, self.View:GetTall () + 12)
		self.Equip:SetPos (self:GetWide () * 0.3 + 10 + self.Drop:GetWide (), self.View:GetTall () + 12)
		self.Holster:SetPos (self:GetWide () * 0.3 + 18 + self.Drop:GetWide () + self.Equip:GetWide (), self.View:GetTall () + 12)
		self.Use:SetPos (self:GetWide () * 0.3 + 26 + self.Drop:GetWide () + self.Equip:GetWide () + self.Holster:GetWide (), self.View:GetTall () + 12)
		
		self.Weight:SizeToContents ()
		self.Weight:SetPos (self:GetWide () - self.Weight:GetWide () - 16, self:GetTall () - self.Weight:GetTall () - 16)
	end)
	
	function self:SetVisible (visible)
		_R.Panel.SetVisible (self, visible)
		
		if visible and CurTime () - self.LastVisibleTime > 1 then
			self.LastVisibleTime = CurTime ()
			self:UpdatePlayerInfo ()
		end
	end
	
	function self:UpdateButtons ()
		self.Drop:SetDisabled (not self.View:GetSelectedItem ():GetItem ():CanRunAction (LocalPlayer (), "drop"))
		self.Equip:SetDisabled (not self.View:GetSelectedItem ():GetItem ():CanRunAction (LocalPlayer (), "equip"))
		self.Use:SetDisabled (not self.View:GetSelectedItem ():GetItem ():CanRunAction (LocalPlayer (), "use"))
	end
	
	function self:UpdatePlayerInfo ()
		local playerinfo = LocalPlayer ():Name () .. "\n\n"
		self.PlayerView:SetModel (LocalPlayer ():GetModel ())
		if LocalPlayer ().DarkRPVars then
			playerinfo = playerinfo .. "    Job: " .. LocalPlayer ().DarkRPVars.job .. "\n"
			if LocalPlayer ().DarkRPVars.money >= 0 then
				playerinfo = playerinfo .. "    Money: $" .. tostring (LocalPlayer ().DarkRPVars.money) .. "\n"
			else
				playerinfo = playerinfo .. "    Money: -$" .. tostring (-LocalPlayer ().DarkRPVars.money) .. "\n"
			end
		else
			playerinfo = playerinfo .. "    Job: Unknown\n"
			playerinfo = playerinfo .. "    Money: Unknown\n"
		end
		self.PlayerInfo:SetText (playerinfo)
		self:PerformLayout ()
	end
	
	self:UpdatePlayerInfo ()
	return self
end)