local purps=PurpsAddon

local afterDo,waiting_time=C_Timer.After,1
local registered_comms={
    ["PurpsPing"]=function(data,channel,sender)
        if UnitIsUnit("player",sender) then sender="You" end
        purps:send_user_message("raid_ping",sender,channel)
    end,
    
    ["PurpsSPara"]=function(data,_,sender)
        local tbl=purps:decode_decompress_deserialize(data)
        purps.current_session_paras=tbl
        purps.interface:refresh_sort_raid_table()
        purps.interface:update_response_dd()
    end,
    
    ["PurpsSCurr"]=function(data,_,sender)
        local tbl=purps:decode_decompress_deserialize(data)
        purps.current_session=tbl
        purps.active_session=true
        purps.interface:apply_session_to_scroll()
        
        for i=1,#purps.current_session do
            local purps=purps
            afterDo(waiting_time,function() purps:send_equipped_items(i) end)
        end
        
    end,
    
    ["PurpsSAdd"]=function(data,_,sender)
        if not UnitIsUnit("player",sender) then 
            local tbl=purps:decode_decompress_deserialize(data)
            purps.current_session[#purps.current_session+1]=tbl
        end
        purps.interface:apply_session_to_scroll()
        
        local purps=purps
        afterDo(waiting_time,function() purps:send_equipped_items(#purps.current_session) end)
        
    end,

    ["PurpsSResUpd"]=function(data,_,sender)
        local tbl=purps:decode_decompress_deserialize(data)
        if not tbl then return end
        purps:apply_response_update(sender,tbl)
    end,
    
    ["PurpsSEnd"]=function(data,_,sender)
        purps:apply_end_session()
    end,

    ["PurpsSimc"]=function(data,_,sender)
        local s=purps:decode_decompress(data)
        purps:save_simc_string(sender,s)
        purps.interface:refresh_sort_raid_table()
    end,
}

function purps:send_raid_comm(prefix,data)
    if (not IsInGroup()) then return end
    local channel=(IsInRaid() and "RAID") or "PARTY"
    self:SendCommMessage(prefix,data or "N/A",channel)
end

function purps:OnCommReceived(prefix,data,channel,sender)
    registered_comms[prefix](data,channel,sender)
end

for k,v in pairs(registered_comms) do 
    purps:RegisterComm(k)
end

function purps:send_session_paras()
    local para=self.para.session_paras
    local s=self:serialize_compress_encode(para)
    self:send_raid_comm("PurpsSPara",s)
end

function purps:send_current_session()
    local session=self.current_session
    local s=self:serialize_compress_encode(session)
    self:send_session_paras()
    self:send_raid_comm("PurpsSCurr",s)
end


function purps:send_new_session_item(i)
    local session=self.current_session
    if (not i) or (#session<i) then return end 
    session['item_session_id']=i
    local s=self:serialize_compress_encode(session[i])
    self:send_raid_comm("PurpsSAdd",s)
end


function purps:send_response_update(response)
    if not response or not (type(response)=="table") then return end
    local s=self:serialize_compress_encode(response)
    self:send_raid_comm("PurpsSResUpd",s)
end

local ipairs=ipairs
function purps:send_equipped_items(session_index)
    if (not session_index) or (not self.current_session[session_index]) then return end
    local items=self:get_equipped_items(session_index)
    local _,ilvl=GetAverageItemLevel()
    local response={[3]=ilvl,item_index=session_index}

    if not items then return self:send_response_update(response) end
    response.equipped=items
    self:send_response_update(response)
end

function purps:send_end_session()
    self:send_raid_comm("PurpsSEnd",nil)
end











