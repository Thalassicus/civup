--[[
	CustomMissionHandler.lua
	
	Creator: alpaca
	Last Change: 10.12.2010
	
	Description: Handles added custom missions. To add a new mission, create a Lua file and hook it up as an InGameUIAddin. This Lua file has to do the following:
		- define a CanHandle function that returns true if the selected unit can perform the mission, and hook it up as a handler using the LuaEvents.AddCustomMissionCanHandle event
		- define a OnClick function that is called when the player clicks on the mission button, and hook it up using the LuaEvents.AddCustomMissionOnClickHandler event
		Then define the Lua file as a CustomMissionAddin in the Content tab of your mod.
		See DiscoverMission.lua for an example.
]]--

--[[
	Set up SaveUtils
]]--
--include("SaveUtils")
--MY_MOD_NAME = "PlayWithMe_v4"

--[[
	Load library
]]--
include("AlpacaUtils")
VERBOSITY = 0



-- table containing all custom missions
CustomMissions = {}


------------------------------------------------------------------
--	Custom mission class
------------------------------------------------------------------

CustomMission = class(function(o, typ)
	o.Type = typ
	o.ActionTable = {}
	o.CanHandle = function() end
	o.OnClick = function() end
	o.ToolTipActionHelp = function() end
	o.ToolTipDisabledHelp = function() end
end)

------------------------------------------------------------------
--	Superglobal Functions
------------------------------------------------------------------
Game.CustomMission = {}

--[[
	Checks whether the currently selected unit can perform a mission. Equivalent function to Game.CanHandleAction(). If you checked for Game.CanHandleAction() now check for "Game.CanHandleAction() or CanHandleCustomMission"
	Arguments:
		iMission: num. Mission id to GameInfoActions
		bTestDisabled: boolean. If true, this will return true if the ability is disabled but legal for the current unit. Defaults to false
	Returns:
		boolean. Whether the mission can be performed by the selected unit
]]--
function CanHandleCustomMission(iMission, bTestDisabled)
	if CustomMissions == nil then
		print("WARN   CanHandleCustomMission: CustomMissions is nil")
		CustomMissions = {}
	end
	if CustomMissions[iMission] == nil then
		return false
	end
	bTestDisabled = bTestDisabled or false
	return CustomMissions[iMission].CanHandle(bTestDisabled)
end
Game.CustomMission.CanHandleCustomMission = CanHandleCustomMission

--[[
	Handles a custom mission when it is clicked
	Arguments:
		iMission: num. Mission id to GameInfoActions
]]--
function HandleCustomMission(iMission)
	if CustomMissions[iMission] == nil then
		return false
	end
	CustomMissions[iMission].OnClick()
end
Game.CustomMission.HandleCustomMission = HandleCustomMission

--[[
	Retrieves a custom tooltip action string for a mission
	Arguments:
		iMission: num. Mission id to GameInfoActions
	Returns:
		string. The tooltip string addition
]]--
function GetToolTipActionHelp(iMission)
	if CustomMissions[iMission] == nil then
		return ""
	end
	local str = CustomMissions[iMission].ToolTipActionHelp()
	return str or ""
end
Game.CustomMission.GetCustomMissionToolTipActionHelp = GetToolTipActionHelp

--[[
	Retrieves a custom tooltip disabled string for a mission
	Arguments:
		iMission: num. Mission id to GameInfoActions
	Returns:
		string. The tooltip string addition
]]--
function GetToolTipDisabledHelp(iMission)
	if CustomMissions[iMission] == nil then
		return ""
	end
	local str = CustomMissions[iMission].ToolTipDisabledHelp()
	return str or ""
end
Game.CustomMission.GetCustomMissionDisabledToolTipHelp = GetToolTipDisabledHelp


--[[
	Reads mission data from Missions and adds it to the list of custom missions
	Arguments:
		missionType: String. Reference to Missions.Type
]]--
function AddCustomMission(missionType)
	-- only add if a mission is not yet added
	for k,v in pairs(CustomMissions) do
		if v.Type == missionType then
			print("Warning: Mission Type already added in AddCustomMission")
			return
		end
	end
	--aprint("Trying to add mission", "Type", missionType)
	
	local missionEntry = GameInfo.Missions[missionType]
	local newID = #GameInfoActions + 1
	local newMission = {
		["ActionInfoIndex"] = newID,
		["AltDown"] = missionEntry.AltDown,
		["AltDownAlt"] = missionEntry.AltDownAlt,
		["AutomateType"] = -1,
		["CommandData"] = -1,
		["ActionInfoIndex"] = 0,
		["HotKey"] = missionEntry.HotKey,
		["HotKeyPriority"] = missionEntry.HotKeyPriority,
		["HotKeyVal"] = -1,
		["ConfirmCommand"] = false,
		["ShiftDown"] = missionEntry.ShiftDown,
		["ShiftDownAlt"] = missionEntry.ShiftDownAlt,
		["HotKeyAlt"] = missionEntry.HotKeyAlt,
		["HotKeyPriorityAlt"] = missionEntry.HotKeyPriorityAlt,
		["HotKeyValAlt"] = -1,
		["DisabledHelp"] = missionEntry.DisabledHelp,
		["Help"] = missionEntry.Help,
		["CtrlDown"] = missionEntry.CtrlDown,
		["CtrlDownAlt"] = missionEntry.CtrlDownAlt,
		["OrderPriority"] = missionEntry.OrderPriority,
		["Type"] = missionEntry.Type,
		["Visible"] = missionEntry.Visible,
		["ControlType"] = -1,
		["SubType"] = ActionSubTypes.ACTIONSUBTYPE_MISSION, 
		["MissionType"] = missionEntry.ID, 
		["OriginalIndex"] = missionEntry.ID,
		["InterfaceModeType"] = -1,
		["CommandData"] = -1,
		["CommandType"] = -1,
		["AutomateType"] = -1,
		["TextKey"] = missionEntry.Description,
		["MissionData"] = -1
	}
	CustomMissions[newID] = CustomMission(missionType)
	CustomMissions[newID].ActionTable = newMission
	GameInfoActions[newID] = newMission
	--aprint("Mission added at ID",newID)
end

--[[
	Loads all custom missions from the Database
]]--
function LoadCustomMissionsFromDB()
	--aprint("Loading missions from DB")
	for miss in GameInfo.CustomMissions() do
		AddCustomMission(miss.Type)
	end
end


--[[
	Adds a custom mission CanHandle handler function. This function will be called when CanHandleCustomMission is called for the custom mission
	Arguments:
		missionType: string. Reference to Missions.Type
		handler: function. The handler
]]--
function OnAddCustomMissionCanHandle(missionType, handler)
	for k,v in pairs(CustomMissions) do
		if v.Type == missionType then
			--aprint("Custom mission CanHandle added for type ", missionType)
			v.CanHandle = handler
			return
		end
	end
	print("Error: Mission Type not found in OnAddCustomMissionCanHandle", missionType)
end

--[[
	Adds a custom mission OnClick handler function. This function will be called when the button for the custom mission is clicked
	Arguments:
		missionType: string. Reference to Missions.Type
		handler: function. The handler
]]--
function OnAddCustomMissionOnClick(missionType, handler)
	for k,v in pairs(CustomMissions) do
		if v.Type == missionType then
			--aprint("Custom mission OnClick added for type ", missionType)
			v.OnClick = handler
			return
		end
	end
	print("Error: Mission Type not found in OnAddCustomMissionOnClick", missionType)
end

--[[
	Adds a tooltip callback handler function to a custom mission. It will be displayed as the action help string in the UnitPanel button mouse-over
	Arguments:
		missionType: string. Reference to Missions.Type
		handler: function. The handler
]]--
function OnAddCustomMissionToolTip(missionType, handler)
	for k,v in pairs(CustomMissions) do
		if v.Type == missionType then
			--aprint("Custom mission ToolTip added for type ", missionType)
			v.ToolTipActionHelp = handler
			return
		end
	end
	print("Error: Mission Type not found in OnAddCustomMissionToolTip", missionType)
end

--[[
	Adds a tooltip disabled help callback handler function to a custom mission. It will be displayed as the disabled help string in the UnitPanel button mouse-over
	Arguments:
		missionType: string. Reference to Missions.Type
		handler: function. The handler
]]--
function OnAddCustomMissionDisabledToolTip(missionType, handler)
	for k,v in pairs(CustomMissions) do
		if v.Type == missionType then
			--aprint("Custom mission disabled ToolTip added for type ", missionType)
			v.ToolTipDisabledHelp = handler
			return
		end
	end
	print("Error: Mission Type not found in OnAddCustomMissionDisabledToolTip", missionType)
end

------------------------------------------------------------------
--	Script scope
------------------------------------------------------------------
LuaEvents.AddCustomMissionCanHandle.Add(OnAddCustomMissionCanHandle)
LuaEvents.AddCustomMissionOnClick.Add(OnAddCustomMissionOnClick)
LuaEvents.AddCustomMissionToolTip.Add(OnAddCustomMissionToolTip)
LuaEvents.AddCustomMissionDisabledToolTip.Add(OnAddCustomMissionDisabledToolTip)

LoadCustomMissionsFromDB()

g_CustomMissionAddins = {};
for addin in Modding.GetActivatedModEntryPoints("CustomMissionAddin") do
	local addinFile = addin.File;
	--aprint("Adding CustomMissionAddin", addin.Name)
	-- Get the absolute path and filename without extension.
	local extension = Path.GetExtension(addinFile);
	local path = string.sub(addinFile, 1, #addinFile - #extension);
	
	table.insert(g_CustomMissionAddins, ContextPtr:LoadNewContext(path));
end