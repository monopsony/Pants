local pants=PantsAddon

pants.simc_strings={
}
--setmetatable( pants.simc_strings, {__index=function(self,index) return '' end} )

local Simulationcraft
if LibStub.libs['AceAddon-3.0'].addons['Simulationcraft'] then
	Simulationcraft=LibStub.libs["AceAddon-3.0"]:GetAddon("Simulationcraft")
end

function pants:generate_simc_string()
    if not Simulationcraft then return end
    Simulationcraft:PrintSimcProfile(false,true)
    local s=SimcCopyFrameScrollText:GetText(nil,true)
    SimcCopyFrame:Hide()
    return s 
end

function pants:send_simc_string()
    local sim=self:generate_simc_string()
	if not sim then return end
    local s=self:compress_encode(sim)
    self:send_raid_comm("pantsSimc",s)
end

function pants:save_simc_string(sender,data)
	local name=self:convert_to_full_name(sender)
	self.simc_strings[name]=data
end

function pants:get_simc_string(sender)
	local name=self:convert_to_full_name(sender)
	return self.simc_strings[name] or ''
end

function pants:show_simc_output(out)
	if not SimcCopyFrame then print("No Simulationcraft Addon found! Output cannot be given"); return end --TBA error handling
	-- show the appropriate frames
	SimcCopyFrame:Show()
	SimcCopyFrameScroll:Show()
	SimcCopyFrameScrollText:Show()
	SimcCopyFrameScrollText:SetText(out)
	SimcCopyFrameScrollText:HighlightText()
	SimcCopyFrameScrollText:SetScript("OnEscapePressed", function(self)
		SimcCopyFrame:Hide()
	end)
	SimcCopyFrameButton:SetScript("OnClick", function(self)
		SimcCopyFrame:Hide()
	end)
end

function pants:generate_bag_item_from_info(item)
	-- this is kinda disgusting but it works without the need to copy local simc functions into here
	if not Simulationcraft then return '' end
    local link=item.itemLink
    Simulationcraft:HandleChatCommand(link)

    local s=SimcCopyFrameScrollText:GetText(nil,true)
    SimcCopyFrame:Hide()

    i,_=string.find(s,'### Linked gear')
    subs=s:sub(i)
    return subs or ''
end

function pants:simc_slash_itemlink(item)
	if not item then return end
	if not Simulationcraft then self:send_user_message('no_simc'); return  end
	Simulationcraft:HandleChatCommand(item)
end