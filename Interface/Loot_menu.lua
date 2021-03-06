local pants=PantsAddon
pants.interface={}
local interface=pants.interface
local ui=LibStub('StdUi')
local media="Interface\\AddOns\\Pants\\Media\\"


local function update_scroll_XY_paras()
    local panel=pants.interface.session_scroll_panel
    local x,y=panel:GetLeft(),panel:GetTop()
    pants.para.scroll_frame_pos[1]=x
    pants.para.scroll_frame_pos[2]=y
end

local floor=floor
local function raid_table_adapt_rows_to_height()
    local frame=interface.session_main_frame
    local tbl=frame.raid_table
    local para=pants.para
    
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
    --frame:SetClipsChildren(true)


    frame.sizer_frame=ui:Frame(frame,15,15)
    local sizer=frame.sizer_frame
    sizer:SetPoint("BOTTOMRIGHT")
    
    frame:SetResizable(true)
    sizer:EnableMouse(true)
    sizer:RegisterForDrag("LeftButton")
    
    --preview icon
    frame.preview_icon=ui:Button(frame,75,75)
    local icon=frame.preview_icon
    icon:SetPoint("TOPLEFT",frame,"TOPLEFT",10,-10)
    
    
    local function set_icon_tooltip(self)
    
        local item_index=pants.interface.currently_selected_item or nil
        if not item_index then return "N/A" end 

        if (not pants.current_session) or (not pants.current_session[item_index]) then return "N/A" end
        
        local page=pants.current_session[item_index]
        local itemLink=page.item_info.itemLink    
        
        self:SetHyperlink(itemLink)
        self:SetUpgradeItem(itemLink,itemLink)
    end
    
    icon:SetScript('OnEnter',function(self)
        pants.interface.mousing_over=self
        if (pants.interface.currently_selected_item)
        and (pants.current_session) 
        and (pants.current_session[pants.interface.currently_selected_item])
        and (pants.current_session[pants.interface.currently_selected_item].item_info) 
        then
            pants.interface.show_tooltip(self, true, pants.current_session[pants.interface.currently_selected_item].item_info.itemLink)
        end
    end)
    icon:SetScript('OnLeave',function(self)
        pants.interface.mousing_over=nil
        pants.interface.show_tooltip(self, false);
    end)
    icon:SetScript('OnClick',function(self)
        local item_index=pants.interface.currently_selected_item
        if IsModifiedClick()
            and item_index
            and pants.current_session 
            and pants.current_session[item_index]
            and pants.current_session[item_index].item_info
        then 
            HandleModifiedItemClick(pants.current_session[item_index].item_info.itemLink); 
        end
    end)
    icon:RegisterForClicks("AnyUp")

    icon.texture=ui:Texture(icon,75,75)
    local txt=icon.texture
    txt:SetAllPoints()
    
    --duplicate buttons
    local function duplicate_button_OnClick(self)
        local session = pants.current_session
        -- currently_clicked_duplicate
        if not session then return end
        local index = pants.interface.currently_selected_item
        local page = session[index]

        if not page then return end

        if page.ori then page = page.ori end
        self.session_index = page.item_index
        page.currently_clicked_duplicate = self.duplicate_index
        pants.interface.scroll_child_OnClick(self)
    end

    local target_dup_btn_text = "Interface\\Buttons\\CheckButtonHilight-Blue"
    frame.duplicate_buttons = {}
    local dp = frame.duplicate_buttons
    for i = 1, 20 do 
        if not dp[i] then 
            dp[i] = ui:HighlightButton(frame,20,20,tostring(i)) 
        end
        local btn = dp[i]

        if i==1 then
            btn:SetPoint('TOPLEFT',icon,'BOTTOMLEFT',0,-10)
        else
            btn:SetPoint('LEFT',dp[i-1],'RIGHT',0,0)
        end
        btn.duplicate_index = i-1
        btn:SetScript('OnClick',duplicate_button_OnClick)

        btn.targetted_texture = btn:CreateTexture(nil,'OVERLAY')
        btn.targetted_texture:SetAllPoints()
        btn.targetted_texture:SetTexture(target_dup_btn_text)
        btn.targetted_texture:SetTexCoord(.2,.8,.2,.8)
        btn.targetted_texture:SetAlpha(.7)

        btn:Hide()
    end    


    --info texts
    frame.text_item_name=ui:FontString(frame,"")
    frame.text_item_name:SetPoint("TOPLEFT",icon,"TOPRIGHT",10,0)

    frame.text_item_info=ui:FontString(frame,"")
    frame.text_item_info:SetPoint("TOPLEFT",frame.text_item_name,"BOTTOMLEFT",0,-5)

    frame.text_item_level=ui:FontString(frame,"")
    frame.text_item_level:SetPoint("TOPLEFT",frame.text_item_info,"BOTTOMLEFT",0,-5)

    frame.text_item_extra=ui:FontString(frame,"")
    frame.text_item_extra:SetPoint("TOPLEFT",frame.text_item_level,"BOTTOMLEFT",0,-5)
    

    frame.text_assigned=ui:FontString(frame,"")
    frame.text_assigned:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-85,-10)



end


--create loot menu response frame
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

    frame.sizer_frame=ui:Frame(frame,15,15)
    local sizer=frame.sizer_frame
    sizer:SetPoint("BOTTOMLEFT")
    
    frame:SetResizable(true)
    sizer:EnableMouse(true) 
    sizer:RegisterForDrag("LeftButton")
    
    --response dd
    frame.response_dd=ui:Dropdown(frame,150,25,{{text="N/A",value=1}},nil)
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
    local eb=frame.note_eb

    --bandaiding what I think is a bug in the new stdui update
    eb.editBox.stdUi=dd.stdUi  
    eb.scrollFrame.stdUi=dd.stdUi 
    eb.scrollChild.stdUi=dd.stdUi
    local previous_value=''
    eb.editBox:SetScript("OnTextChanged",function(self) 
        local s = self:GetText()
        local _,n_lines = string.gsub(s,'\n','') --second return value is number of occurences
        if n_lines > 30 then 
            self:SetText(previous_value)
        else 
            previous_value=s
        end

    end)
    eb:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-10,-40)
    eb:SetPoint("BOTTOMLEFT",frame,"BOTTOMLEFT",10,40)
    
    eb.scrollChild:SetMaxLetters(200)
    
    
    --vote button
    frame.send_button=ui:Button(frame,75,25,"SEND")
    local sb=frame.send_button
    sb:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-10,10)
    sb:SetScript("OnClick",function()
        local item_index=pants.interface.currently_selected_item or nil
        if not item_index then return end 
    
        local response=pants.interface:generate_response()
        if not response then return end
        
        frame.note_eb:ClearFocus()

        pants:send_response_update(response)
        if pants.para.go_next then 
            local new = pants.interface:item_go_next() 
            if not new then pants:throttle_action('send_button') end
        else
            pants:throttle_action('send_button')
        end
        
    end)
    

end

function interface.show_tooltip(frame, show, itemLink)
	if show then
		GameTooltip:SetOwner(frame,"ANCHOR_RIGHT");
		GameTooltip:SetHyperlink(itemLink)    
	else
		GameTooltip:Hide();
	end
end
local show_tooltip=interface.show_tooltip

local function show_tooltip_string(frame, show, str)
	if show then
		GameTooltip:SetOwner(frame,"ANCHOR_RIGHT");
		GameTooltip:SetText(str)
	else
		GameTooltip:Hide();
	end
end

local has_note,has_no_note=media.."NOTE_FILLED",media.."NOTE_EMPTY"
local regarded_icon,disregarded_icon=media.."EYE_OPEN",media.."EYE_CLOSED"
local simc_filled,simc_empty=media.."SIMC_ICON",media.."SIMC_ICON"
local assign_icon=media..'LOOT_BAG'
local RAID_CLASS_COLORS=RAID_CLASS_COLORS 
local compare_sort_function=function(self,rowA,rowB,sortBy)
    local x,y=self:GetRow(rowA),self:GetRow(rowB)
    local a = ( x.disregarded and pants.current_session_paras.disregard_order )  or  (x.response_id) or 0
    local b = ( y.disregarded and pants.current_session_paras.disregard_order )  or  (y.response_id) or 0  
    a = ((a==0) and (pants.current_session_paras.pending_order or 2.5)) or a
    b = ((b==0) and (pants.current_session_paras.pending_order or 2.5)) or b
    local column=self.columns[sortBy]
    local direction=column.sort or column.defaultSort or 'asc'

    if a==b then 
        local n1,n2 = x[1], y[1]
        return n1<n2
    end

    if direction:lower() == 'asc' then 
        return a<b
    else
        return a>b
    end
end

local yellow_color,grey_color,white_color,red_color={r=1,g=.8,b=0,a=1},{r=.3,g=.3,b=.3,a=1},{r=1,g=1,b=1,a=1},{r=1,g=.2,b=.2,a=1}
pants.interface.table_column_settings={

    --Updater
    {
        name="",
        width=1,
        align="LEFT",
        index=0,
        format=function(_,response)
            --best way I found to do this
            --updates whatever needs to be updates
            --like the note icon/disregard icon/response/equipped items etc
            
            --equipped items
            local eq,name=response.equipped,response[1]
            if (not eq) or (not eq[1]) then 
                response[4]=nil
            else
                local itemIcon=select(10,GetItemInfo(eq[1]))
                response[4]=itemIcon
            end
            if (not eq) or (not eq[2]) then 
                response[5]=nil
            else
                local itemIcon=select(10,GetItemInfo(eq[2]))
                response[5]=itemIcon
            end
            

            --note
            local note=response.note
            if not note or (note=="") then 
                response[6]=has_no_note
                pants.interface.table_column_settings[7].color=grey_color
            else
                response[6]=has_note
                pants.interface.table_column_settings[7].color=yellow_color
            end
        
            --simc
            local simc=pants.simc_strings[name]
            if (not simc) or (simc=="") then 
                response[8]=simc_empty
                pants.interface.table_column_settings[9].color=grey_color
            elseif (simc=="pending") then
                response[8]=simc_filled
                pants.interface.table_column_settings[9].color=white_color
            elseif (simc=="failed") then
                response[8]=simc_filled
                pants.interface.table_column_settings[9].color=red_color
            else
                response[8]=simc_filled
                pants.interface.table_column_settings[9].color=yellow_color
            end

            --assign
            local win=response.win
            if (not win)  then 
                response[9]=assign_icon
                pants.interface.table_column_settings[10].color=white_color
            else
                response[9]=assign_icon
                pants.interface.table_column_settings[10].color=yellow_color
            end

            --response
            local s=""
            if response.disregarded and (pants.current_session_paras) and (pants.current_session_paras.disregard) then --simple lua error fix, minor
                s=pants.current_session_paras.disregard.text or "Disregarded"
            else
                s=pants.current_session_paras.response_names[response.response_id or ""] or "N/A"
            end
            response[2]=s
            
            --disregard/show
            if response.disregarded then
                response[7]=disregarded_icon
                pants.interface.table_column_settings[8].color=yellow_color
            else
                response[7]=regarded_icon
                pants.interface.table_column_settings[8].color=grey_color
            end
        end,
        
    },

    --Name
    {
        name="Name",
        width=105,
        align="LEFT",
        index=1,
        format=function(name) 
            return pants:remove_realm(name)
        end,
        
        color=function(_,_,tbl)
            local class=tbl.class or "PRIEST"
            local color=RAID_CLASS_COLORS[class]
            return {r=color.r,g=color.g,b=color.b}
        end,
        sortable=true,
    }, 
    
    --Response
    {
        name="Response",
        width=175,
        align="LEFT",
        index=2,
        format="text",
        color=function(_,_,tbl)
            local r,g,b,a=1,1,1,1
            if pants.current_session_paras then
                if tbl.disregarded then 
                    r,g,b,a=unpack(pants.current_session_paras.disregard.color)
                else
                    local response_id=tbl.response_id
                    r,g,b,a=unpack(pants.current_session_paras.response_colours[response_id] or {1,1,1,1})
                end
            end
            return {r=r,g=g,b=b,a=a or 1}
        end,
        compareSort=compare_sort_function,
    },   
    
    --ilvl
    {
        name="iLvl",
        sortable=false,
        width=75,
        align="CENTER",
        index=3,
        format=function(ilvl_avg,response)
            if (not pants.interface.currently_selected_item) or (not pants.current_session) or (not response) then return end
            if pants.current_session[pants.interface.currently_selected_item] 
            and pants.current_session[pants.interface.currently_selected_item].item_info 
            and response.equipped then

                local ilvl,ilvln = pants.current_session[pants.interface.currently_selected_item].item_info.itemLevel,9999
                for i=1,2 do 
                    local item = response.equipped[i]
                    if not item then break end
                    local temp_ilvl = select(4,GetItemInfo(item))
                    if not temp_ilvl then break end
                    ilvln = min(temp_ilvl, ilvln)
                end

                if ilvln~=9999 and pants.para.ilvl_difference then
                    local diff = ilvl - ilvln
                    local c = ((diff>0) and '+') or ((diff<0) and '-') or ''
                    return ("%.0f(%s%s)"):format(ilvl_avg,c,abs(diff))
                end
            end
            return ("%.0f"):format(ilvl_avg or 'N/A')
        end,
        compareSort=compare_sort_function,

    }, 
    
    --equipped 1
    {
        name="1",
        sortable=false,
        width=32,
        align="CENTER",
        index=4,
        format="icon",
        events={
			OnEnter = function(table, cellFrame, rowFrame, rowData, columnData, rowIndex)
                pants.interface.mousing_over=cellFrame
				local cellData = rowData[columnData.index];
                local eq=rowData.equipped
                if (not eq) or (not eq[1]) then show_tooltip(cellFrame,false); return false end
                
				show_tooltip(cellFrame, true, eq[1]);
				return false;
			end,
			OnLeave = function(rowFrame, cellFrame)
                pants.interface.mousing_over=nil
				show_tooltip(cellFrame, false);
				return false;
			end
        },
        compareSort=compare_sort_function,

    }, 
    
    --equipped 2
    {
        name="2",
        sortable=false,
        width=32,
        align="CENTER",
        index=5,
        format="icon",
        events={
			OnEnter = function(table, cellFrame, rowFrame, rowData, columnData, rowIndex)
                pants.interface.mousing_over=cellFrame
				local cellData = rowData[columnData.index];
                local eq=rowData.equipped
                if (not eq) or (not eq[2]) then show_tooltip(cellFrame,false); return false end
                
				show_tooltip(cellFrame, true, eq[2]);
				return false;
			end,
			OnLeave = function(rowFrame, cellFrame)
                pants.interface.mousing_over=nil
				show_tooltip(cellFrame, false);
				return false;
			end
        },
        compareSort=compare_sort_function,

    }, 
 
    --note icon
    {
        name="Note",
        sortable=false,
        width=42,
        align="CENTER",
        index=6,
        format="icon",
        color=yellow_color,
        events={
			OnEnter = function(table, cellFrame, rowFrame, rowData, columnData, rowIndex)
                pants.interface.mousing_over=cellFrame
				local cellData = rowData[columnData.index];
                local note=rowData.note
                if (not note) or (note=="") then show_tooltip_string(cellFrame,false); return false end
                
				show_tooltip_string(cellFrame, true, note);
				return false;
			end,
			OnLeave = function(rowFrame, cellFrame)
                pants.interface.mousing_over=nil
				show_tooltip_string(cellFrame, false);
				return false;
			end,
            OnClick = function(table, cellFrame, rowFrame, rowData, columnData, rowIndex)
                if not pants.para.copy_note_link then return end
                local note = rowData.note
                if not note then return end
                note = note..' ' --easier than adding a third match for "if there's only a link"
                local a = note:match('(www.-) ')
                if not a then a = note:match('(www.-)\n') end
                if a then pants.interface:open_link_cp_frame(a) end
            end,  
            },      
        compareSort=compare_sort_function,
    }, 
 
    --disregard icon
    {
        name="Show",
        sortable=false,
        width=42,
        align="CENTER",
        index=7,
        format="icon",
        events={
			OnClick = function(table, cellFrame, rowFrame, rowData, columnData, rowIndex)
                if not pants:in_council() then pants:send_user_message('not_in_council','disregard responses'); return end
                local item_index=pants.interface.currently_selected_item or nil
                if not item_index then return end 
                local regard=(not rowData.disregarded) or false
                pants:send_response_update({item_index=item_index,row_index=rowIndex,disregarded=regard})
            end,
            }, 
        compareSort=compare_sort_function,
        },
 
    --simc icon
    {
        name="Simc",
        sortable=false,
        width=42,
        align="CENTER",
        index=8,
        format="icon",
        events={
            OnClick = function(table, cellFrame, rowFrame, rowData, columnData, rowIndex)
                local item_index=pants.interface.currently_selected_item or nil
                if not item_index then return end 
                local name=rowData[1]
                local iteminfo=pants.current_session[item_index].item_info

                if UnitIsUnit(Ambiguate(name,'none'),'player') then pants:simc_slash_itemlink(iteminfo.itemLink); return end

                local simc_string=pants.simc_strings[name]
                if (not simc_string) or (simc_string=="failed") then 
                    if pants.throttle_timers.simc_ask.allowed then 
                        pants:send_simc_request(name)
                        pants:throttle_action('simc_ask')
                    end
                    return
                elseif simc_string=="pending" then return end


                local extra=pants:generate_bag_item_from_info(iteminfo)
                
                local concat=('%s%s'):format(simc_string,extra)

                if pants.simc_strings[name] then 
                    pants:show_simc_output(concat) 
                end
                --show_simc_output
            end,

            OnEnter = function(table, cellFrame, rowFrame, rowData, columnData, rowIndex)
                pants.interface.mousing_over=cellFrame
                local cellData = rowData[columnData.index];

                local name,s=rowData[1],''
                local simc_string=pants.simc_strings[name]
                
                if not simc_string then 
                    s="Click to request simc info"
                elseif simc_string=='pending' then
                    s='Simc info is underway...'
                elseif simc_string=='failed' then
                    s='Simc info failed to arrive. Perhaps recipient\ndoes not have the Simulationcraft addon enabled.\nClick to try again.'
                else 
                    s='Show simc info'
                end
                show_tooltip_string(cellFrame, true, s);
                return false;
            end,
            OnLeave = function(rowFrame, cellFrame)
                pants.interface.mousing_over=nil
                show_tooltip_string(cellFrame, false);
                return false;
            end
            }, 
            compareSort=compare_sort_function,
        },

    --assign icon
    {
        name="Give",
        sortable=false,
        width=42,
        align="CENTER",
        index=9,
        format="icon",
        events={
            OnClick = function(table, cellFrame, rowFrame, rowData, columnData, rowIndex)
                if not pants:in_council() then pants:send_user_message('not_in_council','assign winners'); return end
                local item_index=pants.interface.currently_selected_item or nil
                if not item_index then return end 
                if rowData.win then return end
                local name,class=rowData[1],rowData.class
                local hex=pants:class_to_hex(class)
                pants.pending_item_assignment={item_index,name}
                pants:create_popup_confirm( ('assign this item to |c%s%s|r'):format(hex,name),pants.confirm_pending_item_assignment)
            end,
            }, 
        compareSort=compare_sort_function,
        },
        
}

local table_column_default=pants.interface.table_column_settings

local help_table1,wipe={},table.wipe
function interface:generate_response()
    local item_index=self.currently_selected_item or nil
    if not item_index then return end 

    local vote=self.session_vote_frame
    local a,b=vote.response_dd:GetValue() or 0,vote.note_eb:GetText() or ""
    if a==0 then return nil end
    wipe(help_table1)
    help_table1.response_id=a --response is [2] but it's updated by the Updater (see [0])
    help_table1.note=b --note id is 6, but that's just the icon
                        --the actual tooltip etc is done in [3] the ilvl thing (which also handles equipped items tooltips)
    help_table1.voted=true
    help_table1.item_index=item_index
    return help_table1
end

--create loot menu table
do
    local frame=interface.session_main_frame
    local tbl=ui:ScrollTable(frame,table_column_default,0,20)
    frame.raid_table=tbl
    interface.raid_table=tbl
    tbl:SetPoint("TOPLEFT",frame,"TOPLEFT",10,-120)
    tbl:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-10,-120)
    tbl:SetPoint("BOTTOM",frame,"BOTTOM",0,20)
        
    --icon
    frame.pants_icon=frame:CreateTexture(nil,'OVERLAY')
    frame.pants_icon:SetTexture(media..'PANTS_ICON')
    frame.pants_icon:SetPoint('TOPRIGHT',frame,'TOPRIGHT',-5,-10)
    frame.pants_icon:SetSize(50,50)
    frame.pants_icon:SetAlpha(.5)


    --council buttons
    frame.start_session_button=ui:Button(frame,105,25,'Start session')
    frame.start_session_button:SetPoint('BOTTOMLEFT',frame,'TOPLEFT',30,-1)
    frame.start_session_button:SetScript('OnClick',function()
        if not pants:in_council() then pants:send_user_message('not_in_council','start sessions'); return end
        if pants.active_session then pants:send_user_message('session_active') return end
        pants:create_popup_confirm('start the session',pants.start_session)
    end)

    --council buttons
    frame.end_session_button=ui:Button(frame,105,25,'End session')
    frame.end_session_button:SetPoint('BOTTOMLEFT',frame,'TOPLEFT',140,-1)
    frame.end_session_button:SetScript('OnClick',function()
        if not pants:in_council() then pants:send_user_message('not_in_council','end sessions'); return end
        pants:create_popup_confirm('end the session',pants.send_end_session)
    end)

end

function interface:update_main_frame_parameters(initialize)
    local frame=interface.session_main_frame
    local icon=frame.preview_icon
    local para=pants.para
    local panel=interface.session_scroll_panel
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT",panel,"TOPRIGHT")
    frame:SetSize(para.main_frame_width,para.main_frame_height)
    
    frame:SetMinResize(100,para.min_resize_height)
    frame:SetMaxResize(2000,para.max_resize_height)
    
    icon:SetSize(unpack(para.preview_icon_size))
    if initialize then icon.texture:SetTexture(para.scroll_item_default_icon) end
    
    interface:udpate_raid_table_parameters()
end

function interface:update_vote_frame_parameters(initialize)
    local frame=interface.session_vote_frame
    local para=pants.para
    local panel=interface.session_scroll_panel
    frame:ClearAllPoints()
    frame:SetPoint("TOPRIGHT",panel,"TOPLEFT")
    frame:SetPoint("BOTTOMRIGHT",panel,"BOTTOMLEFT")
    frame:SetSize(para.vote_frame_width,para.scroll_frame_height)
    
    frame:SetMinResize(100,para.min_resize_height)
    frame:SetMaxResize(2000,para.max_resize_height)
end

function interface:udpate_raid_table_parameters(initialize)
    local frame=interface.session_main_frame
    local tbl=frame.raid_table
    local para=pants.para
    tbl:SetPoint("TOPLEFT",frame,"TOPLEFT",para.raid_table_x_inset,-para.raid_table_y_inset-15)
    tbl:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-para.raid_table_x_inset,-para.raid_table_y_inset-15)
    tbl:SetPoint("BOTTOM",frame,"BOTTOM",0,para.raid_table_bottom_inset)
    
    --tbl:SetDisplayRows(0,para.raid_table_row_height)
    --tbl:SetDisplayRows(10,para.raid_table_row_height)
    
    raid_table_adapt_rows_to_height()
end

function interface:update_scroll_parameters(initialize)
    local para=pants.para
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
    panel.close_window_button:SetSize(size,size)
end

function interface:refill_vote_frame()
    local item_index=self.currently_selected_item or nil
    if not item_index then return end 

    local vote=self.session_vote_frame
    
    local index=pants:name_index_in_session(pants.full_name,item_index)
    
    if pants.current_session and pants.current_session[item_index] and pants.current_session_paras then
        if not pants.current_session[item_index].responses then return end
        local response=pants.current_session[item_index].responses[index]
        if not response then
            --youre not allowed to respond here
            vote.blocker:Show()
            return 
        end
        vote.blocker:Hide()

        local response_id=(response.response_id==0 and #pants.current_session_paras.response_names) or response.response_id 
        vote.response_dd:SetValue(response_id)
        vote.note_eb:SetText(response.note or "")
        
    else
        vote.response_dd:SetValue(0)
        vote.note_eb:SetText("")
    end
    
    vote.note_eb:ClearFocus()
    vote.send_button:Enable()
end

local help_table,wipe,pairs={},table.wipe,pairs
function interface:update_response_dd()
    if not pants.current_session_paras then return end
    local para=pants.current_session_paras.response_names
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
    
    if IsModifiedClick()
        and self.session_index
        and pants.current_session
        and pants.current_session[self.session_index]
        and pants.current_session[self.session_index].item_info
    then 
        HandleModifiedItemClick(pants.current_session[self.session_index].item_info.itemLink); 
    else

        local session = pants.current_session[self.session_index]
        if not session then return end
        if pants.para.stack_duplicates 
            and session.duplicates
            and #session.duplicates>0
        then
            if not session.currently_clicked_duplicate then
                session.currently_clicked_duplicate = 0 -- 0 means original
            end
            local ccd = session.currently_clicked_duplicate

            if ccd == 0 then 
                interface.currently_selected_item = self.session_index
            else
                local index = session.duplicates[ccd].item_index
                interface.currently_selected_item = index
            end
        else
            interface.currently_selected_item = self.session_index
        end

        interface:apply_selected_item()
        interface:check_selected_item()
    end
    
end
pants.interface.scroll_child_OnClick = scroll_child_OnClick

local function scroll_child_tooltip(self)

    local item_index=self.button.session_index or nil
    if not item_index then return end 

    local page=pants.current_session[item_index]
    if not page then return end

    local itemLink=page.item_info.itemLink    
    if not itemLink then return end

    self:SetHyperlink(itemLink)
    self:SetHyperlink(itemLink)
    
end

local function check_selected(self)
    local bool=false
    local ind1,ind2=self.session_index or nil,pants.interface.currently_selected_item or nil
    local session = pants.current_session 
    if (not ind1) or (not ind2) or (not session) then return end
    if not session[ind2] then return end

    if pants.para.stack_duplicates and session[ind2].ori then 
        ind2 = session[ind2].ori.item_index
    end
    bool = (ind1==ind2) 
    
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
        self.item_texture:SetDesaturated(false)
        self:SetAlpha(1)
    end,
    
    ["vote_pending"]=function(self)
        self.status="vote_pending"
        self.status_frame:Show()
        self.status_frame:SetSize(self:GetWidth()*.7,self:GetHeight()*.7)
        self.status_frame.texture:SetTexture(media.."EXC_POINT")
        self.status_frame.texture:SetVertexColor(1,.8,0)
        self.item_texture:SetDesaturated(false)
        self:SetAlpha(1)
    end,

    ["not_in_list"]=function(self)
        self.status="not_in_list"
        self.status_frame:Hide()
        self.item_texture:SetDesaturated(true)
        self.status_frame.texture:SetVertexColor(1,1,1)
        self:SetAlpha(.7)
    end,

    ['pending']=function(self)
        self.status="pending"
        self.status_frame:Show()
        self.status_frame:SetSize(self:GetWidth(),self:GetHeight())
        self.status_frame.texture:SetTexture(media.."CIRCLE")
        self.status_frame.texture:SetVertexColor(1,.7,0)
        self.item_texture:SetDesaturated(false)
        self:SetAlpha(1)
    end,

    ['won']=function(self)
        self.status="won"
        self.status_frame:Show()
        self.status_frame:SetSize(self:GetWidth(),self:GetHeight())
        self.status_frame.texture:SetTexture(media.."CIRCLE")
        self.status_frame.texture:SetVertexColor(.1,.9,.1)
        self.item_texture:SetDesaturated(false)
        self:SetAlpha(1)
    end,

    ['lost']=function(self)
        self.status="lost"
        self.status_frame:Show()
        self.status_frame:SetSize(self:GetWidth(),self:GetHeight())
        self.status_frame.texture:SetTexture(media.."CIRCLE")
        self.status_frame.texture:SetVertexColor(.9,.1,.1)
        self.item_texture:SetDesaturated(false)
        self:SetAlpha(1)
    end,


    ["metatable"]={__index=function(table,key) return table["none"] end}
}   

local function session_player_status(session,player_index)
    if (not session) or (not session.responses) then 
        return 'none'
    end
    status = 'none'
    if (not player_index) or (not session.responses[player_index]) then
        status="not_in_list"
    elseif session.responses[player_index].win then
        status='won'
    elseif pants:item_assigned_player(index) then
        status='lost'
    elseif not session.responses[player_index].voted then
        status="vote_pending"
    else
        status='pending'
    end
    return status
end

local duplicate_status_prio_list={
    'not_in_list',
    'won',
    'pending',
    'vote_pending',
    'lost',
}
local function duplicate_status(tbl)
    local status='none'
    if not tbl then return end

    local is_in = pants.array_has_value

    for i,v in ipairs(duplicate_status_prio_list) do 
        if is_in(nil,tbl,v) then
            status = v
            break
        end
    end
    return status
end

local function btn_apply_duplicate_text(btn)
    if not btn then return end
    local index = btn.session_index
    local session = pants.current_session[index]
    if not session then return end 

    if pants.para.stack_duplicates 
        and session.duplicates 
        and (#session.duplicates>0) 
    then 
        local n = #session.duplicates
        btn.duplicate_text:SetText(tostring(n+1))
        btn.duplicate_text:Show()
    else
        btn.duplicate_text:Hide()
    end
end

local function btn_apply_assigned_tag(btn)
    if not btn then return end
    local index = btn.session_index
    local session = pants.current_session[index]
    if not session then return end 

    if pants.para.council_show_assigned_tag 
        and pants:in_council()
        and pants:item_assigned_player(index)
    then 
        btn.assigned_tag:Show()
    else
        btn.assigned_tag:Hide()
    end

end


setmetatable(set_status,set_status.metatable)
local status_help_table = {} --helps with saving intermediate duplicate states
local function check_status(self,is_session_item)
    if not is_session_item then 
        local index=self.session_index
        if not index then return 'none' end

        local session,status,player_index=pants.current_session[index],"none",pants:name_index_in_session(pants.full_name,index)

        if (not session) or (not session.responses) then set_status['none'](self); return end
            
        if pants.para.stack_duplicates 
            and session.duplicates 
            and #session.duplicates>0 
        then
            local tbl = status_help_table
            wipe(tbl)
            tbl[1] = check_status(session,true)
            for i,v in ipairs(session.duplicates) do 
                tbl[#tbl+1] = check_status(v,true)
            end
            status = duplicate_status(tbl)

        else -- if not duplicate stuff
            status = session_player_status(session, player_index)
        end

        if status~=self.status then set_status[status](self) end

    else --if it's a session item (i.e. not the actual button)
         --this is (only) called for the duplicate thing above
        local index = self.item_index 
        local player_index = pants:name_index_in_session(pants.full_name,index)
        if not pants.current_session 
            or not pants.current_session[index] 
        then return 'none' end
        return session_player_status(self, player_index)
    end


end


function interface:populate_scroll_child()

    local para=pants.para
    local scrollChild=self.session_scroll_panel.scrollChild
    if not scrollChild.items then scrollChild.items={} end
    
    for i=1,20 do
        if not scrollChild.items[i] then scrollChild.items[i]=ui:HighlightButton(scrollChild,50,50,nil) end
        local btn=scrollChild.items[i]
        btn:SetSize(unpack(para.scroll_item_size))
        btn.OnClick=scroll_child_OnClick
        btn:RegisterForClicks("AnyUp")
        if i==1 then 
            btn:SetPoint("TOP")
        else
            btn:SetPoint("TOP",scrollChild.items[i-1],"BOTTOM",0,-para.scroll_item_spacing)
        end
        btn:SetScript("OnClick",btn.OnClick)
        
        if not btn.item_texture then btn.item_texture=ui:Texture(btn,50,50) end
        btn.item_texture:SetAllPoints()
        btn.item_texture:SetTexture(para.scroll_item_default_icon)

        btn:SetScript('OnEnter',function(self)
            pants.interface.mousing_over=self
            local session_index=self.session_index
            if session_index and pants.current_session[session_index] and pants.current_session[session_index].item_info
            then
                show_tooltip(self, true, pants.current_session[session_index].item_info.itemLink)
            end
        end)
        btn:SetScript('OnLeave',function(self)
            pants.interface.mousing_over=nil
            show_tooltip(self, false);
        end)
        
    
        -- btn.tooltip=ui:Tooltip(btn,scroll_child_tooltip,"PantsAddon_scroll_frame_icon_tooltip"..tostring(i),"TOPRIGHT",true)
        -- btn.tooltip.button=btn
        
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

        --duplicate number
        if not btn.duplicate_text then 
            btn.duplicate_text = ui:FontString(btn,'')
        end
        btn.duplicate_text:SetPoint('BOTTOMRIGHT',btn,'BOTTOMRIGHT',-4,2)
        btn.duplicate_text:SetJustifyH('RIGHT')
        btn.duplicate_text:SetJustifyV('BOTTOM') 
        btn.duplicate_text:SetFont( "Fonts\\ARIALN.TTF",14, "OUTLINE")
        btn.duplicate_text:SetTextColor(1,1,1)

        --duplicate number
        if not btn.assigned_tag then 
            btn.assigned_tag = btn:CreateTexture(nil,"OVERLAY")
        end
        btn.assigned_tag:SetPoint('TOPRIGHT',btn,'TOPRIGHT',0,0)
        btn.assigned_tag:SetTexture(assign_icon)
        btn.assigned_tag:SetSize(17,17)
        r,g,b = yellow_color.r, yellow_color.g, yellow_color.b
        btn.assigned_tag:SetVertexColor(r, g, b)
    end
end

function interface:apply_session_to_scroll()
    local items=pants.current_session
    if (not items) or (#items==0) then return end
    local scroll_items=interface.session_scroll_panel.scrollChild.items
    local order=pants:get_session_order()

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

local empty_table={}
function interface:table_reload_item()
    local tbl=self.raid_table
    
    
    local item_index=self.currently_selected_item or nil
    
    if item_index and (pants.current_session) and (pants.current_session[item_index]) and (pants.current_session[item_index].responses) then
        tbl:SetData(pants.current_session[item_index].responses)
        if not interface:table_currently_sorted() then tbl.head.columns[3]:Click() end
    else
        tbl:SetData(empty_table)
    end
end

local ITEM_QUALITY_COLORS=ITEM_QUALITY_COLORS
function interface:update_assigned_text()
    local frame=self.session_main_frame
    local item_index=self.currently_selected_item or nil
    if not item_index then return end
    local assigned='|cffff0000No winner yet|r'
    local winner,class=pants:item_assigned_player(item_index)
    if winner then
        winner=pants:remove_realm(winner)
        assigned=('|cff00ff00Winner: |r|c%s%s|r'):format(pants:class_to_hex(class),winner)
    end
    frame.text_assigned:SetText(assigned)

end

function interface:table_currently_sorted()
    local tbl=self.raid_table
    local cols=tbl.head.columns

    --surely theres a better way?
    for k,v in ipairs(cols) do if v.arrow:IsShown() then return k end end 
    return nil
end

function interface:apply_selected_item()
    
    if (self.currently_selected_item)
        and (pants.current_session) 
        and (pants.current_session) 
        and (pants.current_session[self.currently_selected_item])
        and (pants.current_session[self.currently_selected_item].item_info)  
        then
    
        local item_index=self.currently_selected_item or nil
        if (not item_index) then return end 
        --TBA add error message
        
        local para=pants.para
        local page=pants.current_session[item_index]
        local item=page.item_info
        local frame=self.session_main_frame
        
        --apply icon 
        frame.preview_icon.texture:SetTexture(item.itemIcon or para.scroll_item_default_icon)

        --apply texts
        frame.text_item_name:SetText(  ("|c%s%s|r"):format( (item.itemRarity and ITEM_QUALITY_COLORS[item.itemRarity].color:GenerateHexColor()) or "ffffffff", item.itemName)  )
        frame.text_item_info:SetText(  ("%s, %s"):format(item.itemSubType or "",(item.itemEquipLoc and _G[item.itemEquipLoc] ) or "") )
        frame.text_item_level:SetText(  ("ilvl: %d"):format(item.itemLevel or 69))
        frame.text_item_extra:SetText(  ("|cff00ff00%s|r"):format(item.itemTertiary or "") )
        self:update_assigned_text()
        
        n = 0
        --apply duplicate things
        local page = page.ori or page
        local sel = page.currently_clicked_duplicate or 21
        if para.stack_duplicates 
            and page.duplicates 
            and #page.duplicates>0 
        then
            n = #page.duplicates + 1 -- +1 cause original is included
        end
        for i = 1, n do 
            frame.duplicate_buttons[i]:Show()
        end
        for i = n+1, 20 do 
            frame.duplicate_buttons[i]:Hide()
        end
        -- currently_clicked_duplicate

        for i= 1, 20 do 
            local b = frame.duplicate_buttons[i]

            -- Hide/show not needed/needed buttons
            if i<=n then b:Show() else b:Hide() end

            -- Apply selected texutre
            if b.duplicate_index == sel then  
                b.targetted_texture:Show() 
            else 
                b.targetted_texture:Hide() 
            end
        end

    else
    
        local para=pants.para
        local frame=self.session_main_frame
        
        self.current_selected_item=nil
        frame.preview_icon.texture:SetTexture(nil)
        frame.text_item_name:SetText("")
        frame.text_item_info:SetText("")
        frame.text_item_level:SetText("")
        frame.text_item_extra:SetText("")
        frame.text_assigned:SetText('')
    end
    
    if pants.active_session then
        self.session_main_frame.raid_table:Show()
        self:table_reload_item()
        self:refill_vote_frame()
    else
        self.session_main_frame.raid_table:Hide()
    end


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
    local panel=ui:ScrollFrame(UIParent,60,200)
    local scrollFrame=panel.scrollFrame
    frame:SetParent(panel) --changed my mind
    interface.session_scroll_panel=panel
    --panel.scrollChild / scrollFrame / scrollBar
    
    panel:SetPoint("TOPLEFT",UIparent,"BOTTOMLEFT",50,850)
    panel:SetMovable(true)
    panel:SetResizable(true)
    panel:EnableMouse(true)
    frame:SetPoint("TOPLEFT",panel,"TOPRIGHT")
   
    frame:SetScript("OnDragStart",function() 
        panel:StartMoving()
    end)
    frame:SetScript("OnDragStop",function() 
        panel:StopMovingOrSizing() 
        update_scroll_XY_paras()      
        pants.interface:update_scroll_parameters()
    end)  
    
    scrollFrame:EnableMouse(true)
    scrollFrame:RegisterForDrag('LeftButton')
    scrollFrame:SetScript("OnDragStart",function() 
        panel:StartMoving()
    end)
    scrollFrame:SetScript("OnDragStop",function() 
        panel:StopMovingOrSizing() 
        update_scroll_XY_paras()      
        pants.interface:update_scroll_parameters()
    end)     

    local sizer=frame.sizer_frame
    sizer:SetFrameLevel(frame:GetFrameLevel()+10)
    sizer:SetScript("OnDragStart",function()
        -- local x,y=unpack(pants.para.scroll_frame_pos)
        -- x=x+pants.para.scroll_frame_width
        -- frame:ClearAllPoints()
        -- frame:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",x,y)
        -- frame:SetSize(pants.para.main_frame_width,pants.para.scroll_frame_height)
        frame:StartSizing("BOTTOMRIGHT") 
    end)
    sizer:SetScript("OnDragStop",function() 
        frame:StopMovingOrSizing() 
        panel:StopMovingOrSizing()
        local w,h=frame:GetWidth(),frame:GetHeight()
        pants.para.main_frame_width=w
        pants.para.main_frame_height=h
        pants.interface:update_scroll_parameters()
        pants.interface:update_main_frame_parameters()
        
        raid_table_adapt_rows_to_height()
    end)  
    sizer.texture=sizer:CreateTexture(nil,'OVERLAY')
    sizer.texture:SetAllPoints()
    sizer.texture:SetTexture(media..'SIZER')
    sizer.texture:SetAlpha(.7)
    
    local interface=interface
    --create vote/main expansion buttons
    panel.expand_left_button=ui:SquareButton(panel,30,30,"LEFT")
    local left=panel.expand_left_button
    left:SetScript("OnClick",function() toggle_frame(interface.session_vote_frame) end)
    left:SetPoint("BOTTOMLEFT",panel,"TOPLEFT",0,-1)
    
    panel.expand_right_button=ui:SquareButton(panel,30,30,"RIGHT")
    local right=panel.expand_right_button
    right:SetScript("OnClick",function() toggle_frame(interface.session_main_frame) end)
    right:SetPoint("BOTTOMRIGHT",panel,"TOPRIGHT",0,-1)
    
    panel.close_window_button=ui:SquareButton(panel,30,30,"LEFT")
    local close=panel.close_window_button
    --close.icon:SetTexture(media.."CLOSE_BUTTON")
    --close.icon:SetAllPoints()
    close.icon:ClearAllPoints()
    close.icon:SetAllPoints()
    close.icon:SetTexCoord(0,1,0,1)
    close:SetNormalTexture(media.."CLOSE_BUTTON_TEXTURE")
    close:SetScript("OnClick",function() toggle_frame(interface.session_scroll_panel) end)
    close:SetPoint("BOTTOM",panel,"TOP",0,-1)

    local vote=interface.session_vote_frame
    vote:SetPoint("TOPRIGHT",panel,"TOPLEFT")
    vote:SetPoint("BOTTOMRIGHT",panel,"BOTTOMLEFT")

    vote:SetParent(panel)
    vote:SetScript("OnDragStart",function() 
        panel:StartMoving()
    end)
    vote:SetScript("OnDragStop",function() 
        panel:StopMovingOrSizing() 
        update_scroll_XY_paras()      
        pants.interface:update_scroll_parameters()
    end)  

    local sizer=vote.sizer_frame
    sizer:SetFrameLevel(vote:GetFrameLevel()+10)
    sizer:SetScript("OnDragStart",function()
        local x,y=vote:GetLeft(),vote:GetTop()
        vote:ClearAllPoints()
        vote:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",x,y)
        vote:SetSize(pants.para.vote_frame_width,pants.para.scroll_frame_height)
        panel:ClearAllPoints()
        panel:SetPoint("TOPLEFT",vote,"TOPRIGHT")
        panel:SetPoint("BOTTOMLEFT",vote,"BOTTOMRIGHT")
        vote:StartSizing("BOTTOMLEFT") 
    end)
    sizer:SetScript("OnDragStop",function() 
        vote:StopMovingOrSizing() 
        local w,h=vote:GetWidth(),vote:GetHeight()
        pants.para.vote_frame_width=w
        pants.para.vote_frame_height=h
        pants.para.scroll_frame_height=h
        pants.interface:update_scroll_parameters()
        pants.interface:update_vote_frame_parameters()
    end) 

    sizer.texture=sizer:CreateTexture(nil,'OVERLAY')
    sizer.texture:SetAllPoints()
    sizer.texture:SetTexture(media..'SIZER')
    sizer.texture:SetAlpha(.7)
    sizer.texture:SetRotation(-math.pi/2)

    --create vote blocker
    vote.blocker=CreateFrame('Button',nil,vote)
    bl=vote.blocker
    bl:SetFrameLevel(vote:GetFrameLevel()+4)
    bl:SetAllPoints()
    bl:EnableMouse(true)
    bl:RegisterForDrag('LeftButton')
    bl:SetScript("OnDragStart",function() 
        panel:StartMoving()
    end)
    bl:SetScript("OnDragStop",function() 
        panel:StopMovingOrSizing() 
        update_scroll_XY_paras()      
        pants.interface:update_scroll_parameters()
    end)  


    bl.texture=bl:CreateTexture(nil,'OVERLAY')
    bl.texture:SetAllPoints()
    bl.texture:SetColorTexture(0,0,0,.4)

    bl.text=bl:CreateFontString(nil,'OVERLAY')
    bl.text:SetPoint('CENTER')
    bl.text:SetFont("Fonts\\FRIZQT__.TTF",13)
    bl.text:SetText('Not lootable')
    bl:Show()
end

function interface:refresh_sort_raid_table()
    local tbl=self.raid_table
    tbl:Refresh()
    tbl:SortData()
end

function interface:check_selected_item()
    local items=pants.current_session
    local scroll_items=interface.session_scroll_panel.scrollChild.items
    
    if not items then interface.currently_selected_item=nil; return end
    
    for i=1,#items do 
        if scroll_items[i]:IsShown() then
            scroll_items[i]:check_selected()
        end
    end
end

function interface:check_items_status()
    local items=pants.current_session
    local scroll_items=interface.session_scroll_panel.scrollChild.items

    if not items then return end
    for i=1,#items do 
        scroll_items[i]:check_status()
        btn_apply_duplicate_text(scroll_items[i])
        btn_apply_assigned_tag(scroll_items[i])
    end
end

function interface:item_go_next()
    local items=pants.current_session
    local scroll_items=interface.session_scroll_panel.scrollChild.items
    if not items then return end

    i0=1
    for i=1,#items do 
        if scroll_items[i]:IsShown() and scroll_items[i].is_selected then
            i0=i
        end
    end

    for i=i0+1,#items do 
        if scroll_items[i].status == 'vote_pending' then scroll_items[i]:Click(); return true end
    end
    return false
end

function interface:reset_items_status()
    local items=pants.current_session
    local scroll_items=interface.session_scroll_panel.scrollChild.items

    if not items then return end
    for i=1,#items do 
        set_status['none'](scroll_items[i])
    end
end


local modifier_frame = CreateFrame('Frame',nil,UIParent)
modifier_frame:RegisterEvent('MODIFIER_STATE_CHANGED')
modifier_frame:SetScript('OnEvent',function()
    if pants.interface.mousing_over then
        local f = pants.interface.mousing_over:GetScript('OnEnter')
        if f then f( pants.interface.mousing_over) end
    end
end)

