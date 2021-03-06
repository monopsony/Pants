local pants=PantsAddon
local unpack,ipairs,pairs=unpack,ipairs,pairs

pants.current_session={}

--default paras
--those will be overwritten by whoever started the session
--information will be sent as session is started
pants.current_session_paras={
    response_names={[1]="Need",[2]="Offspec",[3]="M+",[4]="Transmog",[5]="Higher ilvl for trading",[6]="Pass",[100]="Autopass"},
    response_colours={[1]={.2,1,.2,1},[2]={.2,.2,1,1},[3]={1,0,0,1},[4]={.7,.2,.7,1},[5]={.5,.5,.5,1},[6]={.5,.5,.5,1},[100]={.3,.3,.3,1}},
}


function pants:add_items_to_session(msg)
    local session=pants.current_session
    local n=#session+1
    session[n]={item_index=n}
    local page=session[n]    
    page.item_info=self:itemlink_info(msg)

    if self.active_session then 

    end
    self.interface:apply_session_to_scroll()

end

local session_order,wipe={},table.wipe
local session_help_table = {} -- used when stack_duplicates is true, saves 
                              -- which itemlinks were already seen

function pants:get_session_order()
    local session=self.current_session
    if not session then return {} end
    
    wipe(session_order)

    --TBA PROPER ORDER BASED ON PARAS
    if self.para.stack_duplicates 
        and session[1] and session[1].item_info
    then
        wipe(session_help_table)
        for i,v in ipairs(session) do
            local link = ''
            if v.item_info then link = v.item_info.itemLink end
            if session_help_table[link] then
                v.is_duplicate = true
                local ori=session_help_table[link]
                ori.duplicates[#ori.duplicates+1] = v
                v.ori = ori
            else 
                v.is_duplicate = false
                session_help_table[link] = v
                session_order[#session_order+1] = i
                v.duplicates = {}
            end
        end

    else --else of if stack_duplicates
        for i=1,#session do
            session_order[i]=i
        end
    end --end of if stack_duplicates
   
    return session_order
end

pants.session_test_data={
    {"Bob",1,320,nil},
    {"Patrick",2,320,nil},
    {"John",1,345,nil},
    {"Lucie",3,676,nil},
    {"Sarah",5,234,nil},
    {"Gavin",1,576,nil},
    {"Sean",100,75,nil},
    {"Tamara",100,123,nil},
    {"Legolas",6,75,nil},
    {"Hazzikostas",6,752,nil},
    {"Midget",6,963,nil},
    {"Brown",1,741,nil},
    {"Hamilton",4,852,nil},
    {"Arthas",4,735,nil},
    {"Légôlàs",5,432,nil},
    {"Mario",2,690,nil},
}

function pants:raid_table_test_data()
    local tbl=pants.interface.raid_table
    tbl:SetData(self.session_test_data)
end

function pants:generate_group_member_list(item_info)
    local a={}
    local list=self:get_units_list()
    itemSubType=item_info.itemSubType
    for i=1,#list do 
        local unit=list[i]
        local name=pants:unit_full_name(unit)
        local _,class=UnitClass(unit)
        if not name then break end
        if not self.item_itemSubType_class_filters[itemSubType][class] then
            a[#a+1]={self:convert_to_full_name(name),"",0,nil,nil,"",class=class,response_id=0,win=false}  --name,response_id,ilvl,item1,item2,note
        end
    end
    return a
end

function pants:start_session()
    if (not self:in_council()) then pants:send_user_message('not_in_council','start sessions'); return end
    local tbl=self.current_session
    if (not tbl) or (#tbl==0) then 
        self:send_user_message("add_items_none_found")
        return
    end
        
    for i=1,#tbl do 
        local t=tbl[i]
        t.responses=self:generate_group_member_list(t.item_info)
    end
    pants.active_session=true
    pants.current_session_paras=pants:table_deep_copy(pants.para.session_paras)
    pants:send_current_session()
    pants:apply_session_on_update()
end

function pants:name_index_in_session(name,session_index)
    if (not name) or (not session_index) then return nil end
    if (not self.current_session[session_index]) or (not self.current_session[session_index].responses) then return nil end
    local session=self.current_session[session_index].responses
    name=self:convert_to_full_name(name)
    for i=1,#session do
        if session[i][1]==name then return i end
    end
    return nil
end

function pants:apply_response_update(sender,response)
    if (not response) or not (type(response)=="table") or (not sender) then return end

    -- if not sender then 
    --     if response.multiple=true then 
    --         for k,v in pairs(response.responses) do self:apply_response_update(k,v) end
    --     else return end
    -- end
    local item_index=response.item_index 
    if (not item_index) or (not self.current_session) or (not self.current_session[item_index]) then return end 
    
    sender=self:convert_to_full_name(sender)
    local sender_id=(response.row_index) or self:name_index_in_session(sender,item_index)
    if not sender_id then return end 
    
    response.item_index=nil
    response.row_index=nil
    local session = self.current_session 
    local page = session[item_index]
    local current_response=page.responses[sender_id]
        
    for k,v in pairs(response) do 
        current_response[k]=v
    end
    
    -- apply the response to all other duplicates
    -- note: not using .duplicates as this is needed
    -- even if the interface is inactive
    -- response.
    local itemLink = ''
    if page and page.item_info and page.item_info.itemLink then
        itemLink = page.item_info.itemLink 
    end
    for i,v in ipairs(session) do
        local link = v.item_info.itemLink
        if link == itemLink then 
            local current_response = v.responses[sender_id]
            for k,v in pairs(response) do 
                current_response[k]=v
            end
        end
    end

    --update interface if item is selected
    if self.interface.currently_selected_item==item_index then
        self.interface:refresh_sort_raid_table()
    end
    
    if sender==self.full_name then self.interface:check_items_status() end
end

local help_table_items={}
function pants:get_equipped_items(session_index)
    if (not session_index) or (not self.current_session[session_index]) then return end
    local loc=self.current_session[session_index].item_info.itemEquipLoc
    local links=self:get_item_link_slot(loc)
    if not links then return end 
    return links
end

local wipe_keys={
    'current_session',
    'simc_strings',
    'items_recently_looted',
    'pending_looted_items',
    'equipped_item_index_sent'
}

function pants:apply_end_session()
    if self.active_session and self.para.session_archive then 
        pants:archive_current_session() 
    end
    self.active_session=false
    self:apply_session_on_update()

    --wipe tables
    for i,v in ipairs(wipe_keys) do
        if self[v] then wipe(self[v]) end
    end

    pants.interface:apply_session_to_scroll()
    pants.interface:apply_selected_item()
    self.interface.session_vote_frame.note_eb:SetText('')
    self.interface.session_scroll_panel:Hide()
    self.interface.qol_frame:Hide()
end

function pants:apply_rl_paras()
    self:apply_session_on_update()
    local para=self.current_rl_paras
    if not para then return end 
    local in_council=false

    for k,v in pairs(para.council) do
        if v==pants.full_name then in_council=true; break end
    end

    pants.currently_in_council=in_council
end

function pants:apply_item_assignment(data)
    if (not data) or (not data.name) or (not data.item_index) then return end 
    local item_index,name=data.item_index,data.name
    if (not item_index) or (not name) or (not self.current_session) or (not self.current_session[item_index]) then return end 
    local index=pants:name_index_in_session(name,item_index)
    if not index then return end

    local response=self.current_session[item_index].responses[index][2]
    if self:are_you_ML() and self.para.announce_winner then
        local s=('Item %s was assigned to %s for %s'):format( self.current_session[item_index].item_info.itemLink , Ambiguate(name,'none'), response)
        SendChatMessage(s,(IsInRaid and 'RAID') or 'PARTY')
    end

    for k,v in pairs(self.current_session[item_index].responses) do 
        if k==index then v.win=true else v.win=false end
    end

    --makes sure that you dont get prompted to trade items that you looted then got assigned
    self:remove_recent_items_by_link(self.current_session[item_index].item_info.itemLink) 

    --update interface if item is selected
    if self.interface.currently_selected_item==item_index then
        self.interface:refresh_sort_raid_table()
    end
    
    self.interface:check_items_status()
    self.interface:update_assigned_text()
    self:qol_generate_update_table()
end

function pants:confirm_pending_item_assignment()
    if not self.pending_item_assignment then return end
    local item_index,name=unpack(self.pending_item_assignment)
    self:send_item_assignment(item_index,name)
    wipe(self.pending_item_assignment)
end

function pants:item_assigned_player(item_index)
    if (not item_index) 
    or (not self.current_session) 
    or (not self.current_session[item_index])
    or (not self.current_session[item_index].responses) then return false end 
    for k,v in pairs(self.current_session[item_index].responses) do if v.win then return v[1],v.class end end
    return false
end

function pants:find_ML()
    local para=self.current_rl_paras
    if (not para) or (not para.council) then return end

    for k,v in pairs(para.council) do 
        if (type(v)=='string') and (v~='') then 
            local name=Ambiguate(v,'none')

            if UnitInRaid(name) then
                local _,class=UnitClass(name)
                return name,class
            end
        end
    end
    return false
end

function pants:in_council()
    if IsInRaid() then return self.currently_in_council else return true end
end

function pants:apply_session_on_update()
    local bool = self:are_you_ML() and (self.active_session) and (self.current_session) and (not self.current_session.archived)
    if bool then 
        pants.session_on_update_frame:SetScript('OnUpdate',pants.session_on_update_frame.onUpdateFunc)
        pants.session_on_update_frame.eT=10
    else
        self.session_on_update_frame:SetScript("OnUpdate",nil)
    end
end

function pants:session_id()
    if (not self.active_session) or (not self.current_session) then return 'None' end
    return ('%s,%s'):format(self.current_session.id0 or 'None',#self.current_session or '0')
end

pants.session_on_update_frame=CreateFrame('Frame','PantsSessionOnUpdateFrame',UIParent)
pants.session_on_update_frame.eT=0
local throttle=15
function pants.session_on_update_frame:onUpdateFunc(elapsed)
    self.eT=self.eT+elapsed
    if self.eT<throttle then return end
    self.eT=0
    --send session version ping if active session
    if (pants.active_session) and (pants.current_session) and not (pants.current_session.archived) then 
        local id = pants:session_id()
        pants:send_raid_comm('pantsSIDCheck',id)
    end

end
