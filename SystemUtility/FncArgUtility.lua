---------------------------------------------------------------
-- FncArgUtility.lua
--
-- Function Argument utility
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
--local resDir = (...):match("(.-)[^%.]+$")

-- Local Constant Setting
local LOCAL_SETTINGS = {
						RES_DIR = "",					-- Common resource directory for scene
						DOC_DIR = "",					-- Common document directory for scene
						}

---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------
require ( "SystemUtility.Debug" )

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
local fncArgUtility = {}

-- Sample table:
-- local argTable = {
--                      {name = "argA", type = "string", canSkip = true, default = "test"},
--                      {name = "argB", type = "number"},
--                      {name = "argC", type = "table", canSkip = true},
--                      fncName = "someFunction"
--                  }
function fncArgUtility.parseArg(argTable, arg)
	local isError = false
	local argIdx = 1
	local returnTable = {}
	for i = 1, #argTable do
		local argTableElement = argTable[i]
		if (type(arg[argIdx]) == argTableElement.type) then
			returnTable[argTableElement.name] = arg[argIdx]
			argIdx = argIdx + 1
		elseif (argTableElement.default) then
			returnTable[argTableElement.name] = argTableElement.default
		elseif (not (argTableElement.canSkip)) then
			isError = true
		end
	end
	if (isError) then
		debugLog("parsing input parameter error in function " .. argTable.fncName)
	end
	return returnTable
end

return fncArgUtility
