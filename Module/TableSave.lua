---------------------------------------------------------------
-- SaveData.lua
--
-- Control Save Data
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
local saveData = require( "SaveData.SaveData" )
local json = require("json")
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
local tableSave = {}

function tableSave.save(...)
	local returnData = saveData.save(...)
	return returnData
end

function tableSave.load(...)
	local returnData = saveData.load(...)
	return returnData
end

function tableSave.delete(path, baseDir)
	local returnData = saveData.delete(path, baseDir)
	return returnData
end

function tableSave.push(...)
	print("PUSHPUSHPUSH!!!!!!")
	local path, baseDir, data, encryptionKey
	path = arg[1]
	local argIdx = 2
	if (type(arg[argIdx]) == "userdata") then
		baseDir = arg[argIdx]
		argIdx = argIdx + 1
	end
	baseDir = baseDir or system.DocumentsDirectory
	data = arg[argIdx]
	if (type(data) ~= "table") then
		return false
	end
	encryptionKey = arg[argIdx + 1]
	
	local dataTable = saveData.load(path,baseDir,encryptionKey)
	if(not dataTable)then -- new Table
		dataTable = {}
		dataTable[1] = data
		saveData.save(path,baseDir,dataTable,encryptionKey)
		return true
	else	-- replace old Table
		dataTable[#dataTable+1] = data
		saveData.save(path,baseDir,dataTable,encryptionKey)
		return true
	end
	return false
end

function tableSave.pop(...)
	print("POPPOPPOP!!!!!!")
	local path, baseDir, encryptionKey
	path = arg[1]
	local argIdx = 2
	if (type(arg[argIdx]) == "userdata") then
		baseDir = arg[argIdx]
		argIdx = argIdx + 1
	end
	baseDir = baseDir or system.DocumentsDirectory
	encryptionKey = arg[argIdx]
	local dataTable = saveData.load(path,baseDir,encryptionKey)
	
	if(not dataTable)then -- no table return nil
		return nil
	else
		if(#dataTable==0)then
			return nil
		else
			local returnData
			returnData = dataTable[#dataTable]
			dataTable[#dataTable] = nil
			saveData.save(path,baseDir,dataTable,encryptionKey)
			return returnData
		end
	end
	return false
end

return tableSave
