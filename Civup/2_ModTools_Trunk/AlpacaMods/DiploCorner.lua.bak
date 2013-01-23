-------------------------------------------------
-- Diplomacy and Advisors Buttons that float out in the screen
-------------------------------------------------
include("IconSupport");
include("SupportFunctions");
include("InstanceManager");
local g_ChatInstances = {};

local g_iChatTeam   = -1;
local g_iChatPlayer = -1;

local g_iLocalPlayer = Game.GetActivePlayer();
local g_pLocalPlayer = Players[ g_iLocalPlayer ];
local g_iLocalTeam = g_pLocalPlayer:GetTeam();
local g_pLocalTeam = Teams[ g_iLocalTeam ];
local g_SortTable;
        

local m_bChatOpen = not Controls.ChatPanel:IsHidden();


-------------------------------------------------
-------------------------------------------------
local g_MultiPullInfo = {};
g_MultiPullInfo[0] = { text="TXT_KEY_ADVISOR_SCREEN_TECH_TREE_DISPLAY",        call=function() Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_TECH_TREE } ); end };
g_MultiPullInfo[1] = { text="TXT_KEY_DIPLOMACY_OVERVIEW",        call=function() Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_DIPLOMATIC_OVERVIEW } ); end };
g_MultiPullInfo[2] = { text="TXT_KEY_MILITARY_OVERVIEW",         call=function() Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_MILITARY_OVERVIEW } ); end };
g_MultiPullInfo[3] = { text="TXT_KEY_ECONOMIC_OVERVIEW",         call=function() Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_ECONOMIC_OVERVIEW } ); end };
g_MultiPullInfo[4] = { text="TXT_KEY_VP_TT",                     call=function() Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_VICTORY_INFO} ); end };
g_MultiPullInfo[5] = { text="TXT_KEY_DEMOGRAPHICS",              call=function() Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_DEMOGRAPHICS} ); end };
g_MultiPullInfo[6] = { text="TXT_KEY_POP_NOTIFICATION_LOG",      call=function() Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_NOTIFICATION_LOG, Data1 = Game.GetActivePlayer() } ); end };
--alpaca
function meh(tab)
	g_MultiPullInfo[#g_MultiPullInfo + 1] = tab
end
LuaEvents.DiploCornerAddin.Add(meh)

addins = {}
-- handle DiploCornerAddins
for addin in Modding.GetActivatedModEntryPoints("DiploCornerAddin") do
	local addinFile = addin.File;
	-- Get the absolute path and filename without extension.
	local extension = Path.GetExtension(addinFile);
	local path = string.sub(addinFile, 1, #addinFile - #extension);
	ptr = ContextPtr:LoadNewContext(path)
	table.insert(addins, ptr)
end

--/alpaca

local controlTable;
for i = 0, #g_MultiPullInfo do
    controlTable = {};
    Controls.MultiPull:BuildEntry( "InstanceOne", controlTable );

    controlTable.Button:LocalizeAndSetText( g_MultiPullInfo[i].text );
    controlTable.Button:LocalizeAndSetToolTip( g_MultiPullInfo[i].tip );
    controlTable.Button:SetVoid1( i );
end
Controls.MultiPull:CalculateInternals();


-------------------------------------------------
-------------------------------------------------
function OnMultiPull( id )
    g_MultiPullInfo[id].call();
end
Controls.MultiPull:RegisterSelectionCallback( OnMultiPull );


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
function ShowHideHandler( bIsHide )
    Controls.CornerAnchor:SetHide( false );
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
