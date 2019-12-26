local purps=PurpsAddon
local interface=purps.interface

local gui = LibStub("AceGUI-3.0")
local AceConfig=LibStub("AceConfig-3.0")

local args=purps.optionsTable.args.raid_leader.args

args["title"]={
    type="description",
    fontSize="large",
    order=11,
    width='full',
    name="Council members"
}

args["council_1"]={
    type="input",
    order=12,
    name="1",
    set=function(self,name)
            if not name then return end
            purps.para.rl_paras.council[1]=name
            purps:send_rl_paras()
        end,
    get=function(self) 
            return purps.para.rl_paras.council[1]
        end,
}  

args["council_2"]={
    type="input",
    order=13,
    name="2",
    set=function(self,name)
            if not name then return end
            purps.para.rl_paras.council[2]=name
            purps:send_rl_paras()
        end,
    get=function(self) 
            return purps.para.rl_paras.council[2]
        end,
}

args["council_3"]={
    type="input",
    order=14,
    name="3",
    set=function(self,name)
            if not name then return end
            purps.para.rl_paras.council[3]=name
            purps:send_rl_paras()
        end,
    get=function(self) 
            return purps.para.rl_paras.council[3]
        end,
}  


args["council_4"]={
    type="input",
    order=15,
    name="4",
    set=function(self,name)
            if not name then return end
            purps.para.rl_paras.council[4]=name
            purps:send_rl_paras()
        end,
    get=function(self) 
            return purps.para.rl_paras.council[4]
        end,
}  

args["council_5"]={
    type="input",
    order=16,
    name="5",
    set=function(self,name)
            if not name then return end
            purps.para.rl_paras.council[5]=name
            purps:send_rl_paras()
        end,
    get=function(self) 
            return purps.para.rl_paras.council[5]
        end,
}  

args["council_6"]={
    type="input",
    order=17,
    name="6",
    set=function(self,name)
            if not name then return end
            purps.para.rl_paras.council[6]=name
            purps:send_rl_paras()
        end,
    get=function(self) 
            return purps.para.rl_paras.council[6]
        end,
}  

args["council_7"]={
    type="input",
    order=18,
    name="7",
    set=function(self,name)
            if not name then return end
            purps.para.rl_paras.council[7]=name
            purps:send_rl_paras()
        end,
    get=function(self) 
            return purps.para.rl_paras.council[7]
        end,
}  

args["council_8"]={
    type="input",
    order=19,
    name="8",
    set=function(self,name)
            if not name then return end
            purps.para.rl_paras.council[8]=name
            purps:send_rl_paras()
        end,
    get=function(self) 
            return purps.para.rl_paras.council[8]
        end,
}  


args["council_9"]={
    type="input",
    order=20,
    name="9",
    set=function(self,name)
            if not name then return end
            purps.para.rl_paras.council[9]=name
            purps:send_rl_paras()
        end,
    get=function(self) 
            return purps.para.rl_paras.council[9]
        end,
}  