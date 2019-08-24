local purps=PurpsAddon
local unpack,ipairs,pairs=unpack,ipairs,pairs

purps.current_session={}

--default paras
--those will be overwritten by whoever the leader is
--information will be sent as session is started
purps.current_session_paras={
    response_names={[1]="Need",[2]="Offspec",[3]="M+",[4]="Transmog",[5]="Higher ilvl for trading",[6]="Pass",[100]="Autopass"},
    response_colours={[1]={.2,1,.2,1},[2]={.2,.2,1,1},[3]={1,0,0,1},[4]={.7,.2,.7,1},[5]={.5,.5,.5,1},[6]={.5,.5,.5,1},[100]={.3,.3,.3,1}},
}

local session=purps.current_session
function purps:add_items_to_session(msg)
    local n=#session+1
    session[n]={}
    local page=session[n]
    
    page.item_info=self:itemlink_info(msg)
    
    self.interface:apply_session_to_scroll()
    
end

local session_order,wipe={},table.wipe
function purps:get_session_order()
    local session=self.current_session
    if not session then return end
    
    wipe(session_order)
    --TBA PROPER ORDER BASED ON PARAS
    for i=1,#session do
        session_order[i]=i
    end
   
    return session_order
end


purps.session_test_data={
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


function purps:raid_table_test_data()
    local tbl=purps.interface.raid_table
    tbl:SetData(self.session_test_data)
end


function purps:generate_group_member_list()
    if not IsInGroup() then return {} end
    local a={}
    local list=self:get_units_list()
    for i=1,#list do 
        local unit=list[i]
        local name=purps:unit_full_name(unit)
        local _,class=UnitClass(unit)
        if not name then break end
        a[#a+1]={self:convert_to_full_name(name),0,0,nil,nil,"",class=class}  --name,response_id,ilvl,item1,item2,note
    end
    return a
end

function purps:start_session()
    local tbl=self.current_session
    if (not tbl) or (#tbl==0) then 
        self:send_user_message("add_items_none_found")
        return
    end
        
    for i=1,#tbl do 
        local t=tbl[i]
        t.responses=self:generate_group_member_list()
    end
    purps.active_session=true
    purps:send_current_session()
end

function purps:name_index_in_session(name,session_index)
    if (not name) or (not session_index) then return nil end
    if (not self.current_session[session_index]) or (not self.current_session[session_index].responses) then return nil end
    local session=self.current_session[session_index].responses
    name=self:convert_to_full_name(name)
    
    
    for i=1,#session do
        if session[i][1]==name then return i end
    end
    return nil
end

function purps:apply_response_update(sender,response)
    if not response or not (type(response)=="table") or (not sender) then return end
    local item_index=response.item_index 
    if (not item_index) or (not self.current_session) or (not self.current_session[item_index]) then return end 
    
    sender=self:convert_to_full_name(sender)
    local sender_id=self:name_index_in_session(sender,item_index)
    if not sender_id then return end 
    
    response.item_index=nil
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
function purps:get_equipped_items(session_index)
    if (not session_index) or (not self.current_session[session_index]) then return end
    local loc=self.current_session[session_index].item_info.itemEquipLoc
    
    local links=self:get_item_link_slot(loc)
    if not links then return end 
    return links
end










