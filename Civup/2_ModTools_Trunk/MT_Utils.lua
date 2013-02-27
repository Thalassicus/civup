-- TU-Utils
-- Author: Thalassicus
-- DateCreated: 2/29/2012 7:40:23 AM
--------------------------------------------------------------

include("MT_LuaLogger.lua")
local log = Events.LuaLogger:New()
log:SetLevel("WARN")



------------------------------------------------------------------
-- Game.CivupSaveGame(fileName)
-- Game.CivupLoadGame()
-- Fixes a bug causing defense buildings to not update city max health upon game load.
--
MapModData.Civup.DefenseBuildingsReal = MapModData.Civup.DefenseBuildingsReal or {}
MapModData.Civup.DefenseBuildingsFree = MapModData.Civup.DefenseBuildingsFree or {}

function Game.CivupSaveGame(fileName)
	for playerID, player in pairs(Players) do
		for city in player:Cities() do
			local cityID = City_GetID(city)
			if not MapModData.Civup.DefenseBuildingsReal[cityID] then MapModData.Civup.DefenseBuildingsReal[cityID] = {} end
			for buildingInfo in GameInfo.Buildings("ExtraCityHitPoints <> 0") do
				local numBuilding = city:GetNumRealBuilding(buildingInfo.ID)
				if MapModData.Civup.DefenseBuildingsReal[cityID][buildingInfo.ID] ~= numBuilding then
					MapModData.Civup.DefenseBuildingsReal[cityID][buildingInfo.ID] = numBuilding
					SaveValue(numBuilding, "MapModData.Civup.DefenseBuildingsReal[%s][%s]", cityID, buildingInfo.ID)
					--log:Info("Save %s %s", city:GetName(), buildingInfo.Type)
				end
				city:SetNumRealBuilding(buildingInfo.ID, 0)
				
				-- city:SetNumFreeBuilding core function not pushed to lua?!
				--MapModData.Civup.DefenseBuildingsFree[cityID][buildingInfo.ID] = city:GetNumFreeBuilding(buildingInfo.ID)
				--SaveValue(MapModData.Civup.DefenseBuildingsFree[cityID][buildingInfo.ID], "MapModData.Civup.DefenseBuildingsFree[%s][%s]", cityID, buildingInfo.ID)
				--city:SetNumFreeBuilding(buildingInfo.ID, 0)
			end			
		end
	end

	UI.SaveGame(fileName)

	for playerID, player in pairs(Players) do
		for city in player:Cities() do
			local cityID = City_GetID(city)
			for buildingInfo in GameInfo.Buildings("ExtraCityHitPoints <> 0") do
				city:SetNumRealBuilding(buildingInfo.ID, MapModData.Civup.DefenseBuildingsReal[cityID][buildingInfo.ID])
				--city:SetNumFreeBuilding(buildingInfo.ID, MapModData.Civup.DefenseBuildingsFree[cityID][buildingInfo.ID])
			end			
		end
	end
end

function Game.CivupLoadGame()
	for playerID, player in pairs(Players) do
		for city in player:Cities() do
			local cityID = City_GetID(city)
			if not MapModData.Civup.DefenseBuildingsReal[cityID] then MapModData.Civup.DefenseBuildingsReal[cityID] = {} end
			for buildingInfo in GameInfo.Buildings("ExtraCityHitPoints <> 0") do
				local numBuilding = LoadValue("MapModData.Civup.DefenseBuildingsReal[%s][%s]", cityID, buildingInfo.ID) or 0
				MapModData.Civup.DefenseBuildingsReal[cityID][buildingInfo.ID] = numBuilding
				city:SetNumRealBuilding(buildingInfo.ID, numBuilding)
				--city:SetNumFreeBuilding(buildingInfo.ID, LoadValue("MapModData.Civup.DefenseBuildingsFree[%s][%s]", cityID, buildingInfo.ID) or 0)
			end
		end
	end
end
----------------------------------------------------------------
--[[ Init(string) usage example:
Game.DoOnce("TurnAcquired") and LuaEvents.MT_Initialize.Add(InitTurnAcquired)
]]
function Game.DoOnce(str)
	if not MapModData.Civup[str] then
		MapModData.Civup[str] = true
		return true
	end
	return false
end

----------------------------------------------------------------
--[[ Game.DeepCopy(object) usage example: copies all elements of a table
table1 = Game.DeepCopy(table2)
]]
function Game.DeepCopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

----------------------------------------------------------------
--[[ Game.Literalize(str) usage example: gets rid of newline at the start of a string
strText = string.gsub(strText, "^"..Game.Literalize("[NEWLINE]"), "")
]]
function Game.Literalize(str)
	return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", function(c) return "%" .. c end)
end

----------------------------------------------------------------
--[[ Game.GetTruthTableResult(inputs, truthTable) usage example:
showYieldString = {
--   show { base, surplus} if Consumed YieldMod SurplusMod
		  { false, false}, --    -        -         -     
		  {  true, false}, --    -        -     SurplusMod
		  {  true, false}, --    -     YieldMod     -     
		  {  true,  true}, --    -     YieldMod SurplusMod
		  { false,  true}, -- Consumed    -         -     
		  { false,  true}, -- Consumed    -     SurplusMod
		  {  true,  true}, -- Consumed YieldMod     -     
		  {  true,  true}  -- Consumed YieldMod SurplusMod
}

local truthiness = Game.GetTruthTableResult(showYieldString, {isConsumed, hasYieldMod, hasSurplusMod})
local showBaseYield = truthiness[1]
local showSurplusYield = truthiness[2]
]]
function Game.GetTruthTableResult(truthTable, inputs)
	local index = 0

	for k,v in ipairs(inputs) do
		if v then
			index = index + math.pow(2, #inputs-k)
		end
	end
	return truthTable[index + 1]
end

----------------------------------------------------------------
--[[ Game.IsBetween(lower, mid, upper) usage example:
if Game.IsBetween(0, x, 5) then
]]
function Game.IsBetween(lower, mid, upper)
	return ((lower <= mid) and (mid <= upper))
end

----------------------------------------------------------------
--[[ Game.Constrain(lower, mid, upper) usage example:
local healthPercent = Game.Constrain(0, pUnit:GetCurrHitPoints() / pUnit:GetMaxHitPoints(), 1)
]]
function Game.Constrain(lower, mid, upper)
	return math.max(lower, math.min(mid, upper))
end

----------------------------------------------------------------
-- Game.GetFlavors(itemTable, itemColumn, itemType, minVal, skipHeader)
--
local flavorColors = {
	[128] = "[COLOR_PLAYER_ORANGE_TEXT]",
	[64] = "[COLOR:255:60:255:255]",
	[32] = "[COLOR_RESEARCH_STORED]",
	[16]  = "[COLOR_PLAYER_LIGHT_GREEN]",
	[8]  = "",
	[4]  = "[COLOR_GREY]"
}
function Game.GetFlavorColor(flavor)
	return flavorColors[Game.Constrain(4, Game.RoundToPowerOf2(flavor), 128)] or "[COLOR_WHITE]"
end
function Game.GetFlavors(itemTable, itemColumn, itemType, minVal, skipHeader)
	local flavors = {}
	local showBasicHelp = not OptionsManager.IsNoBasicHelp()

	if Civup.SHOW_GOOD_FOR_RAW_NUMBERS == 1 then
		minVal = 1
	else
		minVal = minVal or 1
	end	

	if not itemTable or not itemColumn or not itemType then
		log:Fatal("Game.GetFlavors: itemTable=%s itemColumn=%s itemType=%s", itemTable, itemColumn, itemType)
	end
	for flavorInfo in GameInfo[itemTable](string.format("%s = '%s'", itemColumn, itemType)) do
		if not flavorInfo.FlavorType then
			log:Error("Game.GetFlavors: itemTable=%s itemColumn=%s itemType=%s FlavorType=%s", itemTable, itemColumn, itemType, flavorInfo.FlavorType)
		else
			local description = GameInfo.Flavors[flavorInfo.FlavorType].Description
			if description then
				description = Locale.ConvertTextKey(description)
			else
				log:Warn("Game.GetFlavors: %s has no description!", flavorInfo.FlavorType)
				description = "NO DESCRIPTION"
			end		
			if flavorInfo.Flavor >= minVal then
				table.insert(flavors, {
					FlavorType	= flavorInfo.FlavorType,
					FlavorName	= description,
					Flavor		= math.max(1, Game.Round(flavorInfo.Flavor))
				})
			end
		end
	end

	if #flavors == 0 then
		return ""
	end
	
	table.sort(flavors, function (a,b)
		if a.Flavor ~= b.Flavor then
			return a.Flavor > b.Flavor
		end
		return a.FlavorName < b.FlavorName
	end)
	
	local helpText = skipHeader and "" or string.format("[NEWLINE]%s", Locale.ConvertTextKey("TXT_KEY_TOOLTIP_GOOD_FOR"))
	local firstLine = true

	for k, v in ipairs(flavors) do
		local flavorInfo = GameInfo.Flavors[v.FlavorType]
		helpText = string.format(
			"%s[NEWLINE]%s%s %s[ENDCOLOR]",
			helpText,
			(Civup.SHOW_GOOD_FOR_RAW_NUMBERS == 1) and (v.Flavor.." ") or Game.GetFlavorColor(v.Flavor),
			flavorInfo.IconString or "[ICON_HAPPINESS_2]",
			v.FlavorName
		);
	end
	return helpText
end

----------------------------------------------------------------
--[[ Game.Round(num, idp) usage example:
local iFoodPerTurn = Game.Round(City_GetYieldRateTimes100(city, YieldTypes.YIELD_FOOD)/100, 1)
]]
function Game.Round(num, places)
	local mult = 10^(places or 0)
	return math.floor(num * mult + 0.5) / mult
end

----------------------------------------------------------------
--[[ Game.RoundDown(num, idp) usage example:
costMultiplier = Game.RoundDown(costMultiplier, -1) / baseCost * 100
]]
function Game.RoundDown(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.0) / mult
end

----------------------------------------------------------------
-- Game.RoundToPowerOf2(num)
--
function Game.RoundToPowerOf2(num)
	return 2 ^ Game.Round(math.log(num)/math.log(2))
end

----------------------------------------------------------------
--[[ Game.Shuffle(t) usage example:

for index, plot in Plots(Game.Shuffle) do
	if ( not plot:IsWater() ) then
					
		-- Prevents too many goodies from clustering on any one landmass.
		local area = plot:Area()
		local improvementCount = area:GetNumImprovements(improvementID)
		local scaler = (area:GetNumTiles() + (tilesPerGoody/2))/tilesPerGoody	
		if (improvementCount < scaler) then
						
			if (CanPlaceGoodyAt(improvement, plot)) then
				plot:SetImprovementType(improvementID)
			end
		end
	end
end
]]
function Game.Shuffle(t)
	local first = t[0] and 0 or 1
	local last = #t
	for i = first, last do
		local k = Map.Rand(last - 1, "Shuffling Values") + 1
		t[i], t[k] = t[k], t[i]
	end
	return t
end

----------------------------------------------------------------
-- Game.Reverse(list)
--
function Game.Reverse(t)
	local first = t[0] and 0 or 1
	local last = math.floor((#t + first)/2)
	for i = first, last do
		t[i], t[last-i] = t[last-i], t[i]
	end
	return t
end

------------------------------------------------------------------
--[[ Game.Contains(list, value) checks if a table contains a value
if Game.Contains(myTable, 1) then
	-- do stuff
end
]]
function Game.Contains(list, value)
	for k, v in pairs(list) do
		if v == value then
			return true
		end
	end
	return false
end

------------------------------------------------------------------
-- Game.GetMaximum(table) returns maximum item from a list
--
function Game.GetMaximum(list)
	local maxIndex = -1
	local maxValue = -math.huge
	for index, value in pairs(list) do
		if value > maxValue then
			maxIndex = index
			maxValue = value
		elseif value == maxValue and 1 == Map.Rand(2, "Game.GetMaximum") then
			maxIndex = index
			maxValue = value
		end
	end
	return maxIndex, maxValue
end

------------------------------------------------------------------
-- Game.GetRandomWeighted(list, size) returns an item from a list of weighted probabilities
--
function Game.GetRandomWeighted(list, size)
	size = size or 100
	local chanceIDs = Game.GetWeightedTable(list, size)

	if chanceIDs == -1 then
		return -1
	end
	local randomID = 1 + Map.Rand(size, "Game.GetRandomWeighted")
	if not chanceIDs[randomID] then
		log:Warn("Game.GetrandomIDWeighted: invalid random index selected = %s", randomID)
		chanceIDs[randomID] = -1
	end
	return chanceIDs[randomID]
end

------------------------------------------------------------------
-- Game.GetWeightedTable(list, size) returns a table with key blocks sized proportionately to a weighted list
--
function Game.GetWeightedTable(list, size)
	local totalWeight	= 0
	local chanceIDs		= {}
	local position		= 1
	
	for key, weight in pairs(list) do
		totalWeight = totalWeight + weight
	end
	
	if totalWeight == 0 then
		for key, weight in pairs(list) do
			list[key] = 1
			totalWeight = totalWeight + 1
		end
		if totalWeight == 0 then
			log:Debug("Game.GetWeightedTable: empty list")
			--print(debug.traceback())
			return -1
		end
	end
	
	for key, weight in pairs(list) do
		local positionNext = position + size * weight / totalWeight
		--log:Debug("%25s weight=%-4s totalWeight=%-4s position=%-3s positionNext=%-3s size=%-3s", key, Game.Round(weight), Game.Round(totalWeight), Game.Round(position), Game.Round(positionNext), size)
		for i = math.floor(position), math.floor(positionNext) do
			chanceIDs[i] = key
		end
		position = positionNext
	end	
	return chanceIDs
end

------------------------------------------------------------------
-- Game.RemoveExtraNewlines(str) returns a string with extraneous newlines removed from the start and end.
--
function Game.RemoveExtraNewlines(str)
	local newline = Game.Literalize("[NEWLINE]")
	for i=1, 10 do
		if string.find(str, "^"..newline) then
			str = string.gsub(str, "^"..newline, "")
		else
			break
		end
	end
	for i=1, 10 do
		if string.find(str, newline.."$") then
			str = string.gsub(str, newline.."$", "")
		else
			break
		end
	end
	return str
end