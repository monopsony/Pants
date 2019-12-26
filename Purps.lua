PurpsAddon=LibStub("AceAddon-3.0"):NewAddon("PurpsAddon","AceConsole-3.0","AceComm-3.0","AceEvent-3.0","AceSerializer-3.0")
local purps=PurpsAddon
local LSM=LibStub:GetLibrary("LibSharedMedia-3.0")
local unpack,ipairs,pairs,wipe=unpack,ipairs,pairs,table.wipe

local defaults={
	profile={
		scroll_item_size={40,40},
		scroll_item_default_icon=136207,
		tertiary_stats_delimiter="//",
		scroll_item_spacing=10,
		scroll_frame_display_count=4,

		scroll_frame_width=65,
		scroll_frame_height=400,
		scroll_frame_pos={500,500},

		main_frame_width=450,
		main_frame_height=450,

		raid_table_y_inset=130,
		raid_table_x_inset=10,
		raid_table_bottom_inset=40,
		raid_table_row_height=30,
		preview_icon_size={75,75},

		min_resize_height=100,
		max_resize_height=1500,

		vote_frame_height=200,
		vote_frame_width=200,

		session_paras={
			response_names={[0]="Waiting for response...",[1]="Need",[2]="Offspec",[3]="M+",[4]="Transmog",[5]="Higher ilvl for trading",[6]="Pass"},
			response_colours={[0]={.2,.7,.7,1},[1]={.2,1,.2,1},[2]={.2,.2,1,1},[3]={.7,.7,.2,1},[4]={.7,.2,.7,1},[5]={.5,.5,.5,1},[6]={.5,.5,.5,1},[100]={.3,.3,.3,1}},
			disregard={text="Disregarded",color={.9,.6,0,1}},
			disregard_order=1.5,
		}, --end of session_paras

		rl_paras={
			council={
				[1]='',
				[2]='',
				[3]='',
				[4]='',
				[5]='',
				[6]='',
				[7]='',
				[8]='',
				[9]='',
			}
		}

	},-- end of profile
}--end of defaults

function purps:OnInitialize()
	self.full_name=self:unit_full_name("player")
	local _,realm=UnitFullName("player")
	self.realm_name=realm
	
	self.db=LibStub("AceDB-3.0"):New("PurpsAddonDB",defaults,true)  --true sets the default profile to a profile called "Default"
																 --see https://www.wowace.com/projects/ace3/pages/api/ace-db-3-0
	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
	
	self.para=self.db.profile
	
	self.interface:populate_scroll_child()
	self.interface:update_scroll_parameters(true)
	self.interface:update_main_frame_parameters(true)
	self.interface:update_vote_frame_parameters(true)
	
	self.interface:reset_items_status()
end


local chat_commands={
	["add"]=function(self,msg)
	
		if (self.active_session) and (not self.currently_in_council) then purps:send_user_message('not_in_council','add items to sessions'); return end

		if not purps:is_itemlink(msg) then purps:send_user_message("add_items_none_found") end
		local msg=purps:separate_itemlinks(msg)
		local args={self:GetArgs(msg,10,1)}
   
		for i,v in ipairs(args) do
			if self:is_itemlink(v) then 
				
				self:add_items_to_session(v)
				if self.active_session then 
					local item_info=self.current_session[#self.current_session].item_info
					self.current_session[#self.current_session].responses=self:generate_group_member_list(item_info)
					self:send_new_session_item(#self.current_session)
				end
			end
		end
		

	end,

	["help"]=function(...)
		purps:send_user_message("help_message")
		
	end,
	
	["test_table"]=function(...)
		PurpsAddon:raid_table_test_data()
	end,
	
	["raid_ping"]=function()     
		purps:send_raid_comm("PurpsPing")
	end,
	
	["send_session_paras"]=function(self)
		self:send_session_paras()
	end,
	
	["reset_profile"]=function()
		purps.db:ResetProfile()
	end,
	
	["send_current_session"]=function(self)
		self:send_current_session()
	end,
	
	["start_session"]=function(self)
		self:start_session()
	end,
	
	["end_session"]=function(self)
		self:send_end_session()
	end,
	
	['toggle']=function(self)
		local f=PurpsAddon.interface.session_scroll_panel
		if f:IsShown() then f:Hide() else f:Show() end
	end,

	['council']=function(self)
		local para=self.current_rl_paras
		if (not para) or (not para.council) then self:send_user_message('no_rl_paras'); return end
		local s=('Council members\n%s  %s  %s\n'):format('ID','Name','Status')  --'ID','Name','Status')
		for k,v in pairs(para.council) do 
			if (type(v)=='string') and (v~='') then 
				local name=Ambiguate(v,'none')
				local status=((not UnitInRaid(name)) and '|cffff0000Not in raid|r') 
					or ((not UnitIsConnected(name)) and '|cffffff00Offline|r')
					or '|cff00ff00Connected|r'

				s=('%s%s  %s  %s\n'):format(s,k,v,status)
			end
		end
		purps:send_user_message('generic',s)
	end,

	["metatable"]={__index=function(self,key) return self["help"] end},
}
setmetatable(chat_commands,chat_commands.metatable)


function purps:chat_command_handler(msg)
	local key=self:GetArgs(msg,1)
	if (not key) or (key=='metatable') then chat_commands["help"]() 
	else chat_commands[key](self,msg) end
end
purps:RegisterChatCommand("purps","chat_command_handler")

function purps:RefreshConfig()
	ReloadUI()
end

function purps:OnEnable()
		
end


local event_frame=CreateFrame('Frame','PurpsGlobalEventFrame',UIParent)
registered_events={'PLAYER_ENTERING_WORLD','PARTY_LEADER_CHANGED','GROUP_JOINED'}
purps.active_session_found_requested=false
for k,v in pairs(registered_events) do event_frame:RegisterEvent(v) end
function event_frame:handle_event(event)
	if (event=='PLAYER_ENTERING_WORLD') or (event=='GROUP_JOINED') then 

		purps.full_name=purps:unit_full_name("player")
		local _,realm=UnitFullName("player")
		purps.realm_name=realm

		--gotta throttle it by 1 frame when logging in
		--I assume for people to load your name (nil otherwise)
		local purps=purps
		C_Timer.After(0,function() purps:send_active_session_request() end)
	
	elseif event=='PARTY_LEADER_CHANGED' then
		purps:send_rl_paras()
	end

end
event_frame:SetScript('OnEvent',event_frame.handle_event)



