--[[
	DiscoverMission.lua
	
	Creator: alpaca
	Last Change: 10.12.2010
	
	Description: Defines the mission handler for the replacement GS discover tech function.
]]--

--[[
	Set up SaveUtils
]]--
--include("SaveUtils")
--MY_MOD_NAME = "PlayWithMe_v4"

--[[
	Load library
]]--
include("AlpacaUtils")
VERBOSITY = 1


--[[
	Calculates the tech points to grant the player depending on the number of techs he has researched
	Arguments: 
		iUnitType: num. The unit type to get the values for tech points from.
	Returns:
		num. Tech points to assign
]]--
function CalcTechPointsToAssign(iUnitType)
	local pActivePlayer = Players[Game.GetActivePlayer()]
	local teamTechs = Teams[pActivePlayer:GetTeam()]:GetTeamTechs()
	local numTechs = teamTechs:GetNumTechsKnown()
	local freeBeakers = GameInfo.Units[iUnitType].FreeBeakersBase
	if freeBeakers == -1 then
		freeBeakers = 1000000
	else
		freeBeakers = freeBeakers + (GameInfo.Units[iUnitType].FreeBeakersCoefficient*(numTechs - 1))^GameInfo.Units[iUnitType].FreeBeakersExponent
	
		for iModKey,iMod in ipairs(modifiers) do
			freeBeakers = freeBeakers*iMod/100
		end
	
		freeBeakers = freeBeakers - math.fmod(freeBeakers, GameInfo.Units[iUnitType].FreeBeakersVisibleDivisor)
	end
	--aprint("Calculating tech points to assign:",freeBeakers)
	return freeBeakers
end

--[[
	This is the function that determines whether the DiscoverMission is available for a unit. Right now it's "hardcoded" to the Great Scientist but it can be hooked to an XML value
	Arguments:
		bTestDisabled: boolean. If true, this will return true if the ability is disabled but legal for the current unit
	Returns:
		true if enabled, false otherwise
]]--
function CanHandle(bTestDisabled)
	local pActivePlayer = Players[Game.GetActivePlayer()]
	if GameInfo.Units[UI.GetHeadSelectedUnit():GetUnitType()].FreeBeakersBase ~= 0 then
		local cooldownTurnsLeft = load(pActivePlayer, "CooldownTurnsLeftForDiscoverMission") or 0
		return bTestDisabled and true or cooldownTurnsLeft <= 0
	end
	return false
end

--[[
	This function generates a tooltip action help for the DiscoverMission.
	Returns:
		string. The tooltip
]]--
function GetToolTip()
	--aprint("Getting discover mission tooltip, string: ","[NEWLINE]"..Locale.ConvertTextKey( "TXT_KEY_MISSION_DISCOVER_ME_HELP", CalcTechPointsToAssign(UI.GetHeadSelectedUnit():GetUnitType())))
	return "[NEWLINE]"..Locale.ConvertTextKey( "TXT_KEY_MISSION_DISCOVER_ME_HELP", CalcTechPointsToAssign(UI.GetHeadSelectedUnit():GetUnitType()))
end

--[[
	This function generates a tooltip disabled help for the DiscoverMission.
	Returns:
		string. The tooltip
]]--
function GetDisabledToolTip()
	local pActivePlayer = Players[Game.GetActivePlayer()]
	local cooldownTurnsLeft = load(pActivePlayer, "CooldownTurnsLeftForDiscoverMission") or 0
	--aprint("Getting discover mission disabled tooltip, string: ","[NEWLINE]"..Locale.ConvertTextKey( "TXT_KEY_MISSION_DISCOVER_ME_DISABLED_HELP",cooldownTurnsLeft))
	return "[NEWLINE]"..Locale.ConvertTextKey( "TXT_KEY_MISSION_DISCOVER_ME_DISABLED_HELP", cooldownTurnsLeft)
end

--[[
	What happens when the player clicks the DiscoverMission button
]]--
function OnClick()
	--aprint("Discover Mission clicked")
	local unitType = UI.GetHeadSelectedUnit():GetUnitType()
	UI.GetHeadSelectedUnit():Kill() -- consumes the scientist
	local techPointsToAssign = CalcTechPointsToAssign(unitType)
	local cooldownTurnsLeft = GameInfo.Units[unitType].FreeBeakersCooldownTurns
	local pActivePlayer = Players[Game.GetActivePlayer()]
	local teamTechs = Teams[pActivePlayer:GetTeam()]:GetTeamTechs()
	local researchLeft = teamTechs:GetResearchLeft(pActivePlayer:GetCurrentResearch())
	-- if a tech is currently being researched, add to this tech, otherwise wait until one is selected
	if researchLeft > 0 then
		--aprint("Assigning research points")
		teamTechs:ChangeResearchProgress(pActivePlayer:GetCurrentResearch(), math.min(techPointsToAssign, researchLeft))
		techPointsToAssign = 0
	end
	save(pActivePlayer, "TechPointsToAssignFromDiscoverMission", techPointsToAssign)
	save(pActivePlayer, "CooldownTurnsLeftForDiscoverMission", cooldownTurnsLeft)
end

--[[
	The next time a research is selected, add the tech points
]]--
function OnResearchDirty()
	local pActivePlayer = Players[Game.GetActivePlayer()]
	local techPointsToAssign = load(pActivePlayer, "TechPointsToAssignFromDiscoverMission") or 0
	if techPointsToAssign > 0 then
		local teamTechs = Teams[pActivePlayer:GetTeam()]:GetTeamTechs()
		local researchLeft = teamTechs:GetResearchLeft(pActivePlayer:GetCurrentResearch())
		if researchLeft > 0 then
			--aprint("Assigning research points")
			teamTechs:ChangeResearchProgress(pActivePlayer:GetCurrentResearch(), math.min(techPointsToAssign, researchLeft))
			techPointsToAssign = 0
			save(pActivePlayer, "TechPointsToAssignFromDiscoverMission", techPointsToAssign)
		end
	end
end
Events.SerialEventResearchDirty.Add(OnResearchDirty)

--[[
	On active player turn start, reduce the cooldown counter by 1 per turn
]]--
function OnActivePlayerTurnStart()
	local pActivePlayer = Players[Game.GetActivePlayer()]
	local cooldownTurnsLeft = load(pActivePlayer, "CooldownTurnsLeftForDiscoverMission") or 0
	cooldownTurnsLeft = cooldownTurnsLeft - 1
	save(pActivePlayer, "CooldownTurnsLeftForDiscoverMission", cooldownTurnsLeft)
end
Events.ActivePlayerTurnStart.Add(OnActivePlayerTurnStart)


--[[
	Calculate modifiers for difficulty, map size and speed	
]]--
modifiers = {}
modifiers[#modifiers + 1] = GameInfo.HandicapInfos[Players[Game.GetActivePlayer()]:GetHandicapType()].ResearchPercent
modifiers[#modifiers + 1] = GameInfo.GameSpeeds[Game.GetGameSpeedType()].ResearchPercent
modifiers[#modifiers + 1] = GameInfo.Worlds[Map:GetWorldSize()].ResearchPercent

--[[
	Hook up the handlers to the CustomMissionHandler
]]--
LuaEvents.AddCustomMissionCanHandle("MISSION_DISCOVER_ME", CanHandle)
LuaEvents.AddCustomMissionOnClick("MISSION_DISCOVER_ME", OnClick)
LuaEvents.AddCustomMissionToolTip("MISSION_DISCOVER_ME", GetToolTip)
LuaEvents.AddCustomMissionDisabledToolTip("MISSION_DISCOVER_ME", GetDisabledToolTip)