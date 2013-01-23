print("This is the 'Utils - Modular DiploCorner' mod script.")

local isGandK = (GameInfoTypes.UNITCOMBAT_NAVALMELEE ~= nil)

-------------------------------------------------
-- Diplomacy and Advisors Buttons that float out in the screen
-------------------------------------------------
include( "IconSupport" );
include( "SupportFunctions"  );
include( "InstanceManager" );
local g_ChatInstances = {};

local g_iChatTeam   = -1;
local g_iChatPlayer = -1;

local g_iLocalPlayer = Game.GetActivePlayer();
local g_pLocalPlayer = Players[ g_iLocalPlayer ];
local g_iLocalTeam = g_pLocalPlayer:GetTeam();
local g_pLocalTeam = Teams[ g_iLocalTeam ];      

local m_bChatOpen = not Controls.ChatPanel:IsHidden();


-------------------------------------------------
-------------------------------------------------


-------------------------------------------------
----- MODS START -----
-------------------------------------------------
function Popup(popupType, data1, data2)
  Events.SerialEventGameMessagePopup{ 
    Type = popupType,
    Data1 = data1,
    Data2 = data2
  };
end

-- Convert the standard list of pull-down entries into a "list of lists" that we can index by name
local g_MultiPullIndexes = {tech=1, diplomatic=2, military=3, economic=4, victory=5, demographics=6, logs=7, other=8};
local g_MultiPullInfo = {
  {{text="TXT_KEY_ADVISOR_SCREEN_TECH_TREE_DISPLAY", call=function() Popup(ButtonPopupTypes.BUTTONPOPUP_TECH_TREE, nil, -1); end}},
  {{text="TXT_KEY_DIPLOMACY_OVERVIEW",               call=function() Popup(ButtonPopupTypes.BUTTONPOPUP_DIPLOMATIC_OVERVIEW); end}},
  {{text="TXT_KEY_MILITARY_OVERVIEW",                call=function() Popup(ButtonPopupTypes.BUTTONPOPUP_MILITARY_OVERVIEW); end}},
  {{text="TXT_KEY_ECONOMIC_OVERVIEW",                call=function() Popup(ButtonPopupTypes.BUTTONPOPUP_ECONOMIC_OVERVIEW); end}},
  {{text="TXT_KEY_VP_TT",                            call=function() Popup(ButtonPopupTypes.BUTTONPOPUP_VICTORY_INFO); end}},
  {{text="TXT_KEY_DEMOGRAPHICS",                     call=function() Popup(ButtonPopupTypes.BUTTONPOPUP_DEMOGRAPHICS); end}},
  {{text="TXT_KEY_POP_NOTIFICATION_LOG",             call=function() Popup(ButtonPopupTypes.BUTTONPOPUP_NOTIFICATION_LOG, Game.GetActivePlayer()); end}},
  {} -- The (initially empty) catch-all "other" section
};


-------------------------------------------------
-------------------------------------------------
local g_MultiPullCallbacks = {};

function OnMultiPull(id)
    g_MultiPullCallbacks[id]();
end
Controls.MultiPull:RegisterSelectionCallback(OnMultiPull);


-------------------------------------------------
-------------------------------------------------
-- This method refreshes the entries that are in the additional information dropdown.
-- Modders can use the Lua event "AdditionalInformationDropdownGatherEntries" to 
-- add entries to the list.
function RefreshAdditionalInformationEntries()
  LuaEvents.DiploCornerExtended()

  local additionalEntries = {}

	-- Obtain any modder/dlc entries.
	LuaEvents.AdditionalInformationDropdownGatherEntries(additionalEntries);
	
	-- Now that we have all entries, call methods to sort them
	LuaEvents.AdditionalInformationDropdownSortEntries(additionalEntries);

	 Controls.MultiPull:ClearEntries();

  g_MultiPullCallbacks = {}
  local i = 1;

  -- process the "list of lists" into a single pull-down
  for iGroup = 1, #g_MultiPullInfo, 1 do
    for _, tab in ipairs(g_MultiPullInfo[iGroup]) do
      local controlTable = {};
      Controls.MultiPull:BuildEntry("InstanceOne", controlTable);

      controlTable.Button:LocalizeAndSetText(tab.text);
      controlTable.Button:LocalizeAndSetToolTip(tab.tip);
      controlTable.Button:SetVoid1(i);

      -- we only get an integer key for the selected item, so store a flattened list of callbacks
      g_MultiPullCallbacks[i] = tab.call
      i = i + 1
    end
  end

  -- add in the additional entries
  for _, tab in ipairs(additionalEntries) do
    local controlTable = {};
    Controls.MultiPull:BuildEntry("InstanceOne", controlTable);

    controlTable.Button:LocalizeAndSetText(tab.text);
    controlTable.Button:LocalizeAndSetToolTip(tab.tip);
    controlTable.Button:SetVoid1(i);

    -- we only get an integer key for the selected item, so store a flattened list of callbacks
    g_MultiPullCallbacks[i] = tab.call
    i = i + 1
  end

	-- STYLE HACK
	-- The grid has a nice little footer that will overlap entries if it is not resized to be larger than everything else.
	Controls.MultiPull:CalculateInternals();
	local dropDown = Controls.MultiPull;
	local width, height = dropDown:GetGrid():GetSizeVal();
	dropDown:GetGrid():SetSizeVal(width, height+100);
end
LuaEvents.RequestRefreshAdditionalInformationDropdownEntries.Add(RefreshAdditionalInformationEntries);


-------------------------------------------------
-------------------------------------------------
function OnDiploCornerAddin(tab)
  local sGroup = tab.group or "other"
  local iIndex = g_MultiPullIndexes[sGroup] or g_MultiPullIndexes.other

  -- print(string.format("Adding %s to group %s", Locale.ConvertTextKey(tab.text), sGroup))
  table.insert(g_MultiPullInfo[iIndex], tab)
end
LuaEvents.DiploCornerAddin.Add(OnDiploCornerAddin)


addins = {}
-- handle DiploCornerAddins
for addin in Modding.GetActivatedModEntryPoints("DiploCornerAddin") do
	local addinFile = addin.File;
	local extension = Path.GetExtension(addinFile);
	local path = string.sub(addinFile, 1, #addinFile - #extension);
	ptr = ContextPtr:LoadNewContext(path)
	table.insert(addins, ptr)
end
RefreshAdditionalInformationEntries()


-------------------------------------------------
----- MODS END -----
-------------------------------------------------

-------------------------------------------------
-------------------------------------------------
function SortAdditionalInformationDropdownEntries(entries)
	table.sort(entries, function(a,b)
		return (Locale.Compare(a.text, b.text) == -1);
	end);
end
LuaEvents.AdditionalInformationDropdownSortEntries.Add(SortAdditionalInformationDropdownEntries);

-------------------------------------------------
-------------------------------------------------
function OnAdvisorButton()
    local popupInfo = {
        Type = ButtonPopupTypes.BUTTONPOPUP_ADVISOR_COUNSEL,
    }
    Events.SerialEventGameMessagePopup(popupInfo);

end
Controls.AdvisorButton:RegisterCallback( Mouse.eLClick, OnAdvisorButton );


-------------------------------------------------
-------------------------------------------------
function OnAdvisorButtonR()
    LuaEvents.AdvisorButtonEvent( Mouse.eRClick );
end
Controls.AdvisorButton:RegisterCallback( Mouse.eRClick, OnAdvisorButtonR );

function OnEspionageButton()
	Events.SerialEventGameMessagePopup{ 
		Type = ButtonPopupTypes.BUTTONPOPUP_ESPIONAGE_OVERVIEW,
	};
end
-- MOVED TO THE END - Controls.EspionageButton:RegisterCallback(Mouse.eLClick, OnEspionageButton);

-------------------------------------------------
-- On ChatToggle
-------------------------------------------------
function OnChatToggle()

    m_bChatOpen = not m_bChatOpen;

    if( m_bChatOpen ) then
        Controls.ChatPanel:SetHide( false );
        Controls.ChatToggle:SetTexture( "assets/UI/Art/Icons/MainChatOn.dds" );
        Controls.HLChatToggle:SetTexture( "assets/UI/Art/Icons/MainChatOffHL.dds" );
        Controls.MOChatToggle:SetTexture( "assets/UI/Art/Icons/MainChatOff.dds" );
    else
        Controls.ChatPanel:SetHide( true );
        Controls.ChatToggle:SetTexture( "assets/UI/Art/Icons/MainChatOff.dds" );
        Controls.HLChatToggle:SetTexture( "assets/UI/Art/Icons/MainChatOnHL.dds" );
        Controls.MOChatToggle:SetTexture( "assets/UI/Art/Icons/MainChatOn.dds" );
    end

    LuaEvents.ChatShow( m_bChatOpen );
end
Controls.ChatToggle:RegisterCallback( Mouse.eLClick, OnChatToggle );


-------------------------------------------------
-------------------------------------------------
local bFlipper = false;
function OnChat( fromPlayer, toPlayer, text, eTargetType )

    local controlTable = {};
    ContextPtr:BuildInstanceForControl( "ChatEntry", controlTable, Controls.ChatStack );
  
    table.insert( g_ChatInstances, controlTable );
    if( #g_ChatInstances > 100 ) then
        Controls.ChatStack:ReleaseChild( g_ChatInstances[ 1 ].Box );
        table.remove( g_ChatInstances, 1 );
    end
    
    TruncateString( controlTable.String, 200, Players[fromPlayer]:GetNickName() );
    local fromName = controlTable.String:GetText();
    
    if( eTargetType == ChatTargetTypes.CHATTARGET_TEAM ) then
        controlTable.String:SetColorByName( "Green_Chat" );
        controlTable.String:SetText( fromName .. ": " .. text ); 
        
    elseif( eTargetType == ChatTargetTypes.CHATTARGET_PLAYER ) then
    
        local toName;
        if( toPlayer == g_iLocalPlayer ) then
            toName = Locale.ConvertTextKey( "TXT_KEY_YOU" );
        else
            TruncateString( controlTable.String, 200, Players[toPlayer]:GetNickName() );
            toName = Locale.ConvertTextKey( "TXT_KEY_DIPLO_TO_PLAYER", controlTable.String:GetText() );
        end
        controlTable.String:SetText( fromName .. " (" .. toName .. "): " .. text ); 
        controlTable.String:SetColorByName( "Magenta_Chat" );
        
    elseif( fromPlayer == g_iLocalPlayer ) then
        controlTable.String:SetColorByName( "Gray_Chat" );
        
        controlTable.String:SetText( fromName .. ": " .. text ); 
    else
        controlTable.String:SetText( fromName .. ": " .. text ); 
    end
      
    controlTable.Box:SetSizeY( controlTable.String:GetSizeY() + 8 );
    controlTable.Box:ReprocessAnchoring();

    if( bFlipper ) then
        controlTable.Box:SetColorChannel( 3, 0.4 );
    end
    bFlipper = not bFlipper;
    
	Events.AudioPlay2DSound( "AS2D_IF_MP_CHAT_DING" );		

    Controls.ChatStack:CalculateSize();
    Controls.ChatScroll:CalculateInternalSize();
    Controls.ChatScroll:SetScrollValue( 1 );
end
Events.GameMessageChat.Add( OnChat );


-------------------------------------------------
-------------------------------------------------
function SendChat( text )
    if( string.len( text ) > 0 ) then
        Network.SendChat( text, g_iChatTeam, g_iChatPlayer );
    end
    Controls.ChatEntry:ClearString();
end
Controls.ChatEntry:RegisterCallback( SendChat );

-------------------------------------------------
-------------------------------------------------
function ShowHideInviteButton()
	local bShow = Matchmaking.IsHost() and PreGame.IsInternetGame();
	Controls.MPInvite:SetHide( not bShow );
end

-------------------------------------------------
-- On MPInvite
-------------------------------------------------
function OnMPInvite()
    Steam.ActivateInviteOverlay();	
end
Controls.MPInvite:RegisterCallback( Mouse.eLClick, OnMPInvite );

----------------------------------------------------------------
----------------------------------------------------------------
function OnPlayerDisconnect( playerID )
    if( ContextPtr:IsHidden() == false ) then
    	ShowHideInviteButton();
	end
end
Events.MultiplayerGamePlayerDisconnected.Add( OnPlayerDisconnect );

-------------------------------------------------
-------------------------------------------------
function ShowHideHandler( bIsHide )
    Controls.CornerAnchor:SetHide( false );
    
    if(not bIsHide) then
		ShowHideInviteButton();
		LuaEvents.RequestRefreshAdditionalInformationDropdownEntries();
    end
end
ContextPtr:SetShowHideHandler( ShowHideHandler );

-------------------------------------------------
-------------------------------------------------
function InputHandler( uiMsg, wParam, lParam )
    if( m_bChatOpen 
        and uiMsg == KeyEvents.KeyUp
        and wParam == Keys.VK_TAB ) then
        Controls.ChatEntry:TakeFocus();
        return true;
    end
end
ContextPtr:SetInputHandler( InputHandler );


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function OnSocialPoliciesClicked()
    Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_CHOOSEPOLICY } );
end
Controls.SocialPoliciesButton:RegisterCallback( Mouse.eLClick, OnSocialPoliciesClicked );


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function OnDiploClicked()
    Controls.DiploList:SetHide( not Controls.DiploList:IsHidden() );
    -- Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_DIPLOMACY } );
end
Controls.DiploButton:RegisterCallback( Mouse.eLClick, OnDiploClicked );


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function OnOpenPlayerDealScreen( iOtherPlayer )
    local iUs = Game.GetActivePlayer();
    local iUsTeam = Players[ iUs ]:GetTeam();
    local pUsTeam = Teams[ iUsTeam ];

    -- any time we're legitimately opening the pvp deal screen, make sure we hide the diplolist.
    local iOtherTeam = Players[iOtherPlayer]:GetTeam();
    local iProposalTo = UI.HasMadeProposal( iUs );
   
    -- this logic should match OnOpenPlayerDealScreen in TradeLogic.lua
    if( (pUsTeam:IsAtWar( iOtherTeam ) and (g_bAlwaysWar or g_bNoChangeWar) ) or
	    (iProposalTo ~= -1 and iProposalTo ~= iOtherPlayer) ) then
	    -- do nothing
	    return;
    else
        Controls.CornerAnchor:SetHide( true );
    end

end
Events.OpenPlayerDealScreenEvent.Add( OnOpenPlayerDealScreen );


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function OnChatTarget( iTeam, iPlayer )
    g_iChatTeam = iTeam;
    g_iChatPlayer = iPlayer;

    if( iTeam ~= -1 ) then
		TruncateString( Controls.LengthTest, Controls.ChatPull:GetSizeX(), Locale.ConvertTextKey("TXT_KEY_DIPLO_TO_TEAM"));
        Controls.ChatPull:GetButton():SetText( Controls.LengthTest:GetText() );
    else
        if( iPlayer ~= -1 ) then
			TruncateString( Controls.LengthTest, Controls.ChatPull:GetSizeX(), Locale.ConvertTextKey("TXT_KEY_DIPLO_TO_PLAYER", Players[ iPlayer ]:GetNickName()));
            Controls.ChatPull:GetButton():SetText( Controls.LengthTest:GetText() );
        else
            Controls.ChatPull:GetButton():LocalizeAndSetText( "TXT_KEY_DIPLO_TO_ALL" );
        end
    end
end
Controls.ChatPull:RegisterSelectionCallback( OnChatTarget );


-------------------------------------------------------
-------------------------------------------------------
function PopulateChatPull()

    Controls.ChatPull:ClearEntries();

    -------------------------------------------------------
    -- Add All Entry
    local controlTable = {};
    Controls.ChatPull:BuildEntry( "InstanceOne", controlTable );
    controlTable.Button:SetVoids( -1, -1 );
    local textControl = controlTable.Button:GetTextControl();
    textControl:LocalizeAndSetText( "TXT_KEY_DIPLO_TO_ALL" );


    -------------------------------------------------------
    -- See if Team has more than 1 other human member
    local iTeamCount = 0;
    for iPlayer = 0, GameDefines.MAX_PLAYERS do
        local pPlayer = Players[iPlayer];

        if( iPlayer ~= g_iLocalPlayer and pPlayer ~= nil and pPlayer:IsHuman() and pPlayer:GetTeam() == g_iLocalTeam ) then
            iTeamCount = iTeamCount + 1;
        end
    end

    if( iTeamCount > 0 ) then
        local controlTable = {};
        Controls.ChatPull:BuildEntry( "InstanceOne", controlTable );
        controlTable.Button:SetVoids( g_iLocalTeam, -1 );
        local textControl = controlTable.Button:GetTextControl();
        textControl:LocalizeAndSetText( "TXT_KEY_DIPLO_TO_TEAM" );
    end


    -------------------------------------------------------
    -- Humans
    for iPlayer = 0, GameDefines.MAX_PLAYERS do
        local pPlayer = Players[iPlayer];

        if( iPlayer ~= g_iLocalPlayer and pPlayer ~= nil and pPlayer:IsHuman() ) then

            controlTable = {};
            Controls.ChatPull:BuildEntry( "InstanceOne", controlTable );
            controlTable.Button:SetVoids( -1, iPlayer );
            textControl = controlTable.Button:GetTextControl();
			TruncateString( textControl, Controls.ChatPull:GetSizeX()-20, Locale.ConvertTextKey("TXT_KEY_DIPLO_TO_PLAYER", pPlayer:GetNickName()));
        end
    end
    
    Controls.ChatPull:GetButton():LocalizeAndSetText( "TXT_KEY_DIPLO_TO_ALL" );
    Controls.ChatPull:CalculateInternals();
end


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function DoUpdateUNCountdown()
	
	local iUNCountdown = Game.GetUnitedNationsCountdown();
	
	if (iUNCountdown ~= 0 and Game.GetGameState() == GameplayGameStateTypes.GAMESTATE_ON ) then
		Controls.UNTurnsLabel:SetText(iUNCountdown);
		Controls.UNTurnsLabel:SetHide(false);
		Controls.DiploButton:SetToolTipString(Locale.ConvertTextKey("TXT_KEY_EO_DIPLOMACY_AND_UN_VOTE", iUNCountdown));
	else
		Controls.UNTurnsLabel:SetHide(true)
		Controls.DiploButton:SetToolTipString(Locale.ConvertTextKey("TXT_KEY_EO_DIPLOMACY"));
	end
end
Events.SerialEventGameDataDirty.Add(DoUpdateUNCountdown);

-- Also call it once so it starts correct - surprisingly enough, GameData isn't dirtied as we're loading a game
DoUpdateUNCountdown();

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function DoUpdateEspionageButton()
	local iLocalPlayer = Game.GetActivePlayer();
	local pLocalPlayer = Players[iLocalPlayer];
	local iNumUnassignedSpies = pLocalPlayer:GetNumUnassignedSpies();
	
	local strToolTip = Locale.ConvertTextKey("TXT_KEY_EO_TITLE");
	
	if (iNumUnassignedSpies > 0) then
		strToolTip = strToolTip .. "[NEWLINE][NEWLINE]";
		strToolTip = strToolTip .. Locale.ConvertTextKey("TXT_KEY_EO_UNASSIGNED_SPIES_TT", iNumUnassignedSpies);
		Controls.UnassignedSpiesLabel:SetHide(false);
		Controls.UnassignedSpiesLabel:SetText(iNumUnassignedSpies);
	else
		Controls.UnassignedSpiesLabel:SetHide(true);
	end
	
	Controls.EspionageButton:SetToolTipString(strToolTip);
end
-- MOVED TO THE END - Events.SerialEventEspionageScreenDirty.Add(DoUpdateEspionageButton);

--------------------------------------------------------------------
function HandleNotificationAdded(notificationId, notificationType, toolTip, summary, gameValue, extraGameData)
	
	-- In the event we receive a new spy, make sure the large button is displayed.
	if(ContextPtr:IsHidden() == false) then
		if(notificationType == NotificationTypes.NOTIFICATION_SPY_CREATED_ACTIVE_PLAYER) then
			CheckEspionageStarted();
		end
	end
end
-- MOVED TO THE END - Events.NotificationAdded.Add(HandleNotificationAdded);

-- MOVED TO THE END - DoUpdateEspionageButton();

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
if( Game.IsGameMultiPlayer() ) then
    PopulateChatPull();

	if ( not Game.IsHotSeat() ) then
		Controls.ChatToggle:SetHide( false );
		OnChatToggle();
	end
end


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function OnEndGameButton()

    local which = math.random( 1, 6 );
    
    if( which == 1 ) then Events.EndGameShow( EndGameTypes.Technology, Game.GetActivePlayer() ); 
    elseif( which == 2 ) then Events.EndGameShow( EndGameTypes.Domination, Game.GetActivePlayer() );
    elseif( which == 3 ) then Events.EndGameShow( EndGameTypes.Culture, Game.GetActivePlayer() );
    elseif( which == 4 ) then Events.EndGameShow( EndGameTypes.Diplomatic, Game.GetActivePlayer() );
    elseif( which == 5 ) then Events.EndGameShow( EndGameTypes.Time, Game.GetActivePlayer() );
    elseif( which == 6 ) then Events.EndGameShow( EndGameTypes.Time, Game.GetActivePlayer() + 1 ); 
    end
end
Controls.EndGameButton:RegisterCallback( Mouse.eLClick, OnEndGameButton );

local g_PerPlayerState = {};
----------------------------------------------------------------
-- 'Active' (local human) player has changed
----------------------------------------------------------------
function OnDiploCornerActivePlayerChanged( iActivePlayer, iPrevActivePlayer )
	-- Restore the state per player
	local bIsHidden = Controls.DiploList:IsHidden() == true;
	-- Save the state per player
	if (iPrevActivePlayer ~= -1) then
		g_PerPlayerState[ iPrevActivePlayer + 1 ] = bIsHidden;
	end
	
	if (iActivePlayer ~= -1) then
		if (g_PerPlayerState[ iActivePlayer + 1 ] == nil or g_PerPlayerState[ iActivePlayer + 1 ] == -1) then
			Controls.DiploList:SetHide( true );
		else
			local bWantHidden = g_PerPlayerState[ iActivePlayer + 1 ];
			if ( bWantHidden ~= Controls.DiploList:IsHidden()) then
				Controls.DiploList:SetHide( bWantHidden );
			end
		end
	end

	g_iLocalPlayer = Game.GetActivePlayer();
	g_pLocalPlayer = Players[ g_iLocalPlayer ];
	g_iLocalTeam = g_pLocalPlayer:GetTeam();
	g_pLocalTeam = Teams[ g_iLocalTeam ];
	PopulateChatPull();
end
Events.GameplaySetActivePlayer.Add(OnDiploCornerActivePlayerChanged);


function CheckEspionageStarted()
	function TestEspionageStarted()
		local player = Players[Game.GetActivePlayer()];
		return player:GetNumSpies() > 0;
	end

	local bEspionageStarted = TestEspionageStarted();
	Controls.CornerAnchor:SetHide(bEspionageStarted);
	Controls.CornerAnchor_Espionage:SetHide(not bEspionageStarted);
	Controls.EspionageButton:SetHide(not bEspionageStarted);
	if(bEspionageStarted) then
		DoUpdateEspionageButton();
	end
end

function OnActivePlayerTurnStart()
	CheckEspionageStarted();
	
end
-- MOVED TO THE END - Events.ActivePlayerTurnStart.Add(OnActivePlayerTurnStart);


if (isGandK) then
  Controls.EspionageButton:RegisterCallback(Mouse.eLClick, OnEspionageButton);
  Events.SerialEventEspionageScreenDirty.Add(DoUpdateEspionageButton);
  Events.NotificationAdded.Add(HandleNotificationAdded);
  DoUpdateEspionageButton();
  Events.ActivePlayerTurnStart.Add(OnActivePlayerTurnStart);

  OnActivePlayerTurnStart();
end
