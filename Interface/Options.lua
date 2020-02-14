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

args["go_next_prot"]={
    type="toggle",
    order=13,
    name="Next item",
    desc='When active, automatically goes to the next item in the list (for which you can roll) when responding',
    set=function(self,value)
            pants.para.go_next=value

        end,
    get=function(self) 
            return pants.para.go_next
        end,
}  

args["archive_prot"]={
    type="toggle",
    order=14,
    name="Session archive",
    desc='When active, saves all sessions in the archive to be re-opened using /pants history',
    set=function(self,value)
            pants.para.session_archive=value

        end,
    get=function(self) 
            return pants.para.session_archive
        end,
}  

args["copy_note_link_prot"]={
    type="toggle",
    order=15,
    name="Note links",
    desc='When active, clicking on a note will open a frame containing the first link found (for easy copy pasting)',
    set=function(self,value)
            pants.para.copy_note_link=value

        end,
    get=function(self) 
            return pants.para.copy_note_link
        end,
}  


args["reopen_on_add_prot"]={
    type="toggle",
    order=16,
    name="Reopen on add",
    desc='When active, reopen the pants window when items are added to an active session',
    set=function(self,value)
            pants.para.reopen_on_add=value

        end,
    get=function(self) 
            return pants.para.reopen_on_add
        end,
}  


args["announce_on_add_prot"]={
    type="toggle",
    order=17,
    name="Announce on add",
    desc='When active, announce items when added to an active session',
    set=function(self,value)
            pants.para.announce_on_add=value

        end,
    get=function(self) 
            return pants.para.announce_on_add
        end,
}  

args["ilvl_difference_prot"]={
    type="toggle",
    order=17,
    name="iLvl difference",
    desc='When active, show the ilvl difference in the response table',
    set=function(self,value)
            pants.para.ilvl_difference=value

        end,
    get=function(self) 
            return pants.para.ilvl_difference
        end,
}  


args["minimap_icon_prot"]={
    type="toggle",
    order=17,
    name="Minimap icon",
    desc='Toggle the minimap icon |cffccff00(requires reload)|r',
    set=function(self,value)
            pants.para.minimap.hide=not value

        end,
    get=function(self) 
            return not pants.para.minimap.hide
        end,
}  