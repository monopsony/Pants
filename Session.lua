local purps=PurpsAddon
local unpack,ipairs,pairs=unpack,ipairs,pairs

purps.current_session={}

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


