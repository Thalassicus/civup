-- Lua Script1
-- Author: Sneaks/alpaca
-- DateCreated: 1/31/2011 12:07:40 PM
--------------------------------------------------------------

------------------------------------------------------------------
--Debugging Print Namespace Addin
------------------------------------------------------------------
include("AlpacaUtils.lua")
VERBOSITY = 0
include("ModTools.lua")
local log = Events.LuaLogger:New()
log:SetLevel("WARN")

------------------------------------------------------------------
--Notification Addins
------------------------------------------------------------------
include("CustomNotification.lua");

LuaEvents.NotificationAddin({ name = "CityGrowth", type = "CNOTIFICATION_CITY_GROWTH"})
LuaEvents.NotificationAddin({ name = "CityTile", type = "CNOTIFICATION_CULTURE_GROWTH"})
LuaEvents.NotificationOverrideAddin({
	type = "NOTIFICATION_CITY_GROWTH",
	override = 
	function(toolTip,summary,value1,value2) 
		--print("Overriding",toolTip,summary,value1,value2); 
		return; 
	end})
------------------------------------------------------------------

------------------------------------------------------------------
--	City Growth notification (also above pop 5)
------------------------------------------------------------------

-- initialise city sizes
citySizes = {}

--aprint("Initializing City Sizes")
for pCity in Players[Game.GetActivePlayer()]:Cities() do
	citySizes[pCity:GetID()] = pCity:GetPopulation()
end


--[[
	Detects city growth and fires a notification
]]--
function CityGrowthNotificationOnSerialEventCityPopulationChanged(iHexX, iHexY, iNewPop, iUnknown)
	--aprint("Received a growth event at coordinates ", iHexX, iHexY)
	local pPlot = Map.GetPlot(ToGridFromHex(iHexX, iHexY))
	local pCity = pPlot:GetPlotCity()

	if not pCity then
		log:Fatal("CityGrowthNotification pCity=nil %s %s", iHexX, iHexY)
		return
	end
	
	--aprint("plot and city ", pPlot,pCity)
	if pCity:GetOwner() == Game.GetActivePlayer() and iNewPop > 1 then
		--aprint("Firing growth notification")
		CustomNotification("CityGrowth", Locale.ConvertTextKey("TXT_KEY_NOTIFICATION_SUMMARY_CITY_GROWTH_2", pCity:GetName()), Locale.ConvertTextKey("TXT_KEY_NOTIFICATION_CITY_GROWTH_2", pCity:GetName(), iNewPop), pPlot, pCity, "Green", 0)
	end
end
Events.SerialEventCityPopulationChanged.Add(CityGrowthNotificationOnSerialEventCityPopulationChanged)


------------------------------------------------------------------
--	Border Growth notification
------------------------------------------------------------------
-- initialise culture levels
cityCultureLevels = cityCultureLevels or {}

-- initialise culture levels for player cities
--aprint("Initializing Culture Levels")
for pCity in Players[Game.GetActivePlayer()]:Cities() do
	cityCultureLevels[pCity:GetID()] = pCity:GetJONSCultureLevel()
end

--[[
	Detects border growth and fires a notification
]]--
function CLNOnPlotAcquired(pPlot, iPlayerID)
	local pCity = pPlot:GetWorkingCity()
	if iPlayerID == 0 then
		if pCity then
			-- detect a culture level change
			local newLevel = pCity:GetJONSCultureLevel()
			if cityCultureLevels[pCity:GetID()] ~= newLevel then
				--aprint("Hex culture level. Owner is: ", pPlot:GetOwner())
				cityCultureLevels[pCity:GetID()] = newLevel
				if newLevel == 0 then
					return
				end
				--aprint("Firing Culture Change City")
				CustomNotification("CityTile", Locale.ConvertTextKey("TXT_KEY_NOTIFICATION_SUMMARY_CITY_TILE", pCity:GetName()), Locale.ConvertTextKey("TXT_KEY_NOTIFICATION_CITY_TILE", pCity:GetName()), pPlot, pCity, "Magenta", 0)
			end
		else
			-- this means a tile was grabbed outside the territory; I'm not checking for culture bomb yet so it triggers.
			--aprint("Firing Culture Change Empire")
			CustomNotification("CityTile", Locale.ConvertTextKey("TXT_KEY_NOTIFICATION_SUMMARY_EMPIRE_TILE"), Locale.ConvertTextKey("TXT_KEY_NOTIFICATION_EMPIRE_TILE"), pPlot, 0, "Magenta", 0)
		end
	end
end


LuaEvents.PlotAcquired.Add(CLNOnPlotAcquired)

--Alternate Override Method. Unused for Now
--[[
function VanillaCityGrowthOverride()
	return
end
LuaEvents.ImprovedEventsCityGrowth.Add(VanillaCityGrowthOverride)
]]--