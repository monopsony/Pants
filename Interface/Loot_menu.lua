local purps=PurpsAddon
purps.interface={}
local interface=purps.interface
local ui=LibStub('StdUi')

local function update_scroll_XY_paras()
    local panel=purps.interface.session_scroll_panel
    local x,y=panel:GetLeft(),panel:GetTop()
    purps.para.scroll_frame_pos[1]=x
    purps.para.scroll_frame_pos[2]=y
            
end

local floor=floor
local function raid_table_adapt_rows_to_height()
    local frame=interface.session_main_frame
    local tbl=frame.raid_table
    local para=purps.para
    
    local h=tbl:GetHeight()
    
    if h<120 then tbl:Hide() else tbl:Show() end
    
    local rh=para.raid_table_row_height
    local n=floor(h/rh)
    
    tbl:SetDisplayRows(0,0)
    tbl:SetDisplayRows(n,rh)
    
end

--create loot menu main frame
do
    --interface.session_main_frame=ui:PanelWithTitle(UIParent,200,200,"MAIN FRAME")
    interface.session_main_frame=ui:Panel(UIParent,200,200)
    local frame=interface.session_main_frame
    --frame:SetPoint("CENTER")
    
    frame:Show()
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetClipsChildren(true)


    frame.sizer_frame=ui:Frame(frame,10,10)
    local sizer=frame.sizer_frame
    sizer:SetPoint("BOTTOMRIGHT")
    
    frame:SetResizable(true)
    sizer:EnableMouse(true)
    sizer:RegisterForDrag("LeftButton")
    
    --preview icon
    frame.preview_icon=ui:Frame(frame,75,75)
    local icon=frame.preview_icon
    icon:SetPoint("TOPLEFT",frame,"TOPLEFT",10,-10)
    
    
    local function set_icon_tooltip(self)
    
        local item_index=purps.interface.currently_selected_item or nil
        if not item_index then return "N/A" end 
                
        local page=purps.current_session[item_index]
        local itemLink=page.item_info.itemLink    
        
        self:SetHyperlink(itemLink)
    end
    
    icon.tooltip=ui:Tooltip(icon,set_icon_tooltip,"PurpsAddon_main_frame_icon_tooltip","TOPRIGHT",true)

    
    icon.texture=ui:Texture(icon,75,75)
    local txt=icon.texture
    txt:SetAllPoints()
    
    
    --info texts
    frame.text_item_name=ui:FontString(frame,"")
    frame.text_item_name:SetPoint("TOPLEFT",icon,"TOPRIGHT",10,0)

    frame.text_item_info=ui:FontString(frame,"")
    frame.text_item_info:SetPoint("TOPLEFT",frame.text_item_name,"BOTTOMLEFT",0,-5)

    frame.text_item_level=ui:FontString(frame,"")
    frame.text_item_level:SetPoint("TOPLEFT",frame.text_item_info,"BOTTOMLEFT",0,-5)

    frame.text_item_extra=ui:FontString(frame,"")
    frame.text_item_extra:SetPoint("TOPLEFT",frame.text_item_level,"BOTTOMLEFT",0,-5)
    
end


--create loot menu vote frame
do
    --interface.session_main_frame=ui:PanelWithTitle(UIParent,200,200,"MAIN FRAME")
    interface.session_vote_frame=ui:Panel(UIParent,200,200)
    local frame=interface.session_vote_frame
    --frame:SetPoint("CENTER")
    
    frame:Show()
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetClipsChildren(true)
    frame:SetSize(300,300)

    frame.sizer_frame=ui:Frame(frame,10,10)
    local sizer=frame.sizer_frame
    sizer:SetPoint("BOTTOMLEFT")
    
    frame:SetResizable(true)
    sizer:EnableMouse(true)
    sizer:RegisterForDrag("LeftButton")
    
    --response dd
    frame.response_dd=ui:Dropdown(frame,100,25,{{text="N/A",value=1}},nil)
    local dd=frame.response_dd
    dd:SetPlaceholder("SELECT")
    dd:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-10,-10)
    --dd:SetOptions({{text="TEST",value=1}})
    --dd:SetValue(1)
    
    dd.text=ui:FontString(dd,"Response:")
    dd:SetWidth(150)
    dd.text:SetPoint("RIGHT",dd,"LEFT",-10,0)
    
    --note edit box
    frame.note_eb=ui:MultiLineBox(frame,200,200,"")
    local eb=frame.note_eb.panel
    eb:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-10,-55)
    eb:SetPoint("BOTTOMLEFT",frame,"BOTTOMLEFT",10,55)
    
    eb.scrollChild:SetMaxLetters(150)
    
end

local RAID_CLASS_COLORS=RAID_CLASS_COLORS 
local table_column_default={
    --Name
    {
        name="Name",
        width=105,
        align="LEFT",
        index=1,
        format=function(name)
            return purps:remove_realm(name)
        end,
        
        color=function(_,_,tbl)
            local class=tbl.class or "PRIEST"
            local color=RAID_CLASS_COLORS[class]
            return {r=color.r,g=color.g,b=color.b}
        end,
        sortable=false,
    }, 
    
    --Response
    {
        name="Response",
        width=175,
        align="LEFT",
        index=2,
        format=function(response_id)
            local s=purps.current_session_paras.response_names[response_id] or "N/A"
            return s
            --purps.current_session_paras
        end,
        color=function(_,_,tbl)
            local response_id=tbl[2]
            local r,g,b,a=unpack(purps.current_session_paras.response_colours[response_id] or {1,1,1,1})
            return {r=r,g=g,b=b,a=a or 1}
        end,
        --compareSort=function(self,rowA,rowB,sortBy)
        --    local a = self:GetRow(rowA)[2]
        --    local b = self:GetRow(rowB)[2]           
        --    local column=self.columns[sortBy]
        --    local direction=column.sort or column.defaultSort or 'asc'
        --    if direction:lower() == 'asc' then 
        --        return a>b
        --   else
        --        return a<b
        --    end
        --    
        --end
    },   
    
    --ilvl
    {
        name="iLvl",
        sortable=false,
        width=30,
        align="LEFT",
        index=3,
        format="text",
    }, 
    
    --other
    {
        name="Other",
        sortable=false,
        width=30,
        align="LEFT",
        index=4,
        format="icon",
        
    }, 
    
}



--create loot menu table
do
    local frame=interface.session_main_frame
    local tbl=ui:ScrollTable(frame,table_column_default,0,20)
    frame.raid_table=tbl
    interface.raid_table=tbl
    tbl:SetPoint("TOPLEFT",frame,"TOPLEFT",10,-150)
    tbl:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-10,-150)
    tbl:EnableSelection(true)
    
    tbl:SetPoint("BOTTOM",frame,"BOTTOM",0,20)
        
end

function interface:update_main_frame_parameters(initialize)
    local frame=interface.session_main_frame
    local icon=frame.preview_icon
    local para=purps.para
    local panel=interface.session_scroll_panel
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT",panel,"TOPRIGHT")
    frame:SetPoint("BOTTOMLEFT",panel,"BOTTOMRIGHT")
    frame:SetWidth(para.main_frame_width)
    
    frame:SetMinResize(100,para.min_resize_height)
    frame:SetMaxResize(2000,para.max_resize_height)
    
    icon:SetSize(unpack(para.preview_icon_size))
    if initialize then icon.texture:SetTexture(para.scroll_item_default_icon) end
    
    interface:udpate_raid_table_parameters()
end

function interface:update_vote_frame_parameters(initialize)
    local frame=interface.session_vote_frame
    local para=purps.para
    local panel=interface.session_scroll_panel
    frame:ClearAllPoints()
    frame:SetPoint("TOPRIGHT",panel,"TOPLEFT")
    frame:SetSize(para.vote_frame_width,para.vote_frame_height)
    
    frame:SetMinResize(100,para.min_resize_height)
    frame:SetMaxResize(2000,para.max_resize_height)
end

function interface:udpate_raid_table_parameters(initialize)
    local frame=interface.session_main_frame
    local tbl=frame.raid_table
    local para=purps.para
    tbl:SetPoint("TOPLEFT",frame,"TOPLEFT",para.raid_table_x_inset,-para.raid_table_y_inset)
    tbl:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-para.raid_table_x_inset,-para.raid_table_y_inset)
    tbl:SetPoint("BOTTOM",frame,"BOTTOM",0,para.raid_table_bottom_inset)
    
    --tbl:SetDisplayRows(0,para.raid_table_row_height)
    --tbl:SetDisplayRows(10,para.raid_table_row_height)
    
    raid_table_adapt_rows_to_height()
end

function interface:update_scroll_parameters(initialize)
    local para=purps.para
    local panel=self.session_scroll_panel
    panel:SetWidth(para.scroll_frame_width or 60)
    panel:SetHeight(para.scroll_frame_height or 200)
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT",UIparent,"BOTTOMLEFT",unpack(para.scroll_frame_pos))
    
    panel:SetMinResize(para.scroll_frame_width,para.min_resize_height)
    panel:SetMaxResize(para.scroll_frame_width,para.max_resize_height)
    
    local size=para.scroll_frame_width/3
    panel.expand_left_button:SetSize(size,size)
    panel.expand_right_button:SetSize(size,size)
end

local help_table,wipe,pairs={},table.wipe,pairs
function interface:update_response_dd()
    local para=purps.current_session_paras.response_names
    if not para then return end

    local dd=self.session_vote_frame.response_dd
    local help_table=help_table
    wipe(help_table)
    
    for k,v in pairs(para) do 
        if k>0 and k<100 then help_table[k]={value=k,text=v} end
    end
    
    dd:SetOptions(help_table)

end

local function scroll_child_OnClick(self)
    if not self.session_index then return end
    
    interface.currently_selected_item=self.session_index
    interface:apply_selected_item()
    
    interface:check_selected_item()
    
end

local function scroll_child_tooltip(self)

    local item_index=self.button.session_index or nil
    if not item_index then return end 

    local page=purps.current_session[item_index]
    if not page then return end

    local itemLink=page.item_info.itemLink    
    if not itemLink then return end

    self:SetHyperlink(itemLink)
    self:SetHyperlink(itemLink)
    
end

local function check_selected(self)
    local bool=false
    local ind1,ind2=self.session_index or nil,purps.interface.currently_selected_item or nil
    
    if (ind1) and (ind2) and (ind1==ind2) then bool=true end
    
    if bool and not self.is_selected then 
        self.selected_frame:Show()
        self.is_selected=true
    elseif (not bool) and (self.is_selected) then
        self.selected_frame:Hide()
        self.is_selected=false
    end
end

local set_status={
    ["none"]=function(self)
        self.status="none"
        self.status_frame:Hide()
    end,
    
    ["vote_pending"]=function(self)
        self.status="vote_pending"
        self.status_frame:Show()
        self.status_frame:SetSize(self:GetWidth()*.7,self:GetHeight()*.7)
        self.status_frame.texture:SetTexture("Interface\\OPTIONSFRAME\\UI-OptionsFrame-NewFeatureIcon.PNG")
        --self.status_frame.texture:SetTexture("Interface\\GossipFrame\\AvailableQuestIcon.PNG")
    end,
    
    ["metatable"]={__index=function(table,key) return table["none"] end}
}   
setmetatable(set_status,set_status.metatable)

local function check_status(self)
    local index=self.session_index
    if not index then return end
    local session,status,player_index=purps.current_session[index],"none",purps:name_index_in_session(purps.full_name,index)
    
    if (not session) or (not session.responses) then return end
        
    if (not player_index) or (not session.responses[player_index]) then
        status="not_in_list"
    elseif not session.responses[player_index].voted then
        status="vote_pending"
    else
    
    end
    
    if status~=self.status then 
        set_status[status](self)
    end
    
end

function interface:populate_scroll_child()

    local para=purps.para
    local scrollChild=self.session_scroll_panel.scrollChild
    if not scrollChild.items then scrollChild.items={} end
    
    for i=1,20 do
        if not scrollChild.items[i] then scrollChild.items[i]=ui:HighlightButton(scrollChild,50,50,nil) end
        local btn=scrollChild.items[i]
        btn:SetSize(unpack(para.scroll_item_size))
        btn.OnClick=scroll_child_OnClick
        if i==1 then 
            btn:SetPoint("TOP")
        else
            btn:SetPoint("TOP",scrollChild.items[i-1],"BOTTOM",0,-para.scroll_item_spacing)
        end
        btn:SetScript("OnClick",btn.OnClick)
        
        
        if not btn.item_texture then btn.item_texture=ui:Texture(btn,50,50) end
        btn.item_texture:SetAllPoints()
        btn.item_texture:SetTexture(para.scroll_item_default_icon)
        
    
        btn.tooltip=ui:Tooltip(btn,scroll_child_tooltip,"PurpsAddon_scroll_frame_icon_tooltip"..tostring(i),"TOPRIGHT",true)
        btn.tooltip.button=btn
        
        --'selected' frame
        btn.check_selected=check_selected
        btn.is_selected=false
        if not btn.selected_frame then btn.selected_frame=CreateFrame("Frame",nil,btn) end
        local sel=btn.selected_frame
        sel:SetAllPoints()
        sel.texture=sel:CreateTexture(nil,"OVERLAY")
        sel.texture:SetAllPoints()
        sel.texture:SetTexture("Interface\\ContainerFrame\\UI-Icon-QuestBorder.PNG")
        sel:Hide()
        
        --status frame
        btn.check_status=check_status
        if not btn.status_frame then btn.status_frame=CreateFrame("Frame",nil,btn) end
        local sel=btn.status_frame
        sel:SetPoint("CENTER")
        sel.texture=sel:CreateTexture(nil,"OVERLAY")
        sel.texture:SetAllPoints()
        --sel.texture:SetTexture("Interface\\Buttons\\UI-Quickslot-Depress.PNG")
        
    end
    
end

function interface:apply_session_to_scroll()
    local items=purps.current_session
    local scroll_items=interface.session_scroll_panel.scrollChild.items
    local order=purps:get_session_order()
    
    for i=1,#order do
        scroll_items[i]:Show()
        local j=order[i]
        scroll_items[i].session_index=j
        scroll_items[i].item_texture:SetTexture(items[j].item_info.itemIcon)
    end
    
    for i=#order+1,20 do
        scroll_items[i]:Hide()
    end
    
    self:check_selected_item()
    self:check_items_status()
end

function interface:table_reload_item()
    local tbl=self.raid_table
    
    local item_index=self.currently_selected_item or nil
    if not item_index then return end 
    
    if (not purps.current_session) or not (purps.current_session[item_index]) or not (purps.current_session[item_index].responses) then return end
        
    tbl:SetData(purps.current_session[item_index].responses)
    
end

local ITEM_QUALITY_COLORS=ITEM_QUALITY_COLORS
function interface:apply_selected_item()
    
    local item_index=self.currently_selected_item or nil
    if not item_index then return end 
    --TBA add error message
    
    local para=purps.para
    local page=purps.current_session[item_index]
    local item=page.item_info
    
    local frame=self.session_main_frame
    
    --apply icon 
    frame.preview_icon.texture:SetTexture(item.itemIcon or para.scroll_item_default_icon)

    --apply texts
    frame.text_item_name:SetText(  ("|c%s%s|r"):format( (item.itemRarity and ITEM_QUALITY_COLORS[item.itemRarity].color:GenerateHexColor()) or "ffffffff", item.itemName)  )
    frame.text_item_info:SetText(  ("%s, %s"):format(item.itemSubType or "",(item.itemEquipLoc and _G[item.itemEquipLoc] ) or "") )
    frame.text_item_level:SetText(  ("ilvl: %d"):format(item.itemLevel or 69))
    frame.text_item_extra:SetText(  ("|cff00ff00%s|r"):format(item.itemTertiary or "") )
    
    self:table_reload_item()
    
end

local function toggle_frame(frame)
    if (not frame) or (not frame.Show) then return end
    if frame:IsShown() then frame:Hide() else frame:Show() end
end

--create loot menu scroll frame item picker
do
    
    --interface.session_scroll_frame=ui:
    --local args=interface.session_scroll_frame
    local frame=interface.session_main_frame
    local panel,scrollFrame,scrollChild,scrollBar=ui:ScrollFrame(UIParent,60,200)
    frame:SetParent(panel) --changed my mind
    interface.session_scroll_panel=panel
    --panel.scrollChild / scrollFrame / scrollBar
    
    panel:SetPoint("TOPLEFT",UIparent,"BOTTOMLEFT",50,850)
    panel:SetMovable(true)
    panel:SetResizable(true)
    panel:EnableMouse(true)
    frame:SetPoint("TOPLEFT",panel,"TOPRIGHT")
    frame:SetPoint("BOTTOMLEFT",panel,"BOTTOMRIGHT")
   
    frame:SetScript("OnDragStart",function() 
        panel:StartMoving()
    end)
    frame:SetScript("OnDragStop",function() 
        panel:StopMovingOrSizing() 
        update_scroll_XY_paras()      
        purps.interface:update_scroll_parameters()
    end)  
    
    local sizer=frame.sizer_frame
    sizer:SetFrameLevel(frame:GetFrameLevel()+10)
    sizer:SetScript("OnDragStart",function()
        local x,y=unpack(purps.para.scroll_frame_pos)
        x=x+purps.para.scroll_frame_width
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",x,y)
        frame:SetSize(purps.para.main_frame_width,purps.para.scroll_frame_height)
        panel:ClearAllPoints()
        panel:SetPoint("TOPRIGHT",frame,"TOPLEFT")
        panel:SetPoint("BOTTOMRIGHT",frame,"BOTTOMLEFT")
        frame:StartSizing("BOTTOMRIGHT") 
    end)
    sizer:SetScript("OnDragStop",function() 
        frame:StopMovingOrSizing() 
        panel:StopMovingOrSizing()
        local w,h=frame:GetWidth(),frame:GetHeight()
        purps.para.main_frame_width=w
        purps.para.scroll_frame_height=h
        purps.interface:update_scroll_parameters()
        purps.interface:update_main_frame_parameters()
        
        raid_table_adapt_rows_to_height()
    end)  
    
    local interface=interface
    --create vote/main expansion buttons
    panel.expand_left_button=ui:SquareButton(panel,30,30,"LEFT")
    local left=panel.expand_left_button
    left:SetScript("OnClick",function() toggle_frame(interface.session_vote_frame) end)
    left:SetPoint("BOTTOMLEFT",panel,"TOPLEFT")
    
    panel.expand_right_button=ui:SquareButton(panel,30,30,"RIGHT")
    local right=panel.expand_right_button
    right:SetScript("OnClick",function() toggle_frame(interface.session_main_frame) end)
    right:SetPoint("BOTTOMRIGHT",panel,"TOPRIGHT")
    
    local vote=interface.session_vote_frame
    vote:SetPoint("TOPRIGHT",panel,"TOPLEFT")
    vote:SetPoint("BOTTOMRIGHT",panel,"BOTTOMLEFT")

    vote:SetScript("OnDragStart",function() 
        panel:StartMoving()
    end)
    vote:SetScript("OnDragStop",function() 
        panel:StopMovingOrSizing() 
        update_scroll_XY_paras()      
        purps.interface:update_scroll_parameters()
    end)  

    local sizer=vote.sizer_frame
    sizer:SetFrameLevel(vote:GetFrameLevel()+10)
    sizer:SetScript("OnDragStart",function()
        vote:StartSizing("BOTTOMLEFT") 
    end)
    sizer:SetScript("OnDragStop",function() 
        vote:StopMovingOrSizing() 
        local w,h=vote:GetWidth(),vote:GetHeight()
        purps.para.vote_frame_width=w
        purps.para.vote_frame_height=h
        purps.interface:update_vote_frame_parameters()
    end)  

end

function interface:refresh_sort_raid_table()
    local tbl=self.raid_table
    tbl:Refresh()
    tbl:SortData()
end

function interface:check_selected_item()
    local items=purps.current_session
    local scroll_items=interface.session_scroll_panel.scrollChild.items
    
    for i=1,#items do 
        scroll_items[i]:check_selected()
    end
    
end

function interface:check_items_status()
    local items=purps.current_session
    local scroll_items=interface.session_scroll_panel.scrollChild.items
    
    for i=1,#items do 
        scroll_items[i]:check_status()
    end
    
end












