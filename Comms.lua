local purps=PurpsAddon

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
    end,
    
    ["PurpsSResUpd"]=function(data,_,sender)
        local tbl=purps:decode_decompress_deserialize(data)
        if not tbl then return end
        purps:apply_response_update(sender,tbl)
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

function purps:send_response_update(response)
    if not response or not (type(response)=="table") then return end
    local s=self:serialize_compress_encode(response)
    self:send_raid_comm("PurpsSResUpd",s)
end