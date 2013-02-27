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

--
-- Globals
--

do
	log = Events.LuaLogger:New()
	log:SetLevel("WARN")

	timeStart = os.clock()

	isFirstTimePromotions = true
	errorMsg = {Type=fieldType, Section=fieldSection, Priority=linePriority, TextBody=fieldType}

	Game.Fields				= Game.Fields or {}
	Game.Fields.Units		= Game.Fields.Units or {}
	Game.Fields.Buildings	= Game.Fields.Buildings or {}
	Game.Fields.Promotions	= Game.Fields.Promotions or {}

	MAX_RESOURCES = {}
	for resourceInfo in GameInfo.Resources() do
		resUsageType = Game.GetResourceUsageType(resourceInfo.ID)
		MAX_RESOURCES[resUsageType] = (MAX_RESOURCES[resUsageType] or 0) + 1
	end

	MAX_SPECIALISTS = 0
	for specialistInfo in GameInfo.Specialists() do
		MAX_SPECIALISTS = MAX_SPECIALISTS + 1
	end

	resUsageTypeStr = {}
	resUsageTypeStr[ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC] = Locale.ConvertTextKey("TXT_KEY_CIV5_RESOURCE_STRATEGIC")
	resUsageTypeStr[ResourceUsageTypes.RESOURCEUSAGE_LUXURY] = Locale.ConvertTextKey("TXT_KEY_CIV5_RESOURCE_LUXURY")
	resUsageTypeStr[ResourceUsageTypes.RESOURCEUSAGE_BONUS] = Locale.ConvertTextKey("TXT_KEY_CIV5_RESOURCE_BONUS")

	fieldTextKey		= nil
	fieldFootKey		= nil
	fieldFoot			= nil
	fieldPriority		= nil
	lineType			= nil
	lineTextKey			= nil
	lineSection			= nil
	linePriority		= nil
	linePrefix			= nil
	lineSign			= nil
	lineValue			= nil
	lineExtra			= nil
	buildingInfo		= nil
	buildingClassInfo	= nil
	activePlayer		= nil
	activeTeam			= nil
	adjustedCost		= nil
	subFields			= nil
end


--
-- Main Method
--

Game.GetDefaultBuildingFieldText = Game.GetDefaultBuildingFieldText or function(buildingID, fieldType, fieldSection, fPriority, fieldValue, city)
	if not buildingID or not fieldType then
		log:Fatal("Game.GetDefaultBuildingFieldText buildingID=%s fieldType=%s fieldValue=%s fieldPriority=%s", buildingID, fieldType, fieldValue, fPriority)
	end
	if not fieldValue or fieldValue == 0 or fieldValue == "" then
		return {}
	end
	
	lineType			= fieldType
	buildingInfo		= GameInfo.Buildings[buildingID]
	buildingClassInfo	= GameInfo.BuildingClasses[buildingInfo.BuildingClass]
	activePlayer		= Players[Game.GetActivePlayer()]
	activeTeam			= Teams[Game.GetActiveTeam()]
	adjustedCost		= activePlayer:GetBuildingProductionNeeded(buildingID)	
	fieldTextKey		= "TXT_KEY_BUILDING_EFFECT" .. string.upper( string.gsub(lineType, '(%u)',  function(x) return "_"..x end) )
	fieldFootKey		= Locale.ConvertTextKey(fieldTextKey.."_FOOT")
	fieldFoot			= (fieldFootKey ~= (fieldTextKey.."_FOOT")) and fieldFootKey
	fieldPriority		= fPriority
	lineTextKey			= fieldTextKey
	lineSection			= fieldSection
	linePriority		= fieldPriority
	linePrefix			= ""
	lineSign			= ""
	lineValue			= fieldValue
	lineExtra			= ""	
	subFields			= {}
	
	if type(lineValue) == "number" then
		lineValue = ToDecimal(lineValue)
		lineSign = GetSign(lineValue)
	end
	
	if lineType == "Name" then
		table.insert(subFields, {Type=lineType, Section=fieldSection, Priority=fieldPriority,
			TextBody = Locale.ToUpper(Locale.ConvertTextKey(buildingInfo.Description))
		})
		
	elseif lineType == "Cost" then
		lineValue = activePlayer:GetBuildingProductionNeeded(buildingID)
		InsertSubField()
		
	elseif lineType == "FaithCost" then
		lineValue = activePlayer:GetBuildingProductionNeeded(buildingID)
		InsertSubField()

	elseif lineType == "HurryCostModifier" then
		if buildingInfo.Cost <= 0 or buildingInfo[lineType] == -1 then return {} end
		lineValue = activePlayer:GetPurchaseCostMod(activePlayer:GetBuildingProductionNeeded(buildingID), buildingInfo[lineType])
		InsertSubField()

	elseif lineType == "NumCityCostMod" then
		lineValue = buildingInfo[lineType]
		InsertSubField()

	elseif lineType == "PopCostMod" then
		lineValue = buildingInfo[lineType]
		InsertSubField()

	elseif lineType == "GoldMaintenance" then
		if city and city:GetNumFreeBuilding(buildingID) > 0 then return {} end
		lineValue = buildingInfo[lineType]
		InsertSubField()

	elseif lineType == "UnmoddedHappiness" then
		lineValue = activePlayer:GetBuildingYield(buildingID, YieldTypes.YIELD_HAPPINESS_NATIONAL, city)
		InsertSubField()

	elseif lineType == "Happiness" then
		lineValue = activePlayer:GetBuildingYield(buildingID, YieldTypes.YIELD_HAPPINESS_CITY, city)
		InsertSubField()

	elseif lineType == "AlreadyBuilt" then
		lineValue = Building_IsAlreadyBuilt(buildingID, activePlayer)
		InsertSubField()

	elseif lineType == "Replaces" then
		local defaultObjectType = buildingClassInfo.DefaultBuilding
		if buildingInfo.Type ~= defaultObjectType then		
			lineValue = Locale.ConvertTextKey(GameInfo.Buildings[defaultObjectType].Description)
			InsertSubField()
		end

	elseif lineType == "YieldChange" then
		for yieldInfo in GameInfo.Yields("Type <> 'YIELD_HAPPINESS_CITY' AND Type <> 'YIELD_HAPPINESS_NATIONAL'") do
			lineValue = activePlayer:GetBuildingYield(buildingID, yieldInfo.ID, city)
			--[[
			if buildingID == GameInfo.Buildings.BUILDING_SHRINE.ID and yieldInfo.Type == "YIELD_FOOD" then
				log:Warn("Shrine food=%s in %s", lineValue, city:GetName())
			end
			--]]
			if lineValue ~= 0 then
				linePrefix = string.format("%s {%s}", yieldInfo.IconString, yieldInfo.Description)
				linePriority = fieldPriority + (100 * yieldInfo.ListPriority)
				InsertSubField()
			end
		end

	elseif lineType == "YieldMod" then
		for yieldInfo in GameInfo.Yields() do
			lineValue = activePlayer:GetBuildingYieldMod(buildingID, yieldInfo.ID, city)
			if lineValue ~= 0 then
				linePrefix = string.format("%s {%s}", yieldInfo.IconString, yieldInfo.Description)
				linePriority = fieldPriority + (100 * yieldInfo.ListPriority)
				InsertSubField()
			end
		end

	elseif lineType == "YieldInstant" then
		return GetYieldInfo{table="Building_YieldInstant"}

	elseif lineType == "YieldPerPop" then
		return GetYieldInfo{table="Building_YieldChangesPerPop", div100=true}

	elseif lineType == "YieldModSurplus" then
		return GetYieldInfo{table="Building_YieldSurplusModifiers"}

	elseif lineType == "YieldModInAllCities" then
		return GetYieldInfo{table="Building_GlobalYieldModifiers"}

	elseif lineType == "YieldFromPlots" then
		return GetYieldInfo{table="Building_PlotYieldChanges", tableExtra="Plots", cellExtra="PlotType"}

	elseif lineType == "YieldFromSea" then
		return GetYieldInfo{table="Building_SeaPlotYieldChanges", tableExtra="Plots", typeExtra="PLOT_OCEAN"}
		
	elseif lineType == "YieldFromTerrain" then
		return GetYieldInfo{table="Building_TerrainYieldChanges", tableExtra="Terrains", cellExtra="TerrainType"}
		
	elseif lineType == "YieldFromRivers" then
		return GetYieldInfo{table="Building_RiverPlotYieldChanges"}

	elseif lineType == "YieldFromFeatures" then
		local yieldList = {}
		for row in GameInfo.Building_FeatureYieldChanges{BuildingType = buildingInfo.Type} do
			if row.FeatureType ~= buildingInfo.NotFeature then
				if not yieldList[row.YieldType] then yieldList[row.YieldType] = {} end
				yieldList[row.YieldType][row.Yield] = (yieldList[row.YieldType][row.Yield] or "") .. Locale.ConvertTextKey(GameInfo.Features[row.FeatureType].Description) .. ", "
			end
		end
		return ConvertYieldList(lineType, fieldSection, fieldPriority, lineTextKey, yieldList)

	elseif lineType == "YieldFromTech" then
		return GetYieldInfo{table="Building_TechEnhancedYieldChanges", tableExtra="Technologies", cellExtra="EnhancedYieldTech"}

	elseif lineType == "YieldFromBuildings" then
		return GetYieldInfo{table="Building_BuildingClassYieldChanges", cell="YieldChange", tableExtra="BuildingClasses", cellExtra="BuildingClassType"}

	elseif lineType == "YieldModFromBuildings" then
		return GetYieldInfo{table="Building_BuildingClassYieldModifiers", tableExtra="BuildingClasses", cellExtra="BuildingClassType"}
		
	elseif lineType == "YieldModHurry" then
		return GetYieldInfo{table="Building_HurryModifiers", cell="HurryCostModifier", yieldType=GameInfo.HurryInfos.HURRY_GOLD.YieldType}

	elseif lineType == "YieldModCombat" then
		return GetYieldInfo{table="Building_UnitCombatProductionModifiers", cell="Modifier", tableExtra="UnitCombatInfos", cellExtra="UnitCombatType", yieldType="YIELD_PRODUCTION"}

	elseif lineType == "YieldModDomain" then
		return GetYieldInfo{table="Building_DomainProductionModifiers", cell="Modifier", tableExtra="Domains", cellExtra="DomainType", yieldType="YIELD_PRODUCTION"}
		
	elseif lineType == "YieldModMilitary" or lineType == "YieldModBuilding" or lineType == "YieldModWonder" or lineType == "YieldModSpace" then
		lineType = string.gsub(lineType, "YieldMod(.*)", function(x) return x.."ProductionModifier" end)
		InsertSubField(GameInfo.Yields.YIELD_PRODUCTION)

	elseif lineType == "YieldStorage" then
		lineType = "FoodKept"
		InsertSubField(GameInfo.Yields.YIELD_FOOD)

	elseif lineType == "InstantBorderPlots" then
		InsertSubField(GameInfo.Yields.YIELD_CULTURE)

	elseif lineType == "InstantBorderRadius" then
		InsertSubField(GameInfo.Yields.YIELD_CULTURE)

	elseif lineType == "YieldFromUsingGreatPeople" then
		lineType = "GreatPersonExpendGold"
		InsertSubField(GameInfo.Yields.YIELD_GOLD)

	elseif lineType == "TradeRouteModifier" then
		InsertSubField(GameInfo.Yields.YIELD_GOLD)

	elseif lineType == "MedianTechPercentChange" then
		InsertSubField(GameInfo.Yields.YIELD_SCIENCE)

	elseif lineType == "ReligiousPressureModifier" then
		InsertSubField(GameInfo.Yields.YIELD_FAITH)

	elseif lineType == "YieldFromResources" then
		local yieldRes = {}
		local numResources = {}
		for row in GameInfo.Building_ResourceYieldChanges{BuildingType = buildingInfo.Type} do
			local resourceInfo	= GameInfo.Resources[row.ResourceType]
			local resUsageType	= tonumber(Game.GetResourceUsageType(resourceInfo.ID))
			if not yieldRes[row.YieldType] then yieldRes[row.YieldType] = {} end
			if not yieldRes[row.YieldType][row.Yield] then yieldRes[row.YieldType][row.Yield] = {} end
			if not yieldRes[row.YieldType][row.Yield][resUsageType] then yieldRes[row.YieldType][row.Yield][resUsageType] = {} end
			yieldRes[row.YieldType][row.Yield][resUsageType].string = (yieldRes[row.YieldType][row.Yield][resUsageType].string or "") .. resourceInfo.IconString
			yieldRes[row.YieldType][row.Yield][resUsageType].quantity = (yieldRes[row.YieldType][row.Yield][resUsageType].quantity or 0) + 1
		end
		
		-- merge usage strings
		local yieldList = {}
		for yieldType, yields in pairs(yieldRes) do
			if not yieldList[yieldType] then yieldList[yieldType] = {} end			
			for yield, resources in pairs(yields) do
				if not yieldList[yieldType][yield] then yieldList[yieldType][yield] = "" end	
				local numMaxed = 0
				for resUsageType, res in pairs(resources) do
					if res.quantity >= MAX_RESOURCES[resUsageType] then
						yieldList[yieldType][yield] = yieldList[yieldType][yield] .. resUsageTypeStr[resUsageType]..", "
						numMaxed = numMaxed + 1
					else
						yieldList[yieldType][yield] = yieldList[yieldType][yield] .. res.string
					end
				end
				if numMaxed == 3 then
					yieldList[yieldType][yield] = Locale.ConvertTextKey("TXT_KEY_SV_ICONS_ALL") .. " " .. Locale.ConvertTextKey("TXT_KEY_SV_ICONS_RESOURCES")
				end				
			end
		end
		
		return ConvertYieldList(lineType, fieldSection, fieldPriority, lineTextKey, yieldList)

	elseif lineType == "YieldFromSpecialists" then
		local yieldList = {}
		local  yieldNum = {}
		for row in GameInfo.Building_SpecialistYieldChanges{BuildingType = buildingInfo.Type} do
			if not yieldList[row.YieldType] then yieldList[row.YieldType] = {} end
			if not  yieldNum[row.YieldType] then  yieldNum[row.YieldType] = {} end
			yieldList[row.YieldType][row.Yield] = (yieldList[row.YieldType][row.Yield] or "") .. Locale.ConvertTextKey(GameInfo.Specialists[row.SpecialistType].Description) .. ", "
			 yieldNum[row.YieldType][row.Yield] = ( yieldNum[row.YieldType][row.Yield] or 0) + 1
			if   yieldNum[row.YieldType][row.Yield] == MAX_SPECIALISTS then
				yieldList[row.YieldType][row.Yield] = Locale.ConvertTextKey("TXT_KEY_PEOPLE_SECTION_1")
			end
		end
		return ConvertYieldList(lineType, fieldSection, fieldPriority, lineTextKey, yieldList)

	elseif lineType == "SpecialistType" then
		local specInfo = GameInfo.Specialists[buildingInfo.SpecialistType]
		local fieldPriority = fieldPriority * specInfo.ListPriority
		if buildingInfo.SpecialistCount ~= 0 then
			lineTextKey = "TXT_KEY_BUILDING_EFFECT_SPECIALIST_POINTS"
			linePrefix = string.format("%s {%s}", specInfo.IconString, specInfo.Description)
			lineValue = buildingInfo.SpecialistCount
			InsertSubField()
		end
		if buildingInfo.GreatPeopleRateChange ~= 0 then
			lineTextKey = "TXT_KEY_BUILDING_EFFECT_GREAT_PERSON_POINTS"
			linePrefix = specInfo.IconString
			lineValue = buildingInfo.GreatPeopleRateChange
			lineExtra = string.format("{%s}", specInfo.Description)
			InsertSubField()
		end

	elseif lineType == "ExperienceDomain" then
		for row in GameInfo.Building_DomainFreeExperiences{BuildingType = buildingInfo.Type} do
			lineValue = row.Experience
			lineExtra = Locale.ConvertTextKey(GameInfo.Domains[row.DomainType].Description)
			InsertSubField()
		end

	elseif lineType == "ExperienceCombat" then
		for row in GameInfo.Building_UnitCombatFreeExperiences{BuildingType = buildingInfo.Type} do
			lineValue = row.Experience
			lineExtra = Locale.ConvertTextKey(GameInfo.UnitCombatInfos[row.UnitCombatType].Description)
			InsertSubField()
		end

	elseif lineType == "FreeBuildingThisCity" then
		local uniqueID = activePlayer:GetUniqueBuildingID(buildingInfo[lineType])
		lineValue = string.format("{%s}", GameInfo.Buildings[uniqueID].Description)
		InsertSubField()

	elseif lineType == "FreeBuilding" then
		local uniqueID = activePlayer:GetUniqueBuildingID(buildingInfo[lineType])
		lineValue = string.format("{%s}", GameInfo.Buildings[uniqueID].Description)
		InsertSubField()

	elseif lineType == "FreeUnits" then
		for row in GameInfo.Building_FreeUnits{BuildingType = buildingInfo.Type} do
			local unitInfo = GameInfo.Units[row.UnitType]
			lineValue = row.NumUnits
			lineExtra = Locale.ConvertTextKey(unitInfo.Description)
			if unitInfo.MoveRate == "GREAT_PERSON" then
				lineTextKey = "TXT_KEY_BUILDING_EFFECT_FREE_GREAT_PERSON"
			end
			InsertSubField()
		end

	elseif lineType == "FreeResources" then
		for row in GameInfo.Building_ResourceQuantity{BuildingType = buildingInfo.Type} do
			local resInfo = GameInfo.Resources[row.ResourceType]
			linePrefix = resInfo.IconString
			lineValue = row.Quantity
			lineExtra = Locale.ConvertTextKey(resInfo.Description)
			InsertSubField()
		end

	elseif lineType == "NotFeature" then
		lineValue = string.format("{%s}", GameInfo.Features[lineValue].Description)
		InsertSubField()

	elseif lineType == "RequiresNearAll" then
		lineValue = ""
		for row in GameInfo.Building_LocalResourceAnds{BuildingType = buildingInfo.Type} do
			lineValue = lineValue .. GameInfo.Resources[row.ResourceType].IconString
		end
		InsertSubField()

	elseif lineType == "RequiresNearAny" then
		lineValue = ""
		for row in GameInfo.Building_LocalResourceOrs{BuildingType = buildingInfo.Type} do
			lineValue = lineValue .. GameInfo.Resources[row.ResourceType].IconString
		end
		InsertSubField()

	elseif lineType == "RequiresResourceConsumption" then
		lineValue = ""
		for row in GameInfo.Building_ResourceQuantityRequirements{BuildingType = buildingInfo.Type} do
			lineValue = string.format("%s%s%s ", lineValue, row.Cost, GameInfo.Resources[row.ResourceType].IconString)
		end
		InsertSubField()

	elseif lineType == "NearbyTerrainRequired" then
		lineValue = string.format("{%s}", GameInfo.Terrains[lineValue].Description)
		InsertSubField()

	elseif lineType == "RequiresTech" then
		for row in GameInfo.Building_TechAndPrereqs{BuildingType = buildingInfo.Type} do
			lineValue = string.format("{%s}", GameInfo.Technologies[row.TechType].Description)
			InsertSubField()
		end

	elseif lineType == "RequiresBuilding" then
		for row in GameInfo.Building_ClassesNeededInCity{BuildingType = buildingInfo.Type} do
			local uniqueID = activePlayer:GetUniqueBuildingID(row.BuildingClassType)
			lineValue = string.format("{%s}", GameInfo.Buildings[uniqueID].Description)
			InsertSubField()
		end

	elseif lineType == "RequiresBuildingInCities" then
		for row in GameInfo.Building_PrereqBuildingClasses{BuildingType = buildingInfo.Type} do
			local uniqueID = activePlayer:GetUniqueBuildingID(row.BuildingClassType)
			lineValue = string.format("{%s}", GameInfo.Buildings[uniqueID].Description)
			if row.NumBuildingNeeded == -1 then
				lineExtra = Locale.ConvertTextKey("TXT_KEY_SV_ICONS_ALL")
			else
				lineExtra = row.NumBuildingNeeded
			end
			InsertSubField()
		end

	elseif lineType == "RequiresBuildingInPercentCities" then
		for row in GameInfo.Building_PrereqBuildingClasses{BuildingType = buildingInfo.Type} do
			local uniqueID = activePlayer:GetUniqueBuildingID(row.BuildingClassType)
			lineValue = string.format("{%s}", GameInfo.Buildings[uniqueID].Description)
			if row.PercentBuildingNeeded == -1 then
				lineExtra = Locale.ConvertTextKey("TXT_KEY_SV_ICONS_ALL")
			else
				lineExtra = row.PercentBuildingNeeded
			end
			InsertSubField()
		end
		
	else
		-- ** DEFAULT STRING HANDLING ** --
		InsertSubField()
	end
	
	return subFields
end
	
--
-- Private Helper Methods
--


function ToDecimal(value)
	return (value % 1) and value or Locale.ToNumber(value, "#.#")
end

function GetSign(value)
	return value > 0 and "+" or ""
end
	
function ConvertYieldList(fieldType, fieldSection, fieldPriority, lineTextKey, yieldList)
	local subFields = {}
	for yieldType, yieldData in pairs(yieldList) do
		local yieldInfo = GameInfo.Yields[yieldType]
		if not yieldInfo then
			log:Error("ConvertYieldList fieldType=%s : %s is not a valid yieldType", fieldType, yieldType)
			return errorMsg
		end
		local linePrefix = string.format("%s {%s}", yieldInfo.IconString, yieldInfo.Description)
		local linePriority = fieldPriority + (100 * yieldInfo.ListPriority)
		if type(yieldData) == "table" then
			for yieldValue, objectString in pairs(yieldData) do
				table.insert(subFields, {
					Type=fieldType, Section=fieldSection, Priority=linePriority,
					TextBody = Locale.ConvertTextKey(lineTextKey, linePrefix, GetSign(yieldValue), ToDecimal(yieldValue), string.gsub(objectString, ", $", ""))
				})
			end
		else
			table.insert(subFields, {
				Type=fieldType, Section=fieldSection, Priority=linePriority,
				TextBody = Locale.ConvertTextKey(lineTextKey, linePrefix, GetSign(yieldData), ToDecimal(yieldData))
			})
		end
	end
	return subFields
end

function GetYieldInfo(info)
	-- Error checking
	if not GameInfo[info.table] then
		log:Error("GetDefaultBuildingFieldText lineType=%s : GameInfo.%s does not exist", lineType, info.table)
		return errorMsg
	elseif info.tableExtra and not GameInfo[info.tableExtra] then
		log:Error("GetDefaultBuildingFieldText lineType=%s : GameInfo.%s does not exist", lineType, info.tableExtra)
		return errorMsg
	end
	
	-- Algorithm
	local yieldList = {}		
	for row in GameInfo[info.table]{BuildingType = buildingInfo.Type} do
		-- Error checking	
		if info.cell and not row[info.cell or "Yield"] then
			log:Error("GetDefaultBuildingFieldText lineType=%s : column %s does not exist in GameInfo.%s", lineType, info.cell, info.table)
			return errorMsg
		end
		if not (info.yieldType or row[info.cellYieldType or "YieldType"]) then
			log:Error("GetDefaultBuildingFieldText lineType=%s : column %s does not exist in GameInfo.%s", lineType, "YieldType", info.table)
			return errorMsg
		end
		if info.cellExtra then
			if not row[info.cellExtra] then
				log:Error("GetDefaultBuildingFieldText lineType=%s : column %s does not exist in GameInfo.%s", lineType, info.cellExtra, info.table)
				return errorMsg
			end
			info.typeExtra = row[info.cellExtra]
		end				
		if info.cellExtra and not GameInfo[info.tableExtra][info.typeExtra] then
			log:Error("GetDefaultBuildingFieldText lineType=%s : GameInfo.%s.%s does not exist", lineType, info.table, info.typeExtra)
			return errorMsg
		elseif info.cellExtra and not GameInfo[info.tableExtra][info.typeExtra].Description then
			log:Error("GetDefaultBuildingFieldText lineType=%s : GameInfo.%s.%s.Description is null", lineType, info.table, info.typeExtra)
			return errorMsg
		end
		
		-- Algorithm
		local yieldType = info.yieldType or row[info.cellYieldType or "YieldType"]
		local yield = row[info.cell or "Yield"]
		if not yieldList[yieldType] then yieldList[yieldType] = {} end		
		
		if info.tableExtra then
			yieldList[yieldType][yield] = (yieldList[yieldType][yield] or "") .. Locale.ConvertTextKey(GameInfo[info.tableExtra][info.typeExtra].Description) .. ", "
		else
			yieldList[yieldType] = info.div100 and yield/100 or yield
		end
	end
	return ConvertYieldList(lineType, lineSection, linePriority, lineTextKey, yieldList)
end
		
function InsertSubField(yieldInfo)
	if yieldInfo then
		linePrefix		= string.format("%s {%s}", yieldInfo.IconString, yieldInfo.Description)
		linePriority	= fieldPriority + (100 * yieldInfo.ListPriority)
		lineValue		= buildingInfo[lineType]
	end
	if not lineValue or lineValue == 0 or lineValue == -1 or lineValue == "" then
		return
	end
	if type(lineValue) == "function" then
		log:Warn("GetDefaultBuildingFieldText %s value is an unhandled function!", lineType)
		return
	end
	table.insert(subFields, {Type=lineType, Section=lineSection, Priority=linePriority, TextBody = Locale.ConvertTextKey(lineTextKey, linePrefix, lineSign, lineValue, lineExtra), TextFoot = fieldFoot})
end

--print(string.format("%3s ms loading InfoTooltipInclude.lua building field functions", Game.Round(os.clock() - buildingFieldStartTime, 8)))
local buildingFieldStartTime = os.clock()

civup_BuildingInfo = nil
civup_BuildingClassInfo = nil
if not Game.InitializedFields then
	Game.InitializedFields = true
	Game.Fields.Buildings = {}
	for buildingInfo in GameInfo.Buildings() do
		local buildingID = buildingInfo.ID
		civup_BuildingInfo = buildingInfo
		civup_BuildingClassInfo = GameInfo.BuildingClasses[buildingInfo.BuildingClass]
		Game.Fields.Buildings[buildingID] = {}
		for row in GameInfo.BuildingFields() do
			if row.Value then
				local v = {Type=row.Type, Section=row.Section, Priority=row.Priority, Dynamic=row.Dynamic, Value=assert(loadstring("return " .. row.Value))()}
				if v.Value and v.Value ~= 0 and v.Value ~= -1 and v.Value ~= "" then
					if v.Dynamic == 1 then
						table.insert(Game.Fields.Buildings[buildingID], v)
					else
						for _, subField in pairs(Game.GetDefaultBuildingFieldText(buildingID, v.Type, v.Section, v.Priority, v.Value)) do
							if subField.Section and subField.Priority and subField.TextBody then
								table.insert(Game.Fields.Buildings[buildingID], {Type=v.Type, Section=subField.Section, Priority=subField.Priority, TextBody=subField.TextBody, TextFoot=subField.TextFoot})
							else
								log:Error("Init Fields %25s %20s %20s section=%3s priority=%3s textBody=%s", buildingInfo.Type, v.Type, subField.Type, subField.Section, subField.Priority, subField.TextBody)
							end
						end
					end
				end
			else
				log:Error("civup_BuildingInfo %s value is nil!", row.Type)
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


