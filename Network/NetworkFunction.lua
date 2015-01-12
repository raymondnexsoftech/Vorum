---------------------------------------------------------------
-- NetworkFunction.lua
--
-- Set Network Request
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
local resDir = (...):match("(.-)[^%.]+$")

-- Local Constant Setting
local LOCAL_SETTINGS = {
						RES_DIR = "",					-- Common resource directory for scene
						DOC_DIR = "",					-- Common document directory for scene
						}

---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------
local networkHandler = require( resDir .. ".NetworkHandler" )
local simulatedNetworkHandler = require( resDir .. ".SimulatedNetworkHandler" )

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local API_GET_NEWS = "http://office.jointedheart.com:8051/mobile_api/getLatestTimeForNews.php"
local API_REG_INVOICE = "http://office.jointedheart.com:8051/mobile_api/getRegisteredInvoice.php"
local API_GET_SHOP = "http://office.jointedheart.com:8051/mobile_api/getLatestTimeForShopLists.php"

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
--	This is the sample code to set the NetworkFunction.lua
--	You can modify This file, or directly require NetworkHandler to do the network request

local networkFunction = {}

-- The following Code is to turn on the debug info of network handler
-- "GLOBAL_DEBUG_STATUS" is just a global variable that control debug status, change it if needed
if (type(GLOBAL_DEBUG_STATUS) == "boolean") then
	networkHandler.setDisplayDebugInfo(GLOBAL_DEBUG_STATUS)
	simulatedNetworkHandler.setDisplayDebugInfo(GLOBAL_DEBUG_STATUS)
else
	networkHandler.setDisplayDebugInfo(true)
	simulatedNetworkHandler.setDisplayDebugInfo(true)
end



-- function start

local function createParamsForApiNumber(number)
	local apiParams = {}
	for i = 1, number do
		apiParams[i] = {}
	end
	return apiParams
end

function networkFunction.getApiList1(listener)
	local apiParams = createParamsForApiNumber(2)
	apiParams[1].url = API_GET_NEWS
	apiParams[2].url = API_REG_INVOICE
	apiParams[2].params = {
								body = string.format("{\"variable\":{\"member_id\":\"%s\",\"logintoken\":\"%s\",\"appid\":\"%s\"}}", "92558335", "ACL563QK7FVG9QPQ", "GF61GD9H1WDH3QHP"),
								timeout = 10,
							}
	return networkHandler.requestNetwork(apiParams, listener, "ApiList1")
end

function networkFunction.getApiList2(listener)
	local apiParams = createParamsForApiNumber(2)
	apiParams[1].url = API_GET_SHOP
	apiParams[2].url = API_REG_INVOICE
	apiParams[2].params = {
								body = string.format("{\"variable\":{\"member_id\":\"%s\",\"logintoken\":\"%s\",\"appid\":\"%s\"}}", "92558335", "ACL563QK7FVG9QPQ", "GF61GD9H1WDH3QHP"),
								timeout = 10,
							}
	return networkHandler.requestNetwork(apiParams, listener, "ApiList2")
end

function networkFunction.getApiList3(listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].url = API_GET_SHOP
	return networkHandler.requestNetwork(apiParams, listener, "ApiList3")
end

function networkFunction.getSimulatedApiList1(listener)
	local apiParams = createParamsForApiNumber(2)
	apiParams[1].url = API_GET_NEWS
	apiParams[1].listenerEvent = simulatedNetworkHandler.makeSingleSimulatedNetworkEventResponse(false, "test1")
	apiParams[2].url = API_REG_INVOICE
	apiParams[2].params = {
								body = string.format("{\"variable\":{\"member_id\":\"%s\",\"logintoken\":\"%s\",\"appid\":\"%s\"}}", "92558335", "ACL563QK7FVG9QPQ", "GF61GD9H1WDH3QHP"),
								timeout = 10,
							}
	apiParams[2].listenerEvent = simulatedNetworkHandler.makeSingleSimulatedNetworkEventResponse(false, "test2")
	return simulatedNetworkHandler.requestNetwork(apiParams, listener, "ApiList1")
end

function networkFunction.getSimulatedApiList2(listener)
	local apiParams = createParamsForApiNumber(2)
	apiParams[1].url = API_GET_SHOP
	apiParams[1].listenerEvent = simulatedNetworkHandler.makeSingleSimulatedNetworkEventResponse(false, "test3")
	apiParams[2].url = API_REG_INVOICE
	apiParams[2].params = {
								body = string.format("{\"variable\":{\"member_id\":\"%s\",\"logintoken\":\"%s\",\"appid\":\"%s\"}}", "92558335", "ACL563QK7FVG9QPQ", "GF61GD9H1WDH3QHP"),
								timeout = 10,
							}
	apiParams[2].listenerEvent = simulatedNetworkHandler.makeSingleSimulatedNetworkEventResponse(false, "test4")
	return simulatedNetworkHandler.requestNetwork(apiParams, listener, "ApiList2")
end

function networkFunction.getSimulatedApiList3(listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].url = API_GET_SHOP
	apiParams[1].listenerEvent = simulatedNetworkHandler.makeSingleSimulatedNetworkEventResponse(false, "test5")
	return simulatedNetworkHandler.requestNetwork(apiParams, listener, "ApiList3")
end

function networkFunction.cancelConnection(key)
	networkHandler.cancelRequest(key)
	simulatedNetworkHandler.cancelRequest(key)
end

function networkFunction.cancelAllConnection()
	networkHandler.cancelAllRequest()
	simulatedNetworkHandler.cancelAllRequest()
end

-- Debug function
function networkFunction.printRequestOfNetworkHandling()
	networkHandler.printRequestOfNetworkHandling()
	simulatedNetworkHandler.printRequestOfNetworkHandling()
end

return networkFunction
