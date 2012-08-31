-------------------------------------------------
-- Help text for Info Objects (Units, Buildings, etc.)
-------------------------------------------------

-- Changes to this file were made by Thalassicus, primarily for the AutoTips and YieldLibrary modules of the Civ 5 Unofficial Patch.


include( "CiVUP_Core.lua" )

if Game == nil then
	--print("InfoTooltipInclude.lua: Game == nil")
	return
end

local log = Events.LuaLogger:New()
log:SetLevel("WARN")

local isFirstTimePromotions = true

--
-- Helper Functions
--

function OnAddToFieldTable(tableName, tableData, tablePos)
	if tablePos then
		table.insert(tableName, tablePos, fieldData)
	else
		table.insert(tableName, fieldData)
	end
end

LuaEvents.AddToFieldTable.Add( OnAddToFieldTable );



--
-- Data
--

-------------------------------------------------
-- Initialize MapModData.Fields
-------------------------------------------------
--if MapModData.Fields == nil then

--log:Info("Initializing MapModData.Fields")

MapModData.Fields			= MapModData.Fields or {}
MapModData.Fields.Units		= MapModData.Fields.Units or {}
--MapModData.Fields.Buildings	= MapModData.Fields.Buildings or {}

local MAX_RESOURCES = {}
for resourceInfo in GameInfo.Resources() do
	resUsageType = Game.GetResourceUsageType(resourceInfo.ID)
	MAX_RESOURCES[resUsageType] = (MAX_RESOURCES[resUsageType] or 0) + 1
end

local MAX_SPECIALISTS = 0
for specialistInfo in GameInfo.Specialists() do
	MAX_SPECIALISTS = MAX_SPECIALISTS + 1
end

GetDefaultBuildingFieldData = GetDefaultBuildingFieldData or function (iBuildingID, fieldType, bExcludeName, bExcludeHeader, bNoMaintenance)
	if GameInfo == nil then
		return nil
	end
	local buildingInfo	= GameInfo.Buildings[iBuildingID]
	local activePlayer	= Players[Game.GetActivePlayer()]
	local activeTeam	= Teams[Game.GetActiveTeam()]
	local adjustedCost	= activePlayer:GetBuildingProductionNeeded(iBuildingID)

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
		return Game.Round(purchaseCostMod / 100, 1)
		
	elseif fieldType == "NumCityCostMod" then 
		return (not bExcludeHeader) and buildingInfo.NumCityCostMod
		
	elseif fieldType == "PopCostMod" then 
		return (not bExcludeHeader) and buildingInfo.PopCostMod
		
	elseif fieldType == "GoldMaintenance" then 
		return not(bExcludeHeader or bNoMaintenance) and buildingInfo.GoldMaintenance
		
	elseif fieldType == "UnmoddedHappiness" then
		return buildingInfo.UnmoddedHappiness

	elseif fieldType == "Happiness" then
		return activePlayer:GetBuildingYield(nil, iBuildingID, YieldTypes.YIELD_HAPPINESS)

	elseif yieldChange then
		return activePlayer:GetBuildingYield(nil, iBuildingID, YieldTypes[yieldChange])
	
	elseif yieldMod then
		return activePlayer:GetBuildingYieldMod(nil, iBuildingID, YieldTypes[yieldMod])
		
	elseif fieldType == "AlreadyBuilt" then
		return Building_IsAlreadyBuilt(iBuildingID, activePlayer)

	end
	
	return false
end

local resUsageTypeStr = {}
resUsageTypeStr[ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC] = Locale.ConvertTextKey("TXT_KEY_CIV5_RESOURCE_STRATEGIC")
resUsageTypeStr[ResourceUsageTypes.RESOURCEUSAGE_LUXURY] = Locale.ConvertTextKey("TXT_KEY_CIV5_RESOURCE_LUXURY")
resUsageTypeStr[ResourceUsageTypes.RESOURCEUSAGE_BONUS] = Locale.ConvertTextKey("TXT_KEY_CIV5_RESOURCE_BONUS")

GetDefaultBuildingFieldText = GetDefaultBuildingFieldText or function(iBuildingID, fieldType, fieldValue)
	local buildingInfo = GameInfo.Buildings[iBuildingID]
	local activePlayer = Players[Game.GetActivePlayer()]
	local strHelpText = ""
	local strWrittenHelpText = ""
	if fieldValue and fieldValue ~= 0 and fieldValue ~= "" then
		local fieldTextKey = "TXT_KEY_PRODUCTION_BUILDING" .. string.upper( string.gsub(fieldType, '(%u)',  function(x) return "_"..x end) )
		local flagSign = ""
		local flagSignLine = ""

		if type(fieldValue) == "number" then
			fieldValue = (fieldValue % 1) and fieldValue or Locale.ToNumber(fieldValue, "#.#")
			flagSign = fieldValue > 0 and "+" or ""
		end

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
			strHelpText = strHelpText .. Locale.ToUpper(Locale.ConvertTextKey( buildingInfo.Description ));
			strHelpText = strHelpText .. "[NEWLINE]----------------";
			
		--[[elseif fieldType == "HurryCostModifier" then
			if fieldValue > 0 then
				strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, fieldValue, flagSign)
			end--]]

		elseif yieldFromFeature then
			yieldFromFeature = "YIELD_"..string.upper(yieldFromFeature)
			-- for each yield modifier value, create a feature-affected list
			local yieldFeatureList = {}
			for pEntry in GameInfo.Building_FeatureYieldChanges() do
				if (pEntry.BuildingType == buildingInfo.Type) and (pEntry.YieldType == yieldFromFeature) then
					yieldFeatureList[pEntry.Yield] = (yieldFeatureList[pEntry.Yield] or "") .. Locale.ConvertTextKey(GameInfo.Features[pEntry.FeatureType].Description) .. ", "
				end
			end
			-- display each yield modifier value with a feature-affected list
			for yieldValue,FeatureString in pairs(yieldFeatureList) do
				yieldValue = (yieldValue % 1) and yieldValue or Locale.ToNumber(yieldValue, "#.#")
				flagSignLine = yieldValue > 0 and "+" or ""
				strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, yieldValue, flagSignLine, string.sub(FeatureString,1,-3))
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
				strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, yieldValue, flagSignLine, string.sub(TerrainString,1,-3))
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
				strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, magnitude, flagSignLine, str)
			end

			--[[
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
				strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, magnitude, flagSignLine, str)
			end
			--]]

		elseif yieldSurplusMod then
			yieldSurplusMod = "YIELD_"..string.upper(yieldSurplusMod)
			for pEntry in GameInfo.Building_YieldSurplusModifiers() do
				if pEntry.BuildingType == buildingInfo.Type and pEntry.YieldType == yieldSurplusMod then
					yieldValue = pEntry.Yield
					flagSignLine = yieldValue > 0 and "+" or ""
					strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, yieldValue, flagSignLine, techName)
				end
			end

		elseif yieldGlobalMod then
			yieldGlobalMod = "YIELD_"..string.upper(yieldGlobalMod)
			for pEntry in GameInfo.Building_GlobalYieldModifiers() do
				if pEntry.BuildingType == buildingInfo.Type and pEntry.YieldType == yieldGlobalMod then
					yieldValue = pEntry.Yield
					flagSignLine = yieldValue > 0 and "+" or ""
					strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, yieldValue, flagSignLine, techName)
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
					strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, yieldValue, flagSignLine, techName)
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
				strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, yieldValue, flagSignLine, SpecialistString)
			end
			
		elseif fieldType == "HurryModifier" then
			for pEntry in GameInfo.Building_HurryModifiers() do
				if pEntry.BuildingType == buildingInfo.Type then
					hurryMod = pEntry.HurryCostModifier
					flagSignLine = hurryMod > 0 and "+" or ""
					strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, hurryMod, flagSignLine)
				end
			end

		elseif fieldType == "SpecialistType" then
			local txtSpecialist = Locale.ConvertTextKey(GameInfo.Specialists[buildingInfo.SpecialistType].Description)
			if buildingInfo.SpecialistCount ~= 0 then
				fieldTextKey = "TXT_KEY_PRODUCTION_BUILDING_SPECIALIST_POINTS"
				flagSignLine = ""
				strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, txtSpecialist, flagSignLine, buildingInfo.SpecialistCount)
			end
			if buildingInfo.GreatPeopleRateChange ~= 0 then
				fieldTextKey = "TXT_KEY_PRODUCTION_BUILDING_GREAT_PERSON_POINTS"
				flagSignLine = "" --flagSign and "+" or ""
				strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, txtSpecialist, flagSignLine, buildingInfo.GreatPeopleRateChange)
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
					strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, entryValue, flagSignLine, entryName)
				end
			end

		elseif fieldType == "ExperienceCombat" then
			for pEntry in GameInfo.Building_UnitCombatFreeExperiences() do
				if pEntry.BuildingType == buildingInfo.Type and pEntry.Experience ~= 0 then
					entryName = Locale.ConvertTextKey(GameInfo.UnitCombatInfos[pEntry.UnitCombatType].Description)
					entryValue = pEntry.Experience
					strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, entryValue, flagSignLine, entryName)
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
						strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_FREE_GREAT_PERSON", entryValue, flagSignLine, entryName)
					else
						strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, entryValue, flagSignLine, entryName)
					end
				end
			end

		elseif fieldType == "RequiresNearAll" then
			local resourceString = ""
			for pEntry in GameInfo.Building_LocalResourceAnds() do
				if pEntry.BuildingType == buildingInfo.Type then
					resourceString = resourceString .. GameInfo.Resources[pEntry.ResourceType].IconString
				end
			end
			strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, resourceString)

		elseif fieldType == "RequiresNearAny" then
			local resourceString = ""
			for pEntry in GameInfo.Building_LocalResourceOrs() do
				if pEntry.BuildingType == buildingInfo.Type then
					resourceString = resourceString .. GameInfo.Resources[pEntry.ResourceType].IconString
				end
			end
			strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, resourceString)

		elseif fieldType == "RequiresResourceConsumption" then
			local resourceString = ""
			for pEntry in GameInfo.Building_ResourceQuantityRequirements() do
				if pEntry.BuildingType == buildingInfo.Type and pEntry.Cost ~= 0 then
					resourceString = resourceString .. pEntry.Cost .. GameInfo.Resources[pEntry.ResourceType].IconString .. " "
				end
			end
			strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, resourceString)

		elseif fieldType == "NearbyTerrainRequired" then
			local terrainName = Locale.ConvertTextKey(GameInfo.Terrains[fieldValue].Description)
			strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, terrainName)

		elseif fieldType == "RequiresTech" then
			for pEntry in GameInfo.Building_TechAndPrereqs(string.format("BuildingType = '%s'", buildingInfo.Type)) do
				local entryName = Locale.ConvertTextKey(GameInfo.Technologies[pEntry.TechType].Description)
				strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, entryName)
			end

		elseif fieldType == "RequiresBuilding" then
			local buildingClassesNeededInCity = {}
			for pEntry in GameInfo.Building_ClassesNeededInCity() do
				if pEntry.BuildingType == buildingInfo.Type then
					local entryName = Locale.ConvertTextKey(GameInfo.Buildings[activePlayer:GetUniqueBuildingID(pEntry.BuildingClassType)].Description)
					buildingClassesNeededInCity[entryName] = 1
				end
			end
			for entryName, entryNum in pairs(buildingClassesNeededInCity) do
				strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, entryName, entryNum)
			end

		elseif fieldType == "RequiresBuildingInCities" then
			local buildingClassesNeeded = {}
			for pEntry in GameInfo.Building_PrereqBuildingClasses() do
				if pEntry.BuildingType == buildingInfo.Type then
					local className = pEntry.BuildingClassType
					className = activePlayer:GetUniqueBuildingID(pEntry.BuildingClassType)
					className = GameInfo.Buildings[activePlayer:GetUniqueBuildingID(pEntry.BuildingClassType)].Description
					className = Locale.ConvertTextKey(GameInfo.Buildings[activePlayer:GetUniqueBuildingID(pEntry.BuildingClassType)].Description)
					buildingClassesNeeded[className] = pEntry.NumBuildingNeeded
				end
			end
			for className, classNum in pairs(buildingClassesNeeded) do
				classNum = (classNum == -1) and Locale.ConvertTextKey("TXT_KEY_SV_ICONS_ALL") or classNum
				strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, className, classNum)
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
				strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, className, classNum)
			end
			
		else
			-- ** DEFAULT STRING HANDLING ** --
			local strExtraText = Locale.ConvertTextKey(fieldTextKey.."_EXTRA")
			if strExtraText ~= (fieldTextKey.."_EXTRA") then
				strWrittenHelpText = "[NEWLINE][NEWLINE]" .. strExtraText
			end
			strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, fieldValue, flagSign)
		end
	end
	
	return strHelpText, strWrittenHelpText
end

data_BuildingFields = nil
if true then --not MapModData.Fields.Buildings then
	MapModData.Fields.Buildings = {}
	for buildingInfo in GameInfo.Buildings() do
		local iBuildingID = buildingInfo.ID
		data_BuildingFields = buildingInfo
		MapModData.Fields.Buildings[iBuildingID] = {}
		for row in GameInfo.BuildingFields() do
			if row.Value == nil then
				log:Error("data_BuildingFields %s value is nil", row.Type)
				MapModData.Fields.Buildings[iBuildingID][row.Order] = {row.Type, nil}
			else
				MapModData.Fields.Buildings[iBuildingID][row.Order] = {row.Type, assert(loadstring("return " .. row.Value))()}
			end
		end
		for k,v in ipairs(MapModData.Fields.Buildings[iBuildingID]) do
			if v == nil or v == 0 or v == "" then
				v = nil
			else
				if type(v[2]) == "function" then
					v[3] = GetDefaultBuildingFieldText
				else
					v[3], v[4] = GetDefaultBuildingFieldText(iBuildingID, v[1], v[2])
				end
			end
		end
	end
end

--[[
promotionFields = {}

function SetDefaultPromotionFieldData(iPromotionID)
	local pPromotionInfo = GameInfo.UnitPromotions[iPromotionID]
	local activePlayer = Players[Game.GetActivePlayer()]
	local activeTeam = Teams[Game.GetActiveTeam()]
	promotionFields = {
	{"LostWithUpgrade"						, promotionInfo.LostWithUpgrade },
	{"InstaHeal"							, promotionInfo.InstaHeal },
	{"Leader"								, promotionInfo.Leader },
	{"Blitz"								, promotionInfo.Blitz },
	{"Amphib"								, promotionInfo.Amphib },
	{"River"								, promotionInfo.River },
	{"EnemyRoute"							, promotionInfo.EnemyRoute },
	{"RivalTerritory"						, promotionInfo.RivalTerritory },
	{"MustSetUpToRangedAttack"				, promotionInfo.MustSetUpToRangedAttack },
	{"RangedSupportFire"					, promotionInfo.RangedSupportFire },
	{"CanMoveAfterAttacking"				, promotionInfo.CanMoveAfterAttacking },
	{"AlwaysHeal"							, promotionInfo.AlwaysHeal },
	{"HealOutsideFriendly"					, promotionInfo.HealOutsideFriendly },
	{"HillsDoubleMove"						, promotionInfo.HillsDoubleMove },
	{"RoughTerrainEndsTurn"					, promotionInfo.RoughTerrainEndsTurn },
	{"IgnoreTerrainCost"					, promotionInfo.IgnoreTerrainCost },
	{"HoveringUnit"							, promotionInfo.HoveringUnit },
	{"FlatMovementCost"						, promotionInfo.FlatMovementCost },
	{"CanMoveImpassable"					, promotionInfo.CanMoveImpassable },
	{"NoCapture"							, promotionInfo.NoCapture },
	{"OnlyDefensive"						, promotionInfo.OnlyDefensive },
	{"NoDefensiveBonus"						, promotionInfo.NoDefensiveBonus },
	{"NukeImmune"							, promotionInfo.NukeImmune },
	{"HiddenNationality"					, promotionInfo.HiddenNationality },
	{"AlwaysHostile"						, promotionInfo.AlwaysHostile },
	{"NoRevealMap"							, promotionInfo.NoRevealMap },
	{"Recon"								, promotionInfo.Recon },
	{"CanMoveAllTerrain"					, promotionInfo.CanMoveAllTerrain },
	{"FreePillageMoves"						, promotionInfo.FreePillageMoves },
	{"AirSweepCapable"						, promotionInfo.AirSweepCapable },
	{"AllowsEmbarkation"					, promotionInfo.AllowsEmbarkation },
	{"EmbarkedNotCivilian"					, promotionInfo.EmbarkedNotCivilian },
	{"EmbarkedAllWater"						, promotionInfo.EmbarkedAllWater },
	{"HealIfDestroyExcludesBarbarians"		, promotionInfo.HealIfDestroyExcludesBarbarians },
	{"RangeAttackIgnoreLOS"					, promotionInfo.RangeAttackIgnoreLOS },
	{"RangedAttackModifier"					, promotionInfo.RangedAttackModifier },
	{"InterceptionCombatModifier"			, promotionInfo.InterceptionCombatModifier },
	{"InterceptionDefenseDamageModifier"	, promotionInfo.InterceptionDefenseDamageModifier },
	{"AirSweepCombatModifier"				, promotionInfo.AirSweepCombatModifier },
	{"ExtraAttacks"							, promotionInfo.ExtraAttacks },
	{"ExtraNavalMovement"					, promotionInfo.ExtraNavalMovement },
	{"VisibilityChange"						, promotionInfo.VisibilityChange },
	{"MovesChange"							, promotionInfo.MovesChange },
	{"MoveDiscountChange"					, promotionInfo.MoveDiscountChange },
	{"RangeChange"							, promotionInfo.RangeChange },
	{"InterceptChanceChange"				, promotionInfo.InterceptChanceChange },
	{"NumInterceptionChange"				, promotionInfo.NumInterceptionChange },
	{"EvasionChange"						, promotionInfo.EvasionChange },
	{"CargoChange"							, promotionInfo.CargoChange },
	{"EnemyHealChange"						, promotionInfo.EnemyHealChange },
	{"NeutralHealChange"					, promotionInfo.NeutralHealChange },
	{"FriendlyHealChange"					, promotionInfo.FriendlyHealChange },
	{"SameTileHealChange"					, promotionInfo.SameTileHealChange },
	{"AdjacentTileHealChange"				, promotionInfo.AdjacentTileHealChange },
	{"EnemyDamageChance"					, promotionInfo.EnemyDamageChance },
	{"NeutralDamageChance"					, promotionInfo.NeutralDamageChance },
	{"CombatPercent"						, promotionInfo.CombatPercent },
	{"CityAttack"							, promotionInfo.CityAttack },
	{"CityDefense"							, promotionInfo.CityDefense },
	{"RangedDefenseMod"						, promotionInfo.RangedDefenseMod },
	{"HillsAttack"							, promotionInfo.HillsAttack },
	{"HillsDefense"							, promotionInfo.HillsDefense },
	{"OpenAttack"							, promotionInfo.OpenAttack },
	{"OpenRangedAttackMod"					, promotionInfo.OpenRangedAttackMod },
	{"OpenDefense"							, promotionInfo.OpenDefense },
	{"RoughAttack"							, promotionInfo.RoughAttack },
	{"RoughRangedAttackMod"					, promotionInfo.RoughRangedAttackMod },
	{"RoughDefense"							, promotionInfo.RoughDefense },
	{"AttackFortifiedMod"					, promotionInfo.AttackFortifiedMod },
	{"AttackWoundedMod"						, promotionInfo.AttackWoundedMod },
	{"UpgradeDiscount"						, promotionInfo.UpgradeDiscount },
	{"ExperiencePercent"					, promotionInfo.ExperiencePercent },
	{"AdjacentMod"							, promotionInfo.AdjacentMod },
	{"AttackMod"							, promotionInfo.AttackMod },
	{"DefenseMod"							, promotionInfo.DefenseMod },
	{"DropRange"							, promotionInfo.DropRange },
	{"GreatGeneral"							, promotionInfo.GreatGeneral },
	{"GreatGeneralModifier"					, promotionInfo.GreatGeneralModifier },
	{"FriendlyLandsModifier"				, promotionInfo.FriendlyLandsModifier },
	{"FriendlyLandsAttackModifier"			, promotionInfo.FriendlyLandsAttackModifier },
	{"OutsideFriendlyLandsModifier"			, promotionInfo.OutsideFriendlyLandsModifier },
	{"HPHealedIfDestroyEnemy"				, promotionInfo.HPHealedIfDestroyEnemy },
	{"ExtraWithdrawal"						, promotionInfo.ExtraWithdrawal },
	{"EmbarkExtraVisibility"				, promotionInfo.EmbarkExtraVisibility },
	{"LayerAnimationPath"					, promotionInfo.LayerAnimationPath },
	{"TechPrereq"							, promotionInfo.TechPrereq },
	{"Invisible"							, promotionInfo.Invisible },
	{"SeeInvisible"							, promotionInfo.SeeInvisible },
	{"PromotionPrereq"						, promotionInfo.PromotionPrereq },
	{"PromotionPrereqOr1"					, promotionInfo.PromotionPrereqOr1 },
	{"PromotionPrereqOr2"					, promotionInfo.PromotionPrereqOr2 },
	{"PromotionPrereqOr3"					, promotionInfo.PromotionPrereqOr3 },
	{"PromotionPrereqOr4"					, promotionInfo.PromotionPrereqOr4 }
	}	
	
end

function GetDefaultPromotionFieldText(iPromotionID, fieldType, fieldValue)
	local pPromotionInfo = GameInfo.UnitPromotions[iPromotionID]
	local strHelpText = ""
	local strWrittenHelpText = ""
	if fieldValue and fieldValue ~= 0 and fieldValue ~= "" then
		local fieldTextKey = "TXT_KEY_PROMOTION_TIP" .. string.upper( string.gsub(fieldType, '(%u)',  function(x) return "_"..x end) )
		local flagSign = ""
		local flagSignLine = ""

		if type(fieldValue) == "number" then
			fieldValue = (fieldValue % 1) and fieldValue or Locale.ToNumber(fieldValue, "#.#")
			flagSign = fieldValue > 0 and "+" or ""
		end

		local yieldFromFeature = (
			(fieldType == "FoodFromFeatures" and "Food")
			or (fieldType == "ProductionFromFeatures" and "Production")
			or (fieldType == "GoldFromFeatures" and "Gold")
			or (fieldType == "ScienceFromFeatures" and "Science")
		)
		
		
		if fieldType == "Name" then
			strHelpText = strHelpText .. Locale.ToUpper(Locale.ConvertTextKey( pPromotionInfo.Description ));
			strHelpText = strHelpText .. "[NEWLINE]----------------";

		elseif yieldFromFeature then
			
		else
			-- ** DEFAULT STRING HANDLING ** --
			local strExtraText = Locale.ConvertTextKey(fieldTextKey.."_EXTRA")
			if strExtraText ~= (fieldTextKey.."_EXTRA") then
				strWrittenHelpText = "[NEWLINE][NEWLINE]" .. strExtraText
			end
			strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, fieldValue, flagSign)
		end
	end
	
	return strHelpText, strWrittenHelpText
end
--]]

-------------------------------------------------
-- Completed initialization of MapModData.Fields
-------------------------------------------------

--log:Info("Completed initialization of MapModData.Fields")
--end


-- load custom mod-added fields
----log:Debug("Generating event LuaEvents.SetModFieldData(fields)")
--LuaEvents.SetModFieldData(fields)







--
--	Algorithms
--

-- UNIT
function GetHelpTextForUnit(iUnitID, bIncludeRequirementsInfo)
	local pUnitInfo = GameInfo.Units[iUnitID];
	
	local activePlayer = Players[Game.GetActivePlayer()];
	local activeTeam = Teams[Game.GetActiveTeam()];

	local strHelpText = "";
	local fieldTextKey = ""
	
	-- Name
	--strHelpText = strHelpText .. "ZOMBIE " .. Locale.ToUpper(Locale.ConvertTextKey( pUnitInfo.Description ));
	strHelpText = strHelpText .. Locale.ToUpper(Locale.ConvertTextKey( pUnitInfo.Description ));
	
	-- Cost
	local cost = activePlayer:GetUnitProductionNeeded(iUnitID)
	if iUnitID == GameInfo.Units.UNIT_SETTLER.ID then
		cost = Game.Round(cost * Civup.UNIT_SETTLER_BASE_COST / 105, -1)
	end
	strHelpText = strHelpText .. "[NEWLINE]----------------[NEWLINE]";
	strHelpText = strHelpText .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_COST", cost);
	-- Moves
	strHelpText = strHelpText .. "[NEWLINE]";
	strHelpText = strHelpText .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_MOVEMENT", pUnitInfo.Moves);
	local costMultiplier = nil
	if pUnitInfo.HurryCostModifier ~= -1 then
		costMultiplier = math.pow(cost * GameDefines.GOLD_PURCHASE_GOLD_PER_PRODUCTION, GameDefines.HURRY_GOLD_PRODUCTION_EXPONENT)
		costMultiplier = costMultiplier * (1 + pUnitInfo.HurryCostModifier / 100)
		costMultiplier = Game.Round(Game.RoundDown(costMultiplier, -1) / cost, 1)
		--costMultiplier = Game.Round(Game.RoundDown(costMultiplier, -1) / cost * 100, -1)
		strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_UNIT_HURRY_COST_MODIFIER", costMultiplier, costMultiplier);
	end
	
	if pUnitInfo.ExtraMaintenanceCost > 0 then
		strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_UNIT_MAINTENANCE", pUnitInfo.ExtraMaintenanceCost);
	end
	
	-- Range
	local iRange = pUnitInfo.Range;
	if (iRange ~= 0) then
		strHelpText = strHelpText .. "[NEWLINE]";
		strHelpText = strHelpText .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_RANGE", iRange);
	end
	
	-- Ranged Strength
	local iRangedStrength = pUnitInfo.RangedCombat;
	if (iRangedStrength ~= 0) then
		strHelpText = strHelpText .. "[NEWLINE]";
		strHelpText = strHelpText .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_RANGED_STRENGTH", iRangedStrength);
	end
	
	-- Strength
	local iStrength = pUnitInfo.Combat;
	if (iStrength ~= 0) then
		strHelpText = strHelpText .. "[NEWLINE]";
		strHelpText = strHelpText .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_STRENGTH", iStrength);
	end
	
	fieldTextKey = "TXT_KEY_PRODUCTION_BUILDING_REQUIRES_BUILDING"
	for pEntry in GameInfo.Unit_TechTypes() do
		if pEntry.UnitType == pUnitInfo.Type then
			local entryValue = Locale.ConvertTextKey(GameInfo.Technologies[pEntry.TechType].Description)
			strHelpText = strHelpText .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, entryValue)
		end
	end
	
	-- Resource Requirements
	local iNumResourcesNeededSoFar = 0;
	local iNumResourceNeeded;
	local iResourceID;
	for pResource in GameInfo.Resources() do
		iResourceID = pResource.ID;
		iNumResourceNeeded = Game.GetNumResourceRequiredForUnit(iUnitID, iResourceID);
		if (iNumResourceNeeded > 0) then
			-- First resource required
			if (iNumResourcesNeededSoFar == 0) then
				strHelpText = strHelpText .. "[NEWLINE]";
				strHelpText = strHelpText .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_RESOURCES_REQUIRED");
				strHelpText = strHelpText .. " " .. iNumResourceNeeded .. " " .. pResource.IconString .. " " .. Locale.ConvertTextKey(pResource.Description);
			else
				strHelpText = strHelpText .. ", " .. iNumResourceNeeded .. " " .. pResource.IconString .. " " .. Locale.ConvertTextKey(pResource.Description);
			end
			
			-- JON: Not using this for now, the formatting is better when everything is on the same line
			--iNumResourcesNeededSoFar = iNumResourcesNeededSoFar + 1;
		end
 	end
	
	-- Obsolescence
	local pObsolete = pUnitInfo.ObsoleteTech;
	if pObsolete ~= nil and pObsolete ~= "" then
		pObsolete = Locale.ConvertTextKey(GameInfo.Technologies[pObsolete].Description);
		strHelpText = strHelpText .. "[NEWLINE]";
		strHelpText = strHelpText .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_UNIT_OBSOLETE_TECH", pObsolete);
	end
	
	-- Pre-written Help text
	if (not pUnitInfo.Help) then
		--print("Invalid unit help");
		--print(strHelpText);
	else
		local strWrittenHelpText = Locale.ConvertTextKey( pUnitInfo.Help );
		if (strWrittenHelpText ~= nil and strWrittenHelpText ~= "") then
			-- Separator
			strHelpText = strHelpText .. "[NEWLINE]----------------[NEWLINE]";
			strHelpText = strHelpText .. strWrittenHelpText;
		end	
	end
	
	-- add help text for how much a new city would cost when looking at a settler
	if (activePlayer.CalcNextCityMaintenance ~= nil) and (pUnitInfo.Type == "UNIT_SETTLER") and (pUnitInfo.ExtraMaintenanceCost > 0) then
		strHelpText = strHelpText .. "[NEWLINE][NEWLINE]"..Locale.ConvertTextKey("TXT_KEY_NEXT_CITY_SETTLER_MAINTENANCE_TEXT",activePlayer:CalcNextCityMaintenance() or 0)
	end
	
	-- Requirements?
	if (bIncludeRequirementsInfo) then
		if (pUnitInfo.Requirements) then
			strHelpText = strHelpText .. Locale.ConvertTextKey( pUnitInfo.Requirements );
		end
	end
	
	-- AI Flavor Debug
	if Civup.SHOW_AI_PRIORITY_UNITS == 1 then
		strHelpText = strHelpText .. "[NEWLINE]----------------[NEWLINE]AI Priorites (debug info):"
		for flavorInfo in GameInfo.Unit_Flavors(string.format("UnitType = '%s'", pUnitInfo.Type)) do
			strHelpText = strHelpText .. string.format("[NEWLINE]%s %s", flavorInfo.Flavor, Locale.ToLower(string.gsub(flavorInfo.FlavorType, "FLAVOR_", "")));
		end
	end
	
	return strHelpText;
	
end

-- BUILDING
function GetHelpTextForBuilding(iBuildingID, bExcludeName, bExcludeHeader, bNoMaintenance, city, bExcludeWritten)
	local buildingInfo = GameInfo.Buildings[iBuildingID]
	local strText = ""
	local strHelpText = ""
	if buildingInfo.AlwaysShowHelp and buildingInfo.Help and buildingInfo.Help ~= "" then
		strHelpText = Locale.ConvertTextKey(buildingInfo.Help)
	end

	if MapModData.Fields.Buildings[iBuildingID] == nil then
		return nil
	end
	
	for _,fieldData in ipairs(MapModData.Fields.Buildings[iBuildingID]) do
		local fieldType		= fieldData[1]
		local fieldValue	= fieldData[2]
		local fieldText		= fieldData[3]
		local fieldHelpText	= fieldData[4]

		if type(fieldValue) == "function" then
			local fieldFunction = fieldValue
			fieldValue = fieldFunction(iBuildingID, fieldType, bExcludeName, bExcludeHeader, bNoMaintenance)
		end
		
		if fieldValue then
			if type(fieldText) == "function" then
				fieldText, fieldHelpText = fieldText(iBuildingID, fieldType, fieldValue)
			end
		
			strText = strText .. fieldText
			strHelpText = strHelpText .. fieldHelpText
		end
	end
	
	strText = string.gsub(strText, "^%[NEWLINE%]", "")
	strHelpText = string.gsub(strHelpText, "^%[NEWLINE%]", "")
	strHelpText = string.gsub(strHelpText, "^%[NEWLINE%]", "")
	
	-- AI Flavor Debug
	if Civup.SHOW_AI_PRIORITY_BUILDINGS == 1 then
		strText = strText .. "[NEWLINE]----------------[NEWLINE]AI Priorites (debug info):"
		for flavorInfo in GameInfo.Building_Flavors(string.format("BuildingType = '%s'", buildingInfo.Type)) do
			strText = strText .. string.format("[NEWLINE]%s %s", flavorInfo.Flavor, Locale.ToLower(string.gsub(flavorInfo.FlavorType, "FLAVOR_", "")));
		end
	end
	
	if bExcludeWritten ~= true and strHelpText ~= "" then
		strText = strText .. "[NEWLINE]----------------[NEWLINE]"
		strText = strText .. strHelpText
	end
	
	if strText == nil or strText == "" then
		strText = "Error!"
		log:Fatal("GetHelpTextForBuilding: error with %s", GameInfo.Buildings[iBuildingID].Type)
	end
	return strText;
end



--[[ PROMOTION
function GetHelpTextForPromotion(iPromotionID)
	local strHelpText = ""
	local strWrittenHelpText = GameInfo.UnitPromotions[iPromotionID].Help or ""
	
	-- Pre-written Help text
	if strWrittenHelpText ~= "" then
		strWrittenHelpText = Locale.ConvertTextKey(strWrittenHelpText)
	end
	
	if isFirstTimePromotions then
		isFirstTimePromotions = false
		SetDefaultPromotionFieldData()
		
		-- load custom mod-added Promotion fields
		LuaEvents.SetModPromotionFieldData()
	end
	
	for _,fieldData in ipairs(promotionFields) do
		local fieldType = fieldData[1]
		local fieldValue = fieldData[2]
		local fieldTextFunc = fieldData[3] or GetDefaultPromotionFieldText
		
		local fieldText, fieldWrittenText = fieldTextFunc(iBuildingID, fieldType, fieldValue)
		
		strHelpText = strHelpText .. fieldText
		strWrittenHelpText = strWrittenHelpText .. fieldWrittenText
	end
	
	strHelpText = string.gsub(strHelpText, "^(%[NEWLINE%])+", "")
	strWrittenHelpText = string.gsub(strWrittenHelpText, "^(%[NEWLINE%])+", "")
	strWrittenHelpText = string.gsub(strWrittenHelpText, "^(%[NEWLINE%])+", "")
	
	if bExcludeWritten ~= true and strWrittenHelpText ~= "" then
		strHelpText = strHelpText .. "[NEWLINE]--------[NEWLINE]"
		strHelpText = strHelpText .. strWrittenHelpText
	end
	
	return strHelpText;
end
--]]


-- IMPROVEMENT
function GetHelpTextForImprovement(iImprovementID, bExcludeName, bExcludeHeader, bNoMaintenance)
	local pImprovementInfo = GameInfo.Improvements[iImprovementID];
	
	local activePlayer = Players[Game.GetActivePlayer()];
	local activeTeam = Teams[Game.GetActiveTeam()];
	
	local strHelpText = "";
	
	if (not bExcludeHeader) then
		
		if (not bExcludeName) then
			-- Name
			strHelpText = strHelpText .. Locale.ToUpper(Locale.ConvertTextKey( pImprovementInfo.Description ));
			strHelpText = strHelpText .. "[NEWLINE]----------------[NEWLINE]";
		end
				
	end
		
	-- if we end up having a lot of these we may need to add some more stuff here
	
	-- Pre-written Help text
	if (pImprovementInfo.Help ~= nil) then
		local strWrittenHelpText = Locale.ConvertTextKey( pImprovementInfo.Help );
		if (strWrittenHelpText ~= nil and strWrittenHelpText ~= "") then
			-- Separator
			-- strHelpText = strHelpText .. "[NEWLINE]----------------[NEWLINE]";
			strHelpText = strHelpText .. strWrittenHelpText;
		end
	end
	
	return strHelpText;
	
end










-- PROJECT
function GetHelpTextForProject(iProjectID, bIncludeRequirementsInfo)
	local pProjectInfo = GameInfo.Projects[iProjectID];
	
	local activePlayer = Players[Game.GetActivePlayer()];
	local activeTeam = Teams[Game.GetActiveTeam()];
	
	local strHelpText = "";
	
	-- Name
	strHelpText = strHelpText .. Locale.ToUpper(Locale.ConvertTextKey( pProjectInfo.Description ));
	
	-- Cost
	local iCost = activePlayer:GetProjectProductionNeeded(iProjectID);
	strHelpText = strHelpText .. "[NEWLINE]----------------[NEWLINE]";
	strHelpText = strHelpText .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_COST", iCost);
	
	-- Pre-written Help text
	local strWrittenHelpText = Locale.ConvertTextKey( pProjectInfo.Help );
	if (strWrittenHelpText ~= nil and strWrittenHelpText ~= "") then
		-- Separator
		strHelpText = strHelpText .. "[NEWLINE]----------------[NEWLINE]";
		strHelpText = strHelpText .. strWrittenHelpText;
	end
	
	-- Requirements?
	if (bIncludeRequirementsInfo) then
		if (pProjectInfo.Requirements) then
			strHelpText = strHelpText .. Locale.ConvertTextKey( pProjectInfo.Requirements );
		end
	end
	
	return strHelpText;
	
end


-- CITY STATE STATUS
function GetCityStateStatus(pPlayer, iForPlayer, bWar)
	
	local strStatusTT = pPlayer:GetCitystateThresholdString();
	local strShortDescKey = pPlayer:GetCivilizationShortDescriptionKey();
	local bShowBasicHelp = not OptionsManager.IsNoBasicHelp()
	local activePlayer = Players[Game.GetActivePlayer()]
	
	local iInfluenceChangeThisTurn = Game.Round(pPlayer:GetFriendshipChangePerTurnTimes100(iForPlayer) / 100, 1);
	
	local strLabel = ""
	local strValue = ""
	local strBasicHelp = ""
	local strInfluenceRate = " "	
	
	if pPlayer:IsAllies(iForPlayer) then
		strLabel = "[COLOR_CYAN]"..Locale.ConvertTextKey("TXT_KEY_ALLIES").."[ENDCOLOR]"
		strValue = string.format("[COLOR_CYAN]%s[ENDCOLOR]", pPlayer:GetMinorCivFriendshipWithMajor(iForPlayer))
		strInfluenceRate = string.format("(%s%.1f)", iInfluenceChangeThisTurn >= 0 and "+" or "", iInfluenceChangeThisTurn)
		strBasicHelp = Locale.ConvertTextKey("TXT_KEY_ALLIES_CSTATE_TT", strShortDescKey, iInfluenceChangeThisTurn);
	elseif pPlayer:IsFriends(iForPlayer) then
		strLabel = "[COLOR_GREEN]"..Locale.ConvertTextKey("TXT_KEY_FRIENDS").."[ENDCOLOR]"
		strValue = string.format("[COLOR_GREEN]%s[ENDCOLOR]", pPlayer:GetMinorCivFriendshipWithMajor(iForPlayer))
		strInfluenceRate = string.format("(%s%.1f)", iInfluenceChangeThisTurn >= 0 and "+" or "", iInfluenceChangeThisTurn)
		strBasicHelp = Locale.ConvertTextKey("TXT_KEY_FRIENDS_CSTATE_TT", strShortDescKey, iInfluenceChangeThisTurn);
	elseif pPlayer:IsMinorPermanentWar(iActiveTeam) then
		strLabel = "[COLOR_RED]"..Locale.ConvertTextKey("TXT_KEY_ANGRY").."[ENDCOLOR]"
		strValue = string.format("[COLOR_RED]%s[ENDCOLOR]", pPlayer:GetMinorCivFriendshipWithMajor(iForPlayer))
		strBasicHelp = Locale.ConvertTextKey("TXT_KEY_PERMANENT_WAR_CSTATE_TT", strShortDescKey);
	elseif pPlayer:IsPeaceBlocked(iActiveTeam) then
		strLabel = "[COLOR_RED]"..Locale.ConvertTextKey("TXT_KEY_ANGRY").."[ENDCOLOR]"
		strValue = string.format("[COLOR_RED]%s[ENDCOLOR]", pPlayer:GetMinorCivFriendshipWithMajor(iForPlayer))
		strBasicHelp = Locale.ConvertTextKey("TXT_KEY_PEACE_BLOCKED_CSTATE_TT", strShortDescKey);
	elseif bWar then
		strLabel = "[COLOR_RED]"..Locale.ConvertTextKey("TXT_KEY_ANGRY").."[ENDCOLOR]"
		strValue = string.format("[COLOR_RED]%s[ENDCOLOR]", pPlayer:GetMinorCivFriendshipWithMajor(iForPlayer))
		strBasicHelp = Locale.ConvertTextKey("TXT_KEY_WAR_CSTATE_TT", strShortDescKey);
	elseif pPlayer:GetMinorCivFriendshipWithMajor(iForPlayer) < 0 then
		strLabel = "[COLOR_RED]"..Locale.ConvertTextKey("TXT_KEY_ANGRY").."[ENDCOLOR]"
		strValue = string.format("[COLOR_RED]%s[ENDCOLOR]", pPlayer:GetMinorCivFriendshipWithMajor(iForPlayer))
		strInfluenceRate = string.format("(%s%.1f)", iInfluenceChangeThisTurn >= 0 and "+" or "", iInfluenceChangeThisTurn)
		strBasicHelp = Locale.ConvertTextKey("TXT_KEY_ANGRY_CSTATE_TT", strShortDescKey, iInfluenceChangeThisTurn);
	else
		-- Neutral
		strLabel = Locale.ConvertTextKey("TXT_KEY_CITY_STATE_PERSONALITY_NEUTRAL")
		strValue = string.format("%s", pPlayer:GetMinorCivFriendshipWithMajor(iForPlayer))
		if pPlayer:GetMinorCivFriendshipWithMajor(iForPlayer) ~= 0 then
			strInfluenceRate = string.format("(%s%s)", iInfluenceChangeThisTurn >= 0 and "+" or "", iInfluenceChangeThisTurn)
		end
		strBasicHelp = Locale.ConvertTextKey("TXT_KEY_NEUTRAL_CSTATE_TT", strShortDescKey);
	end
	
	strStatusTT = strStatusTT .. Locale.ConvertTextKey("TXT_KEY_DIPLO_STATUS_TT", strLabel, strValue, strInfluenceRate)
	if bShowBasicHelp then
		strStatusTT = strStatusTT .. "[NEWLINE][NEWLINE]" .. strBasicHelp
	end

	local rivalInfluence, rivalID = activePlayer:GetRivalInfluence(pPlayer)
	local rival = Players[rivalID]
	if rival then	
		if activePlayer:HasMet(rival) then
			rival = rival:GetName()
		else
			rival = Locale.ConvertTextKey("TXT_KEY_UNMET_PLAYER")
		end
		--log:Debug("Best is %15s influence with %15s = %3s", rival, pPlayer:GetName(), rivalInfluence)	
		if (pPlayer:IsAllies(rivalID)) then
			rival			= string.format("[COLOR_CYAN]%s[ENDCOLOR]", rival)
			rivalInfluence	= string.format("[COLOR_CYAN]%s[ENDCOLOR]", rivalInfluence)
		elseif (pPlayer:IsFriends(rivalID)) then
			rival			= string.format("[COLOR_GREEN]%s[ENDCOLOR]", rival)
			rivalInfluence	= string.format("[COLOR_GREEN]%s[ENDCOLOR]", rivalInfluence)
		end
		strStatusTT = strStatusTT .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_INFLUENCE_RIVAL_TT", rival, rivalInfluence);
	end
	
	return strStatusTT;
	
end


-------------------------------------------------
-- Tooltips for Yields
-------------------------------------------------

showYieldString = {
--   show {  base, surplus,  total }  if Consumed YieldMod SurplusMod
		  { false,   false,   true }, --    -        -         -     
		  {  true,   false,   true }, --    -        -     SurplusMod
		  {  true,   false,   true }, --    -     YieldMod     -     
		  {  true,    true,   true }, --    -     YieldMod SurplusMod
		  { false,    true,  false }, -- Consumed    -         -     
		  { false,    true,   true }, -- Consumed    -     SurplusMod
		  {  true,    true,  false }, -- Consumed YieldMod     -     
		  {  true,    true,   true }  -- Consumed YieldMod SurplusMod
}

local surplusModStrings = {
	"TXT_KEY_FOODMOD_PLAYER",
	"TXT_KEY_FOODMOD_CAPITAL",
	"TXT_KEY_FOODMOD_UNHAPPY",
	"TXT_KEY_FOODMOD_WLTKD"
}

local yieldHelp = {
	[YieldTypes.YIELD_FOOD]			= "TXT_KEY_FOOD_HELP_INFO",
	[YieldTypes.YIELD_PRODUCTION]	= "TXT_KEY_PRODUCTION_HELP_INFO",
	[YieldTypes.YIELD_GOLD]			= "TXT_KEY_GOLD_HELP_INFO",
	[YieldTypes.YIELD_SCIENCE]		= "TXT_KEY_SCIENCE_HELP_INFO",
	[YieldTypes.YIELD_CULTURE]		= "TXT_KEY_CULTURE_HELP_INFO",
	[YieldTypes.YIELD_FAITH]		= "TXT_KEY_FAITH_HELP_INFO"
}

-- Deprecated vanilla functions
function GetFoodTooltip(city)		return GetYieldTooltip(city, YieldTypes.YIELD_FOOD)			 end
function GetProductionTooltip(city)	return GetYieldTooltip(city, YieldTypes.YIELD_PRODUCTION)	 end
function GetGoldTooltip(city)		return GetYieldTooltip(city, YieldTypes.YIELD_GOLD)			 end
function GetScienceTooltip(city)	return GetYieldTooltip(city, YieldTypes.YIELD_SCIENCE)		 end
function GetCultureTooltip(city)	return GetYieldTooltip(city, YieldTypes.YIELD_CULTURE)		 end
function GetFaithTooltip(city)		return GetYieldTooltip(city, YieldTypes.YIELD_FAITH)		 end
function GetYieldTooltipHelper(city, iYieldType, strIcon) return GetYieldTooltip(city, iYieldType) end

function GetYieldTooltip(city, yieldID)
	--log:Debug("City_GetSurplusYieldRate %15s %15s", city:GetName(), GameInfo.Yields[yieldID].Type)
	local ownerID			= city:GetOwner();
	local owner				= Players[ownerID]
	local iBase				= City_GetBaseYieldRate(city, yieldID)
	local iTotal			= City_GetYieldRate(city, yieldID)
	local strIconString		= GameInfo.Yields[yieldID].IconString
	local strTooltip		= ""
	local baseModString		= City_GetBaseYieldModifierTooltip(city, yieldID)
	local surplusModString	= "[NEWLINE]"
	
	if yieldID == YieldTypes.YIELD_SCIENCE then
		if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_SCIENCE) then
			return Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_SCIENCE_OFF_TOOLTIP")
		end
	end
	
	-- Header
	local yieldStored	= City_GetYieldStored(city, yieldID)
	local yieldNeeded	= City_GetYieldNeeded(city, yieldID)
	local yieldTurns	= City_GetYieldTurns(city, yieldID)
	yieldTurns			= (yieldTurns == math.huge) and "-" or yieldTurns
	if yieldNeeded > 0 and yieldTurns ~= math.huge then
		strTooltip = strTooltip .. string.format(
			"%s: %.1i/%.1i%s (%s %s)",
			Locale.ConvertTextKey("TXT_KEY_MODDING_HEADING_PROGRESS"),
			City_GetYieldStored(city, yieldID), 
			City_GetYieldNeeded(city, yieldID),
			strIconString,
			yieldTurns,
			Locale.ConvertTextKey("TXT_KEY_TURNS")
		)
		strTooltip = strTooltip .. "[NEWLINE][NEWLINE]";
	end

	-- Base Yield from Terrain
	local iYieldFromTerrain = Game.Round(City_GetBaseYieldFromTerrain(city, yieldID));
	if (iYieldFromTerrain ~= 0) then
		strTooltip = strTooltip .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_YIELD_FROM_TERRAIN", iYieldFromTerrain, strIconString);
		strTooltip = strTooltip .. "[NEWLINE]";
	end
	
	-- Base Yield from Buildings
	local iYieldFromBuildings = Game.Round(City_GetBaseYieldFromBuildings(city, yieldID));
	if (iYieldFromBuildings ~= 0) then
		strTooltip = strTooltip .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_YIELD_FROM_BUILDINGS", iYieldFromBuildings, strIconString);
		strTooltip = strTooltip .. "[NEWLINE]";
	end
	
	-- Base Yield from Specialists
	local iYieldFromSpecialists = Game.Round(City_GetBaseYieldFromSpecialists(city, yieldID));
	if (iYieldFromSpecialists ~= 0) then
		strTooltip = strTooltip .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_YIELD_FROM_SPECIALISTS", iYieldFromSpecialists, strIconString);
		strTooltip = strTooltip .. "[NEWLINE]";
	end
	
	-- Base Yield from Religion
	local iYieldFromReligion = Game.Round(City_GetBaseYieldFromReligion(city, yieldID));
	if (iYieldFromReligion ~= 0) then
		strTooltip = strTooltip .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_YIELD_FROM_RELIGION", iYieldFromReligion, strIconString);
		strTooltip = strTooltip .. "[NEWLINE]";
	end
	
	-- Base Yield from Pop
	local iYieldFromPop = Game.Round(City_GetBaseYieldFromPopulation(city, yieldID));
	if (iYieldFromPop ~= 0) then
		strTooltip = strTooltip .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_YIELD_FROM_POP", iYieldFromPop, strIconString);
		strTooltip = strTooltip .. "[NEWLINE]";
	end
	
	-- Base Yield from Policies
	local iYieldFromPolicies = Game.Round(City_GetBaseYieldFromPolicies(city, yieldID));
	if (iYieldFromPolicies ~= 0) then
		strTooltip = strTooltip .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_YIELD_FROM_POLICIES", iYieldFromPolicies, strIconString);
		strTooltip = strTooltip .. "[NEWLINE]";
	end

	-- Base Yield from Traits
	local iYieldFromTraits = Game.Round(City_GetBaseYieldFromTraits(city, yieldID));
	if (iYieldFromTraits ~= 0) then
		strTooltip = strTooltip .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_YIELD_FROM_TRAITS", iYieldFromTraits, strIconString);
		strTooltip = strTooltip .. "[NEWLINE]";
	end
	
	-- Base Yield from Processes
	local iYieldFromProcesses = Game.Round(City_GetBaseYieldFromProcesses(city, yieldID));
	if (iYieldFromProcesses ~= 0) then
		strTooltip = strTooltip .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_YIELD_FROM_PROCESSES", iYieldFromProcesses, strIconString);
		strTooltip = strTooltip .. "[NEWLINE]";
	end
	
	-- Base Yield from Misc
	local iYieldFromMisc = Game.Round(City_GetBaseYieldFromMisc(city, yieldID));
	if (iYieldFromMisc ~= 0) and (yieldID ~= YieldTypes.YIELD_SCIENCE) then
		strTooltip = strTooltip .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_YIELD_FROM_MISC", iYieldFromMisc, strIconString);
		strTooltip = strTooltip .. "[NEWLINE]";
	end
	
	-- Base Yield from Citystates
	local cityYieldFromMinorCivs	= City_GetBaseYieldFromMinorCivs(city, yieldID);
	if cityYieldFromMinorCivs ~= 0 then
		strTooltip = strTooltip .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_YIELD_FROM_MINOR_CIVS", Game.Round(cityYieldFromMinorCivs, 1), strIconString) .. "[NEWLINE]";
	end
	
	if Civup.ENABLE_DISTRIBUTED_MINOR_CIV_YIELDS then
		local playerMinorCivYield	= owner:GetYieldsFromCitystates()[yieldID];
		if playerMinorCivYield > 0 then
			local cityWeight		= City_GetWeight(city, yieldID);
			local playerWeight		= owner:GetTotalWeight(yieldID);
			for weight in GameInfo.CityWeights() do
				if weight.IsCityStatus == true and city[weight.Type](city) then
					local result = city[weight.Type](city)
					if type(result) == "number" then
						if weight.Type == "GetPopulation" then
							result = weight.Value * result
						else
							result = 100 * weight.Value * result
						end
					else
						result = 100 * weight.Value
					end
					strTooltip = strTooltip .. "     " .. Locale.ConvertTextKey(weight.Description, Game.Round(result)) .. "[NEWLINE]";
				end
			end
			if city:GetFocusType() == CityYieldFocusTypes[yieldID] then
				weight = GameInfo.CityWeights.CityFocus
				strTooltip = strTooltip .. "     " .. Locale.ConvertTextKey(weight.Description, Game.Round(weight.Value * 100), strIconString) .. "[NEWLINE]";
			end
			if not Players[ownerID]:IsCapitalConnectedToCity(city) then
				weight = GameInfo.CityWeights.NotConnected;
				strTooltip = strTooltip .. "     " .. Locale.ConvertTextKey(weight.Description, Game.Round(weight.Value * 100)) .. "[NEWLINE]";
			end
			if yieldID == YieldTypes.YIELD_FOOD and city:IsForcedAvoidGrowth() then
				weight = Game.Round(owner:GetAvoidModifier() * 100);
				strTooltip = strTooltip .. "     " .. Locale.ConvertTextKey("TXT_KEY_CITYSTATE_MODIFIER_IS_AVOID", weight) .. "[NEWLINE]";
				if weight > 0 then
					strTooltip = strTooltip .. "     " .. Locale.ConvertTextKey("TXT_KEY_CITYSTATE_MODIFIER_IS_AVOID_MANY", Civup.AVOID_GROWTH_FULL_EFFECT_CUTOFF) .. "[NEWLINE]";
				end
			end
		
			strTooltip = strTooltip .. "     " .. Locale.ConvertTextKey(
				"TXT_KEY_CITYSTATE_MODIFIER_WEIGHT_TOTAL",
				Game.Round(cityWeight, 1),
				Game.Round(playerWeight, 1),
				Game.Round(100 * cityWeight / playerWeight, 0),
				Game.Round(playerMinorCivYield, 1),
				strIconString
			)
			strTooltip = strTooltip .. "[NEWLINE]";
		end
	end
	
	
	---------------------------
	-- Build combined string
	---------------------------
	
	-- Base modifier
	local baseMod = City_GetBaseYieldRateModifier(city, yieldID)
	local hasBaseMod = (baseMod ~= 0)
		
	-- Surplus
	local iYieldEaten = City_GetYieldConsumed(city, yieldID)
	local iSurplus = City_GetSurplusYieldRate(city, yieldID)
	local isConsumed = (iYieldEaten ~= 0)
	
	-- Surplus modifier
	local surplusMod = City_GetSurplusYieldRateModifier(city, yieldID)
	local hasSurplusMod = (surplusMod ~= 0)
	
	-- Base and surplus yield
	local truthiness		= Game.GetTruthTableResult(showYieldString, {isConsumed, hasBaseMod, hasSurplusMod})
	local showBaseYield		= truthiness[1]
	local showSurplusYield	= truthiness[2]
	local showTotalYield	= truthiness[3]
	--print("inputs="..tostring(isConsumed)..","..tostring(hasBaseMod)..","..tostring(hasSurplusMod).."  outputs="..tostring(showBaseYield)..","..tostring(showSurplusYield))
	
	
	--
	-- Append each part to the string
	--
	
	

	if yieldID == YieldTypes.YIELD_FOOD then
		if iSurplus > 0 and Game.Round(owner:GetYieldRate(YieldTypes.YIELD_HAPPINESS)) <= GameDefines.VERY_UNHAPPY_THRESHOLD then
			baseModString = baseModString .. Locale.ConvertTextKey("TXT_KEY_FOODMOD_UNHAPPY", GameDefines.VERY_UNHAPPY_GROWTH_PENALTY)
		end
		local settlerMod = City_GetCapitalSettlerModifier(city)
		if settlerMod ~= 0 then
			baseModString = baseModString .. Locale.ConvertTextKey("TXT_KEY_PRODMOD_YIELD_SETTLER_POLICY", settlerMod)
		end
	--[[elseif yieldID == YieldTypes.YIELD_PRODUCTION then
		local settlerMod = City_GetCapitalSettlerModifier(city)
		if settlerMod ~= 0 then
			baseModString = baseModString .. Locale.ConvertTextKey("TXT_KEY_PRODMOD_YIELD_SETTLER_POLICY", settlerMod)
		end--]]
	elseif yieldID == YieldTypes.YIELD_CULTURE then
		local buildingMod = City_GetBaseYieldModFromBuildings(city, yieldID)
		if buildingMod ~= 0 then
			baseModString = baseModString .. Locale.ConvertTextKey("TXT_KEY_PRODMOD_YIELD_BUILDINGS", buildingMod)				
		end
	end
	
	local baseModFromPuppet = City_GetBaseYieldModFromPuppet(city, yieldID)
	if baseModFromPuppet ~= 0 then
		baseModString = baseModString .. Locale.ConvertTextKey("TXT_KEY_PRODMOD_PUPPET", baseModFromPuppet)
	end
	
	local surplusModFromBuildings = City_GetSurplusYieldModFromBuildings(city, yieldID)
	if surplusModFromBuildings ~= 0 then
		surplusModString = surplusModString .. Locale.ConvertTextKey("TXT_KEY_PRODMOD_YIELD_BUILDINGS", surplusModFromBuildings) 
	end
	
	local surplusModFromReligion = City_GetSurplusYieldModFromReligion(city, yieldID)
	if surplusModFromReligion ~= 0 then
		surplusModString = surplusModString .. Locale.ConvertTextKey("TXT_KEY_PRODMOD_YIELD_BELIEF", surplusModFromReligion)
	end
	
	local surplusModFromGAs = owner:GetGoldenAgeSurplusYieldModifier(yieldID)
	if surplusModFromGAs ~= 0 then
		surplusModString = surplusModString .. Locale.ConvertTextKey("TXT_KEY_PRODMOD_YIELD_GOLDEN_AGE", surplusModFromGAs) 
	end
	
	if hasSurplusMod then
		local strTarget = ""
		local strStart, strEnd
		for _,v in ipairs(surplusModStrings) do
			strTarget = string.gsub(Game.Literalize(Locale.ConvertTextKey(v, "value")), "value", '%%%-%?%%d+')
			--log:Fatal("strTarget = '%s'", strTarget)
			strStart, strEnd = string.find(baseModString, strTarget)
			if strStart then
				strTarget = string.sub(baseModString, strStart, strEnd)
				baseModString = string.gsub(baseModString, Game.Literalize(strTarget), "")
				surplusModString = surplusModString .. strTarget
			end
		end
	end
	surplusModString = string.gsub(surplusModString, "^"..Game.Literalize("[NEWLINE]"), "")
	baseModString = string.gsub(baseModString, "^"..Game.Literalize("[NEWLINE]"), "")
	baseModString = string.gsub(baseModString, Game.Literalize("[NEWLINE]").."$", "")
	
	strTooltip = strTooltip .. "----------------";
	
	if showBaseYield then
		strTooltip = strTooltip .. "[NEWLINE]";
		strTooltip = strTooltip .. Locale.ConvertTextKey("TXT_KEY_YIELD_BASE", Game.Round(iBase,1), strIconString);
	end
	--print(strTooltip)
	
	if hasBaseMod then
		iBase = iBase * (1 + baseMod / 100)
		strTooltip = strTooltip .. "[NEWLINE]";
		strTooltip = strTooltip .. baseModString;
	end
	
	--print(strTooltip)
	if showSurplusYield then
		local surplusString = Locale.ConvertTextKey("TXT_KEY_YIELD_SURPLUS", Game.Round(iSurplus,1), strIconString); 
		if iSurplus > 0 then
			surplusString = "[COLOR_POSITIVE_TEXT]"..surplusString.."[ENDCOLOR]"
		elseif iSurplus < 0 then
			surplusString = "[COLOR_NEGATIVE_TEXT]"..surplusString.."[ENDCOLOR]"
		end
		surplusString = surplusString .. "  " .. Locale.ConvertTextKey("TXT_KEY_YIELD_USAGE", Game.Round(iBase, 1), iYieldEaten);
		strTooltip = strTooltip .. "[NEWLINE]";
		strTooltip = strTooltip .. surplusString
	end
	
	if hasSurplusMod then
		--strTooltip = strTooltip .. "[NEWLINE]";
		strTooltip = strTooltip .. surplusModString;
	end
	
	if showTotalYield then
		strTooltip = strTooltip .. "[NEWLINE]";
		if (iTotal >= 0) then
			strTooltip = strTooltip .. Locale.ConvertTextKey("TXT_KEY_YIELD_TOTAL", Game.Round(iTotal, 1), strIconString);
		else
			strTooltip = strTooltip .. Locale.ConvertTextKey("TXT_KEY_YIELD_TOTAL_NEGATIVE", Game.Round(iTotal, 1), strIconString);
		end
	end
		
	-- Yield from Other Yields (food converted to production)
	local iYieldFromOtherYields = Game.Round(City_GetYieldFromFood(city, yieldID));
	if (iYieldFromOtherYields ~= 0) then
		strTooltip = strTooltip .."  ".. Locale.ConvertTextKey("TXT_KEY_YIELD_FROM_OTHER_YIELDS",
																iTotal - iYieldFromOtherYields,
																strIconString,
																iYieldFromOtherYields,
																"[ICON_FOOD]",
																Locale.ConvertTextKey(GameInfo.Yields.YIELD_FOOD.Description)
																);
		strTooltip = strTooltip .. "[NEWLINE]";
	end
	
	-- Footer
	
	if yieldID == YieldTypes.YIELD_FAITH then
		strTooltip = strTooltip .. "[NEWLINE]----------------[NEWLINE]" .. GetReligionTooltip(city)
	end

	if not OptionsManager.IsNoBasicHelp() then
		strTooltip = strTooltip .. "[NEWLINE][NEWLINE]" .. Locale.ConvertTextKey(yieldHelp[yieldID]);
	end
	
	return strTooltip;

end


----------------------------------------------------------------        
-- MOOD INFO
----------------------------------------------------------------        
function GetMoodInfo(iOtherPlayer)
	
	local strInfo = "";
	
	-- Always war!
	if (Game.IsOption(GameOptionTypes.GAMEOPTION_ALWAYS_WAR)) then
		return "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_ALWAYS_WAR_TT");
	end
	
	local iActivePlayer = Game.GetActivePlayer();
	local pActivePlayer = Players[iActivePlayer];
	local pActiveTeam = Teams[pActivePlayer:GetTeam()];
	local pOtherPlayer = Players[iOtherPlayer];
	local iOtherTeam = pOtherPlayer:GetTeam();
	local pOtherTeam = Teams[iOtherTeam];
	
	--local iVisibleApproach = Players[iActivePlayer]:GetApproachTowardsUsGuess(iOtherPlayer);
	
	-- At war right now
	--[[if (pActiveTeam:IsAtWar(iOtherTeam)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_AT_WAR") .. "[NEWLINE]";
		
	-- Not at war right now
	else
		
		-- We've fought before
		if (pActivePlayer:GetNumWarsFought(iOtherPlayer) > 0) then
			-- They don't appear to be mad
			if (iVisibleApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_FRIENDLY or 
				iVisibleApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_NEUTRAL) then
				strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_PAST_WAR_NEUTRAL") .. "[NEWLINE]";
			-- They aren't happy with us
			else
				strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_PAST_WAR_BAD") .. "[NEWLINE]";
			end
		end
	end]]--
		
	-- Neutral things
	--[[if (iVisibleApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_AFRAID) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_AFRAID") .. "[NEWLINE]";
	end]]--
		
	-- Good things
	--[[if (pOtherPlayer:WasResurrectedBy(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_RESURRECTED") .. "[NEWLINE]";
	end]]--
	--[[if (pActivePlayer:IsDoF(iOtherPlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_DOF") .. "[NEWLINE]";
	end]]--
	--[[if (pActivePlayer:IsPlayerDoFwithAnyFriend(iOtherPlayer)) then		-- Human has a mutual friend with the AI
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_MUTUAL_DOF") .. "[NEWLINE]";
	end]]--
	--[[if (pActivePlayer:IsPlayerDenouncedEnemy(iOtherPlayer)) then		-- Human has denounced an enemy of the AI
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_MUTUAL_ENEMY") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:GetNumCiviliansReturnedToMe(iActivePlayer) > 0) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_CIVILIANS_RETURNED") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherTeam:HasEmbassyAtTeam(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_HAS_EMBASSY") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:GetNumTimesIntrigueSharedBy(iActivePlayer) > 0) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_SHARED_INTRIGUE") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerForgivenForSpying(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_FORGAVE_FOR_SPYING") .. "[NEWLINE]";
	end]]--
	
	-- Bad things
	--[[if (pOtherPlayer:IsFriendDeclaredWarOnUs(iActivePlayer)) then		-- Human was a friend and declared war on us
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_HUMAN_FRIEND_DECLARED_WAR") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsFriendDenouncedUs(iActivePlayer)) then			-- Human was a friend and denounced us
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_HUMAN_FRIEND_DENOUNCED") .. "[NEWLINE]";
	end]]--
	--[[if (pActivePlayer:GetWeDeclaredWarOnFriendCount() > 0) then		-- Human declared war on friends
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_HUMAN_DECLARED_WAR_ON_FRIENDS") .. "[NEWLINE]";
	end]]--
	--[[if (pActivePlayer:GetWeDenouncedFriendCount() > 0) then			-- Human has denounced his friends
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_HUMAN_DENOUNCED_FRIENDS") .. "[NEWLINE]";
	end]]--
	--[[if (pActivePlayer:GetNumFriendsDenouncedBy() > 0) then			-- Human has been denounced by friends
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_HUMAN_DENOUNCED_BY_FRIENDS") .. "[NEWLINE]";
	end]]--
	--[[if (pActivePlayer:IsDenouncedPlayer(iOtherPlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_DENOUNCED_BY_US") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsDenouncedPlayer(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_DENOUNCED_BY_THEM") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerDoFwithAnyEnemy(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_HUMAN_DOF_WITH_ENEMY") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerDenouncedFriend(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_HUMAN_DENOUNCED_FRIEND") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerNoSettleRequestEverAsked(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_NO_SETTLE_ASKED") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerStopSpyingRequestEverAsked(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_STOP_SPYING_ASKED") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsDemandEverMade(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_TRADE_DEMAND") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:GetNumTimesRobbedBy(iActivePlayer) > 0) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_CAUGHT_STEALING") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:GetNumTimesCultureBombed(iActivePlayer) > 0) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_CULTURE_BOMB") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:GetNegativeReligiousConversionPoints(iActivePlayer) > 0) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_RELIGIOUS_CONVERSIONS") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:HasOthersReligionInMostCities(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_ADOPTING_MY_RELIGION") .. "[NEWLINE]";
	end]]--
	--[[if (pActivePlayer:HasOthersReligionInMostCities(iOtherPlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_ADOPTING_HIS_RELIGION") .. "[NEWLINE]";
	end]]--
	--[[local myLateGamePolicies = pActivePlayer:GetLateGamePolicyTree();
	local otherLateGamePolicies = pOtherPlayer:GetLateGamePolicyTree();
	if (myLateGamePolicies ~= PolicyBranchTypes.NO_POLICY_BRANCH_TYPE and otherLateGamePolicies ~= PolicyBranchTypes.NO_POLICY_BRANCH_TYPE) then
	    local myPoliciesStr = Locale.ConvertTextKey(GameInfo.PolicyBranchTypes[myLateGamePolicies].Description);
	    print (myPoliciesStr);
		if (myLateGamePolicies == otherLateGamePolicies) then
			strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_SAME_LATE_POLICY_TREES", myPoliciesStr) .. "[NEWLINE]";
		else
			local otherPoliciesStr = Locale.ConvertTextKey(GameInfo.PolicyBranchTypes[otherLateGamePolicies].Description);
			strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_DIFFERENT_LATE_POLICY_TREES", myPoliciesStr, otherPoliciesStr) .. "[NEWLINE]";
		end
	end]]--
	--[[if (pOtherPlayer:IsPlayerBrokenMilitaryPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_MILITARY_PROMISE") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerIgnoredMilitaryPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_MILITARY_PROMISE_IGNORED") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerBrokenExpansionPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_EXPANSION_PROMISE") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerIgnoredExpansionPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_EXPANSION_PROMISE_IGNORED") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerBrokenBorderPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_BORDER_PROMISE") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerIgnoredBorderPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_BORDER_PROMISE_IGNORED") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerBrokenAttackCityStatePromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_CITY_STATE_PROMISE") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerIgnoredAttackCityStatePromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_CITY_STATE_PROMISE_IGNORED") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerBrokenBullyCityStatePromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_BULLY_CITY_STATE_PROMISE_BROKEN") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerIgnoredBullyCityStatePromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_BULLY_CITY_STATE_PROMISE_IGNORED") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerBrokenSpyPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_SPY_PROMISE_BROKEN") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerIgnoredSpyPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_SPY_PROMISE_IGNORED") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerBrokenNoConvertPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_NO_CONVERT_PROMISE_BROKEN") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerIgnoredNoConvertPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_NO_CONVERT_PROMISE_IGNORED") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerBrokenCoopWarPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_COOP_WAR_PROMISE") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerRecklessExpander(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_RECKLESS_EXPANDER") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:GetNumRequestsRefused(iActivePlayer) > 0) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_REFUSED_REQUESTS") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:GetRecentTradeValue(iActivePlayer) > 0) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_TRADE_PARTNER") .. "[NEWLINE]";	
	end]]--
	--[[if (pOtherPlayer:GetCommonFoeValue(iActivePlayer) > 0) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_COMMON_FOE") .. "[NEWLINE]";	
	end]]--
	--[[if (pOtherPlayer:GetRecentAssistValue(iActivePlayer) > 0) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_ASSISTANCE_TO_THEM") .. "[NEWLINE]";	
	end	]]--
	--[[if (pOtherPlayer:IsLiberatedCapital(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_LIBERATED_CAPITAL") .. "[NEWLINE]";	
	end]]--
	--[[if (pOtherPlayer:IsLiberatedCity(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_LIBERATED_CITY") .. "[NEWLINE]";	
	end	]]--
	--[[if (pOtherPlayer:IsGaveAssistanceTo(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_ASSISTANCE_FROM_THEM") .. "[NEWLINE]";	
	end	]]--	
	--[[if (pOtherPlayer:IsHasPaidTributeTo(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_PAID_TRIBUTE") .. "[NEWLINE]";	
	end	]]--
	--[[if (pOtherPlayer:IsNukedBy(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_NUKED") .. "[NEWLINE]";	
	end]]--	
	--[[if (pOtherPlayer:IsCapitalCapturedBy(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_CAPTURED_CAPITAL") .. "[NEWLINE]";	
	end	]]--

	-- Protected Minors
	--[[if (pOtherPlayer:IsAngryAboutProtectedMinorKilled(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_PROTECTED_MINORS_KILLED") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsAngryAboutProtectedMinorAttacked(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_PROTECTED_MINORS_ATTACKED") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsAngryAboutProtectedMinorBullied(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_PROTECTED_MINORS_BULLIED") .. "[NEWLINE]";
	end]]--
	
	-- Bullied Minors
	--[[if (pOtherPlayer:IsAngryAboutSidedWithTheirProtectedMinor(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_SIDED_WITH_MINOR") .. "[NEWLINE]";
	end]]--
	
	--local iActualApproach = pOtherPlayer:GetMajorCivApproach(iActivePlayer)
	
	-- MOVED TO LUAPLAYER
	--[[
	-- Bad things we don't want visible if someone is friendly (acting or truthfully)
	if (iVisibleApproach ~= MajorCivApproachTypes.MAJOR_CIV_APPROACH_FRIENDLY) then-- and
		--iActualApproach ~= MajorCivApproachTypes.MAJOR_CIV_APPROACH_DECEPTIVE) then
		if (pOtherPlayer:GetLandDisputeLevel(iActivePlayer) > DisputeLevelTypes.DISPUTE_LEVEL_NONE) then
			strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_LAND_DISPUTE") .. "[NEWLINE]";
		end
		--if (pOtherPlayer:GetVictoryDisputeLevel(iActivePlayer) > DisputeLevelTypes.DISPUTE_LEVEL_NONE) then
			--strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_VICTORY_DISPUTE") .. "[NEWLINE]";
		--end
		if (pOtherPlayer:GetWonderDisputeLevel(iActivePlayer) > DisputeLevelTypes.DISPUTE_LEVEL_NONE) then
			strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_WONDER_DISPUTE") .. "[NEWLINE]";
		end
		if (pOtherPlayer:GetMinorCivDisputeLevel(iActivePlayer) > DisputeLevelTypes.DISPUTE_LEVEL_NONE) then
			strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_MINOR_CIV_DISPUTE") .. "[NEWLINE]";
		end
		if (pOtherPlayer:GetWarmongerThreat(iActivePlayer) > ThreatTypes.THREAT_NONE) then
			strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_WARMONGER_THREAT") .. "[NEWLINE]";
		end
	end
	]]--
	
	local aOpinion = pOtherPlayer:GetOpinionTable(iActivePlayer);
	--local aOpinionList = {};
	for i,v in ipairs(aOpinion) do
		--aOpinionList[i] = "[ICON_BULLET]" .. v .. "[NEWLINE]";
		strInfo = strInfo .. "[ICON_BULLET]" .. v .. "[NEWLINE]";
	end
	--strInfo = table.cat(aOpinionList, "[NEWLINE]");

	--  No specific events - let's see what string we should use
	if (strInfo == "") then
		
		-- Appears Friendly
		if (iVisibleApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_FRIENDLY) then
			strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_FRIENDLY");
		-- Appears Guarded
		elseif (iVisibleApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_GUARDED) then
			strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_GUARDED");
		-- Appears Hostile
		elseif (iVisibleApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_HOSTILE) then
			strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_HOSTILE");
		-- Neutral - default string
		else
			strInfo = "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_DEFAULT_STATUS");
		end
	end
	
	-- Remove extra newline off the end if we have one
	if (Locale.EndsWith(strInfo, "[NEWLINE]")) then
		local iNewLength = Locale.Length(strInfo)-9;
		strInfo = Locale.Substring(strInfo, 1, iNewLength);
	end
	
	return strInfo;
	
end
------------------------------
-- Helper function to build religion tooltip string
function GetReligionTooltip(city)

	local religionToolTip = "";
	
	if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION)) then
		return religionToolTip;
	end

	local bFoundAFollower = false;
	local eReligion = city:GetReligiousMajority();
	local bFirst = true;
	
	if (eReligion >= 0) then
		bFoundAFollower = true;
		local religion = GameInfo.Religions[eReligion];
		local strReligion = Locale.ConvertTextKey(Game.GetReligionName(eReligion));
	    local strIcon = religion.IconString;
		local strPressure = "";
			
		if (city:IsHolyCityForReligion(eReligion)) then
			if (not bFirst) then
				religionToolTip = religionToolTip .. "[NEWLINE]";
			else
				bFirst = false;
			end
			religionToolTip = religionToolTip .. Locale.ConvertTextKey("TXT_KEY_HOLY_CITY_TOOLTIP_LINE", strIcon, strReligion);			
		end

		local iPressure = city:GetPressurePerTurn(eReligion);
		if (iPressure > 0) then
			strPressure = Locale.ConvertTextKey("TXT_KEY_RELIGIOUS_PRESSURE_STRING", iPressure);
		end
			
		local iFollowers = city:GetNumFollowers(eReligion)
		if (not bFirst) then
			religionToolTip = religionToolTip .. "[NEWLINE]";
		else
			bFirst = false;
		end
		religionToolTip = religionToolTip .. Locale.ConvertTextKey("TXT_KEY_RELIGION_TOOLTIP_LINE", strIcon, iFollowers, strPressure);
	end	
		
	local iReligionID;
	for pReligion in GameInfo.Religions() do
		iReligionID = pReligion.ID;
		
		if (iReligionID >= 0 and iReligionID ~= eReligion and city:GetNumFollowers(iReligionID) > 0) then
			bFoundAFollower = true;
			local religion = GameInfo.Religions[iReligionID];
			local strReligion = Locale.ConvertTextKey(Game.GetReligionName(iReligionID));
			local strIcon = religion.IconString;
			local strPressure = "";

			if (city:IsHolyCityForReligion(iReligionID)) then
				if (not bFirst) then
					religionToolTip = religionToolTip .. "[NEWLINE]";
				else
					bFirst = false;
				end
				religionToolTip = religionToolTip .. Locale.ConvertTextKey("TXT_KEY_HOLY_CITY_TOOLTIP_LINE", strIcon, strReligion);			
			end
				
			local iPressure = city:GetPressurePerTurn(iReligionID);
			if (iPressure > 0) then
				strPressure = Locale.ConvertTextKey("TXT_KEY_RELIGIOUS_PRESSURE_STRING", iPressure);
			end
			
			local iFollowers = city:GetNumFollowers(iReligionID)
			if (not bFirst) then
				religionToolTip = religionToolTip .. "[NEWLINE]";
			else
				bFirst = false;
			end
			religionToolTip = religionToolTip .. Locale.ConvertTextKey("TXT_KEY_RELIGION_TOOLTIP_LINE", strIcon, iFollowers, strPressure);
		end
	end
	
	if (not bFoundAFollower) then
		religionToolTip = religionToolTip .. Locale.ConvertTextKey("TXT_KEY_RELIGION_NO_FOLLOWERS");
	end
		
	return religionToolTip;
end