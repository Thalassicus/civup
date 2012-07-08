-- MT_Initialize
-- Author: Thalassicus
-- DateCreated: 3/17/2012 1:19:27 PM
--------------------------------------------------------------

include("ModTools.lua")

--if not MapModData.VEM.MT_Initialized then
	MapModData.VEM.MT_Initialized = true
	--print("MapModData.VEM.MT_Initialized")

	LuaEvents.MT_Initialize()
	
	Events.ActivePlayerTurnStart		.Add(OnTurnStart)
	Events.ActivePlayerTurnEnd			.Add(OnTurnEnd)
	--Events.SerialEventImprovementCreated.Add(OnNewImprovement)
	Events.SerialEventUnitCreated		.Add(OnNewUnit)
	Events.SerialEventCityCreated		.Add(OnNewCity)
	GameEvents.TeamTechResearched		.Add(OnNewTech)
	Events.SerialEventCityCaptured		.Add(UpdateTurnAcquiredCapture)
	Events.SerialEventCityCaptured		.Add(OnCityDestroyed)
	Events.SerialEventCityDestroyed		.Add(OnCityDestroyed)
	Events.SerialEventHexCultureChanged	.Add(OnHexCultureChanged)
	LuaEvents.NewCity					.Add(UpdateTurnAcquiredFounding)
	LuaEvents.BuildingConstructed		.Add(OnBuildingConstructed)
	LuaEvents.BuildingDestroyed			.Add(OnBuildingDestroyed)
	LuaEvents.ActivePlayerTurnStart_Plot.Add(LuaEvents.CheckPlotBuildingsStatus)
	LuaEvents.ActivePlayerTurnEnd_Plot	.Add(LuaEvents.CheckPlotBuildingsStatus)
	LuaEvents.ActivePlayerTurnStart_Turn.Add(LuaEvents.CheckActiveBuildingStatus)
	LuaEvents.ActivePlayerTurnEnd_Turn	.Add(LuaEvents.CheckActiveBuildingStatus)
	LuaEvents.ActivePlayerTurnEnd_Unit	.Add(RemoveNewUnitFlag)
	Events.EndCombatSim					.Add(CheckCombatLevelup)
	Events.LoadScreenClose				.Add(function() MapModData.VEM.Initialized = true end)
--end