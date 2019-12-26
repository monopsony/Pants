local pants=PantsAddon
local unpack,ipairs,pairs=unpack,ipairs,pairs

pants.current_session={}

--default paras
--those will be overwritten by whoever the leader is
--information will be sent as session is started
pants.current_session_paras={
    response_names={[1]="Need",[2]="Offspec",[3]="M+",[4]="Transmog",[5]="Higher ilvl for trading",[6]="Pass",[100]="Autopass"},
    response_colours={[1]={.2,1,.2,1},[2]={.2,.2,1,1},[3]={1,0,0,1},[4]={.7,.2,.7,1},[5]={.5,.5,.5,1},[6]={.5,.5,.5,1},[100]={.3,.3,.3,1}},
}


function pants:add_items_to_session(msg)
    local session=pants.current_session
    local n=#session+1
    session[n]={}
    local page=session[n]    
    page.item_info=self:itemlink_info(msg)
    
    if self.active_session then 

    end

    self.interface:apply_session_to_scroll()
    
end

local session_order,wipe={},table.wipe
function pants:get_session_order()
    local session=self.current_session
    if not session then return {} end
    
    wipe(session_order)
    --TBA PROPER ORDER BASED ON PARAS
    for i=1,#session do
        session_order[i]=i
    end
   
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
    if not IsInGroup() then return {} end
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
    if not self.currently_in_council then pants:send_user_message('not_in_council','start sessions'); return end
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
    pants:send_current_session()
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
    local current_response=self.current_session[item_index].responses[sender_id]
        
    for k,v in pairs(response) do 
        current_response[k]=v
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

function pants:apply_end_session()
    self.active_session=false
    wipe(self.current_session)
    pants.interface:apply_session_to_scroll()
    pants.interface:apply_selected_item()
    self.interface.session_scroll_panel:Hide()
end

function pants:apply_rl_paras()
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

    for k,v in pairs(self.current_session[item_index].responses) do 
        if k==index then v.win=true else v.win=false end
    end

    --update interface if item is selected
    if self.interface.currently_selected_item==item_index then
        self.interface:refresh_sort_raid_table()
    end
    
    self.interface:check_items_status()
    self.interface:update_assigned_text()
end

function pants:item_assigned_player(item_index)
    if (not item_index) or (not self.current_session) or (not self.current_session[item_index]) then return false end 
    for k,v in pairs(self.current_session[item_index].responses) do if v.win then return v[1],v.class end end
    return false
end