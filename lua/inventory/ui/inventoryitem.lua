local HoverMaterial = Material ("vgui/spawnmenu/hover")
local Gradient = Material ("gui/gradient_down")

CGUI.RegisterControl ("InventoryItem", function (item)
	local self = CGUI.CreateControl ("BasePanel")
	self:SetTall (64)
	self.Selected = false
	self.InventoryView = nil
	
	self.Item = item
	self.Item:AddEventListener ("Updated", function ()
		if not self:IsValid () then
			return
		end
		self:Update ()
	end)
	
	self.Name = vgui.Create ("DLabel", self)
	self.Name:SetText ("Item")
	self.Name:SetFont ("TargetID")
	
	self.Weight = vgui.Create ("DLabel", self)
	self.Weight:SetText ("0 lb each")
	self.Weight:SetFont ("TargetID")
	
	self.TotalWeight = vgui.Create ("DLabel", self)
	self.TotalWeight:SetText ("0 lb total")
	self.TotalWeight:SetFont ("TargetID")
	
	if item:GetModel () and
		item:GetModel () ~= "models/" then
		self.ModelView = vgui.Create ("ModelImage", self)
		self.ModelView:SetPos (0, 0)
		self.ModelView:SetModel (item:GetModel ())
	end
	
	self.Count = vgui.Create ("DLabel", self)
	self.Count:SetText ("0")
	self.Count:SetTextColor (Color (255, 255, 128, 255))
	self.Count:SetFont ("TargetID")
	self.Count:SetExpensiveShadow (1, Color (0, 0, 0, 192))
	
	self:AddLayouter (function (self)
		if self.ModelView then
			self.ModelView:SetSize (64, 64)
		end
		self.Name:SetPos (72, 4)
		self.Name:SizeToContents ()
		
		self.Weight:SizeToContents ()
		self.Weight:SetPos ((self:GetWide () - 64) * 0.7 - self.Weight:GetWide (), self:GetTall () - self.Weight:GetTall ())
		
		self.TotalWeight:SizeToContents ()
		self.TotalWeight:SetPos (self:GetWide () - self.TotalWeight:GetWide () - 4, self:GetTall () - self.TotalWeight:GetTall ())
		
		self.Count:SizeToContents ()
		self.Count:SetPos (64 - self.Count:GetWide () - 4, 64 - self.Count:GetTall () - 2)
	end)
	
	function self:Deselect ()
		self.Selected = false
		self:DispatchEvent ("Deselected")
	end
	
	function self:GetItem ()
		return self.Item
	end
	
	function self:IsHovered ()
		if self.Hovered then
			return true
		end
		if self.ModelView and self.ModelView.Hovered then
			return true
		end
		return false
	end
	
	function self:IsSelected ()
		return self.Selected
	end
	
	function self:OnCursorEntered ()
		self:DispatchEvent ("MouseOver")
	end
	
	function self:OnCursorExited ()
		self:DispatchEvent ("MouseOut")
	end
	
	function self:OnMousePressed ()
		self:Select ()
	end
	
	function self:OnMouseReleased ()
		self:DispatchEvent ("Click")
	end
	
	function self:Paint ()
		if self.Selected then
			draw.RoundedBox (4, 0, 0, self:GetWide (), self:GetTall (), Color (128, 128, 255, 128))
		else
			draw.RoundedBox (4, 0, 0, self:GetWide (), self:GetTall (), Color (128, 128, 128, 128))
		end
		surface.SetDrawColor (255, 255, 255, 32)
		surface.SetMaterial (Gradient)
		surface.DrawTexturedRect (0, 0, self:GetWide (), self:GetTall ())
	end
	
	function self:PaintOver ()
		if self:IsHovered () then
			surface.SetDrawColor (255, 255, 255, 32)
			surface.SetMaterial (Gradient)
			surface.DrawTexturedRect (0, 0, self:GetWide (), self:GetTall ())
		end
	end
	
	function self:Select ()
		if self.Selected then
			return
		end
		self.Selected = true
		self:DispatchEvent ("Selected")
	end
	
	function self:SetInventoryView (view)
		self.InventoryView = view
	end
	
	function self:Update ()
		self.Name:SetText (self.Item:GetName () or "Unknown")
		self.Weight:SetText (tostring (math.Round (self.Item:GetWeight (), 1)) .. " lb each")
		self.TotalWeight:SetText (tostring (math.Round (self.Item:GetTotalWeight (), 1)) .. " lb total")
		
		local count = self.Item:GetCount ()
		self.Count:SetVisible (count > 1)
		self.Count:SetText (tostring (count))
		
		self:PerformLayout ()
	end
	
	self:Update ()
	return self
end)