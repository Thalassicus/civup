--
-- Common logic used by both plot info panels
-- Author: csebal
--

include("EPM_CommonPlotHelpers.lua");
include("AlpacaUtils");

-------------------------------------------------
-- Returns general unit / military information
-- about a plot
-------------------------------------------------
function GetUnitsString(pPlot)
	local strResult = "";
	local bShowBasicHelp = not OptionsManager.IsNoBasicHelp()

	local iActiveTeam = Game.GetActiveTeam();
	local pTeam = Teams[iActiveTeam];
	local bIsDebug = Game.IsDebugMode();
	local bFirstEntry = true;
	
	-- Loop through all units
	local numUnits = pPlot:GetNumUnits();
	for i = 0, numUnits do
		
		local unit = pPlot:GetUnit(i);
		if (unit ~= nil and not unit:IsInvisible(iActiveTeam, bIsDebug)) then

			if (bFirstEntry) then
				bFirstEntry = false;
			else
				strResult = strResult .. "[NEWLINE]";
			end

			local strength = unit:GetBaseCombatStrength();
			local unitInfo = GameInfo.Units[unit:GetUnitType()]
		
			local pPlayer = Players[unit:GetOwner()];
			
			-- Unit Name
			--local strUnitName = unit:GetNameKey();
			--local convertedKey = Locale.ConvertTextKey(strUnitName);
			local convertedKey = unit:GetName();
			--convertedKey = Locale.ToUpper(convertedKey);
			
			-- Player using nickname
			if (pPlayer:GetNickName() ~= nil and pPlayer:GetNickName() ~= "") then
				strResult = strResult .. Locale.ConvertTextKey("TXT_KEY_MULTIPLAYER_UNIT_TT", pPlayer:GetNickName(), Locale.ConvertTextKey(pPlayer:GetCivilizationAdjectiveKey()), convertedKey);
			-- Use civ short description
			else
				strResult = strResult .. Locale.ConvertTextKey("TXT_KEY_PLOTROLL_UNIT_DESCRIPTION_CIV", pPlayer:GetCivilizationAdjectiveKey(), convertedKey);
			end
			
			local unitTeam = unit:GetTeam();
			if iActiveTeam == unitTeam then
				strResult = "[COLOR_WHITE]" .. strResult .. "[ENDCOLOR]";
			elseif pTeam:IsAtWar(unitTeam) then
				strResult = "[COLOR_NEGATIVE_TEXT]" .. strResult .. "[ENDCOLOR]";
			else
				strResult = "[COLOR_POSITIVE_TEXT]" .. strResult .. "[ENDCOLOR]";
			end
			
			-- Debug stuff
			if (OptionsManager:IsDebugMode()) then
				strResult = strResult .. " ("..tostring(unit:GetOwner()).." - " .. tostring(unit:GetID()) .. ")";
			end
			
			-- Embarked
			if (unit:IsEmbarked()) and bShowBasicHelp then
				strResult = strResult .. ", " .. Locale.ConvertTextKey( "TXT_KEY_PLOTROLL_EMBARKED" );
			end
			

			local strStatus = ""

			if iActiveTeam == unitTeam and unitInfo.ExtraMaintenanceCost > 0 and not unitInfo.NoMaintenance then
				strStatus = strStatus .. unitInfo.ExtraMaintenanceCost .. "[ICON_GOLD] ";
			end

			-- Combat strength
			if (strength > 0) and bShowBasicHelp then
				strStatus = strStatus .. unit:GetBaseCombatStrength() .. "[ICON_STRENGTH] ";
			end
			
			-- Movement
			if iActiveTeam == unitTeam and bShowBasicHelp then
				strStatus = strStatus .. Locale.ConvertTextKey("TXT_KEY_HOVERINFO_MOVES", unit:MovesLeft() / GameDefines.MOVE_DENOMINATOR) .. " ";
			end
			
			-- Experience
			if iActiveTeam == unitTeam and unit:IsCombatUnit() or unit:GetDomainType() == DomainTypes.DOMAIN_AIR then
				strStatus = strStatus .. Locale.ConvertTextKey("TXT_KEY_HOVERINFO_EXPERIENCE", Unit_GetXPStored(unit), Unit_GetXPNeeded(unit)) .. " ";
			end
			
			-- Hit Points
			if unit:GetDamage() > 0 then
				strStatus = strStatus .. Locale.ConvertTextKey("TXT_KEY_HOVERINFO_HEALTH", GameDefines["MAX_HIT_POINTS"] - unit:GetDamage()) .. " ";
			end

			if strStatus ~= "" then
				strResult = strResult .. "[NEWLINE]" .. strStatus
			end
			
			-- Building something?
			--if (unit:GetBuildType() ~= -1) then
				--strResult = strResult .. ", " .. Locale.ConvertTextKey(GameInfo.Builds[unit:GetBuildType()].Description);
			--end
		end			
	end	
	
	return strResult;

end

-------------------------------------------------
-- Returns general city / owner information
-- about a plot
-------------------------------------------------
function GetOwnerString(pPlot)
	local strResult = "";
	
	local iActiveTeam = Game.GetActiveTeam();
	local pTeam = Teams[iActiveTeam];
	local bIsDebug = Game.IsDebugMode();
	
	-- City here?
	if (pPlot:IsCity()) then
		
		local pCity = pPlot:GetPlotCity();
		local strAdjectiveKey = Players[pCity:GetOwner()]:GetCivilizationAdjectiveKey();
		
		strResult = Locale.ConvertTextKey("TXT_KEY_CITY_OF", strAdjectiveKey, pCity:GetName());
		
	-- No city, see if this plot is just owned
	else
		
		-- Plot owner
		local iOwner = pPlot:GetRevealedOwner(iActiveTeam, bIsDebug);
		
		if (iOwner >= 0) then
			local pPlayer = Players[iOwner];
			
			-- Player using nickname
			if (pPlayer:GetNickName() ~= nil and pPlayer:GetNickName() ~= "") then
				strResult = Locale.ConvertTextKey("TXT_KEY_PLOTROLL_OWNED_PLAYER", pPlayer:GetNickName());
			-- Use civ short description
			else
				strResult = Locale.ConvertTextKey("TXT_KEY_PLOTROLL_OWNED_CIV", pPlayer:GetCivilizationShortDescriptionKey());
			end
				local iActiveTeam = Game.GetActiveTeam();
				local plotTeam = pPlayer:GetTeam();
				if iActiveTeam == plotTeam then
					strResult = "[COLOR_WHITE]" .. strResult .. "[ENDCOLOR]";
				elseif pTeam:IsAtWar(plotTeam) then
					strResult = "[COLOR_NEGATIVE_TEXT]" .. strResult .. "[ENDCOLOR]";
				else
					strResult = "[COLOR_POSITIVE_TEXT]" .. strResult .. "[ENDCOLOR]";
				end
		end
	end
	
	return strResult;
end

-------------------------------------------------
-- Returns general terrain information
-- about a plot
-------------------------------------------------
function GetNatureString(pPlot)	
	local strResult = ""; -- result string	
	local bFirst = true; -- differentiate betweent he first and subsequent entries in the nature line		
	local bMountain = false; -- mountains and special features (natural wonders) do not display base pPlot type.

	local iFeature = pPlot:GetFeatureType(); -- Get the feature on the pPlot

	-- Features
	if (iFeature > -1) then -- if there is a feature on the pPlot
		if (bFirst) then
			bFirst = false;
		else
			strResult = strResult .. ", ";
		end
			
		-- Block terrian type below natural wonders
		if (GameInfo.Features[iFeature].NaturalWonder) then
			bMountain = true;
		end
									
		strResult = strResult .. csebPlotHelpers_GetPlotFeatureName(pPlot);
	else 
		-- Mountain
		if (pPlot:IsMountain()) then
			if (bFirst) then
				bFirst = false;
			else
				strResult = strResult .. ", ";
			end
				
			bMountain = true;
				
			strResult = strResult .. Locale.ConvertTextKey( "TXT_KEY_PLOTROLL_MOUNTAIN" );
		end
	end
	-- Terrain
	if (not bMountain) then -- we do not display base terrain for mountain type features
		if (bFirst) then
			bFirst = false;
		else
			strResult = strResult .. ", ";
		end
			
		local convertedKey;
			
		-- Lake?
		if (pPlot:IsLake()) then
			convertedKey = Locale.ConvertTextKey( "TXT_KEY_PLOTROLL_LAKE" );
		else
			convertedKey = Locale.ConvertTextKey(GameInfo.Terrains[pPlot:GetTerrainType()].Description);		
		end
			
		strResult = strResult .. convertedKey;
	end
	-- Hills
	if (pPlot:IsHills()) then
		if (bFirst) then
			bFirst = false;
		else
			strResult = strResult .. ", ";
		end
		
		strResult = strResult .. Locale.ConvertTextKey( "TXT_KEY_PLOTROLL_HILL" );
	end
	-- River
	if (pPlot:IsRiver()) then
		if (bFirst) then
			bFirst = false;
		else
			strResult = strResult .. ", ";
		end
		
		strResult = strResult .. Locale.ConvertTextKey( "TXT_KEY_PLOTROLL_RIVER" );
	end
	-- Fresh Water
	if (pPlot:IsFreshWater()) then
		strResult = strResult .. ", [COLOR_POSITIVE_TEXT]" .. Locale.ConvertTextKey( "TXT_KEY_PLOTROLL_FRESH_WATER" ) .. "[ENDCOLOR]";
	end
	
	return strResult;	
end

-------------------------------------------------
-- Returns general improvement information
-- about a plot
-------------------------------------------------
function GetImprovementString(pPlot)

	local strResult = ""; -- result string		
	local iActiveTeam = Game.GetActiveTeam(); -- the ID of the currently active team
	local pTeam = Teams[iActiveTeam]; -- the currently active team

	-- add the improvement already built on this plot
	local iImprovementType = pPlot:GetRevealedImprovementType(iActiveTeam, false); -- get improvement on the pPlot
	if (iImprovementType >= 0) then -- if there is an improvement, display it
		if (strResult ~= "") then
			strResult = strResult .. ", ";
		end

		local improvementInfo = GameInfo.Improvements[iImprovementType]
		local improvementName = Locale.ConvertTextKey(improvementInfo.Description);

		if improvementInfo.BarbarianCamp then
			improvementName = "[COLOR_WARNING_TEXT]" ..improvementName.. "[ENDCOLOR]"
		end

		strResult = strResult .. improvementName;

		if pPlot:IsImprovementPillaged() then -- add text, when it is pillaged.
			strResult = strResult .. " [COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_PLOTROLL_PILLAGED") .. "[ENDCOLOR]";
		end
	end

	-- add the route already built on this plot
	local iRouteType = pPlot:GetRevealedRouteType(iActiveTeam, false); -- get route type on pPlot
	if (iRouteType > -1) then -- if there is a route, display it
		if (strResult ~= "") then
			strResult = strResult .. ", ";
		end
		local convertedKey = Locale.ConvertTextKey(GameInfo.Routes[iRouteType].Description);		
		strResult = strResult .. convertedKey;
		
		if (pPlot:IsRoutePillaged()) then
			strResult = strResult .." [COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_PLOTROLL_PILLAGED") .. "[ENDCOLOR]";
		end
	end

	-- add the improvement being built on this plot
	--[[
	for pBuildInfo in GameInfo.Builds() do -- iterate through all the possible worker actions
		local iTurnsLeft = PlotGetBuildTurnsLeft(pPlot, pBuildInfo.ID);
		-- only process if it is an improvement type and actually has turns left
		if (pBuildInfo.ImprovementType and iTurnsLeft < 4000 and iTurnsLeft > 0) then
			-- only process it, if it isnt already built
			if (GameInfoTypes[ pBuildInfo.ImprovementType ] ~= iImprovementType) then
				if (strResult ~= "") then
					strResult = strResult .. ", ";
				end

				local convertedKey = Locale.ConvertTextKey(GameInfo.Improvements[pBuildInfo.ImprovementType].Description);		
				strResult = strResult .. Locale.ConvertTextKey("TXT_KEY_CSB_PLOTROLL_IMPROVEMENT_UNDER_CONSTRUCTION", convertedKey, iTurnsLeft);
			end
		end
	end

	-- add the route being built on this plot
	for pBuildInfo in GameInfo.Builds() do -- iterate through all the possible worker actions
		local iTurnsLeft = pPlot:GetBuildTurnsLeft(pBuildInfo.ID, 0, 0);
		-- only process if it is an imprvement type and actually has turns left
		if (pBuildInfo.RouteType and iTurnsLeft < 4000 and iTurnsLeft > 0) then
			-- only process it, if it isnt already built
			if (GameInfoTypes[pBuildInfo.RouteType] ~= iRouteType) then

				if (strResult ~= "") then
					strResult = strResult .. ", ";
				end

				local convertedKey = Locale.ConvertTextKey(GameInfo.Routes[pBuildInfo.RouteType].Description);		
				strResult = strResult .. Locale.ConvertTextKey("TXT_KEY_CSB_PLOTROLL_IMPROVEMENT_UNDER_CONSTRUCTION", convertedKey, iTurnsLeft);
			end
		end
	end
	--]]
	
	for i=0, pPlot:GetNumUnits()-1 do
		local iBuildID = pPlot:GetUnit( i ):GetBuildType();
		if iBuildID ~= -1 then
			--local iTurnsLeft = pPlot:GetBuildTurnsLeft(pBuildInfo.ID, 0, 0); -- vanilla version is bugged
			local iTurnsLeft = PlotGetBuildTurnsLeft(pPlot, iBuildID);
				
			if (iTurnsLeft < 4000 and iTurnsLeft >= 0) then
				if (strResult ~= "") then
					strResult = strResult .. ", ";
				end

				local buildInfo = GameInfo.Builds[iBuildID]
				local buildDescription = ""
				if buildInfo.ImprovementType then
					buildDescription = Locale.ConvertTextKey(GameInfo.Improvements[buildInfo.ImprovementType].Description)
				elseif buildInfo.RouteType then
					buildDescription = Locale.ConvertTextKey(GameInfo.Routes[buildInfo.RouteType].Description)
				else
					buildDescription = buildInfo.Description
				end
					
				strResult = strResult .. Locale.ConvertTextKey("TXT_KEY_CSB_PLOTROLL_IMPROVEMENT_UNDER_CONSTRUCTION", buildDescription, iTurnsLeft);
			end
		end
	end
	
	return strResult;
end

-------------------------------------------------
-- Returns quests / tasks given by minor civs
-- if they are related to this plot
-------------------------------------------------
function GetCivStateQuestString(pPlot, bShortVersion)
	local strResult = "";  -- result string	
	local iActivePlayer = Game.GetActivePlayer(); -- the ID of the currently active player
	local iActiveTeam = Game.GetActiveTeam(); -- the ID of the currently active team
	local pTeam = Teams[iActiveTeam]; -- the currently active team
	
	for iPlayerLoop = GameDefines.MAX_MAJOR_CIVS, GameDefines.MAX_CIV_PLAYERS-1, 1 do -- cycle through other players
		pOtherPlayer = Players[iPlayerLoop]; -- the ID of the other player
		iOtherTeam = pOtherPlayer:GetTeam(); -- the ID of the other player's team
			
		if( pOtherPlayer:IsMinorCiv() and iActiveTeam ~= iOtherTeam and pOtherPlayer:IsAlive() and pTeam:IsHasMet( iOtherTeam ) ) then
			-- if the other player is a minor civ, not the currently active player, is still in the game and is in contact with us
			local iQuest      = pOtherPlayer:GetActiveQuestForPlayer(iActivePlayer); -- get quests for the current player
			local iQuestData1 = pOtherPlayer:GetQuestData1(iActivePlayer); -- get quest data (x coord of quest location)
			local iQuestData2 = pOtherPlayer:GetQuestData2(iActivePlayer); -- get quest data (y coord of quest location)
			
			if (iQuest == MinorCivQuestTypes.MINOR_CIV_QUEST_KILL_CAMP and iQuestData1 == pPlot:GetX() and iQuestData2 == pPlot:GetY()) then
				if (strResult ~= "") then
					strResult = strResult .. "[NEWLINE]";
				end
				if (bShortVersion) then
					strResult = strResult .. "[COLOR_POSITIVE_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_CITY_STATE_BARB_QUEST_SHORT") .. "[ENDCOLOR]";
				else				
					strResult = strResult .. "[COLOR_POSITIVE_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_CITY_STATE_BARB_QUEST_LONG",  pOtherPlayer:GetCivilizationShortDescriptionKey()) .. "[ENDCOLOR]";
				end
			end
		end
	end		
	
	return strResult;
end

-------------------------------------------------
-- Returns resource information for any resource
-- located on this plot
-------------------------------------------------
function GetResourceString(pPlot, bShortVersion)
	local strResult = "";
	local iActiveTeam = Game.GetActiveTeam();
	local pTeam = Teams[iActiveTeam];
	local bShowBasicHelp = not OptionsManager.IsNoBasicHelp()
	
	if (pPlot:GetResourceType(iActiveTeam) >= 0) then
		local resourceType = pPlot:GetResourceType(iActiveTeam);
		local pResource = GameInfo.Resources[resourceType];
		
		strResult = strResult .. pResource.IconString .. " "
		if (pPlot:GetNumResource() > 1) then
			strResult = strResult .. "[COLOR_POSITIVE_TEXT]" .. pPlot:GetNumResource() .. "[ENDCOLOR] ";
		end
		strResult = strResult .. Locale.ConvertTextKey(pResource.Description);

		if bShowBasicHelp then
			local strImpList = csebPlotHelpers_GetImprovementListForResource(pPlot, pResource);
			if (strImpList ~= "") then
				strResult = strResult .. " " .. Locale.ConvertTextKey( "TXT_KEY_CSB_PLOTROLL_IMPROVEMENTS_REQUIRED_FOR_RESOURCE", strImpList );
			end
		end

		local iTechCityTrade = GameInfoTypes[pResource.TechCityTrade];
		if (iTechCityTrade ~= nil) then
			if (iTechCityTrade ~= -1 and not pTeam:GetTeamTechs():HasTech(iTechCityTrade)) then
				local techName = Locale.ConvertTextKey(GameInfo.Technologies[iTechCityTrade].Description);

				if bShowBasicHelp then
					strResult = strResult .. "[NEWLINE]"
				else
					strResult = strResult .. " "
				end
				
				if (bShortVersion) then
					strResult = strResult .. Locale.ConvertTextKey( "TXT_KEY_PLOTROLL_REQUIRES_TECH", techName );
				else
					strResult = strResult .. Locale.ConvertTextKey( "TXT_KEY_PLOTROLL_REQUIRES_TECH_TO_USE", techName );
				end
			end
		end
	end
	
	return strResult;	
end

-------------------------------------------------
-- Returns various yield informations 
-- about the plot
-------------------------------------------------
function GetYieldLines(pPlot, bExpanded)
	local strResult			= ""
	local bShowBasicHelp	= not OptionsManager.IsNoBasicHelp()

	-- get current plot yield
	local strCurrentYield = csebPlotHelpers_GetCurrentPlotYieldString(pPlot);

	-- get current plot yield
	if bShowBasicHelp then
		strResult = strResult .. Locale.ConvertTextKey("TXT_KEY_CSB_PLOTROLL_LABEL_YIELDS_ACTUAL", strCurrentYield);
	else
		strResult = strResult .. csebPlotHelpers_GetCurrentPlotYieldString(pPlot);
	end

	-- if the plot has a clearable feature, get the yield after clearing the feature
	local strPlotFeature = csebPlotHelpers_GetPlotFeatureName(pPlot);
	local strYieldWithoutFeature = csebPlotHelpers_GetYieldWithoutFeatureString(pPlot);

	local strExtraInfo = "";

	if (strYieldWithoutFeature ~= "") then
		strExtraInfo = strExtraInfo .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_CSB_PLOTROLL_LABEL_YIELDS_WITHOUTFEATURE", strPlotFeature, strYieldWithoutFeature);
	end

	-- list each item we can build on this plot, along with the yields they provide, if it differs from the base yield
	for pBuildInfo in GameInfo.Builds() do
		local strBuildName = "";
		
		if (pBuildInfo.ImprovementType ~= nil) then
			strBuildName = Locale.ConvertTextKey( GameInfo.Improvements[ pBuildInfo.ImprovementType ].Description );
		end
			
--		if (pBuildInfo.RouteType ~= nil) then
--			strBuildName = Locale.ConvertTextKey( GameInfo.Routes [ pBuildInfo.RouteType ].Description );
--		end
		
		if (strBuildName ~= "" and csebPlotHelpers_HasTechForBuild(pBuildInfo) and csebPlotHelpers_CanBeBuilt(pPlot, pBuildInfo)) then
			local strYieldWithBuild = csebPlotHelpers_GetPlotYieldWithBuild( pPlot, pBuildInfo.ID, true );
			if (strYieldWithBuild ~= "") then
				strExtraInfo = strExtraInfo .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_CSB_PLOTROLL_LABEL_YIELDS_WITHIMPROVEMENT", strBuildName, strYieldWithBuild);
			end
		end
	end

	if (bExpanded or strExtraInfo == "") then -- display expanded version, that also shows the yields
		strResult = strResult .. strExtraInfo;
	else
		if bShowBasicHelp then
			strResult = strResult .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_CSB_PLOTROLL_HELP_PRESS_FOR_MORE");
		end
	end

	return strResult;
end


-------------------------------------------------
-- Returns defensive bonuses / penalties 
-- for the plot
-------------------------------------------------
function GetPlotDefenseString(pPlot)
	local strResult = ""; -- result string
	local iActiveTeam = Game.GetActiveTeam(); -- the ID of the currently active team
	local pTeam = Teams[iActiveTeam]; -- the currently active team

	if pPlot:GetPlotCity() then
		return strResult;
	end

	local iDefensePlotTotal = pPlot:DefenseModifier(pTeam, false);

	if (iDefensePlotTotal ~= 0) then
		strResult = Locale.ConvertTextKey("TXT_KEY_CSB_PLOTROLL_LABEL_DEFENSE_BLOCK_SIMPLE", iDefensePlotTotal)
	end

	return strResult;
end



