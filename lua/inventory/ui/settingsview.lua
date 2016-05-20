local View = nil

CGUI.RegisterView ("InventorySettingsView", function ()
	local self = CGUI.CreateControl ("BasePanel")
	self.LastVisibleTime = 0
	self.MaximumWeight = 0
	
	self.WeightSlider = vgui.Create ("DNumSlider", self)
	self.WeightSlider:SetText ("Maximum Inventory Weight")
	self.WeightSlider:SetMin (0)
	self.WeightSlider:SetMax (1000)
	self.WeightSlider:SetDecimals (0)
	
	self.CreateItemClass = vgui.Create ("GButton", self)
	self.CreateItemClass:SetText ("Create Item Class")
	self.CreateItemClass:SetSize (160, 28)
	self.CreateItemClass:AddEventListener ("Click", function (button)
		CGUI.CreateDialog ("InventoryItemClassAdditionDialog"):ShowDialog ()
	end)
	
	self.ModifyItemClass = vgui.Create ("GButton", self)
	self.ModifyItemClass:SetText ("Modify Item Class...")
	self.ModifyItemClass:SetSize (160, 28)
	self.ModifyItemClass:AddEventListener ("Click", function (button)
		CGUI.CreateDialog ("InventoryItemClassModificationDialog"):ShowDialog ()
	end)
	
	self.Description = vgui.Create ("DLabel", self)
	self.Description:SetText ("Open an inventory:\n\nEnter the steam ID of the player whose inventory you want to open.\nA partial name is fine too as long as the player is in the server.")
	self.Description:SetWrap (true)
	
	self.SteamEntry = vgui.Create ("DTextEntry", self)
	function self.SteamEntry.OnEnter (entry)
		self.OpenButton:DispatchEvent ("Click")
	end
	
	self.OpenButton = vgui.Create ("GButton", self)
	self.OpenButton:SetSize (80, 28)
	self.OpenButton:SetText ("Open")
	self.OpenButton:AddEventListener ("Click", function (button)
		local steam = self.SteamEntry:GetText ():Trim ()
		if steam == "" then
			self.Feedback:SetText ("That is not a valid Steam ID or name.")
			return
		end
		local players = {}
		for _, ply in ipairs (player.GetAll ()) do
			if ply:Name ():lower ():find (steam) then
				players [#players + 1] = ply
			end
		end
		if #players > 1 then
			self.Feedback:SetText ("Multiple players were found with that name.")
		elseif #players == 1 then
			if SinglePlayer () and players [1] == LocalPlayer () then
				steam = "STEAM_0:0:0"
			else
				steam = players [1]:SteamID ()
			end
		end
		if steam == "NULL" then
			steam = "BOT"
		end
		self.Feedback:SetText ("Looking up player...")
		RunConsoleCommand ("_inventory_inspect", steam)
	end)
	
	self.Feedback = vgui.Create ("DLabel", self)
	self.Feedback:SetText ("")
	
	function self.WeightSlider.OnValueChanged (slider)
		if self.MaximumWeight ~= slider:GetValue () then
			RunConsoleCommand ("_inventory_set_max_weight", tostring (slider:GetValue ()))
			self.MaximumWeight = slider:GetValue ()
		end
	end
	
	function self:SetMaximumWeight (weight)
		self.MaximumWeight = weight
		self.WeightSlider:SetValue (weight)
	end
	
	function self:SetVisible (visible)
		_R.Panel.SetVisible (self, visible)
		
		if visible and CurTime () - self.LastVisibleTime > 1 then
			self.LastVisibleTime = CurTime ()
			RunConsoleCommand ("_inventory_request_settings")
		end
	end
	
	self:AddLayouter (function (self)
		local x, y = 8, 8
		self.WeightSlider:SetPos (x, y)
		self.WeightSlider:SetWide (self:GetWide () - 16)
		y = y + self.WeightSlider:GetTall () + 8
		
		self.CreateItemClass:SetPos (x, y)
		y = y + self.CreateItemClass:GetTall () + 8
		self.ModifyItemClass:SetPos (x, y)
		y = y + self.ModifyItemClass:GetTall () + 32
		
		self.Description:SetPos (x, y)
		self.Description:SetSize (self:GetWide () - 8, 64)
		y = y + self.Description:GetTall () + 8
		
		self.SteamEntry:SetPos (x + 8, y)
		self.SteamEntry:SetWide (self:GetWide () * 0.5)
		self.OpenButton:SetPos (x + 16 + self.SteamEntry:GetWide (), y - 4)
		y = y + self.SteamEntry:GetTall ()
		
		self.Feedback:SetPos (x + 8, y)
		self.Feedback:SetWide (self:GetWide () - 16)
	end)
	
	View = self
	return self
end)

usermessage.Hook ("inventory_settings", function (umsg)
	if not View or not View:IsValid () then return end
	local maxweight = umsg:ReadFloat ()
	View:SetMaximumWeight (maxweight)
end)

usermessage.Hook ("inventory_inspection_response", function (umsg)
	if not View or not View:IsValid () then return end
	local id = umsg:ReadString ()
	local response = umsg:ReadString ()
	View.Feedback:SetText (response)
	if response == "" then
		local dialog = CGUI.CreateDialog ("InventoryInspectionDialog")
		dialog:OpenInventory (id)
		dialog:ShowDialog ()
	end
end)