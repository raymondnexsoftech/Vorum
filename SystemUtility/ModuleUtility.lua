---------------------------------------------------------------
-- ModuleUtility.lua
--
-- Module Utility
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
local moduleUtility = {}

function moduleUtility.checkModuleExist(moduleName)
	local checkModuleFunctionTotal = #package.loaders
	for i = 1, checkModuleFunctionTotal do
		local loaderReturnVal = package.loaders[i](moduleName)
		local typeOfResult = type(loaderReturnVal)
		if (typeOfResult == "function") then
			return true
		end
	end
	return false
end

return moduleUtility
