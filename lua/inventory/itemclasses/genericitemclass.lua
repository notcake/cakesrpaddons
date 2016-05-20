local GenericItemClass = {}
GenericItemClass.__index = GenericItemClass
setmetatable (GenericItemClass, CInventory.ItemClass)
CInventory.GenericItemClass = CUtil.MakeConstructor (GenericItemClass)

function GenericItemClass:ctor (name, parameters)
	CInventory.ItemClass.ctor (self, name, parameters)
	
	self:RegisterAction ("Drop")
end

function GenericItemClass:ExportItemFile (item, tbl)
	tbl.ExtraFields = item.ExtraFields
end

function GenericItemClass:ImportItemFile (item, tbl)
	item.ExtraFields = tbl.extrafields
end

function GenericItemClass:GetItemName (item)
	return self:GetName ()
end

function GenericItemClass:SetUpEntityFromItem (item, ent)
	if item.ExtraFields then
		for _, field in pairs (item.ExtraFields) do
			if field.value then
				ent [field.name] = field.value
			end
		end
	end
end

function GenericItemClass:SetUpItemFromEntity (item, ent)
	local extrafields = ent:TryCall ("GetSavedFields")
	if extrafields then
		item.ExtraFields = {}
		for _, fieldname in ipairs (extrafields) do
			local field = {
				name = fieldname,
				value = ent [fieldname]
			}
			item.ExtraFields [#item.ExtraFields + 1] = field
		end
	end
end