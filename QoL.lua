local pants=PantsAddon
local unpack,ipairs,pairs=unpack,ipairs,pairs


pants.qol_event_frame=CreateFrame('Frame',nil,UIParent)
pants.items_recently_looted={}
pants.items_tag_pending={}
local ef=pants.qol_event_frame

local events={'ENCOUNTER_LOOT_RECEIVED','ENCOUNTER_START','BAG_UPDATE_DELAYED'}
for k,v in pairs(events) do ef:RegisterEvent(v) end
function ef:event_handler(event,...)

    if event=='ENCOUNTER_LOOT_RECEIVED' then
        local itemLink,_,name=select(3,...)
        if not UnitIsUnit(name,'player') then return end
        local _,_,rarity=GetItemInfo(itemLink)
        if rarity<3 then return end
        pants.items_tag_pending[#pants.items_tag_pending+1]=itemLink
    end

    if event=='BAG_UPDATE_DELAYED' then
        if not pants.active_session then return end

        pants:update_bag_items()
        for i,v in ipairs(pants.items_tag_pending) do
            if pants:has_tradable_version(v) then
                pants.items_recently_looted[#pants.items_recently_looted+1]=v
                pants:send_item_looted(v)
            else
            end
        end
        wipe(pants.items_tag_pending)

        pants:qol_generate_update_table(false)
    end


    if event=='ENCOUNTER_START' then
        wipe(pants.items_recently_looted)
        wipe(pants.pending_looted_items)
    end
end
ef:SetScript('OnEvent',ef.event_handler)
ef:SetPoint('CENTER')

pants.tooltip_testing_frame=CreateFrame('GameTooltip','PantsTooltipHelper',UIParent,'GameTooltipTemplate')
local ttf=pants.tooltip_testing_frame
ttf:SetPoint('CENTER',UIParent,'CENTER')
ttf:SetSize(100,100)

function pants:update_bag_items()
    local titems={}
    for container=0, _G.NUM_BAG_SLOTS do
        for slot=1, GetContainerNumSlots(container) or 0 do
            ttf:SetOwner(UIParent,'ANCHOR_NONE')
            ttf:SetBagItem(container,slot)
            local tradable=pants:tooltip_is_tradable(ttf:GetRegions())
            if tradable then titems[#titems+1]={container,slot,GetContainerItemLink(container,slot)} end
        end
    end
    pants.tradable_items=titems
end


local abs=abs
function pants:tooltip_is_tradable(...)
    local n=select('#',...)
    local s=''
    for i=1,n do 
        local reg=select(i,...)
        if reg.GetText then 
            local gt=reg:GetText()
            if gt then 
                local r,g,b=reg:GetTextColor()
                if (r<.001) and (abs(g-.8)<.001) and (abs(b-1)<.001) and gt:find('%d+') then return true end 
                            --checks if theres this blue tradable text, including a number (to avoid the 'Legacy Item' thing)
                            --this should bypass language problems
            end
        end
    end
    return false
end

pants.qol_full_data={
}

function pants:qol_generate_update_table(skip)
    wipe(pants.qol_full_data)
    local d=pants.qol_full_data

    if not skip then pants:update_bag_items() end

    if self:are_you_ML() then 
        self:qol_add_item_trades(d) 
        self:qol_add_looted_pending_items(d)
    else self:qol_add_looted_items(d) end
    self.interface:refresh_qol_list()

    if #self.qol_full_data>0 then self.interface.qol_frame:Show() else self.interface.qol_frame:Hide() end
end

function pants:qol_perform_quick_action(frame)
    if not frame.data then return end
    local mode,name,itemLink=frame.data.mode,frame.data.name,frame.data.itemLink
    if (not mode) or (not name) or (not itemLink) then return end

    pants:update_bag_items()

    if mode=='assign' or mode=='trade_ML' then
        local bag,id=false,false
        for k,v in pairs(pants.tradable_items) do 
            if v[3]==itemLink then bag,id=v[1],v[2] end
        end
        if not bag then self:send_user_message('item_not_in_bags',itemLink); return end

        name=Ambiguate(name,'none')
        if self.para.quick_follow then FollowUnit(name) end

        --initiate trade
        if not TradeFrame:IsShown() then
            InitiateTrade(name)
            return
        end

        --put item in there
        if not GetTradePlayerItemLink(1) then
            PickupContainerItem(bag,id)
            ClickTradeButton(1)
            return
        end


        AcceptTrade()

    end --end of 'assign' mode

    if mode == 'to_add' then
        if not self.currently_in_council then return end
        local index=frame.data.index
        if not index then return end


        self:add_items_to_session(itemLink)
        if self.active_session then 
            local item_info=self.current_session[#self.current_session].item_info
            self.current_session[#self.current_session].responses=self:generate_group_member_list(item_info)
            self:send_new_session_item(#self.current_session)
        end

        local f=PantsAddon.interface.session_scroll_panel
        if not f:IsShown() then f:Show() end

        table.remove(pants.pending_looted_items,index)
        pants:qol_generate_update_table()

    end
end

function pants:qol_add_item_trades(tbl)
    if not tbl then return end
    if not self.current_session then return end

    for i=1,#self.current_session do
        local name,class=self:item_assigned_player(i)
        if name and self:has_tradable_version(self.current_session[i].item_info.itemLink) and (not UnitIsUnit(Ambiguate(name,'none'),'player')) then 
            tbl[#tbl+1]={name=name,class=class,mode='assign',itemLink=self.current_session[i].item_info.itemLink}
        end
    end
end

function pants:has_tradable_version(itemLink)
    if (not itemLink) or (not self.tradable_items) then return false end
    for k,v in pairs(self.tradable_items) do 
        if itemLink==v[3] then return true end
    end
    return false
end

function pants:qol_add_looted_items(tbl)
    if not tbl then return end
    local ML_name,ML_class=self:find_ML()
    if not ML_name then return end

    for k,v in ipairs(self.items_recently_looted) do
        if self:has_tradable_version(v) then
            tbl[#tbl+1]={name=ML_name,class=ML_class,mode='trade_ML',itemLink=v}
        end
    end
end

function pants:remove_recent_items_by_link(itemLink)
    if not itemLink then return end
    for i,v in ipairs(self.items_recently_looted) do
        if v==itemLink then table.remove(self.items_recently_looted,i); return end
    end
end

function pants:qol_add_looted_pending_items(tbl)
    if not tbl then return end

    for k,v in ipairs(self.pending_looted_items) do
        local class,CLASS
        if UnitExists(v[2]) then class,CLASS=UnitClass(v[2]) end
        tbl[#tbl+1]={name=v[2],class=class or 'PRIEST',mode='to_add',itemLink=v[1],index=k}
    end
end

--looted items
pants.pending_looted_items={
}
function pants:add_to_looted_items(item,sender)
    if type(item)=='table' then
        for k,v in pairs(item) do self:add_to_looted_items(v,sender) end
        return
    end

    local pli=self.pending_looted_items
    pli[#pli+1]={item,pants:convert_to_full_name(sender)}

end