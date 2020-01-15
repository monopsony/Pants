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

		personal={
			name='Personal',
			type='group',
			args={},
		},		

	}
}

AceConfig:RegisterOptionsTable('Pants',pants.optionsTable)
AceConfigDialog:AddToBlizOptions('Pants','Pants')

local args=pants.optionsTable.args.personal.args

args["follow_unit_prot"]={
    type="toggle",
    order=12,
    name="Quick follow",
    desc='When active, automatically follows relevant people for quick actions (e.g. trading to the ML)',
    set=function(self,value)
            pants.para.quick_follow=value

        end,
    get=function(self) 
            return pants.para.quick_follow
        end,
}  