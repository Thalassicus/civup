-- TU - LuaEvents
-- Author: Thalassicus
-- DateCreated: 2/29/2012 7:29:27 AM
--------------------------------------------------------------

--
-- Prototypes
--

LuaEvents.MT_Initialize					= LuaEvents.MT_Initialize					or function()							end
LuaEvents.PrintDebug					= LuaEvents.PrintDebug						or function()							end
LuaEvents.ActivePlayerTurnStart_Turn	= LuaEvents.ActivePlayerTurnStart_Turn		or function()							end
LuaEvents.ActivePlayerTurnStart_Player	= LuaEvents.ActivePlayerTurnStart_Player	or function(player)						end
LuaEvents.ActivePlayerTurnStart_Unit	= LuaEvents.ActivePlayerTurnStart_Unit		or function(unit)						end
LuaEvents.ActivePlayerTurnStart_City	= LuaEvents.ActivePlayerTurnStart_City		or function(city, owner)				end
LuaEvents.ActivePlayerTurnStart_Plot	= LuaEvents.ActivePlayerTurnStart_Plot		or function(plot)						end
LuaEvents.ActivePlayerTurnEnd_Turn		= LuaEvents.ActivePlayerTurnEnd_Turn		or function()							end
LuaEvents.ActivePlayerTurnEnd_Player	= LuaEvents.ActivePlayerTurnEnd_Player		or function(player)						end
LuaEvents.ActivePlayerTurnEnd_Unit		= LuaEvents.ActivePlayerTurnEnd_Unit		or function(unit)						end
LuaEvents.ActivePlayerTurnEnd_City		= LuaEvents.ActivePlayerTurnEnd_City		or function(city, owner)				end
LuaEvents.ActivePlayerTurnEnd_Plot		= LuaEvents.ActivePlayerTurnEnd_Plot		or function(plot)						end
LuaEvents.NewCity						= LuaEvents.NewCity							or function(hexPos, playerID, cityID, cultureType, eraType, continent, populationSize, size, fowState) end
LuaEvents.NewUnit						= LuaEvents.NewUnit							or function(playerID, unitID, hexVec, unitType, cultureType, civID, primaryColor, secondaryColor, unitFlagIndex, fogState, selected, military, notInvisible) end
LuaEvents.NewImprovement				= LuaEvents.NewImprovement					or function(hexX, hexY, cultureArtID, continentArtID, playerID, engineImprovementTypeDoNotUse, improvementID, engineResourceTypeDoNotUse, resourceID, eraID, improvementState) end
LuaEvents.NewTech						= LuaEvents.NewTech							or function(player, techID, changeID)	end
LuaEvents.PlotAcquired					= LuaEvents.PlotAcquired					or function(plot, newOwnerID)			end
LuaEvents.PolicyAdopted					= LuaEvents.PolicyAdopted					or function(policyID, isPolicy)			end
LuaEvents.CityOccupied					= LuaEvents.CityOccupied					or function(city, player, isForced)		end
LuaEvents.CityPuppeted					= LuaEvents.CityPuppeted					or function(city, player, isForced)		end
LuaEvents.CityLiberated					= LuaEvents.CityLiberated					or function(city, player, isForced)		end
LuaEvents.PromotionEarned				= LuaEvents.PromotionEarned					or function(unit, promotionType)		end
LuaEvents.UnitUpgraded					= LuaEvents.UnitUpgraded					or function(unit)						end
LuaEvents.BuildingConstructed			= LuaEvents.BuildingConstructed				or function(player, city, buildingID)	end
LuaEvents.BuildingDestroyed				= LuaEvents.BuildingDestroyed				or function(player, city, buildingID)	end
LuaEvents.CheckPlotBuildingsStatus		= LuaEvents.CheckPlotBuildingsStatus		or function(plot)						end

--
-- Includes
--

include("MT_Utils.lua")
include("MT_LuaLogger.lua")
include("MT_LoadSave.lua")
include("MT_City.lua")
include("MT_Player.lua")
include("MT_Plot.lua")
include("MT_Unit.lua")
include("MT_Misc.lua")

local log = Events.LuaLogger:New()
log:SetLevel("WARN")

local startAITurnTime = nil

MapModData.VEM.VanillaTurnTimes	= 0
MapModData.VEM.StartTurn		= Game.GetGameTurn()
MapModData.VEM.TotalPlayers		= 0
MapModData.VEM.TotalCities		= 0
MapModData.VEM.TotalUnits		= 0
MapModData.VEM.ReplacingUnit	= false


MapModData.VEM.StartTurnTimes = {
	Turn		= 0,
	Players		= 0,
	Units		= 0,
	Cities		= 0,
	Policies	= 0,
	Plots		= 0,
	Total		= 0
}

MapModData.VEM.EndTurnTimes = {
	Turn		= 0,
	Players		= 0,
	Units		= 0,
	Cities		= 0,
	Policies	= 0,
	Plots		= 0,
	Total		= 0
}

--
-- Event Definitions
--

----------------------------------------------------------------
--[[ LuaEvents.ActivePlayerTurnStart usage example:

function UpdatePromotions(pUnit, pOwner)
	-- does stuff for each unit, once at the start of the turn
end
LuaEvents.ActivePlayerTurnStart_Unit.Add(UpdatePromotions)

-- also available:
-- LuaEvents.ActivePlayerTurnStart_Turn		()
-- LuaEvents.ActivePlayerTurnStart_Player	(player)
-- LuaEvents.ActivePlayerTurnStart_Unit		(unit)
-- LuaEvents.ActivePlayerTurnStart_City		(city, owner) 
-- LuaEvents.ActivePlayerTurnStart_Plot		(plot)
]]


function OnTurnStart()
	if startAITurnTime then
		log:Info("VanillaStuff %10s %10.3f seconds", "Total", os.clock() - startAITurnTime)
		MapModData.VEM.VanillaTurnTimes = MapModData.VEM.VanillaTurnTimes + (os.clock() - startAITurnTime)
	else
		log:Info("OnTurnStart")
	end
	
	--log:Info("OnTurnStart")
	local startClockTime = os.clock()
	local stepClockTime = os.clock()
	LuaEvents.ActivePlayerTurnStart_Turn()
	MapModData.VEM.StartTurnTimes.Turn = MapModData.VEM.StartTurnTimes.Turn + (os.clock() - stepClockTime)
	--log:Info("OnTurnStart %10s %10.3f seconds", "Turn", os.clock() - stepClockTime)
	stepClockTime = os.clock()
	for playerID, player in pairs(Players) do
		if player:IsAliveCiv() then
			LuaEvents.ActivePlayerTurnStart_Player(player)
			MapModData.VEM.TotalPlayers = MapModData.VEM.TotalPlayers + 1
		end
	end
	--log:Info("OnTurnStart %10s %10.3f seconds", "Players", os.clock() - stepClockTime)
	MapModData.VEM.StartTurnTimes.Players = MapModData.VEM.StartTurnTimes.Players + (os.clock() - stepClockTime)
	stepClockTime = os.clock()
	for playerID, player in pairs(Players) do
		if player:IsAliveCiv() then
			for city in player:Cities() do
				if city then
					LuaEvents.ActivePlayerTurnStart_City(city, player)
					MapModData.VEM.TotalCities = MapModData.VEM.TotalCities + 1
				end
			end
		end
	end
	--log:Info("OnTurnStart %10s %10.3f seconds", "Cities", os.clock() - stepClockTime)
	MapModData.VEM.StartTurnTimes.Cities = MapModData.VEM.StartTurnTimes.Cities + (os.clock() - stepClockTime)
	stepClockTime = os.clock()
	for playerID, player in pairs(Players) do
		if player:IsAliveCiv() then
			for pUnit in player:Units() do
				if pUnit then
					LuaEvents.ActivePlayerTurnStart_Unit(pUnit)
					MapModData.VEM.TotalUnits = MapModData.VEM.TotalUnits + 1
				end
			end
		end
	end
	--log:Info("OnTurnStart %10s %10.3f seconds", "Units", os.clock() - stepClockTime)
	MapModData.VEM.StartTurnTimes.Units = MapModData.VEM.StartTurnTimes.Units + (os.clock() - stepClockTime)
	stepClockTime = os.clock()
	for playerID, player in pairs(Players) do
		if player:IsAliveCiv() then
			if not player:IsMinorCiv() then
				for policyInfo in GameInfo.Policies() do
					local policyID = policyInfo.ID
					if MapModData.VEM.HasPolicy[playerID][policyID] ~= player:HasPolicy(policyID) then
						MapModData.VEM.HasPolicy[playerID][policyID] = player:HasPolicy(policyID)
						LuaEvents.PolicyAdopted(player, policyID)
					end
				end
			end
		end
	end
	--log:Info("OnTurnStart %10s %10.3f seconds", "Policies", os.clock() - stepClockTime)
	MapModData.VEM.StartTurnTimes.Policies = MapModData.VEM.StartTurnTimes.Policies + (os.clock() - stepClockTime)
	stepClockTime = os.clock()
	for plotID = 0, Map.GetNumPlots() - 1, 1 do
		local plot = Map.GetPlotByIndex(plotID)
		LuaEvents.ActivePlayerTurnStart_Plot(plot)
	end
	--log:Info("OnTurnStart %10s %10.3f seconds", "Plots", os.clock() - stepClockTime)
	MapModData.VEM.StartTurnTimes.Plots = MapModData.VEM.StartTurnTimes.Plots + (os.clock() - stepClockTime)
	log:Info("OnTurnStart  %10s %10.3f seconds", "Total", os.clock() - startClockTime)
	MapModData.VEM.StartTurnTimes.Total = MapModData.VEM.StartTurnTimes.Total + (os.clock() - startClockTime)
end

----------------------------------------------------------------
--[[ Events.ActivePlayerTurnEnd usage example:

function CheckNewBuildingStats(city, player)
	-- does stuff for each city, once at the end of the turn
end
LuaEvents.ActivePlayerTurnEnd_City.Add(CheckNewBuildingStats)

-- also available:
-- LuaEvents.ActivePlayerTurnEnd_Turn	()
-- LuaEvents.ActivePlayerTurnEnd_Player	(player)
-- LuaEvents.ActivePlayerTurnEnd_Unit	(unit)
-- LuaEvents.ActivePlayerTurnEnd_City	(city, owner) 
-- LuaEvents.ActivePlayerTurnEnd_Plot	(plot)
]]

--
function OnTurnEnd()
	log:Info("OnTurnEnd")
	local startClockTime = os.clock()
	local stepClockTime = os.clock()
	LuaEvents.ActivePlayerTurnEnd_Turn()
	MapModData.VEM.EndTurnTimes.Turn = MapModData.VEM.EndTurnTimes.Turn + (os.clock() - stepClockTime)
	--log:Info("OnTurnEnd   %10s %10.3f seconds", "Turn", os.clock() - stepClockTime)
	stepClockTime = os.clock()
	for playerID, player in pairs(Players) do
		if player:IsAliveCiv() then
			LuaEvents.ActivePlayerTurnEnd_Player(player)
		end
	end
	--log:Info("OnTurnEnd   %10s %10.3f seconds", "Players", os.clock() - stepClockTime)
	MapModData.VEM.EndTurnTimes.Players = MapModData.VEM.EndTurnTimes.Players + (os.clock() - stepClockTime)
	stepClockTime = os.clock()
	for playerID, player in pairs(Players) do
		if player:IsAliveCiv() then
			for pUnit in player:Units() do
				if pUnit then
					LuaEvents.ActivePlayerTurnEnd_Unit(pUnit)
				end
			end
		end
	end
	--log:Info("OnTurnEnd   %10s %10.3f seconds", "Units", os.clock() - stepClockTime)
	MapModData.VEM.EndTurnTimes.Units = MapModData.VEM.EndTurnTimes.Units + (os.clock() - stepClockTime)
	stepClockTime = os.clock()
	for playerID, player in pairs(Players) do
		if player:IsAliveCiv() then
			for city in player:Cities() do
				if city then
					LuaEvents.ActivePlayerTurnEnd_City(city, player)
				end
			end
		end
	end
	--log:Info("OnTurnEnd   %10s %10.3f seconds", "Cities", os.clock() - stepClockTime)
	MapModData.VEM.EndTurnTimes.Cities = MapModData.VEM.EndTurnTimes.Cities + (os.clock() - stepClockTime)
	stepClockTime = os.clock()
	for playerID, player in pairs(Players) do
		if player:IsAliveCiv() then
			if not player:IsMinorCiv() then
				for policyInfo in GameInfo.Policies() do
					local policyID = policyInfo.ID
					if MapModData.VEM.HasPolicy[playerID][policyID] ~= player:HasPolicy(policyID) then
						MapModData.VEM.HasPolicy[playerID][policyID] = player:HasPolicy(policyID)
						LuaEvents.PolicyAdopted(player, policyID)
					end
				end
			end
		end
	end
	--log:Info("OnTurnEnd   %10s %10.3f seconds", "Policies", os.clock() - stepClockTime)
	MapModData.VEM.EndTurnTimes.Policies = MapModData.VEM.EndTurnTimes.Policies + (os.clock() - stepClockTime)
	stepClockTime = os.clock()
	for plotID = 0, Map.GetNumPlots() - 1, 1 do
		local plot = Map.GetPlotByIndex(plotID)
		LuaEvents.ActivePlayerTurnEnd_Plot(plot)
	end
	--log:Info("OnTurnEnd   %10s %10.3f seconds", "Plots", os.clock() - stepClockTime)
	MapModData.VEM.EndTurnTimes.Plots = MapModData.VEM.EndTurnTimes.Plots + (os.clock() - stepClockTime)
	log:Info("OnTurnEnd    %10s %10.3f seconds", "Total", os.clock() - startClockTime)
	MapModData.VEM.EndTurnTimes.Total = MapModData.VEM.EndTurnTimes.Total + (os.clock() - startClockTime)
	startAITurnTime = os.clock()
end
--]]

----------------------------------------------------------------
--[[ These run a single time when a city is founded

LuaEvents.NewCity.Add(CityCreatedChecks)
]]

function OnNewCity(hexPos, playerID, cityID, cultureType, eraType, continent, populationSize, size, fowState)
	if MapModData.VEM.Initialized or not UI.IsLoadedGame() then
		LuaEvents.NewCity(hexPos, playerID, cityID, cultureType, eraType, continent, populationSize, size, fowState)
	end
end

----------------------------------------------------------------
--[[ These run a single time when an improvement is built

LuaEvents.NewImprovement.Add(CheckPlotCultureYields)
]]

function OnNewImprovement(hexX, hexY, cultureArtID, continentArtID, playerID, engineImprovementTypeDoNotUse, improvementID, engineResourceTypeDoNotUse, resourceID, eraID, improvementState)
	if MapModData.VEM.Initialized or not UI.IsLoadedGame() then
		LuaEvents.NewImprovement(hexX, hexY, cultureArtID, continentArtID, playerID, engineImprovementTypeDoNotUse, improvementID, engineResourceTypeDoNotUse, resourceID, eraID, improvementState)
	end
end

----------------------------------------------------------------
--[[ LuaEvents.NewUnit runs a single time when the unit is created

function UnitCreatedChecks( playerID, unitID, hexVec, unitType, cultureType, civID, primaryColor, secondaryColor, unitFlagIndex, fogState, selected, military, notInvisible )
	-- do stuff
end

LuaEvents.NewUnit.Add(UnitCreatedChecks)
]]


function OnNewUnit(playerID, unitID, hexVec, unitType, cultureType, civID, primaryColor, secondaryColor, unitFlagIndex, fogState, selected, military, notInvisible)
	local unit = Players[playerID]:GetUnitByID(unitID)
	if ( unit == nil
		or unit:IsDead()
		or unit:IsHasPromotion(GameInfo.UnitPromotions.PROMOTION_NEW_UNIT.ID)
		or unit:GetGameTurnCreated() < Game.GetGameTurn() ) then
        return
    end

	unit:SetHasPromotion(GameInfo.UnitPromotions.PROMOTION_NEW_UNIT.ID, true)
	if not MapModData.VEM.ReplacingUnit then
		--log:Warn("New %s %s", unit:GetName(), Players[playerID]:GetName())
		LuaEvents.NewUnit(playerID, unitID, hexVec, unitType, cultureType, civID, primaryColor, secondaryColor, unitFlagIndex, fogState, selected, military, notInvisible)
	end
end

function RemoveNewUnitFlag(unit)
	unit:SetHasPromotion(GameInfo.UnitPromotions.PROMOTION_NEW_UNIT.ID, false)
end

--[[
if not MapModData.VEM.UnitCreated then
	MapModData.VEM.UnitCreated = {}
	for playerID, player in pairs(Players) do
		MapModData.VEM.UnitCreated[playerID] = {}
		for unit in player:Units() do
			MapModData.VEM.UnitCreated[playerID][unit:GetID()] = true
		end
	end
end

function OnNewUnit(playerID, unitID, hexVec, unitType, cultureType, civID, primaryColor, secondaryColor, unitFlagIndex, fogState, selected, military, notInvisible)
	if MapModData.VEM.Initialized or not UI.IsLoadedGame() then
		local unit = Players[playerID]:GetUnitByID(unitID)

		if not MapModData.VEM.UnitCreated[playerID][unitID] then
			MapModData.VEM.UnitCreated[playerID][unitID] = true
			LuaEvents.NewUnit(playerID, unitID, hexVec, unitType, cultureType, civID, primaryColor, secondaryColor, unitFlagIndex, fogState, selected, military, notInvisible)
		end
	end
end
--]]

---------------------------------------------------------------------
-- OnNewTech(teamID, techID, changeID)
--
function OnNewTech(teamID, techID, changeID)
	for playerID, player in pairs(Players) do
		if player and player:IsAlive() and player:GetTeam() == teamID then
			LuaEvents.NewTech(player, techID, changeID)
		end
	end	
end


---------------------------------------------------------------------
--[[ LuaEvents.PlotAcquired(plot, newOwnerID) usage example:

]]

if not MapModData.VEM.PlotOwner then
	MapModData.VEM.PlotOwner = {}
	for plotID = 0, Map.GetNumPlots() - 1, 1 do
		local plot = Map.GetPlotByIndex(plotID)
		--if plot:GetOwner() ~= -1 then
			--log:Warn("Loading PlotOwner %s", plotID)
			MapModData.VEM.PlotOwner[plotID] = plot:GetOwner() --LoadPlot(plot, "PlotOwner")
		--end
	end
end

function OnHexCultureChanged(hexX, hexY, newOwnerID, unknown)
	local plot = Map.GetPlot(ToGridFromHex(hexX, hexY))
	local plotID = Plot_GetID(plot)
	--log:Warn("OnHexCultureChanged old=%s new=%s", MapModData.VEM.PlotOwner[plotID], newOwnerID)
	if newOwnerID ~= MapModData.VEM.PlotOwner[plotID] then
		MapModData.VEM.PlotOwner[plotID] = newOwnerID
		--SavePlot(plot, "PlotOwner", newOwnerID)
		--log:Warn("PlotAcquired")
		LuaEvents.PlotAcquired(plot, newOwnerID)
	end
end

---------------------------------------------------------------------
--[[ LuaEvents.PolicyAdopted(player, policyID) usage example:

function CheckFreeBuildings(player, policyID)
	-- check for buildings affected by the new policy
end

LuaEvents.ActivePlayerTurnEnd_Player.Add( CheckFreeBuildings )
LuaEvents.PolicyAdopted.Add( CheckFreeBuildings )	
]]

Events.PolicyAdopted = Events.PolicyAdopted or function(policyID, isPolicy)
	log:Info("TriggerPolicyAdopted %s %s", policyID, isPolicy)
	if not isPolicy then
		policyID = GameInfo.Policies[GameInfo.PolicyBranchTypes[policyID].FreePolicy].ID
	end
	local playerID = Game.GetActivePlayer()
	MapModData.VEM.HasPolicy[playerID][policyID] = true
	LuaEvents.PolicyAdopted(Players[playerID], policyID)
end

if not MapModData.VEM.HasPolicy then
	MapModData.VEM.HasPolicy = {}
	startClockTime = os.clock()
	for playerID, player in pairs(Players) do
		MapModData.VEM.HasPolicy[playerID] = {}
		if not player:IsMinorCiv() then
			for policyInfo in GameInfo.Policies() do
				MapModData.VEM.HasPolicy[playerID][policyInfo.ID] = player:HasPolicy(policyInfo.ID)
			end
		end
	end
	if UI:IsLoadedGame() then
		log:Warn("%10.3f seconds loading HasPolicy", os.clock() - startClockTime)
	end
end


---------------------------------------------------------------------
--[[ LuaEvents.UnitExperienceChange(unit, experience) usage example:

]]
--LuaEvents.UnitExperienceChange = LuaEvents.UnitExperienceChange or function(unit, oldXP, newXP) end

if not MapModData.VEM.UnitXP then
	MapModData.VEM.UnitXP = {}
	startClockTime = os.clock()
	for playerID,player in pairs(Players) do
		if player:IsAliveCiv() and not player:IsMinorCiv() then
			MapModData.VEM.UnitXP[playerID] = {}
			if UI.IsLoadedGame() then
				for policyInfo in GameInfo.Policies("GarrisonedExperience <> 0") do
					if player:HasPolicy(policyInfo.ID) then
						for unit in player:Units() do
							----log:Debug("Loading UnitXP %s", unit:GetName())
							MapModData.VEM.UnitXP[playerID][unit:GetID()] = LoadValue("MapModData.VEM.UnitXP[%s][%s]", playerID, unit:GetID())
						end
					end
				end
			end		
		end
	end
	if UI:IsLoadedGame() then
		log:Warn("%10.3f seconds loading UnitXP", os.clock() - startClockTime)
	end
end

---------------------------------------------------------------------
--[[ GetBranchFinisherID(policyBranchType) usage example:

]]
function GetBranchFinisherID(policyBranchType)
	return GameInfo.Policies[GameInfo.PolicyBranchTypes[policyBranchType].FreeFinishingPolicy].ID
end

---------------------------------------------------------------------
--[[ GetItemName(itemTable, itemTypeOrID) usage example:

]]
function GetName(itemInfo, itemTable)
	if itemTable then
		itemInfo = itemTable[itemInfo]
	end
	return Locale.ConvertTextKey(itemInfo.Description)
end

---------------------------------------------------------------------
--[[ HasFinishedBranch(player, policyBranchType, newPolicyID) usage example:

]]
function HasFinishedBranch(player, policyBranchType, newPolicyID)
	local branchFinisherID = GetBranchFinisherID(policyBranchType)
	if player:HasPolicy(branchFinisherID) then
		return true
	end

	for policyInfo in GameInfo.Policies(string.format("PolicyBranchType = '%s' AND ID != '%s'", policyBranchType, branchFinisherID)) do
		if (newPolicyID ~= policyInfo.ID) and not player:HasPolicy(policyInfo.ID) then
			return false
		end
	end
	--log:Debug("%s finished %s", player:GetName(), policyBranchType)
	return true
end

---------------------------------------------------------------------
--[[ LuaEvents.CityOccupied(city, player) usage example:

]]
Events.CityOccupied = Events.CityOccupied or function(city, player, isForced)
	LuaEvents.CityOccupied(city, player, isForced)
end

Events.CityPuppeted = Events.CityPuppeted or function(city, player, isForced)
	LuaEvents.CityPuppeted(city, player, isForced)
end

Events.CityLiberated = Events.CityLiberated or function(city, player, isForced)
	LuaEvents.CityLiberated(city, player, isForced)
end

---------------------------------------------------------------------
--[[ LuaEvents.PromotionEarned(city, player) usage example:

]]
Events.PromotionEarned = Events.PromotionEarned or function(unit, promotionType)
	--log:Warn("PromotionEarned")
	LuaEvents.PromotionEarned(unit, promotionType)
end

Events.UnitUpgraded = Events.UnitUpgraded or function(unit)
	LuaEvents.UnitUpgraded(unit)
end

----------------------------------------------------------------
--[[ CheckPlotBuildingsStatus(plot) usage example:

]]


if not MapModData.buildingsAlive then
	MapModData.buildingsAlive = {}
	for plotID = 0, Map.GetNumPlots() - 1, 1 do
		MapModData.buildingsAlive[plotID] = {}
	end
	for playerID,player in pairs(Players) do
		for city in player:Cities() do
			for buildingInfo in GameInfo.Buildings() do
				--log:Info("Loading buildingsAlive %15s %20s = %s", city:GetName(), GetName(buildingInfo), city:IsHasBuilding(buildingInfo.ID))
				MapModData.buildingsAlive[City_GetID(city)][buildingInfo.ID] = city:IsHasBuilding(buildingInfo.ID)
			end
		end
	end
end

function OnBuildingConstructed(player, city, buildingID)
	--log:Info("%-25s %15s %15s %30s %s", "BuildingConstructed", player:GetName(), city:GetName(), GameInfo.Buildings[buildingID].Type, MapModData.buildingsAlive[City_GetID(city)])
	local cityID = City_GetID(city)
	MapModData.buildingsAlive[cityID] = MapModData.buildingsAlive[cityID] or {}
	MapModData.buildingsAlive[cityID][buildingID] = true
end

function OnBuildingDestroyed(player, city, buildingID)
	local buildingInfo = GameInfo.Buildings[buildingID]
	if buildingInfo.OneShot then
		return
	end
	--log:Info("%-25s %15s %15s %30s %s", "BuildingDestroyed", player:GetName(), city:GetName(), buildingInfo.Type, MapModData.buildingsAlive[City_GetID(city)])
	local cityID = City_GetID(city)
	MapModData.buildingsAlive[cityID] = MapModData.buildingsAlive[cityID] or {}
	MapModData.buildingsAlive[cityID][buildingID] = false
	if MapModData.VEM.FreeFlavorBuilding then
		for flavorInfo in GameInfo.Flavors() do
			if buildingID == MapModData.VEM.FreeFlavorBuilding[flavorInfo.Type][cityID] then
				MapModData.VEM.FreeFlavorBuilding[flavorInfo.Type][cityID] = false
				SaveValue(false, "MapModData.VEM.FreeFlavorBuilding[%s][%s]", flavorInfo.Type, cityID)
			end
		end
	end
end


LuaEvents.CheckPlotBuildingsStatus = function(plot)
	if plot == nil then
		log:Fatal("CheckPlotBuildingsStatus plot=nil")
		return
	end
	local plotID = Plot_GetID(plot)
	local city = plot:GetPlotCity()
	if city then
		local player = Players[city:GetOwner()]
		if MapModData.buildingsAlive[plotID] == nil then
			MapModData.buildingsAlive[plotID] = {}
		end
		for buildingInfo in GameInfo.Buildings() do
			local buildingID = buildingInfo.ID
			if city:IsHasBuilding(buildingID) and not MapModData.buildingsAlive[plotID][buildingID] then
				LuaEvents.BuildingConstructed(player, city, buildingID)
			elseif not city:IsHasBuilding(buildingID) and MapModData.buildingsAlive[plotID][buildingID] then
				LuaEvents.BuildingDestroyed(player, city, buildingID)
			end
		end
	end
end

function LuaEvents.CheckActiveBuildingStatus()
	for plotID, data in pairs(MapModData.buildingsAlive) do
		if not Map_GetCity(plotID) then
			MapModData.buildingsAlive[plotID] = nil
		end
	end
	if not MapModData.VEM.FreeFlavorBuilding then
		return
	end
	for flavorInfo in GameInfo.Flavors() do
		for plotID, data in pairs(MapModData.VEM.FreeFlavorBuilding[flavorInfo.Type]) do
			if not Map_GetCity(plotID) then
				MapModData.VEM.FreeFlavorBuilding[flavorInfo.Type][plotID] = false
				SaveValue(false, "MapModData.VEM.FreeFlavorBuilding[%s][%s]", flavorInfo.Type, plotID)
			end			
		end
	end
end

function OnCityDestroyed(hexPos, playerID, cityID, newPlayerID)
	LuaEvents.CheckPlotBuildingsStatus(Map.GetPlot(ToGridFromHex(hexPos.x, hexPos.y)))
end