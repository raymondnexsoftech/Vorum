---------------------------------------------------------------
-- FacebookModule.lua
--
-- Facebook Module
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
-- local facebook = require( "facebook" )
local json = require("json")

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local DEFAULT_FACEBOOK_APP_ID = "904553419585105"

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
local facebookAppId = DEFAULT_FACEBOOK_APP_ID
local facebookNewAppId
local facebookUserId
local facebookAccessToken
local facebookPermissionList = {}
local facebookListener
local isGettingFacebookUserId = false

-- Format of facebookUserInstantListener:
--   key of type
--     listener
local facebookUserInstantListener = {}

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
local facebookModule = {}

local function runFacebookListener(event)
	local listenerKey = event.type
	if (listenerKey == "session") then
		if (string.find(event.phase, "login")) then
			listenerKey = "login"
		else
			listenerKey = event.phase
		end
	end
	local instantListenerByKey = facebookUserInstantListener[listenerKey]
	if (instantListenerByKey) then
		facebookUserInstantListener[listenerKey] = nil
		local instantListenerReturn = instantListenerByKey(event)
		if (instantListenerReturn == true) then
			return
		end
	end
	if (facebookListener) then
		facebookListener(event)
	end
end

local function copyFacebookEvent(event)
	local newEventTable = {}
	for k, v in pairs(event) do
		newEventTable[k] = v
	end
	return newEventTable
end

local function createLoginEvent(event, isLoginSuccess)
	local newEventTable = copyFacebookEvent(event)
	newEventTable.type = "session"
	newEventTable.response = nil
	if (isLoginSuccess) then
		newEventTable.phase = "login"
	else
		newEventTable.phase = "loginFailed"
	end
	return newEventTable
end

local function facebookModuleListener(event)

	-- print("---------------")
 --    print( "event.name:" .. event.name )  --"fbconnect"
 --    print( "isError: " .. tostring( event.isError ) )
 --    print( "didComplete: " .. tostring( event.didComplete ) )
 --    print( "event.type:" .. event.type )  --"session", "request", or "dialog"
 --    print( "event.phase:" .. tostring(event.phase) )
 --    print( "event.response:" .. tostring(event.response) )
	-- print("---------------")

    local facebookListenerEvent = event

	if (event.isError) then
		if (isGettingFacebookUserId) then
			facebookListenerEvent = createLoginEvent(event, false)
		end
	else
		if (event.type == "session") then
			if (event.phase == "login") then
				facebookUserId = nil
				facebookAccessToken = event.token
				local params = {fields = "id"}
				-- facebook.request("me", "GET", params)
				isGettingFacebookUserId = true
				return
			else
				facebookUserId = nil
				facebookAccessToken = nil
			end
		elseif (event.type == "request") then
			if (isGettingFacebookUserId) then
				local response = json.decode(event.response)
				if (response.id ~= nil) then
					facebookUserId = response.id
					facebookAppId = facebookNewAppId
					facebookNewAppId = nil
				else
					facebookAccessToken = nil
				end
				facebookListenerEvent = createLoginEvent(event, facebookAccessToken ~= nil)
				facebookListenerEvent.userId = facebookUserId
				facebookListenerEvent.AccessToken = facebookAccessToken
				isGettingFacebookUserId = false
			else
				-- other request
			end
		end
	end
	runFacebookListener(facebookListenerEvent)
end

function facebookModule.setFacebookListener(listener)
	if (type(listener) == "function") then
		facebookListener = listener
	else
		facebookListener = nil
	end
end

-- facebookModule.login([facebookAppId][, permissions][, isLogoutFirst][, loginListener])
function facebookModule.login(...)
	local permissions, isLogoutFirst, loginListener
	local argIdx = 1
	if (type(arg[argIdx]) == "string") then
		facebookNewAppId = arg[argIdx]
		argIdx = argIdx + 1
	else
		facebookNewAppId = facebookAppId
	end
	if (type(arg[argIdx]) == "table") then
		permissions = arg[argIdx]
		argIdx = argIdx + 1
	end
	if (type(arg[argIdx]) == "boolean") then
		isLogoutFirst = true
		argIdx = argIdx + 1
	end
	if (type(arg[argIdx]) == "function") then
		loginListener = arg[argIdx]
		argIdx = argIdx + 1
	end
	local function logoutListener(event)
		facebookUserInstantListener["login"] = loginListener
		-- facebook.login(facebookNewAppId, facebookModuleListener, permissions)
	end
	if (isLogoutFirst) then
		facebookModule.logout(logoutListener)
	else
		logoutListener()
	end
end

function facebookModule.logout(listener)
	if (type(listener) == "function") then
		if (facebookAccessToken) then
			facebookUserInstantListener["logout"] = listener
			-- facebook.logout()
		else
			local event = {
								name = "fbconnect",
								type = "session",
								phase = "logout",
							}
			listener(event)
		end
	end
end

local function createCheckTokenValidListener(facebookActionCallback, instantListenerKey, listener)
	return function (event)
				local function loginListener(event)
					if (facebookAccessToken) then
						facebookUserInstantListener[instantListenerKey] = listener
						facebookActionCallback()
					else
						event.isError = true
						listener(event)
					end
				end
				if (facebookAccessToken) then
					listener(event)
				else
					facebookUserInstantListener["login"] = loginListener
					facebookNewAppId = facebookAppId
					-- facebook.login(facebookNewAppId, facebookModuleListener, {"publish_actions"})
				end
			end
end

-- -- TODO: add permission in module

function facebookModule.showDialog(action, params, showDialogListener)
	if (type(params) == "function") then
		showDialogListener = params
		params = nil
	end
	local function showDialogCallback()
		-- facebook.showDialog(action, params)
	end
	local instantRequestListener = createCheckTokenValidListener(showDialogCallback, "dialog", showDialogListener)
	if (facebookAccessToken) then
		facebookUserInstantListener["dialog"] = instantRequestListener
		showDialogCallback()
	else
		instantRequestListener()
	end
end

-- function facebookModule.request(path [, httpMethod, params][, requestListener])
function facebookModule.request(path, ...)
	local httpMethod, params, requestListener
	local argIdx = 1
	if (type(arg[argIdx]) == "string") then
		httpMethod = arg[argIdx]
		params = arg[argIdx + 1]
		argIdx = argIdx + 2
	end
	if (type(arg[argIdx]) == "function") then
		requestListener = arg[argIdx]
		argIdx = argIdx + 1
	end
	local function requestCallback()
		-- facebook.request(path, httpMethod, params)
	end
	local instantRequestListener = createCheckTokenValidListener(requestCallback, "request", requestListener)
	if (facebookAccessToken) then
		facebookUserInstantListener["request"] = instantRequestListener
		requestCallback()
	else
		instantRequestListener()
	end
end

function facebookModule.getUserInfo()
	return facebookUserId, facebookAccessToken
end

return facebookModule
