-- Clock
-- Author: Attila
-- DateCreated: 2010-10-02 09:04:41 AM
--------------------------------------------------------------
--Clock from AgentofEvil

TimeFormats = {}
TimeFormats[12] = "%I:%M";
TimeFormats[24] = "%H:%M";


ModID		= "ddbb4126-9f1a-4f02-be52-28e1578e9389";
ModVersion	= Modding.GetActivatedModVersion(ModID) or 2;
ModUserData = Modding.OpenUserData(ModID, ModVersion);

local CurrentTimeFormatIndex = ModUserData.GetValue("TimeFormat") or 12;			

ContextPtr:SetUpdate(function ()
	local computersystime = os.date(TimeFormats[CurrentTimeFormatIndex]);
	Controls.TopPanelClock:SetText(computersystime);
end);

function ToggleTimeFormat()
	CurrentTimeFormatIndex = ((CurrentTimeFormatIndex + 11) % 24) + 1;
	ModUserData.SetValue("TimeFormat", CurrentTimeFormatIndex)
end;

Controls.TopPanelClock:RegisterCallback( Mouse.eLClick, ToggleTimeFormat );
