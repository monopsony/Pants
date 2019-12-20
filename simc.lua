local purps=PurpsAddon

purps.simc_strings={
}
--setmetatable( purps.simc_strings, {__index=function(self,index) return '' end} )

local Simulationcraft=LibStub.libs["AceAddon-3.0"]:GetAddon("Simulationcraft")


function purps:generate_simc_string()
    if not Simulationcraft then return end
    Simulationcraft:PrintSimcProfile(false,true)
    local s=SimcCopyFrameScrollText:GetText(nil,true)
    SimcCopyFrame:Hide()
    return s 
end

function purps:send_simc_string()
    local Simulationcraft=self:generate_simc_string()
    local s=self:compress_encode(Simulationcraft)
    self:send_raid_comm("PurpsSimc",s)
end

function purps:save_simc_string(sender,data)
	local name=self:convert_to_full_name(sender)
	self.simc_strings[name]=data
end

function purps:show_simc_output(out)
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

function purps:generate_bag_item_from_info(...)
    return
end

purps.simc_bag_header=[[
### Gear from Bags
#
]]

--[[
DISCLAIMER:
This file almost entirely consists of an edited copy of select functions from the Simulationcraft addon. 
All credit goes to the author(s) of said addon: 
  https://wow.curseforge.com/projects/simulationcraft
  https://github.com/simulationcraft/simc-addon
]]

if not Simulationcraft then return end 

local OFFSET_ITEM_ID = 1
local OFFSET_ENCHANT_ID = 2
local OFFSET_GEM_ID_1 = 3
local OFFSET_GEM_ID_2 = 4
local OFFSET_GEM_ID_3 = 5
local OFFSET_GEM_ID_4 = 6
local OFFSET_GEM_BASE = OFFSET_GEM_ID_1
local OFFSET_SUFFIX_ID = 7
local OFFSET_FLAGS = 11
local OFFSET_CONTEXT = 12
local OFFSET_BONUS_ID = 13
local OFFSET_UPGRADE_ID = 14 -- Flags = 0x4

local SocketInventoryItem   = _G.SocketInventoryItem
local Timer                 = _G.C_Timer
local AzeriteEmpoweredItem  = _G.C_AzeriteEmpoweredItem
local AzeriteItem           = _G.C_AzeriteItem
local AzeriteEssence        = _G.C_AzeriteEssence

-- load stuff from extras.lua 
local upgradeTable        = Simulationcraft.upgradeTable
local slotNames           = Simulationcraft.slotNames
local simcSlotNames       = Simulationcraft.simcSlotNames
local specNames           = Simulationcraft.SpecNames
local profNames           = Simulationcraft.ProfNames
local regionString        = Simulationcraft.RegionString
local zandalariLoaBuffs   = Simulationcraft.zandalariLoaBuffs
local essenceMinorSlots   = Simulationcraft.azeriteEssenceSlotsMinor
local essenceMajorSlots   = Simulationcraft.azeriteEssenceSlotsMajor

local function GetItemSplit(itemLink)
  local itemString = string.match(itemLink, "item:([%-?%d:]+)")
  local itemSplit = {}

  -- Split data into a table
  for _, v in ipairs({strsplit(":", itemString)}) do
    if v == "" then
      itemSplit[#itemSplit + 1] = 0
    else
      itemSplit[#itemSplit + 1] = tonumber(v)
    end
  end

  return itemSplit
end

local function GetGemItemID(itemLink, index)
  local _, gemLink = GetItemGem(itemLink, index)
  if gemLink ~= nil then
    local itemIdStr = string.match(gemLink, "item:(%d+)")
    if itemIdStr ~= nil then
      return tonumber(itemIdStr)
    end
  end

  return 0
end

local function GetGemBonuses(itemLink, index)
  local bonuses = {}
  local _, gemLink = GetItemGem(itemLink, index)
  if gemLink ~= nil then
    local gemSplit = GetItemSplit(gemLink)
    for index=1, gemSplit[OFFSET_BONUS_ID] do
      bonuses[#bonuses + 1] = gemSplit[OFFSET_BONUS_ID + index]
    end
  end

  if #bonuses > 0 then
    return table.concat(bonuses, ':')
  end

  return 0
end

local function GetItemStringFromItemLink(slotNum, itemLink, itemLoc, debugOutput)
  local itemSplit = GetItemSplit(itemLink)
  local simcItemOptions = {}
  local gems = {}
  local gemBonuses = {}

  -- Item id
  local itemId = itemSplit[OFFSET_ITEM_ID]
  simcItemOptions[#simcItemOptions + 1] = ',id=' .. itemId

  -- Enchant
  if itemSplit[OFFSET_ENCHANT_ID] > 0 then
    simcItemOptions[#simcItemOptions + 1] = 'enchant_id=' .. itemSplit[OFFSET_ENCHANT_ID]
  end

  -- Gems
  for gemOffset = OFFSET_GEM_ID_1, OFFSET_GEM_ID_4 do
    local gemIndex = (gemOffset - OFFSET_GEM_BASE) + 1
    if itemSplit[gemOffset] > 0 then
      local gemId = GetGemItemID(itemLink, gemIndex)
      if gemId > 0 then
        gems[gemIndex] = gemId
        gemBonuses[gemIndex] = GetGemBonuses(itemLink, gemIndex)
      end
    else
      gems[gemIndex] = 0
      gemBonuses[gemIndex] = 0
    end
  end

  -- Remove any trailing zeros from the gems array
  while #gems > 0 and gems[#gems] == 0 do
    table.remove(gems, #gems)
  end
  -- Remove any trailing zeros from the gem bonuses
  while #gemBonuses > 0 and gemBonuses[#gemBonuses] == 0 do
    table.remove(gemBonuses, #gemBonuses)
  end

  if #gems > 0 then
    simcItemOptions[#simcItemOptions + 1] = 'gem_id=' .. table.concat(gems, '/')
    if #gemBonuses > 0 then
      simcItemOptions[#simcItemOptions + 1] = 'gem_bonus_id=' .. table.concat(gemBonuses, '/')
    end
  end

  -- New style item suffix, old suffix style not supported
  if itemSplit[OFFSET_SUFFIX_ID] ~= 0 then
    simcItemOptions[#simcItemOptions + 1] = 'suffix=' .. itemSplit[OFFSET_SUFFIX_ID]
  end

  local flags = itemSplit[OFFSET_FLAGS]

  local bonuses = {}

  for index=1, itemSplit[OFFSET_BONUS_ID] do
    bonuses[#bonuses + 1] = itemSplit[OFFSET_BONUS_ID + index]
  end

  if #bonuses > 0 then
    simcItemOptions[#simcItemOptions + 1] = 'bonus_id=' .. table.concat(bonuses, '/')
  end

  local linkOffset = OFFSET_BONUS_ID + #bonuses + 1

  -- Upgrade level
  if bit.band(flags, 0x4) == 0x4 then
    local upgradeId = itemSplit[linkOffset]
    if upgradeTable and upgradeTable[upgradeId] ~= nil and upgradeTable[upgradeId] > 0 then
      simcItemOptions[#simcItemOptions + 1] = 'upgrade=' .. upgradeTable[upgradeId]
    end
    linkOffset = linkOffset + 1
  end

  -- Some leveling quest items seem to use this, it'll include the drop level of the item
  if bit.band(flags, 0x200) == 0x200 then
    simcItemOptions[#simcItemOptions + 1] = 'drop_level=' .. itemSplit[linkOffset]
    linkOffset = linkOffset + 1
  end

  -- Get item creation context. Can be used to determine unlock/availability of azerite tiers for 3rd parties
  if itemSplit[OFFSET_CONTEXT] ~= 0 then
    simcItemOptions[#simcItemOptions + 1] = 'context=' .. itemSplit[OFFSET_CONTEXT]
  end

  -- Azerite powers - only run in BfA client
  if itemLoc and AzeriteEmpoweredItem then
    if AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLoc) then
      -- C_AzeriteEmpoweredItem.GetAllTierInfo(ItemLocation:CreateFromEquipmentSlot(5))
      -- C_AzeriteEmpoweredItem.GetPowerInfo(ItemLocation:CreateFromEquipmentSlot(5), 111)
      local azeritePowers = {}
      local powerIndex = 1
      local tierInfo = AzeriteEmpoweredItem.GetAllTierInfo(itemLoc)
      for azeriteTier, tierInfo in pairs(tierInfo) do
        for _, powerId in pairs(tierInfo.azeritePowerIDs) do
          if AzeriteEmpoweredItem.IsPowerSelected(itemLoc, powerId) then
            azeritePowers[powerIndex] = powerId
            powerIndex = powerIndex + 1
          end
        end
      end
      simcItemOptions[#simcItemOptions + 1] = 'azerite_powers=' .. table.concat(azeritePowers, '/')
    end
    if AzeriteItem.IsAzeriteItem(itemLoc) then
      simcItemOptions[#simcItemOptions + 1] = 'azerite_level=' .. AzeriteItem.GetPowerLevel(itemLoc)
    end
  end

  local itemStr = ''
  if debugOutput then
    itemStr = itemStr .. '# ' .. itemString .. '\n'
  end
  itemStr = itemStr .. simcSlotNames[slotNum] .. "=" .. table.concat(simcItemOptions, ',')

  return itemStr
end

slotNames = {
	"HeadSlot",
	"NeckSlot",
	"ShoulderSlot",
	"BackSlot",
	"ChestSlot",
	"ShirtSlot",
	"TabardSlot",
	"WristSlot",
	"HandsSlot",
	"WaistSlot",
	"LegsSlot",
	"FeetSlot",
	"Finger0Slot",
	"Finger1Slot",
	"Trinket0Slot",
	"Trinket1Slot",
	"MainHandSlot",
	"SecondaryHandSlot",
	"AmmoSlot"}

slotNamesInverse={}
for i=1,#slotNames do
  slotNamesInverse[slotNames[i]]=i
end  
slotNamesInverse["Two-HandSlot"]=slotNamesInverse["MainHandSlot"]

function purps:generate_bag_item_from_info(item)
    local link=item.itemLink
    local itemName,_,_,itemLevel=GetItemInfo(link)
    local header=string.format("# %s (%s)",itemName,itemLevel)
    local loc=_G[item.itemEquipLoc]
    if not loc then return 

    else
      if loc=="Finger" or loc=="Trinket" then loc=loc.."0Slot" else loc=loc.."Slot" end
      local loc2=slotNamesInverse[loc]
      if not loc2 then return 'None'
      else
        local itemString=GetItemStringFromItemLink(loc2,link)
        local simstring=string.format("#\n%s\n# %s\n",header,itemString)
        return simstring 
      end --end of if not loc2 
    end --end of if not loc
end


