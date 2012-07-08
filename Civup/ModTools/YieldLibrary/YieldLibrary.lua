-- YieldLibrary
-- Author: Thalassicus
-- DateCreated: 5/4/2011 10:43:09 AM
--------------------------------------------------------------

include("ModTools.lua")

if Game == nil or IncludedYieldLibrary then
	return
end

IncludedYieldLibrary = true

local log = Events.LuaLogger:New()
log:SetLevel("INFO")

PlayerClass	= getmetatable(Players[0]).__index
--PlotClass	= getmetatable(Map.GetPlotByIndex(0)).__index

MapModData.VEM						= MapModData.VEM					or {}
MapModData.VEM.AvoidModifier		= MapModData.VEM.AvoidModifier		or {}
MapModData.VEM.CityWeights			= MapModData.VEM.CityWeights		or {}
MapModData.VEM.MinorCivRewards		= MapModData.VEM.MinorCivRewards	or {}
MapModData.VEM.PlayerCityIDs		= MapModData.VEM.PlayerCityIDs		or {}
MapModData.VEM.PlayerCityWeights	= MapModData.VEM.PlayerCityWeights	or {}
MapModData.VEM.UnitSupplyCurrent	= MapModData.VEM.UnitSupplyCurrent	or {}
MapModData.VEM.UnitSupplyMax		= MapModData.VEM.UnitSupplyMax		or {}

doUpdate = false

YieldTypes.YIELD_FOOD				= YieldTypes.YIELD_FOOD
YieldTypes.YIELD_PRODUCTION			= YieldTypes.YIELD_PRODUCTION
YieldTypes.YIELD_GOLD				= YieldTypes.YIELD_GOLD
YieldTypes.YIELD_SCIENCE			= YieldTypes.YIELD_SCIENCE
YieldTypes.YIELD_CULTURE			= GameInfo.Yields.YIELD_CULTURE.ID
YieldTypes.YIELD_HAPPINESS			= GameInfo.Yields.YIELD_HAPPINESS.ID
YieldTypes.YIELD_GREAT_PEOPLE		= GameInfo.Yields.YIELD_GREAT_PEOPLE.ID
YieldTypes.YIELD_EXPERIENCE			= GameInfo.Yields.YIELD_EXPERIENCE.ID
YieldTypes.YIELD_LAW				= GameInfo.Yields.YIELD_LAW.ID
YieldTypes.YIELD_CS_MILITARY		= GameInfo.Yields.YIELD_CS_MILITARY.ID
YieldTypes.YIELD_CS_GREAT_PEOPLE	= GameInfo.Yields.YIELD_CS_GREAT_PEOPLE.ID
YieldTypes.YIELD_POPULATION			= GameInfo.Yields.YIELD_POPULATION.ID

CityYieldFocusTypes = {}
CityYieldFocusTypes[YieldTypes.YIELD_FOOD]				= CityAIFocusTypes.CITY_AI_FOCUS_TYPE_FOOD
CityYieldFocusTypes[YieldTypes.YIELD_PRODUCTION]		= CityAIFocusTypes.CITY_AI_FOCUS_TYPE_PRODUCTION
CityYieldFocusTypes[YieldTypes.YIELD_GOLD]				= CityAIFocusTypes.CITY_AI_FOCUS_TYPE_GOLD
CityYieldFocusTypes[YieldTypes.YIELD_SCIENCE]			= CityAIFocusTypes.CITY_AI_FOCUS_TYPE_SCIENCE
CityYieldFocusTypes[YieldTypes.YIELD_CULTURE]			= CityAIFocusTypes.CITY_AI_FOCUS_TYPE_CULTURE
CityYieldFocusTypes[YieldTypes.YIELD_HAPPINESS]			= -2
CityYieldFocusTypes[YieldTypes.YIELD_GREAT_PEOPLE]		= CityAIFocusTypes.CITY_AI_FOCUS_TYPE_GREAT_PERSON
CityYieldFocusTypes[YieldTypes.YIELD_EXPERIENCE]		= -2
CityYieldFocusTypes[YieldTypes.YIELD_LAW]				= -2
CityYieldFocusTypes[YieldTypes.YIELD_CS_MILITARY]		= -2
CityYieldFocusTypes[YieldTypes.YIELD_CS_GREAT_PEOPLE]	= -2
CityYieldFocusTypes[YieldTypes.YIELD_POPULATION]		= -2

local tileYieldTypes = {
	YieldTypes.YIELD_FOOD,
	YieldTypes.YIELD_PRODUCTION,
	YieldTypes.YIELD_GOLD,
	YieldTypes.YIELD_SCIENCE,
	YieldTypes.YIELD_CULTURE,
	YieldTypes.YIELD_FAITH,
	YieldTypes.YIELD_HAPPINESS
}

---------------------------------------------------------------------
-- Base Cost
---------------------------------------------------------------------

function City_GetCostMod(city, yieldID, itemTable, itemID)
	local costMod = 1
	if itemTable == nil then
		if city:GetProductionUnit() ~= -1 then
			itemID = city:GetProductionUnit()
			itemTable = GameInfo.Units
		end
		if city:GetProductionBuilding() ~= -1 then
			itemID = city:GetProductionBuilding()
			itemTable = GameInfo.Buildings
		end
		if city:GetProductionProject() ~= -1 then
			itemID = city:GetProductionProject()
			itemTable = GameInfo.Projects
		end
	end
	if yieldID == YieldTypes.YIELD_PRODUCTION then
		if itemTable == GameInfo.Buildings and itemID then
			costMod = 1 + city:GetPopulation() * itemTable[itemID].PopCostMod / 100
		end
		-- add new cost modifier here
	end
	return costMod
end

---------------------------------------------------------------------
-- Base Yield
---------------------------------------------------------------------

function City_GetBaseYieldRate(city, yieldID, itemTable, itemID, queueNum)
	if city == nil then
		log:Fatal("City_GetBaseYieldRate city=nil")
	elseif itemTable and not itemID then
		log:Fatal("City_GetBaseYieldRate itemID=nil")
	end
	----log:Debug("City_GetBaseYieldRate %15s %15s", city:GetName(), GameInfo.Yields[yieldID].Type)
	local baseYield = 0
	--
	if yieldID == YieldTypes.YIELD_HAPPINESS then	
		for i = 0, city:GetNumCityPlots() - 1 do
			local plot = city:GetCityIndexPlot(i)
			if plot and city:IsWorkingPlot(plot) then
				baseYield = baseYield + Plot_GetYield(plot, yieldID)
			end
		end
	else
		baseYield = (
			  City_GetBaseYieldFromTerrain		(city, yieldID)
			+ City_GetBaseYieldFromReligion		(city, yieldID)
			+ City_GetBaseYieldFromProcesses	(city, yieldID)
			+ City_GetBaseYieldFromBuildings	(city, yieldID)
			+ City_GetBaseYieldFromPopulation	(city, yieldID)
			+ City_GetBaseYieldFromSpecialists	(city, yieldID)
			+ City_GetBaseYieldFromPolicies		(city, yieldID)
			+ City_GetBaseYieldFromTraits		(city, yieldID)
			+ City_GetBaseYieldFromMinorCivs	(city, yieldID)
		)
	end
	return baseYield
end

function Player_GetBuildingYield(player, buildingID, yieldID)
	local buildingInfo = GameInfo.Buildings[buildingID]
	local yield = 0
	if yieldID == nil then
		log:Fatal("Player_GetBuildingYield yieldID=nil")
	end
	if buildingID == nil then
		log:Fatal("Player_GetBuildingYield buildingID=nil")
	end
	if yieldID == YieldTypes.YIELD_HAPPINESS then 
		yield = yield + buildingInfo.UnmoddedHappiness
		yield = yield + player:GetExtraBuildingHappinessFromPolicies(buildingID)
	else
		yield = yield + Game.GetBuildingYieldChange(buildingID, yieldID)
	end

	local buildingClass = GameInfo.Buildings[buildingID].BuildingClass
	local query = string.format("BuildingClassType = '%s' AND YieldType = '%s'", buildingClass, GameInfo.Yields[yieldID].Type)
	for row in GameInfo.Policy_BuildingClassYieldChanges(query) do
		if player:HasPolicy(GameInfo.Policies[row.PolicyType].ID) then
			yield = yield + row.YieldChange
		end
	end
	return yield
end

function Player_GetBuildingYieldMod(player, buildingID, yieldID)
	local buildingInfo = GameInfo.Buildings[buildingID]
	local yield = 0
	local query = ""
	if yieldID == nil then
		log:Fatal("Player_GetBuildingYieldMod yieldID=nil")
	end
	if yieldID == YieldTypes.YIELD_CULTURE then
		yield = yield + buildingInfo.CultureRateModifier
		query = string.format("BuildingType = '%s' AND YieldType = '%s'", buildingInfo.Type, GameInfo.Yields[yieldID].Type)
		for row in GameInfo.Building_YieldModifiers(query) do
			yield = yield + row.Yield
		end
	--[[elseif yieldID == YieldTypes.YIELD_GOLD then
		query = string.format("BuildingType = '%s' AND YieldType = '%s'", buildingInfo.Type, GameInfo.Yields[yieldID].Type)
		for row in GameInfo.Building_YieldModifiers(query) do
			yield = yield + row.Yield
		end--]]
	else
		yield = yield + Game.GetBuildingYieldModifier(buildingID, yieldID)
	end

	query = string.format("BuildingClassType = '%s' AND YieldType = '%s'", buildingInfo.BuildingClass, GameInfo.Yields[yieldID].Type)
	for row in GameInfo.Policy_BuildingClassYieldModifiers(query) do
		if player:HasPolicy(GameInfo.Policies[row.PolicyType].ID) then
			--log:Trace("%30s %20s %5s", buildingInfo.BuildingClass, GameInfo.Yields[yieldID].Type, row.YieldMod)
			yield = yield + row.YieldMod
		end
	end
	return yield
end

function City_GetBaseYieldFromTerrain(city, yieldID)
	return city:GetBaseYieldRateFromTerrain(yieldID)
end

function City_GetBaseYieldFromReligion(city, yieldID)
	return city:GetBaseYieldRateFromReligion(yieldID)
end

function City_GetBaseYieldFromPopulation(city, yieldID)
	local yield = 0
	--yield = city:GetPopulation() * city:GetYieldPerPopTimes100(yieldID) / 100  -- returns incorrect values for science
	if yieldID == YieldTypes.YIELD_SCIENCE then
		yield = yield + city:GetPopulation() * GameDefines.SCIENCE_PER_POPULATION
	end
	for buildingInfo in GameInfo.Building_YieldChangesPerPop(string.format("YieldType = '%s'", GameInfo.Yields[yieldID].Type)) do
		if City_GetNumBuilding(city, buildingInfo.BuildingType) > 0 then
			yield = yield + buildingInfo.Yield * city:GetPopulation() / 100
		end
	end
	return yield
end

function City_GetBaseYieldFromProcesses(city, yieldID)
	local yield = 0
	if yieldID ~= YieldTypes.YIELD_PRODUCTION then
		local processID = city:GetProductionProcess()
		if processID ~= -1 then
			local processInfo = GameInfo.Processes[processID]
			local query = string.format("ProcessType = '%s' AND YieldType = '%s'", processInfo.Type, GameInfo.Yields[yieldID].Type)
			for row in GameInfo.Process_ProductionYields(query) do
				yield = yield + row.Yield / 100 * math.max(0, City_GetYieldRate(city, YieldTypes.YIELD_PRODUCTION))
			end
		end
	end
	return yield
end

function City_GetBaseYieldFromBuildings(city, yieldID)
	local yield = 0
	local player = Players[city:GetOwner()]
	for building in GameInfo.Buildings() do
		local numBuilding = City_GetNumBuilding(city, building.ID)
		if numBuilding > 0 and (building.Type ~= "BUILDING_EXTRA_HAPPINESS") then
			yield = yield + Player_GetBuildingYield(player, building.ID, yieldID) * numBuilding
		end
	end
	return yield
end

function City_GetBaseYieldModFromBuildings(city, yieldID)
	local yield = 0
	local player = Players[city:GetOwner()]
	for building in GameInfo.Buildings() do
		local numBuilding = City_GetNumBuilding(city, building.ID)
		if numBuilding > 0 then
			yield = yield + Player_GetBuildingYieldMod(player, building.ID, yieldID) * numBuilding
		end
	end
	return yield
end


function City_GetBaseYieldFromSpecialists(city, yieldID)
	local yield = 0
	local citizenID = GameDefines.DEFAULT_SPECIALIST
	for specialistInfo in GameInfo.Specialists() do
		yield = yield + city:GetSpecialistCount(specialistInfo.ID) * City_GetSpecialistYield(city, yieldID, specialistInfo.ID)
	end
	return yield
end

function City_GetBaseYieldFromPolicies(city, yieldID)
	local player = Players[city:GetOwner()]
	local query = ""
	local yield = 0
	if yieldID == YieldTypes.YIELD_CULTURE then
		yield = city:GetJONSCulturePerTurnFromPolicies()
	elseif yieldID == YieldTypes.YIELD_FOOD then
		--[[
		-- This goes directly to the base terrain and cannot be reported separately.
		if city:IsCapital() then			
			query = string.format("YieldType = '%s'", GameInfo.Yields[yieldID].Type)
			for row in GameInfo.Policy_CapitalYieldChanges(query) do
				if player:HasPolicy(GameInfo.Policies[row.PolicyType].ID) then
					yield = yield + row.Yield
				end
			end
		end 
		--]]
	end
	return yield
end


function City_GetBaseYieldFromTraits(city, yieldID)
	if yieldID == YieldTypes.YIELD_CULTURE then
		return city:GetJONSCulturePerTurnFromTraits()
	else
		return 0
	end
end

function City_GetBaseYieldFromMisc(city, yieldID)
	if yieldID == YieldTypes.YIELD_CULTURE or yieldID == YieldTypes.YIELD_SCIENCE then
		return 0
	else
		return city:GetBaseYieldRateFromMisc(yieldID)
	end
end


function City_GetBaseYieldFromMinorCivs(city, yieldID)
	local player = Players[city:GetOwner()]
	local yield = 0
	if player:IsMinorCiv() then
		return yield
	end
	if Civup.ENABLE_DISTRIBUTED_MINOR_CIV_YIELDS then
		yield = player:GetYieldsFromCitystates()[yieldID]
		if not yield then
			log:Fatal("player:GetYieldsFromCitystates %s %s is nil", player:GetName(), GameInfo.Yields[yieldID].Type)
		end
		if yield ~= 0 then
			yield = yield * City_GetWeight(city, yieldID) / player:GetTotalWeight(yieldID)
		end

		--[[
		for row in GameInfo.Policy_MinorCivBonuses(string.format("YieldType = '%s'", GameInfo.Yields[yieldID].Type)) do
			if player:HasPolicy(GameInfo.Policies[row.PolicyType].ID) then
				for minorCivID,minorCiv in pairs(Players) do
					if minorCiv:IsAliveCiv() and minorCiv:IsMinorCiv() then
						if row.FriendLevel == minorCiv:GetMinorCivFriendshipLevelWithMajor(player:GetID()) then
							yield = yield + row.Yield
						end
					end
				end
			end
		end
		--]]
	--[[
	-- This goes directly to the base terrain and cannot be reported separately.
	elseif yieldID == YieldTypes.YIELD_FOOD then
		local isRenaissance = (player:GetCurrentEra() >= GameInfo.Eras.ERA_RENAISSANCE.ID)
		local yieldLevel	= {}
		yieldLevel[-1]		= 0
		yieldLevel[0]		= 0
		yieldLevel[1]		= 0
		yieldLevel[2]		= 0
		if city:IsCapital() then
			if isRenaissance then
				yieldLevel[1] = GameDefines.FRIENDS_CAPITAL_FOOD_BONUS_AMOUNT_POST_RENAISSANCE
			else
				yieldLevel[1] = GameDefines.FRIENDS_CAPITAL_FOOD_BONUS_AMOUNT_PRE_RENAISSANCE
			end
			yieldLevel[2] = yieldLevel[1] + GameDefines.ALLIES_CAPITAL_FOOD_BONUS_AMOUNT
		else
			if isRenaissance then
				yieldLevel[1] = GameDefines.FRIENDS_OTHER_CITIES_FOOD_BONUS_AMOUNT_POST_RENAISSANCE
			else
				yieldLevel[1] = GameDefines.FRIENDS_OTHER_CITIES_FOOD_BONUS_AMOUNT_PRE_RENAISSANCE
			end
			yieldLevel[2] = yieldLevel[1] + GameDefines.ALLIES_OTHER_CITIES_FOOD_BONUS_AMOUNT
		end

		for minorCivID,minorCiv in pairs(Players) do
			if minorCiv:IsAliveCiv() and minorCiv:IsMinorCiv() then
				yield = yield + yieldLevel[minorCiv:GetMinorCivFriendshipLevelWithMajor(player:GetID())] / 100
			end
		end
	--]]
	end
	return yield
end

function City_GetSpecialistYield(city, yieldID, specialistID)
	if specialistID == nil then
		log:Fatal("City_GetSpecialistYield specialistID=nil")
	end
	local yield		= 0
	local player	= Players[city:GetOwner()]
	local traitType	= player:GetTraitInfo().Type
	local specType	= GameInfo.Specialists[specialistID].Type
	local query		= nil

	query = string.format("YieldType = '%s' AND SpecialistType = '%s' AND TraitType = '%s'", GameInfo.Yields[yieldID].Type, specType, traitType)
	for row in GameInfo.Trait_SpecialistYieldChanges(query) do
		--if row.TraitType == traitType then
			yield = yield + row.Yield
		--end
	end

	query = string.format("YieldType = '%s' AND SpecialistType = '%s'", GameInfo.Yields[yieldID].Type, specType)
	for row in GameInfo.Policy_SpecialistYieldChanges(query) do
		if player:HasPolicy(GameInfo.Policies[row.PolicyType].ID) then
			yield = yield + row.Yield
		end
	end
	
	if yieldID == YieldTypes.YIELD_CULTURE then
		yield = yield + city:GetCultureFromSpecialist(specialistID)
	
		query = string.format("YieldType = '%s' AND SpecialistType = '%s'", GameInfo.Yields[yieldID].Type, specType)
		for row in GameInfo.Building_SpecialistYieldChanges(query) do
			for targetCity in player:Cities() do
				if targetCity:IsHasBuilding(GameInfo.Buildings[row.BuildingType].ID) then
					yield = yield + row.Yield
				end
			end
		end

		query = string.format("YieldType = '%s'", GameInfo.Yields[yieldID].Type)
		for row in GameInfo.Policy_SpecialistExtraYields(query) do
			if player:HasPolicy(GameInfo.Policies[row.PolicyType].ID) then
				yield = yield + row.Yield
			end
		end

	elseif yieldID == YieldTypes.YIELD_HAPPINESS then
		
	elseif yieldID == YieldTypes.YIELD_GREAT_PEOPLE then
		yield = yield + GameInfo.Specialists[specialistID].GreatPeopleRateChange

	elseif yieldID == YieldTypes.YIELD_EXPERIENCE then
		yield = yield + GameInfo.Specialists[specialistID].Experience
	elseif Game.Contains(tileYieldTypes, yieldID) then
		yield = yield + city:GetSpecialistYield(specialistID, yieldID)
	end
	return yield
end

function City_GetBaseYieldFromAIBonus(city, yieldID)
	local player = Players[city:GetOwner()]
	local capital = player:GetCapitalCity()
	if capital ~= city or player:IsHuman() then
		return 0
	end
	local yield = 0 + Game.GetAverageHumanHandicap()
	capital:SetNumRealBuilding(GameInfo.Buildings.BUILDING_AI_PRODUCTION.ID, yield)
	if not player:IsMilitaristicLeader() then
		yield = Game.Round(0.5 * yield)
	end
	yield = yield + GameInfo.Yields.YIELD_GOLD.MinPlayer
	capital:SetNumRealBuilding(GameInfo.Buildings.BUILDING_AI_GOLD.ID, yield)
end


---------------------------------------------------------------------
-- Base Yield Modifiers
---------------------------------------------------------------------

function City_GetBaseYieldRateModifier(city, yieldID, itemTable, itemID, queueNum)
	if city == nil then
		log:Fatal("City_GetBaseYieldRateModifier city=nil")
	elseif itemTable and not itemID then
		log:Fatal("City_GetBaseYieldRateModifier itemTable=%s itemID=%s", itemTable, itemID)
	end
	local player = Players[city:GetOwner()]
	local yieldMod = 0
	local yieldMod = yieldMod + City_GetBaseYieldModFromTraits(city, yieldID) + player:GetGoldenAgeYieldModifier(yieldID)
	local cityOwner = Players[city:GetOwner()]
	if yieldID == YieldTypes.YIELD_CULTURE then
		yieldMod = yieldMod + City_GetBaseYieldModFromBuildings(city, yieldID) + cityOwner:GetCultureCityModifier()
		if city:GetNumWorldWonders() > 0 then
			yieldMod = yieldMod + cityOwner:GetCultureWonderMultiplier()
		end
	elseif yieldID == YieldTypes.YIELD_HAPPINESS then
		-- todo
	else
		yieldMod = yieldMod + city:GetYieldRateModifier(yieldID)
		yieldMod = yieldMod + City_GetBaseYieldModifierFromPolicies(city, yieldID, itemTable, itemID, queueNum)
		if yieldID == YieldTypes.YIELD_FOOD then
			yieldMod = yieldMod + City_GetCapitalSettlerModifier(city, yieldID, itemTable, itemID, queueNum)
			yieldMod = yieldMod + City_GetBaseYieldModifierFromGlobalBuildings(cityOwner, yieldID)
		elseif yieldID == YieldTypes.YIELD_PRODUCTION then
			if Game.Round(cityOwner:GetYieldRate(YieldTypes.YIELD_HAPPINESS)) <= GameDefines.VERY_UNHAPPY_THRESHOLD then
				yieldMod = yieldMod + GameDefines.VERY_UNHAPPY_PRODUCTION_PENALTY
			end
			if city:IsCapital() and cityOwner:HasTech("TECH_RAILROAD") then
				yieldMod = yieldMod + GameDefines.INDUSTRIAL_ROUTE_PRODUCTION_MOD
			end
			if itemTable == GameInfo.Units then
				--yieldMod = yieldMod + City_GetCapitalSettlerModifier(city, yieldID, itemTable, itemID, queueNum) 
				yieldMod = yieldMod + City_GetSupplyModifier(city, yieldID, itemTable, itemID, queueNum)
				yieldMod = yieldMod + city:GetUnitProductionModifier(itemID)
				return yieldMod
			elseif itemTable == GameInfo.Buildings then
				--yieldMod = yieldMod + City_GetBuildingClassConstructionYieldModifier(city, yieldID, itemTable, itemID, queueNum)
				if Building_IsWonder(itemID) then
					return yieldMod + City_GetWonderConstructionModifier(city, yieldID, itemTable, itemID, queueNum)
				end
				yieldMod = yieldMod + city:GetBuildingProductionModifier(itemID)
				--log:Warn("buildMod = %3s %20s", city:GetBuildingProductionModifier(itemID), itemTable[itemID].Type)
				return yieldMod
			elseif itemTable == GameInfo.Projects then
				yieldMod = yieldMod + city:GetProjectProductionModifier(itemID)
				--log:Warn("projMod  = %3s %20s", yieldMod, itemTable[itemID].Type)
				return yieldMod
			else
				local unitID		= city:GetProductionUnit()
				local buildingID	= city:GetProductionBuilding()
				local projectID		= city:GetProductionProject()
				if unitID and unitID ~= -1 then
					return City_GetBaseYieldRateModifier(city, yieldID, GameInfo.Units, unitID)
				elseif buildingID and buildingID ~= -1 then
					return City_GetBaseYieldRateModifier(city, yieldID, GameInfo.Buildings, buildingID)
				elseif projectID and projectID ~= -1 then
					return City_GetBaseYieldRateModifier(city, yieldID, GameInfo.Projects, projectID)
				end
			end
		end
	end
	return yieldMod
end

function City_GetBaseYieldModifierTooltip(city, yieldID, itemTable, itemID, queueNum)
	local tooltip = ""
	local player = Players[city:GetOwner()]
	if yieldID == YieldTypes.YIELD_CULTURE then
		-- Empire Culture modifier
		local empireMod = player:GetCultureCityModifier()
		if empireMod ~= 0 then
			tooltip = tooltip .. "[NEWLINE][ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_CULTURE_PLAYER_MOD", empireMod)
		end
		
		-- City Culture modifier
		local cityMod = city:GetCultureRateModifier()
		if cityMod ~= 0 then
			tooltip = tooltip .. "[NEWLINE][ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_CULTURE_CITY_MOD", cityMod)
		end
		
		-- Wonders Culture modifier
		local wonderMod = 0
		if city:GetNumWorldWonders() > 0 then
			wonderMod = player:GetCultureWonderMultiplier()
		
			if (wonderMod ~= 0) then
				tooltip = tooltip .. "[NEWLINE][ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_CULTURE_WONDER_BONUS", wonderMod)
			end
		end

		-- Golden Age Culture modifier
		yieldMod = player:GetGoldenAgeYieldModifier(yieldID)
		if yieldMod ~= 0 then
			tooltip = tooltip .. Locale.ConvertTextKey("TXT_KEY_PRODMOD_YIELD_GOLDEN_AGE", yieldMod)
		end
	else
		tooltip = tooltip .. (city:GetYieldModifierTooltip(yieldID) or "")
		--[[
		local yieldMod = City_GetBaseYieldModifierFromGlobalBuildings(player, yieldID)
		if yieldMod ~= 0 then
			tooltip = tooltip .. Locale.ConvertTextKey("TXT_KEY_YIELD_MOD_GLOBAL_BUILDINGS", yieldMod)
		end
		--]]
		if city:IsCapital() and player:HasTech("TECH_RAILROAD") then
			tooltip = tooltip .. Locale.ConvertTextKey("TXT_KEY_PRODMOD_RAILROAD_CONNECTION", GameDefines.INDUSTRIAL_ROUTE_PRODUCTION_MOD)
		end
		local yieldMod = City_GetBaseYieldModifierFromPolicies(city, yieldID, itemTable, itemID, queueNum)
		if yieldMod ~= 0 then
			tooltip = tooltip .. Locale.ConvertTextKey("TXT_KEY_PRODMOD_YIELD_POLICY", yieldMod)
		end
	end
	return tooltip
end

function PlayerClass.GetGoldenAgeYieldModifier(player, yieldID)
	local yieldMod = 0
	if player:GetGoldenAgeTurns() == 0 then
		return yieldMod
	end
	
	yieldMod = GameInfo.Yields[yieldID].GoldenAgeYieldMod
	--[[
	local query = string.format("YieldType = '%s'", yieldName)
	for row in GameInfo.GoldenAgeYields(query) do
		yieldMod = yieldMod + row.YieldMod
	end
	--]]
	
	local query = string.format("TraitType='%s' AND YieldType='%s'", player:GetTraitInfo().Type, GameInfo.Yields[yieldID].Type)
	for row in GameInfo.Trait_GoldenAgeYieldModifier(query) do
		yieldMod = yieldMod + row.YieldMod
	end
	
	return yieldMod
end

function City_GetBaseYieldModifierFromGlobalBuildings(player, yieldID)
	local yieldMod = 0
	local yieldInfo = GameInfo.Yields[yieldID]
	local query = string.format("YieldType = '%s'", yieldInfo.Type)
	for entry in GameInfo.Building_GlobalYieldModifiers(query) do
		local buildingInfo = GameInfo.Buildings[entry.BuildingType]
		for city in player:Cities() do
			if City_GetNumBuilding(city, buildingInfo.ID) > 0 then
				yieldMod = entry.Yield
			end
		end
	end
	return yieldMod
end

function City_GetBaseYieldModFromTraits(city, yieldID)
	local yieldMod = 0
	--[[
	if Players[city:GetOwner()]:GetGoldenAgeTurns() > 0 then
		local query = string.format("TraitType='%s' AND YieldType='%s'", Players[city:GetOwner()]).Type:GetTrait(GameInfo.Yields[yieldID].Type)
		for row in GameInfo.Trait_GoldenAgeYieldModifier(query) do
			yieldMod = yieldMod + row.YieldMod
		end
	end
	--]]
	return yieldMod
end

function City_GetBaseYieldModifierFromPolicies(city, yieldID, itemTable, itemID, queueNum)
	local yieldMod = 0
	local player = Players[city:GetOwner()]
	for row in GameInfo.Policy_YieldModifiers() do
		if yieldID == GameInfo.Yields[row.YieldType].ID and Players[city:GetOwner()]:HasPolicy(GameInfo.Policies[row.PolicyType].ID) then
			yieldMod = yieldMod + row.Yield
		end
	end
	if yieldID == YieldTypes.YIELD_PRODUCTION then
		if itemID == nil then
			itemID = city:GetProductionUnit()
			itemTable = GameInfo.Units
		end
		for row in GameInfo.Policy_UnitClassProductionModifiers() do
			if Players[city:GetOwner()]:HasPolicy(GameInfo.Policies[row.PolicyType].ID) then
				local unitID = player:GetUniqueUnitID(row.UnitClassType)
				if itemTable == GameInfo.Units and itemID == unitID then
					yieldMod = yieldMod + row.ProductionModifier
				end
			end
		end
	end
	return yieldMod
end

function City_GetSupplyModifier(city, yieldID, itemTable, itemID, queueNum)
	if itemID == nil then
		itemID = city:GetProductionUnit()
		itemTable = GameInfo.Units
	end
	if (itemID
		and itemID ~= -1
		and itemTable == GameInfo.Units
		and itemTable[itemID].Domain == "DOMAIN_LAND"
		and (itemTable[itemID].Combat > 0 or itemTable[itemID].RangedCombat > 0)
		) then
		return Players[city:GetOwner()]:GetSupplyModifier(yieldID)
	end
	return 0
end

function PlayerClass.GetSupplyModifier(player, yieldID, doUpdate)
	if yieldID and yieldID ~= YieldTypes.YIELD_PRODUCTION then
		return 0
	end
	local yieldMod = 0
	local netSupply = GetMaxUnitSupply(player, doUpdate) - GetCurrentUnitSupply(player, doUpdate)
	if netSupply < 0 then
		yieldMod = math.max(Civup.SUPPLY_PENALTY_MAX, netSupply * Civup.SUPPLY_PENALTY_PER_UNIT_PERCENT)
	end
	return yieldMod
end

function GetSupplyFromPopulation(player)
	if player:GetNumCities() == 0 then
		return 0
	end
	local supply = 0
	for city in player:Cities() do
		supply = supply + Civup.SUPPLY_PER_POP * city:GetPopulation()
	end
	return Game.Round(supply)
end

function GetMaxUnitSupply(player, doUpdate)
	local playerID = player:GetID()
	local activePlayer = Players[Game.GetActivePlayer()]
	if player:GetNumCities() == 0 then
		return 0
	end
	if doUpdate or MapModData.VEM.UnitSupplyMax[playerID] == nil then
		MapModData.VEM.UnitSupplyMax[playerID] = Civup.SUPPLY_BASE
		for city in player:Cities() do
			MapModData.VEM.UnitSupplyMax[playerID] = MapModData.VEM.UnitSupplyMax[playerID] + Civup.SUPPLY_PER_CITY + Civup.SUPPLY_PER_POP * city:GetPopulation()
		end
		if not player:IsHuman() then
			local handicapMod = 1 + GameInfo.HandicapInfos[activePlayer:GetHandicapType()].AIUnitSupplyPercent / 100
			MapModData.VEM.UnitSupplyMax[playerID] = handicapMod * MapModData.VEM.UnitSupplyMax[playerID]
		end
		MapModData.VEM.UnitSupplyMax[playerID] = Game.Round(MapModData.VEM.UnitSupplyMax[playerID])
		--log:Warn("%20s UnitSupplyMax     = %-3s", player:GetName(), MapModData.VEM.UnitSupplyMax[playerID])
	end
	return MapModData.VEM.UnitSupplyMax[playerID]
end

function GetCurrentUnitSupply(player, doUpdate)
	local playerID = player:GetID()
	if doUpdate or MapModData.VEM.UnitSupplyCurrent[playerID] == nil then
		MapModData.VEM.UnitSupplyCurrent[playerID] = 0
		for unit in player:Units() do
			if Unit_IsCombatDomain(unit, "DOMAIN_LAND") then
				MapModData.VEM.UnitSupplyCurrent[playerID] = MapModData.VEM.UnitSupplyCurrent[playerID] + 1
			end
		end
		--log:Warn("%20s UnitSupplyCurrent = %-3s", player:GetName(), MapModData.VEM.UnitSupplyCurrent[playerID])
	end
	return MapModData.VEM.UnitSupplyCurrent[playerID]
end

function City_GetCapitalSettlerModifier(city, yieldID, itemTable, itemID, queueNum)
	local yieldMod = 0
	if itemID == nil then
		itemID = city:GetProductionUnit()
		itemTable = GameInfo.Units
	end
	if city:IsCapital() and itemID and itemID ~= -1 and itemTable[itemID].Food then
		for policyInfo in GameInfo.Policies("CapitalSettlerProductionModifier != 0") do
			if Players[city:GetOwner()]:HasPolicy(policyInfo.ID) then
				yieldMod = yieldMod + policyInfo.CapitalSettlerProductionModifier
			end
		end
	end
	return yieldMod
end

function City_GetBuildingClassConstructionYieldModifier(city, yieldID, itemTable, itemID, queueNum)
	local yieldMod = 0
	if itemID == nil then
		itemID = city:GetProductionBuilding()
		if itemID == nil or itemID == -1 then
			return 0
		end
		itemTable = GameInfo.Buildings
	end
	for policyInfo in GameInfo.Policy_BuildingClassProductionModifiers() do
		if (policyInfo.BuildingClassType == itemTable[itemID].BuildingClass) then
			if Players[city:GetOwner()]:HasPolicy(GameInfo.Policies[policyInfo.PolicyType].ID) then
				yieldMod = yieldMod + policyInfo.ProductionModifier
			end
		end
	end
	return yieldMod
end

function City_GetWonderConstructionModifier(city, yieldID, itemTable, itemID, queueNum)
	local yieldMod = 0
	if yieldID == YieldTypes.YIELD_PRODUCTION then
		local player = Players[city:GetOwner()]

		yieldMod = yieldMod + player:GetTraitInfo().WonderProductionModifier
		
		for resourceInfo in GameInfo.Resources("WonderProductionMod != 0") do
			if city:IsHasResourceLocal(resourceInfo.ID) then
				yieldMod = yieldMod + resourceInfo.WonderProductionMod
			end
		end
		for policyInfo in GameInfo.Policies("WonderProductionModifier != 0") do
			if player:HasPolicy(policyInfo.ID) then
				yieldMod = yieldMod + policyInfo.WonderProductionModifier
			end
		end
		----log:Debug("wondMod = "..yieldMod.." "..itemTable[itemID].Type)
	end
	return yieldMod
end



---------------------------------------------------------------------
-- Surplus Yield
---------------------------------------------------------------------

function City_GetYieldConsumed(city, yieldID, itemTable, itemID, queueNum)
	if city == nil then
		log:Fatal("City_GetYieldConsumed city=nil")
	elseif itemTable and not itemID then
		log:Fatal("City_GetYieldConsumed itemID=nil")
	end
	if yieldID == YieldTypes.YIELD_FOOD then
		return city:FoodConsumption(true, 0)
	end
	return 0
end

function City_GetSurplusYieldRate(city, yieldID, itemTable, itemID, queueNum)
	if city == nil then
		log:Fatal("City_GetSurplusYieldRate city=nil")
	elseif itemTable and not itemID then
		log:Fatal("City_GetSurplusYieldRate itemTable=%s itemID=%s", itemTable, itemID)
	end
	if city:IsResistance() then
		return 0
	end
	
	----log:Debug("City_GetSurplusYieldRate %15s %15s", city:GetName(), GameInfo.Yields[yieldID].Type)
	--
	local baseMod = City_GetBaseYieldRateModifier(city, yieldID, itemTable, itemID, queueNum)
	local baseYield = City_GetBaseYieldRate(city, yieldID, itemTable, itemID, queueNum) * (1 + baseMod/100)
	return baseYield - City_GetYieldConsumed(city, yieldID, itemTable, itemID, queueNum)
	--]]
end

function City_GetSurplusYieldModFromBuildings(city, yieldID, itemTable, itemID, queueNum)
	local player = Players[city:GetOwner()]
	local surplusMod = 0
	if yieldID == YieldTypes.YIELD_HAPPINESS then
		return surplusMod
	end
	----log:Debug("City_GetSurplusYieldModFromBuildings %15s %15s", city:GetName(), GameInfo.Yields[yieldID].Type)
	if City_GetSurplusYieldRate(city, yieldID) < 0 and Game.Round(player:GetYieldRate(YieldTypes.YIELD_HAPPINESS)) <= GameDefines.VERY_UNHAPPY_THRESHOLD then
		return surplusMod
	end
	for row in GameInfo.Building_YieldSurplusModifiers() do
		if yieldID == YieldTypes[row.YieldType] and city:IsHasBuilding(GameInfo.Buildings[row.BuildingType].ID) then
			surplusMod = row.Yield + surplusMod
		end
	end
	return surplusMod
end

function City_GetSurplusYieldRateModifier(city, yieldID, itemTable, itemID, queueNum)
	if city == nil then
		log:Fatal("City_GetSurplusYieldRateModifier city=nil")
	elseif itemTable and not itemID then
		log:Fatal("City_GetSurplusYieldRateModifier itemID=nil")
	end
	local surplusMod = 0
	
	----log:Debug("City_GetSurplusYieldRateModifier %15s %15s", city:GetName(), GameInfo.Yields[yieldID].Type)
	if yieldID == YieldTypes.YIELD_HAPPINESS or City_GetSurplusYieldRate(city, yieldID) < 0 then
		return surplusMod
	end
	--
	local player = Players[city:GetOwner()]
	local happiness = Game.Round(player:GetYieldRate(YieldTypes.YIELD_HAPPINESS))
	local surplusMod = City_GetSurplusYieldModFromBuildings(city, yieldID, itemTable, itemID, queueNum)
	surplusMod = surplusMod + player:GetGoldenAgeSurplusYieldModifier(yieldID)
	
	if yieldID == YieldTypes.YIELD_FOOD then
		if City_GetSurplusYieldRate(city, yieldID) > 0 then
			if happiness <= GameDefines.VERY_UNHAPPY_THRESHOLD then
				surplusMod = surplusMod + GameDefines.VERY_UNHAPPY_GROWTH_PENALTY
			elseif happiness < 0 then
				surplusMod = surplusMod + GameDefines.UNHAPPY_GROWTH_PENALTY
			end
		end
		if city:GetWeLoveTheKingDayCounter() > 0 then
			surplusMod = surplusMod + GameDefines.WLTKD_GROWTH_MULTIPLIER
		end
		for policyInfo in GameInfo.Policies("CityGrowthMod != 0") do
			if player:HasPolicy(policyInfo.ID) then
				surplusMod = surplusMod + policyInfo.CityGrowthMod
			end
		end
		if city:IsCapital() then
			for policyInfo in GameInfo.Policies("CapitalGrowthMod != 0") do
				if player:HasPolicy(policyInfo.ID) then
					surplusMod = surplusMod + policyInfo.CapitalGrowthMod
				end
			end			
		end
	end
	--]]
	
	return surplusMod
end

function PlayerClass.GetGoldenAgeSurplusYieldModifier(player, yieldID)
	local yieldMod = 0
	if player:GetGoldenAgeTurns() == 0 then
		return yieldMod
	end
	
	yieldMod = GameInfo.Yields[yieldID].GoldenAgeSurplusYieldMod	
	return yieldMod
end



---------------------------------------------------------------------
-- Total Yield
---------------------------------------------------------------------

function City_GetYieldRate(city, yieldID, itemTable, itemID, queueNum)
	if city == nil then
		log:Fatal("City_GetYieldRate city=nil")
	elseif itemTable and not itemID then
		log:Fatal("City_GetYieldRate itemID=nil")
	end
	if not Game.Contains(tileYieldTypes, yieldID) then
		return 0
	end

	local player = Players[city:GetOwner()]
	local activePlayer = Players[Game.GetActivePlayer()]
	
	if MapModData.CityYieldRatesDirty then
		activePlayer:CleanCityYieldRates()
	end

	local yield = 1
	if not MapModData.VEM.UpdateCityYields and not itemTable then
		local cityID = City_GetID(city)
		yield = MapModData.CityYields[cityID]
		if not yield then
			player:CleanCityYieldRates()
			yield = MapModData.CityYields[cityID]
		end
		if yield then
			yield = yield[yieldID]
			if yield then
				return yield
			end
		end
		log:Warn("City_GetYieldRate: Cleaning failed! %20s %15s %15s %3s", player:GetName(), city:GetName(), GameInfo.Yields[yieldID].Type, yield)
	end

	yield = City_GetSurplusYieldRate(city, yieldID, itemTable, itemID, queueNum)
	yield = yield * (1 + City_GetSurplusYieldRateModifier(city, yieldID, itemTable, itemID, queueNum) / 100)
	if yieldID == YieldTypes.YIELD_PRODUCTION then
		if itemTable == nil then
			if city:GetProductionUnit() ~= -1 then
				itemID = city:GetProductionUnit()
				itemTable = GameInfo.Units
			end
		end
		if itemID then
			if itemTable == GameInfo.Units then
				if itemTable[itemID].Food then
					yield = yield + math.max(0, City_GetYieldRate(city, YieldTypes.YIELD_FOOD, itemTable, itemID))
				end
				if itemID == GameInfo.Units.UNIT_SETTLER.ID then
					yield = yield * 105 / Civup.UNIT_SETTLER_BASE_COST
				end
			end
		end
		if not player:IsHuman() then
			local handicapInfo = GameInfo.HandicapInfos[activePlayer:GetHandicapType()]
			local handicapBonus = 1 + 0.01 * handicapInfo.AIProductionPercentPerEra * activePlayer:GetCurrentEra()
			--log:Warn("%-15s %3s", city:GetName(), Game.Round(handicapBonus * 100))
			yield = yield * handicapBonus
		end
	end
	yield = yield / City_GetCostMod(city, yieldID, itemTable, itemID)
	--[[
	if city:GetName() == "Copenhagen" and yieldID == YieldTypes.YIELD_PRODUCTION then
		log:Error("%3s %s City_GetYieldRate", yield, city:GetName())
	end
	--]]
	return yield
end

function City_GetYieldFromFood(city, yieldID, itemTable, itemID, queueNum)
	local yield = 0
	if yieldID == YieldTypes.YIELD_PRODUCTION then
		if itemTable == nil then
			if city:GetProductionUnit() ~= -1 then
				itemID = city:GetProductionUnit()
				itemTable = GameInfo.Units
			end
		end
		if itemID and itemTable == GameInfo.Units and itemTable[itemID].Food then
			yield = yield + math.max(0, City_GetYieldRate(city, YieldTypes.YIELD_FOOD, itemTable, itemID))
		end
	end
	return yield
end

function City_GetYieldRateTimes100(city, yieldID, itemTable, itemID, queueNum)
	if city == nil then
		log:Fatal("City_GetYieldRateTimes100 city=nil")
	elseif itemTable and not itemID then
		log:Fatal("City_GetYieldRateTimes100 itemID=nil")
	end
	return City_GetYieldRate(city, yieldID) * 100
end

function City_GetYieldStored(city, yieldID, itemTable, itemID, queueNum)
	if city == nil then
		log:Fatal("City_GetYieldStored city=nil")
	elseif itemTable and not itemID then
		log:Fatal("City_GetYieldStored itemID=nil")
	end
	if yieldID == YieldTypes.YIELD_FOOD then
		return city:GetFoodTimes100() / 100
	elseif yieldID == YieldTypes.YIELD_PRODUCTION then
		if itemTable == GameInfo.Units then
			return city:GetUnitProduction(itemID, queueNum)
		elseif itemTable == GameInfo.Buildings then
			return city:GetBuildingProduction(itemID, queueNum)
		elseif itemTable == GameInfo.Projects then
			log:Fatal("City_GetYieldStored: Civ API has no city:GetProjectProductionNeeded function!")
			--return city:GetProjectProduction(itemID, queueNum)
			return 0
		else
			return city:GetProduction()
		end		
	elseif yieldID == YieldTypes.YIELD_CULTURE then
		return city:GetJONSCultureStored()
	end
	return 0
end

function City_GetYieldNeeded(city, yieldID, itemTable, itemID, queueNum)
	if city == nil then
		log:Fatal("City_GetYieldNeeded city=nil")
	elseif itemTable and not itemID then
		log:Fatal("City_GetYieldNeeded itemID=nil")
	end
	if yieldID == YieldTypes.YIELD_FOOD then
		return city:GrowthThreshold()
	elseif yieldID == YieldTypes.YIELD_PRODUCTION then
		if itemTable == GameInfo.Units then
			return city:GetUnitProductionNeeded(itemID, queueNum)
		elseif itemTable == GameInfo.Buildings then
			return city:GetBuildingProductionNeeded(itemID, queueNum)
		elseif itemTable == GameInfo.Projects then
			return city:GetProjectProductionNeeded(itemID, queueNum)
		elseif not city:IsProductionProcess() and city:GetProductionNameKey() and city:GetProductionNameKey() ~= "" then 
			return city:GetProductionNeeded()
		end
	elseif yieldID == YieldTypes.YIELD_CULTURE then
		return city:GetJONSCultureThreshold()
	end
	return 0
end

function City_GetYieldTurns(city, yieldID, itemTable, itemID, queueNum)
	if city == nil then
		log:Fatal("City_GetYieldTurns city=nil")
	elseif itemTable and not itemID then
		log:Fatal("City_GetYieldTurns itemID=nil")
	end
	if itemTable == GameInfo.Projects then
		-- The API is missing the "city:GetProjectProduction(itemID, queueNum)" function!
		return math.max(1, math.ceil(
			city:GetProjectProductionTurnsLeft(itemID, queueNum)
			* City_GetYieldRate(city, yieldID, itemTable, itemID, queueNum)
			/ (city:GetYieldRateTimes100(yieldID) / 100)
		))
	end
	return math.max(1, math.ceil(
			( City_GetYieldNeeded(city, yieldID, itemTable, itemID, queueNum)
			- City_GetYieldStored(city, yieldID, itemTable, itemID, queueNum) )
			/ City_GetYieldRate(city, yieldID, itemTable, itemID, queueNum)
		))
end

function City_ChangeYieldStored(city, yieldID, amount, checkThreshold)
	if city == nil then
		log:Fatal("City_ChangeYieldStored city=nil")
	elseif itemTable and not itemID then
		log:Fatal("City_ChangeYieldStored itemID=nil")
	end
	local player = Players[city:GetOwner()]
	if yieldID == YieldTypes.YIELD_FOOD then
		city:ChangeFood(amount)
		local overflow = City_GetYieldStored(city, yieldID) - City_GetYieldNeeded(city, yieldID)
		if checkThreshold and overflow >= 0 then
			local totalYieldKept = 0
			for building in GameInfo.Buildings("FoodKept != 0") do
				if city:IsHasBuilding(building.ID) then
					totalYieldKept = totalYieldKept + building.FoodKept / 100
				end
			end
			city:ChangePopulation(1,true)
			city:SetFood(0)
			City_ChangeYieldStored(city, yieldID, overflow + totalYieldKept * City_GetYieldNeeded(city, yieldID), true)
		end
	elseif yieldID == YieldTypes.YIELD_PRODUCTION then
		city:ChangeProduction(amount)
	elseif yieldID == YieldTypes.YIELD_CULTURE then
		city:ChangeJONSCultureStored(amount)
		player:ChangeYieldStored(YieldTypes.YIELD_CULTURE, amount)
		local overflow = City_GetYieldStored(city, yieldID) - City_GetYieldNeeded(city, yieldID)
		if checkThreshold and overflow >= 0 then
			city:DoJONSCultureLevelIncrease()
			city:SetJONSCultureStored(0)
			City_ChangeYieldStored(city, yieldID, overflow, true)
		end
	elseif yieldID == YieldTypes.YIELD_POPULATION then
		city:ChangePopulation(amount,true)
	end
end



---------------------------------------------------------------------
-- Total Player Yields
---------------------------------------------------------------------

if not MapModData.VEM.Yields then
	MapModData.VEM.Yields = {}
	MapModData.VEM.Yields[YieldTypes.YIELD_CS_MILITARY]		= {}
	MapModData.VEM.Yields[YieldTypes.YIELD_CS_GREAT_PEOPLE]	= {}
	local milBaseThreshold = Civup.MINOR_CIV_MILITARISTIC_REWARD_NEEDED * GameInfo.GameSpeeds[Game.GetGameSpeedType()].TrainPercent / 100
	local gpBaseThreshold = GameDefines.GREAT_PERSON_THRESHOLD_BASE	* GameInfo.GameSpeeds[Game.GetGameSpeedType()].GreatPeoplePercent / 100
	startClockTime = os.clock()
	for playerID,player in pairs(Players) do
		if player:IsAliveCiv() and not player:IsMinorCiv() then
			MapModData.VEM.Yields[YieldTypes.YIELD_CS_MILITARY][playerID]					= {}
			MapModData.VEM.Yields[YieldTypes.YIELD_CS_MILITARY][playerID].Needed			= milBaseThreshold
			MapModData.VEM.Yields[YieldTypes.YIELD_CS_GREAT_PEOPLE][playerID]				= {}
			if UI:IsLoadedGame() then
				MapModData.VEM.Yields[YieldTypes.YIELD_CS_MILITARY][playerID].Stored		= LoadValue("MapModData.VEM.Yields[%s][%s].Stored", YieldTypes.YIELD_CS_MILITARY, playerID) or 0
				MapModData.VEM.Yields[YieldTypes.YIELD_CS_GREAT_PEOPLE][playerID].Stored	= LoadValue("MapModData.VEM.Yields[%s][%s].Stored", YieldTypes.YIELD_CS_GREAT_PEOPLE, playerID) or 0
				MapModData.VEM.Yields[YieldTypes.YIELD_CS_GREAT_PEOPLE][playerID].Needed	= LoadValue("MapModData.VEM.Yields[%s][%s].Needed", YieldTypes.YIELD_CS_GREAT_PEOPLE, playerID) or gpBaseThreshold
			else
				MapModData.VEM.Yields[YieldTypes.YIELD_CS_MILITARY][playerID].Stored		= 0
				MapModData.VEM.Yields[YieldTypes.YIELD_CS_GREAT_PEOPLE][playerID].Stored	= 0
				MapModData.VEM.Yields[YieldTypes.YIELD_CS_GREAT_PEOPLE][playerID].Needed	= gpBaseThreshold
			end
		end
	end
	if UI:IsLoadedGame() then
		log:Warn("%-10s seconds loading Yields", Game.Round(os.clock() - startClockTime, 8))
	end
end

function PlayerClass.GetYieldStored(player, yieldID, itemID)
	if player == nil then
		log:Fatal("player:GetYieldStored player=nil")
	end
	if yieldID == YieldTypes.YIELD_GOLD then
		return player:GetGold()
	elseif yieldID == YieldTypes.YIELD_SCIENCE then
		return Teams[player:GetTeam()]:GetTeamTechs():GetResearchProgress(itemID or player:GetCurrentResearch()) + player:GetOverflowResearch()
	elseif yieldID == YieldTypes.YIELD_CULTURE then
		return player:GetJONSCulture()
	elseif yieldID == YieldTypes.YIELD_HAPPINESS then
		return player:GetGoldenAgeProgressMeter()
	elseif yieldID == YieldTypes.YIELD_FAITH then
		return player:GetFaith()
	elseif yieldID == YieldTypes.YIELD_CS_MILITARY or yieldID == YieldTypes.YIELD_CS_GREAT_PEOPLE then
		return MapModData.VEM.Yields[yieldID][player:GetID()].Stored
	end
	
	return 0
end

function PlayerClass.SetYieldStored(player, yieldID, yield, itemID)
	if player == nil then
		log:Fatal("player:GetYieldStored player=nil")
	end
	if yieldID == YieldTypes.YIELD_GOLD then
		player:SetGold(yield)
	elseif yieldID == YieldTypes.YIELD_SCIENCE then
		local sciString	= ""
		local teamID	= player:GetTeam()
		local team   	= Teams[teamID]
		local teamTechs	= team:GetTeamTechs()
		
		sciString = "Sci bonus for "..player:GetName()..": "
		local targetTech = itemID or player:GetCurrentResearch()
		if targetTech ~= -1 then
			targetTech = GameInfo.Technologies[targetTech]
			teamTechs:SetResearchProgress(targetTech.ID, yield, player)
			sciString = string.format("%-40s +%-3d  @ %s", sciString, Game.Round(yield), targetTech.Type)
		else
			local researchableTechs = {}
			for techInfo in GameInfo.Technologies() do
				if player:CanResearch(techInfo.ID) and not team:IsHasTech(techInfo.ID) then
					table.insert(researchableTechs, techInfo.ID)
				end
			end
			if #researchableTechs > 0 then
				targetTech = researchableTechs[1 + Map.Rand(#researchableTechs, "player:ChangeYieldStored: Random Tech")]
				targetTech = GameInfo.Technologies[targetTech]
				teamTechs:SetResearchProgress(targetTech.ID, yield, player)
				sciString = string.format("%-40s +%-3d  @ %s (random)", sciString, Game.Round(yield), targetTech.Type)
			end
		end
		--log:Warn(sciString)
	elseif yieldID == YieldTypes.YIELD_CULTURE then
		player:SetJONSCulture(yield)
	elseif yieldID == YieldTypes.YIELD_FAITH then
		player:SetFaith(yield)
	elseif yieldID == YieldTypes.YIELD_HAPPINESS then
		player:SetGoldenAgeProgressMeter(yield)
	elseif yieldID == YieldTypes.YIELD_CS_MILITARY or yieldID == YieldTypes.YIELD_CS_GREAT_PEOPLE then
		MapModData.VEM.Yields[yieldID][player:GetID()].Stored = yield
		SaveValue(yield, "MapModData.VEM.Yields[%s][%s].Stored", yieldID, player:GetID())
	end
end

function PlayerClass.ChangeYieldStored(player, yieldID, yield, itemID)
	if yield == 0 then
		return
	end
	if yieldID == YieldTypes.YIELD_GOLD then
		player:ChangeGold(yield)
	elseif yieldID == YieldTypes.YIELD_CULTURE then
		player:ChangeJONSCulture(yield)
	elseif yieldID == YieldTypes.YIELD_FAITH then
		player:SetFaith(player:GetFaith() + yield)
	elseif yieldID == YieldTypes.YIELD_HAPPINESS then
		player:SetGoldenAgeProgressMeter(math.max(0, player:GetGoldenAgeProgressMeter() + yield))
		local surplusGoldenPoints = player:GetGoldenAgeProgressMeter() - player:GetGoldenAgeProgressThreshold()
		if surplusGoldenPoints > 0 then
			player:SetGoldenAgeProgressMeter(surplusGoldenPoints)
			player:ChangeGoldenAgeTurns((1 + player:GetGoldenAgeModifier() / 100) * (GameDefines.GOLDEN_AGE_LENGTH - player:GetNumGoldenAges()))
			----log:Debug("Mod=%s Turns=%s NumAges=%s", player:GetGoldenAgeModifier(), GameDefines.GOLDEN_AGE_LENGTH - player:GetNumGoldenAges(), player:GetNumGoldenAges())
			player:ChangeNumGoldenAges(1)
		end
	elseif yieldID == YieldTypes.YIELD_EXPERIENCE then
		player:ChangeCombatExperience(yield)
	elseif yieldID == YieldTypes.YIELD_SCIENCE then
		local sciString	= ""
		local teamID	= player:GetTeam()
		local team   	= Teams[teamID]
		local teamTechs	= team:GetTeamTechs()
		
		sciString = "Sci bonus for "..player:GetName()..": "
		local targetTech = itemID or player:GetCurrentResearch()
		if targetTech ~= -1 then
			targetTech = GameInfo.Technologies[targetTech]
			sciString = string.format("%-40s %s +%-3d  @ %s (%s needed)", sciString, Game.Round(teamTechs:GetResearchProgress(targetTech.ID)), Game.Round(yield), targetTech.Type, teamTechs:GetResearchCost(targetTech.ID))
			teamTechs:ChangeResearchProgress(targetTech.ID, yield)
		else
			local researchableTechs = {}
			for techInfo in GameInfo.Technologies() do
				if player:CanResearch(techInfo.ID) and not team:IsHasTech(techInfo.ID) then
					table.insert(researchableTechs, techInfo.ID)
				end
			end
			if #researchableTechs > 0 then
				targetTech = researchableTechs[1 + Map.Rand(#researchableTechs, "player:ChangeYieldStored: Random Tech")]
				targetTech = GameInfo.Technologies[targetTech]
				sciString = string.format("%-40s +%-3d  @ %s (random)", sciString, Game.Round(yield), targetTech.Type)
				teamTechs:ChangeResearchProgress(targetTech.ID, yield)
			end
		end
		if player:IsHuman() then
			--log:Warn(sciString)
		end
	end
	if player == Players[Game.GetActivePlayer()] then
		LuaEvents.CityYieldRatesDirty()
	end
end

function PlayerClass.GetYieldNeeded(player, yieldID, itemID)
	if player == nil then
		log:Fatal("player:GetYieldNeeded player=nil")
	end
	if yieldID == YieldTypes.YIELD_SCIENCE then
		return Game.Round(player:GetResearchCost(itemID or player:GetCurrentResearch()))
	elseif yieldID == YieldTypes.YIELD_CULTURE then
		return player:GetNextPolicyCost()
	elseif yieldID == YieldTypes.YIELD_FAITH then
		return player:GetMinimumFaithNextGreatProphet()		
	elseif yieldID == YieldTypes.YIELD_HAPPINESS then
		return player:GetGoldenAgeProgressThreshold()
	elseif yieldID == YieldTypes.YIELD_CS_MILITARY or yieldID == YieldTypes.YIELD_CS_GREAT_PEOPLE then
		return MapModData.VEM.Yields[yieldID][player:GetID()].Needed
	end
	return 0
end

function PlayerClass.SetYieldNeeded(player, yieldID, value)
	if player == nil then
		log:Fatal("player:GetYieldNeeded player=nil")
	end
	if yieldID == YieldTypes.YIELD_CS_GREAT_PEOPLE then
		MapModData.VEM.Yields[yieldID][player:GetID()].Needed = value
		SaveValue(value, "MapModData.VEM.Yields[%s][%s].Needed", yieldID, player:GetID())
	end
	return 0
end

function PlayerClass.GetMinYieldRate(player, yieldID)
	if not player:IsHuman() and (yieldID == YieldTypes.YIELD_GOLD or yieldID == YieldTypes.YIELD_SCIENCE) then
		return 0
	end
	return GameInfo.Yields[yieldID].MinPlayer
end

if not PlayerClass.VanillaCalculateGoldRate then
	PlayerClass.VanillaCalculateGoldRate = PlayerClass.CalculateGoldRate
	--PlayerClass.CalculateGoldRate = function(player) return player:GetYieldRate(YieldTypes.YIELD_GOLD) end
end

function PlayerClass.GetBaseYieldRate(player, yieldID, skipGlobalMods)
	if yieldID ~= YieldTypes.YIELD_GOLD then
		return player:GetYieldRate(yieldID)
	end
	
	local yield = (
		player:GetMinYieldRate(yieldID)
		+ math.max(0, player:GetGoldPerTurnFromDiplomacy())
		+ player:GetGoldFromCitiesTimes100() / 100
		+ player:GetCityConnectionGoldTimes100() / 100
	)
	if not skipGlobalMods then
		yield = yield + player:GetYieldFromTradeDeals(yieldID)
		yield = yield + player:GetYieldFromResources(yieldID)
		yield = yield + player:GetYieldFromPolicies(yieldID)
	end	
	return Game.Round(yield)
end

function PlayerClass.GetYieldRate(player, yieldID, skipGlobalMods)
	if player == nil then
		log:Fatal("player:GetYieldRate player=nil")
		return nil
	end
	--print(tostring(player:GetYieldRate).." player:GetYieldRate")

	local capital = player:GetCapitalCity()
	if capital == nil then
		return 0
	end

	local yield = player:GetMinYieldRate(yieldID)
	if yieldID == YieldTypes.YIELD_GOLD then
		yield = yield + player:GetFreeGarrisonMaintenance()
		yield = yield + player:VanillaCalculateGoldRate()
		if not skipGlobalMods then
			yield = yield + player:GetYieldFromTradeDeals(yieldID)
			yield = yield + player:GetYieldFromResources(yieldID)
			yield = yield + player:GetYieldFromPolicies(yieldID)
		end
		return Game.Round(yield)
	elseif yieldID == YieldTypes.YIELD_SCIENCE then
		yield = yield + player:GetScience()
		if not skipGlobalMods then
			yield = yield + player:GetYieldFromTradeDeals(yieldID)
			yield = yield + player:GetYieldFromResources(yieldID)
			yield = yield + player:GetYieldFromPolicies(yieldID)
			yield = yield * (1 + player:GetYieldHappinessMod(yieldID) / 100)
		end
		return yield
	elseif yieldID == YieldTypes.YIELD_CULTURE then
		yield = (yield
			+ player:GetJONSCulturePerTurnForFree()
			+ player:GetJONSCulturePerTurnFromExcessHappiness()
			+ player:GetJONSCulturePerTurnFromMinorCivs()
		)
		for city in player:Cities() do
			yield = yield + City_GetYieldRate(city, YieldTypes.YIELD_CULTURE)
		end
		return yield
	elseif yieldID == YieldTypes.YIELD_FAITH then
		return player:GetTotalFaithPerTurn()
	elseif yieldID == YieldTypes.YIELD_HAPPINESS then
		yield = yield + player:GetExcessHappiness()
		for city in player:Cities() do
			yield = yield + City_GetYieldRate(city, YieldTypes.YIELD_HAPPINESS)
		end
		if not player:IsMinorCiv() then
			yield = yield + player:GetYieldFromTerrain(yieldID)
			yield = yield + player:GetYieldFromSurplusResources(yieldID)
			yield = yield + player:GetYieldsFromCitystates()[yieldID]
			yield = yield - City_GetNumBuilding(player:GetCapitalCity(), GameInfo.Buildings.BUILDING_EXTRA_HAPPINESS.ID)
		end
		return yield
	elseif yieldID == YieldTypes.YIELD_CS_MILITARY then
		yield = yield + player:GetYieldsFromCitystates(true)[yieldID]
		return yield
	elseif yieldID == YieldTypes.YIELD_CS_GREAT_PEOPLE then
		local gpRate = 0
		for policyInfo in GameInfo.Policies("MinorGreatPeopleRate != 0") do
			if player:HasPolicy(policyInfo.ID) then
				gpRate = gpRate + policyInfo.MinorGreatPeopleRate
			end
		end
		if gpRate > 0 then
			for minorCivID,minorCiv in pairs(Players) do
				if minorCiv:IsAliveCiv() and minorCiv:IsMinorCiv() then
					local friendLevel = minorCiv:GetMinorCivFriendshipLevelWithMajor(playerID)
					if friendLevel == 1 then
						yield = yield + 1.0 * gpRate
					elseif friendLevel == 2 then
						yield = yield + 1.5 * gpRate
					end
				end
			end
		end
		return yield
	end
	return yield
end


function PlayerClass.GetYieldTurns(player, yieldID, itemID, overflow)
	local rate = player:GetYieldRate(yieldID, itemID)
	if rate == 0 then
		return 0
	end
	return math.max(0, math.ceil(
		( player:GetYieldNeeded(yieldID, itemID)
		- player:GetYieldStored(yieldID, itemID) )
		/ rate
	))
end

function PlayerClass.GetYieldFromSurplusResources(player, yieldID)
	local luxurySurplus = 0
	if yieldID == YieldTypes.YIELD_HAPPINESS then
		for policyInfo in GameInfo.Policies("ExtraHappinessPerLuxury != 0") do
			if player:HasPolicy(policyInfo.ID) and policyInfo.ExtraHappinessPerLuxury > 0 then
				for resourceInfo in GameInfo.Resources("Happiness != 0") do
					if resourceInfo.Happiness > 0 then
						luxurySurplus = luxurySurplus + math.max(0, player:GetNumResourceTotal(resourceInfo.ID, true) - 1)
					end
				end
			end
		end
	end
	return luxurySurplus
end

function PlayerClass.GetYieldFromResources(player, yieldID)
	local yieldMod = 0
	if not Game.HasValue({TraitType=player:GetTraitInfo().Type, YieldType=GameInfo.Yields[yieldID].Type}, GameInfo.Trait_LuxuryYieldModifier) then
		return 0
	end
	
	local luxuryTotal = 0
	for resourceInfo in GameInfo.Resources() do
		if Game.GetResourceUsageType(resourceInfo.ID) == ResourceUsageTypes.RESOURCEUSAGE_LUXURY and player:GetNumResourceAvailable(resourceInfo.ID, true) > 0 then
			luxuryTotal = luxuryTotal + 1
		end
	end
	local query = string.format("TraitType = '%s' AND YieldType = '%s'", player:GetTraitInfo().Type, GameInfo.Yields[yieldID].Type)
	for policyInfo in GameInfo.Trait_LuxuryYieldModifier(query) do
		yieldMod = yieldMod + policyInfo.YieldMod
	end
	return player:GetBaseYieldRate(yieldID, true) * yieldMod / 100
end

function PlayerClass.GetYieldFromPolicyHappiness(player, yieldID)
	if yieldID ~= YieldTypes.YIELD_SCIENCE then
		return 0
	end
	local yieldMod = 0
	for policyInfo in GameInfo.Policies("HappinessToScience <> 0") do
		if player:HasPolicy(policyInfo.ID) then
			yieldMod = yieldMod + policyInfo.HappinessToScience
		end
	end
	if yieldMod == 0 then
		return 0
	end
	return player:GetBaseYieldRate(yieldID, true) * yieldMod / 100
end

function PlayerClass.GetYieldFromPolicies(player, yieldID)
	local yieldMod = 0
	for policyInfo in GameInfo.Policy_PlayerYieldModifiers{YieldType = GameInfo.Yields[yieldID].Type} do
		if player:HasPolicy(GameInfo.Policies[policyInfo.PolicyType].ID) then
			yieldMod = yieldMod + policyInfo.YieldMod
		end
	end
	if yieldMod == 0 then
		return 0
	end
	return player:GetBaseYieldRate(yieldID, true) * yieldMod / 100
end

function PlayerClass.GetYieldFromTerrain(player, yieldID)
	local yield = 0
	for plotID, plotYield in pairs(MapModData.VEM.PlotYields[yieldID]) do
		local plotOwner = Players[Map.GetPlotByIndex(plotID):GetOwner()]
		if plotOwner == player then
			--log:Warn("%s owns plot #%s for +%s happiness", plotOwner:GetName(), plotID, plotYield)
			yield = yield + plotYield
		end
	end
	return yield
end

if not PlayerClass.VanillaCalculateUnitCost then
	PlayerClass.VanillaCalculateUnitCost = PlayerClass.CalculateUnitCost
end

function PlayerClass.CalculateUnitCost(player)
	return player:VanillaCalculateUnitCost() - player:GetFreeGarrisonMaintenance()
end

function PlayerClass.GetFreeGarrisonMaintenance(player)
	local gold = 0
	for policyInfo in GameInfo.Policies() do
		if policyInfo.GarrisonFreeMaintenance and player:HasPolicy(policyInfo.ID) then
			for city in player:Cities() do
				local garrisonUnit = city:GetGarrisonedUnit()
				if garrisonUnit then
					gold = gold + GameInfo.Units[garrisonUnit:GetUnitType()].ExtraMaintenanceCost
				end
			end
			break
		end
	end
	return gold
end


---------------------------------------------------------------------
-- Plot Yields
---------------------------------------------------------------------

function GetImprovementExtraYield(improvementID, yieldID, player)
	local impInfo	= GameInfo.Improvements[improvementID]
	local player	= Players[playerID]
	local eraID		= player:IsHuman() and player:GetCurrentEra() or Game.GetAverageHumanEra()
	local yield		= 0

	if not impInfo.CreatedByGreatPerson or eraID == 0 then
		return 0
	end

	local query = string.format("ImprovementType = '%s' AND YieldType = '%s'", impInfo.Type, GameInfo.Yields[policyInfo.yieldID].Type)
	for policyInfo in GameInfo.Improvement_Yields(query) do
		yield = yield + eraID * policyInfo.Yield
	end
	return yield
end

function Plot_GetYield(plot, yieldID)
	local yield = 0
	local plotID = Plot_GetID(plot)
	if yieldID ~= YieldTypes.YIELD_HAPPINESS then
		yield = plot:CalculateYield(yieldID, true)
	elseif yieldID == YieldTypes.YIELD_HAPPINESS then
		yield = (MapModData.VEM.PlotYields[yieldID][plotID] or 0)
	end
	--[[
	if (yieldID == YieldTypes.YIELD_FOOD
		or yieldID == YieldTypes.YIELD_PRODUCTION
		or yieldID == YieldTypes.YIELD_GOLD
		or yieldID == YieldTypes.YIELD_SCIENCE
		) then
		yield = plot:CalculateYield(yieldID, true)
	elseif yieldID == YieldTypes.YIELD_CULTURE then
		yield = (MapModData.VEM.PlotYields[yieldID][plotID] or 0)
	elseif yieldID == YieldTypes.YIELD_HAPPINESS then
		yield = (MapModData.VEM.PlotYields[yieldID][plotID] or 0)
	end
	--]]
	return yield
end

function Plot_ChangeYield(plot, yieldID, yield)
	local currentYield = Plot_GetYield(plot, yieldID)
	local newYield = 0
	local plotID = Plot_GetID(plot)
	if (yieldID == YieldTypes.YIELD_FOOD
		or yieldID == YieldTypes.YIELD_PRODUCTION
		or yieldID == YieldTypes.YIELD_GOLD
		or yieldID == YieldTypes.YIELD_SCIENCE
		or yieldID == YieldTypes.YIELD_CULTURE
		or yieldID == YieldTypes.YIELD_FAITH
		) then
		newYield = (MapModData.VEM.PlotYields[yieldID][plotID] or 0) + yield
		Game.SetPlotExtraYield( plot:GetX(), plot:GetY(), yieldID, newYield)
	elseif yieldID == YieldTypes.YIELD_CULTURE then
		plot:ChangeCulture(yield)
		newYield = currentYield + yield
	elseif yieldID == YieldTypes.YIELD_HAPPINESS then
		newYield = currentYield + yield
	elseif yieldID == YieldTypes.YIELD_POPULATION then
		if plot:GetWorkingCity() then
			City_ChangeYieldStored(plot:GetWorkingCity(), yieldID, yield)
		end
		return
	end
	MapModData.CityYieldRatesDirty = true
	MapModData.VEM.PlotYields[yieldID][plotID] = newYield
	SaveValue(newYield, "MapModData.VEM.PlotYields[%s][%s]", yieldID, plotID)
	Events.HexYieldMightHaveChanged(plot:GetX(), plot:GetY())
	if yieldID == YieldTypes.YIELD_HAPPINESS and plot:GetOwner() ~= -1 then
		Players[plot:GetOwner()]:UpdateModdedHappiness()
	end
end

function Plot_SetYield(plot, yieldID, yield)
	local newYield = 0
	if (yieldID == YieldTypes.YIELD_FOOD
		or yieldID == YieldTypes.YIELD_PRODUCTION
		or yieldID == YieldTypes.YIELD_GOLD
		or yieldID == YieldTypes.YIELD_SCIENCE
		or yieldID == YieldTypes.YIELD_CULTURE
		or yieldID == YieldTypes.YIELD_FAITH
		) then
		newYield = yield
		Game.SetPlotExtraYield(plot:GetX(), plot:GetY(), yieldID, yield)
	--[[
	elseif yieldID == YieldTypes.YIELD_CULTURE then
		newYield = yield
		plot:ChangeCulture(yield - Plot_GetYield(plot, yieldID))
	--]]
	elseif yieldID == YieldTypes.YIELD_HAPPINESS then
		newYield = yield
	end
	MapModData.CityYieldRatesDirty = true
	MapModData.VEM.PlotYields[yieldID][Plot_GetID(plot)] = newYield
	SaveValue(newYield, "MapModData.VEM.PlotYields[%s][%s]", yieldID, Plot_GetID(plot))
	Events.HexYieldMightHaveChanged(plot:GetX(), plot:GetY())
	if yieldID == YieldTypes.YIELD_HAPPINESS and plot:GetOwner() ~= -1 then
		Players[plot:GetOwner()]:UpdateModdedHappiness()
	end
end

function CheckPlotCultureYields()
	for plotID, yield in pairs(MapModData.VEM.PlotYields[YieldTypes.YIELD_CULTURE]) do
		local plot = Map.GetPlotByIndex(plotID)
		local culture = plot:CalculateYield( 4, true )
		if culture < yield then
			plot:ChangeCulture(yield - culture)
		end
	end
end

if not MapModData.VEM.PlotYields then
	MapModData.VEM.PlotYields = {}
	startClockTime = os.clock()
	for yieldInfo in GameInfo.Yields() do
		MapModData.VEM.PlotYields[yieldInfo.ID] = {}
		for plotID, plot in Plots() do
			if UI:IsLoadedGame() then
				MapModData.VEM.PlotYields[yieldInfo.ID][plotID] = LoadValue("MapModData.VEM.PlotYields[%s][%s]", yieldInfo.ID, plotID) --or 0
			else
				--MapModData.VEM.PlotYields[yieldInfo.ID][plotID] = 0
			end
		end
	end
	if UI:IsLoadedGame() then
		log:Warn("%-10s seconds loading PlotYields", Game.Round(os.clock() - startClockTime, 8))
	end
end

---------------------------------------------------------------------
-- Update modded yields
---------------------------------------------------------------------

MapModData.CityYieldRatesDirty = false
MapModData.CityYields = {}

LuaEvents.CityYieldRatesDirty = LuaEvents.CityYieldRatesDirty or function() end

function PlayerClass.CleanCityYieldRates(player)
	if type(player) == "number" then
		log:Error("CleanCityYieldRates player=%s", player)
		return nil
	end
	--log:Info("%-25s %15s", "CleanCityYieldRates", player:GetName())
	local activePlayer = Players[Game.GetActivePlayer()]
	if MapModData.CityYieldRatesDirty then
		if player == activePlayer then
			MapModData.CityYieldRatesDirty = false
		else
			activePlayer:CleanCityYieldRates()
		end
	end
	MapModData.VEM.UpdateCityYields = true
	
	player:GetYieldsFromCitystates(true)
	player:UpdateModdedHappiness()
	
	--[[
	if player == activePlayer then
		--log:Info("%-40s sci %s/%s +%s", player:GetName(), player:GetYieldStored(YieldTypes.YIELD_SCIENCE), player:GetYieldNeeded(YieldTypes.YIELD_SCIENCE), player:GetYieldRate(YieldTypes.YIELD_SCIENCE))
		if player:GetYieldStored(YieldTypes.YIELD_SCIENCE) >= player:GetYieldNeeded(YieldTypes.YIELD_SCIENCE) then
			--log:Warn("ActivePlayer excess science")
			player:ChangeYieldStored(YieldTypes.YIELD_SCIENCE, 0, player:GetCurrentResearch())
			--activePlayer:SetHasTech(activePlayer:GetCurrentResearch(), true)
		end
		if player:GetYieldStored(YieldTypes.YIELD_CULTURE) >= player:GetYieldNeeded(YieldTypes.YIELD_CULTURE) then
			--log:Warn("ActivePlayer excess culture")
			player:ChangeYieldStored(YieldTypes.YIELD_CULTURE, 0)
			--activePlayer:SetHasTech(activePlayer:GetCurrentResearch(), true)
		end
	end
	--]]
	for yieldInfo in GameInfo.Yields() do
		player:GetSupplyModifier(yieldInfo.ID, true)
		for city in player:Cities() do
			local cityID = City_GetID(city)
			City_GetWeight(city, yieldInfo.ID, true)
			MapModData.CityYields[cityID] = MapModData.CityYields[cityID] or {}
			MapModData.CityYields[cityID][yieldInfo.ID] = City_GetYieldRate(city, yieldInfo.ID)
		end
	end
	MapModData.VEM.UpdateCityYields = false
end

function OnCityYieldRatesDirty()
	if Players[Game.GetActivePlayer()]:IsTurnActive() then
		MapModData.CityYieldRatesDirty = true
		--log:Warn("MapModData.CityYieldRatesDirty = true")
	end
end


function City_UpdateModdedYields(city, cityOwner)	
	--log:Info("%-25s %15s %15s", "City_UpdateModdedYields", cityOwner:GetName(), city:GetName())
	if city:IsResistance() then
		return
	end
	
	local capital = cityOwner:GetCapitalCity()
	if (city == capital
		and not cityOwner:IsHuman()
		and not cityOwner:IsMinorCiv()
		) then
		local yield = Game.GetAverageHumanHandicap()
		if not cityOwner:IsMilitaristicLeader() then
			yield = 0.75 * yield
		end
		if GameInfo.Leaders[cityOwner:GetLeaderType()].AIBonus then
			yield = yield * 1.5
		end
		yield = Game.Round(yield)
		city:SetNumRealBuilding(GameInfo.Buildings.BUILDING_AI_PRODUCTION.ID, math.min(city:GetPopulation(), yield))
		if not city:IsHasBuilding(GameInfo.Buildings.BUILDING_AI_GOLD.ID) then
			city:SetNumRealBuilding(GameInfo.Buildings.BUILDING_AI_GOLD.ID, yield + GameInfo.Yields.YIELD_GOLD.MinPlayer)
			city:SetNumRealBuilding(GameInfo.Buildings.BUILDING_AI_SCIENCE.ID, yield + GameInfo.Yields.YIELD_SCIENCE.MinPlayer)
			city:SetNumRealBuilding(GameInfo.Buildings.BUILDING_AI_CULTURE.ID, yield)
		end
		--log:Debug("Set AI Buildings %3s %25s %25s", City_GetNumBuilding(city, GameInfo.Buildings.BUILDING_AI_PRODUCTION.ID), cityOwner:GetName(), city:GetName())
		cityOwner:CleanCityYieldRates()
	end

	local yieldID = YieldTypes.YIELD_FOOD
	local vanillaYield = city:FoodDifferenceTimes100() / 100
	local modYield = City_GetYieldRate(city, yieldID)
	if modYield ~= vanillaYield and not city:IsFoodProduction() then
		--log:Debug("%20s %15s vanillaYield:%3s modYield:%3s (to food)", cityOwner:GetName(), city:GetName(), Game.Round(vanillaYield), Game.Round(modYield))
		City_ChangeYieldStored(city, yieldID, modYield-vanillaYield)
	end
	
	yieldID = YieldTypes.YIELD_PRODUCTION
	vanillaYield = city:GetCurrentProductionDifferenceTimes100(false, false) / 100
	modYield = City_GetYieldRate(city, yieldID)
	if modYield ~= vanillaYield then
		--log:Debug("%20s %15s vanillaYield:%3s modYield:%3s (to production)", cityOwner:GetName(), city:GetName(), Game.Round(vanillaYield), Game.Round(modYield))
		City_ChangeYieldStored(city, yieldID, modYield-vanillaYield)
	end
	
	yieldID = YieldTypes.YIELD_CULTURE
	vanillaYield = city:GetJONSCulturePerTurn()
	modYield = City_GetYieldRate(city, yieldID)
	if modYield ~= vanillaYield then
		--log:Debug("%20s %15s vanillaYield:%3s modYield:%3s (to culture)", cityOwner:GetName(), city:GetName(), Game.Round(vanillaYield), Game.Round(modYield))
		City_ChangeYieldStored(city, yieldID, modYield-vanillaYield)
	end

	--[[
	if City_GetNumBuilding(city, GameInfo.Buildings.BUILDING_NATIONAL_EPIC.ID) >= 1 then
		for policyInfo in GameInfo.Policy_BuildingClassYieldModifiers("YieldType = 'YIELD_GREAT_PEOPLE'") do
			if cityOwner:HasPolicy(GameInfo.Policies[policyInfo.PolicyType].ID) then
				-- modify specialist yields
			end
		end
	end
	--]]
end

function PlayerClass.UpdateModdedYieldsEnd(player)
	if player:IsMinorCiv() then
		return
	end
	--log:Info("%-25s %15s", "UpdateModdedYieldsEnd", player:GetName())

	GetCurrentUnitSupply(player, true)
	player:UpdateModdedHappiness()
	--CheckPlotCultureYields()
	
	local yieldID = YieldTypes.YIELD_GOLD
	vanillaYield = player:VanillaCalculateGoldRate()
	modYield = player:GetYieldRate(yieldID)
	if modYield ~= vanillaYield then
		if player:IsHuman() then
			--log:Warn("%s %s %s vanilla=%s mod=%s", Game.GetGameTurn(), player:GetName(), GameInfo.Yields[yieldID].Type, vanillaYield, modYield)
		end
		player:ChangeYieldStored(yieldID, modYield-vanillaYield)
	end
	
	local yieldID = YieldTypes.YIELD_SCIENCE
	vanillaYield = player:GetScience()
	modYield = player:GetYieldRate(yieldID)
	if modYield ~= vanillaYield then
		if player:IsHuman() then
			--log:Warn("%s %s %s vanilla=%s mod=%s", Game.GetGameTurn(), player:GetName(), GameInfo.Yields[yieldID].Type, vanillaYield, modYield)
		end
		player:ChangeYieldStored(yieldID, modYield-vanillaYield)
	end
	
	local yieldID = YieldTypes.YIELD_CULTURE
	vanillaYield = player:GetTotalJONSCulturePerTurn()
	modYield = player:GetYieldRate(yieldID)
	if modYield ~= vanillaYield then
		--log:Warn("%s %s %s vanilla=%s mod=%s", Game.GetGameTurn(), player:GetName(), GameInfo.Yields[yieldID].Type, vanillaYield, modYield)
		player:ChangeYieldStored(yieldID, modYield-vanillaYield)
	end
	
	local yieldID = YieldTypes.YIELD_FAITH
	vanillaYield = player:GetTotalFaithPerTurn()
	modYield = player:GetYieldRate(yieldID)
	if modYield ~= vanillaYield then
		--log:Warn("%s %s %s vanilla=%s mod=%s", Game.GetGameTurn(), player:GetName(), GameInfo.Yields[yieldID].Type, vanillaYield, modYield)
		player:ChangeYieldStored(yieldID, modYield-vanillaYield)
	end
	
	local yieldID = YieldTypes.YIELD_HAPPINESS
	modYield = player:GetYieldRate(yieldID)
	if player:GetGoldenAgeTurns() ~= 0 then
		--log:Warn("%s %s %s vanilla=%s mod=%s", Game.GetGameTurn(), player:GetName(), GameInfo.Yields[yieldID].Type, vanillaYield, modYield)
		player:ChangeYieldStored(yieldID, modYield)
	end
end

function PlayerClass.UpdateModdedYieldsStart(player)
	if player:IsMinorCiv() then
		return
	end
	--log:Info("%-25s %15s", "UpdateModdedYieldsStart", player:GetName())
	local playerID = player:GetID()

	GetCurrentUnitSupply(player, true)
	player:UpdateModdedHappiness()
end

function PlayerClass.UpdateModdedHappiness(player)	
	local capital = player:GetCapitalCity()
	if player:IsMinorCiv() or not capital then
		return
	end			
	
	local yieldID = YieldTypes.YIELD_HAPPINESS
	local yield = 0
	yield = yield + player:GetYieldFromTerrain(yieldID)
	yield = yield + player:GetYieldFromSurplusResources(yieldID)
	yield = yield + player:GetYieldsFromCitystates()[yieldID]
	for city in player:Cities() do
		local happiness = City_GetYieldRate(city, yieldID)
		--log:Error("%20s %20s happiness = %s", city:GetName(), player:GetName(), happiness)
		yield = yield + City_GetYieldRate(city, yieldID)
	end

	if yield > 0 then
		--log:Warn("%s has +%s happiness", player:GetName(), yield)
	end
	capital:SetNumRealBuilding(GameInfo.Buildings.BUILDING_EXTRA_HAPPINESS.ID, yield)

	--yield = Game.Round(player:GetYieldRate(yieldID) * Civup.PERCENT_SCIENCE_FOR_1_SURPLUS_HAPPINESS)

	--capital:SetNumRealBuilding(GameInfo.Buildings.BUILDING_SCIENCE_BONUS.ID, Game.Constrain(0, yield, 200))
	--capital:SetNumRealBuilding(GameInfo.Buildings.BUILDING_SCIENCE_PENALTY.ID, Game.Constrain(0, -yield, 90))
end


function PlayerClass.GetYieldFromHappiness(player, yieldID)
	local yield = player:GetMinYieldRate(yieldID)
	if yieldID == YieldTypes.YIELD_SCIENCE then
		yield = player:GetYieldRate(yieldID, true)
		yield = yield * player:GetYieldHappinessMod(yieldID) / 100
	end
	return yield
end

function PlayerClass.GetYieldHappinessMod(player, yieldID)
	local yieldMod = 0
	if yieldID == YieldTypes.YIELD_SCIENCE then
		yieldMod = player:GetYieldRate(YieldTypes.YIELD_HAPPINESS) * Civup.PERCENT_SCIENCE_FOR_1_SURPLUS_HAPPINESS
	end
	return yieldMod
end

function PlayerClass.GetYieldFromTradeDeals(playerUs, yieldID, doUpdate)
	local yieldSum			= 0
	local playerUsID		= playerUs:GetID()
	local teamUsID			= playerUs:GetTeam()
	local teamUs			= Teams[teamUsID]
	local playerUsScience	= Civup.RESEARCH_AGREEMENT_SCIENCE_RATE_PERCENT
	local playerUsGold		= Civup.OPEN_BORDERS_GOLD_RATE_PERCENT
	local goldMod			= Civup.OPEN_BORDERS_GOLD_RATE_PERCENT / 100
	
	goldMod = goldMod * (1 + playerUs:GetTraitInfo().OpenBordersModifier / 100)
	for policyInfo in GameInfo.Policies("OpenBordersModifier <> 0") do
		if playerUs:HasPolicy(policyInfo.ID) then
			goldMod = goldMod * (1 + policyInfo.OpenBordersModifier / 100)
		end
	end
	
	if yieldID == YieldTypes.YIELD_SCIENCE then
		if playerUsScience == nil or playerUsScience == 0 then
			----log:Debug("playerUsScience: %s", playerUsScience)
			return 0
		end
		if playerUs:GetScience() <= 0 then
			----log:Debug("%s - no science for DoF research (%i)", playerUs:GetName(), playerUs:GetScience())
			return 0
		end
		playerUsScience = playerUs:GetYieldRate(yieldID, true)
	elseif yieldID == YieldTypes.YIELD_GOLD then
		if playerUsGold == nil or playerUsGold == 0 then
			----log:Debug("playerUsGold: %s", playerUsGold)
			return 0
		end
		playerUsGold = playerUs:GetBaseYieldRate(yieldID, true)
	else
		----log:Debug("Invalid yield type: %s", GameInfo.Yields[yieldID].Type)
		return 0
	end

	----log:Debug("%s:GetYieldFromTradeDeals(%s)", playerUs:GetName(), GameInfo.Yields[yieldID].Type)
	for playerThemID,playerThem in pairs(Players) do
		if playerThem:IsAliveCiv() and not playerThem:IsMinorCiv() and not (playerThem == playerUs) then
			local teamThemID = playerThem:GetTeam()
			local teamThem = Teams[teamThemID]
			if not teamUs:IsAtWar(teamThemID) then
				local yieldChange = 0
				if yieldID == YieldTypes.YIELD_SCIENCE then
					if teamUs:IsHasResearchAgreement(teamThemID) then
						yieldChange = yieldChange + (playerUsScience + playerThem:GetYieldRate(yieldID, true)) * Civup.RESEARCH_AGREEMENT_SCIENCE_RATE_PERCENT / 100
						----log:Debug("%s has RA with %s", playerUs:GetName(), playerThem:GetName())
					end
				elseif yieldID == YieldTypes.YIELD_GOLD then
					if teamUs:IsAllowsOpenBordersToTeam(teamThemID) and teamThem:IsAllowsOpenBordersToTeam(teamUsID) then
						local themGold = math.max(0, playerThem:GetBaseYieldRate(yieldID, true))
						yieldChange = yieldChange + goldMod * (playerUsGold + themGold)
					end
				end
				if playerUs:IsDoF(playerThemID) then
					yieldChange = yieldChange * (1 + Civup.FRIENDSHIP_TRADE_BONUS_PERCENT / 100)
				end
				----log:Debug("%s %s from %s = %s", playerUs:GetName(), GameInfo.Yields[yieldID].Type, playerThem:GetName(), yieldChange)
				yieldSum = yieldSum + math.ceil(yieldChange)
			end
		end
	end
	if yieldSum > 0 then
		local yieldMod = 1
		for buildingInfo in GameInfo.Buildings("TradeDealModifier != 0") do
			for city in playerUs:Cities() do 
				if city:IsHasBuilding(buildingInfo.ID) then
					yieldMod = yieldMod + buildingInfo.TradeDealModifier / 100
				end
			end
		end
		yieldSum = yieldSum * yieldMod
	end

	return math.max(0, Game.Round(yieldSum))
end

function City_ChangeCulture(city, player, culture)
	city:ChangeJONSCultureStored(culture)
	player:ChangeYieldStored(YieldTypes.YIELD_CULTURE, culture)
	cultureStored = city:GetJONSCultureStored()
	cultureNext = city:GetJONSCultureThreshold()
	cultureDiff = cultureNext - cultureStored
	if cultureDiff < 1 then
		city:DoJONSCultureLevelIncrease()
		city:SetJONSCultureStored(-cultureDiff)
	end
end


---------------------------------------------------------------------
-- Update citystate rewards
---------------------------------------------------------------------

function UpdatePlayerRewardsFromMinorCivs(player)
	log:Warn("UpdatePlayerRewardsFromMinorCivs")
end

Game.UpdatePlayerRewardsFromMinorCivs = UpdatePlayerRewardsFromMinorCivs

function PlayerClass.GetYieldsFromCitystates(player, doUpdate)
	if type(player) == "number" then
		log:Error("player:GetYieldsFromCitystates player=%s", player)
		return nil
	end
	local playerID = player:GetID()
	MapModData.VEM.MinorCivRewards[playerID] = MapModData.VEM.MinorCivRewards[playerID] or {}
	if doUpdate or MapModData.VEM.MinorCivRewards[playerID].Total == nil then
		--log:Debug("Recalculate Player Rewards from Minor Civs %s", player:GetName())
		MapModData.VEM.MinorCivRewards[playerID].Total = {}
		for yieldInfo in GameInfo.Yields() do
			MapModData.VEM.MinorCivRewards[playerID].Total[yieldInfo.ID] = 0
		end
		if not (player:GetNumCities() == 0 or player:IsMinorCiv() or player:IsBarbarian()) then
			for minorCivID,minorCiv in pairs(Players) do
				if minorCiv:IsAliveCiv() and minorCiv:IsMinorCiv() then
					local traitType = minorCiv:GetMinorCivTrait()
					local friendLevel = minorCiv:GetMinorCivFriendshipLevelWithMajor(player:GetID())
					for yieldID,yield in pairs(player:GetCitystateYields(traitType, friendLevel)) do
						MapModData.VEM.MinorCivRewards[playerID].Total[yieldID] = MapModData.VEM.MinorCivRewards[playerID].Total[yieldID] + yield
					end
					--log:Debug("friendLevel with %s = %i", minorCiv:GetName(), friendLevel)
				end
			end
		end
		--log:Debug("player:GetYieldsFromCitystates %s yield=%s", GameInfo.Yields[YieldTypes.YIELD_CS_MILITARY].Type, MapModData.VEM.MinorCivRewards[playerID].Total[YieldTypes.YIELD_CS_MILITARY])
	end
	return MapModData.VEM.MinorCivRewards[playerID].Total
end

function PlayerClass.GetFinalCitystateYield(player, yieldID)
	if type(player) == "number" then
		log:Error("player:GetFinalCitystateYield player=%s", player)
		return nil
	end
	local yieldID = YieldTypes.YIELD_CULTURE
	local csYield = 0
	if player:GetYieldsFromCitystates()[yieldID] == 0 then
		return csYield
	end
	for city in player:Cities() do
		local cityYield = City_GetBaseYieldFromMinorCivs(city, yieldID)
		cityYield = cityYield * (1 + City_GetBaseYieldRateModifier(city, yieldID) / 100)
		cityYield = cityYield * (1 + City_GetSurplusYieldRateModifier(city, yieldID) / 100)
		csYield = csYield + cityYield
	end
	return csYield
end

function PlayerClass.GetCitystateYields(player, traitType, friendLevel)
	local yields = {}
	local query = ""
	if friendLevel <= 0 then
		return yields
	end

	for yieldInfo in GameInfo.Yields() do
		yields[yieldInfo.ID] = {Base=0, PerEra=0}		
	end
	
	query = string.format("FriendLevel = '%s'", friendLevel)
	for traitInfo in GameInfo.MinorCivTrait_Yields(query) do
		if GameInfo.MinorCivTraits[traitInfo.TraitType].ID == traitType then
			local yieldID = GameInfo.Yields[traitInfo.YieldType].ID
			yields[yieldID].Base = yields[yieldID].Base + traitInfo.Yield
			yields[yieldID].PerEra = yields[yieldID].PerEra + traitInfo.YieldPerEra
		end
	end
	
	for row in GameInfo.Policy_MinorCivBonuses(query) do
		if player:HasPolicy(GameInfo.Policies[row.PolicyType].ID) then
			local yieldID = GameInfo.Yields[row.YieldType].ID
			yields[yieldID].Base = yields[yieldID].Base + row.Yield
			yields[yieldID].PerEra = yields[yieldID].PerEra + row.YieldPerEra
		end
	end

	for yieldID, yield in pairs(yields) do
		if yield.Base == 0 and yield.PerEra == 0 then
			yields[yieldID] = 0
		else
			yields[yieldID] = yield.Base + yield.PerEra * (1 + player:GetCurrentEra())
			local numCities = player:GetNumCities()
			if yieldID ~= YieldTypes.YIELD_CS_MILITARY and numCities < 4 then
				yields[yieldID] = (1 - 0.2*(4-numCities)) * yields[yieldID]
			end
			yields[yieldID] = math.ceil(yields[yieldID] * (1 + player:GetTraitInfo().CityStateBonusModifier / 100))
		end
	end
	return yields
end

function PlayerClass.GetAvoidModifier(player, doUpdate)
	if type(player) ~= "table" then
		log:Fatal("player:GetAvoidModifier player=%s", player)
	elseif MapModData.VEM == nil then
		log:Warn("player:GetAvoidModifier: VEM Not Initialized Yet")
		return 0
	end
	
	local playerID = player:GetID()
	if true then --doUpdate then
		--log:Debug("Recalculate Avoid Modifier ", player)
		local player = Players[playerID]
		local numAvoid = 0
		local numCities = 0
		for city in player:Cities() do
			numAvoid = numAvoid + (city:IsForcedAvoidGrowth() and 1 or 0)
			numCities = numCities + (not city:IsPuppet() and 1 or 0)
		end
		MapModData.VEM.AvoidModifier[playerID] = math.max(0, 1 + (numAvoid / numCities - 1) / (1 - Civup.AVOID_GROWTH_FULL_EFFECT_CUTOFF / 100))
	end
	return MapModData.VEM.AvoidModifier[playerID] or 0
end

function PlayerClass.GetTotalWeight(player, yieldID, doUpdate)
	if MapModData.VEM == nil then
		log:Warn("player:GetTotalWeight: TBM Not Yet Initialized")
		return 1
	end
	if player == nil then
		log:Fatal("player:GetTotalWeight: Invalid player")
	end

	local playerID = player:GetID()
	local totalWeight = 0
	if MapModData.VEM.CityWeights[playerID] and MapModData.VEM.CityWeights[playerID][yieldID] then
		for k,v in pairs(MapModData.VEM.CityWeights[playerID][yieldID]) do
			if player:GetCityByID(k) ~= nil and player:GetCityByID(k):GetOwner() == playerID then
				totalWeight = totalWeight + v
			else
				v = nil
			end
		end
	end
	if totalWeight == 0 then
		return 1
	else
		return totalWeight
	end
end

function City_GetWeight(city, yieldID, doUpdate)
	if MapModData.VEM == nil then
		log:Warn("City_GetWeight: VEM Not Initialized Yet")
		return 0
	elseif city == nil then
		log:Fatal("City_GetWeight city=nil")
	elseif yieldID == nil then
		log:Fatal("City_GetWeight yieldID=nil")
	end
	--log:Error(string.format("City_GetWeight %s %s %s", city:GetName(), GameInfo.Yields[yieldID].Description, tostring(doUpdate)))
	local ownerID = city:GetOwner()
	local owner = Players[ownerID]
	if doUpdate or not (MapModData.VEM.CityWeights[ownerID] and MapModData.VEM.CityWeights[ownerID][yieldID] and MapModData.VEM.CityWeights[ownerID][yieldID][city:GetID()]) then
		MapModData.VEM.CityWeights[ownerID] = MapModData.VEM.CityWeights[ownerID] or {}
		MapModData.VEM.CityWeights[ownerID][yieldID] = MapModData.VEM.CityWeights[ownerID][yieldID] or {}

		local weight = 1
		for v in GameInfo.CityWeights() do
			if v.IsCityStatus == true and city[v.Type](city) then
				local result = city[v.Type](city)
				weight = weight * v.Value * ((type(result) == type(1)) and result or 1)
			end
		end
		if city:GetFocusType() == CityYieldFocusTypes[yieldID] then
			weight = weight * GameInfo.CityWeights.CityFocus.Value
		end
		if not Players[ownerID]:IsCapitalConnectedToCity(city) then
			weight = weight * GameInfo.CityWeights.NotConnected.Value
		end
		if yieldID == YieldTypes.YIELD_FOOD and city:IsForcedAvoidGrowth() then
			weight = weight * owner:GetAvoidModifier(doUpdate)
		end	
		MapModData.VEM.CityWeights[ownerID][yieldID][city:GetID()] = math.max(0, weight)
	end
	--log:Error("Weight = "..MapModData.VEM.CityWeights[ownerID][yieldID][city:GetID()])
	return MapModData.VEM.CityWeights[ownerID][yieldID][city:GetID()]
end

---------------------------------------------------------------------
---------------------------------------------------------------------