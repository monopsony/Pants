local pants=PantsAddon
local unpack,ipairs,pairs=unpack,ipairs,pairs


pants.qol_event_frame=CreateFrame('Frame',nil,UIParent)
local ef=pants.qol_event_frame
local events={'ENCOUNTER_LOOT_RECEIVED','PLAYER_EQUIPMENT_CHANGED'}
for k,v in pairs(events) do ef:RegisterEvent(v) end
function ef:event_handler(event,...)
    pants:update_bag_items()
end
ef:SetScript('OnEvent',ef.event_handler)
ef:SetPoint('CENTER')

pants.tooltip_testing_frame=CreateFrame('GameTooltip','PantsTooltipHelper',UIParent,'GameTooltipTemplate')
local ttf=pants.tooltip_testing_frame
ttf:SetPoint('CENTER',UIParent,'CENTER')
ttf:SetSize(100,100)

for k,v in pairs(ttf) do print(k,v) end

function pants:update_bag_items()
    local titems={}
    for container=0, _G.NUM_BAG_SLOTS do
        for slot=1, GetContainerNumSlots(container) or 0 do
            ttf:SetOwner(UIParent,'ANCHOR_NONE')
            ttf:SetBagItem(container,slot)
            local tradable=pants:tooltip_is_tradable(ttf:GetRegions())
            if tradable then titems[#titems]={container,slot,GetContainerItemLink(container,slot)} end
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

function pants:qol_generate_update_table()
    wipe(pants.qol_full_data)
    local d=pants.qol_full_data

    if self:are_you_ML() then self:qol_add_item_trades(d) end
    self.interface:refresh_qol_list()
end

function pants:qol_add_item_trades(tbl)
    if not tbl then return end
    for i=1,#self.current_session do
        local name,class=self:item_assigned_player(i)
        if name then 
            tbl[#tbl+1]={name=name,class=class,mode='assign',itemLink=self.current_session[i].item_info.itemLink}
        end
    end
end