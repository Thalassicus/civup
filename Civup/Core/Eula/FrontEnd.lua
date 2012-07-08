-------------------------------------------------
-- FrontEnd
-------------------------------------------------

function ShowHideHandler( bIsHide, bIsInit )

    --if( not UI:HasShownLegal() ) then
	if( false ) then
        UIManager:QueuePopup( Controls.LegalScreen, PopupPriority.LegalScreen );
    end

    if( not bIsHide ) then
    	UIManager:SetUICursor( 0 );
        UIManager:QueuePopup( Controls.MainMenu, PopupPriority.MainMenu );
        Controls.AtlasLogo:SetTexture( "CivilzationVAtlas.dds" );
    else
        Controls.AtlasLogo:UnloadTexture();
    end
end
ContextPtr:SetShowHideHandler( ShowHideHandler );
