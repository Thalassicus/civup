--
-- Load/save operations
--

if not MapModData.VEM.CanDoTriggers then
	MapModData.VEM.CanDoTriggers	= {}
	MapModData.VEM.TrigChance		= {}
	MapModData.VEM.TrigOutcomes		= {}
	MapModData.VEM.TrigRanRecently	= {}
	MapModData.VEM.TrigRanFor		= {}
	MapModData.VEM.TrigTech			= {}
	for playerID,player in Players() do
		MapModData.VEM.TrigOutcomes[playerID]		= {}
		MapModData.VEM.TrigRanRecently[playerID]	= {}
		MapModData.VEM.TrigChance[playerID]			= LoadValue("MapModData.VEM.TrigChance[%s]", playerID)
		MapModData.VEM.TrigTech[playerID]			= {}
		for trigInfo in GameInfo.Triggers() do			
			if trigInfo.BuildingClass then
				TrigTech[playerID][trigInfo.ID] = GameInfo.Buildings[GetUniqueBuildingID(player, trigInfo.Target)].PrereqTech
			elseif trigInfo.UnitClass then
				TrigTech[playerID][trigInfo.ID] = GameInfo.Units[GetUniqueUnitID(player, trigInfo.Target)].PrereqTech
			elseif trigInfo.ImprovementType then
				for buildInfo in GameInfo.Builds(string.format("ImprovementType = '%s'", trigInfo.Target)) do
					TrigTech[playerID][trigInfo.ID] = buildInfo.PrereqTech
				end
			else
				TrigTech[playerID][trigInfo.ID] = trigInfo.PrereqTech
			end
		end
		if MapModData.VEM.TrigChance[playerID] then
			LoadTriggers(player)
		else
			ResetTriggers(player)
		end
	end
end

function LoadTriggers(player)
	MapModData.VEM.CanDoTriggers[playerID] = LoadValue("MapModData.VEM.CanDoTriggers[%s]", playerID) or 0
	for trigInfo in GameInfo.Triggers() do
		local trigID = trigInfo.ID
		MapModData.VEM.TrigOutcomes[playerID][trigID] = {}
		MapModData.VEM.TrigRanRecently[playerID][trigID] = (1 == LoadValue("MapModData.VEM.TrigRanRecently[%s][%s]", playerID, trigID))
		MapModData.VEM.TrigRanFor[trigID] = {}
		local flagString = LoadValue("MapModData.VEM.TrigRanFor[%s]", trigID)
		if Contains({"TARGET_PLAYER", "TARGET_CITYSTATE", "TARGET_POLICY", "TARGET_UNIT"}, trigInfo.target) then
			-- these require a 2-dimensional array per trigger
			for playerID, player in pairs(Players) do
				MapModData.VEM.TrigRanFor[trigID][playerID] = {}
				for index=1, flagString:len() do
					MapModData.VEM.TrigRanFor[trigID][playerID][index] = (1 == flagString[index + playerID * GameDefines.MAX_MAJOR_CIVS])
				end
			end
		else
			for index=1, flagString:len() do
				MapModData.VEM.TrigRanFor[trigID][index] = (1 == flagString[index])
			end
		end
	end
end

function ResetTriggers(player)
	MapModData.VEM.TrigChance[playerID] = 0
	MapModData.VEM.CanDoTriggers[playerID] = 1
	SaveValue(0, "MapModData.VEM.TrigChance[%s]", playerID)
	SaveValue(1, "MapModData.VEM.CanDoTriggers[%s]", playerID)
	for trigInfo in GameInfo.Triggers() do
		MapModData.VEM.TrigOutcomes[playerID][trigInfo.ID] = {}
		MapModData.VEM.TrigRanRecently[playerID][trigInfo.ID] = CanDoThisTurn(player, trigID)
		MapModData.VEM.TrigRanFor[trigID] = {}
		if Contains({"TARGET_PLAYER", "TARGET_CITYSTATE", "TARGET_POLICY", "TARGET_UNIT"}, trigInfo.target) then
			-- these require a 2-dimensional array per trigger
			for playerID, player in pairs(Players) do
				MapModData.VEM.TrigRanFor[trigID][playerID] = {}
			end
		end
	end
end

--
-- Check for eligible triggers
--

function HasTriggeredFor(trigID, playerID, targetID)
	local trigInfo = GameInfo.Triggers[trigID]
	if Contains({"TARGET_PLAYER", "TARGET_CITYSTATE", "TARGET_POLICY", "TARGET_UNIT"}, trigInfo.target) then
		return MapModData.VEM.TrigRanFor[trigID][playerID][targetID]
	else
		return MapModData.VEM.TrigRanFor[trigID][targetID]
	end
end

function SetTriggeredFor(trigID, playerID, targetID, value)
	local trigInfo = GameInfo.Triggers[trigID]
	if trigInfo.CanRepeat then
		return
	end
	if Contains({"TARGET_PLAYER", "TARGET_CITYSTATE", "TARGET_POLICY", "TARGET_UNIT"}, trigInfo.target) then
		MapModData.VEM.TrigRanFor[trigID][playerID][targetID] = value
	else
		MapModData.VEM.TrigRanFor[trigID][targetID] = value
	end	
end

function CheckOutcomes(playerID, trigID, targetID)
	local trigInfo = GameInfo.Triggers[trigID]
	if not HasTriggeredFor(trigID, playerID, targetID) then
		for outInfo in GameInfo.Outcomes(string.format("TriggerType = '%s'", trigInfo.Type)) do
			if assert(loadstring("return " .. outInfo.Condition))(playerID, targetID) then
				MapModData.VEM.TrigOutcomes[playerID][trigID][targetID] = MapModData.VEM.TrigOutcomes[playerID][trigID][targetID] or {}
				MapModData.VEM.TrigOutcomes[playerID][trigID][targetID][outInfo.Order] = outInfo.Type
			else
				MapModData.VEM.TrigOutcomes[playerID][trigID][targetID][outInfo.Order] = -1
			end
		end
	end
end

function CanDoThisTurn(player, trigID)
	local playerID			= player:GetID()
	local trigInfo			= GameInfo.Triggers[trigID]
	local target			= nil
	local tarUnitClass		= nil
	local tarBuildingClass	= nil
	local tarImprovement	= nil
	local query				= string.format("TriggerType = '%s'", trigInfo.Type)
	local MapModData.VEM.TrigOutcomes[playerID][trigID] = {}
	
	if not Player_HasTech(player, MapModData.VEM.TrigTech[playerID]) then
		return false
	end
		
	target = trigInfo.TargetClass
	if trigInfo.UnitClass then
		tarUnitClass = GameInfo.UnitClasses[trigInfo.UnitClass].Type
		target = target or "TARGET_UNIT"
	elseif trigInfo.BuildingClass then
		tarBuildingClass = GameInfo.BuildingClasses[trigInfo.BuildingClass].Type
		target = target or "TARGET_CITY"
	elseif trigInfo.ImprovementType then
		tarImprovement = GameInfo.Improvements[trigInfo.ImprovementType].ID
		target = target or "TARGET_CITY_PLOT"
	elseif trigInfo.Turn then
		if Game.GetGameTurn() ~= trigInfo.Turn then
			return false
		end
	end
	target = target or "TARGET_GENERIC"
	
	if target == "TARGET_CITY" or target == "TARGET_OWNED_PLOT" then
		for city in player:Cities() do
			if target == "TARGET_CITY" or (tarBuildingClass and GetNumBuildingClass(city, tarBuildingClass) > 0) then
				CheckOutcomes(playerID, trigID, City_GetID(city))
			elseif target == "TARGET_OWNED_PLOT" or tarImprovement then
				for i = 0, city:GetNumCityPlots() - 1, 1 do
					local plot = city:GetCityIndexPlot(i)
					if plot and plot:GetOwner() == playerID then
						if not tarImprovement or tarImprovement == plot:GetImprovementType() then
							CheckOutcomes(playerID, trigID, Plot_GetID(plot))
						end
					end
				end
			end
		end
	elseif target == "TARGET_ANY_PLOT" then
		for plotID, plot in Plots() do
			if not tarImprovement or tarImprovement == plot:GetImprovementType() then
				CheckOutcomes(playerID, trigID, plotID)
			end
		end
	elseif target == "TARGET_UNIT" then
		for unit in player:Units() do
			if target == "TARGET_UNIT" or (tarUnitClass and tarUnitClass == GetUnitClass(unit)) then
				CheckOutcomes(playerID, trigID, unit:GetID())
			end
		end
	elseif target == "TARGET_POLICY" then
		for policyInfo in GameInfo.Policies() do
			if player:HasPolicy(policyInfo.ID) then
				CheckOutcomes(playerID, trigID, policyInfo.ID)
			end
		end	
	elseif target == "TARGET_PLAYER" or target == "TARGET_CITYSTATE" then
		for otherPlayerID, otherPlayer in Players() do
			if playerID ~= otherPlayerID then
				if (target == "TARGET_PLAYER" and not otherPlayer:IsMinorCiv()) or (target == "TARGET_CITYSTATE" and otherPlayer:IsMinorCiv()) then
					CheckOutcomes(playerID, trigID, otherPlayerID)
				end
			end
		end
	elseif target == "TARGET_TURN" then
		CheckOutcomes(playerID, trigID, 1)
	elseif target == "TARGET_GENERIC" then
		CheckOutcomes(playerID, trigID, 1)
	else
		log:Warn("Invalid TargetClass %s for trigger %s", target, trigInfo.Type)
	end
	if #(MapModData.VEM.TrigOutcomes[playerID][trigID]) > 0 then
		return true
	end
	return false
end

function GetEligibleTriggers(player)
	local eligibleIDs = {}
	for trigInfo in GameInfo.Triggers() do
		if MapModData.VEM.TrigRanRecently[playerID][trigInfo.ID] then
			if CanDoThisTurn(player, trigInfo.ID) then
				table.insert(eligibleIDs, trigInfo.ID)
			else
				MapModData.VEM.TrigRanRecently[playerID][trigInfo.ID] = false
			end
		end
	end
	return eligibleIDs
end

--
-- Main algorithm
--

function DoTrigger(player, trigID)
	local trigInfo = GameInfo.Triggers[trigID]
	local playerID = player:GetID()
	
	local possibleIDs = {}
	for targetID, outInfo in pairs(MapModData.VEM.TrigOutcomes[playerID][trigID]) do
		table.insert(possibleIDs, targetID)
	end
	
	local selectedID = possibleIDs[1 + Map.Rand(#possibleIDs, "CheckTriggers")]
	
	SetTriggeredFor(trigID, playerID, targetID, true)	
	LogTrigger(player, trigID, selectedID)
	LuaEvents.DoTriggerPopup(player, trigID, selectedID)
end

function CheckTriggers(player)
	local playerID			= player:GetID()
	local activePlayer		= Game.GetActivePlayer()
	local trigRate			= GameInfo.Eras[activePlayer:GetCurrentEra()].trigRatePercent
	local trigChance		= MapModData.VEM.TrigChance[playerID] + trigRate
	
	if MapModData.VEM.CanDoTriggers[playerID] and trigChance >= (1 + Map.Rand(100, "CheckTriggers")) then
		local eligibleIDs	= GetEligibleTriggers(player)
		local totalWeight	= 0
		local chanceIDs		= {}
		local chancePos		= 1
		
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
	
	if trigChance == 100 then
		ResetTriggers(player)
	else
		MapModData.VEM.TrigChance[playerID] = trigChance
		SaveValue(trigChance, "MapModData.VEM.TrigChance[%s]", playerID)
	end
end

LuaEvents.ActivePlayerTurnStart_Player.Add(CheckTriggers)