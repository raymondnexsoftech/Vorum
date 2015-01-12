---------------------------------------------------------------
-- SimulatedNetworkHandler.lua
--
-- Simulated Network Handler for debug purpose
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
local SIMULATED_MIN_DELAY_TIME_MS = 200
local SIMULATED_MAX_DELAY_TIME_MS = 500

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
local simulatedNetworkHandler = {}

local function suspendAllRequestBySystem()
	for k, v in pairs(networkHandling) do
		local networkHandingGroup = v
		for i = 1, #v do
			local singleNetworkRequest = v[i]
			if (singleNetworkRequest.status == "connecting") then
				singleNetworkRequest.status = "suspendedBySystem"
				timer.cancel(singleNetworkRequest.request)
				singleNetworkRequest.request = nil
				if (singleNetworkRequest.isResumeAfterSystemSuspend == false) then
					local event = {}
					event.isError = true
					event.name = "simulatedNetworkRequest"
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
				singleNetworkRequest.request = timer.performWithDelay(math.random(SIMULATED_MIN_DELAY_TIME_MS, SIMULATED_MAX_DELAY_TIME_MS), function() singleNetworkRequest.listener(singleNetworkRequest.listenerEvent) end, 1)
				singleNetworkRequest.status = "connecting"
			end
		end
	end
end

function simulatedNetworkHandler.suspendRequest(key)
	local networkHandlingGroup = networkHandling[key]
	if (networkHandlingGroup) then
		for i = 1, #networkHandlingGroup do
			local singleNetworkRequest = networkHandlingGroup[i]
			if (singleNetworkRequest.status == "connecting") then
				singleNetworkRequest.status = "suspended"
				timer.cancel(singleNetworkRequest.request)
				singleNetworkRequest.request = nil
			end
		end
	end
end

function simulatedNetworkHandler.suspendAllRequest()
	for k, v in pairs(networkHandling) do
		simulatedNetworkHandler.suspendRequest(k)
	end
end

function simulatedNetworkHandler.resumeRequest(key)
	local networkHandlingGroup = networkHandling[key]
	if (networkHandlingGroup) then
		for i = 1, #networkHandlingGroup do
			local singleNetworkRequest = networkHandlingGroup[i]
			if (singleNetworkRequest.status == "suspended") then
				singleNetworkRequest.request = timer.performWithDelay(math.random(SIMULATED_MIN_DELAY_TIME_MS, SIMULATED_MAX_DELAY_TIME_MS), function() singleNetworkRequest.listener(singleNetworkRequest.listenerEvent) end, 1)
				singleNetworkRequest.status = "connecting"
			end
		end
	end
end

function simulatedNetworkHandler.resumeAllRequest()
	for k, v in pairs(networkHandling) do
		simulatedNetworkHandler.resumeRequest(v)
	end
end

function simulatedNetworkHandler.cancelRequest(key)
	simulatedNetworkHandler.suspendRequest(key)
	networkHandling[key] = nil
end

function simulatedNetworkHandler.cancelAllRequest()
	for k, v in pairs(networkHandling) do
		simulatedNetworkHandler.cancelRequest(k)
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
			singleNetworkRequest.request = timer.performWithDelay(math.random(SIMULATED_MIN_DELAY_TIME_MS, SIMULATED_MAX_DELAY_TIME_MS), function() singleNetworkRequest.listener(singleNetworkRequest.listenerEvent) end, 1)
			singleNetworkRequest.status = "connecting"
		end
	end
end

function simulatedNetworkHandler.requestNetwork(apiParamsArray, listener, keyForRequest)
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
		curNetworkRequest.listenerEvent = apiParamsArray[i].listenerEvent
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
												if (listener(newNetworkRequest.event) == false) then
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

function simulatedNetworkHandler.makeSingleSimulatedNetworkEventResponse(isError, response)
	local event = {}
	event.name = "simulatedNetworkRequest"
	event.phase = "ended"
	event.isError = false
	if (isError ~= true) then
		event.response = response
	end
	return event
end

function simulatedNetworkHandler.setMinDelayTimeMs(time)
	if (type(time) == "number") then
		if (time > 0) then
			SIMULATED_MIN_DELAY_TIME_MS = time
			if (SIMULATED_MIN_DELAY_TIME_MS > SIMULATED_MAX_DELAY_TIME_MS) then
				SIMULATED_MAX_DELAY_TIME_MS = SIMULATED_MIN_DELAY_TIME_MS
			end
		end
	end
end

function simulatedNetworkHandler.setMaxDelayTimeMs(time)
	if (type(time) == "number") then
		if (time > 0) then
			SIMULATED_MAX_DELAY_TIME_MS = time
			if (SIMULATED_MIN_DELAY_TIME_MS > SIMULATED_MAX_DELAY_TIME_MS) then
				SIMULATED_MIN_DELAY_TIME_MS = SIMULATED_MAX_DELAY_TIME_MS
			end
		end
	end
end

function simulatedNetworkHandler.setDisplayDebugInfo(enable)
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
function simulatedNetworkHandler.printRequestOfNetworkHandling()
	if (displayDebugInfo) then
		print("Request in Simulated Network Handling:")
		for k, v in pairs(networkHandling) do
			print("  \"" .. k .. "\" with " .. tostring(#v) .. " API(s)")
		end
	end
end

return simulatedNetworkHandler
