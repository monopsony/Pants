local pants=PantsAddon
local interface=pants.interface
local ui=LibStub('StdUi')
local media="Interface\\AddOns\\Pants\\Media\\"


--Create popup confirm
interface.popup_confirm=ui:PanelWithTitle(UIParent,350,110,'Pants',30,15)
interface.popup_confirm.label=ui:Label(interface.popup_confirm,'',12)

local pc=interface.popup_confirm
pc:SetPoint('TOP',UIParent,'TOP') --will be set when called as well
pc:SetFrameLevel(interface.session_main_frame:GetFrameLevel()+10)
pc:Hide()

--YES BUTTON
pc.yes=ui:Button(pc,65,30,'Confirm')
pc.yes:SetPoint('BOTTOMLEFT',pc,'BOTTOMLEFT',20,10)
pc.yes:SetScript('OnClick',function()
	pc:Hide()
	if pc.func and (type(pc.func)=='function') then pc.func(pants) end
end)

--NO BUTTON
pc.no=ui:Button(pc,65,30,'Cancel')
pc.no:SetPoint('BOTTOMRIGHT',pc,'BOTTOMRIGHT',-20,10)
pc.no:SetScript('OnClick',function()
	pc:Hide()
	pc.func=nil
end)

interface.popup_confirm.label:SetPoint('TOP',interface.popup_confirm,'TOP',0,-10)
interface.popup_confirm.label:SetPoint('BOTTOMRIGHT',interface.popup_confirm.no,'BOTTOMRIGHT',0,10)
interface.popup_confirm.label:SetPoint('BOTTOMLEFT',interface.popup_confirm.yes,'BOTTOMLEFT',0,10)

function pants:create_popup_confirm(s,f)
	if (not s) or (not f) or not (type(s)=='string') or not (type(f)=='function') then return end
	pc:SetPoint('TOP',UIParent,'TOP',0,-GetScreenHeight()*.15)
	pc.func=f
	pc.label:SetText(('Are you sure you want to %s?'):format(s))
	pc:Show()
end


------QoL frame

local function qol_update_XY_paras()
    local qol=pants.interface.qol_frame
    local x,y=qol:GetLeft(),qol:GetTop()
    pants.para.qol_frame_pos[1]=x
    pants.para.qol_frame_pos[2]=y
end

interface.qol_frame=ui:PanelWithTitle(UIParent,400,200,'Quick pants',70,30)
local qol=interface.qol_frame
qol:Hide()

do --make movable
	qol:SetPoint('TOP',UIParent,'TOP')
	qol:SetMovable(true)
	qol:EnableMouse(true)
	qol:RegisterForDrag("LeftButton")
	qol:SetScript("OnDragStart",function() 
	    qol:StartMoving()
	end)
	qol:SetScript("OnDragStop",function() 
	    qol:StopMovingOrSizing() 
	    qol_update_XY_paras()
	    interface:update_qol_frame_paras()
	end)  
end 

local qol_paras={
	width=350,
	height=160,
	num_items=3,
	scroll_height=130,
	scroll_width=340,
	item_texture_size=35,
	btn_width=80,
	btn_height=32,
}
qol_paras.scroll_child_height=qol_paras.scroll_height/qol_paras.num_items-2
qol_paras.scroll_child_width=qol_paras.scroll_width-25

function interface:update_qol_frame_paras()
	pants.para.qol_frame_height=qol_paras.height
	pants.para.qol_frame_width=qol_paras.width --quick fix
    local qol,para=pants.interface.qol_frame,pants.para
    local x,y=unpack(para.qol_frame_pos)
    qol:SetHeight(para.qol_frame_height)
    qol:SetWidth(para.qol_frame_width)
    qol:ClearAllPoints()
    qol:SetPoint('TOPLEFT',UIParent,'BOTTOMLEFT',x,y)

    qol.scroll_frame:SetWidth(qol_paras.scroll_width)
    qol.scroll_frame:SetHeight(qol_paras.scroll_height)
end

--create sizer & closer
do 
	-- qol.sizer=ui:Frame(qol,15,15)
	-- local sizer=qol.sizer
	-- sizer:SetPoint("BOTTOMRIGHT")

	-- qol:SetResizable(true)
	-- sizer:EnableMouse(true) 
	-- sizer:RegisterForDrag("LeftButton")
	-- sizer:SetFrameLevel(qol:GetFrameLevel()+10)
	-- sizer.texture=sizer:CreateTexture(nil,'OVERLAY')
	-- sizer.texture:SetAllPoints()
	-- sizer.texture:SetTexture(media..'SIZER')
	-- sizer.texture:SetAlpha(.7)
	-- sizer:SetScript("OnDragStart",function()
	--     qol:StartSizing("BOTTOMRIGHT") 
	-- end)

	-- sizer:SetScript("OnDragStop",function() 
	--     qol:StopMovingOrSizing() 
	--     local w,h=qol:GetWidth(),qol:GetHeight()
	--     pants.para.qol_frame_height=h
	--     pants.para.qol_frame_width=w
	--     interface:update_qol_frame_paras()
	-- end) 

 --    qol:SetMinResize(460,300)
 --    qol:SetMaxResize(2000,2000)

    qol.close_window_button=ui:SquareButton(qol,25,25,"LEFT")
    local close=qol.close_window_button
    close.icon:ClearAllPoints()
    close.icon:SetAllPoints()
    close.icon:SetTexCoord(0,1,0,1)
    close:SetNormalTexture(media.."CLOSE_BUTTON_TEXTURE")
    close:SetScript("OnClick",function() qol:Hide() end)
    close:SetPoint("TOPLEFT",qol,"TOPLEFT",5,-5)
end


--create faux scroll frame
do 	
	qol.scroll_child=ui:Frame()
	qol.scroll_frame=ui:FauxScrollFrame(qol,qol_paras.scroll_width,qol_paras.scroll_child_height,qol_paras.num_items,qol_paras.scroll_child_height,qol.scroll_child)
	local sf,sc=qol.scroll_frame,qol.scroll_child
	sc.items={}
	sf:SetPoint('TOP',qol,'TOP',0,-30)

	local qol_paras=qol_paras

    local function set_icon_tooltip(self)
        local itemLink=self.link
        if not itemLink then return end  
        self:SetHyperlink(itemLink)
    end

	local function create(parent,itemFrame,value,i,key)
		local f=ui:Panel(parent)
		f.texture_frame=ui:Frame(f,qol_paras.item_texture_size,qol_paras.item_texture_size)
		f.texture_frame:SetPoint('LEFT',f,'LEFT',10,0)

		f.texture=ui:Texture(f.texture_frame,nil,nil,136207)
		f.texture:SetAllPoints()

		f.text=ui:FontString(f,'N/A')
		f.text:SetPoint('LEFT',f.texture,'RIGHT',10,0)

		f.button=ui:Button(f,qol_paras.btn_width,qol_paras.btn_height,'N/A')
		f.button:SetSize(qol_paras.btn_width, qol_paras.btn_height)
		f.button:SetPoint('RIGHT',f,'RIGHT',-10,0)
		f.button:SetScript('OnClick',function() pants:qol_perform_quick_action(f) end)

		f.button2=ui:Button(f,qol_paras.btn_width,qol_paras.btn_height,'N/A')
		f.button2:SetSize(qol_paras.btn_width/4, qol_paras.btn_height)
		f.button2:SetPoint('RIGHT',f.button,'LEFT',-5,0)
		f.button2:SetScript('OnClick',function() pants:qol_perform_quick_action_2(f) end)
    	
    	f.texture_frame:EnableMouse()
    	f.texture_frame.tooltip=ui:Tooltip(f.texture_frame,set_icon_tooltip,"PantsAddon_qol_tooltip_"..tostring(i),"TOPRIGHT",true)
		return f
	end

	local function update(parent,frame,data)
		frame.data = data
		ui:SetObjSize(frame, qol_paras.scroll_child_width,qol_paras.scroll_child_height)
		--tbl[#tbl+1]={name=name,class=class,mode='assign',itemLink=self.current_session[i].item_info.itemLink}

		if data.mode =='assign' then
			local color=pants:class_to_hex(data.class)
			frame.text:SetText(('Assigned to |c%s%s|r'):format(color,pants:remove_realm(data.name)))

			frame.button:SetText('Trade')

			local _,_,_,_,_,_,_,_,_,itemTexture=GetItemInfo(data.itemLink)
			frame.texture:SetTexture(itemTexture)
			frame.texture_frame.tooltip.link=data.itemLink
		end

		
		if data.mode =='trade_ML' then
			local color=pants:class_to_hex(data.class)
			frame.text:SetText(('Trade to |c%s%s|r (ML)'):format(color,pants:remove_realm(data.name)))

			frame.button:SetText('Trade')

			local _,_,_,_,_,_,_,_,_,itemTexture=GetItemInfo(data.itemLink)
			frame.texture:SetTexture(itemTexture)
			frame.texture_frame.tooltip.link=data.itemLink
		end

		if data.mode == 'to_add' then
			local color=pants:class_to_hex(data.class)
			frame.text:SetText(('Looted by |c%s%s|r'):format(color,pants:remove_realm(data.name)))

			frame.button:SetText('Add item')

			local _,_,_,_,_,_,_,_,_,itemTexture=GetItemInfo(data.itemLink)
			frame.texture:SetTexture(itemTexture)
			frame.texture_frame.tooltip.link=data.itemLink
		end

		if data.mode2 then
			frame.button2:Show()

			if data.mode2 == 'dont_add' then
				frame.button2:SetText('X')
			end

		else
			frame.button2:Hide()
		end




		return frame
	end

	local sc,create,update=sc,create,update
	function interface:refresh_qol_list()
		ui:ObjectList(sc,sc.items,create,update,pants.qol_full_data)
	end

end
