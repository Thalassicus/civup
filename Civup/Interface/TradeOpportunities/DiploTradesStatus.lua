include("IconSupport")
include("SupportFunctions")
include("InstanceManager")
include("InfoTooltipInclude")
include("YieldLibrary.lua")

local log = Events.LuaLogger:New()
log:SetLevel("DEBUG")

local gLabelIM = InstanceManager:new("TradeStatusInstance", "TradeBox", Controls.WindowHeaders)
local gPlayerIM = InstanceManager:new("TradeStatusInstance", "TradeBox", Controls.PlayerBox)
local gAiIM = InstanceManager:new("TradeStatusInstance", "TradeBox", Controls.AiStack)
local gCsIM = InstanceManager:new("CityStateInstance", "TradeBox", Controls.AiStack)

local gSortTable

local resourceList = Game.GetSortedResourceList({ResourceUsageTypes.RESOURCEUSAGE_LUXURY, ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC}, true)
local dealList = {}
local numResources = 0

for _, resInfo in ipairs(resourceList) do
	numResources = numResources + 1
end

local defaultWidth = Game.Round(500 / numResources)
local stackOffset = 910 - (defaultWidth * (numResources + 5) + 100)


function ShowHideHandler(bIsHide, bIsInit)
	if (not bIsInit and not bIsHide) then
		--print("Show DiploTradeStatus")
		gLabelIM:ResetInstances()
		gPlayerIM:ResetInstances()
		gAiIM:ResetInstances()
		gCsIM:ResetInstances()
		
		dealList = Players[Game.GetActivePlayer()]:GetDeals()
		InitLabels()
		InitPlayer()
		InitAiList()
	end
end
ContextPtr:SetShowHideHandler(ShowHideHandler)

function InitLabels()
	local controlTable = gLabelIM:GetInstance()
	controlTable.CivButton:SetHide(true)
	controlTable.MainStack:DestroyAllChildren()
	
	local button = {}
	
	for _, resInfo in ipairs(resourceList) do
		button = AddButton(controlTable.MainStack, resInfo.IconString, resInfo.IconString .. " " .. Locale.ConvertTextKey(resInfo.Description))
	end
	
	AddButton(controlTable.MainStack)
	AddButton(controlTable.MainStack, "[ICON_TRADE]", "TXT_KEY_DEAL_BORDER_AGREEMENT")
	AddButton(controlTable.MainStack, "[ICON_RESEARCH]", "TXT_KEY_DEAL_RESEARCH_AGREEMENT")
	AddButton(controlTable.MainStack, "[ICON_STRENGTH]", "TXT_KEY_DEAL_DEFENSIVE_PACT")
	AddButton(controlTable.MainStack, "[ICON_TEAM_8]", "TXT_KEY_DEAL_ALLIANCE")
	button = AddButton(controlTable.MainStack, "[ICON_GOLD]", "TXT_KEY_DEAL_GOLD_STORED", false, 50)
	local width = button.Label:GetSizeX()
	button.Label:SetAnchor("R,C")
	button.Button:SetOffsetX(5)
	button.Button:SetSizeX(50)
	button = AddButton(controlTable.MainStack, string.format("+[ICON_GOLD]/%s", Locale.ConvertTextKey("TXT_KEY_DO_TURN")), "TXT_KEY_DEAL_GOLD_PROFIT", false, 50)
	local width = button.Label:GetSizeX()
	button.Label:SetAnchor("L,C")
	button.Button:SetSizeX(50)
	
	controlTable.MainStack:CalculateSize()
	controlTable.MainStack:ReprocessAnchoring()
	controlTable.MainStack:SetOffsetX(stackOffset)
	
	controlTable.Divider:SetHide(true)
end

function InitPlayer()	
	--allButtons[Game.GetActivePlayer()] = {}
	GetCivControl(gPlayerIM, 0, false)
end

function InitAiList()
	local activePlayerID = Game.GetActivePlayer()
	local activePlayer = Players[activePlayerID]
	local activeTeam = Teams[activePlayer:GetTeam()]
	local count = 0

	gSortTable = {}
	
	for playerIDLoop = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
		local pOtherPlayer = Players[playerIDLoop]
		local iOtherTeam = pOtherPlayer:GetTeam()
		
		if pOtherPlayer:IsAlive() and playerIDLoop ~= activePlayerID then
			if (activeTeam:IsHasMet(iOtherTeam)) then
				count = count+1
				GetCivControl(gAiIM, playerIDLoop, true)
			end
		end
	end
	
	if InitCsList() then
		count = count+1
	end

	if count == 0 then
		Controls.AiNoneMetText:SetHide(false)
		Controls.AiScrollPanel:SetHide(true)
	else
		Controls.AiStack:SortChildren(ByScore)
		Controls.AiStack:CalculateSize()
		Controls.AiStack:ReprocessAnchoring()
		Controls.AiScrollPanel:CalculateInternalSize()
		Controls.AiNoneMetText:SetHide(true)
		Controls.AiScrollPanel:SetHide(false)
	end
end

function InitCsList()
	local bCsMet = false
	local activePlayerID = Game.GetActivePlayer()
	local activePlayer = Players[activePlayerID]
	local activeTeam = Teams[activePlayer:GetTeam()]

	local controlTable = gCsIM:GetInstance()
	local iMaxY = controlTable.TradeBox:GetSizeY()
	
	controlTable.MainStack:DestroyAllChildren()

	for _, resInfo in ipairs(resourceList) do
		local resStack = {}
		local numCS = 0
		local resID = resInfo.ID
		ContextPtr:BuildInstanceForControl("CityStateResourceStack", resStack, controlTable.MainStack)

		for iCsLoop = GameDefines.MAX_MAJOR_CIVS, GameDefines.MAX_CIV_PLAYERS-1, 1 do
			local pCs = Players[iCsLoop]
	
			if (pCs:IsAlive() and activeTeam:IsHasMet(pCs:GetTeam())) then
				local numResourceNear = GetResourceNearCS(pCs, resInfo)
				if IsCsHasResource(pCs, resInfo) or numResourceNear > 0 then
					numCS = numCS + 1
					local sTrait = GameInfo.MinorCivilizations[pCs:GetMinorCivType()].MinorCivTrait
					local primaryColor, secondaryColor = pCs:GetPlayerColors()
					local color = "[COLOR_GREY]"
					local exported = pCs:GetResourceExport(resID)
					local allyID = pCs:GetAlly()
					if allyID == activePlayerID then
						if exported >= numResourceNear then
							color = "[COLOR_POSITIVE_TEXT]"
						else
							color = "[COLOR_WHITE]"
							numResourceNear = exported .. "/" .. numResourceNear
						end
					elseif pCs:GetNumResourceTotal(resID, false) > 0 then
						if pCs:GetMinorCivFriendshipWithMajor(activePlayerID) >= GameDefines.FRIENDSHIP_THRESHOLD_ALLIES then
							-- rival higher than us
							color = "[COLOR_NEGATIVE_TEXT]"
						elseif allyID and allyID ~= -1 then
							-- rival lower than us
							color = "[COLOR_PLAYER_ORANGE_TEXT]"
							
						else
							-- no rival
							color = "[COLOR_YELLOW]"
						end
					end
					local sToolTip = string.format("%s[NEWLINE]%s %s%s %s[ENDCOLOR]", pCs:GetName(), resInfo.IconString, color, numResourceNear, Locale.ConvertTextKey(resInfo.Description))
					sToolTip = sToolTip .. "[NEWLINE]" .. GetCityStateStatus(pCs, activePlayer, pCs:IsAtWar(activePlayer))
					
					local button = {}
					
					ContextPtr:BuildInstanceForControl("CityStateButtonInstance", button, resStack.Stack)

					--button.CsLuxuryIcon:SetText(resInfo.IconString)
					
					button.CsTraitIcon:SetTexture(GameInfo.MinorCivTraits[sTrait].TraitIcon)
					button.CsTraitIcon:SetColor({x = secondaryColor.x, y = secondaryColor.y, z = secondaryColor.z, w = 1})
					button.CsButton:SetSizeX(defaultWidth)
					button.CsButton:SetToolTipString(sToolTip)
					button.CsButton:SetVoid1(iCsLoop)
					button.CsButton:RegisterCallback(Mouse.eLClick, OnCsSelected)
					button.MouseOverContainer:SetHide(false)
					button.MouseOverContainer:SetSizeX(20 + defaultWidth)
					button.MouseOverAnim:SetSizeX(20 + defaultWidth)
					button.MouseOverGrid:SetSizeX(20 + defaultWidth)
					if pCs:IsAllies(activePlayerID) then
						button.CsTraitIcon:SetAlpha(1)
					else
						button.CsTraitIcon:SetAlpha(0.3)
					end
				end

				bCsMet = true
			end
		end
		
		if numCS == 0 then
			AddButton(resStack.Stack)
		end

		resStack.Stack:CalculateSize()
		resStack.Stack:SetSizeX(defaultWidth)
		resStack.Stack:ReprocessAnchoring()

		iMaxY = math.max(iMaxY, resStack.Stack:GetSizeY())
	end 

	if (not bCsMet) then
		controlTable.TradeBox:SetHide(true)
	else
		controlTable.TradeBox:SetSizeY(iMaxY+5)
		controlTable.MainStack:SetOffsetX(stackOffset)
	end
	--]]
	return bCsMet
end

function GetCivControl(im, playerID, bCanTrade)
	local player			= Players[playerID]
	local iTeam				= player:GetTeam()
	local pTeam				= Teams[iTeam]
	local pCivInfo			= GameInfo.Civilizations[player:GetCivilizationType()]
	local activePlayerID	= Game.GetActivePlayer()
	local activePlayer		= Players[activePlayerID]
	local iActiveTeam		= activePlayer:GetTeam()
	local activeTeam		= Teams[iActiveTeam]
	local bIsActivePlayer	= (activePlayerID == playerID)
	local isAtWar			= player:IsAtWar(activePlayer)	
	
	local pDeal				= UI.GetScratchDeal()
	local button			= {}
	
	local controlTable		= im:GetInstance()
	local sortEntry			= {}
	local turnsLeft			= 0
	local statusIcon		= "[ICON_HAPPINESS_2]"
	local statusColor		= "[COLOR_WHITE]"
	local statusTip			= ""
	
	if bIsActivePlayer then
		controlTable.CivName:SetText(Locale.ConvertTextKey("TXT_KEY_YOU"))
	elseif player:IsHuman() then
		controlTable.CivName:SetText(Locale.TruncateString(player:GetNickName(), 20, true))
	else
		if isAtWar then
			statusIcon	= "[ICON_WAR]"
			statusColor	= "[COLOR_RED]"
			statusTip	= "TXT_KEY_DO_AT_WAR"
		elseif player:IsDenouncedPlayer(activePlayerID) and activePlayer:IsDenouncedPlayer(playerID) then
			statusIcon	= "[ICON_TEAM_2]"
			statusColor	= "[COLOR_RED]"
			statusTip	= "TXT_KEY_DEAL_DENOUNCED_BOTH"
		elseif player:IsDenouncedPlayer(activePlayerID) then
			statusIcon	= "[ICON_TEAM_9]"
			statusColor	= "[COLOR_PLAYER_ORANGE_TEXT]"
			statusTip	= "TXT_KEY_DEAL_DENOUNCED_US"
		elseif activePlayer:IsDenouncedPlayer(playerID) then
			statusIcon	= "[ICON_TEAM_9]"
			statusColor	= "[COLOR_PLAYER_ORANGE_TEXT]"
			statusTip	= "TXT_KEY_DEAL_DENOUNCED_THEM"
		elseif player:IsDoF(activePlayerID) then
			statusIcon	= "[ICON_TEAM_8]"
			statusColor	= "[COLOR_MENU_BLUE]"			
			statusTip	= "TXT_KEY_DEAL_STATUS_ALLIANCE_NO_TT"
		elseif pTeam:IsForcePeace(iActiveTeam) then
			statusIcon	= "[ICON_TEAM_1]"
			statusTip	= "TXT_KEY_DEAL_PEACE_TREATY"
		else
			local approachID = activePlayer:GetApproachTowardsUsGuess(playerID)
			if approachID == MajorCivApproachTypes.MAJOR_CIV_APPROACH_HOSTILE then
				statusIcon	= "[ICON_HAPPINESS_4]"
				statusColor	= "[COLOR_PLAYER_ORANGE_TEXT]"
				statusTip	= "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_HOSTILE"
			elseif approachID == MajorCivApproachTypes.MAJOR_CIV_APPROACH_GUARDED then
				statusIcon	= "[ICON_HAPPINESS_3]"
				statusColor	= "[COLOR_YELLOW]"
				statusTip	= "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_GUARDED"
			elseif approachID == MajorCivApproachTypes.MAJOR_CIV_APPROACH_AFRAID then
				statusIcon	= "[ICON_HAPPINESS_3]"
				statusColor	= "[COLOR_CULTURE_STORED]"
				statusTip	= "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_AFRAID"
			elseif approachID == MajorCivApproachTypes.MAJOR_CIV_APPROACH_FRIENDLY then
				statusIcon	= "[ICON_HAPPINESS_1]"
				statusColor	= "[COLOR_GREEN]"
				statusTip	= "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_FRIENDLY"
			else
				statusIcon	= "[ICON_HAPPINESS_2]"
				statusTip	= "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_NEUTRAL"
			end
		end
			
		controlTable.CivName:SetText(string.format("%s%s[ENDCOLOR]", statusColor, Locale.TruncateString(player:GetName(), 20, true)))
		statusTip = string.format("%s%s[ENDCOLOR][NEWLINE]", statusColor, Locale.ConvertTextKey(statusTip))
	end
	
	
	CivIconHookup(playerID, 32, controlTable.CivSymbol, controlTable.CivIconBG, controlTable.CivIconShadow, false, true)
	controlTable.CivIconBG:SetHide(false)
	
	statusTip = string.format(
		"%s%s[NEWLINE]%s %s",
		statusTip,
		Locale.ConvertTextKey(GameInfo.Eras[player:GetCurrentEra()].Description),
		player:GetScore(),
		Locale.ConvertTextKey("TXT_KEY_POP_SCORE")
	)

	controlTable.StatusIcon:SetText(statusIcon)
	controlTable.CivButton:SetToolTipString(statusTip)

	if bCanTrade then				
		controlTable.CivButton:SetVoid1(playerID)
		controlTable.CivButton:RegisterCallback(Mouse.eLClick, OnCivSelected)

		gSortTable[tostring(controlTable.TradeBox)] = sortEntry
		sortEntry.PlayerID = playerID
	else
		controlTable.CivButtonHL:SetHide(true)
	end
	
	controlTable.MainStack:DestroyAllChildren()
	
	if isAtWar then
		button = AddButton(controlTable.MainStack, "TXT_KEY_AT_WAR_LARGE")
		button.Button:SetSizeX(defaultWidth * numResources)
		button.Label:SetAnchor("C,C")
	else
		for _, resInfo in ipairs(resourceList) do
			PopulateResourceInstance(controlTable.MainStack, player, resInfo, bIsActivePlayer)
		end
	end
	
	AddButton(controlTable.MainStack)	
	
	if bIsActivePlayer then
		AddButton(controlTable.MainStack)
		AddButton(controlTable.MainStack)
		AddButton(controlTable.MainStack)
		AddButton(controlTable.MainStack)
		controlTable.Divider:SetHide(true)
	elseif isAtWar then
		AddButton(controlTable.MainStack)
		AddButton(controlTable.MainStack)
		AddButton(controlTable.MainStack)
		AddButton(controlTable.MainStack)
	else
		if pTeam:IsAllowsOpenBordersToTeam(iActiveTeam) and activeTeam:IsAllowsOpenBordersToTeam(iTeam) then
			turnsLeft = dealList[TradeableItems.TRADE_ITEM_OPEN_BORDERS][playerID][1].finalTurn - Game.GetGameTurn()
			AddButton(
				controlTable.MainStack, 
				turnsLeft,
				string.format("%s[NEWLINE][NEWLINE]%s %s", Locale.ConvertTextKey("TXT_KEY_DEAL_BORDER_AGREEMENT"), turnsLeft, Locale.ConvertTextKey("TXT_KEY_VP_TURNS"))
			)
		elseif pTeam:IsAllowsOpenBordersToTeam(iActiveTeam) then
			AddButton(
				controlTable.MainStack, "[ICON_BLOCKADED]", "TXT_KEY_DEAL_STATUS_BORDERS_US_TT",
				function() UI_StartDeal{
					fromPlayerID = Game.GetActivePlayer(), 
					toPlayerID = player:GetID(),
					agreement = "OpenBorders"
				} end
			)
		elseif activeTeam:IsAllowsOpenBordersToTeam(iTeam) then
			AddButton(
				controlTable.MainStack, "[ICON_BLOCKADED]", "TXT_KEY_DEAL_STATUS_BORDERS_THEM_TT",
				function() UI_StartDeal{
					fromPlayerID = Game.GetActivePlayer(), 
					toPlayerID = player:GetID(),
					agreement = "OpenBorders"
				} end
			)
		elseif pDeal:IsPossibleToTradeItem(playerID, activePlayerID, TradeableItems.TRADE_ITEM_OPEN_BORDERS, Game.GetDealDuration()) then
			AddButton(
				controlTable.MainStack, "[ICON_PLUS]", Locale.ConvertTextKey("TXT_KEY_DEAL_STATUS_BORDERS_YES_TT", Game.GetDealDuration()),
				function() UI_StartDeal{
					fromPlayerID = Game.GetActivePlayer(), 
					toPlayerID = player:GetID(),
					agreement = "OpenBorders"
				} end
			)
		else
			AddButton(controlTable.MainStack)
		end
		
		if pTeam:IsHasResearchAgreement(iActiveTeam) then
			turnsLeft = dealList[TradeableItems.TRADE_ITEM_RESEARCH_AGREEMENT][playerID][1].finalTurn - Game.GetGameTurn()
			AddButton(controlTable.MainStack,
				turnsLeft,
				string.format("%s[NEWLINE][NEWLINE]%s %s", Locale.ConvertTextKey("TXT_KEY_DEAL_RESEARCH_AGREEMENT"), turnsLeft, Locale.ConvertTextKey("TXT_KEY_VP_TURNS"))
			)
		elseif pDeal:IsPossibleToTradeItem(playerID, activePlayerID, TradeableItems.TRADE_ITEM_RESEARCH_AGREEMENT, Game.GetDealDuration()) then
			AddButton(
				controlTable.MainStack, "[ICON_PLUS]", Locale.ConvertTextKey("TXT_KEY_DEAL_STATUS_RA_YES_TT", Game.GetDealDuration()),
				function() UI_StartDeal{
					fromPlayerID = Game.GetActivePlayer(), 
					toPlayerID = player:GetID(),
					agreement = "ResearchAgreement"
				} end
			)
		else
			AddButton(controlTable.MainStack)
		end	
		
		if pTeam:IsDefensivePact(iActiveTeam) then
			turnsLeft = dealList[TradeableItems.TRADE_ITEM_DEFENSIVE_PACT][playerID][1].finalTurn - Game.GetGameTurn()
			AddButton(controlTable.MainStack,
				turnsLeft,
				string.format("%s[NEWLINE][NEWLINE]%s %s", Locale.ConvertTextKey("TXT_KEY_DEAL_DEFENSIVE_PACT"), turnsLeft, Locale.ConvertTextKey("TXT_KEY_VP_TURNS"))
			)
		elseif pDeal:IsPossibleToTradeItem(playerID, activePlayerID, TradeableItems.TRADE_ITEM_DEFENSIVE_PACT, Game.GetDealDuration()) then
			AddButton(controlTable.MainStack, "[ICON_PLUS]", Locale.ConvertTextKey("TXT_KEY_DEAL_STATUS_DEFENSE_YES_TT", Game.GetDealDuration()),
				function() UI_StartDeal{
					fromPlayerID = Game.GetActivePlayer(), 
					toPlayerID = player:GetID(),
					agreement = "DefensePact"
				} end
			)
		else
			AddButton(controlTable.MainStack)
		end
		
		if player:IsDoF(activePlayerID) then
			button = AddButton(controlTable.MainStack, "[ICON_TEAM_8]", "TXT_KEY_DEAL_ALLIANCE", OnCivSelected)
			button.Button:SetVoid1(playerID)
		elseif not player:IsDoFMessageTooSoon(activePlayerID) then
			button = AddButton(controlTable.MainStack, "[ICON_PLUS]", Locale.ConvertTextKey("TXT_KEY_DEAL_STATUS_ALLIANCE_YES_TT", Game.GetDealDuration()), OnCivSelected)
			button.Button:SetVoid1(playerID)
		else
			AddButton(controlTable.MainStack)
		end
	end
	
	button = AddButton(controlTable.MainStack, player:GetYieldStored(YieldTypes.YIELD_GOLD), false, false, 50)
	button.Label:SetAnchor("R,C")
	button.Button:SetOffsetX(5)
	
	local goldRate = string.format("[COLOR_CLEAR]+[ENDCOLOR]%s", player:GetYieldRate(YieldTypes.YIELD_GOLD))
	button = AddButton(controlTable.MainStack, goldRate, false, false, 50)
	button.Label:SetAnchor("L,C")
	
	controlTable.MainStack:CalculateSize()
	controlTable.MainStack:ReprocessAnchoring()
	controlTable.MainStack:SetOffsetX(stackOffset)

	return controlTable
end

function ByScore(a, b)
	local entryA = gSortTable[tostring(a)]
	local entryB = gSortTable[tostring(b)]

	if ((entryA == nil) or (entryB == nil)) then 
		if ((entryA ~= nil) and (entryB == nil)) then
			return true
		elseif ((entryA == nil) and (entryB ~= nil)) then
			return false
		else
			return (tostring(a) < tostring(b)) -- gotta do something!
		end
	end

	return (Players[entryA.PlayerID]:GetScore() > Players[entryB.PlayerID]:GetScore())
end


function AddButton(control, text, tooltip, callbackFunction, width)
	local button = {}
	width = width or defaultWidth
	ContextPtr:BuildInstanceForControl("ButtonInstance", button, control)
	
	if text then
		text = tostring(text)
		if string.find(text, "TXT_KEY") then
			button.Label:LocalizeAndSetText(text)
		else
			button.Label:SetText(text)
		end
	else
		button.Label:SetText("[ICON_HAPPINESS_2]")
	end
	
	if tooltip then
		tooltip = tostring(tooltip)
		if string.find(tooltip, "TXT_KEY") then
			button.Button:LocalizeAndSetToolTip(tooltip)
		else
			button.Button:SetToolTipString(tooltip)
		end
	else
		button.Button:SetToolTipString("")
	end
	
	button.Button:SetSizeX(width)	
	
	if callbackFunction then
		button.Button:RegisterCallback(Mouse.eLClick, callbackFunction)
		button.MouseOverContainer:SetHide(false)
		button.MouseOverContainer:SetSizeX(20 + width)
		button.MouseOverAnim:SetSizeX(20 + width)
		button.MouseOverGrid:SetSizeX(20 + width)
	else
		button.MouseOverContainer:SetHide(true)
	end
	return button
end

function PopulateResourceInstance(stack, player, resInfo, isActivePlayer)
	if (Game.GetResourceUsageType(resInfo.ID) == ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC)
		and (not player:HasTech(resInfo.TechReveal) or not player:HasTech(resInfo.TechCityTrade)
		) then
		return AddButton(stack)
	end
	
	local control		= {}
	local resID			= resInfo.ID
	local res			= player:GetResourceQuantities(resID)
	local name			= Locale.ConvertTextKey(resInfo.Description)	
	local text			= res.Available
	local tip			= Locale.ConvertTextKey("TXT_KEY_DEAL_RESOURCE", resInfo.IconString, name)

	if isActivePlayer then
		text = string.format("%s%s[ENDCOLOR]", res.Color, text)
		if res.Cities then
			text = "[ICON_FOOD]"
			tip = tip .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_RESOURCE_DEMANDED_BY") .. ":[NEWLINE]"
			tip = string.format("%s%s[ENDCOLOR]", res.Color, tip)
			for cityID, city in pairs(res.Cities) do
				tip = tip .. city:GetName() .. ", "
			end
			tip = string.gsub(tip, ", $", "")
		end
		return AddButton(stack, text, tip)
	end
	
	local activeRes = Players[Game.GetActivePlayer()]:GetResourceQuantities(resID)
	local callback = nil
	local tradeQuantity = 1

	local resType = GameInfo.Resources[resID].Type
	
	if res.Tradable > 0 and activeRes.Available <= 0 then
		-- them, not us
		if res.IsStrategic then
			tradeQuantity = math.min(5, res.Tradable)
		end
		tip = Locale.ConvertTextKey("TXT_KEY_DEAL_FROM", resInfo.IconString, name)
		callback = function()
			UI_StartDeal{
				fromPlayerID = player:GetID(),
				toPlayerID = Game.GetActivePlayer(),
				fromResources = {[resID]=tradeQuantity}
			}
		end
	elseif res.Available > 0 then
		-- them, us
		if res.IsStrategic then
			tradeQuantity = math.min(5, res.Tradable)
		end
		res.Color = "[COLOR_WHITE]"
		callback = function()
			UI_StartDeal{
				fromPlayerID = player:GetID(),
				toPlayerID = Game.GetActivePlayer(),
				fromResources = {[resID]=tradeQuantity}
			}
		end
	elseif (activeRes.Tradable > 0) or 
			(activeRes.Available == 1
			and not activeRes.IsStrategic
			and activeRes.Available ~= activeRes.Citystates
			and activeRes.Available ~= activeRes.Imported
			) then
		-- not them, us
		if res.Available < 0 then
			res.Color = "[COLOR_RED]"
		else
			res.Color = "[COLOR_YELLOW]"
		end
		tip = Locale.ConvertTextKey("TXT_KEY_DEAL_TO", resInfo.IconString, name)
		if res.IsStrategic then
			tradeQuantity = math.min(5, activeRes.Tradable)
			callback = function()
				UI_StartDeal{
					fromPlayerID = Game.GetActivePlayer(),
					toPlayerID = player:GetID(),
					fromResources = {[resID]=tradeQuantity}
				}
			end
		else
			callback = function()
				UI_StartDeal{
					fromPlayerID = Game.GetActivePlayer(),
					toPlayerID = player:GetID(),
					fromResources = {[resID]=tradeQuantity}
				}
			end			
		end
	else
		-- not them, not us
		return AddButton(stack)
	end
	
	text = string.format("%s%s[ENDCOLOR]", res.Color, text)
	tip = string.format("%s%s[ENDCOLOR]", res.Color, tip)	
	
	return AddButton(stack, text, tip, callback)
end

function GetResourceNearCS(pCs, pResource)
	local iCs = pCs:GetID()
	local pCapital = pCs:GetCapitalCity()
	local numResource = 0
	
	if (pCapital ~= nil) then
		local thisX = pCapital:GetX()
		local thisY = pCapital:GetY()
		
		local iRange = 5
		local iCloseRange = 2
		
		for iDX = -iRange, iRange, 1 do
			for iDY = -iRange, iRange, 1 do
				local pTargetPlot = Map.GetPlotXY(thisX, thisY, iDX, iDY)
				
				if (pTargetPlot ~= nil) then
					local iOwner = pTargetPlot:GetOwner()
					
					if (iOwner == iCs or iOwner == -1) then
						local plotDistance = Map.PlotDistance(thisX, thisY, pTargetPlot:GetX(), pTargetPlot:GetY())
						
						if (plotDistance <= iRange and (plotDistance <= iCloseRange or iOwner == iCs)) then
							if (pTargetPlot:GetResourceType(pCs:GetTeam()) == pResource.ID) then
								numResource = numResource + pTargetPlot:GetNumResource()
							end
						end
					end
				end
			end
		end
	end

	return numResource
end

function IsCsHasResource(pCs, pResource)
	return (GetCsResourceCount(pCs, pResource) > 0)
end

function GetCsStrategics(pCs)
	local sStrategics = ""
	
	for pResource in GameInfo.Resources() do
		local iResource = pResource.ID

		if (Game.GetResourceUsageType(iResource) == ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC) then
			iAmount = GetCsResourceCount(pCs, pResource)

			if (iAmount > 0) then
				if (sStrategics ~= "") then
					sStrategics = sStrategics .. ", "
				end

				sStrategics = sStrategics .. pResource.IconString .. " [COLOR_POSITIVE_TEXT]" .. iAmount .. "[ENDCOLOR]"
			end
		end
	end

	return sStrategics
end

function GetCsResourceCount(pCs, pResource)
	return pCs:GetNumResourceTotal(pResource.ID, false) + pCs:GetResourceExport(pResource.ID)
end

function OnCivSelected(playerID)
	if (Players[playerID]:IsHuman()) then
		Events.OpenPlayerDealScreenEvent(playerID)
	else
		UI.SetRepeatActionPlayer(playerID)
		UI.ChangeStartDiploRepeatCount(1)
		Players[playerID]:DoBeginDiploWithHuman()
	end
end

function OnCsSelected(iCs)
	local popupInfo = {
		Type = ButtonPopupTypes.BUTTONPOPUP_CITY_STATE_DIPLO,
		Data1 = iCs
	}
		
	Events.SerialEventGameMessagePopup(popupInfo)
end
