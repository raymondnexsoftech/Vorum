---------------------------------------------------------------
-- FileUtility.lua
--
-- File Utility
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
local lfs = require("lfs")

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
local fileUtility = {}

function fileUtility.isDirectoryExist(path, baseDir)
	baseDir = baseDir or system.DocumentsDirectory
	return lfs.chdir(system.pathForFile(path, baseDir))
end

function fileUtility.createDirectory(path, baseDir)
	baseDir = baseDir or system.DocumentsDirectory
	if not(fileUtility.isDirectoryExist(path, baseDir)) then
		local tempPath = system.pathForFile("", baseDir)
		local success = lfs.chdir(tempPath) -- returns true on success

		if (success) then
			local pathPointer = string.find(path, "/", 1)
			while (pathPointer ~= nil) do
				local curFolderPath = string.sub(path, 1, pathPointer - 1)
				lfs.mkdir(curFolderPath)
				pathPointer = string.find(path, "/", pathPointer + 1)
			end
			lfs.mkdir(path)
		else
			return false
		end
	end
end

return fileUtility
