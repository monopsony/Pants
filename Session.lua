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
    for i=1,40 do 
        local name,_,_,_,class=GetRaidRosterInfo(i)
        if not name then break end
        a[#a+1]={self:convert_to_full_name(name),0,0,"",nil,nil,class=class}  --name,response_id,ilvl,note,item1,item2
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

    purps:send_current_session()
end