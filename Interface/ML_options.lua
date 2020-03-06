local pants=PantsAddon

local interface=pants.interface

local args=pants.optionsTable.args.master_looter.args

args["announce_winner_prot"]={
    type="toggle",
    order=12,
    name="Announce winner",
    desc='When active, automatically announces winners (if you are the ML)',
    set=function(self,value)
        pants.para.announce_winner=value
    end,
    
    get=function(self) 
        return pants.para.announce_winner
    end,
}