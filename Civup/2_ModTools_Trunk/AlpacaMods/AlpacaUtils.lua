--[[
	AlpacaUtils.lua
	
	Creator: alpaca
	Last Change: 27.11.2010
	
	Description: Adds some useful functions
]]--

include("ModTools")

local log = Events.LuaLogger:New()
log:SetLevel("WARN")

-- Constants

MAX_LOGGING_DEPTH = 10
SPACES_PER_TAB = 4
VERBOSITY = 0

--[[
	Recursively prints a table. For userdata, the metatable is logged
	Arguments:
		tab: Table. Table to log
		depth: Number. Current depth (for recursion)
		maxDepth: Number. Maximal recursion depth (to avoid infinite loops through back-referencing)
		callStack: Used internally
	Returns:
		true: on success
]]--
function printTable(tab, depth, maxDepth, callStack)
	local depth = depth or 0
	local maxDepth = maxDepth or MAX_LOGGING_DEPTH
	local iD = iD or "default"
	local callStack = callStack or {}
	
	if tab == nil then
		print(intToSpaces(depth).."<nil>")
		return 
	end
	if tab == {} then
		print(intToSpaces(depth).."<empty>")
		return
	end
	
	if depth > maxDepth then
		return "MaxDepth reached"
	end
	
	tab = (type(tab) == "userdata") and getmetatable(tab) or tab -- for userdata, we use the metatable
	
	for k,v in pairs(tab) do
		if type(v) == "table" then
			print(intToSpaces(depth).."(table) "..tostring(k))
			-- avoid infinite recursion by making sure the table is only printed once
			if callStack[v] == nil then
				callStack[v] = v
				printTable(v, depth + 1, maxDepth, iD, callStack)
			end
		else
			print(intToSpaces(depth).."("..type(k)..") "..tostring(k)..": ".."("..type(v)..") "..tostring(v))
		end
	end
end


--[[
	Prints a text only for debugging
	Arguments:
		...: The args to print
	Returns:
		true if something was printed, false otherwise
]]--
function aprint(...)
	if VERBOSITY > 0 then
		print(...)
		return true
	end
	return false
end

--[[
	Converts an integer into a string containing n times so many spaces (for indentation).
	Arguments:
		num: Number. Number of "tabs" to write
	Returns:
		String containing the spaces
]]--
function intToSpaces(num)
	local retValue = ""
	for var = 1, num*SPACES_PER_TAB do
		retValue = retValue.." "
	end
	return retValue
end


--[[
	Replaces the bugged vanilla version
	Arguments:
		pPlot: Plot. The plot
		iBuildID: num. The ID of the build to check
	Returns:
		num. The number of turns left to finish the build
]]--
PlotGetBuildTurnsLeft = function(pPlot, iBuildID, iWorkRate)
	local workerSpeed = 100 + Players[Game.GetActivePlayer()]:GetWorkerSpeedModifier()
	local progress = pPlot:GetBuildProgress(iBuildID)
	local futureProgressThisTurn
	if iWorkRate then
		futureProgressThisTurn = iWorkRate * ((progress == 0) and 2 or 1)
		--log:Debug("futureProgressThisTurn = %s", futureProgressThisTurn)
	else
		for i=0, pPlot:GetNumUnits()-1 do
			local pUnit = pPlot:GetUnit( i )
			if iBuildID == pUnit:GetBuildType() then
				if pUnit:MovesLeft() > 0 then
					futureProgressThisTurn = pUnit:WorkRate(true, iBuildID)
				else
					futureProgressThisTurn = 0
				end
			end
		end
	end
	progress = progress + futureProgressThisTurn
	local turnsRemaining = math.ceil((pPlot:GetBuildTime(iBuildID) - progress) / workerSpeed)
	return (turnsRemaining == -0) and 0 or turnsRemaining
end


--[[
	Expands the vanilla version, which doesn't take route yield into account
	Arguments:
		pPlot: Plot. The plot
		iBuild: num. The ID of the build to check
		iYield: num. The yield ID (from YieldTypes)
		iPlayer: num. The player to check for
	Returns:
		num. Total yield with the build in place
]]--
function PlotGetYieldWithBuild(pPlot, iBuild, iYield, iPlayer)
	local newYield = pPlot:GetYieldWithBuild(iBuild, iYield, false, iPlayer)
	local iRoute = pPlot:GetRouteType()
	if iRoute and iRoute >= 0 then
		-- add route yield
		for pRouteYield in GameInfo.Route_Yields() do
			if pRouteYield.RouteType == GameInfo.Routes[iRoute].Type and YieldTypes[pRouteYield.YieldType] == iYield then
				newYield = newYield + pRouteYield.Yield
				break
			end
		end
	end
	
	return newYield
end

--[[
	Defines a class that can be instantiated. Taken from the LuA users wiki: http://lua-users.org/wiki/SimpleLuaClasses (April 8th 2010)
	An example for implementing a class with this can be found in the wiki.
	Arguments:
		base: Class. Base class to derive this class from
		init: Function. Initialisation function to call - a constructor if you will
	Returns:
		The class object
]]--
function class(base, init)
	local c = {}    -- a new class instance
	if not init and type(base) == 'function' then
		init = base
		base = nil
	elseif type(base) == 'table' then
		-- our new class is a shallow copy of the base class!
		for i,v in pairs(base) do
			c[i] = v
		end
		c._base = base
	end
	-- the class will be the metatable for all its objects,
	-- and they will look up their methods in it.
	c.__index = c

   -- expose a constructor which can be called by <classname>(<args>)
	local mt = {}
	mt.__call = function(class_tbl, ...)
		local obj = {}
		setmetatable(obj,c)
		
		if init then
			init(obj,...)
		else 
			-- make sure that any stuff from the base class is initialized!
			if base and base.init then
				base.init(obj, ...)
			end
		end
		return obj
	end
	
	c.init = init
	c.is_a = function(self, klass)
		local m = getmetatable(self)
		while m do 
			if m == klass then return true end
			m = m._base
		end
		return false
   end
   setmetatable(c, mt)
   return c
end

--[[
	Checks if a player has the needed prerequisites to build an improvement
	Arguments:
		iBuild: number. The build ID
		iPlayer: number. The player ID
	Returns:
		boolean. True if the prereq is met, false otherwise
]]--
function HasTechForBuild(iBuild, iPlayer)
	if iPlayer == nil then
		iPlayer = Game.GetActivePlayer()
	end
	
	local iActiveTeam = Players[iPlayer]:GetTeam()
	local pActiveTeam = Teams[iActiveTeam]
	local pBuild = GameInfo.Builds[iBuild]
	
	if (pBuild.PrereqTech ~= nil) then
		local iTech = GameInfo.Technologies[pBuild.PrereqTech].ID
		return pActiveTeam:GetTeamTechs():HasTech(iTech);	
	end
	return true
end


--[[
	Formats a number to a green highlighted text if it's positive, and red if it's negative
	Arguments:
		value: num.
		localizedText: string. Localization entry
		localizeArgs: table. Arguments to ConvertTextKey. nil to skip
		bPercent: bool. Add a percent sign?
		bNegate: bool. Invert colors?
	Returns:
		
]]--
function FormatNumber(value, localizedText, localizeArgs, bPercent, bNegate, formatStr)
	if value == 0 then
		return ""
	end
	if bPercent == nil then
		bPercent = true
	end
	formatStr = formatStr or "#.##"

	local str = "[NEWLINE][ICON_BULLET]" 
	if localizeArgs then
		str = str .. (localizedText and (Locale.ConvertTextKey(localizedText, unpack(localizeArgs)) .. ": ") or "")
	else
		str = str .. (localizedText and (Locale.ConvertTextKey(localizedText) .. ": ") or "")
	end
	
	if (value > 0 and not bNegate) or (value < 0 and bNegate) then
		str = str .. "[COLOR_POSITIVE_TEXT]"
	else
		str = str .. "[COLOR_NEGATIVE_TEXT]"
	end
	
	str = str .. Locale.ToNumber(value, formatStr) .. (bPercent and "%" or "") .. "[ENDCOLOR]"
	
	return str
end

--[[
	Formats a yield type and number using font icons and green/red text do denote positive/negative
	Arguments:
		iYieldType: num. Yield Type index (YieldTypes.YIELD_GOLD, etc)
		nQuantity: num. Amount
	Returns:
		string. The formatted string
]]--
function GetYieldTypeString(iYieldType, nQuantity)
	local returnString = ""
	if nQuantity ~= 0 then
		if iYieldType == YieldTypes.YIELD_FOOD then
			returnString = returnString .. "[ICON_FOOD] " 
		elseif iYieldType == YieldTypes.YIELD_GOLD then
			returnString = returnString .. "[ICON_GOLD] "
		elseif iYieldType == YieldTypes.YIELD_PRODUCTION then
			returnString = returnString .. "[ICON_PRODUCTION] "
		elseif iYieldType == YieldTypes.YIELD_SCIENCE then
			returnString = returnString .. "[ICON_RESEARCH] "
		elseif iYieldType == 4 then
			returnString = returnString .. "[ICON_CULTURE] "
		end
		if nQuantity < 0 then
			returnString = returnString .. "[COLOR_NEGATIVE_TEXT]"
		else
			returnString = returnString .. "[COLOR_POSITIVE_TEXT]+"
		end
		returnString = returnString .. tostring(nQuantity) .. "[ENDCOLOR]"
	end
	return returnString
end