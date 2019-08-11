local purps=PurpsAddon
purps.interface={}
local interface=purps.interface
local ui=LibStub('StdUi')

--create loot menu main/vote frame
do
    --interface.session_main_frame=ui:PanelWithTitle(UIParent,200,200,"MAIN FRAME")
    interface.session_main_frame=ui:Panel(UIParent,200,200)
    local frame=interface.session_main_frame
    frame:SetPoint("CENTER")
    
    frame:Show()
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart",frame.StartMoving)
    frame:SetScript("OnDragStop",frame.StopMovingOrSizing)  
    frame:SetMinResize(100,100)

    frame.sizer_frame=ui:Frame(frame,10,10)
    local sizer=frame.sizer_frame
    sizer:SetPoint("BOTTOMRIGHT")
    
    frame:SetResizable(true)
    sizer:EnableMouse(true)
    sizer:RegisterForDrag("LeftButton")
    sizer:SetScript("OnDragStart",function() frame:StartSizing("BOTTOMRIGHT") end)
    sizer:SetScript("OnDragStop",function() frame:StopMovingOrSizing() end)  
    
end


function interface:update_scroll_parameters()
    local para=purps.para
    local panel=self.session_scroll_panel
    panel:SetWidth(para.scroll_frame_width)

end

function interface:populate_scroll_child()


    local para=purps.para
    local scrollChild=self.session_scroll_panel.scrollChild
    if not scrollChild.items then scrollChild.items={} end
    
    for i=1,20 do
        if not scrollChild.items[i] then scrollChild.items[i]=ui:HighlightButton(scrollChild,50,50,i) end
        local btn=scrollChild.items[i]
        btn:SetSize(unpack(para.scroll_item_size))
        if i==1 then 
            btn:SetPoint("TOP")
        else
            btn:SetPoint("TOP",scrollChild.items[i-1],"BOTTOM",0,-para.scroll_item_spacing)
        end
        btn:SetScript("OnClick",function() print(i) end)
        
        
        if not btn.item_texture then btn.item_texture=ui:Texture(btn,50,50) end
        btn.item_texture:SetAllPoints()
        btn.item_texture:SetTexture(para.scroll_item_default_icon)
    end
    
    
end

function interface:apply_session_to_scroll()
    local items=purps.current_session
    local n_items=#items
    local scroll_items=interface.session_scroll_panel.scrollChild.items
    
    for i=1,n_items do
        scroll_items[i]:Show()
        scroll_items[i].item_texture:SetTexture(items[i].item_info.itemIcon)
    end
    
    for i=n_items+1,20 do
        scroll_items[i]:Hide()
    end
    
end

--create loot menu scroll frame item picker
do
    
    --interface.session_scroll_frame=ui:
    --local args=interface.session_scroll_frame
    local frame=interface.session_main_frame
    local panel,scrollFrame,scrollChild,scrollBar=ui:ScrollFrame(frame,60,200)
    interface.session_scroll_panel=panel
    --panel.scrollChild / scrollFrame / scrollBar
    
    panel:SetPoint("TOPRIGHT",frame,"TOPLEFT")
    panel:SetPoint("BOTTOMRIGHT",frame,"BOTTOMLEFT")
    
    
end









