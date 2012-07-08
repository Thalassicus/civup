-------------------------------------------------
-- Main Menu
-------------------------------------------------

-------------------------------------------------
-- Script Body
-------------------------------------------------
local bHideUITest = true;
local bHideGridExamples = true;
local bHideLoadGame = true;
local bHidePreGame = true;
local fTime = 0;
local i1, i2 = string.find( UI.GetVersionInfo(), " " );
versionNumber = string.sub(UI.GetVersionInfo(), 1, i2-1);
Controls.VersionNumber:SetText(versionNumber);


function ShowHideHandler( bIsHide, bIsInit )
    if( not bIsHide ) then
        Controls.Civ5Logo:SetTexture( "CivilzationV_Logo.dds" );
        
        -- This is a catch all to ensure that mods are not activated at this point in the UI.
        -- Also, since certain maps and settings will only be available in either the modding or multiplayer
        -- screen, we want to ensure that "safe" settings are loaded that can be used for either SP, MP or Mods.
        -- Activating the DLC (there doesn't have to be any) will make sure no mods are active and all the user's
        -- purchased content is available
		UIManager:SetUICursor( 1 );
        Modding.ActivateDLC();
        PreGame.LoadPreGameSettings();
		UIManager:SetUICursor( 0 );
        -- Look for any cached invite
		UI:CheckForCommandLineInvitation();
    else
        Controls.Civ5Logo:UnloadTexture();
    end
end
ContextPtr:SetShowHideHandler( ShowHideHandler );

-------------------------------------------------
-- Event Handler: ConnectedToNetworkHost
-------------------------------------------------

-------------------------------------------------
-- StartGame Button Handler
-------------------------------------------------
function SinglePlayerClick()
	UIManager:QueuePopup( Controls.SinglePlayerScreen, PopupPriority.SinglePlayerScreen );
end
Controls.SinglePlayerButton:RegisterCallback( Mouse.eLClick, SinglePlayerClick );

-------------------------------------------------
-- Multiplayer Button Handler
-------------------------------------------------
function MultiplayerClick()
    UIManager:QueuePopup( Controls.MultiplayerSelectScreen, PopupPriority.MultiplayerSelectScreen );
end
Controls.MultiplayerButton:RegisterCallback( Mouse.eLClick, MultiplayerClick );


-------------------------------------------------
-- Mods button handler
-------------------------------------------------
function ModsButtonClick()
	--UIManager:QueuePopup( Controls.ModsEULAScreen, PopupPriority.ModsEULAScreen );
    UIManager:QueuePopup( Controls.ModsMenu, PopupPriority.ModsMenu );
end
Controls.ModsButton:RegisterCallback( Mouse.eLClick, ModsButtonClick );


-------------------------------------------------
-- UITest Button Handler
-------------------------------------------------
--[[
function UITestRClick()
    bHideUITest = not bHideUITest;
    Controls.UITestScreen:SetHide( bHideUITest );
end
Controls.OptionsButton:RegisterCallback( Mouse.eRClick, UITestRClick );
--]]


-------------------------------------------------
-- Options Button Handler
-------------------------------------------------
function OptionsClick()
    UIManager:QueuePopup( Controls.OptionsMenu_FrontEnd, PopupPriority.OptionsMenu );
end
Controls.OptionsButton:RegisterCallback( Mouse.eLClick, OptionsClick );


-------------------------------------------------
-- Hall Of Fame Button Handler
-------------------------------------------------
function OtherClick()
    UIManager:QueuePopup( Controls.Other, PopupPriority.OtherMenu );
end
Controls.OtherButton:RegisterCallback( Mouse.eLClick, OtherClick );


-------------------------------------------------
-- Exit Button Handler
-------------------------------------------------
function OnExitGame()
	Events.UserRequestClose();
end
Controls.ExitButton:RegisterCallback( Mouse.eLClick, OnExitGame );


----------------------------------------------------------------        
----------------------------------------------------------------
Steam.SetOverlayNotificationPosition( "bottom_left" );

-------------------------------------------------
-- Event Handler: MultiplayerGameLaunched
-------------------------------------------------
function OnGameLaunched()

	UIManager:DequeuePopup( ContextPtr );

end
Events.MultiplayerGameLaunched.Add( OnGameLaunched );


-- Returns -1 if time1 < time2, 0 if equal, 1 if time1 > time 2
function CompareTime(time1, time2)
	
	--First, convert the table into a single numerical value
	-- YYYYMMDDHH
	function convert(t)
		local r = 0;
		if(t.year ~= nil) then
			r = r + t.year * 1000000
		end
		
		if(t.month ~= nil) then
			r = r + t.month * 10000
		end
		
		if(t.day ~= nil) then
			r = r + t.day * 100
		end
		
		if(t.hour ~= nil) then
			r = r + t.hour;
		end
		
		return r;
	end
	
	local ct1 = convert(time1);
	local ct2 = convert(time2);
	
	if(ct1 < ct2) then
		return -1;
	elseif(ct1 > ct2) then
		return 1;
	else
		return 0;
	end
end

function DisplayDLCButtons()
	local ButtonsDisplayUntil = {

		[Controls.CivWorldButton] = {
			start = {
				month = 7,
				day = 11,
				year = 2011,
				hour = 10,
			},
			
			stop = {
				year = 2011,
				month = 8, 
				day = 10,
				hour = 17,
			},
			
			customurl = "http://apps.facebook.com/civworld?kt_type=partner&kt_st1=civ_v_pc_link&kt_st2=civ_v_cross_promote&kt_st3=pc_sku",
		},
		
		[Controls.KoreaDLCButton] = {
			start = {
				month = 8,
				day = 11,
				year = 2011,
				hour = 17,
			},
			
			stop = {
				year = 2011,
				month = 9, 
				day = 10,
				hour = 17,
			},
		},
	}

	local currentDate = os.date("!*t");

	for k,v in pairs(ButtonsDisplayUntil) do
		local bShow = false;
		
		if(CompareTime(currentDate, v.start) >= 0 and CompareTime(v.stop, currentDate) >= 0) then
			bShow = true;
		end
		
		
		k:SetHide(not bShow);
		
		k:RegisterCallback(Mouse.eLClick, function()
			if(v.customurl == nil) then
				Steam.ActivateGameOverlayToStore();
			else
				Steam.ActivateGameOverlayToWebPage(v.customurl);
			end
		end);
	end
end

DisplayDLCButtons();

----------------------------------------------------------------        
function OnExpansionRulesSwitch()
	UIManager:QueuePopup( Controls.PremiumContentScreen, PopupPriority.OtherMenu );
end		
Controls.ExpansionRulesSwitch:RegisterCallback(Mouse.eLClick, OnExpansionRulesSwitch);	