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
    end,
    
    ["PurpsSCurr"]=function(data,_,sender)
        local tbl=purps:decode_decompress_deserialize(data)
        purps.current_session=tbl
        purps.interface:apply_session_to_scroll()
    end,
}



function purps:send_raid_comm(prefix,data)
    if (not IsInGroup()) then return end
    local channel=(IsInRaid() and "RAID") or "PARTY"
    self:SendCommMessage(prefix,data,channel)
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
    self:send_raid_comm("PurpsSCurr",s)
end