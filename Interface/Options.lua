local pants=PantsAddon

local interface=pants.interface
local gui = LibStub("AceGUI-3.0")
local AceConfig=LibStub("AceConfig-3.0")
local AceConfigDialog=LibStub("AceConfigDialog-3.0")


pants.optionsTable = {
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

AceConfig:RegisterOptionsTable('pants',pants.optionsTable)
AceConfigDialog:AddToBlizOptions('pants','pants')