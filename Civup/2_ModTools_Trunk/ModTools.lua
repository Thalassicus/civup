-- ModTools.lua
-- Author: Thalassicus
-- DateCreated: 2/6/2011 5:17:42 AM
--------------------------------------------------------------

if Game == nil or IncludedModTools then
	return
end

IncludedModTools = true

--print("INFO   Loading ModTools.lua")
--
-- Function Definitions
--

include("SaveUtils.lua")
MY_MOD_NAME = "CiVUP_VEM"

MapModData.Civup = MapModData.Civup or {}
saveDB = saveDB or Modding.OpenSaveData()

Civup = Civup or {}
for row in GameInfo.Civup() do
	Civup[row.Type] = row.Value
end

include("MT_LuaEvents.lua")