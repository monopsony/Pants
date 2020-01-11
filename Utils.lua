local pants=PantsAddon
local LSM=LibStub:GetLibrary("LibSharedMedia-3.0")
local unpack,ipairs,pairs,wipe=unpack,ipairs,pairs,table.wipe

pants.colors={
    ["epic"]={0.64,0.21,0.93},
    ["epic_hex"]="136207",
    ['yellow_hex']=''
}

pants.predefined_messages={
    ["name"]="|cffa335eePants|r",
    ["add_items_none_found"]="No items were found. Type '/pants add' followed by shift-clicking relevant items to add them to the session.",
    ["help_message"]='available commands:\n'
        ..'|cffffff00help|r Displays this message\n'
        ..'|cffffff00toggle|r Show/hides main frame\n'
        ..'|cffffff00history|r Show/hides history frame\n'
        ..'|cffffff00add|r Adds items to the session (shift-click links)\n'
        ..'|cffffff00council|r Shows information about the current council\n'
        ..'|cffffff00quick|r Toggles the Quick pants window\n',
    ["raid_ping"]=function(a,b) return ("%s pinged the %s."):format(a or "N/A",b:lower()) end,
    ['not_in_council']=function(a) return ('You need to be in the council to %s.'):format(a or 'do this') end,
    ['no_rl_paras']='Raid leader has not sent out council members.',
    ['generic']=function(a) return tostring(a) end,
}

pants.item_loc_to_slot={
    INVTYPE_AMMO={0},
    INVTYPE_HEAD={1},
    INVTYPE_NECK={2},
    INVTYPE_SHOULDER={3},
    INVTYPE_BODY={4},
    INVTYPE_CHEST={5},
    INVTYPE_WAIST={6},
    INVTYPE_LEGS={7},
    INVTYPE_FEET={8},
    INVTYPE_WRIST={9},
    INVTYPE_HAND={10},
    INVTYPE_FINGER={11,12},
    INVTYPE_TRINKET={13,14},
    INVTYPE_CLOAK={15},
    INVTYPE_WEAPON={16,17},
    INVTYPE_SHIELD={17},
    INVTYPE_WEAPONMAINHAND={16},
    INVTYPE_WEAPONOFFHAND={17},
    INVTYPE_2HWEAPON={16,17},
    INVTYPE_RANGED={18},
    INVTYPE_THROWN={18},
    INVTYPE_RANGEDRIGHT={18},
    INVTYPE_RELIC={18},
    INVTYPE_TABARD={19},
    INVTYPE_BAG={20,21,22,23},
    INVTYPE_QUIVER={20,21,22,23},
}

pants.item_itemSubType_class_filters={
    ['Cloth']={
        ['WARRIOR']=true,
        ['PALADIN']=true,
        ['HUNTER']=true,
        ['ROGUE']=true,
        ['PRIEST']=false,
        ['SHAMAN']=true,
        ['MAGE']=false,
        ['MONK']=true,
        ['WARLOCK']=false,
        ['DRUID']=true,
        ['DEMONHUNTER']=true,
        ['DEATHKNIGHT']=true,
    },
    
    ['Leather']={
        ['WARRIOR']=true,
        ['PALADIN']=true,
        ['HUNTER']=true,
        ['ROGUE']=false,
        ['PRIEST']=true,
        ['SHAMAN']=true,
        ['MAGE']=true,
        ['MONK']=false,
        ['WARLOCK']=true,
        ['DRUID']=false,
        ['DEMONHUNTER']=false,
        ['DEATHKNIGHT']=true,
    },
    
    ['Mail']={
        ['WARRIOR']=true,
        ['PALADIN']=true,
        ['HUNTER']=false,
        ['ROGUE']=true,
        ['PRIEST']=true,
        ['SHAMAN']=false,
        ['MAGE']=true,
        ['MONK']=true,
        ['WARLOCK']=true,
        ['DRUID']=true,
        ['DEMONHUNTER']=true,
        ['DEATHKNIGHT']=true,
    },
    
    ['Plate']={
        ['WARRIOR']=false,
        ['PALADIN']=false,
        ['HUNTER']=true,
        ['ROGUE']=true,
        ['PRIEST']=true,
        ['SHAMAN']=true,
        ['MAGE']=true,
        ['MONK']=true,
        ['WARLOCK']=true,
        ['DRUID']=true,
        ['DEMONHUNTER']=true,
        ['DEATHKNIGHT']=false,
    },

    ['One-Handed Swords']={
        ['WARRIOR']=false,
        ['PALADIN']=false,
        ['HUNTER']=false,
        ['ROGUE']=false,
        ['PRIEST']=true,
        ['SHAMAN']=true,
        ['MAGE']=false,
        ['MONK']=false,
        ['WARLOCK']=false,
        ['DRUID']=true,
        ['DEMONHUNTER']=false,
        ['DEATHKNIGHT']=false,
    },

    ['One-Handed Maces']={
        ['WARRIOR']=false,
        ['PALADIN']=false,
        ['HUNTER']=true,
        ['ROGUE']=false,
        ['PRIEST']=false,
        ['SHAMAN']=false,
        ['MAGE']=true,
        ['MONK']=false,
        ['WARLOCK']=true,
        ['DRUID']=false,
        ['DEMONHUNTER']=true,
        ['DEATHKNIGHT']=true,
    },

    ['Daggers']={
        ['WARRIOR']=false,
        ['PALADIN']=true,
        ['HUNTER']=false,
        ['ROGUE']=false,
        ['PRIEST']=false,
        ['SHAMAN']=false,
        ['MAGE']=false,
        ['MONK']=true,
        ['WARLOCK']=false,
        ['DRUID']=false,
        ['DEMONHUNTER']=false,
        ['DEATHKNIGHT']=true,    
    },

    ['One-Handed Axes']={
        ['WARRIOR']=false,
        ['PALADIN']=false,
        ['HUNTER']=false,
        ['ROGUE']=false,
        ['PRIEST']=true,
        ['SHAMAN']=false,
        ['MAGE']=true,
        ['MONK']=true,
        ['WARLOCK']=true,
        ['DRUID']=true,
        ['DEMONHUNTER']=false,
        ['DEATHKNIGHT']=false,
    },

    ['Two-Handed Swords']={
        ['WARRIOR']=false,
        ['PALADIN']=false,
        ['HUNTER']=true,
        ['ROGUE']=false,
        ['PRIEST']=true,
        ['SHAMAN']=true,
        ['MAGE']=true,
        ['MONK']=true,
        ['WARLOCK']=true,
        ['DRUID']=true,
        ['DEMONHUNTER']=true,
        ['DEATHKNIGHT']=false,
    },

    ['Two-Handed Axes']={
        ['WARRIOR']=false,
        ['PALADIN']=false,
        ['HUNTER']=false,
        ['ROGUE']=true,
        ['PRIEST']=true,
        ['SHAMAN']=true,
        ['MAGE']=true,
        ['MONK']=false,
        ['WARLOCK']=true,
        ['DRUID']=true,
        ['DEMONHUNTER']=true,
        ['DEATHKNIGHT']=false,
    },

    ['Two-Handed Maces']={
        ['WARRIOR']=false,
        ['PALADIN']=false,
        ['HUNTER']=true,
        ['ROGUE']=true,
        ['PRIEST']=true,
        ['SHAMAN']=false,
        ['MAGE']=true,
        ['MONK']=true,
        ['WARLOCK']=true,
        ['DRUID']=false,
        ['DEMONHUNTER']=true,
        ['DEATHKNIGHT']=false,
    },

    ['Shields']={
        ['WARRIOR']=false,
        ['PALADIN']=false,
        ['HUNTER']=true,
        ['ROGUE']=true,
        ['PRIEST']=true,
        ['SHAMAN']=false,
        ['MAGE']=true,
        ['MONK']=true,
        ['WARLOCK']=true,
        ['DRUID']=true,
        ['DEMONHUNTER']=true,
        ['DEATHKNIGHT']=true,
    },

    ['Miscellaneous']={

    }
}

setmetatable(pants.item_itemSubType_class_filters,
    {
        __index=function(self,index)
            if not index then return {} end
            self[index]={}
            pants:send_user_message( ('WARN: no itemSubType entry for %s'):format(index) )
            return self[index]
        end
    }
)

function pants:send_user_message(key,...)
    local msg,s=(self.predefined_messages[key] or key) or "NO KEY GIVEN",""
    if type(msg)=="string" then
        s=msg
    elseif type(msg)=="function" then 
        s=msg(...)
    else
        s="UNRCOGNIZED TYPE"
    end
    
    print(("%s: %s"):format(self.predefined_messages.name,s))
end

local GetItemInfo=GetItemInfo
function pants:itemlink_info(ilink)
    local itemName,itemLink,itemRarity,itemLevel,itemMinLevel,itemType,itemSubType,_,itemEquipLoc,itemIcon,_,itemClassID,itemSubClassID=GetItemInfo(ilink)
    
    return {
        itemName=itemName,
        itemLink=itemLink,
        itemRarity=itemRarity,
        itemLevel=itemLevel,
        itemMinLevel=itemMinLevel,
        itemType=itemType,
        itemSubType=itemSubType,
        itemEquipLoc=itemEquipLoc,
        itemIcon=itemIcon,
        itemClassID=itemClassID,
        itemSubClassID=itemSubClassID,
        itemTertiary=pants:get_tertiary_stats(itemLink),
        }
end

local help_table1={}
local GetItemStats=GetItemStats
function pants:get_tertiary_stats(itemLink)
    --mostly borrowed from RCLootCouncil
    --https://www.curseforge.com/wow/addons/rclootcouncil
	local delimiter=self.para.tertiary_stats_delimiter or "/"
	wipe(help_table1)
	GetItemStats(itemLink,help_table1)
	local text = ""
	for k, _ in pairs(help_table1) do
		if k:find("SOCKET") then
			text = "Socket"
			break
		end
	end
    
	if help_table1["ITEM_MOD_CR_AVOIDANCE_SHORT"] then
		if text ~= "" then text = text..delimiter end
		text = text.._G.ITEM_MOD_CR_AVOIDANCE_SHORT
	end
	if help_table1["ITEM_MOD_CR_LIFESTEAL_SHORT"] then
		if text ~= "" then text = text..delimiter end
		text = text.._G.ITEM_MOD_CR_LIFESTEAL_SHORT
	end
	if help_table1["ITEM_MOD_CR_SPEED_SHORT"] then
		if text ~= "" then text = text..delimiter end
		text = text.._G.ITEM_MOD_CR_SPEED_SHORT
	end
	if help_table1["ITEM_MOD_CR_STURDINESS_SHORT"] then -- Indestructible
		if text ~= "" then text = text..delimiter end
		text = text.._G.ITEM_MOD_CR_STURDINESS_SHORT
	end    
    return text
end

--/script DEFAULT_CHAT_FRAME:AddMessage("\124cffff8000\124Hitem:77949::::::::120:::::\124h[Golad, Twilight of Aspects]\124h\124r");
--/script DEFAULT_CHAT_FRAME:AddMessage("\124cff0070dd\124Hitem:158030::::::::120::::2:42:4803:\124h[Bleakweald Vambraces]\124h\124r");
local sgsub=string.gsub
function pants:separate_itemlinks(msg)
    local s=sgsub(msg,"]|h|r","]|h|r ")
    return sgsub(s,"|c%x+|Hitem"," %0")
end

local sfind=string.find
function pants:is_itemlink(msg)
    if not (type(msg)=="string") then return false end
    return sfind(msg,"|Hitem")
end


function pants:RGBToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("%02x%02x%02x", r*255, g*255, b*255)
end

local RAID_CLASS_COLORS=RAID_CLASS_COLORS
function pants:class_to_hex(class)
    local c=RAID_CLASS_COLORS[class]
    if not c then return 'ffffffff' end
    return c:GenerateHexColor()
end

local LibS =LibStub:GetLibrary("AceSerializer-3.0")
local LibD=LibStub:GetLibrary("LibDeflate")

function pants:serialize_compress_encode(tbl)
    if (not tbl) or (not type(tbl)=="table") then return nil end
    local s1=LibS:Serialize(tbl)
    local s2=LibD:CompressDeflate(s1)
    local s3=LibD:EncodeForWoWAddonChannel(s2)
    return s3
end

function pants:compress_encode(s)
    if (not s) or (not type(s)=="string") then return nil end
    local s1=LibD:CompressDeflate(s)
    local s2=LibD:EncodeForWoWAddonChannel(s1)
    return s2
end

function pants:decode_decompress_deserialize(str)
    if (not str) or (not type(str)=="string") then return nil end
    local s1=LibD:DecodeForWoWAddonChannel(str)
    local s2=LibD:DecompressDeflate(s1)
    local _,s3=LibS:Deserialize(s2)
    return s3
end

function pants:decode_decompress(s)
    if (not s) or (not type(s)=="string") then return nil end
    local s1=LibD:DecodeForWoWAddonChannel(s)
    local s2=LibD:DecompressDeflate(s1)
    return s2
end

local sfind=string.find
function pants:convert_to_full_name(s)
    if (not s) or not (type(s)=="string") then return s end
    local realm=self.realm_name or ""
    if not sfind(s,"-") then s=("%s-%s"):format(s,realm) end
    return s
end

local strsub=string.sub
function pants:remove_realm(s)
    if (not s) or not (type(s)=="string") then return s end
    return strsub(s,1,(s:find("-") or 0)-1)
end

function pants:table_deep_copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[self:table_deep_copy(orig_key)] = self:table_deep_copy(orig_value)
        end
        setmetatable(copy, self:table_deep_copy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local raid_units={}
for i=1,40 do raid_units[i]="raid"..tostring(i) end
local party_units={"player","party1","party2","party3","party4"}
local player_list={"player"}
function pants:get_units_list()
    if not IsInGroup() then return player_list end
    return (IsInRaid() and raid_units) or party_units
end

local UnitFulLName=UnitFullName
function pants:unit_full_name(unit)
    if not UnitExists(unit) then return end
    local name,realm=UnitFullName(unit)
    if (not realm) or (realm=='') then realm=self.realm_name end
    if (not realm) then 
        local _,realm=UnitFullName("player")
        self.realm_name=realm
    end
    return ("%s-%s"):format(name,realm)
end

local ipairs=ipairs
function pants:get_item_link_slot(slot)
    if not slot then return end
    local id=((type(slot)=="number") and {slot}) or ((type(slot)=="string") and self.item_loc_to_slot[slot]) or nil
    if not id then return end
    local links={}
    for i,v in ipairs(id) do 
        local item=ItemLocation:CreateFromEquipmentSlot(v)
        if (item) and (item:IsValid()) then 
            local link=C_Item.GetItemLink(item)
            links[#links+1]=link
        end
    end
        
    return links
end

function pants:clearEmptyTables(t)
    for k,v in pairs(t) do
        if type(v) == 'table' then
            self:clearEmptyTables(v)
            if next(v) == nil then
                t[k] = nil
            end
         end
     end
end


function pants:are_you_ML()
    local para=self.current_rl_paras
    if (not para) or (not para.council) then return false end

    for k,v in pairs(para.council) do 
        if (type(v)=='string') and (v~='') then 
            local name=Ambiguate(v,'none')
            if UnitExists(name) and UnitInRaid(name) then
                return UnitIsUnit(name,'player') 
            end
        end
    end
end