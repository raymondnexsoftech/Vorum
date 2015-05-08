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
local json = require("json")
local url = require("socket.url")
local networkHandler = require( resDir .. "NetworkHandler" )
local simulatedNetworkHandler = require( resDir .. "SimulatedNetworkHandler" )

local fncArgUtility = require("SystemUtility.FncArgUtility")
local networkFile = require("Network.NetworkFile")

local storyboard = require("storyboard")
local localization = require("Localization.Localization")

local global = require( "GlobalVar.global" )
local headTabFnc = require( "ProjectObject.HeadTabFnc" )
local saveData = require( "SaveData.SaveData" )

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local IS_DEBUG_ON = false

-- local API_BASE = "http://aws.lwhken.info/vorum/index.php/rest/"
local API_BASE = "http://52.24.97.183/vorum/rest/"
local API_USER_BASE = API_BASE .. "user"
local API_FILE_BASE = API_BASE .. "file"
local API_POST_BASE = API_BASE .. "post"
local API_VOTE_BASE = API_BASE .. "vote"
local API_COUPON_BASE = API_BASE .. "coupon"
local API_FRIEND_BASE = API_BASE .. "friend"
local API_DEVICE_BASE = API_BASE .. "device"
local API_NOTIFICATION_BASE = API_BASE .. "notification"

local CHOICE_LETTER = {"A", "B", "C", "D"}

local API_ERROR_CODE_SESSION_INVALID = 4

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
local userEmailLoginData
local userFbLoginData
local sessionToken = nil
local awaitingRequest

local pushToken
local registerPushTimer
local pushDeviceRequest

local goToLoginSceneOption =
{
    effect = "fade",
    time = 400,
}

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
	networkHandler.setDisplayDebugInfo(IS_DEBUG_ON)
	simulatedNetworkHandler.setDisplayDebugInfo(IS_DEBUG_ON)
end

-- function start

local function deepCopyTable(val)
	if (type(val) == "table") then
		local newTable = {}
		for k, v in pairs(val) do
			newTable[k] = deepCopyTable(v)
		end
		return newTable
	end
	return val
end

local function createVorumNetworkHeader(sessionToken)
	local headers = {
						-- ["Content-Type"] = "application/json",
						["X-API-KEY"] = "53b42978a961661ce0a712fc30ba2cf3e26b959f",
					}
	if (sessionToken) then
		headers["X-SESSION-TOKEN"] = sessionToken
	end
	return headers
end

local function createParamsForApiNumber(number)
	local apiParams = {}
	for i = 1, number do
		apiParams[i] = {}
	end
	return apiParams
end

local POST_PIC_MAX_WIDTH = 640
local POST_PIC_MAX_HEIGHT = 1136
local POST_PIC_ASPECT_RATIO = POST_PIC_MAX_WIDTH / POST_PIC_MAX_HEIGHT
local IMG_SCALE_FOR_SCREEN = display.contentWidth / display.pixelWidth

local function resizePic(path, newFileName, baseDir)
	local img
	if (baseDir) then
		img = display.newImage(path, baseDir, true)
	else
		img = display.newImage(path, true)
	end
	if (img) then
		local picScale = 1
		local picAspectRatio = img.width / img.height
		if (picAspectRatio >= POST_PIC_ASPECT_RATIO) then
			picScale = POST_PIC_MAX_WIDTH / img.width
		else
			picScale = POST_PIC_MAX_HEIGHT / img.height
		end
		if (picScale > 1) then
			picScale = 1
		end
		img.xScale = picScale * IMG_SCALE_FOR_SCREEN
		img.yScale = picScale * IMG_SCALE_FOR_SCREEN
		display.save(img, {filename = newFileName, baseDir = system.TemporaryDirectory, isFullResolution = true})
		display.remove(img)
		return {path = newFileName, baseDir = system.TemporaryDirectory}
	else
		return {}
	end
	return nil
end


function networkFunction.resizePic(path, newFileName, baseDir)
	return resizePic(path, newFileName, baseDir)
end

local function login(listener)
	local dataToSend
	if (userFbLoginData) then
		dataToSend = userFbLoginData
	elseif (userEmailLoginData) then
		dataToSend = userEmailLoginData
	else
		return nil
	end
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(),
								body = json.encode(dataToSend)
							}
	apiParams[1].url = API_USER_BASE .. "/login"
	apiParams[1].method = "POST"
	apiParams[1].triggerEventOnCancel = true
	return networkHandler.requestNetwork(apiParams, listener, "login")
end

local function loginErrorForAwaitingRequest(event)
	if (awaitingRequest ~= nil) then
		for i = 1, #awaitingRequest do
			if (awaitingRequest[i].listener ~= nil) then
				awaitingRequest[i].listener(event)
				break;
			end
		end
	end
end

local function runAwaitingRequest()
	if (awaitingRequest ~= nil) then
		for i = 1, #awaitingRequest do
			if (awaitingRequest[i].fnc ~= nil) then
				awaitingRequest[i].fnc(awaitingRequest[i].params, awaitingRequest[i].listener)
			end
		end
	end
	awaitingRequest = nil
end

local function loginListenerForTokenExpired(event)
	if (event.cancelled) then
		awaitingRequest = nil
	elseif (event.isError) then
		loginErrorForAwaitingRequest(event)
	else
		local response = json.decode(event[1].response)
		if (response.code) then
			-- loginErrorForAwaitingRequest(event)
			networkFunction.logout()
			native.showAlert(localization.getLocalization("login_loginExpiredlogin_loginExpired"), localization.getLocalization("login_loginExpiredPleaseLoginAgain"), {localization.getLocalization("ok")})
		else
			sessionToken = response.session
			runAwaitingRequest()
		end
	end
end

local function performNetworkFunction(networkFnc, params, listener)
	if (type(listener) ~= "function") then
		listener = nil
	end
	if (awaitingRequest) then
		awaitingRequest[#awaitingRequest + 1] = {fnc = networkFnc, params = params, listener = listener}
		return {}
	else
		local function sessionInvalidLogin()
			if (awaitingRequest) then
				awaitingRequest[#awaitingRequest + 1] = {fnc = networkFnc, params = params, listener = listener}
			else
				if (login(loginListenerForTokenExpired) == nil) then
					if (listener) then
						local event = {
											code = API_ERROR_CODE_SESSION_INVALID,
											response = json.encode({code = API_ERROR_CODE_SESSION_INVALID})
										}
						return listener(event)
					end
				else
					awaitingRequest = {
										{fnc = networkFnc, params = params, listener = listener},
										}
				end
			end
		end
		local function networkFncListener(event)
			if (event.isError) then
				if (listener) then
					return listener(event)
				end
			elseif (event[1].response) then
				local response = json.decode(event[1].response)
				if ((response ~= nil) and (response.code == API_ERROR_CODE_SESSION_INVALID)) then
					sessionInvalidLogin()
				else
					if (listener) then
						return listener(event)
					end
				end
			end
		end
		if (sessionToken) then
			return networkFnc(params, networkFncListener)
		else
			sessionInvalidLogin()
		end
	end
end

local function filterTable(table, filter)
	local returnTable = {}
	for i = 1, #filter do
		local key = filter[i]
		returnTable[key] = table[key]
	end
	return returnTable
end

local function convertToUrlParam(params)
	local paramsStr = ""
	for k, v in pairs(params) do
		paramsStr = paramsStr .. "&" .. k .. "=" .. tostring(v)
	end
	return string.gsub(paramsStr, "^(&)", "")
end

---------------------------------------------------------------------------------
-- Push Setting / Notification
---------------------------------------------------------------------------------
local function createTableForRegisterDevice(token)
	local returnTable = {
							token = pushToken
						}
	local platformNameStr = system.getInfo("platformName")
	if (platformNameStr == "Android") then
		returnTable.os = "Android"
	else
		returnTable.os = "iOS"
	end
	return returnTable
end

-- Set Push Device Token
function networkFunction.setPushDeviceToken(token)
	pushToken = token
end

local function stopRegistering()
	if (registerPushTimer) then
		timer.cancel(registerPushTimer)
		registerPushTimer = nil
	end
	if (pushDeviceRequest) then
		networkHandler.cancelRequest(pushDeviceRequest)
		pushDeviceRequest = nil
	end
end

local function registerPushDeviceListener(event)
	if (event.isError) then
		return
	else
		stopRegistering()
	end
end

-- Register Push Device
local function registerPushDevice(params, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = json.encode(params)
							}
	apiParams[1].url = API_DEVICE_BASE
	apiParams[1].method = "POST"
	pushDeviceRequest = networkHandler.requestNetwork(apiParams, listener, "registerPushDevice")
end
local function registerDevice()
	if (pushDeviceRequest) then
		networkHandler.cancelRequest(pushDeviceRequest)
		pushDeviceRequest = nil
	end
	if (pushToken ~= nil) then
		local dataToSend = createTableForRegisterDevice(pushToken)
		performNetworkFunction(registerPushDevice, dataToSend, registerPushDeviceListener)
	end
end
function networkFunction.registerPushDevice()
	stopRegistering()
	registerDevice()
	registerPushTimer = timer.performWithDelay(15000, registerDevice, 0)
end

-- Unregister Push Device
local function unregisterPushDevice(params, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = json.encode(params)
							}
	apiParams[1].url = API_DEVICE_BASE
	apiParams[1].method = "DELETE"
	pushDeviceRequest = networkHandler.requestNetwork(apiParams, listener, "unregisterPushDevice")
end
local function unregisterDevice()
	if (pushDeviceRequest) then
		networkHandler.cancelRequest(pushDeviceRequest)
		pushDeviceRequest = nil
	end
	if (pushToken ~= nil) then
		local dataToSend = createTableForRegisterDevice(pushToken)
		performNetworkFunction(unregisterPushDevice, dataToSend, registerPushDeviceListener)
	end
end

function networkFunction.unregisterPushDevice()
	stopRegistering()
	unregisterDevice()
	registerPushTimer = timer.performWithDelay(15000, unregisterDevice, 0)
end

-- Get Notification List
local function getNotificationList(params, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
							}
	apiParams[1].url = API_NOTIFICATION_BASE
	apiParams[1].method = "GET"
	return networkHandler.requestNetwork(apiParams, listener, "getNotificationList")
end
function networkFunction.getNotificationList(listener)
	return performNetworkFunction(getNotificationList, {}, listener)
end







---------------------------------------------------------------------------------
-- Files
---------------------------------------------------------------------------------
function networkFunction.getFilePath(filename)
	if ((type(filename) ~= "string") or (filename == "")) then
		return nil
	end
	return API_FILE_BASE .. "?filename=" .. filename
end

---------------------------------------------------------------------------------
-- Member access
---------------------------------------------------------------------------------
-- format of params:
--   path
--   [baseDir]
function networkFunction.uploadProfilePic(params, listener)
	local function uploadPicListener(event)
		if (type(listener) == "function") then
			if (event[1].isError) then
				if (event[1].isFileNotFound) then
					event.fileNotFound = true
				elseif (event.retryTimes >= 3) then
					event.networkError = true
				end
			else
				local response = json.decode(event[1].response)
				event.filename = response.filename
			end
			return listener(event)
		end
	end
	if (params.path) then
		local apiParams = createParamsForApiNumber(1)
		apiParams[1].params = {
									headers = createVorumNetworkHeader(),
									body = {
												filename = params.path,
												baseDirectory = params.baseDir,
											},
									-- progress = "upload",
								}
		apiParams[1].params.headers["Content-Type"] = "image/jpg"
		apiParams[1].url = API_FILE_BASE
		apiParams[1].method = "POST"
		return networkHandler.requestNetwork(apiParams, uploadPicListener, "uploadProfilePic")
	end
	return nil
end

-- format of userData:
--   email
--   password
--   fb_token
--   name
--   profile_pic
--   country
--   phone
--   dob
--   gender
function networkFunction.signup(userData, listener)
	local dataToSend = deepCopyTable(userData)
	dataToSend.username = dataToSend.email
	local function signupListener(event)
		if (event.isError) then
			return listener(event)
		else
			local response = json.decode(event[1].response)
			if (response.code == nil) then
				if (dataToSend.fb_token) then
					userFbLoginData = {
											fb_token = dataToSend.fb_token
										}
				else
					userEmailLoginData = {
											username = dataToSend.username,
											password = dataToSend.password,
										}
				end
				sessionToken = response.session
			end
			return listener(event)
		end
	end
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(),
								body = json.encode(dataToSend)
							}
	apiParams[1].url = API_USER_BASE .. "/signup"
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, signupListener, "register")
end

-- format of params:
--   email
--   password
--   sessionToken
function networkFunction.updateLoginData(params)
	local username = params.username or params.email
	if (userEmailLoginData) then
		if (username) then
			userEmailLoginData.username = username
		end
		if (params.password) then
			userEmailLoginData.password = params.password
		end
	elseif ((username ~= nil) and (params.password ~= nil)) then
		userEmailLoginData = {
								username = username,
								password = params.password,
							}
	end
	if (params.sessionToken) then
		sessionToken = params.sessionToken
	end
end

-- format of params:
--   email
--   password
function networkFunction.login(params, listener)
	if (awaitingRequest) then
		return nil
	end
	if (type(listener) ~= "function") then
		listener = nil
	end
	local function loginListener(event)
		local response = {}
		if (event.isError ~= true) then
			local response = json.decode(event[1].response)
			if (response.code == nil) then
				sessionToken = response.session
			end
		end
		local listenerReturn, listenerReturnOption
		if (listener) then
			listenerReturn, listenerReturnOption = listener(event)
		end
		if (listenerReturn ~= false) then
			if ((event.cancelled) or (event.isError) or (response.code ~= nil)) then
				awaitingRequest = nil
			else
				runAwaitingRequest()
			end
		end
		return listenerReturn, listenerReturnOption
	end
	networkFunction.updateLoginData(params)
	userFbLoginData = nil
	return login(loginListener)
end

-- format of params:
--   fbToken
--   sessionToken
function networkFunction.updateFbLoginData(params)
	if (params.fbToken) then
		userFbLoginData = {
								fb_token = params.fbToken
							}
	end
	if (params.sessionToken) then
		sessionToken = params.sessionToken
	end
end

-- Facebook Login
function networkFunction.fbLogin(fbToken, listener)
	if (awaitingRequest) then
		return nil
	end
	if (type(listener) ~= "function") then
		listener = nil
	end
	local function loginListener(event)
		local response = {}
		if (event.isError ~= true) then
			local response = json.decode(event[1].response)
			if (response.code == nil) then
				sessionToken = response.session
			end
		end
		local listenerReturn, listenerReturnOption
		if (listener) then
			listenerReturn, listenerReturnOption = listener(event)
		end
		if (listenerReturn ~= false) then
			if ((event.cancelled) or (event.isError) or (response.code ~= nil)) then
				awaitingRequest = nil
			else
				runAwaitingRequest()
			end
		end
		return listenerReturn, listenerReturnOption
	end
	networkFunction.updateFbLoginData({fbToken = fbToken})
	return login(loginListener)
end

-- Logout
function networkFunction.logout()
	networkHandler.cancelAllRequest()
	native.setActivityIndicator(false)
	saveData.delete(global.userDataPath)--delete user data
	local header = headTabFnc.getHeader()
	header:toBack()
	header.alpha = 0
	local tabbar = headTabFnc.getTabbar()
	tabbar:toBack()	
	tabbar.alpha = 0
	storyboard.gotoScene("Scene.LoginPageScene",goToLoginSceneOption)
	networkFunction.unregisterPushDevice()

	userEmailLoginData = nil
	userFbLoginData = nil
	sessionToken = nil
end

local function fbLinkAccount(params, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = json.encode(params)
							}
	apiParams[1].url = API_USER_BASE .. "/link"
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, listener, "fbLinkAccount")
end
function networkFunction.fbLinkAccount(facebookToken, listener)
	return performNetworkFunction(fbLinkAccount, {fb_token = facebookToken}, listener)
end

-- Get User Data
local function getUserData(params, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
							}
	apiParams[1].url = API_USER_BASE
	apiParams[1].method = "GET"
	return networkHandler.requestNetwork(apiParams, listener, "getUserData")
end
function networkFunction.getUserData(listener)
	return performNetworkFunction(getUserData, {}, listener)
end

-- Forget Password
function networkFunction.forgetPassword(email, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(),
								body = "{\"username\":\"" .. email .. "\"}"
							}
	apiParams[1].url = API_USER_BASE .. "/forget_password"
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, listener, "forgetPassword")
end

-- Resend verification email
function networkFunction.resendVerificationEmail(email, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(),
								body = "{\"email\":\"" .. email .. "\"}"
							}
	apiParams[1].url = API_USER_BASE .. "/resend_activiation_email"
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, listener, "forgetPassword")
end

-- Edit User Data
local function updateUserData(userData, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = json.encode(userData)
							}
	apiParams[1].url = API_USER_BASE
	apiParams[1].method = "PUT"
	return networkHandler.requestNetwork(apiParams, listener, "updateUserData")
end
function networkFunction.updateUserData(userData, listener)
	local dataToSend = deepCopyTable(userData)
	return performNetworkFunction(updateUserData, dataToSend, listener)
end

---------------------------------------------------------------------------------
-- Post
---------------------------------------------------------------------------------
-- format of photoList:
--   questionPic {path[, baseDir]}
--   answerPicA {path[, baseDir]}
--   answerPicB {path[, baseDir]}
--   answerPicC {path[, baseDir]}
--   answerPicD {path[, baseDir]}
--   couponPic {path[, baseDir]}
local POST_PIC_TABLE = {"answerPicA", "answerPicB", "answerPicC", "answerPicD", "questionPic", "couponPic"}
function networkFunction.uploadPostPic(photoList, listener)
	local finalPicLoc = {}
	local uploadErrorList = {}
	local imgUploadRequestTable = {}
	local picUploadingCount = 0
	local filteredPhotoList = filterTable(photoList, POST_PIC_TABLE)

	local function uploadPicListener(event)
		local keyForTable = event.key
		local uploadedData
		if (event[1].isError) then
			if (event[1].isFileNotFound) then
				uploadErrorList[#uploadErrorList + 1] = {key = keyForTable, reason = "notFound"}
			elseif (event.retryTimes >= 3) then
				uploadErrorList[#uploadErrorList + 1] = {key = keyForTable, reason = "networkError"}
			else
				return false
			end
		else
			local response = json.decode(event[1].response)
			uploadedData = {key = keyForTable, filename = response.filename}
		end
		picUploadingCount = picUploadingCount - 1
		if (type(listener) == "function") then
			if (picUploadingCount == 0) then
				local returnData = {}
				returnData.uploadedData = uploadedData
				if (#uploadErrorList > 0) then
					returnData.uploadErrorList = uploadErrorList
				end
				returnData.isFinished = true
				listener(returnData)
			elseif (uploadedData) then
				local returnData = {}
				returnData.uploadedData = uploadedData
				listener(returnData)
			end
		end
	end
	for i = 1, #POST_PIC_TABLE do
		local key = POST_PIC_TABLE[i]
		if (photoList[key]) then
			if (photoList[key].path) then
				local apiParams = createParamsForApiNumber(1)
				apiParams[1].params = {
											headers = createVorumNetworkHeader(),
											body = {
														filename = photoList[key].path,
														baseDirectory = photoList[key].baseDir,
													},
											-- progress = "upload",
										}
				apiParams[1].params.headers["Content-Type"] = "image/jpg"
				apiParams[1].url = API_FILE_BASE
				apiParams[1].method = "POST"
				picUploadingCount = picUploadingCount + 1
				local request = networkHandler.requestNetwork(apiParams, uploadPicListener, key)
				imgUploadRequestTable[picUploadingCount] = request
			else
				uploadErrorList[#uploadErrorList + 1] = {key = key, reason = "notFound"}
			end
		end
	end
	if (#imgUploadRequestTable > 0) then
		return imgUploadRequestTable
	end
	return nil
end

-- Create Post
-- format of params:
--   post{}
--     title
--     text
--     link
--     post_duration
--     isAnonymous
--     friendOnly
--     tag
--     hide_result
--     coupon{}
--       text
--     choices[]
--       text
--   photoList      -- Photo List From "uploadPostPic"
local function createPost(params, listener)
	local postData = params.post
	local choicesData = postData.choices
	local photoList = params.photoList
	if (type(photoList) == "table") then
		for i = 1, #choicesData do
			choicesData[i].pic = params.photoList[POST_PIC_TABLE[i]]
			choicesData[i].letter = CHOICE_LETTER[i]
		end
		local choiceIdx = #choicesData + 1
		for i = choiceIdx, #CHOICE_LETTER do
			local picFilename = params.photoList[POST_PIC_TABLE[i]]
			if ((picFilename ~= nil) and (picFilename ~= "")) then
				choicesData[choiceIdx].letter = CHOICE_LETTER[choiceIdx]
				choicesData[choiceIdx].pic = picFilename
				choiceIdx = choiceIdx + 1
			end
		end
		postData.pic = photoList.questionPic
		if (photoList.couponPic) then
			if (postData.coupon == nil) then
				postData.coupon = {}
			end
			postData.coupon.pic = photoList.couponPic
		end
	end
	if (#choicesData < 2) then
		if (type(listener) == "function") then
			local event = {isError = true, notEnoughChoice = true}
			listener(event)
		end
		return
	end
	if (postData.tag) then
		postData.tags = {postData.tag}
		postData.tag = nil
	end
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = json.encode(postData)
							}
	apiParams[1].url = API_POST_BASE
	apiParams[1].method = "POST"
-- print(json.encode(postData))
	return networkHandler.requestNetwork(apiParams, listener, "createPost")
end
function networkFunction.createPost(params, listener)
	local dataToSend = deepCopyTable(params)
	return performNetworkFunction(createPost, dataToSend, listener)
end

local function renameKeyOfTable(table, origKey, newKey)
	if (table[origKey]) then
		table[newKey] = table[origKey]
		table[origKey] = nil
	end
end

local function convertPostData(postData)
	renameKeyOfTable(postData, "text", "description")
	renameKeyOfTable(postData, "view", "views")
	renameKeyOfTable(postData, "pic", "post_pic")
	renameKeyOfTable(postData, "create_time", "createdAt")
	local userVotedChoiceId
	if (postData.user_vote) then
		userVotedChoiceId = postData.user_vote.choice_id
	end
	local choicesList = postData.choices
	local choiceTotal = #choicesList
	for i = 1, choiceTotal do
		local choiceLetter = choicesList[i].letter
		choicesList[i].letter = nil
		renameKeyOfTable(choicesList[i], "pic", "choice_pic")
		if (choicesList[i].id == userVotedChoiceId) then
			postData.userVoted = choiceLetter
		end
		choicesList[choiceLetter] = choicesList[i]
		choicesList[i] = nil
	end
	return postData
end

-- Get One Post
local function getPost(params, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
							}
	apiParams[1].url = API_POST_BASE .. "/" .. tostring(params.id)
	apiParams[1].method = "GET"
	return networkHandler.requestNetwork(apiParams, listener, "getPost")
end
function networkFunction.getPost(postId, listener)
	local function getPostListener(event)
		if (type(listener) == "function") then
			if (event.isError) then
				return listener(event)
			else
				local response = json.decode(event[1].response)
				if (response.code) then
					event.isError = true
					event.errorCode = response.code
					listener(event)
				else
					event.postData = convertPostData(response[1])
					listener(event)
				end
			end
		end
	end
	local dataToSend = {id = postId}
	return performNetworkFunction(getPost, dataToSend, getPostListener)
end

-- Get Vorum Post
-- format of params:
--   offset       -- post offset
--   limit
--   sort         -- "voted_all", "voted_month", "voted_week"
--   tag
--   isMyCountry  -- boolean, true to filtered by user country
local function getVorumPost(params, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
							}
	if (params.isMyCountry) then
		params.mycountry = "true"
	end
	params.isMyCountry = nil
	local urlParams = convertToUrlParam(params)
	apiParams[1].url = API_POST_BASE .. "/public"
	if (urlParams ~= "") then
		apiParams[1].url = apiParams[1].url .. "?" .. urlParams
	end
	apiParams[1].method = "GET"
	return networkHandler.requestNetwork(apiParams, listener, "getVorumPost")
end
function networkFunction.getVorumPost(params, listener)
	local function getVorumPostListener(event)
		if (type(listener) == "function") then
			if (event.isError) then
				return listener(event)
			else
				local response = json.decode(event[1].response)
				if (response.code) then
					event.isError = true
					event.errorCode = response.code
					listener(event)
				else
					event.postData = {}
					for i = 1, #response do
						event.postData[i] = convertPostData(response[i])
					end
					listener(event)
				end
			end
		end
	end
	local dataToSend = deepCopyTable(params)
	return performNetworkFunction(getVorumPost, dataToSend, getVorumPostListener)
end

-- -- Get My Post
-- -- format of params:
-- --   offset       -- post offset
-- --   limit
-- local function getMyPost(params, listener)
-- 	local function getMyPostListener(event)
-- 		if (type(listener) == "function") then
-- 			if (event.isError) then
-- 				return listener(event)
-- 			else
-- 				local response = json.decode(event[1].response)
-- 				if (response.code == nil) then
-- 					event.postData = {}
-- 					for i = 1, #response do
-- 						event.postData[i] = convertPostData(response[i])
-- 					end
-- 					listener(event)
-- 				end
-- 			end
-- 		end
-- 	end
-- 	local apiParams = createParamsForApiNumber(1)
-- 	apiParams[1].params = {
-- 								headers = createVorumNetworkHeader(sessionToken),
-- 							}
-- 	local urlParams = ""
-- 	for k, v in pairs(params) do
-- 		urlParams = urlParams .. convertToUrlParam(k, v)
-- 	end
-- 	apiParams[1].url = API_POST_BASE .. "/my"
-- 	if (urlParams ~= "") then
-- 		apiParams[1].url = apiParams[1].url .. "?" .. urlParams
-- 	end
-- 	apiParams[1].method = "GET"
-- 	return networkHandler.requestNetwork(apiParams, getMyPostListener, "getMyPost")
-- end
-- function networkFunction.getMyPost(params, listener)
-- 	local dataToSend = deepCopyTable(params)
-- 	return performNetworkFunction(getMyPost, dataToSend, listener)
-- end

-- -- Get Voted Post
-- -- format of params:
-- --   offset       -- post offset
-- --   limit
-- local function getVotedPost(params, listener)
-- 	local function getVotedPostListener(event)
-- 		if (type(listener) == "function") then
-- 			if (event.isError) then
-- 				return listener(event)
-- 			else
-- 				local response = json.decode(event[1].response)
-- 				if (response.code == nil) then
-- 					event.postData = {}
-- 					for i = 1, #response do
-- 						event.postData[i] = convertPostData(response[i])
-- 					end
-- 					listener(event)
-- 				end
-- 			end
-- 		end
-- 	end
-- 	local apiParams = createParamsForApiNumber(1)
-- 	apiParams[1].params = {
-- 								headers = createVorumNetworkHeader(sessionToken),
-- 							}
-- 	local urlParams = ""
-- 	for k, v in pairs(params) do
-- 		urlParams = urlParams .. convertToUrlParam(k, v)
-- 	end
-- 	apiParams[1].url = API_POST_BASE .. "/voted"
-- 	if (urlParams ~= "") then
-- 		apiParams[1].url = apiParams[1].url .. "?" .. urlParams
-- 	end
-- 	apiParams[1].method = "GET"
-- 	return networkHandler.requestNetwork(apiParams, getMyPostListener, "getVotedPost")
-- end
-- function networkFunction.getVotedPost(params, listener)
-- 	local dataToSend = deepCopyTable(params)
-- 	return performNetworkFunction(getVotedPost, dataToSend, listener)
-- end



-- Me tab get post
-- format of params:
--   offset       -- post offset
--   limit
local function meTabGetPost(params, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
							}
	apiParams[1].url = API_POST_BASE .. "/" .. params.apiEndPoint
	local urlParams = convertToUrlParam(params.params)
	if (urlParams ~= "") then
		apiParams[1].url = apiParams[1].url .. "?" .. urlParams
	end
	apiParams[1].method = "GET"
	return networkHandler.requestNetwork(apiParams, listener, params.apiEndPoint .. "Post")
end
local function createGetPostListener(listener)
	return function(event)
		if (type(listener) == "function") then
			if (event.isError) then
				return listener(event)
			else
				local response = json.decode(event[1].response)
				if (response.code) then
					event.isError = true
					event.errorCode = response.code
					listener(event)
				else
					event.postData = {}
					for i = 1, #response do
						event.postData[i] = convertPostData(response[i])
					end
					listener(event)
				end
			end
		end
	end
end
function networkFunction.getMyPost(params, listener)
	local dataToSend = {
							apiEndPoint = "my",
							params = deepCopyTable(params)
						}
	return performNetworkFunction(meTabGetPost, dataToSend, createGetPostListener(listener))
end
function networkFunction.getVotedPost(params, listener)
	local dataToSend = {
							apiEndPoint = "voted",
							params = deepCopyTable(params)
						}
	return performNetworkFunction(meTabGetPost, dataToSend, createGetPostListener(listener))
end
function networkFunction.getFriendPost(params, listener)
	local dataToSend = {
							apiEndPoint = "friend",
							params = deepCopyTable(params)
						}
	return performNetworkFunction(meTabGetPost, dataToSend, createGetPostListener(listener))
end



---------------------------------------------------------------------------------
-- Post Action
---------------------------------------------------------------------------------
-- Vote Post
local function votePost(params, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = json.encode(params)
							}
	apiParams[1].url = API_VOTE_BASE
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, listener, "votePost")
end
function networkFunction.votePost(params, listener)
	local function getResultListener(event)
		if (event.isError) then
			listener(event)
			return true
		else
			event.result = event.postData.choices
			listener(event)
		end
	end
	local function votePostListener(event)
		if (event.isError) then
			if (event.retryTimes >= 3) then
				if (type(listener) == "function") then
					listener(event)
					return true
				end
				return false
			end
		else
			local response = json.decode(event[1].response)
			if (response.code) then
				event.isError = true
				event.errorCode = response.code
				listener(event)
			else
				networkFunction.getPost(params.post_id, getResultListener)
			end
		end
	end
	local dataToSend = deepCopyTable(params)
	return performNetworkFunction(votePost, dataToSend, votePostListener)
end

-- Report Post
local function reportPost(params, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = json.encode(params)
							}
	apiParams[1].url = API_POST_BASE .. "/report"
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, listener, "reportPost")
end
function networkFunction.reportPost(postId, listener)
	local dataToSend = {id = postId}
	return performNetworkFunction(reportPost, dataToSend, listener)
end

-- Share Post
local function sharePost(params, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = json.encode(params)
							}
	apiParams[1].url = API_POST_BASE .. "/share"
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, listener, "sharePost")
end
function networkFunction.sharePost(postId, listener)
	local dataToSend = {id = postId}
	return performNetworkFunction(sharePost, dataToSend, listener)
end

-- Push Post
local function pushPost(params, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = json.encode(params)
							}
	apiParams[1].url = API_POST_BASE .. "/push"
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, listener, "pushPost")
end
function networkFunction.pushPost(postId, listener)
	local dataToSend = {id = postId}
	return performNetworkFunction(pushPost, dataToSend, listener)
end





---------------------------------------------------------------------------------
-- Search
---------------------------------------------------------------------------------
-- Search User
-- format of params:
--   offset
--   limit
--   searchStr
local function searchUser(params, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = json.encode(params)
							}
	params.searchStr = url.escape(string.lower(params.searchStr))
	local paramsStr = convertToUrlParam(params)
	apiParams[1].url = API_USER_BASE .. "/search?" .. paramsStr
	apiParams[1].method = "GET"
	return networkHandler.requestNetwork(apiParams, listener, "searchUser")
end
function networkFunction.searchUser(params, listener)
	local dataToSend = deepCopyTable(params)
	return performNetworkFunction(searchUser, dataToSend, listener)
end

-- Search Post
-- format of params:
--   offset
--   limit
--   searchStr
local function searchPost(params, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = json.encode(params)
							}
	params.searchStr = url.escape(string.lower(params.searchStr))
	local paramsStr = convertToUrlParam(params)
	apiParams[1].url = API_POST_BASE .. "/search?" .. paramsStr
	apiParams[1].method = "GET"
	return networkHandler.requestNetwork(apiParams, listener, "searchPost")
end
function networkFunction.searchPost(params, listener)
	local dataToSend = deepCopyTable(params)
	return performNetworkFunction(searchPost, dataToSend, listener)
end





---------------------------------------------------------------------------------
-- Coupon
---------------------------------------------------------------------------------
-- Get User Coupon
local function getUserCoupon(params, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = json.encode(params)
							}
	apiParams[1].url = API_COUPON_BASE .. "/user"
	apiParams[1].method = "GET"
	return networkHandler.requestNetwork(apiParams, listener, "getUserCoupon")
end
function networkFunction.getUserCoupon(listener)
	local function getUserCouponListener(event)
		if (type(listener) == "function") then
			if (event.isError) then
				listenen(event)
			else
				local response = json.decode(event[1].response)
				if (response) then
					if (response.code) then
						event.isError = true
						event.errorCode = response.code
						listener(event)
					else
						event.couponData = response
					end
				else
					event.couponData = {}
				end
				listener(event)
			end
		end
	end
	return performNetworkFunction(getUserCoupon, {}, getUserCouponListener)
end



---------------------------------------------------------------------------------
-- Friend System
---------------------------------------------------------------------------------
local function removeAPNSString(str)
	if (str) then
		local strStartIdx = string.find(str, "{")
		if ((strStartIdx ~= nil) and (strStartIdx > 1)) then
			str = string.sub(str, strStartIdx, string.len(str))
		end
	end
	return str
end

-- Get User Data
local function getMemberData(params, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
							}
	apiParams[1].url = API_USER_BASE .. "/" .. tostring(params.memberId)
	apiParams[1].method = "GET"
	return networkHandler.requestNetwork(apiParams, listener, "getMemberData")
end
function networkFunction.getMemberData(memberId, listener)
	local function getMemberDataListener(event)
		if (type(listener) == "function") then
			if (event.isError) then
				return listener(event)
			else
				local response = json.decode(event[1].response)
				if (response.code) then
					event.isError = true
					event.errorCode = response.code
					listener(event)
				else
					if (response ~= nil) then
						if (response.posts ~= nil) then
							event.postData = {}
							for i = 1, #response.posts do
								event.postData[i] = convertPostData(response.posts[i])
							end
							response.posts = nil
						end
						event.userData = response
					end
					listener(event)
				end
			end
		end
	end
	local dataToSend = {memberId = memberId}
	return performNetworkFunction(getMemberData, dataToSend, getMemberDataListener)
end

-- add friend
local function addFriend(params, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = json.encode(params)
							}
	apiParams[1].url = API_FRIEND_BASE .. "/add"
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, listener, "addFriend")
end
function networkFunction.addFriend(params, listener)
	local function addFriendListener(event)
		if (type(listener) == "function") then
			if (event[1].response) then
				event[1].response = removeAPNSString(event[1].response)
			end
			listener(event)
		end
	end
	local dataToSend = {id = params.id}
	return performNetworkFunction(addFriend, dataToSend, addFriendListener)
end

-- cancel request
local function cancelFriendRequest(params, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = json.encode(params)
							}
	apiParams[1].url = API_FRIEND_BASE .. "/cancel"
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, listener, "cancelFriendRequest")
end
function networkFunction.cancelFriendRequest(params, listener)
	local dataToSend = {id = params.id}
	return performNetworkFunction(cancelFriendRequest, dataToSend, listener)
end

-- accept request
local function acceptFriendRequest(params, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = json.encode(params)
							}
	apiParams[1].url = API_FRIEND_BASE .. "/accept"
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, listener, "acceptFriendRequest")
end
function networkFunction.acceptFriendRequest(params, listener)
	local function acceptFriendRequestListener(event)
		if (type(listener) == "function") then
			if (event[1].response) then
				event[1].response = removeAPNSString(event[1].response)
			end
			listener(event)
		end
	end
	local dataToSend = {id = params.id}
	return performNetworkFunction(acceptFriendRequest, dataToSend, acceptFriendRequestListener)
end

-- reject request
local function rejectFriendRequest(params, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = json.encode(params)
							}
	apiParams[1].url = API_FRIEND_BASE .. "/reject"
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, listener, "rejectFriendRequest")
end
function networkFunction.rejectFriendRequest(params, listener)
	local dataToSend = {id = params.id}
	return performNetworkFunction(rejectFriendRequest, dataToSend, listener)
end

-- unfriend
local function unfriend(params, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = json.encode(params)
							}
	apiParams[1].url = API_FRIEND_BASE .. "/unfriend"
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, listener, "unfriend")
end
function networkFunction.unfriend(params, listener)
	local dataToSend = {id = params.id}
	return performNetworkFunction(unfriend, dataToSend, listener)
end

-- get friend request list
local function getRequestList(params, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = json.encode(params)
							}
	apiParams[1].url = API_FRIEND_BASE .. "/request"
	apiParams[1].method = "GET"
	return networkHandler.requestNetwork(apiParams, listener, "getRequestList")
end
function networkFunction.getRequestList(memberId, listener)
	local function getRequestListener(event)
		if (type(listener) == "function") then
			if (event.isError) then
			else
				local response = json.decode(event[1].response)
				if (response == nil) then
					event.hasRequest = "0"
				elseif (response.code) then
					event.isError = true
					event.errorCode = response.code
				else
					event.hasRequest = "0"
					if (response[1]) then
						for i = 1, #response do
							if (response[i].id == memberId) then
								event.hasRequest = "1"
								break
							end
						end
					else
						if (response.id == memberId) then
							event.hasRequest = "1"
						end
					end
				end
			end
		end
		listener(event)
	end
	return performNetworkFunction(getRequestList, {}, getRequestListener)
end


-- Get Member Data, post and request status
local function cancelGetMemberDataWithFriendStatus(networkRequestList)
	for i = 1, #networkRequestList do
		networkHandler.cancelRequest(networkRequestList[i])
	end
end
function networkFunction.getMemberDataWithFriendStatus(memberId, listener)
	local getMemberResponse
	local hasRequestResponse
	local function getMemberDataListener(event)
		if (type(listener) == "function") then
			if (event.isError) then
				cancelGetMemberDataWithFriendStatus(networkRequestList)
				listener(event)
			else
				getMemberResponse = {postData = event.postData, userData = event.userData}
				if (hasRequestResponse~=nil) then
					getMemberResponse.hasRequest = hasRequestResponse
					listener(getMemberResponse)
				end
			end
		end
	end
	local function getRequestListener(event)
		if (type(listener) == "function") then
			if (event.isError) then
				cancelGetMemberDataWithFriendStatus(networkRequestList)
				listener(event)
			else
				hasRequestResponse = event.hasRequest
				if (getMemberResponse~=nil) then
					getMemberResponse.hasRequest = hasRequestResponse
					listener(getMemberResponse)
				end
			end
		end
	end
	local networkRequestList = {}
	networkRequestList[1] = networkFunction.getMemberData(memberId, getMemberDataListener)
	networkRequestList[2] = networkFunction.getRequestList(memberId, getRequestListener)
	return networkRequestList
end

-- Add / Cancel Friend Request
function networkFunction.friendRequestAction(params, listener)
	local function cancelRequestListener(event)
		if (type(listener) == "function") then
			if (event.isError) then
			else
				event.cancelRequest = true
			end
			listener(event)
		end
	end
	local function addFriendListener(event)
		if (event.isError) then
			if (type(listener) == "function") then
				listener(event)
			end
		else
			if (event[1].response) then
				event[1].response = removeAPNSString(event[1].response)
			end
			listener(event)
			local response = json.decode(event[1].response)
			if (response) then
				local code = response.code
				if (code == 37) then			-- "Friend request already sent"
					event.requestSent = true
				elseif (code == 36) then		-- "You are friends now"
					event.isFriend = true
				elseif (code == 35) then		-- "Friend request already sent"
					native.showAlert(localization.getLocalization("friendRequest_alreadyRequest"),
										localization.getLocalization("friendRequest_alreadyRequest_cancel"),
										{localization.getLocalization("yes"), localization.getLocalization("no")},
										function(e)
											if (e.index == 1) then
												networkFunction.cancelFriendRequest(params, cancelRequestListener)
											end
										end)
					return
				elseif (code == 34)	then			-- Already friend
					event.isError = true
				else
					event.isError = true
				end
			else
				event.isError = true
			end
			if (type(listener) == "function") then
				listener(event)
			end
		end
	end
	networkFunction.addFriend(params, addFriendListener)
end





---------------------------------------------------------------------------------
-- Get Files
---------------------------------------------------------------------------------
function networkFunction.getVorumFile(url, path, listener)
	local vorumFileUrl = networkFunction.getFilePath(url)
	if (vorumFileUrl) then
		return networkFile.getDownloadFile(vorumFileUrl, path, {headers = createVorumNetworkHeader(sessionToken)}, listener)
	end
	return nil
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
