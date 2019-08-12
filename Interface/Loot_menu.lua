local purps=PurpsAddon
purps.interface={}
local interface=purps.interface
local ui=LibStub('StdUi')

--create loot menu main/vote frame
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
end

local function scroll_child_OnClick(self)
    if not self.session_index then return end
    
    interface.currently_selected_item=self.session_index
    interface:apply_selected_item()
    
    
    
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
    frame:SetPoint("TOPLEFT",panel,"TOPRIGHT")
    frame:SetPoint("BOTTOMLEFT",panel,"BOTTOMRIGHT")
   
    frame:SetScript("OnDragStart",function() 
        panel:StartMoving()
    end)
    frame:SetScript("OnDragStop",function() 
        panel:StopMovingOrSizing() 
        local x,y=panel:GetLeft(),panel:GetTop()
        purps.para.scroll_frame_pos[1]=x
        purps.para.scroll_frame_pos[2]=y
        
        purps.interface:update_scroll_parameters()
    end)  
    
    local sizer=frame.sizer_frame
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
    end)  
    
end







