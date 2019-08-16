PurpsAddon=LibStub("AceAddon-3.0"):NewAddon("PurpsAddon","AceConsole-3.0","AceComm-3.0","AceEvent-3.0","AceSerializer-3.0")
local purps=PurpsAddon
local LSM=LibStub:GetLibrary("LibSharedMedia-3.0")
local unpack,ipairs,pairs,wipe=unpack,ipairs,pairs,table.wipe

local defaults={
    profile={
        scroll_item_size={40,40},
        scroll_item_default_icon=136207,
        tertiary_stats_delimiter="//",
        scroll_item_spacing=10,
        scroll_frame_display_count=4,
        scroll_frame_width=65,
        scroll_frame_height=200,
        scroll_frame_pos={500,500},
        main_frame_width=200,
        raid_table_y_inset=175,
        raid_table_x_inset=10,
        raid_table_bottom_inset=40,
        raid_table_row_height=30,
        preview_icon_size={75,75},
        voting_frame_width=200,
        min_resize_height=100,
        max_resize_height=1500,
    },-- end of profile
}--end of defaults


function purps:OnInitialize()
    
    self.db=LibStub("AceDB-3.0"):New("PurpsAddonDB",defaults,true)  --true sets the default profile to a profile called "Default"
                                                                 --see https://www.wowace.com/projects/ace3/pages/api/ace-db-3-0
    self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
    
    self.para=self.db.profile
    
    self.interface:populate_scroll_child()
    self.interface:update_scroll_parameters(true)
    self.interface:update_main_frame_parameters(true)
    
    
end


local chat_commands={
    ["add"]=function(self,msg)
    
        if not purps:is_itemlink(msg) then purps:send_user_message("add_items_none_found") end
        local msg=purps:separate_itemlinks(msg)
        local args={self:GetArgs(msg,10,1)}
   
        for i,v in ipairs(args) do
            if self:is_itemlink(v) then self:add_items_to_session(v) end
        end
        
    end,

    ["help"]=function(...)
        purps:send_user_message("help_message")
        
    end,
    
    ["test_table"]=function(...)
        PurpsAddon:raid_table_test_data()
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







