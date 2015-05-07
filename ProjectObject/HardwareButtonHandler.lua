---------------------------------------------------------------
-- HardwareButtonHandler.lua
--
-- Handling hardware button
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
local callbackList = {}
local isActivate = false
---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
local hardwareButtonHandler = {}

local function buttonListener(event)
	for i = 1, #callbackList do
		local isFinished = callbackList[i](event)
		if (isFinished == true) then
			return isFinished
		end
	end
end

function hardwareButtonHandler.clearAllCallback()
	callbackList = {}
end

function hardwareButtonHandler.activate()
	isActivate = true
	Runtime:addEventListener("key", buttonListener)
end

function hardwareButtonHandler.deactivate()
	Runtime:removeEventListener("key", buttonListener)
	isActivate = false
end

function hardwareButtonHandler.getStatus()
	return isActivate
end

local function findCallbackInList(callback)
	for i = 1, #callbackList do
		if (callbackList[i] == callback) then
			return i
		end
	end
	return nil
end

function hardwareButtonHandler.addCallback(callback, isHighPriority)
	local callbackPosition = findCallbackInList(callback)
	if (isHighPriority) then
		if (callbackPosition == nil) then
			callbackPosition = #callbackList + 1
		end
		for i = callbackPosition, 2, -1 do
			callbackList[i] = callbackList[i - 1]
		end
		callbackList[1] = callback
	elseif (callbackPosition == nil) then
		callbackList[#callbackList + 1] = callback
	end
end

function hardwareButtonHandler.removeCallback(callback)
	local callbackPosition = findCallbackInList(callback)
	if (callbackPosition) then
		table.remove(callbackList, callbackPosition)
	end
end

-- Debug function
function hardwareButtonHandler.printCallbackList()
	for i = 1, #callbackList do
		print(callbackList[i])
	end
end

return hardwareButtonHandler
