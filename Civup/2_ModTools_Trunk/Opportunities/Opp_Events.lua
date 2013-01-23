-- CiVUP_General
-- Author: Thalassicus
-- DateCreated: 12/21/2010 10:00:43 AM
--------------------------------------------------------------

local startClockTime = os.clock()

include("YieldLibrary.lua")

local log = Events.LuaLogger:New()
log:SetLevel("WARN")

DEBUG_TRIGGERS = false

--
-- Default Conditions and Actions
--

Game.TrigCondition = Game.TrigCondition or {}
Game.TrigAction = Game.TrigAction or {}

function Game.TrigCondition.HasCapital(playerID, trigID, targetID, outID)
	return Players[playerID]:GetCapitalCity()
end

function Game.TrigAction.ChangePlotYield(playerID, trigID, targetID, outID)
	local plot		= Map.GetPlotByIndex(targetID)
	local yieldType	= GameInfo.Yields[GameInfo.Outcomes[outID].YieldType].ID
	local yield		= GameInfo.Outcomes[outID].Yield
	Plot_ChangeYield(plot, yieldType, yield)
end

--
-- Main algorithm
--

function CheckTriggers(player)
	if player:IsMinorCiv() or (not DEBUG_TRIGGERS and Game.GetAdjustedTurn() < 20) then
		return
	end

	local activePlayer	= Players[Game.GetActivePlayer()]
	local playerID		= player:GetID()
	local trigChance	= MapModData.Civup.TrigChance[playerID]
	local rand			= 1 + Map.Rand(100, "CheckTriggers") -- correct calculation, or off-by-one ?
	local doCheck		= true

	if DEBUG_TRIGGERS then
		trigChance = (player == activePlayer) and 100 or 0 
	end
	
	if (MapModData.Civup.BlockTriggers[playerID] == 0) and (trigChance >= rand) then
		if player:IsHuman() then
			log:Info("%15s %20s          trigChance=%s rand=%s block=%s", "CheckTriggers", player:GetName(), trigChance, rand, MapModData.Civup.BlockTriggers[playerID])
		end
		local eligibleIDs	= {}
		local totalWeight	= 0
		local chanceIDs		= {}
		local chancePos		= 1
		eligibleIDs = GetEligibleTriggers(player)
		if #eligibleIDs <= 1 then
			MapModData.Civup.TrigRanRecently[playerID] = {}
			if #eligibleIDs <= 0 then
				eligibleIDs	= GetEligibleTriggers(player)
				if #eligibleIDs <= 0 then
					log:Warn("%15s %20s          No valid triggers", " ", player:GetName())
					--MapModData.Civup.BlockTriggers[playerID] = 0
					doCheck = false
				end
			end
		end

		if doCheck then
			for _, trigID in pairs(eligibleIDs) do
				totalWeight = totalWeight + GameInfo.Triggers[trigID].Weight
			end
		
			-- map probabilities to trigger IDs
			for _, trigID in pairs(eligibleIDs) do
				local step = 1000 * GameInfo.Triggers[trigID].Weight / totalWeight
				for i = math.floor(chancePos), math.floor(chancePos + step) do
					chanceIDs[i] = trigID
				end
				chancePos = chancePos + step
			end
		
			DoTrigger(player, chanceIDs[1 + Map.Rand(1000, "CheckTriggers")])
		end
	end
	
	local trigRate = GameInfo.Eras[Game.GetAverageHumanEra()].TriggerRatePercent
	local techRate = 1.0 --GameInfo.GameSpeeds[Game.GetGameSpeedType()].ResearchPercent / 100

	MapModData.Civup.TrigChance[playerID] = trigChance + trigRate * techRate
	SaveValue(MapModData.Civup.TrigChance[playerID], "MapModData.Civup.TrigChance[%s]", playerID)
	if player:IsHuman() then
		log:Info("%15s %20s          trigChance=%s", " ", player:GetName(), MapModData.Civup.TrigChance[playerID])
	end
		
	if MapModData.Civup.TrigChance[playerID] >= 100 then
		ResetTriggers(player)
	end

	if (MapModData.Civup.BlockTriggers[playerID] == 0) and (trigChance >= rand) then
		log:Info("%15s %20s          done", " ", "CheckTriggers")
	end
end

function DoTrigger(player, trigID)
	local trigInfo = GameInfo.Triggers[trigID]
	local playerID = player:GetID()

	log:Info("%15s %20s          %s", "DoTrigger", player:GetName(), " ", " ", trigInfo.Type)
	
	local possibleOutIDs = {}
	for targetID, outInfo in pairs(MapModData.Civup.TrigOutcomes[playerID][trigID]) do
		table.insert(possibleOutIDs, targetID)
	end
	
	local targetID = possibleOutIDs[1 + Map.Rand(#possibleOutIDs, "CheckTriggers")]

	SetTriggeredFor(playerID, trigID, targetID, true)
	MapModData.Civup.BlockTriggers[playerID] = 1
	SaveValue(1, "MapModData.Civup.BlockTriggers[%s]", playerID)
	LuaEvents.TriggerPopup(player, trigID, targetID)
end

--
-- Check for eligible triggers
--

function GetEligibleTriggers(player)
	local eligibleIDs = {}
	local playerID = player:GetID()
	for trigInfo in GameInfo.Triggers() do
		if not MapModData.Civup.TrigRanRecently[playerID][trigInfo.ID] and CanDoThisTurn(player, trigInfo.ID) then
			----log:Trace("GetEligibleTriggers : %s", trigInfo.Type)
			table.insert(eligibleIDs, trigInfo.ID)
		end
	end
	if player:IsHuman() then
		----log:Debug("GetEligibleTriggers #eligibleIDs = %s", #eligibleIDs)
	end
	return eligibleIDs
end

function CanDoThisTurn(player, trigID)
	local canDo				= false
	local playerID			= player:GetID()
	local trigInfo			= GameInfo.Triggers[trigID]
	local trigTech			= MapModData.Civup.TrigTech[playerID][trigID]
	local target			= nil
	local tarUnitClass		= nil
	local tarBuildingClass	= nil
	local tarImprovement	= nil
	local tarPolicy			= nil
	local query				= string.format("TriggerType = '%s'", trigInfo.Type)
	MapModData.Civup.TrigOutcomes[playerID][trigID] = {n=0}
	
	if not player:HasTech(trigTech) then
		return false
	end
	if player:IsHuman() then
		--log:Error("%-30s EraType=%s GetCurrentEra=%s EraID=%s", trigInfo.Type, trigInfo.EraType, player:GetCurrentEra(), GameInfo.Eras[trigInfo.EraType].ID)
	end
	if trigInfo.EraType and player:GetCurrentEra() < GameInfo.Eras[trigInfo.EraType].ID then
		return false
	elseif trigInfo.Turn and Game.GetGameTurn() < trigInfo.Turn then
		return false
	end
		
	target = trigInfo.Target
	if trigInfo.UnitClass then
		tarUnitClass = GameInfo.UnitClasses[trigInfo.UnitClass].Type
		target = target or "TARGET_UNIT"
	elseif trigInfo.BuildingClass then
		tarBuildingClass = GameInfo.BuildingClasses[trigInfo.BuildingClass].Type
		target = target or "TARGET_CITY"
	elseif trigInfo.ImprovementType then
		tarImprovement = GameInfo.Improvements[trigInfo.ImprovementType].ID
		target = target or "TARGET_OWNED_PLOT"
	elseif trigInfo.PolicyType then
		tarPolicy = GameInfo.Policies[trigInfo.PolicyType].ID
		target = target or "TARGET_POLICY"
	end
	target = target or "TARGET_CUSTOM"
	
	if target == "TARGET_OWNED_PLOT" or target == "TARGET_CITY" then
		for city in player:Cities() do
			if target == "TARGET_OWNED_PLOT" or tarImprovement then
				for i = 0, city:GetNumCityPlots() - 1, 1 do
					local plot = city:GetCityIndexPlot(i)
					if plot and plot:GetOwner() == playerID then
						if tarImprovement == nil or tarImprovement == plot:GetImprovementType() then
							CheckOutcomes(playerID, trigID, Plot_GetID(plot))
						end
					end
				end
			elseif tarBuildingClass == nil or City_GetNumBuildingClass(city, tarBuildingClass) > 0 then
				----log:Debug("City_GetNumBuildingClass(%s, %s) = %s", city:GetName(), tarBuildingClass, City_GetNumBuildingClass(city, tarBuildingClass))
				CheckOutcomes(playerID, trigID, City_GetID(city))
			end
		end
	elseif target == "TARGET_ANY_PLOT" then
		for plotID, plot in Plots() do
			if tarImprovement == nil or tarImprovement == plot:GetImprovementType() then
				CheckOutcomes(playerID, trigID, plotID)
			end
		end
	elseif target == "TARGET_UNIT" then
		for unit in player:Units() do
			if tarUnitClass == nil or tarUnitClass == Unit_GetClass(unit) then
				CheckOutcomes(playerID, trigID, unit:GetID())
			end
		end
	elseif target == "TARGET_POLICY" or tarPolicy then
		if tarPolicy and player:HasPolicy(tarPolicy) then
			CheckOutcomes(playerID, trigID, policyInfo.ID)
		else
			for policyInfo in GameInfo.Policies() do
				if player:HasPolicy(policyInfo.ID) then
					CheckOutcomes(playerID, trigID, policyInfo.ID)
				end
			end
		end
	elseif target == "TARGET_PLAYER" or target == "TARGET_CITYSTATE" then
		for otherPlayerID, otherPlayer in pairs(Players) do
			if player:IsAliveCiv() and playerID ~= otherPlayerID and player:HasMet(otherPlayer) then
				if (target == "TARGET_PLAYER" and not otherPlayer:IsMinorCiv()) or (target == "TARGET_CITYSTATE" and otherPlayer:IsMinorCiv()) then
					CheckOutcomes(playerID, trigID, otherPlayerID)
				end
			end
		end
	elseif target == "TARGET_TURN" or target == "TARGET_ERA" or target == "TARGET_CUSTOM" then
		CheckOutcomes(playerID, trigID, 1)
	else
		log:Warn("Invalid TargetClass %s for trigger %s", target, trigInfo.Type)
	end
	if MapModData.Civup.TrigOutcomes[playerID][trigID].n > 0 then
		canDo = true
	end
	MapModData.Civup.TrigOutcomes[playerID][trigID].n = nil
	return canDo
end

function CheckOutcomes(playerID, trigID, targetID)
	local trigInfo = GameInfo.Triggers[trigID]
	if not HasTriggeredFor(playerID, trigID, targetID) then
		for outInfo in GameInfo.Outcomes(string.format("TriggerType = '%s'", trigInfo.Type)) do
			local outID = outInfo.ID
			local outCost = outInfo.GoldCost			
			if trigInfo.Target ~= "TARGET_CITYSTATE" then
				outCost = Game.Round(outCost * Game.GetSpeedYieldMod(YieldTypes.YIELD_GOLD), -1)
			end
			if Players[playerID]:GetYieldStored(YieldTypes.YIELD_GOLD) >= outCost then
				if outInfo.Condition and assert(loadstring("return " .. outInfo.Condition))() == nil then
					log:Error("%s %s function does not exist!", trigInfo.Type, outInfo.Condition)
				elseif not outInfo.Condition or assert(loadstring("return " .. outInfo.Condition))()(playerID, trigID, targetID, outID) then
					----log:Trace("Valid Outcome: %s %s %s", trigInfo.Type, outID, targetID)
					MapModData.Civup.TrigOutcomes[playerID][trigID][targetID] = MapModData.Civup.TrigOutcomes[playerID][trigID][targetID] or {}
					MapModData.Civup.TrigOutcomes[playerID][trigID][targetID][outInfo.Order] = outID
					MapModData.Civup.TrigOutcomes[playerID][trigID].n = (MapModData.Civup.TrigOutcomes[playerID][trigID].n or 0) + 1
				end
			end
		end
	end
end

function HasTriggeredFor(playerID, trigID, targetID)
	if MapModData.Civup.TrigRanFor[playerID][trigID][targetID] == nil then
		MapModData.Civup.TrigRanFor[playerID][trigID][targetID] = LoadValue("MapModData.Civup.TrigRanFor[%s][%s][%s]", playerID, trigID, targetID) or 0
	end
	return (1 == MapModData.Civup.TrigRanFor[playerID][trigID][targetID])
end

function SetTriggeredFor(playerID, trigID, targetID, value)
	MapModData.Civup.TrigRanFor[playerID][trigID][targetID] = value and 1 or 0
	SaveValue(value and 1 or 0, "MapModData.Civup.TrigRanFor[%s][%s][%s]", playerID, trigID, targetID)
end

--
-- Load/save operations
--

function LoadTriggers(player)
	local playerID = player:GetID()
	MapModData.Civup.BlockTriggers[playerID] = LoadValue("MapModData.Civup.BlockTriggers[%s]", playerID) or 0
	if MapModData.Civup.BlockTriggers[playerID] == 1 then
		log:Info("%15s %20s          blocked from triggers", "LoadTriggers", player:GetName())
	else
		log:Info("%15s %20s          can do triggers", "LoadTriggers", player:GetName())
	end
	for trigInfo in GameInfo.Triggers() do
		local trigID = trigInfo.ID
		MapModData.Civup.TrigOutcomes[playerID][trigID] = {n=0}
		MapModData.Civup.TrigRanFor[playerID][trigID] = {}
		MapModData.Civup.TrigRanRecently[playerID][trigID] = (1 == LoadValue("MapModData.Civup.TrigRanRecently[%s][%s]", playerID, trigID))
	end
end

function ResetTriggers(player)
	local playerID = player:GetID()
	MapModData.Civup.TrigChance[playerID] = MapModData.Civup.TrigChance[playerID] or 0
	if MapModData.Civup.TrigChance[playerID] >= 100 then
		MapModData.Civup.TrigChance[playerID] = MapModData.Civup.TrigChance[playerID] - 100
	end

	if player:IsHuman() then
		log:Info("%15s %20s          trigChance=%s", "ResetTriggers", player:GetName(), MapModData.Civup.TrigChance[playerID])
	end
	MapModData.Civup.BlockTriggers[playerID] = 0
	MapModData.Civup.TrigRanRecently[playerID] = {}
	SaveValue(0, "MapModData.Civup.TrigChance[%s]", playerID)
	SaveValue(0, "MapModData.Civup.BlockTriggers[%s]", playerID)
	for trigInfo in GameInfo.Triggers() do
		local trigID = trigInfo.ID
		MapModData.Civup.TrigOutcomes[playerID][trigID] = {n=0}
		MapModData.Civup.TrigRanFor[playerID][trigID] = {}
	end
end

--
-- Initialize
--

if not MapModData.Civup.InitTriggers then
	--log:Debug("Initializing Trigger System")
	MapModData.Civup.InitTriggers		= true
	MapModData.Civup.BlockTriggers		= {}
	MapModData.Civup.TrigChance			= {}
	MapModData.Civup.TrigOutcomes		= {}
	MapModData.Civup.TrigRanRecently	= {}
	MapModData.Civup.TrigRanFor			= {}
	MapModData.Civup.TrigTech			= {}
	startClockTime = os.clock()
	for playerID,player in pairs(Players) do
		if player:IsAliveCiv() and not player:IsMinorCiv() then
			MapModData.Civup.TrigOutcomes[playerID]		= {}
			MapModData.Civup.TrigRanRecently[playerID]	= {}
			MapModData.Civup.TrigTech[playerID]			= {}
			MapModData.Civup.TrigRanFor[playerID]			= {}
			if UI:IsLoadedGame() then
				MapModData.Civup.TrigChance[playerID]		= LoadValue("MapModData.Civup.TrigChance[%s]", playerID)
			else
				MapModData.Civup.TrigChance[playerID]		= 0
			end
			if player:IsHuman() then
				log:Info("%15s %20s          trigChance=%s", "Initialize", player:GetName(), MapModData.Civup.TrigChance[playerID])
			end

			-- prerequisite techs
			for trigInfo in GameInfo.Triggers() do
				local prereqTech = nil
				if trigInfo.PrereqTech then
					-- priority override
					prereqTech = trigInfo.PrereqTech
				elseif trigInfo.BuildingClass then
					prereqTech = GameInfo.Buildings[player:GetUniqueBuildingID(trigInfo.BuildingClass)].PrereqTech
				elseif trigInfo.UnitClass then
					prereqTech = GameInfo.Units[player:GetUniqueUnitID(trigInfo.UnitClass)].PrereqTech
				elseif trigInfo.ImprovementType then
					for buildInfo in GameInfo.Builds(string.format("ImprovementType = '%s'", trigInfo.ImprovementType)) do
						prereqTech = buildInfo.PrereqTech
					end
				end
				if not prereqTech then
					prereqTech = "TECH_AGRICULTURE"
				end
				MapModData.Civup.TrigTech[playerID][trigInfo.ID] = prereqTech
			end
			
			if UI:IsLoadedGame() then
				LoadTriggers(player)
			else
				ResetTriggers(player)
			end
		end
	end
	if UI:IsLoadedGame() then
		log:Info("%3s ms loading Triggers", Game.Round((os.clock() - startClockTime)*1000))
	end
end

if GameInfo.Triggers[1] ~= nil then
	log:Info("Trigger System Active")
	LuaEvents.ActivePlayerTurnStart_Player.Add(CheckTriggers)
end

print(string.format("%3s ms loading Opp_Events.lua", Game.Round((os.clock() - startClockTime)*1000)))