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


