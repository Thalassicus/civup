-- TU-Player
-- Author: Thalassicus
-- DateCreated: 2/29/2012 8:19:24 AM
--------------------------------------------------------------

include("MT_LuaLogger.lua")
local log = Events.LuaLogger:New()
log:SetLevel("INFO")


PlayerClass = getmetatable(Players[0]).__index

---------------------------------------------------------------------
--[[ player:GetBuildingAddonLevel(buildingID) usage example:

]]
function PlayerClass.GetBuildingAddonLevel(player, buildingID)
	local parentClass = GameInfo.Buildings[buildingID].AdditionParent
	if parentClass then
		return (1 + player:GetBuildingAddonLevel(player:GetUniqueBuildingID(parentClass)))
	end
	return 0
end

---------------------------------------------------------------------
-- PlayerClass:GetCapitalCity()
-- fixes bug with vanilla version
--
if not PlayerClass.VanillaGetCapitalCity then
	PlayerClass.VanillaGetCapitalCity = PlayerClass.GetCapitalCity
	function PlayerClass.GetCapitalCity(player)
		local capital = player:VanillaGetCapitalCity()
		if not capital then
			for city in player:Cities() do
				if city then
					capital = city
					city:SetNumRealBuilding(player:GetUniqueBuildingID("BUILDINGCLASS_PALACE"), 1)
					log:Warn("%20s capital set to %-s", player:GetName(), city:GetName())
					break
				end
			end
		end
		return capital
	end
end


---------------------------------------------------------------------
-- player:GetDeals()
--
function PlayerClass.GetDeals(player)
	local playerID = player:GetID()
	local deal = UI.GetScratchDeal()
	local dealList = {}
	for index, name in ipairs(TradeableItems) do
		dealList[index] = {}
		for playerID, player in pairs(Players) do
			dealList[index][playerID] = {}
		end
	end

    local numDeals = UI:GetNumCurrentDeals(playerID) --works only for active player?
    if numDeals > 0 then
	    for dealID = 0, numDeals - 1 do
			UI.LoadCurrentDeal(playerID, dealID)
			deal:ResetIterator()
			local itemType, duration, finalTurn, data1, data2, fromPlayerID = deal:GetNextItem()			
			while itemType do
				--log:Debug("activePlayerID=%s fromPlayer=%s", Game.GetActivePlayer(), Players[fromPlayerID])
				--log:Debug("itemType=%s duration=%s finalTurn=%s data1=%s data2=%s fromPlayerID=%s", itemType, duration, finalTurn, data1, data2, fromPlayerID)
				dealList[itemType] = dealList[itemType] or {}
				dealList[itemType][fromPlayerID] = dealList[itemType][fromPlayerID] or {}
				table.insert(dealList[itemType][fromPlayerID], {duration=duration, finalTurn=finalTurn, data1=data1, data2=data2, fromPlayerID=fromPlayerID})
				itemType, duration, finalTurn, data1, data2, fromPlayerID = deal:GetNextItem()
			end
		end
	end
	return dealList
end

---------------------------------------------------------------------
-- player:GetPossibleDeals()
--
function PlayerClass.GetPossibleDeals(player)
	local playerID = player:GetID()
	local deals = {
		{icon="[ICON_CAPITAL]", name="embassies", num=0},
		{icon="[ICON_TRADE]", name="border deals", num=0},
		{icon="[ICON_RESEARCH]", name="research deals", num=0},
		{icon="[ICON_STRENGTH]", name="defense pacts", num=0},
		{icon="[ICON_TEAM_8]", name="alliances", num=0}
	}
	local deal = UI.GetScratchDeal()
	for targetPlayerID, targetPlayer in pairs(Players) do
		if targetPlayer:IsAliveCiv() and targetPlayerID ~= playerID and not targetPlayer:IsMinorCiv() and targetPlayer:IsAtPeace(player) then
			if deal:IsPossibleToTradeItem(targetPlayerID, playerID, TradeableItems.TRADE_ITEM_ALLOW_EMBASSY, Game.GetDealDuration()) then
				log:Debug("%15s embassy", targetPlayer:GetName())
				deals[1].num = deals[1].num + 1
			end
			if deal:IsPossibleToTradeItem(targetPlayerID, playerID, TradeableItems.TRADE_ITEM_OPEN_BORDERS, Game.GetDealDuration()) then
				log:Debug("%15s border deal", targetPlayer:GetName())
				deals[2].num = deals[2].num + 1
			end
			if deal:IsPossibleToTradeItem(targetPlayerID, playerID, TradeableItems.TRADE_ITEM_RESEARCH_AGREEMENT, Game.GetDealDuration()) then
				log:Debug("%15s research deal", targetPlayer:GetName())
				deals[3].num = deals[3].num + 1
			end
			if deal:IsPossibleToTradeItem(targetPlayerID, playerID, TradeableItems.TRADE_ITEM_DEFENSIVE_PACT, Game.GetDealDuration()) then
				log:Debug("%15s defense deal", targetPlayer:GetName())
				deals[4].num = deals[4].num + 1
			end
			if player:IsHuman() and targetPlayer:IsHuman() then
				if deal:IsPossibleToTradeItem(targetPlayerID, playerID, TradeableItems.TRADE_ITEM_DECLARATION_OF_FRIENDSHIP, Game.GetDealDuration()) then
					log:Debug("%15s alliance", targetPlayer:GetName())
					deals[5].num = deals[5].num + 1
				end
			elseif (not targetPlayer:IsDoF(playerID) and not targetPlayer:IsDoFMessageTooSoon(playerID)) then
				log:Debug("%15s alliance", targetPlayer:GetName())
				deals[5].num = deals[5].num + 1
			end
		end
	end
	return deals
end

------------------------------------------------------------------
-- approachType:GetMinorApproach()
--
function PlayerClass.GetMinorApproach(player, approachType)
	for row in GameInfo.Leader_MinorCivApproachBiases(
			string.format(
				"LeaderType='%s' AND MinorCivApproachType='%s'", 
				GameInfo.Leaders[player:GetLeaderType()].Type,
				approachType
			)
		) do
		return row.bias
	end
	log:Fatal("player:GetMinorApproach: %s not a valid approach type!", approachType)	
	return false
end

------------------------------------------------------------------
-- player:GetRivalInfluence(minorCiv) returns the ID and influence of player's rival for minorCiv
--
function PlayerClass.GetRivalInfluence(player, minorCiv)
	local playerID 			= player:GetID()
	local rivalID			= -1
	local rivalInfluence	= 0
	for majorCivID, majorCiv in pairs(Players) do
		if majorCiv:IsAliveCiv() and not majorCiv:IsMinorCiv() and majorCivID ~= playerID then
			local influence = minorCiv:GetMinorCivFriendshipWithMajor(majorCivID)
			if influence > rivalInfluence then
				rivalID = majorCivID
				rivalInfluence = influence
			end
		end
	end
	return rivalInfluence, rivalID
end

---------------------------------------------------------------------
--[[ player:GetPurchaseCostMod usage example:

]]
function PlayerClass.GetPurchaseCostMod(player, baseCost, hurryCostMod)
	local costMultiplier = -1
	if hurryCostMod == -1 then
		return costMultiplier
	end
	costMultiplier = math.pow(baseCost * GameDefines.GOLD_PURCHASE_GOLD_PER_PRODUCTION, GameDefines.HURRY_GOLD_PRODUCTION_EXPONENT)
	costMultiplier = costMultiplier * (1 + hurryCostMod / 100)
	local empireMod = 100

	for row in GameInfo.Building_HurryModifiers() do
		for city in player:Cities() do
			if city:IsHasBuilding(GameInfo.Buildings[row.BuildingType].ID) then
				empireMod = empireMod + row.HurryCostModifier
			end
		end
	end
	for row in GameInfo.Policy_HurryModifiers() do
		if player:HasPolicy(GameInfo.Policies[row.PolicyType].ID) then
			empireMod = empireMod + row.HurryCostModifier
		end
	end
	costMultiplier = (costMultiplier * empireMod) / 100
	costMultiplier = Game.Round(costMultiplier / baseCost * 100, -1)
	return costMultiplier
end


---------------------------------------------------------------------
-- player:GetResourceQuantities(resID)
--
function PlayerClass.GetResourceQuantities(player, resID)
	local res	= {
		IsStrategic	= (Game.GetResourceUsageType(resID) == ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC),
		IsLuxury	= (Game.GetResourceUsageType(resID) == ResourceUsageTypes.RESOURCEUSAGE_LUXURY),
		isBonus		= (Game.GetResourceUsageType(resID) == ResourceUsageTypes.RESOURCEUSAGE_BONUS),
		Tradable	= player:GetNumResourceTotal(resID, false),
		Available	= player:GetNumResourceAvailable(resID, true),
		Used		= player:GetNumResourceUsed(resID, true),
		Imported	= player:GetResourceImport(resID),
		Exported	= player:GetResourceExport(resID),
		Citystates	= player:GetResourceFromMinors(resID)
	}

	if not res.IsStrategic and (res.Available > 0) and (res.Available == res.Tradable) then
		res.Tradable = res.Tradable - 1
	end

	res.Active = false
	res.Color = (res.Available == 0) and "[COLOR_GREY]" or "[COLOR_WHITE]"
	
	if res.Tradable > 0 then
		res.Color = "[COLOR_GREEN]"
	elseif res.IsStrategic then
		if res.Available < 0 then
			res.Color = "[COLOR_RED]"
		end
	elseif res.Available == 0 then
		if res.Exported > 0 then
			res.Color = "[COLOR_RED]"
		end
		if player:GetID() == Game.GetActivePlayer() then
			res.Cities, res.NumCities = player:GetCitiesDemandingResource(resID)
			if res.Cities then
				res.Color = "[COLOR_YELLOW]"
			end
		end
	end
	return res
end


---------------------------------------------------------------------
-- player:GetCitiesDemandingResource(resourceID)
-- returns a table of {cityID, city} pairs
function PlayerClass.GetCitiesDemandingResource(player, resourceID)
	local cities = nil
	local numCities = 0
	for city in player:Cities() do
		if city:GetWeLoveTheKingDayCounter() == 0 and city:GetResourceDemanded(true) == resourceID then
			cities = cities or {}
			cities[City_GetID(city)] = city
			numCities = numCities + 1
		end
	end
	return cities, numCities
end

------------------------------------------------------------------
--[[ usage: somePlayer:GetTraitInfo()
local trait = somePlayer:GetTraitInfo()
]]

function PlayerClass.GetTraitInfo(player)
	if not GameInfo.Leaders[player:GetLeaderType()] then
		log:Error("%s is not a leader", player:GetName())
		return nil
	end
	local leaderType = GameInfo.Leaders[player:GetLeaderType()].Type
	local traitType = GameInfo.Leader_Traits("LeaderType ='" .. leaderType .. "'")().TraitType
	return GameInfo.Traits[traitType]
end

------------------------------------------------------------------
-- player:GetPersonalityInfo()
--
function PlayerClass.GetPersonalityInfo(player)
	local leaderInfo = GameInfo.Leaders[player:GetLeaderType()]
	if not leaderInfo then
		log:Error("%s is not a leader", player:GetName())
		return nil
	elseif not leaderInfo.Personality then
		log:Error("%s has no personality", player:GetName())
		return nil
	end
	return GameInfo.Personalities[leaderInfo.Personality]
end

---------------------------------------------------------------------
--[[ player:GetTurnAcquired(city) usage example:

]]
function PlayerClass.GetTurnAcquired(player, city)
	if not city then
		log:Fatal("player:GetTurnAcquired city=nil")
		return nil
	end
	local playerID = player:GetID()
	local cityID = City_GetID(city)
	MapModData.VEM.TurnAcquired[playerID] = MapModData.VEM.TurnAcquired[playerID] or {}
	return MapModData.VEM.TurnAcquired[playerID][City_GetID(city)]
end

function PlayerClass.SetTurnAcquired(player, city, turn)
	if not city then
		log:Fatal("player:SetTurnAcquired city=nil")
		return nil
	end
	local playerID = player:GetID()
	local cityID = City_GetID(city)
	MapModData.VEM.TurnAcquired[playerID] = MapModData.VEM.TurnAcquired[playerID] or {}
	MapModData.VEM.TurnAcquired[playerID][cityID] = turn
	SaveValue(turn, "MapModData.VEM.TurnAcquired[%s][%s]", playerID, cityID)
end

function UpdateTurnAcquiredFounding(hexPos, playerID, cityID, cultureType, eraType, continent, populationSize, size, fowState)
	local player = Players[playerID]
	player:SetTurnAcquired(player:GetCityByID(cityID), Game.GetGameTurn())	
end

function UpdateTurnAcquiredCapture(plot, lostPlayerID, cityID, wonPlayerID)
	local player = Players[wonPlayerID]
	player:SetTurnAcquired(player:GetCityByID(cityID), Game.GetGameTurn())
end

---------------------------------------------------------------------
--[[ player:GetUniqueUnitID(itemClass) usage example:
player:InitUnit( player:GetUniqueUnitID("UNITCLASS_ARCHER"),  x, y )
capitalCity:SetNumRealBuilding(player:GetUniqueBuildingID("BUILDINGCLASS_MARKET"), 1)
]]

function PlayerClass.GetUniqueUnitID(player, classType)
	local civType = GameInfo.Civilizations[player:GetCivilizationType()].Type
	if not classType then
		log:Error("Invalid unit class: %s", classType)
		return nil
	end
	if not GameInfo.UnitClasses[classType].DefaultUnit then
		log:Error("Invalid unit class: %s", classType)
		return nil
	end
	local unitType = GameInfo.UnitClasses[classType].DefaultUnit
	if civType ~= "CIVILIZATION_MINOR" and civType ~= "CIVILIZATION_BARBARIAN" then
		local query = string.format("CivilizationType = '%s' AND UnitClassType = '%s'", civType, classType)
		for itemInfo in GameInfo.Civilization_UnitClassOverrides(query) do
			unitType = itemInfo.UnitType
			break
		end
	end
	return GameInfo.Units[unitType].ID
end

function PlayerClass.GetUniqueBuildingID(player, classType)
	if not player then
		log:Error("player:GetUniqueBuildingID player=nil")
		return nil
	end
	if not GameInfo.Civilizations[player:GetCivilizationType()] then
		log:Error("player:GetUniqueBuildingID invalid civilization: player=%s classType=%s", player:GetName(), classType)
		return nil
	end
	local civType = GameInfo.Civilizations[player:GetCivilizationType()].Type
	local classType = GameInfo.BuildingClasses[classType]
	if not classType then
		log:Error("Invalid building class: %s", classType)
		return nil
	end
	classType = classType.DefaultBuilding
	if civType ~= "CIVILIZATION_MINOR" and civType ~= "CIVILIZATION_BARBARIAN" then
		for itemInfo in GameInfo.Civilization_BuildingClassOverrides(string.format("BuildingClassType = '%s'", classType)) do
			if civType == itemInfo.CivilizationType then
				classType = itemInfo.BuildingType
				break
			end
		end
	end
	return GameInfo.Buildings[classType].ID
end

------------------------------------------------------------------
-- minorCiv:GetMinorYieldString(showDetails)
--
function PlayerClass.GetMinorYieldString(minorCiv, showDetails)
	local yieldString		= ""
	local query				= ""
	local activePlayerID	= Game.GetActivePlayer()
	local activePlayer		= Players[activePlayerID]
	local traitID			= minorCiv:GetMinorCivTrait()
	local friendLevel		= minorCiv:GetMinorCivFriendshipLevelWithMajor(activePlayerID)
	local yieldValue		= 0
	if friendLevel <= 0 then
		return false
	end
	local yieldList = activePlayer:GetCitystateYields(traitID, friendLevel)
	--log:Trace("GetCitystateYields(%s, %s) = %s", GameInfo.MinorCivTraits[traitID].Type, friendLevel, yieldList)
	for yieldInfo in GameInfo.Yields() do
		yieldID = yieldInfo.ID
		local yieldName = ""
		if showDetails then
			yieldName = Locale.ConvertTextKey(yieldInfo.Description) .. " "
		end
		if yieldID == YieldTypes.YIELD_SCIENCE then
			if friendLevel >= 2 then
				for policyInfo in GameInfo.Policies("MinorScienceAllies = 1") do
					if activePlayer:HasPolicy(policyInfo.ID) then
						if showDetails then
							yieldName = yieldName .. "[NEWLINE]"
						end
						yieldString = string.format(
							"%s%s[COLOR_POSITIVE_TEXT]%s[ENDCOLOR] %s",
							yieldString,
							yieldInfo.IconString,
							Game.Round(0.25 * minorCiv:GetYieldRate(yieldID)),
							yieldName
						)
					end
				end
			end
		elseif yieldID == YieldTypes.YIELD_HAPPINESS then
			query = string.format("FriendLevel = %s AND YieldType = '%s'", friendLevel, yieldInfo.Type)
			for row in GameInfo.Policy_MinorCivBonuses(query) do
				if activePlayer:HasPolicy(GameInfo.Policies[row.PolicyType].ID) then
					if showDetails then
						yieldName = yieldName .. "[NEWLINE]"
					end
					yieldString = string.format(
						"%s%s[COLOR_POSITIVE_TEXT]%s[ENDCOLOR] %s",
						yieldString,
						yieldInfo.IconString,
						row.Yield, 
						yieldName
					)
				end
			end
		elseif yieldID == YieldTypes.YIELD_PRODUCTION then
			query = string.format("FriendLevel = %s AND YieldType = '%s'", friendLevel, yieldInfo.Type)
			for row in GameInfo.Policy_MinorCivBonuses(query) do
				if activePlayer:HasPolicy(GameInfo.Policies[row.PolicyType].ID) then
					if showDetails then
						yieldName = string.format("%s(%s)[NEWLINE]", yieldName, Locale.ConvertTextKey("TXT_KEY_PER_CITY"))
					end
					yieldString = string.format(
						"%s%s[COLOR_POSITIVE_TEXT]%s[ENDCOLOR] %s",
						yieldString,
						yieldInfo.IconString,
						row.Yield, 
						yieldName
					)
				end
			end
		elseif yieldList[yieldID] > 0 and (not showDetails
											or yieldID == YieldTypes.YIELD_FOOD
											or yieldID == YieldTypes.YIELD_CULTURE
											or yieldID == YieldTypes.YIELD_EXPERIENCE
											) then
			if showDetails then
				if yieldID == YieldTypes.YIELD_EXPERIENCE then
					yieldName = string.format("%s(%s)[NEWLINE]", yieldName, Locale.ConvertTextKey("TXT_KEY_MILITARY_UNIT_REWARDS"))
				else
					yieldName = string.format("%s(%s)[NEWLINE]", yieldName, Locale.ConvertTextKey("TXT_KEY_SPLIT_AMONG_CITIES"))
				end
			end
			yieldString = string.format(
				"%s%s[COLOR_POSITIVE_TEXT]%s[ENDCOLOR] %s",
				yieldString,
				yieldInfo.IconString,
				yieldList[yieldID], 
				yieldName
			)
		end
	end
	if showDetails then
		yieldString = yieldString .. minorCiv:GetCitystateThresholdString()
	end
	return Game.RemoveExtraNewlines(yieldString)
end

------------------------------------------------------------------
-- minorCiv:GetCitystateThresholdString()
--
function PlayerClass.GetCitystateThresholdString(minorCiv)
	local csString = ""
	local activePlayerID = Game.GetActivePlayer()
	local activePlayer = Players[activePlayerID]
	if not (minorCiv:IsAllies(activePlayerID) or minorCiv:IsFriends(activePlayerID)) then
		return ""
	end
	
	local traitID 		= minorCiv:GetMinorCivTrait()
	local yieldType		= nil
	local yieldStored	= 0
	local yieldNeeded	= 0
	local yieldRate		= 0
	local turnsLeft		= "-"
	
	--print("GetCitystateThresholdString")
	if Civup.MINOR_CIV_MILITARISTIC_REWARD_NEEDED ~= 0 and traitID == MinorCivTraitTypes.MINOR_CIV_TRAIT_MILITARISTIC then
		yieldType		= YieldTypes.YIELD_CS_MILITARY
		yieldStored		= activePlayer:GetYieldStored(yieldType)
		yieldNeeded		= activePlayer:GetYieldNeeded(yieldType)
		yieldRate		= activePlayer:GetYieldRate(yieldType)
		turnsLeft		= "-"

		if yieldRate > 0 then
			turnsLeft = math.ceil((yieldNeeded - yieldStored) / yieldRate)
			yieldRate = "[COLOR_POSITIVE_TEXT] +" .. yieldRate .. "[ENDCOLOR]"
		else
			yieldRate = ""
		end
		
		--log:Debug("yieldStored=%s yieldNeeded=%s yieldRate=%s", yieldStored, yieldNeeded, yieldRate)
		csString = csString .. Locale.ConvertTextKey("TXT_KEY_DIPLO_STATUS_MILITARISTIC_REWARD_TT", turnsLeft, yieldStored, yieldNeeded, yieldRate) .. "[NEWLINE]"
	end

	if Civup.MINOR_CIV_GREAT_PERSON_REWARD_NEEDED ~= 0  then
		yieldType 		= YieldTypes.YIELD_CS_GREAT_PEOPLE
		yieldStored		= activePlayer:GetYieldStored(yieldType)
		yieldNeeded		= activePlayer:GetYieldNeeded(yieldType)
		yieldRate		= activePlayer:GetYieldRate(yieldType)
		turnsLeft		= "-"

		if yieldRate > 0 then
			turnsLeft = math.ceil((yieldNeeded - yieldStored) / yieldRate)
			yieldRate = "[COLOR_POSITIVE_TEXT] +" .. yieldRate .. "[ENDCOLOR]"
		
			--log:Debug("yieldStored=%s yieldNeeded=%s yieldRate=%s", yieldStored, yieldNeeded, yieldRate)
			csString = csString .. Locale.ConvertTextKey("TXT_KEY_DIPLO_STATUS_GREAT_PERSON_REWARD_TT", turnsLeft, yieldStored, yieldNeeded, yieldRate) .. "[NEWLINE]"
		end
	end
	return csString
end

---------------------------------------------------------------------
--[[ player:HasTech(tech) usage example:

]]
function PlayerClass.HasTech(player, tech)
	return Teams[player:GetTeam()]:IsHasTech(GameInfo.Technologies[tech].ID)
end

---------------------------------------------------------------------
-- player:GetImprovableResources()
--
function PlayerClass.GetImprovableResources(player)
	local playerID = player:GetID()
	local plotList = nil
	local activePlayer = Players[Game.GetActivePlayer()]
	for city in player:Cities() do
		if not city:IsRazing() then
			for _, plot in pairs(Plot_GetPlotsInCircle(city:Plot(), 1, 4)) do
				local resID = plot:GetResourceType(Game.GetActiveTeam())
				if plot:GetOwner() == playerID and resID ~= -1 and Game.GetResourceUsageType(resID) ~= ResourceUsageTypes.RESOURCEUSAGE_BONUS then
					local query = string.format("ResourceType = '%s'", GameInfo.Resources[resID].Type)
					for info in GameInfo.Improvement_ResourceTypes(query) do
						local improveInfo = GameInfo.Improvements[info.ImprovementType]
						local techType = Game.GetValue("PrereqTech", {ImprovementType=improveInfo.Type}, GameInfo.Builds)
						if (not improveInfo.CreatedByGreatPerson
							and not improveInfo.SpecificCivRequired
							and (improveInfo.Water == plot:IsWater())
							and (plot:IsImprovementPillaged() or plot:GetImprovementType() ~= improveInfo.ID)
							and (not techType or activePlayer:HasTech(techType))
							) then
							plotList = plotList or {}
							plotList[Plot_GetID(plot)] = improveInfo.ID
						end
					end
				end
			end				
		end
	end
	return plotList
end

function PlayerClass.ImproveResources(player, plotList)
	plotList = plotList or player:GetImprovableResources()
	if not plotList then
		return
	end
	for plotID, improveID in pairs(plotList) do
		local plot = Map.GetPlotByIndex(plotID)
		if plot:IsImprovementPillaged() then
			plot:SetImprovementPillaged(false)
		else
			Plot_BuildImprovement(plot, improveID)
		end
	end
end

---------------------------------------------------------------------
--[[ player:SetHasTech(tech) usage example:

]]
function PlayerClass.SetHasTech(player, tech, isResearched)
	local techID = GameInfo.Technologies[tech].ID
	Teams[player:GetTeam()]:GetTeamTechs():SetHasTech(techID, isResearched)
	player:SetResearchingTech(techID, not isResearched)
end

---------------------------------------------------------------------
--[[ player:HasBuilding(building) usage example:

]]
function PlayerClass.HasBuilding(player, building)
	for city in player:Cities() do
		if City_GetNumBuilding(city, building) ~= 0 then
			return true
		end
	end
	return false
end

---------------------------------------------------------------------
--[[ player:InitUnitType(unit, plot, experience) usage example:

local availableIDs	= City_GetBuildableUnitIDs(player)
local newUnitID		= availableIDs[1 + Map.Rand(#availableIDs, "InitUnitFromList")]
local capitalPlot	= capitalCity:Plot()
local exp			= (1 + player:GetCurrentEra()) * Civup.MINOR_CIV_MILITARISTIC_XP_PER_ERA
player:InitUnitType(newUnitID, capitalPlot, exp)
]]

function PlayerClass.InitUnitType(player, unit, plot, exp)
	local newUnit = player:InitUnit(GameInfo.Units[unit].ID, plot:GetX(), plot:GetY())
	if exp then
		newUnit:ChangeExperience(exp)
		newUnit:SetPromotionReady(newUnit:GetExperience() >= newUnit:ExperienceNeeded())
	end
	return newUnit
end

---------------------------------------------------------------------
--[[ player:InitUnitClass(unitClassType, plot, experience) usage example:

local availableIDs	= City_GetBuildableUnitIDs(player)
local newUnitID		= availableIDs[Map.Rand(#availableIDs, "InitUnitFromList")]
local capitalPlot	= capitalCity:Plot()
local exp			= (1 + player:GetCurrentEra()) * Civup.MINOR_CIV_MILITARISTIC_XP_PER_ERA
player:InitUnitType(newUnitID, capitalPlot, exp)
]]

function PlayerClass.InitUnitClass(player, unitClassType, plot, exp)
	if not unitClassType then
		log:Error("%s InitUnitClass unitClassType=nil", player:GetName())
		return
	end
	local newUnit = player:InitUnit( player:GetUniqueUnitID(unitClassType), plot:GetX(), plot:GetY() )
	if exp then
		newUnit:ChangeExperience(exp)
	end
	return newUnit
end

----------------------------------------------------------------
--[[ player:IsAliveCiv() usage example:
for playerID,player in pairs(Players) do
	if player:IsAliveCiv() and player:IsMinorCiv() then
		local capitalCity = player:GetCapitalCity()
		player:InitUnit( GameInfo.Units.UNIT_ARCHER.ID, capitalCity:GetX(), capitalCity:GetY() )
		player:InitUnit( GameInfo.Units.UNIT_WARRIOR.ID, capitalCity:GetX(), capitalCity:GetY() )
		player:InitUnit( GameInfo.Units.UNIT_WARRIOR.ID, capitalCity:GetX(), capitalCity:GetY() )
	end
end
]]

function PlayerClass.IsAliveCiv(player)
	return player and player:IsAlive() and not player:IsBarbarian()
end

---------------------------------------------------------------------
--[[ AI Functions

]]

function PlayerClass.IsMilitaristicLeader(player)
	local personality = player:GetPersonalityInfo().Type
	return (personality == "PERSONALITY_CONQUEROR" or personality == "PERSONALITY_COALITION")
end

function PlayerClass.IsAtWarWithHuman(player)
	for otherPlayerID, otherPlayer in pairs(Players) do
		if player:IsAtWar(otherPlayer) and otherPlayer:IsHuman() then
			return true
		end
	end
	return false
end

function PlayerClass.IsAtWarWithAny(player)
	for otherPlayerID, otherPlayer in pairs(Players) do
		if player:IsAtWar(otherPlayer) then
			return true
		end
	end
	return false
end

function PlayerClass.EverAtWarWithHuman(player)
	return (MapModData.VEM.EverAtWarWithHuman[player:GetID()] == 1)
end

---------------------------------------------------------------------
--[[ player:Is

]]
function PlayerClass.HasMet(player, otherPlayer)
	if not player or not otherPlayer then
		log:Fatal("player:HasMet player=%s otherPlayer=%s", player, otherPlayer)
		return
	end
	return Teams[player:GetTeam()]:IsHasMet(otherPlayer:GetTeam())
end

function PlayerClass.IsAtWar(player, otherPlayer)
	if not player or not otherPlayer then
		log:Fatal("player:IsAtWar player=%s otherPlayer=%s", player, otherPlayer)
		return
	end
	return Teams[player:GetTeam()]:IsAtWar(otherPlayer:GetTeam())
end

function PlayerClass.IsAtPeace(player, otherPlayer)
	if not player or not otherPlayer then
		log:Fatal("player:IsAtPeace player=%s otherPlayer=%s", player, otherPlayer)
		return
	end
	return player:HasMet(otherPlayer) and not player:IsAtWar(otherPlayer)
end

---------------------------------------------------------------------
--[[ minorCiv:SetFriendship(majorCivID, friendship) usage example:

]]
function PlayerClass.SetFriendship(minorCiv, majorCivID, friendship)
	minorCiv:ChangeMinorCivFriendshipWithMajor(majorCivID, friendship - minorCiv:GetMinorCivFriendshipLevelWithMajor(majorCivID))
end









--
-- Initialization
--

--function InitTurnAcquired()
	if not MapModData.VEM.TurnAcquired then
		--print("InitTurnAcquired()")
		MapModData.VEM.TurnAcquired = {}
		startClockTime = os.clock()
		for playerID, player in pairs(Players) do
			MapModData.VEM.TurnAcquired[playerID] = {}
			if player:IsAliveCiv() then
				for city in player:Cities() do
					local cityID = City_GetID(city)
					if UI:IsLoadedGame() then
						MapModData.VEM.TurnAcquired[playerID][cityID] = LoadValue("MapModData.VEM.TurnAcquired[%s][%s]", playerID, cityID) 
					end
					if not MapModData.VEM.TurnAcquired[playerID][cityID] then
						player:SetTurnAcquired(city, city:GetGameTurnAcquired())
					end
				end
			end
		end
		if UI:IsLoadedGame() then
			log:Warn("%-10s seconds loading TurnAcquired", Game.Round(os.clock() - startClockTime, 8))
		end
	end
--end

--[[
if not MapModData.VEM.InitTurnAcquired then
	MapModData.VEM.InitTurnAcquired = true
	LuaEvents.MT_Initialize.Add(InitTurnAcquired)
end
--]]