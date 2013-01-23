-- TU-Plot
-- Author: Thalassicus
-- DateCreated: 2/29/2012 8:19:45 AM
--------------------------------------------------------------

include("MT_LuaLogger.lua")
local log = Events.LuaLogger:New()
log:SetLevel("WARN")

--print(string.format("Map.GetPlotByIndex(1) = %s", Map.GetPlotByIndex(1)))

--PlotClass	= getmetatable(Map.GetPlotByIndex(0)).__index

---------------------------------------------------------------------
-- Plot_BuildImprovement(plot)
--
function Plot_BuildImprovement(plot, improveID)
    plot:SetImprovementType(improveID)
	local featureID = plot:GetFeatureType()
	if featureID == -1 then
		return
	end

	local improveType = GameInfo.Improvements[improveID].Type
	local featureType = GameInfo.Features[featureID].Type
	local buildType = Game.GetValue("Type", {ImprovementType=improveType}, GameInfo.Builds)
	if Game.GetValue("Remove", {BuildType=buildType, FeatureType=featureType}, GameInfo.BuildFeatures) then
		plot:SetFeatureType(FeatureTypes.NO_FEATURE, -1)
	end
end

---------------------------------------------------------------------
-- Plot_Buy(player, plot, city, cost) purchases plot for player.
-- This avoids a vanilla bug: the same tile can have different costs when viewed from different cities.
--

function Plot_Buy(plot, player, city, cost)
	local playerID = player:GetID()
	player:ChangeYieldStored(YieldTypes.YIELD_GOLD, -cost)
	plot:SetOwner(playerID, city:GetID())
	MapModData.Civup.PlotCostExtra[playerID] = MapModData.Civup.PlotCostExtra[playerID] + GameDefines.PLOT_ADDITIONAL_COST_PER_PLOT
	SaveValue(MapModData.Civup.PlotCostExtra[playerID], "MapModData.Civup.PlotCostExtra[%s]", playerID)
end

function Plot_CanBuy(city, plot, notCheckGold)
	--local hex = ToHexFromGrid(Vector2(plot:GetX(), plot:GetY()))
	return city:CanBuyPlotAt(plot:GetX(), plot:GetY(), notCheckGold)
end

function Plot_GetCost(city, plot)
	if Plot_CanBuy(city, plot, true) then
		return city:GetBuyPlotCost(plot:GetX(), plot:GetY()) + MapModData.Civup.PlotCostExtra[city:GetOwner()]
	end
	return math.huge
end

if not MapModData.Civup.PlotCostExtra then
	MapModData.Civup.PlotCostExtra = {}
	startClockTime = os.clock()
	for playerID, player in pairs(Players) do
		if UI.IsLoadedGame() then
			MapModData.Civup.PlotCostExtra[playerID] = LoadValue("MapModData.Civup.PlotCostExtra[%s]", playerID) or 0
		else
			MapModData.Civup.PlotCostExtra[playerID] = 0
		end
	end
	if UI:IsLoadedGame() then
		log:Info("%3s ms loading PlotCostExtra", Game.Round((os.clock() - startClockTime)*1000))
	end
end
	
---------------------------------------------------------------------
--
--
function Plot_FindPlotType(startPlot, plotType)
	local hex = ToHexFromGrid( Vector2(startPlot:GetX(), startPlot:GetY()) )
	
	local directions = {
		Vector2(  0,  1),
		Vector2( -1,  0),
		Vector2(  1, -1),
		Vector2(  0, -1),
		Vector2(  1,  0),
		Vector2( -1,  1)
	}

	for _, vecJ in ipairs(directions) do
		local hexJ = VecAdd(hex, vecJ)		
		for _, vecK in ipairs(directions) do
			local hexK = VecAdd(hexJ, vecK)
			local targetPlot = Map.GetPlot(ToGridFromHex(hexK.x, hexK.y))
			
			if targetPlot and targetPlot:GetPlotType() == PlotTypes[plotType] then
				return targetPlot
			end
		end
	end
	return startPlot
end

---------------------------------------------------------------------
--[[ Plot_GetCombatUnit(plot) usage example:
local capturingUnit = Plot_GetCombatUnit(plot)
]]

function Plot_GetCombatUnit(plot)
    local lostCityPlot = Map.GetPlot( ToGridFromHex( plot.x, plot.y ) )
	local count = lostCityPlot:GetNumUnits()
	for i = 0, count - 1 do
		local pUnit = lostCityPlot:GetUnit( i )
		if Unit_IsCombatDomain(pUnit, "DOMAIN_LAND") then
			return pUnit
		end
	end
	return nil
end

---------------------------------------------------------------------
--[[ Plot_GetAreaWeights(centerPlot, minRadius, maxRadius) usage example:

areaWeights = Plot_GetAreaWeights(plot, 2, 2)
if (areaWeights.PLOT_LAND + areaWeights.PLOT_HILLS) <= 0.25 then
	return
end
]]

local plotTypeName		= {}-- -1="NO_PLOT"}
local terrainTypeName	= {}-- -1="NO_TERRAIN"}
local featureTypeName	= {}-- -1="NO_FEATURE"}

--function InitAreaWeightValues()
	for k, v in pairs(PlotTypes) do
		plotTypeName[v] = k
	end
	for itemInfo in GameInfo.Terrains() do
		terrainTypeName[itemInfo.ID] = itemInfo.Type
	end
	for itemInfo in GameInfo.Features() do
		featureTypeName[itemInfo.ID] = itemInfo.Type
	end
--end

--[[
if not MapModData.Civup.InitAreaWeightValues then
	MapModData.Civup.InitAreaWeightValues = true
	LuaEvents.MT_Initialize.Add(InitAreaWeightValues)
end
--]]

function Plot_GetAreaWeights(plot, minR, maxR)
	local weights = {TOTAL=0, SEA=0, NO_PLOT=0, NO_TERRAIN=0, NO_FEATURE=0}
	
	for k, v in pairs(PlotTypes) do
		weights[k] = 0
	end
	for itemInfo in GameInfo.Terrains() do
		weights[itemInfo.Type] = 0
	end
	for itemInfo in GameInfo.Features() do
		weights[itemInfo.Type] = 0
	end
	
	for _, adjPlot in pairs(Plot_GetPlotsInCircle(plot, minR, maxR)) do
		local distance		 = Map.PlotDistance(adjPlot:GetX(), adjPlot:GetY(), plot:GetX(), plot:GetY())
		local adjWeight		 = (distance == 0) and 6 or (1/distance)
		local plotType		 = plotTypeName[adjPlot:GetPlotType()]
		local terrainType	 = terrainTypeName[adjPlot:GetTerrainType()]
		local featureType	 = featureTypeName[adjPlot:GetFeatureType()] or "NO_FEATURE"
		
		weights.TOTAL		 = weights.TOTAL		+ adjWeight 
		weights[plotType]	 = weights[plotType]	+ adjWeight
		weights[terrainType] = weights[terrainType]	+ adjWeight
		weights[featureType] = weights[featureType]	+ adjWeight
				
		if plotType == "PLOT_OCEAN" then
			if not adjPlot:IsLake() and featureType ~= "FEATURE_ICE" then
				weights.SEA = weights.SEA + adjWeight
			end
		end
	end
	
	if weights.TOTAL == 0 then
		log:Fatal("plot:GetAreaWeights Total=0! x=%s y=%s", x, y)
	end
	for k, v in pairs(weights) do
		if k ~= "TOTAL" then
			weights[k] = weights[k] / weights.TOTAL
		end
	end
	
	return weights
end


---------------------------------------------------------------------
--[[ Plot_GetID(plot) usage example:
MapModData.buildingsAlive[Plot_GetID(city:Plot())][buildingID] = true
]]
function Plot_GetID(plot)
	if not plot then
		log:Fatal("plot:GetID plot=nil")
		return nil
	end
	local iW, iH = Map.GetGridSize()
	return plot:GetY() * iW + plot:GetX()
end

---------------------------------------------------------------------
--[[ Plot_GetNearestOceanPlot(centerPlot, radius, minArea) usage example:

]]
function Plot_GetNearestOceanPlot(centerPlot, maxRadius, minArea)
	for radius=1, (maxRadius or 15) do
		local nearPlots = Game.Shuffle(Plot_GetPlotsInCircle(centerPlot, radius))
		for index,nearPlot in pairs(nearPlots) do

			if nearPlot:GetTerrainType() == TerrainTypes.TERRAIN_COAST then
				if (minArea == nil) or (nearPlot:Area():GetNumTiles() >= minArea) then
					return nearPlot
				end
			end
		end
	end
	return false
end

---------------------------------------------------------------------
--[[ Plot_GetPlotsInCircle(plot, minR, [maxR]) usage example:
for _, plot in pairs(Plot_GetPlotsInCircle(plot, 1, 4)) do
	--process plot
end
]]

function Plot_GetPlotsInCircle(plot, minR, maxR)
	if not plot then
		log:Fatal("plot:GetPlotsInCircle plot=nil")
		return
	end
	maxR = maxR or minR
	local plotList	= {}
	local iW, iH	= Map.GetGridSize()
	local isWrapX	= Map:IsWrapX()
	local isWrapY	= Map:IsWrapY()
	local centerX	= plot:GetX()
	local centerY	= plot:GetY()

	x1 = isWrapX and ((centerX-maxR) % iW) or Game.Constrain(0, centerX-maxR, iW-1)
	x2 = isWrapX and ((centerX+maxR) % iW) or Game.Constrain(0, centerX+maxR, iW-1)
	y1 = isHrapY and ((centerY-maxR) % iH) or Game.Constrain(0, centerY-maxR, iH-1)
	y2 = isHrapY and ((centerY+maxR) % iH) or Game.Constrain(0, centerY+maxR, iH-1)

	local x		= x1
	local y		= y1
	local xStep	= 0
	local yStep	= 0
	local rectW	= x2-x1 
	local rectH	= y2-y1
	
	if rectW < 0 then
		rectW = rectW + iW
	end
	
	if rectH < 0 then
		rectH = rectH + iH
	end
	
	local adjPlot = Map.GetPlot(x, y)

	while (yStep < 1 + rectH) and adjPlot ~= nil do
		while (xStep < 1 + rectW) and adjPlot ~= nil do
			if Game.IsBetween(minR, Map.PlotDistance(x, y, centerX, centerY), maxR) then
				table.insert(plotList, adjPlot)
			end
			
			x		= x + 1
			x		= isWrapX and (x % iW) or x
			xStep	= xStep + 1
			adjPlot	= Map.GetPlot(x, y)
		end
		x		= x1
		y		= y + 1
		y		= isWrapY and (y % iH) or y
		xStep	= 0
		yStep	= yStep + 1
		adjPlot	= Map.GetPlot(x, y)
	end
	
	return plotList
end

---------------------------------------------------------------------
--[[ Plot_IsFlatDesert(plot) usage example:

]]
function Plot_IsFlatDesert(plot)
	return (plot:GetPlotType() == PlotTypes.PLOT_LAND and plot:GetTerrainType() == TerrainTypes.TERRAIN_DESERT and plot:GetFeatureType() == -1)
end