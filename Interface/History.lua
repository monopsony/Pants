local pants=PantsAddon
local interface=pants.interface
local ui=LibStub('StdUi')
local media="Interface\\AddOns\\Pants\\Media\\"

function pants:archive_current_session()
	if (not self.current_session) or (self.current_session.archived) then return end 
	self.current_session.archived=true

	local date = C_DateAndTime.GetCurrentCalendarTime()
	self.current_session.date=date
	local monthDay,weekday,month,year=date.monthDay,date.weekday,date.month,date.year

	local session=self:table_deep_copy(self.current_session)

	local h=self.para.history
	if not h[year] then h[year]={} end
	if not h[year][month] then h[year][month]={} end
	if not h[year][month][monthDay] then h[year][month][monthDay]={} end
	local h=h[year][month][monthDay]
	h[#h+1]=session
end

pants.current_date = C_DateAndTime.GetCurrentCalendarTime()
local week_days={'Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday',}
local month_names={'January','February','March','April','May','June','July','August','September','October','November','December',}


function pants:load_archived_session(year,month,monthDay,index)
	local h=self.para.history
	if (not year) or (not h[year])
	or (not month) or (not h[year][month])
	or (not monthDay) or (not h[year][month][monthDay])
	or (not index) or (not h[year][month][monthDay][index]) 
	then return end

	self.current_session=self:table_deep_copy(h[year][month][monthDay][index])
	self.active_session=true

	self.current_session_paras=self.current_session.paras
	self.interface:refresh_sort_raid_table()
	self.interface:update_response_dd()

	self.interface:apply_session_to_scroll()
	self.interface:reset_items_status()
	self.interface:check_items_status()

	self.interface.session_scroll_panel:Show()
end

interface.history_frame=ui:PanelWithTitle(UIParent,400,400,'Pants history',70,30)
local hf=pants.interface.history_frame

local function update_XY_paras()
    local hf=pants.interface.history_frame
    local x,y=hf:GetLeft(),hf:GetTop()
    pants.para.history_frame_pos[1]=x
    pants.para.history_frame_pos[2]=y
end

function interface:update_history_frame_paras()
    local hf,para=pants.interface.history_frame,pants.para
    local x,y=unpack(para.history_frame_pos)
    hf:SetHeight(para.history_frame_height)
    hf:SetWidth(para.history_frame_width)
    hf:ClearAllPoints()
    hf:SetPoint('TOPLEFT',UIParent,'BOTTOMLEFT',x,y)
end

do --make movable
	hf:SetPoint('TOP',UIParent,'TOP')
	hf:SetMovable(true)
	hf:EnableMouse(true)
	hf:RegisterForDrag("LeftButton")
	hf:SetScript("OnDragStart",function() 
	    hf:StartMoving()
	end)
	hf:SetScript("OnDragStop",function() 
	    hf:StopMovingOrSizing() 
	    update_XY_paras()
	    interface:update_history_frame_paras()
	end)  
end 

--create sizer
do 
	hf.sizer=ui:Frame(hf,15,15)
	local sizer=hf.sizer
	sizer:SetPoint("BOTTOMRIGHT")

	hf:SetResizable(true)
	sizer:EnableMouse(true) 
	sizer:RegisterForDrag("LeftButton")
	sizer:SetFrameLevel(hf:GetFrameLevel()+10)
	sizer.texture=sizer:CreateTexture(nil,'OVERLAY')
	sizer.texture:SetAllPoints()
	sizer.texture:SetTexture(media..'SIZER')
	sizer.texture:SetAlpha(.7)
	sizer:SetScript("OnDragStart",function()
	    hf:StartSizing("BOTTOMRIGHT") 
	end)

	sizer:SetScript("OnDragStop",function() 
	    hf:StopMovingOrSizing() 
	    local w,h=hf:GetWidth(),hf:GetHeight()
	    pants.para.history_frame_height=h
	    pants.para.history_frame_width=w
	    interface:update_history_frame_paras()
	end) 

    hf:SetMinResize(460,300)
    hf:SetMaxResize(2000,2000)
end

--create dropdowns
do
	local dd_height,dd_width,spacing=35,100,20
	local year=pants.current_date.year
	hf.year_dd=ui:Dropdown(hf,dd_width,dd_height,{},year)
	hf.year_dd:SetPoint('TOPLEFT',hf,'TOPLEFT',10,-55)
	hf.year_dd.label=ui:AddLabel(hf.year_dd,hf.year_dd,'Year')

	hf.month_dd=ui:Dropdown(hf,dd_width*1.5,dd_height,{},year)
	hf.month_dd:SetPoint('LEFT',hf.year_dd,'RIGHT',spacing,0)
	hf.month_dd.label=ui:AddLabel(hf.month_dd,hf.month_dd,'Month')

	hf.day_dd=ui:Dropdown(hf,dd_width*1.5,dd_height,{},year)
	hf.day_dd:SetPoint('LEFT',hf.month_dd,'RIGHT',spacing,0)
	hf.day_dd.label=ui:AddLabel(hf.day_dd,hf.day_dd,'Day')
end

--make table
do


	interface.history_table_settings={
	    --Updater
	    {
	        name="",
	        width=1,
	        align="LEFT",
	        index=0,
	        format=function(_,response)
	        end,
	        
	    },

	    --Name
	    {
	        name="",
	        width=50,
	        align="LEFT",
	        index=1,
	        format='text',
	        sortable=true,
	    }, 
	    
	    {
	        name="Day",
	        width=105,
	        align="LEFT",
	        index=2,
	        format=function(a)
	        	return week_days[a] or 'UNKNOWN'
	        end,
	        sortable=true,
	    }, 

	    {
	        name="Time",
	        width=60,
	        align="LEFT",
	        index=3,
	        format='text',
	        sortable=true,
	    }, 

	    -- --assign icon
	    -- {
	    --     name="Give",
	    --     sortable=false,
	    --     width=42,
	    --     align="CENTER",
	    --     index=9,
	    --     format="icon",
	    --     events={
	    --         OnClick = function(table, cellFrame, rowFrame, rowData, columnData, rowIndex)
	    --             if not pants.currently_in_council then pants:send_user_message('not_in_council','assign winners'); return end
	    --             local item_index=pants.interface.currently_selected_item or nil
	    --             if not item_index then return end 
	    --             if rowData.win then return end
	    --             local name,class=rowData[1],rowData.class
	    --             local hex=pants:class_to_hex(class)
	    --             pants.pending_item_assignment={item_index,name}
	    --             pants:create_popup_confirm( ('assign this item to |c%s%s|r'):format(hex,name),pants.confirm_pending_item_assignment)
	    --         end,
	    --         }, 
	    --     },
	}
	local table_column_default=interface.history_table_settings

	local function table_entry_from_session(session)
		local tbl,date={},session.date
		tbl[1]=session.date.monthDay
		tbl[2]=session.date.weekday
		tbl[3]= ('%02d:%02d'):format(date.hour,date.minute)
		return tbl
	end

	local pairs=pairs
	function interface:fill_history_table()
		local data,h={},pants.para.history
		local year,month,day=hf.year_dd:GetValue(),hf.month_dd:GetValue(),hf.day_dd:GetValue()

		if (not year) or (not month) or (not h[year]) or (not h[year][month]) then return end
		if (not day) or (not h[year][month][day]) then
			for k,v in pairs(h[year][month]) do
				for k1,v1 in pairs(v) do 
					data[#data+1]=table_entry_from_session(v1)
				end
			end
		else
			for k,v in pairs(h[year][month][day]) do 
				data[#data+1]=table_entry_from_session(v)
			end
		end
		hf.table:SetData(data)
	end

	hf.table=ui:ScrollTable(hf,table_column_default,20,20)
	local tbl=hf.table
	tbl:SetPoint('TOPLEFT',hf.year_dd,'BOTTOMLEFT',0,-35)
	tbl:SetPoint('BOTTOMRIGHT',hf,'BOTTOMRIGHT',-10,15)
end

--apply dropdown functions
do

	local y_tbl,m_tbl,d_tbl={},{},{}
	function interface:apply_history_dds(b1,b2,b3)
		local hf=pants.interface.history_frame
		local h=pants.para.history
		
		--year
		if b1 then
			wipe(y_tbl)
			for k,v in pairs(h) do
				y_tbl[#y_tbl+1]={text=tostring(k),value=k}
			end
			hf.year_dd:SetOptions(y_tbl)
			hf.year_dd:SetValue(y_tbl[#y_tbl].value or pants.current_date.year)
		end

		--month
		if b2 then 
			wipe(m_tbl)
			local year=hf.year_dd:GetValue()
			if (not year)then return end
			for k,v in pairs(h[year]) do
				m_tbl[#m_tbl+1]={text=('%s / %s'):format(k,month_names[k] or 'UNKNOWN'),value=k}
			end
			hf.month_dd:SetOptions(m_tbl)
		end

		--day
		if b3 then 
			wipe(d_tbl)
			local year=hf.year_dd:GetValue()
			local month=hf.month_dd:GetValue()
			if (not year)or (not month) then return end
			for k,v in pairs(h[year][month]) do
				local day_name=(v[1] and week_days[v[1].date.weekday]) or 'UNKNOWN'
				d_tbl[#d_tbl+1]={text=('%s / %s'):format(k,day_name),value=k}
			end
			hf.day_dd:SetOptions(d_tbl)
			hf.day_dd:SetValue(nil)
		end
	end

	hf.year_dd.OnValueChanged=function(self,value)
		interface:apply_history_dds(false,true,false)
	end

	hf.month_dd.OnValueChanged=function(self,value)
		interface:apply_history_dds(false,false,true)
		interface:fill_history_table()
	end

	hf.day_dd.OnValueChanged=function(self,value)
		interface:apply_history_dds(false,false,false)
		interface:fill_history_table()
	end
end