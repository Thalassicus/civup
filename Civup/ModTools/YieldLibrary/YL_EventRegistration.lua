-- Civup - Event Registration
-- Author: Thalassicus
-- DateCreated: 2/12/2011 9:42:55 AM
--------------------------------------------------------------

include("CustomNotification.lua")
include("CiVUP_Core.lua")

local log = Events.LuaLogger:New()
log:SetLevel("INFO")

PlayerClass = getmetatable(Players[0]).__index

LuaEvents.ActivePlayerTurnEnd_Player	.Add(PlayerClass.CleanCityYieldRates)
LuaEvents.ActivePlayerTurnEnd_City		.Add(City_UpdateModdedYields)
LuaEvents.ActivePlayerTurnStart_Player	.Add(PlayerClass.UpdateModdedHappiness)
LuaEvents.ActivePlayerTurnEnd_Player	.Add(PlayerClass.UpdateModdedYieldsEnd)
LuaEvents.ActivePlayerTurnStart_Player	.Add(PlayerClass.UpdateModdedYieldsStart)
--LuaEvents.ActivePlayerTurnStart_Player.Add(UpdatePlayerRewardsFromMinorCivs)
LuaEvents.CityYieldRatesDirty			.Add(OnCityYieldRatesDirty)
LuaEvents.NewImprovement				.Add(function() Players[Game.GetActivePlayer()]:CleanCityYieldRates() end)
LuaEvents.NewImprovement				.Add(CheckPlotCultureYields)

LuaEvents.NotificationOverrideAddin({
	type="NOTIFICATION_STARVING",
	override=function(tooltip,summary,value1,value2)
		--LuaEvents.CustomStarving();
	end
})

function FinishAgriculture()
	for playerID, player in pairs(Players) do
		if player:IsAliveCiv() then
			local techID = GameInfo.Technologies.TECH_AGRICULTURE.ID
			player:SetYieldStored(YieldTypes.YIELD_SCIENCE, 1, techID)
			--log:Warn("%s agriculture science = %s/%s", player:GetName(), player:GetYieldStored(YieldTypes.YIELD_SCIENCE, techID), player:GetYieldNeeded(YieldTypes.YIELD_SCIENCE, techID))
			--player:CleanCityYieldRates()
		end
	end
end
Events.SequenceGameInitComplete.Add(FinishAgriculture)