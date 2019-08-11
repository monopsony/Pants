PurpsAddon=LibStub("AceAddon-3.0"):NewAddon("PurpsAddon","AceConsole-3.0","AceComm-3.0","AceEvent-3.0","AceSerializer-3.0")
local purps=PurpsAddon
local LSM=LibStub:GetLibrary("LibSharedMedia-3.0")
local unpack,ipairs,pairs=unpack,ipairs,pairs
purps.colors={
    ["epic"]={0.64,0.21,0.93},
    ["epic_hex"]="136207",
}

purps.predefined_messages={
    ["name"]="|cffa335eePurps|r",
    ["add_items_none_found"]="No items found. Type '/purps add' followed by shift-clicking relevant items to add them to the session.",
    ["help_message"]=function() return ("This is the %s help message,"):format(purps.predefined_messages.name) end,
}


function purps:send_user_message(key,...)
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

local defaults={
    profile={
        scroll_item_size={40,40},
        scroll_item_default_icon=136207,
        scroll_item_spacing=10,
        scroll_frame_display_count=4,
        scroll_frame_width=65,
    },-- end of profile
}--end of defaults


function purps:OnInitialize()
    
    self.db=LibStub("AceDB-3.0"):New("RaidNotesDB",defaults,true)  --true sets the default profile to a profile called "Default"
                                                                 --see https://www.wowace.com/projects/ace3/pages/api/ace-db-3-0
    self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
    
    self.para=self.db.profile
    
    self.interface:populate_scroll_child()
    self.interface:update_scroll_parameters()
    
end

local GetItemInfo=GetItemInfo
function purps:itemlink_info(ilink)
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
        itemSubClassID=itemSubClassID
        }
end

--/script DEFAULT_CHAT_FRAME:AddMessage("\124cffff8000\124Hitem:77949::::::::120:::::\124h[Golad, Twilight of Aspects]\124h\124r");
--/script DEFAULT_CHAT_FRAME:AddMessage("\124cff0070dd\124Hitem:158030::::::::120::::2:42:4803:\124h[Bleakweald Vambraces]\124h\124r");
local sgsub=string.gsub
local function separate_itemlinks(msg)
    local s=sgsub(msg,"]|h|r","]|h|r ")
    return sgsub(s,"|c%x+|Hitem"," %0")
end

local sfind=string.find
function purps:is_itemlink(msg)
    if not (type(msg)=="string") then return false end
    return sfind(msg,"|Hitem")
end

local chat_commands={
    ["add"]=function(self,msg)
    
        if not purps:is_itemlink(msg) then purps:send_user_message("add_items_none_found") end
        local msg=separate_itemlinks(msg)
        local args={self:GetArgs(msg,10,1)}
        
        
        for i,v in ipairs(args) do
            if self:is_itemlink(v) then self:add_items_to_session(v) end
        end
        
    end,

    ["help"]=function(...)
        purps:send_user_message("help_message")
        
    end,
    
    ["metatable"]={__index=function(self,key) return self["help"] end},
}
setmetatable(chat_commands,chat_commands.metatable)


function purps:chat_command_handler(msg)
    local key=self:GetArgs(msg,1)
    if not key then chat_commands["help"]() 
    else chat_commands[key](self,msg) end
end
purps:RegisterChatCommand("purps","chat_command_handler")

function purps:RefreshConfig()
    ReloadUI()
end

function purps:OnEnable()
    
end







