local purps=PurpsAddon

local interface=purps.interface
local gui = LibStub("AceGUI-3.0")
local AceConfig=LibStub("AceConfig-3.0")
local AceConfigDialog=LibStub("AceConfigDialog-3.0")


purps.optionsTable = {
	type='group',
	childGroups='tab',
	args={

		raid_leader={
			name='Raid leader',
			type='group',
			args={},
		},

		master_looter={
			name='Master looter',
			type='group',
			args={},
		},

	}
}

AceConfig:RegisterOptionsTable('Purps',purps.optionsTable)
AceConfigDialog:AddToBlizOptions('Purps','Purps')