---------------------------------------------------------------
-- NetworkHandler.lua
--
-- Handling Network
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
-- local resDir = (...):match("(.-)[^%.]+$")

-- Local Constant Setting
local LOCAL_SETTINGS = {
						RES_DIR = "",					-- Common resource directory for scene
						DOC_DIR = "",					-- Common document directory for scene
						}

---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
local networkHandling = {}
local displayDebugInfo = false	-- default is not display debug info
 
---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
local networkHandler = {}

local function checkUploadFileExist(networkRequest)
	if (type(networkRequest.params) == "table") then
		if (type(networkRequest.params.body) == "table") then
			local isError = true
			local fileInfo = networkRequest.params.body
			local path = system.pathForFile(fileInfo.filename, fileInfo.baseDirectory)
			if (path) then
				local file = io.open(path)
				if (file) then
					io.close(file)
					isError = false
				end
			end
			if (isError) then
				local response = {
										name = "networkRequest",
										isError = true,
										isFileNotFound = true,
									}
				timer.performWithDelay(1, networkRequest.listener(response))
				return false
			end
		end
	end
	return true
end

local function suspendAllRequestBySystem()
	for k, v in pairs(networkHandling) do
		local networkHandingGroup = v
		for i = 1, #v do
			local singleNetworkRequest = v[i]
			if (singleNetworkRequest.status == "connecting") then
				singleNetworkRequest.status = "suspendedBySystem"
				network.cancel(singleNetworkRequest.request)
				singleNetworkRequest.request = nil
				if (singleNetworkRequest.isResumeAfterSystemSuspend == false) then
					local event = {}
					event.isError = true
					event.name = "networkRequest"
					event.phase = "ended"
					event.isCancelledBySystem = true
					if (type(singleNetworkRequest.listener) == "function") then
						singleNetworkRequest.listener(event)
					end
				end
			end
		end
	end
end

local function resumeAllRequestBySystem()
	for k, v in pairs(networkHandling) do
		local networkHandingGroup = v
		for i = 1, #v do
			local singleNetworkRequest = v[i]
			if (singleNetworkRequest.status == "suspendedBySystem") then
				if (checkUploadFileExist(singleNetworkRequest)) then
					singleNetworkRequest.request = network.request(singleNetworkRequest.url, singleNetworkRequest.method, singleNetworkRequest.listener, singleNetworkRequest.params)
					singleNetworkRequest.status = "connecting"
				end
			end
		end
	end
end

function networkHandler.suspendRequest(key)
	local networkHandlingGroup = networkHandling[key]
	if (networkHandlingGroup) then
		for i = 1, #networkHandlingGroup do
			local singleNetworkRequest = networkHandlingGroup[i]
			if (singleNetworkRequest.status == "connecting") then
				singleNetworkRequest.status = "suspended"
				network.cancel(singleNetworkRequest.request)
				singleNetworkRequest.request = nil
			end
		end
	end
end

function networkHandler.suspendAllRequest()
	for k, v in pairs(networkHandling) do
		networkHandler.suspendRequest(k)
	end
end

function networkHandler.resumeRequest(key)
	local networkHandlingGroup = networkHandling[key]
	if (networkHandlingGroup) then
		for i = 1, #networkHandlingGroup do
			local singleNetworkRequest = networkHandlingGroup[i]
			if (singleNetworkRequest.status == "suspended") then
				if (checkUploadFileExist(singleNetworkRequest)) then
					singleNetworkRequest.request = network.request(singleNetworkRequest.url, singleNetworkRequest.method, singleNetworkRequest.listener, singleNetworkRequest.params)
					singleNetworkRequest.status = "connecting"
				end
			end
		end
	end
end

function networkHandler.resumeAllRequest()
	for k, v in pairs(networkHandling) do
		networkHandler.resumeRequest(v)
	end
end

function networkHandler.cancelRequest(key)
	networkHandler.suspendRequest(key)
	networkHandling[key] = nil
end

function networkHandler.cancelAllRequest()
	for k, v in pairs(networkHandling) do
		networkHandler.cancelRequest(k)
	end
end

local function createKeyForRequestNetwork()
	local keyBase = tostring(os.time(t))
	local key = keyBase
	local i = 0
	while(true) do
		if (networkHandling[key] == nil) then
			return key
		end
		i = i + 1
		key = keyBase .. "." .. tostring(i)
	end
end

local function startNetworkRequest(key)
	local networkHandlingGroup = networkHandling[key]
	if (networkHandlingGroup) then
		networkHandlingGroup.event = {}
		for i = 1, #networkHandlingGroup do
			local singleNetworkRequest = networkHandlingGroup[i]
			if (checkUploadFileExist(singleNetworkRequest)) then
				singleNetworkRequest.request = network.request(singleNetworkRequest.url, singleNetworkRequest.method, singleNetworkRequest.listener, singleNetworkRequest.params)
				singleNetworkRequest.status = "connecting"
			end
		end
	end
end

function networkHandler.requestNetwork(apiParamsArray, listener, keyForRequest)
	local apiNumber = #apiParamsArray
	local requestNetworkKey = createKeyForRequestNetwork()
	local newNetworkRequest = {}
	newNetworkRequest.retryTimes = 0
	for i = 1, apiNumber do
		local curNetworkRequest = {}
		curNetworkRequest.url = apiParamsArray[i].url
		curNetworkRequest.method = apiParamsArray[i].method
		if (type(curNetworkRequest.method) ~= "string") then
			curNetworkRequest.method = "GET"
		end
		curNetworkRequest.params = apiParamsArray[i].params
		curNetworkRequest.isResumeAfterSystemSuspend = apiParamsArray[i].isResumeAfterSystemSuspend
		curNetworkRequest.listener = function(event)
											newNetworkRequest.event[i] = event
											curNetworkRequest.request = nil
											curNetworkRequest.status = "completed"
											if (#newNetworkRequest.event == apiNumber) then
												newNetworkRequest.retryTimes = newNetworkRequest.retryTimes + 1
												newNetworkRequest.event.retryTimes = newNetworkRequest.retryTimes
												newNetworkRequest.event.key = keyForRequest
												if (displayDebugInfo == true) then
													local debugStr = "\n\n  Status of the request:"
													for i = 1, apiNumber do
														debugStr = debugStr .. "\n    " .. newNetworkRequest[i].url .. ":"
														debugStr = debugStr .. "\n      isError:  " .. tostring(newNetworkRequest.event[i].isError)
														debugStr = debugStr .. "\n      response: " .. tostring(newNetworkRequest.event[i].response)
													end
													print(debugStr .. "\n\n")
												end
												if ((type(listener) == "function") and (listener(newNetworkRequest.event) == false)) then
													if (displayDebugInfo == true) then
														print("  Network Request \"" .. keyForRequest .. "\" Retry " .. tostring(newNetworkRequest.retryTimes) .. " times")
													end
													startNetworkRequest(requestNetworkKey)
												else
													networkHandling[requestNetworkKey] = nil
												end
											end
										end
		newNetworkRequest[i] = curNetworkRequest
	end
	networkHandling[requestNetworkKey] = newNetworkRequest
	startNetworkRequest(requestNetworkKey)
	if (displayDebugInfo == true) then
		local debugStr = "\n\n  Request network:"
		for i = 1, apiNumber do
			debugStr = debugStr .. "\n    " .. newNetworkRequest[i].url
		end
		print(debugStr .. "\n\n")
	end
	return requestNetworkKey
end

function networkHandler.setDisplayDebugInfo(enable)
	displayDebugInfo = enable
end

local function onSystemEventHandleNetwork(event)
--	print( "System event name and type: " .. event.name, event.type )
	if (event.type == "applicationStart") then
    elseif (event.type == "applicationExit") then
    elseif (event.type == "applicationSuspend") then
    	suspendAllRequestBySystem()
    elseif (event.type == "applicationResume") then
    	resumeAllRequestBySystem()
    end
end
Runtime:addEventListener( "system", onSystemEventHandleNetwork )

-- Debug function
function networkHandler.printRequestOfNetworkHandling()
	if (displayDebugInfo) then
		print("Request in Network Handling:")
		for k, v in pairs(networkHandling) do
			print("  \"" .. k .. "\" with " .. tostring(#v) .. " API(s)")
		end
	end
end

return networkHandler
