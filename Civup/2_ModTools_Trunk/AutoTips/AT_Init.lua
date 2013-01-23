-- AT_Init
-- Author: Thalassicus
-- DateCreated: 12/19/2012 9:35:05 PM
--------------------------------------------------------------

--
include( "CiVUP_Core.lua" )

if Game == nil then
	print("Game is nil!")
	--return
end

local log = Events.LuaLogger:New()
log:SetLevel("WARN")

local timeStart = os.clock()

local isFirstTimePromotions = true



--
-- Data
--

-------------------------------------------------
-- Initialize Game.Fields
-------------------------------------------------

--log:Info("Initializing Game.Fields")

--local buildingFieldStartTime = os.clock()

Game.Fields				= Game.Fields or {}
Game.Fields.Units		= Game.Fields.Units or {}
Game.Fields.Buildings	= Game.Fields.Buildings or {}
Game.Fields.Promotions	= Game.Fields.Promotions or {}

--

local MAX_RESOURCES = {}
for resourceInfo in GameInfo.Resources() do
	resUsageType = Game.GetResourceUsageType(resourceInfo.ID)
	MAX_RESOURCES[resUsageType] = (MAX_RESOURCES[resUsageType] or 0) + 1
end

local MAX_SPECIALISTS = 0
for specialistInfo in GameInfo.Specialists() do
	MAX_SPECIALISTS = MAX_SPECIALISTS + 1
end

Game.GetDefaultBuildingFieldData = Game.GetDefaultBuildingFieldData or function (buildingID, fieldType, bExcludeName, bExcludeHeader, bNoMaintenance, city)
	if GameInfo == nil then
		print("GetDefaultBuildingFieldData: GameInfo table does not exist!")
		return nil
	end
	local buildingInfo		= GameInfo.Buildings[buildingID]
	local buildingClassInfo	= GameInfo.BuildingClasses[buildingInfo.BuildingClass]
	local activePlayer		= Players[Game.GetActivePlayer()]
	local activeTeam		= Teams[Game.GetActiveTeam()]
	local adjustedCost		= activePlayer:GetBuildingProductionNeeded(buildingID)

	local yieldChange = (
		(fieldType == "FoodChange" and "YIELD_FOOD")
		or (fieldType == "ProductionChange" and "YIELD_PRODUCTION")
		or (fieldType == "GoldChange" and "YIELD_GOLD")
		or (fieldType == "ScienceChange" and "YIELD_SCIENCE")
		or (fieldType == "CultureChange" and "YIELD_CULTURE")
		or (fieldType == "FaithChange" and "YIELD_FAITH")
	)
	local yieldMod = (
		(fieldType == "FoodMod" and "YIELD_FOOD")
		or (fieldType == "ProductionMod" and "YIELD_PRODUCTION")
		or (fieldType == "GoldMod" and "YIELD_GOLD")
		or (fieldType == "ScienceMod" and "YIELD_SCIENCE")
		or (fieldType == "CultureMod" and "YIELD_CULTURE")
		or (fieldType == "FaithMod" and "YIELD_FAITH")
	)
	
	if fieldType == "Name" then
		return (not bExcludeName)
		
	elseif fieldType == "Cost" then 
		if bExcludeHeader or buildingInfo.Cost <= 0 then
			return false
		end
		return adjustedCost
		
	elseif fieldType == "FaithCost" then 
		if bExcludeHeader or buildingInfo.Cost <= 0 then
			return false
		end
		return adjustedCost
		
	elseif fieldType == "HurryCostModifier" then 
		if bExcludeHeader or buildingInfo.Cost <= 0 then
			return false
		end
		local purchaseCostMod = activePlayer:GetPurchaseCostMod(adjustedCost, buildingInfo.HurryCostModifier)
		if purchaseCostMod == -1 then
			return false
		end
		return purchaseCostMod
		
	elseif fieldType == "NumCityCostMod" then 
		return (not bExcludeHeader) and buildingInfo.NumCityCostMod
		
	elseif fieldType == "PopCostMod" then 
		return (not bExcludeHeader) and buildingInfo.PopCostMod
		
	elseif fieldType == "GoldMaintenance" then 
		return not(bExcludeHeader or bNoMaintenance) and buildingInfo.GoldMaintenance
		
	elseif fieldType == "UnmoddedHappiness" then
		return buildingInfo.UnmoddedHappiness

	elseif fieldType == "Happiness" then
		return activePlayer:GetBuildingYield(buildingID, YieldTypes.YIELD_HAPPINESS, city)

	elseif yieldChange then
		return activePlayer:GetBuildingYield(buildingID, GameInfo.Yields[yieldChange].ID, city)
	
	elseif yieldMod then
		return activePlayer:GetBuildingYieldMod(buildingID, GameInfo.Yields[yieldMod].ID, city)		
		
	elseif fieldType == "AlreadyBuilt" then
		return Building_IsAlreadyBuilt(buildingID, activePlayer)
		
	elseif fieldType == "NationalLimit" then
		buildingLimit = buildingClassInfo.MaxPlayerInstances
		return (buildingLimit > 0) and buildingLimit
		
	elseif fieldType == "TeamLimit" then
		buildingLimit = buildingClassInfo.MaxTeamInstances
		return (buildingLimit > 0) and buildingLimit
		
	elseif fieldType == "WorldLimit" then
		buildingLimit = buildingClassInfo.MaxGlobalInstances
		return (buildingLimit > 0) and buildingLimit
		
	elseif fieldType == "Replaces" then
		local defaultObjectType = buildingClassInfo.DefaultBuilding
		if buildingInfo.Type ~= defaultObjectType then
			return Locale.ConvertTextKey(GameInfo.Buildings[defaultObjectType].Description)
		end
		return false

	end
	
	return false
end

local resUsageTypeStr = {}
resUsageTypeStr[ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC] = Locale.ConvertTextKey("TXT_KEY_CIV5_RESOURCE_STRATEGIC")
resUsageTypeStr[ResourceUsageTypes.RESOURCEUSAGE_LUXURY] = Locale.ConvertTextKey("TXT_KEY_CIV5_RESOURCE_LUXURY")
resUsageTypeStr[ResourceUsageTypes.RESOURCEUSAGE_BONUS] = Locale.ConvertTextKey("TXT_KEY_CIV5_RESOURCE_BONUS")


Game.GetDefaultBuildingFieldText = Game.GetDefaultBuildingFieldText or function(buildingID, fieldType, fieldValue)
	if not buildingID or not fieldType then
		log:Fatal("Game.GetDefaultBuildingFieldText buildingID=%s fieldType=%s fieldValue=%s", buildingID, fieldType, fieldValue)
	end
	if not fieldValue or fieldValue == 0 or fieldValue == "" then
		return "", ""
	end
	
	local buildingInfo	= GameInfo.Buildings[buildingID]
	local activePlayer	= Players[Game.GetActivePlayer()]
	local textBody		= ""
	local textFooter	= ""	
	local fieldTextKey	= "TXT_KEY_PRODUCTION_BUILDING" .. string.upper( string.gsub(fieldType, '(%u)',  function(x) return "_"..x end) )
	local flagSign		= ""
	local flagSignLine	= ""

	if type(fieldValue) == "number" then
		fieldValue = (fieldValue % 1) and fieldValue or Locale.ToNumber(fieldValue, "#.#")
		flagSign = fieldValue > 0 and "+" or ""
	end

	local yieldFromPlots = (
		(fieldType == "FoodFromPlots" and "Food")
		or (fieldType == "ProductionFromPlots" and "Production")
		or (fieldType == "GoldFromPlots" and "Gold")
		or (fieldType == "ScienceFromPlots" and "Science")
		or (fieldType == "CultureFromPlots" and "Culture")
		or (fieldType == "FaithFromPlots" and "Faith")
	)
	local yieldFromTerrain = (
		(fieldType == "FoodFromTerrain" and "Food")
		or (fieldType == "ProductionFromTerrain" and "Production")
		or (fieldType == "GoldFromTerrain" and "Gold")
		or (fieldType == "ScienceFromTerrain" and "Science")
		or (fieldType == "CultureFromTerrain" and "Culture")
		or (fieldType == "FaithFromTerrain" and "Faith")
	)
	local yieldFromFeature = (
		(fieldType == "FoodFromFeatures" and "Food")
		or (fieldType == "ProductionFromFeatures" and "Production")
		or (fieldType == "GoldFromFeatures" and "Gold")
		or (fieldType == "ScienceFromFeatures" and "Science")
		or (fieldType == "CultureFromFeatures" and "Culture")
		or (fieldType == "FaithFromFeatures" and "Faith")
	)
	local yieldFromResource = (
		(fieldType == "FoodFromResources" and "Food")
		or (fieldType == "ProductionFromResources" and "Production")
		or (fieldType == "GoldFromResources" and "Gold")
		or (fieldType == "ScienceFromResources" and "Science")
		or (fieldType == "CultureFromResources" and "Culture")
		or (fieldType == "FaithFromResources" and "Faith")
	)
	local yieldFromTech = (
		(fieldType == "FoodFromTech" and "Food")
		or (fieldType == "ProductionFromTech" and "Production")
		or (fieldType == "GoldFromTech" and "Gold")
		or (fieldType == "ScienceFromTech" and "Science")
		or (fieldType == "CultureFromTech" and "Culture")
		or (fieldType == "FaithFromTech" and "Faith")
	)
	local yieldFromSpecialist = (
		(fieldType == "FoodFromSpecialists" and "Food")
		or (fieldType == "ProductionFromSpecialists" and "Production")
		or (fieldType == "GoldFromSpecialists" and "Gold")
		or (fieldType == "ScienceFromSpecialists" and "Science")
		or (fieldType == "CultureFromSpecialists" and "Culture")
		or (fieldType == "FaithFromSpecialists" and "Faith")
	)
	local yieldForBuildings = (
		(fieldType == "FoodForBuildings" and "Food")
		or (fieldType == "ProductionForBuildings" and "Production")
		or (fieldType == "GoldForBuildings" and "Gold")
		or (fieldType == "ScienceForBuildings" and "Science")
		or (fieldType == "CultureForBuildings" and "Culture")
		or (fieldType == "FaithForBuildings" and "Faith")
	)
	--[[
	local yieldInstant = (
		(fieldType == "FoodInstant" and "Food")
		or (fieldType == "ProductionInstant" and "Production")
		or (fieldType == "GoldInstant" and "Gold")
		or (fieldType == "ScienceInstant" and "Science")
		or (fieldType == "CultureInstant" and "Culture")
		or (fieldType == "FaithInstant" and "Faith")
		or (fieldType == "PopulationInstant" and "Population")
		or (fieldType == "HappinessInstant" and "Happiness")
	)
	--]]
	local yieldSurplusMod = (
		(fieldType == "FoodSurplus" and "Food")
		or (fieldType == "ProductionSurplus" and "Production")
		or (fieldType == "GoldSurplus" and "Gold")
		or (fieldType == "ScienceSurplus" and "Science")
		or (fieldType == "CultureSurplus" and "Culture")
		or (fieldType == "FaithSurplus" and "Faith")
	)
	local yieldGlobalMod = (
		(fieldType == "FoodGlobal" and "Food")
		or (fieldType == "ProductionGlobal" and "Production")
		or (fieldType == "GoldGlobal" and "Gold")
		or (fieldType == "ScienceGlobal" and "Science")
		or (fieldType == "CultureGlobal" and "Culture")
		or (fieldType == "FaithGlobal" and "Faith")
	)
	
	
	if fieldType == "Name" then
		textBody = textBody .. Locale.ToUpper(Locale.ConvertTextKey( buildingInfo.Description ));
		
	--elseif fieldType == "HurryCostModifier" then
	--	if fieldValue > 0 then
	--		textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, fieldValue, flagSign)
	--	end

	elseif yieldFromFeature then
		yieldFromFeature = "YIELD_"..string.upper(yieldFromFeature)
		-- for each yield modifier value, create a feature-affected list
		local yieldFeatureList = {}
		for pEntry in GameInfo.Building_FeatureYieldChanges() do
			if (pEntry.BuildingType == buildingInfo.Type
				and pEntry.YieldType == yieldFromFeature
				and pEntry.FeatureType ~= buildingInfo.NotFeature
				) then
				yieldFeatureList[pEntry.Yield] = (yieldFeatureList[pEntry.Yield] or "") .. Locale.ConvertTextKey(GameInfo.Features[pEntry.FeatureType].Description) .. ", "
			end
		end
		-- display each yield modifier value with a feature-affected list
		for yieldValue,FeatureString in pairs(yieldFeatureList) do
			yieldValue = (yieldValue % 1) and yieldValue or Locale.ToNumber(yieldValue, "#.#")
			flagSignLine = yieldValue > 0 and "+" or ""
			textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, yieldValue, flagSignLine, string.sub(FeatureString,1,-3))
		end

	elseif yieldFromPlots then
		yieldFromPlots = "YIELD_"..string.upper(yieldFromPlots)
		-- for each yield modifier value, create a feature-affected list
		local yieldPlotsList = {}
		for pEntry in GameInfo.Building_PlotsYieldChanges() do
			if (pEntry.BuildingType == buildingInfo.Type) and (pEntry.YieldType == yieldFromPlots) then
				yieldPlotsList[pEntry.Yield] = (yieldPlotsList[pEntry.Yield] or "") .. Locale.ConvertTextKey(GameInfo.Plots[pEntry.PlotType].Description) .. ", "
			end
		end
		-- display each yield modifier value with a feature-affected list
		for yieldValue,PlotsString in pairs(yieldPlotsList) do
			yieldValue = (yieldValue % 1) and yieldValue or Locale.ToNumber(yieldValue, "#.#")
			flagSignLine = yieldValue > 0 and "+" or ""
			textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, yieldValue, flagSignLine, string.sub(PlotsString,1,-3))
		end

	elseif yieldFromTerrain then
		yieldFromTerrain = "YIELD_"..string.upper(yieldFromTerrain)
		-- for each yield modifier value, create a feature-affected list
		local yieldTerrainList = {}
		for pEntry in GameInfo.Building_TerrainYieldChanges() do
			if (pEntry.BuildingType == buildingInfo.Type) and (pEntry.YieldType == yieldFromTerrain) then
				yieldTerrainList[pEntry.Yield] = (yieldTerrainList[pEntry.Yield] or "") .. Locale.ConvertTextKey(GameInfo.Terrains[pEntry.TerrainType].Description) .. ", "
			end
		end
		-- display each yield modifier value with a feature-affected list
		for yieldValue,TerrainString in pairs(yieldTerrainList) do
			yieldValue = (yieldValue % 1) and yieldValue or Locale.ToNumber(yieldValue, "#.#")
			flagSignLine = yieldValue > 0 and "+" or ""
			textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, yieldValue, flagSignLine, string.sub(TerrainString,1,-3))
		end

	elseif yieldFromResource then
		yieldFromResource = "YIELD_"..string.upper(yieldFromResource)
		-- for each yield magnitude and resource usage type, create a resources-affected string
		local yieldResourceList = {}
		local numResources = {}
		for pEntry in GameInfo.Building_ResourceYieldChanges() do
			if (pEntry.BuildingType == buildingInfo.Type) and (pEntry.YieldType == yieldFromResource) then
				local resourceInfo	= GameInfo.Resources[pEntry.ResourceType]
				local resUsageType	= tonumber(Game.GetResourceUsageType(resourceInfo.ID))
				local magnitude		= tonumber(pEntry.Yield)
				yieldResourceList[magnitude] = yieldResourceList[pEntry.Yield] or {}
				yieldResourceList[magnitude][resUsageType] = yieldResourceList[magnitude][resUsageType] or {}
				yieldResourceList[magnitude][resUsageType].string = (yieldResourceList[magnitude][resUsageType].string or "") .. resourceInfo.IconString
				yieldResourceList[magnitude][resUsageType].quantity = (yieldResourceList[magnitude][resUsageType].quantity or 0) + 1
			end
		end
		
		-- merge usage strings
		local magString = {}
		for magnitude, magList in pairs(yieldResourceList) do
			magString[magnitude] = magString[magnitude] or ""
			local numMaxed = 0
			for resUsageType, v in pairs(magList) do
				if resUsageType ~= "string" then
					if v.quantity == MAX_RESOURCES[resUsageType] then
						magString[magnitude] = magString[magnitude] .. resUsageTypeStr[resUsageType]..", "
						numMaxed = numMaxed + 1
					else
						magString[magnitude] = magString[magnitude] .. magList[resUsageType].string
					end
				end
			end
			if numMaxed == 3 then
				magString[magnitude] = Locale.ConvertTextKey("TXT_KEY_SV_ICONS_ALL") .. " " .. Locale.ConvertTextKey("TXT_KEY_SV_ICONS_RESOURCES")
			end
		end

		--merge magnitude strings			
		for magnitude, str in pairs(magString) do
			str = string.gsub(str, Game.Literalize(", ").."$", "")
			magnitude = (magnitude % 1) and magnitude or Locale.ToNumber(magnitude, "#.#")
			flagSignLine = magnitude > 0 and "+" or ""
			textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, magnitude, flagSignLine, str)
		end

	--[=[
	elseif fieldType == "CultureFromResources" then
		-- for each yield magnitude and resource usage type, create a resources-affected string
		local yieldResourceList = {}
		local numResources = {}
		for pEntry in GameInfo.Building_ResourceCultureChanges() do
			if pEntry.BuildingType == buildingInfo.Type then
				local resourceInfo = GameInfo.Resources[pEntry.ResourceType]
				local resUsageType = Game.GetResourceUsageType(resourceInfo.ID)
				yieldResourceList[pEntry.CultureChange] = yieldResourceList[pEntry.CultureChange] or {}
				yieldResourceList[pEntry.CultureChange][resUsageType] = yieldResourceList[pEntry.CultureChange][resUsageType] or {}
				yieldResourceList[pEntry.CultureChange][resUsageType].string = (yieldResourceList[pEntry.CultureChange][resUsageType].string or "") .. resourceInfo.IconString
				yieldResourceList[pEntry.CultureChange][resUsageType].quantity = (yieldResourceList[pEntry.CultureChange][resUsageType].quantity or 0) + 1
			end
		end
		
		-- merge usage strings
		local magString = {}
		for magnitude, magList in pairs(yieldResourceList) do
			magString[magnitude] = magString[magnitude] or ""
			local numMaxed = 0
			for resUsageType, v in pairs(magList) do
				if resUsageType ~= "string" then
					magString[magnitude] = magString[magnitude] or ""
					if v.quantity == MAX_RESOURCES[resUsageType] then
						magString[magnitude] = magString[magnitude] .. resUsageTypeStr[resUsageType]..", "
						numMaxed = numMaxed + 1
					else
						magString[magnitude] = magString[magnitude] .. magList[resUsageType].string
					end
				end
			end
			if numMaxed == 3 then
				magString[magnitude] = Locale.ConvertTextKey("TXT_KEY_SV_ICONS_ALL") .. " " .. Locale.ConvertTextKey("TXT_KEY_SV_ICONS_RESOURCES")
			end
		end

		--merge magnitude strings			
		for magnitude, str in pairs(magString) do
			str = string.gsub(str, Game.Literalize(", ").."$", "")
			magnitude = (magnitude % 1) and magnitude or Locale.ToNumber(magnitude, "#.#")
			flagSignLine = magnitude > 0 and "+" or ""
			textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, magnitude, flagSignLine, str)
		end
	--]=]

	elseif yieldSurplusMod then
		yieldSurplusMod = "YIELD_"..string.upper(yieldSurplusMod)
		for pEntry in GameInfo.Building_YieldSurplusModifiers() do
			if pEntry.BuildingType == buildingInfo.Type and pEntry.YieldType == yieldSurplusMod then
				yieldValue = pEntry.Yield
				flagSignLine = yieldValue > 0 and "+" or ""
				textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, yieldValue, flagSignLine, techName)
			end
		end

	elseif yieldGlobalMod then
		yieldGlobalMod = "YIELD_"..string.upper(yieldGlobalMod)
		for pEntry in GameInfo.Building_GlobalYieldModifiers() do
			if pEntry.BuildingType == buildingInfo.Type and pEntry.YieldType == yieldGlobalMod then
				yieldValue = pEntry.Yield
				flagSignLine = yieldValue > 0 and "+" or ""
				textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, yieldValue, flagSignLine, techName)
			end
		end

	elseif yieldFromTech then
		yieldFromTech = "YIELD_"..string.upper(yieldFromTech)
		for pEntry in GameInfo.Building_TechEnhancedYieldChanges() do
			if pEntry.BuildingType == buildingInfo.Type and pEntry.YieldType == yieldFromTech then
				techName = Locale.ConvertTextKey(GameInfo.Technologies[buildingInfo.EnhancedYieldTech].Description)
				yieldValue = pEntry.Yield
				yieldValue = (yieldValue % 1) and yieldValue or Locale.ToNumber(yieldValue, "#.#")
				flagSignLine = yieldValue > 0 and "+" or ""
				textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, yieldValue, flagSignLine, techName)
			end
		end

	elseif yieldFromSpecialist then
		yieldFromSpecialist = "YIELD_"..string.upper(yieldFromSpecialist)
		-- for each yield modifier value, create a Specialist-affected list
		local yieldSpecialistList = {}
		local yieldSpecialistQuantity = {}
		for pEntry in GameInfo.Building_SpecialistYieldChanges() do
			if (pEntry.BuildingType == buildingInfo.Type) and (pEntry.YieldType == yieldFromSpecialist) then
				yieldSpecialistList[pEntry.Yield] = (yieldSpecialistList[pEntry.Yield] or "") .. Locale.ConvertTextKey(GameInfo.Specialists[pEntry.SpecialistType].Description) .. ", "
				yieldSpecialistQuantity[pEntry.Yield] = (yieldSpecialistQuantity[pEntry.Yield] or 0) + 1
				if yieldSpecialistQuantity[pEntry.Yield] == MAX_SPECIALISTS then
					yieldSpecialistList[pEntry.Yield] = Locale.ConvertTextKey("TXT_KEY_PEOPLE_SECTION_1")
				end
			end
		end
		-- display each yield modifier value with a Specialist-affected list
		for yieldValue,SpecialistString in pairs(yieldSpecialistList) do
			yieldValue = (yieldValue % 1) and yieldValue or Locale.ToNumber(yieldValue, "#.#")
			flagSignLine = yieldValue > 0 and "+" or ""
			if yieldSpecialistQuantity[yieldValue] < MAX_SPECIALISTS then
				SpecialistString = string.sub(SpecialistString,1,-3)
			end
			textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, yieldValue, flagSignLine, SpecialistString)
		end

	elseif yieldForBuildings then
		yieldForBuildings = "YIELD_"..string.upper(yieldForBuildings)
		-- for each yield modifier value, create a Building-affected list
		local yieldBuildingList = {}
		local yieldBuildingQuantity = {}
		for pEntry in GameInfo.Building_BuildingClassYieldChanges() do
			if (pEntry.BuildingType == buildingInfo.Type) and (pEntry.YieldType == yieldForBuildings) then
				yieldBuildingList[pEntry.YieldChange] = (yieldBuildingList[pEntry.YieldChange] or "") .. Locale.ConvertTextKey(GameInfo.BuildingClasses[pEntry.BuildingClassType].Description) .. ", "
				yieldBuildingQuantity[pEntry.YieldChange] = (yieldBuildingQuantity[pEntry.YieldChange] or 0) + 1
--					if yieldBuildingQuantity[pEntry.YieldChange] == MAX_BUILDINGS then
--						yieldBuildingList[pEntry.YieldChange] = Locale.ConvertTextKey("TXT_KEY_PEOPLE_SECTION_1")
--					end
			end
		end
		-- display each yield modifier value with a Building-affected list
		for yieldValue,BuildingString in pairs(yieldBuildingList) do
			yieldValue = (yieldValue % 1) and yieldValue or Locale.ToNumber(yieldValue, "#.#")
			flagSignLine = yieldValue > 0 and "+" or ""
			if true then --yieldBuildingQuantity[yieldValue] < MAX_BUILDINGS then
				BuildingString = string.sub(BuildingString,1,-3)
			end
			textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, yieldValue, flagSignLine, BuildingString)
		end

	--elseif yieldInstant then
	--	yieldInstant = "YIELD_"..string.upper(yieldInstant)
	--	Game.GetValue("Yield", {BuildingType=data_BuildingFields.Type, YieldType="YIELD_POPULATION", TraitType=Players[Game.GetActivePlayer()]:GetTraitInfo().Type}, GameInfo.Trait_YieldFromConstruction)
		
	elseif fieldType == "HurryModifier" then
		for pEntry in GameInfo.Building_HurryModifiers() do
			if pEntry.BuildingType == buildingInfo.Type then
				hurryMod = pEntry.HurryCostModifier
				flagSignLine = hurryMod > 0 and "+" or ""
				textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, hurryMod, flagSignLine)
			end
		end

	elseif fieldType == "SpecialistType" then
		local specInfo = GameInfo.Specialists[buildingInfo.SpecialistType]
		local specDescription = Locale.ConvertTextKey(specInfo.Description)
		if buildingInfo.SpecialistCount ~= 0 then
			fieldTextKey = "TXT_KEY_PRODUCTION_BUILDING_SPECIALIST_POINTS"
			flagSignLine = ""
			textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, specInfo.IconString, specDescription, flagSignLine, buildingInfo.SpecialistCount)
		end
		if buildingInfo.GreatPeopleRateChange ~= 0 then
			fieldTextKey = "TXT_KEY_PRODUCTION_BUILDING_GREAT_PERSON_POINTS"
			flagSignLine = "" --flagSign and "+" or ""
			textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, specDescription, flagSignLine, buildingInfo.GreatPeopleRateChange)
		end

	elseif fieldType == "CombatProductionModifier" then
		for pEntry in GameInfo.Building_UnitCombatProductionModifiers() do
			if pEntry.BuildingType == buildingInfo.Type and pEntry.Modifier ~= 0 then
				if GameInfo.UnitCombatInfos[pEntry.UnitCombatType] == nil then
					log:Fatal("UnitCombatInfos[%s] does not exist", pEntry.UnitCombatType)
				end
				if GameInfo.UnitCombatInfos[pEntry.UnitCombatType].Description == nil then
					log:Fatal("UnitCombatInfos[%s].Description does not exist", pEntry.UnitCombatType)
				end
				entryName = Locale.ConvertTextKey(GameInfo.UnitCombatInfos[pEntry.UnitCombatType].Description)
				entryValue = pEntry.Modifier
				entryValue = (entryValue % 1) and entryValue or Locale.ToNumber(entryValue, "#.#")
				flagSignLine = entryValue > 0 and "+" or ""
				textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, entryValue, flagSignLine, entryName)
			end
		end

	elseif fieldType == "ExperienceCombat" then
		for pEntry in GameInfo.Building_UnitCombatFreeExperiences() do
			if pEntry.BuildingType == buildingInfo.Type and pEntry.Experience ~= 0 then
				entryName = Locale.ConvertTextKey(GameInfo.UnitCombatInfos[pEntry.UnitCombatType].Description)
				entryValue = pEntry.Experience
				textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, entryValue, flagSignLine, entryName)
			end
		end

	elseif fieldType == "FreeUnits" then
		for pEntry in GameInfo.Building_FreeUnits() do
			if pEntry.BuildingType == buildingInfo.Type and pEntry.NumUnits ~= 0 then
				local unitInfo = GameInfo.Units[pEntry.UnitType]
				entryName = Locale.ConvertTextKey(unitInfo.Description)
				entryValue = pEntry.NumUnits
				flagSignLine = ""
				if unitInfo.MoveRate == "GREAT_PERSON" then
					textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_FREE_GREAT_PERSON", entryValue, flagSignLine, entryName)
				else
					textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, entryValue, flagSignLine, entryName)
				end
			end
		end

	elseif fieldType == "FreeResources" then
		for pEntry in GameInfo.Building_ResourceQuantity() do
			if pEntry.BuildingType == buildingInfo.Type and pEntry.Quantity ~= 0 then
				local resInfo = GameInfo.Resources[pEntry.ResourceType]
				entryName = Locale.ConvertTextKey(resInfo.Description)
				entryValue = pEntry.Quantity
				flagSignLine = ""
				textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, entryValue, flagSignLine, entryName, resInfo.IconString)
			end
		end

	elseif fieldType == "InstantBorderPlots" then
		for pEntry in GameInfo.Building_PlotsYieldChanges{BuildingType = buildingInfo.Type} do
			textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, Locale.ConvertTextKey(GameInfo.Plots[pEntry.PlotType].Description))
		end

	elseif fieldType == "NotFeature" then
		textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, Locale.ConvertTextKey(GameInfo.Features[fieldValue].Description))

	elseif fieldType == "RequiresNearAll" then
		local resourceString = ""
		for pEntry in GameInfo.Building_LocalResourceAnds() do
			if pEntry.BuildingType == buildingInfo.Type then
				resourceString = resourceString .. GameInfo.Resources[pEntry.ResourceType].IconString
			end
		end
		textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, resourceString)

	elseif fieldType == "RequiresNearAny" then
		local resourceString = ""
		for pEntry in GameInfo.Building_LocalResourceOrs() do
			if pEntry.BuildingType == buildingInfo.Type then
				resourceString = resourceString .. GameInfo.Resources[pEntry.ResourceType].IconString
			end
		end
		textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, resourceString)

	elseif fieldType == "RequiresResourceConsumption" then
		local resourceString = ""
		for pEntry in GameInfo.Building_ResourceQuantityRequirements() do
			if pEntry.BuildingType == buildingInfo.Type and pEntry.Cost ~= 0 then
				resourceString = resourceString .. pEntry.Cost .. GameInfo.Resources[pEntry.ResourceType].IconString .. " "
			end
		end
		textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, resourceString)

	elseif fieldType == "NearbyTerrainRequired" then
		local terrainName = Locale.ConvertTextKey(GameInfo.Terrains[fieldValue].Description)
		textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, terrainName)

	elseif fieldType == "RequiresTech" then
		for pEntry in GameInfo.Building_TechAndPrereqs(string.format("BuildingType = '%s'", buildingInfo.Type)) do
			local entryName = Locale.ConvertTextKey(GameInfo.Technologies[pEntry.TechType].Description)
			textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, entryName)
		end

	elseif fieldType == "RequiresBuilding" then
		local buildingClassesNeededInCity = {}
		for pEntry in GameInfo.Building_ClassesNeededInCity() do
			if pEntry.BuildingType == buildingInfo.Type then
				local uniqueID = activePlayer:GetUniqueBuildingID(pEntry.BuildingClassType)
				local entryName = Locale.ConvertTextKey(GameInfo.Buildings[uniqueID].Description)
				buildingClassesNeededInCity[entryName] = 1
			end
		end
		for entryName, entryNum in pairs(buildingClassesNeededInCity) do
			textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, entryName, entryNum)
		end

	elseif fieldType == "RequiresBuildingInCities" then
		local buildingClassesNeeded = {}
		for pEntry in GameInfo.Building_PrereqBuildingClasses() do
			if pEntry.BuildingType == buildingInfo.Type then
				local className = pEntry.BuildingClassType
				className = activePlayer:GetUniqueBuildingID(pEntry.BuildingClassType)
				className = GameInfo.Buildings[className].Description
				className = Locale.ConvertTextKey(className)
				buildingClassesNeeded[className] = pEntry.NumBuildingNeeded
			end
		end
		for className, classNum in pairs(buildingClassesNeeded) do
			classNum = (classNum == -1) and Locale.ConvertTextKey("TXT_KEY_SV_ICONS_ALL") or classNum
			textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, className, classNum)
		end

	elseif fieldType == "RequiresBuildingInPercentCities" then
		local buildingClassesNeeded = {}
		for pEntry in GameInfo.Building_PrereqBuildingClassesPercentage() do
			if pEntry.BuildingType == buildingInfo.Type then
				local className = Locale.ConvertTextKey(GameInfo.Buildings[activePlayer:GetUniqueBuildingID(pEntry.BuildingClassType)].Description)
				buildingClassesNeeded[className] = pEntry.PercentBuildingNeeded
			end
		end
		for className, classNum in pairs(buildingClassesNeeded) do
			classNum = (classNum == -1) and Locale.ConvertTextKey("TXT_KEY_SV_ICONS_ALL") or classNum
			textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, className, classNum)
		end
		
	else
		-- ** DEFAULT STRING HANDLING ** --
		local strExtraText = Locale.ConvertTextKey(fieldTextKey.."_EXTRA")
		if strExtraText ~= (fieldTextKey.."_EXTRA") then
			textFooter = "[NEWLINE][NEWLINE]" .. strExtraText
		end
		textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, fieldValue, flagSign)
	end

	return textBody, textFooter
end

--print(string.format("%3s ms loading InfoTooltipInclude.lua building field functions", Game.Round(os.clock() - buildingFieldStartTime, 8)))
local buildingFieldStartTime = os.clock()

data_BuildingFields = nil
if not Game.InitializedFields then
	Game.InitializedFields = true
	Game.Fields.Buildings = {}
	for buildingInfo in GameInfo.Buildings() do
		local buildingID = buildingInfo.ID
		data_BuildingFields = buildingInfo
		Game.Fields.Buildings[buildingID] = {}
		for row in GameInfo.BuildingFields() do
			if row.Value then
				local v = {row.Type, assert(loadstring("return " .. row.Value))()}
				if v[2] and v[2] ~= 0 and v[2] ~= "" then
					if type(v[2]) == "function" then
						v[3] = Game.GetDefaultBuildingFieldText
					else
						v[3], v[4] = Game.GetDefaultBuildingFieldText(buildingID, v[1], v[2])
					end
					table.insert(Game.Fields.Buildings[buildingID], v)
				end
			else
				log:Error("data_BuildingFields %s value is nil!", row.Type)
			end
		end
	end
end

local endTime = math.floor((os.clock() - buildingFieldStartTime) * 1000)
if endTime > 100 then
	print(string.format("%s ms loading Game.Fields", endTime))
end

--]==]



-------------------------------------------------
-- Completed initialization of Game.Fields
-------------------------------------------------

--log:Info("Completed initialization of Game.Fields")


