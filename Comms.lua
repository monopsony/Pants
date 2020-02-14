local pants=PantsAddon

local afterDo,waiting_time=C_Timer.After,1
pants.registered_comms={

	["pantsPing"]=function(data,channel,sender)
		if pants.initiated_ping and (data~='init') then 
			pants.ping_responses[pants:unit_full_name(sender)]=data
			return 
		end

		if (data=='init') then
			pants:send_raid_comm('pantsPing',pants.version or '<1.1.3')
		end
	end,
	
	['pantsRLSend']=function(data,channel,sender)
		local tbl=pants:decode_decompress_deserialize(data)
		local prev_ML=pants:find_ML() or ''
		pants.current_rl_paras=tbl
		pants:apply_rl_paras()
		local new_ML=pants:find_ML() or ''

		if (prev_ML~=new_ML) then
			--upon changing ML
			pants:wipe_looted_tables()
			pants:qol_generate_update_table()
		end
	end,

	["pantsActSReq"]=function(data,_,sender)
		pants:send_rl_paras() --check if youre RL in the function itself
		if UnitIsUnit("player",sender) then return end
		if data=="0" then 
			pants:send_active_session_ping()
		else
			local full_name=pants:convert_to_full_name(data)
			if full_name==pants.full_name then
				if pants.throttle_timers.send_current_active_session.allowed then 
					pants:send_current_active_session()
					pants:throttle_action('send_current_active_session')
				end
			end
		end
	end,

	["pantsActSPing"]=function(data,_,sender)
		if UnitIsUnit("player",sender) then return end
		if (not pants.active_session) and data=='1' and (not pants.active_session_found_requested) then
			pants:send_session_request_name(sender)
			pants.active_session_found_requested=true
		end
	end,

	["pantsActSSend"]=function(data,_,sender)
		if UnitIsUnit("player",sender) then return end

		if (not pants.active_session) then --toad or different session version here?
			pants.registered_comms["pantsSCurr"](data,_,sender,true)
		end
	end,
	
	["pantsSCurr"]=function(data,_,sender,refresh)
		local tbl=pants:decode_decompress_deserialize(data)
		pants.current_session=tbl

		if refresh then 
			pants:send_user_message('session_sync',sender)
		else
			pants:send_user_message('session_started',sender)
		end

		pants.current_session_paras=tbl.paras

		pants.active_session=true
		pants.interface:refresh_sort_raid_table()
		pants.interface:update_response_dd()

		pants.interface:apply_session_to_scroll()
		pants.interface:reset_items_status()
		pants.interface:check_items_status()

		for i=1,#pants.current_session do
			local pants=pants
			afterDo(waiting_time,function() pants:send_equipped_items(i) end)
		end
		pants.interface.session_scroll_panel:Show()
	end,
	
	["pantsSAdd"]=function(data,_,sender)
		if not UnitIsUnit("player",sender) then 
			local tbl=pants:decode_decompress_deserialize(data)
			pants.current_session[#pants.current_session+1]=tbl
			local itemLink = tbl.item_info.itemLink
			if pants.active_session and pants.para.announce_on_add then pants:send_user_message('item_added',itemLink,sender) end
		end
		pants.interface:apply_session_to_scroll()
		if pants.active_session and pants.para.reopen_on_add then pants.interface.session_scroll_panel:Show() end

		--check which items are missing, send 
		--for i=1,#pants.current_session do
		--	local index=pants:name_index_in_session(pants.full_name,i)
		--	if index and (not pants.current_session[i].responses[index][4]) then --first equipped item
		--		afterDo(waiting_time,function() pants:send_equipped_items(i) end)
		--	end
		--end
		--
		local pants=pants
		for i=1,#pants.current_session do
			if (not pants.equipped_item_index_sent[i]) then
				pants.equipped_item_index_sent[i]=true
				afterDo(waiting_time,function() pants:send_equipped_items(i) end)
			end
		end

	end,

	["pantsSResUpd"]=function(data,_,sender)
		local tbl=pants:decode_decompress_deserialize(data)
		if not tbl then return end
		pants:apply_response_update(sender,tbl)
	end,
	
	["pantsSEnd"]=function(data,_,sender)
		pants:send_user_message('session_closed',sender)
		pants:apply_end_session()
	end,

	["pantsIAssign"]=function(data,_,sender)
		local data=pants:decode_decompress_deserialize(data)
		pants:apply_item_assignment(data)
	end,

	["pantsSimc"]=function(data,_,sender)
		local s=pants:decode_decompress(data)
		pants:save_simc_string(sender,s)
		pants.interface:refresh_sort_raid_table()
	end,

	["pantsSimcReq"]=function(data,_,sender)
		local s=pants:decode_decompress(data)
		local name=pants:convert_to_full_name(s)
		pants:save_simc_string(name,"pending")
		pants.interface:refresh_sort_raid_table()
		local pants=pants
		C_Timer.After(3,function()
			if not (pants:get_simc_string(name)=='pending') then return end
			pants:save_simc_string(name,'failed')
			pants.interface:refresh_sort_raid_table()
		end)
		if name~=pants.full_name then return end 
		pants:send_simc_string()
	end,

	["pantsItemLooted"]=function(data,_,sender)
		if not pants:are_you_ML() then return end
		local s=pants:decode_decompress(data)
		pants:add_to_looted_items(s,sender)
		pants:qol_generate_update_table()
	end,	

	["pantsDontTrade"]=function(data,_,sender)
		local data=pants:decode_decompress_deserialize(data)
		if not data.target and data.itemLink then return end
		if not UnitIsUnit(Ambiguate(data.target,'none'),'player') then return end
		pants:remove_recent_items_by_link(data.itemLink)
		pants:qol_generate_update_table()
	end,	

	['pantsSIDCheck']=function(data,_,sender)
		--if UnitIsUnit(sender,'player') then return end
		if not data then return end
		local id = pants:session_id()
		if (not pants.active_session) or (id~=data) then
			pants:send_session_request_name(sender)
		end
	end,
}


local registered_comms=pants.registered_comms

function pants:send_raid_comm(prefix,data)
	local channel=(IsInRaid() and "RAID") or (IsInGroup() and "PARTY") or ("WHISPER")
	if channel=="WHISPER" then 
		self:SendCommMessage(prefix,data or '0',channel,self.full_name)
	else
		self:SendCommMessage(prefix,data or '0',channel)
	end
end

function pants:OnCommReceived(prefix,data,channel,sender)
	registered_comms[prefix](data,channel,sender)
end

for k,v in pairs(registered_comms) do 
	pants:RegisterComm(k)
end


function pants:send_simc_request(name)
	if not self:in_council() then pants:send_user_message('not_in_council','send SimC requests'); return end
	local s=self:compress_encode(name)
	self:send_raid_comm("pantsSimcReq",s)
end

function pants:send_current_session()
	local session=self.current_session
	session.paras=self.para.session_paras
	session.id0 = random(1000)
	local s=self:serialize_compress_encode(session)
	self:send_raid_comm("pantsSCurr",s)
end

function pants:send_new_session_item(i)
    if not self:in_council() then pants:send_user_message('not_in_council','end sessions'); return end
	local session=self.current_session
	if (not i) or (#session<i) then return end 
	session['item_session_id']=i
	local s=self:serialize_compress_encode(session[i])
	self:send_raid_comm("pantsSAdd",s)
end

function pants:send_response_update(response)
	if not response or not (type(response)=="table") then return end
	local s=self:serialize_compress_encode(response)
	self:send_raid_comm("pantsSResUpd",s)
end

pants.equipped_item_index_sent={} --will be filled when you send items, resets on session end
local ipairs=ipairs
function pants:send_equipped_items(session_index)
	if (not session_index) or (not self.current_session[session_index]) then return end
	local items=self:get_equipped_items(session_index)
	local _,ilvl=GetAverageItemLevel()
	local response={[3]=ilvl,item_index=session_index}

	if not items then return self:send_response_update(response) end
	response.equipped=items
	self:send_response_update(response)
end

function pants:send_end_session()
    if not self:in_council() then pants:send_user_message('not_in_council','end sessions'); return end
	self:send_raid_comm("pantsSEnd",nil)
end

function pants:send_active_session_request()
	self:send_raid_comm("pantsActSReq",nil)
end

function pants:send_active_session_ping()
	local bool = self.active_session 
		and (self.current_session) 
		and not (self.current_session.archived)
		and pants.throttle_timers.send_active_session_ping.allowed
	self:send_raid_comm("pantsActSPing",(bool and '1') or '0')
	if bool then pants:throttle_action('send_active_session_ping') end
end

function pants:send_session_request_name(name)
	self:send_raid_comm('pantsActSReq',name)
end

function pants:send_current_active_session()
	local session=self.current_session
	local s=self:serialize_compress_encode(session)
	self:send_raid_comm("pantsActSSend",s)
end

function pants:send_rl_paras()
	local para=self.para.rl_paras
	local s=self:serialize_compress_encode(para)
	if not UnitIsGroupLeader('player') then return end
	self:send_raid_comm("pantsRLSend",s)
end

function pants:send_item_assignment(item_index,name)
    if (not item_index) or (not name) or (not self.current_session[item_index]) then return end
    local data={item_index=item_index,name=name}
	local s=self:serialize_compress_encode(data)
	self:send_raid_comm("pantsIAssign",s)
end

function pants:send_item_looted(itemLink)
	if not itemLink then return end
	local s=self:compress_encode(itemLink)
	self:send_raid_comm('pantsItemLooted',s)
end