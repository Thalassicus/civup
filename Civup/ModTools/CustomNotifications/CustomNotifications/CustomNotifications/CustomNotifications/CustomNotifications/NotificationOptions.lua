--[[
	NotificationOptions.lua
	Creator: alpaca
	Last Change: 17.12.2010
	
	Description: Creates a window for notification options.
]]--

--include("CustomNotification");
include("InstanceManager");
include("AlpacaUtils.lua");
VERBOSITY = 0
include("ModTools.lua")
local log = Events.LuaLogger:New()
log:SetLevel("WARN")

g_NotificationOptionsManager = InstanceManager:new("NotificationOptionInstance", "NotificationOptionRoot", Controls.NOLeftStack);
NotificationSettings = nil
NotificationSettingsForUI = nil
NotificationIDs = nil
NotificationSorting = nil
ModUserData = nil

-- notifications that are invisible for one reason or another
InvisibleNotifications = {
	["NUM_NOTIFICATION_TYPES"] = true,
	["NOTIFICATION_GENERIC"] = true,
	["NOTIFICATION_RELIGION_RACE"] = true,
	["NOTIFICATION_BUY_TILE"] = true,
	["NOTIFICATION_POLICY"] = true,
	["NOTIFICATION_FREE_TECH"] = true,
	["NOTIFICATION_UNIT_PROMOTION"] = true,
	["NOTIFICATION_PRODUCTION"] = true,
	["NOTIFICATION_DIPLO_VOTE"] = true,
	["NOTIFICATION_DISCOVERED_BONUS_RESOURCE"] = true,
	["NOTIFICATION_CITY_TILE"] = true,
	["NOTIFICATION_TECH"] = true,
	["NOTIFICATION_FREE_POLICY"] = true,
	["NOTIFICATION_FREE_GREAT_PERSON"] = true,
}

-- overrides the default setting
DefaultOverrides = Game.CustomNotifications.NotificationOverrides


--[[
	Opens the mod user data to get and set values and stores it in a global variable
]]--
function OpenUserData()
	if ModUserData ~= nil then
		return ModUserData
	end
	local modID = "01127f62-3896-4897-b169-ecab445786cd";
    local modVersion = Modding.GetActivatedModVersion(modID) or 2;
    local modUserData = Modding.OpenUserData(modID, modVersion);
	
	return modUserData
end

--[[
	Initialises the notification settings from user data 
]]--
function InitSettings()
	if NotificationSettings == nil then
		NotificationSettings = {}		
		NotificationSettingsForUI = {}
		NotificationSorting = {}
		NotificationIDs = {}
		Game.NotificationSettings = {}
		Game.NotificationSettings.Settings = NotificationSettingsForUI -- to share with NotificationPanel, we need to use the IDs
		
		-- open user data
		ModUserData = OpenUserData()
		
		local highestUsedID = 0
		
		-- loop through vanilla notifications
		for noKey, noID in pairs(NotificationTypes) do
			if InvisibleNotifications[noKey] == nil then
				--aprint("Adding notification", noKey)
				local data = ModUserData.GetValue(noKey)
				if data == nil then
					if DefaultOverrides[noKey] ~= nil then
						NotificationSettings[noKey] = DefaultOverrides[noKey]
					else
						NotificationSettings[noKey] = true
					end
				else
					NotificationSettings[noKey] = data
				end
				
				if type(NotificationSettings[noKey]) == "number" then
					NotificationSettings[noKey] = NotificationSettings[noKey] > 0
				end
				NotificationSettingsForUI[noID] = NotificationSettings[noKey]
				NotificationSorting[#NotificationSorting + 1] = noID
			end
			NotificationIDs[noID] = noKey
		end
		
		-- loop through custom notifications
		for noKey, noID in pairs(Game.CustomNotifications.NotificationTypes) do
			if InvisibleNotifications[noKey] == nil then
				--aprint("Adding custom notification", noKey)
				if data == nil then
					if DefaultOverrides[noKey] ~= nil then
						NotificationSettings[noKey] = DefaultOverrides[noKey]
					else
						NotificationSettings[noKey] = true
					end
				else
					NotificationSettings[noKey] = data
				end
				
				if type(NotificationSettings[noKey]) == "number" then
					NotificationSettings[noKey] = NotificationSettings[noKey] > 0
				end
				NotificationSettingsForUI[noID] = NotificationSettings[noKey]
				NotificationSorting[#NotificationSorting + 1] = noID
			end
			NotificationIDs[noID] = noKey
		end
	end
end


--[[
	Refresh the window. This loads all notification options with their current values and displays them.
]]--
function RefreshNotificationOptions()
	--aprint("refreshing notification options")
	Controls.MainGrid:SetHide(false)
	--InitSettings()
	g_NotificationOptionsManager:ResetInstances();
	
	for index, id in ipairs(NotificationSorting) do
		local key = NotificationIDs[id]
		local notificationOption = g_NotificationOptionsManager:GetInstance();
		
		local notificationOptionTextButton = notificationOption.NotificationOptionRoot:GetTextButton();
		
		-- fetch text
		
		local localisedText = Locale.ConvertTextKey("TXT_KEY_"..key.."_OPTION");
		
		
		notificationOptionTextButton:SetText(localisedText);
		
		--[[if(option.ToolTip ~= nil) then
			notificationOption.GameOptionRoot:SetToolTipString(option.ToolTip);
		end]]--
		
		--notificationOption.NotificationOptionRoot:SetDisabled(val);
		notificationOption.NotificationOptionRoot:SetCheck(NotificationSettings[key]);
		--aprint("Notification setting for ", key, NotificationSettings[key])
		notificationOption.NotificationOptionRoot:RegisterCheckHandler( function(bCheck)
			options = options or {}
			options[id] = bCheck
		end);
	end
	
	Controls.NOLeftStack:CalculateSize();
	Controls.NOLeftStack:ReprocessAnchoring();
	
	Controls.ScrollPanel1:CalculateInternalSize();
end

function OnCancel()
	UIManager:DequeuePopup( ContextPtr );
	options = nil
end
Controls.CancelButton:RegisterCallback( Mouse.eLClick, OnCancel );

function OnAccept()
	ModUserData = OpenUserData()
	-- check if any settings were changed
	if options ~= nil then
		-- loop through all notification options and store the current value
		for id, val in pairs(options) do
			local key = NotificationIDs[id]
			ModUserData.SetValue(key, val)
			NotificationSettings[key] = val
			NotificationSettingsForUI[id] = val
		end
	end
	UIManager:DequeuePopup( ContextPtr );
end
Controls.AcceptButton:RegisterCallback( Mouse.eLClick, OnAccept );

function ShowHideHandler( bIsHide, bIsInit )
	if bIsInit then
		InitSettings()
	else
		RefreshNotificationOptions()
	end
end
ContextPtr:SetShowHideHandler( ShowHideHandler );

