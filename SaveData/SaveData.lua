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
require ( "DebugUtility.Debug" )
local json = require("json")
local openssl = require( "plugin.openssl" )
local crypto = require( "crypto" )
local mime = require ( "mime" )

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local cipher = openssl.get_cipher ( "aes-256-cbc" )

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
local saveData = {}

-- saveData.save(path[, baseDir], data[, encryptionKey])
function saveData.save(...)
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

	local tempPath = system.pathForFile("", baseDir)
	local success = lfs.chdir(tempPath) -- returns true on success

	if (success) then
		local pathPointer = string.find(path, "/", 1)
		while (pathPointer ~= nil) do
			local curFolderPath = string.sub(path, 1, pathPointer - 1)
			lfs.mkdir(curFolderPath)
			pathPointer = string.find(path, "/", pathPointer + 1)
		end
	else
		return false
	end

	local filePath = system.pathForFile(path, baseDir)
	local file = io.open( filePath, "w" )
	if (file == nil) then
		return false
	end

	local dataToStore = data
	-- for k, v in pairs(data) do
	-- 	local typeOfVariable = type(v)
	-- 	if ((typeOfVariable == "function") or (typeOfVariable == "userdata")) then
	-- 		debugLog("The type of data in key \"" .. k .. "\" is \"" .. typeOfVariable .."\", which is not supported in save data. This field will be ignored.")
	-- 	else
	-- 		dataToStore[k] = v
	-- 	end
	-- end
	local dataToFile
	if (encryptionKey) then
		local key = crypto.digest( crypto.sha256, encryptionKey )
		dataToFile = mime.b64(cipher:encrypt(json.encode(dataToStore), key))
	else
		dataToFile = json.encode(dataToStore)
	end
	file:write(dataToFile)
	io.close( file )
	file = nil

	return true
end

-- saveData.load(path[, baseDir][, encryptionKey])
function saveData.load(...)
	local path, baseDir, encryptionKey
	path = arg[1]
	local argIdx = 2
	if (type(arg[argIdx]) == "userdata") then
		baseDir = arg[argIdx]
		argIdx = argIdx + 1
	end
	baseDir = baseDir or system.DocumentsDirectory
	encryptionKey = arg[argIdx]

	local filePath = system.pathForFile(path, baseDir)
	local file = io.open( filePath, "r" )
	if (file == nil) then
		return false
	end
	local dataFromFile = file:read("*a")
	io.close( file )
	file = nil

	local returnData
	if (encryptionKey) then
		local key = crypto.digest( crypto.sha256, encryptionKey )
		local decryptedData = cipher:decrypt(mime.unb64(dataFromFile), key)
		if (string.sub(decryptedData, 1, 1) ~= "{") then
			return false
		end
		returnData = json.decode(decryptedData)
	else
		returnData = json.decode(dataFromFile)
	end
	return returnData
end

return saveData
