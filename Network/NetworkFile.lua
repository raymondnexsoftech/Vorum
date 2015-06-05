---------------------------------------------------------------
-- NetworkFile.lua
--
-- Handling file from network
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
local crypto = require( "crypto" )
local lfs = require("lfs")
local networkHandler = require("Network.NetworkHandler")

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
local displayDebugInfo = false	-- default is not display debug info
local downloadFileList = {}

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
local networkFile = {}

local function checkDir(path, baseDir)
	local filePath = system.pathForFile("", baseDir)
	local success = lfs.chdir(filePath) -- returns true on success
	if (success) then
		local pathPointer = string.find(path, "/", 1)
		while (pathPointer ~= nil) do
			local curFolderPath = string.sub(path, 1, pathPointer - 1)
			lfs.mkdir(curFolderPath)
			pathPointer = string.find(path, "/", pathPointer + 1)
		end
		lfs.mkdir(path)
		return true
	end
	return false
end

local function checkFileInDir(path, baseDir, fileHash)
	local filePath = system.pathForFile(path, baseDir)
	local isFileFound = false

	for file in lfs.dir(filePath) do
		if (string.find(file, "^%.") == nil) then
			if (file == fileHash) then
				isFileFound = true
			else
				local actualPath = filePath .. "/" .. file
				if (lfs.attributes(actualPath,"mode") == "file") then
					os.remove(actualPath)
				end
			end
		end
	end

	return isFileFound
end

-- function networkFile.getDownloadFile(url, path[, baseDir][, params][, listener])
function networkFile.getDownloadFile(...)
	local url, path = arg[1], arg[2]
	if ((url == nil) or (url == "")) then
		if (displayDebugInfo) then
			-- print("URL Error: " .. path)
		end
		return nil
	end
	local baseDir, params, listener
	local argIdx = 3
	if (type(arg[argIdx]) == "userdata") then
		baseDir = arg[argIdx]
		argIdx = argIdx + 1
	else
		baseDir = system.TemporaryDirectory
	end
	if (type(arg[argIdx]) == "table") then
		params = arg[argIdx]
		argIdx = argIdx + 1
	else
		params = {}
	end
	if (type(arg[argIdx]) == "function") then
		listener = arg[argIdx]
		argIdx = argIdx + 1
	end
	if (checkDir(path, baseDir) ~= true) then
		if (displayDebugInfo) then
			-- print("Get File Path Error: " .. path)
		end
		return nil
	end
	local fileHash = crypto.digest(crypto.md5, url)
	local filePath = path .. "/" .. fileHash
	if (checkFileInDir(path, baseDir, fileHash)) then
		if (displayDebugInfo) then
			-- print("File \"" .. path .. "\" exist, no need to download again")
		end
		return {
					path = filePath,
					baseDir = baseDir
				}
	end

	local downloadFileListTable = downloadFileList[path]
	if (downloadFileListTable == nil) then
		local function fileListener(event)
			if (event.cancelled) then
				if (displayDebugInfo) then
					-- print("Cancelled download file to path:")
					-- print("    " .. path)
				end
				-- in case need to do something on cancel
				downloadFileList[path] = nil
			else
				local listenerArray = downloadFileList[path].listenerArray
				local listenerArraySize = #listenerArray
				if ((event.phase == "ended") or ((event[1] ~= nil) and (event[1].phase == "ended"))) then
					if (event.isError) then
						if (event.retryTimes < 3) then
							return false
						end
						-- print("error on downloading pic " .. path)
					else
						for i = 1, listenerArraySize do
							local eventForListener = {}
							for k, v in pairs(event[1]) do
								eventForListener[k] = v
							end
							eventForListener.path = downloadFileList[path].path
							eventForListener.baseDir = downloadFileList[path].baseDir
							listenerArray[i](eventForListener)
						end
						downloadFileList[path] = nil
					end
				else
					for i = 1, listenerArraySize do
						local eventForListener = {}
						for k, v in pairs(event) do
							eventForListener[k] = v
						end
						listenerArray[i](eventForListener)
					end
				end
			end
		end
		downloadFileListTable = {listenerArray = {}}
		local apiParams = {{}}
		apiParams.triggerEventOnCancel = true
		apiParams[1].url = url
		apiParams[1].params = params
		apiParams[1].params.response = {
											filename = filePath,
											baseDirectory = baseDir,
										}
		apiParams[1].params.progress = "download"
		apiParams[1].method = "GET"
		downloadFileListTable.request = networkHandler.requestNetwork(apiParams, fileListener, "networkFileDownload")
		downloadFileListTable.path = filePath
		downloadFileListTable.baseDir = baseDir
		downloadFileList[path] = downloadFileListTable
		if (displayDebugInfo) then
			-- print("Downloading file to path:")
			-- print("    " .. path)
		end
	end
	if (type(listener) == "function") then
		downloadFileListTable.listenerArray[#downloadFileListTable.listenerArray + 1] = listener
	end
	return {
				path = filePath,
				baseDir = baseDir,
				request = downloadFileListTable.request,
			}
end

function networkFile.cancelDownloadFile(path)
	local downloadFileListTable = downloadFileList[path]
	if (downloadFileListTable) then
		networkHandler.cancelRequest(downloadFileListTable.request)
	end
end

function networkFile.cancelDownloadFileByRequest(requestKey)
	networkHandler.cancelRequest(requestKey)
end

function networkFile.cancelAllDownloadFile()
	for k, v in pairs(downloadFileList) do
		networkFile.cancelDownloadFile(v)
	end
end

function networkFile.setDisplayDebugInfo(enable)
	displayDebugInfo = enable
end

return networkFile
