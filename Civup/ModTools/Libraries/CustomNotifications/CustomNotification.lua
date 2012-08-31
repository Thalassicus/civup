--[[
	CustomNotification.lua
	Creator: alpaca
	Last Change: 20.12.2010
	
	Description: Adds support for the city growth and culture tile spread notifications to the game
]]--

include("AlpacaUtils.lua")
VERBOSITY = 0
include("ModTools.lua")
local log = Events.LuaLogger:New()
log:SetLevel("WARN")

include("FLuaVector");--HighlightColors
include("IconSupport");--IconHookups
include("InstanceManager");--Popups

customNotifications = {}

customInstances = {}

--------------------------------------------------------
-- Add Custom Notification
--------------------------------------------------------

function addCustomNotification(noty)
	noty.Type = Game.CustomNotifications.NotificationTypes[Game.CustomNotifications.NotificationNames[noty.Name]]
	noty.ID = lowestFreeID
	customNotifications[noty.ID] = noty
	lowestFreeID = lowestFreeID + 1
end

--------------------------------------------------------
--Notification Enabled Check
--------------------------------------------------------
--[[
	Checks whether a notification is visible and should be fired
	Arguments:
		name: string. The name of the notification
	Returns:
		boolean. Is the notification enabled?
]]--
function IsNotificationEnabled(name)
	if Game.NotificationSettings then
		--aprint("Notification Option Check: ",Game.NotificationSettings.Settings[Game.CustomNotifications.NotificationTypes[Game.CustomNotifications.NotificationNames[name]]])
		return Game.NotificationSettings.Settings[Game.CustomNotifications.NotificationTypes[Game.CustomNotifications.NotificationNames[name]]]
	end
	--aprint("Notification Enabled")
	return true
end



------------------------------------------------------------------
--	Notification class
------------------------------------------------------------------
Notification = class(
	function(o, name, summary, toolTip, imgIconTable, leftClick, rightClick)
		o.Name = name
		o.Instance = nil
		o.Summary = summary
		o.ToolTip = toolTip
		o.imgIconTable = imgIconTable
	end
)

--[[
	Gets the instance of this notification
	Returns:
		instance
]]--
function Notification:GetInstance()
	if self.Instance == nil then
		--aprint("Building Instance for "..self.Name)
		self.Instance = {}
		ContextPtr:BuildInstanceForControl( self.Name.."Item", self.Instance, Controls.SmallStack );
	end
	return self.Instance
end

function Notification.LeftClick(id)
	return
end

function Notification.RightClick(id)
	customNotifications[id]:Remove()
end

function Notification.MiddleClick(id)

end

function Notification:Show()
	addCustomNotification(self)
	local instance = self:GetInstance()
	local container = instance[self.Name.."Container"]
	local button = instance[self.Name.."Button"]
	--aprint(container, button, self.Summary);
	if not instance.FingerTitle then
		log:Fatal("Notification: Displaying %s %s FingerTitle=%s", self.Name, self.Summary, instance.FingerTitle)
		return
	end
	instance.FingerTitle:SetText( self.Summary )
	--aprint(self.Name.." Custom Finger Instance loaded?: ")
	container:BranchResetAnimation();
	if icontableOn == true then
		--aprint("Table at Notification show ",self.imgIconTable)
		for imageLoop, imagerow in pairs(self.imgIconTable) do			-- Run through each set of icon values
			imgIconType = imagerow[1];
			imgIconValue = imagerow[2];
			if imagerow[3] == 0 then	
				imgIconSize = 80;			-- Set standard size
			else
				imgIconSize = imagerow[3];
			end
			if imagerow[4] == 0 then
				imgIconMet = false;
			else
				imgIconMet = imagerow[4];
			end
			imgIconCustom = imagerow[5];
			--aprint("Custom Image Data: ", imgIconType, imgIconValue, imgIconSize, imgIconMet)
			if Locale.StartsWith(imgIconType, "Resource") == true then			-- Test of accepted types
				imgPortrait = GameInfo.Resources[imgIconValue].PortraitIndex;
				if imgPortrait ~= -1 then
					IconHookup( imgPortrait, imgIconSize, GameInfo.Resources[imgIconValue].IconAtlas, self.Instance[imgIconType] );
				end			
			elseif Locale.StartsWith(imgIconType, "Wonder") == true or Locale.StartsWith(imgIconType, "Building") == true then
				imgPortrait = GameInfo.Buildings[imgIconValue].PortraitIndex;
				if imgPortrait ~= -1 then
					IconHookup( imgPortrait, imgIconSize, GameInfo.Buildings[imgIconValue].IconAtlas, self.Instance[imgIconType] );				
				end
			elseif Locale.StartsWith(imgIconType, "Project") == true then
				imgPortrait = GameInfo.Projects[imgIconValue].PortraitIndex;
				if imgPortrait ~= -1 then
					IconHookup( imgPortrait, imgIconSize, GameInfo.Projects[imgIconValue].IconAtlas, self.Instance[imgIconType] );			
				end
			elseif Locale.StartsWith(imgIconType, "Natural") == true then
				imgPortrait = GameInfo.Features[imgIconValue].PortraitIndex;
				if imgPortrait ~= -1 then
					IconHookup( imgPortrait, imgIconSize, GameInfo.Features[imgIconValue].IconAtlas, self.Instance[imgIconType] );				
				end
			elseif Locale.StartsWith(imgIconType, "Tech") == true then
				imgPortrait = GameInfo.Technologies[imgIconValue].PortraitIndex;
				if imgPortrait ~= -1 then
					IconHookup( imgPortrait, imgIconSize, GameInfo.Technologies[imgIconValue].IconAtlas, self.Instance[imgIconType] );				
				end				
			elseif Locale.StartsWith(imgIconType, "Unit") == true then
				imgPortrait = GameInfo.Units[imgIconValue].PortraitIndex;
				if imgPortrait ~= -1 then
					IconHookup( imgPortrait, imgIconSize, GameInfo.Units[imgIconValue].IconAtlas, self.Instance[imgIconType] );				
				end	
			elseif Locale.StartsWith(imgIconType, "Specialist") == true or Locale.StartsWith(imgIconType, "Citizen") == true then
				if imgIconSize == 80 then imgIconSize = 64 end
				imgPortrait = GameInfo.Specialists[imgIconValue].PortraitIndex;
				if imgPortrait ~= -1 then
					IconHookup( imgPortrait, imgIconSize, GameInfo.Specialists[imgIconValue].IconAtlas, self.Instance[imgIconType] );				
				end	
			elseif Locale.StartsWith(imgIconType, "Promotion") == true then
				if imgIconSize == 80 then imgIconSize = 64 end
				imgPortrait = GameInfo.UnitPromotions[imgIconValue].PortraitIndex;
				if imgPortrait ~= -1 then
					IconHookup( imgPortrait, imgIconSize, GameInfo.UnitPromotions[imgIconValue].IconAtlas, self.Instance[imgIconType] );				
				end	
			elseif Locale.StartsWith(imgIconType, "Polic") == true then
				if imgIconSize == 80 then imgIconSize = 64 end
				imgPortrait = GameInfo.Policies[imgIconValue].PortraitIndex;
				if imgPortrait ~= -1 then
					if imgIconMet == true then
						IconHookup( imgPortrait, imgIconSize, GameInfo.Policies[imgIconValue].IconAtlasAchieved, self.Instance[imgIconType] );
					else
						IconHookup( imgPortrait, imgIconSize, GameInfo.Policies[imgIconValue].IconAtlas, self.Instance[imgIconType] );	
					end			
				end	
			elseif Locale.StartsWith(imgIconType, "Leader") == true then
				if imgIconSize == 80 then imgIconSize = 64 end
				if imgIconMet == true then
					local usTeam = Teams[Game.GetActiveTeam()]
					local themTeam = Players[imgIconValue]:GetTeam()
					if usTeam:IsHasMet(themTeam) then
						imgCivType = GameInfo.Civilizations[imgIconValue].Type
						imgLeader = GameInfo.Leaders( "Type = '" .. GameInfo.Civilization_Leaders( "CivilizationType = '" .. imgCivType .. "'" )().LeaderheadType .. "'" )();
						IconHookup( imgLeader.PortraitIndex, imgIconSize, imgLeader.IconAtlas, self.Instance[imgIconType] );
					else
						IconHookup( 22, imgIconSize, GameInfo.Leaders[0].IconAtlas, self.Instance[imgIconType] );
					end
				else
					imgCivType = GameInfo.Civilizations[imgIconValue].Type
					imgLeader = GameInfo.Leaders( "Type = '" .. GameInfo.Civilization_Leaders( "CivilizationType = '" .. imgCivType .. "'" )().LeaderheadType .. "'" )();
					IconHookup( imgLeader.PortraitIndex, imgIconSize, imgLeader.IconAtlas, self.Instance[imgIconType] );
				end
			elseif Locale.StartsWith(imgIconType, "Civ") == true then
				if imgIconMet == true then
					local usTeam = Teams[Game.GetActiveTeam()]
					local themTeam = Players[imgIconValue]:GetTeam()
					if usTeam:IsHasMet(themTeam) then
						CivIconHookup( imgIconValue, imgIconSize, self.Instance[imgIconType], self.Instance[imgIconType.."IconBG"], self.Instance[imgIconType.."IconShadow"], false, true );	
					else
						CivIconHookup( 23, imgIconSize, self.Instance[imgIconType], self.Instance[imgIconType.."IconBG"], self.Instance[imgIconType.."IconShadow"], false, true );
					end
				else
					CivIconHookup( imgIconValue, imgIconSize, self.Instance[imgIconType], self.Instance[imgIconType.."IconBG"], self.Instance[imgIconType.."IconShadow"], false, true );
				end
			elseif Locale.StartsWith(imgIconType, "Custom") == true then
				imgCustom = imgIconCustom[imgIconValue]
				IconHookup(imgCustom.PortraitIndex, imgIconSize, imgCustom.IconAtlas, self.Instance[imgIconType] );
			end
		end
	end

	button:SetHide(false)
	button:SetVoid1(self.ID)
	button:RegisterCallback(Mouse.eLClick, self.LeftClick)
	button:RegisterCallback(Mouse.eRClick, self.RightClick)
	button:RegisterCallback(Mouse.eMClick, self.MiddleClick)
	button:SetToolTipString(self.ToolTip)

	ProcessStackSizes();
	LuaEvents.CustomNotificationLoaded(Controls, ProcessStackSizes, lowestFreeID)
end

function Notification:Remove()
	Controls.SmallStack:ReleaseChild( self:GetInstance()[self.Name.."Container"] )
	customNotifications[self.ID] = nil
	ProcessStackSizes()
	LuaEvents.CustomNotificationLoaded(Controls, ProcessStackSizes, lowestFreeID)
end
------------------------------------------------------------------
--	PopupNotification class
------------------------------------------------------------------
--[[
	The PopupNotification class.
	Constructor Arguments:
		name: string. The name of this notification; references the graphics in CustomNotification.xml
		summary: string. The title of the notification
		toolTip: string.
		plot: Plot to zoom to
		popup: Context of the popup
		highlightColor: Vector4. Color for highlighting the hex if desired.
		highlightOnShow: boolean. Should this be highlighted when shown or when clicked?
]]--

PopupNotification = class(Notification, 
	function (o, name, summary, toolTip, plot, popup, highlightColor, highlightOnShow, imgIconTable)
		o.Plot = plot
		o.Popup = popup
		o.HighlightColor = highlightColor
		o.HighlightOnShow = highlightOnShow
		Notification.init(o, name, summary, toolTip, imgIconTable)
	end
)

function PopupNotification.LeftClick(id)
	local self = customNotifications[id]
	UIManager:QueuePopup( Controls[self.Popup], PopupPriority.BarbarianCamp )
end

function PopupNotification.MiddleClick(id)
	local self = customNotifications[id]

	if self.Plot ~= 0 then
		UI.LookAt(self.Plot)
	end
	
	-- highlight hex
	if self.HighlightColor ~= 0 then
		local pHex = ToHexFromGrid(Vector2(self.Plot:GetX(), self.Plot:GetY()))
		--aprint("Highlighting hex: ",pHex)
		Events.SerialEventHexHighlight(pHex, true, self.HighlightColor)
	end
	--UI.DoSelectCityAtPlot(self.Plot)
end

function PopupNotification:Remove()
	-- un-highlight hex
	if self.HighlightColor ~= 0 then
		local pHex = ToHexFromGrid(Vector2(self.Plot:GetX(), self.Plot:GetY()))
		Events.SerialEventHexHighlight(pHex, false, self.HighlightColor)
	end
	Controls.SmallStack:ReleaseChild( self:GetInstance()[self.Name.."Container"] )
	customNotifications[self.ID] = nil
	ProcessStackSizes()
	LuaEvents.CustomNotificationLoaded(Controls, ProcessStackSizes, lowestFreeID)
end

function PopupNotification:Show()
	-- append tool tip info
	if self.Plot ~= 0 then
		self.ToolTip = self.ToolTip.."[NEWLINE][NEWLINE]Left-click on this message to open popup. Middle-click to center on the plot. Right-click to dismiss."
	else
		self.ToolTip = self.ToolTip.."[NEWLINE][NEWLINE]Left-click on this message to open popup. Right-click to dismiss."
	end
	-- highlight hex
	if self.HighlightColor and self.HighlightOnShow then 
		local pHex = ToHexFromGrid(Vector2(self.Plot:GetX(), self.Plot:GetY()))
		--aprint("Highlighting hex: ",pHex)
		Events.SerialEventHexHighlight(pHex, true, self.HighlightColor)
	end
	-- delegate to parent
	Notification.Show(self)
end
------------------------------------------------------------------
--	PlotHighlightNotification class
------------------------------------------------------------------

--[[
	The PlotHighlightNotification class.
	Constructor Arguments:
		name: string. The name of this notification; references the graphics in CustomNotification.xml
		summary: string. The title of the notification
		toolTip: string.
		plot: Plot. The plot this notification triggered for
		highlightColor: Vector4. Color for highlighting the hex if desired.
		highlightOnShow: boolean. Should this be highlighted when shown or when clicked?
]]--
PlotHighlightNotification = class(Notification, 
	function (o, name, summary, toolTip, plot, highlightColor, highlightOnShow, imgIconTable)
		o.Plot = plot
		o.HighlightColor = highlightColor
		o.HighlightOnShow = highlightOnShow
		Notification.init(o, name, summary, toolTip, imgIconTable)
	end
)

--[[
	Centers on a plot and highlights it
	Arguments:
		id: number. Notification ID
]]--
function PlotHighlightNotification.LeftClick(id)
	local self = customNotifications[id]

	if self.Plot ~= 0 then
		UI.LookAt(self.Plot)
	end
	
	-- highlight hex
	if self.HighlightColor ~= 0 then
		local pHex = ToHexFromGrid(Vector2(self.Plot:GetX(), self.Plot:GetY()))
		--aprint("Highlighting hex: ",pHex)
		Events.SerialEventHexHighlight(pHex, true, self.HighlightColor)
	end
	--UI.DoSelectCityAtPlot(self.Plot)
end

function PlotHighlightNotification:Show()
	-- append tool tip info
	if self.Plot ~= 0 then
		self.ToolTip = self.ToolTip.."[NEWLINE][NEWLINE]Left-click on this message to center the screen on the plot. Right-click to dismiss."
	else
		self.ToolTip = self.ToolTip.."[NEWLINE][NEWLINE]Right-click to dismiss."
	end
	-- highlight hex
	if self.HighlightColor and self.HighlightOnShow then 
		local pHex = ToHexFromGrid(Vector2(self.Plot:GetX(), self.Plot:GetY()))
		--aprint("Highlighting hex: ",pHex)
		Events.SerialEventHexHighlight(pHex, true, self.HighlightColor)
	end
	-- delegate to parent
	Notification.Show(self)
end

function PlotHighlightNotification:Remove()
	-- un-highlight hex
	if self.HighlightColor ~= 0 then
		local pHex = ToHexFromGrid(Vector2(self.Plot:GetX(), self.Plot:GetY()))
		Events.SerialEventHexHighlight(pHex, false, self.HighlightColor)
	end
	Controls.SmallStack:ReleaseChild( self:GetInstance()[self.Name.."Container"] )
	customNotifications[self.ID] = nil
	ProcessStackSizes()
	LuaEvents.CustomNotificationLoaded(Controls, ProcessStackSizes, lowestFreeID)
end

------------------------------------------------------------------
--	CityZoomNotification class
------------------------------------------------------------------

--[[
	The CityZoomNotification class. Same as PlotHighlightNotification except that middle click opens city details
	Arguments:
		name: string. The name of this notification; references the graphics in CustomNotification.xml
		summary: string. The title of the notification
		toolTip: string.
		plot: Plot. The plot this notification triggered for
		city: City. The city to zoom to
		highlightColor: Vector4. Color for highlighting the hex if desired.
		highlightOnShow: boolean. Should this be highlighted when shown or when clicked?
]]--
CityZoomNotification = class(PlotHighlightNotification, 
	function (o, name, summary, toolTip, plot, city, highlightColor, highlightOnShow, imgIconTable)
		o.City = city
		PlotHighlightNotification.init(o, name, summary, toolTip, plot, highlightColor, highlightOnShow, imgIconTable)
	end
)


function CityZoomNotification.MiddleClick(id)




	local self = customNotifications[id]
	UI.DoSelectCityAtPlot(self.City:Plot())
end

function CityZoomNotification:Show()
	-- append tool tip info
	self.ToolTip = self.ToolTip.."[NEWLINE][NEWLINE]Left-click on this message to center the screen on the city. Middle-click to open its city view. Right-click to dismiss."
	-- highlight hex
	if self.HighlightColor and self.HighlightOnShow then 
		local pHex = ToHexFromGrid(Vector2(self.Plot:GetX(), self.Plot:GetY()))
		--aprint("Highlighting hex: ",pHex)
		Events.SerialEventHexHighlight(pHex, true, self.HighlightColor)
	end
	-- delegate to parent
	Notification.Show(self)
end
------------------------------------------------------------------
--	Colors
------------------------------------------------------------------

function ColorChoice(highlightColor)
	if highlightColor == "Red" then
		return Vector4(1,0,0,1);
	elseif highlightColor == "Green" then
		return Vector4(0,1,0,1);
	elseif highlightColor == "Blue" then
		return Vector4(0,0,1,1);
	elseif highlightColor == "Yellow" then
		return Vector4(1,1,0,1);
	elseif highlightColor == "Magenta" or highlightColor == "Pink" or highlightColor == "Culture" then
		return Vector4(1,0,1,1);
	elseif highlightColor == "Cyan" then
		return Vector4(0,1,1,1);
	elseif highlightColor == "White" then
		return Vector4(1,1,1,1);
	elseif highlightColor == "Black" then
		return Vector4(0,0,0,1);
	elseif highlightColor == "Gold" then
		return Vector4(1,0.94,0.08,1);
	elseif highlightColor == "Food" then
		return Vector4(0.99,0.58,0.16,1);
	elseif highlightColor == "Production" then
		return Vector4(0.44,0.56,0.74,1);
	end
end

------------------------------------------------------------------
-- Custom Notification Mod
--	   Event handling
------------------------------------------------------------------

function CustomNotification(name, summary, toolTip, pPlot, pCity, highlightColor, imgIconTable)
		--aprint(name, summary, toolTip, pPlot, pCity, highlightColor)
		--aprint("Icon Image Table: ", imgIconTable)
		if IsNotificationEnabled(name) == false then	-- Check if Notification is Enabled (notification options mod)
			return
		end
		imgIconTable = imgIconTable
		highlightOnShow = true;			-- Check for Highlighting
		if highlightColor == 0 then
			highlightOnShow = false;
		else
			--aprint("Notification: ",name,"Color: ",highlightColor)
			highlightColor = ColorChoice(highlightColor);
			--aprint("New Color: ",highlightColor)
		end
		icontableOn = true;				-- Check for Icon Tables
		if imgIconTable == 0 then
			icontableOn = false;
		end
		if not(pCity == 0) then			-- Check for City Zoom
			--aprint("Creating City Zoom Notification")
			if (pPlot == 0) then		-- Set centering plot to city if no value given
				pPlot = Map.GetPlot(pCity:GetX(),pCity:GetY())
			end
			local notification = CityZoomNotification(name, summary, toolTip, pPlot, pCity, highlightColor, highlightOnShow, imgIconTable)
			notification:Show();
		else		-- Check for Plot Highlight Notifications
			--aprint("Creating Plot Highlight Notification")
			local notification = PlotHighlightNotification(name, summary, toolTip, pPlot, highlightColor, highlightOnShow, imgIconTable)
			notification:Show();
		end;
end;

function CustomPopupNotification(name, summary, toolTip, pPlot, pPopup, highlightColor, imgIconTable)
		--aprint(name, summary, toolTip, pPlot, pPopup, highlightColor)
		--aprint("Icon Image Table: ", imgIconTable)
		if IsNotificationEnabled(name) == false then	-- Check if Notification is Enabled (notification options mod)
			return
		end
		highlightOnShow = true;			-- Check for Highlighting
		if highlightColor == 0 then
			highlightOnShow = false;
		else
			--aprint("Notification: ",name,"Color: ",highlightColor)
			highlightColor = ColorChoice(highlightColor);
			--aprint("New Color: ",highlightColor)
		end
		icontableOn = true;				-- Check for Icon Tables
		if imgIconTable == 0 then
			icontableOn = false;
		end
			local notification = PopupNotification(name, summary, toolTip, pPlot, pPopup, highlightColor, highlightOnShow, imgIconTable)
			notification:Show();
end;
------------------------------------------------------------------
--  Overhead
------------------------------------------------------------------

function OnTurnEnd()
	for id, pNotification in pairs(customNotifications) do 
		pNotification:Remove()
	end
end
Events.ActivePlayerTurnEnd.Add(OnTurnEnd)

function OnCustomNotificationsLoaded(controls, processStackSizes, lowestfreeid)
	Controls = controls
	ProcessStackSizes = processStackSizes
	lowestFreeID = lowestfreeid
	--aprint("CustomNotificationsLoaded: ",controls, processStackSizes, lowestfreeid)
end
LuaEvents.CustomNotificationLoaded.Add(OnCustomNotificationsLoaded)
--aprint("Custom notification executed")