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

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
-- local API_GET_NEWS = "http://office.jointedheart.com:8051/mobile_api/getLatestTimeForNews.php"
-- local API_REG_INVOICE = "http://office.jointedheart.com:8051/mobile_api/getRegisteredInvoice.php"
-- local API_GET_SHOP = "http://office.jointedheart.com:8051/mobile_api/getLatestTimeForShopLists.php"

local API_USER_BASE = "https://api.parse.com/1/users/"
local API_LOGIN_BASE = "https://api.parse.com/1/login/"
local API_CLASS_BASE = "https://api.parse.com/1/classes/"
local API_FNC_BASE = "https://api.parse.com/1/functions/"
local API_FILE_BASE = "https://api.parse.com/1/files/"

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

local function createVorumNetworkHeader(sessionToken)
	local headers = {
						["Content-Type"] = "application/json",
						["X-Parse-Application-Id"] = "FeOHPlcGeWoAxydyXBYvMrNU28JBcBAKsVRagLZd",
						["X-Parse-REST-API-Key"] = "X1EqrSCZ2CJAEummQiHpnegKV1Rway6ob7skEIdJ",
					}
	if (sessionToken) then
		headers["X-Parse-Session-Token"] = sessionToken
	end
	return headers
end

-- search posts with creator ObjectId "tjXqNLob0C" after time "2015-02-10T11:20:34.032Z"
-- https://api.parse.com/1/classes/Post?where={"user":{"__type":"Pointer","className":"_User","objectId":"tjXqNLob0C"},"createdAt":{"$gt":{"__type":"Date","iso":"2015-02-10T11:20:34.032Z"}}}&limit=10

local function createParamsForApiNumber(number)
	local apiParams = {}
	for i = 1, number do
		apiParams[i] = {}
	end
	return apiParams
end

-- userData sample:
-- local userData = {}
-- userData.email = "test2@test.com"
-- userData.password = "abcd"
-- userData.name = "xxx"
-- userData.phone = "90123456"
-- userData.dobString = "1000-02-10T11:20:34.032Z"
-- userData.gender = "M"
-- userData.facebook = {
-- id = "10153143686767340",
-- access_token = "CAAM2r8FBNlEBAKIZAo2jeLCFsuBAg13Dg2wErNcF3kuHrXyDQ1iwlpDb8tqlAutCngbEy1jLJujcj6Qa0QQtcyEukaXBlI1L2VS7ve0cuZCHxXkMbHvFLb5igWdOjU3bIrOhrF1baU8pmD9wFIgfGnoVja80cIep4tM4xDYeF0L7TSwMgCCoYT8zsKx1TwLSZBxIul7GuCDhrJIHmkUiNlHtlkIOxYZD",
-- expiration_date = "2015-04-10T11:20:34.032Z"
-- }
-- return:
--   code = nil: success
--                 objectId: user record ID
--                 sessionToken: session token for user
--   code = 202: email exist
function networkFunction.register(userData, listener)
	local apiParams = createParamsForApiNumber(1)
	userData.username = userData.email
	if (userData.dobString) then
		userData.dob = {}
		userData.dob["__type"] = "Date"
		userData.dob.iso = userData.dobString
		userData.dobString = nil
	end
	if (userData.gender ~= nil) then
		userData.gender = string.upper(userData.gender)
		if ((userData.gender ~= "M") and (userData.gender ~= "F")) then
			userData.gender = nil
		end
	end
	if (userData.facebook) then
		userData.authData = {}
		userData.authData.facebook = userData.facebook
		userData.facebook = nil
	end
	apiParams[1].params = {
								headers = createVorumNetworkHeader(),
								body = json.encode(userData)
							}
	apiParams[1].url = API_USER_BASE
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, listener, "register")
end

-- return:
--   code = nil: success
--                 objectId: user record ID
--                 sessionToken: session token for user
--   code = 101: invalid login / password
--   code = 200: missing username(email in this case)
--   code = 201: missing password
function networkFunction.login(email, password, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(),
							}

	apiParams[1].url = API_LOGIN_BASE .. string.format("?username=%s&password=%s", email, password)
	apiParams[1].method = "GET"
	return networkHandler.requestNetwork(apiParams, listener, "login")
end

-- return:
--   code = nil: success
--   code = 200: no facebook account reg in parse
--   code = 251: token expired
function networkFunction.fbLogin(id, accessToken, listener)
	local apiParams = createParamsForApiNumber(1)
	local userData = {
						authData = {
										facebook = {
														id = id,
														access_token = accessToken,
														expiration_date = "1000-01-01T00:00:00.000Z",
													}
									},
						username = ""
					}
	apiParams[1].params = {
								headers = createVorumNetworkHeader(),
								body = json.encode(userData)
							}
	apiParams[1].url = API_USER_BASE
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, listener, "loginFB")
end

function networkFunction.fbLinkAccount(accObjId, sessionToken, fbId, fbAccessToken, listener)
	local apiParams = createParamsForApiNumber(1)
	local userData = {
						authData = {
										facebook = {
														id = fbId,
														access_token = fbAccessToken,
														expiration_date = "1000-01-01T00:00:00.000Z",
													}
									},
					}
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = json.encode(userData)
							}
	apiParams[1].url = API_USER_BASE .. accObjId
	apiParams[1].method = "PUT"
	return networkHandler.requestNetwork(apiParams, listener, "linkFB")
end


---------------------------------------------------------------------------------
-- Create Post
---------------------------------------------------------------------------------


local POST_PIC_MAX_WIDTH = 640
local POST_PIC_MAX_HEIGHT = 1136
local POST_PIC_ASPECT_RATIO = POST_PIC_MAX_WIDTH / POST_PIC_MAX_HEIGHT
local IMG_SCALE_FOR_SCREEN = display.contentWidth / display.pixelWidth
local function resizePostPic(photoList)
	local returnList = {}
	for k, v in pairs(photoList) do
		if (type(v) == "table") then
			local img
			if (baseDir) then
				img = display.newImage(v.path, v.baseDir, true)
			else
				img = display.newImage(v.path, true)
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
				display.save(img, {filename = k .. ".png", baseDir = system.TemporaryDirectory, isFullResolution = true})
				display.remove(img)
				returnList[k] = {path = k .. ".png", baseDir = system.TemporaryDirectory}
			else
				returnList[k] = {}
			end
		end
	end
	for k, v in pairs(returnList) do
		print(k, v)
	end
	return returnList
end

local function filterTable(table, filter)
	local returnTable = {}
	for i = 1, #filter do
		local key = filter[i]
		returnTable[key] = table[key]
	end
	return returnTable
end

local POST_PIC_TABLE = {"answerPicA", "answerPicB", "answerPicC", "answerPicD", "questionPic"}

-- details of photoList:
--   isPicResized
--   questionPic {path[, baseDir]}
--   answerPicA {path[, baseDir]}
--   answerPicB {path[, baseDir]}
--   answerPicC {path[, baseDir]}
--   answerPicD {path[, baseDir]}
function networkFunction.uploadPostPic(sessionToken, photoList, listener)
	local finalPicLoc = {}
	local uploadErrorList = {}
	local imgUploadRequestTable = {}
	local uploadedPicNameInServer = {}
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
			uploadedPicNameInServer[keyForTable] = response.name
			uploadedData = {key = keyForTable, name = response.name, url = response.url}
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

	if (isPicResized ~= true) then
		finalPicLoc = resizePostPic(photoList)
	else
		finalPicLoc = photoList
	end
	for i = 1, #POST_PIC_TABLE do
		local key = POST_PIC_TABLE[i]
		if (finalPicLoc[key]) then
			if (finalPicLoc[key].path) then
				local apiParams = createParamsForApiNumber(1)
				apiParams[1].params = {
											headers = createVorumNetworkHeader(sessionToken),
											body = {
														filename = finalPicLoc[key].path,
														baseDirectory = finalPicLoc[key].baseDir,
													},
										}
				apiParams[1].params.headers["Content-Type"] = "image/png"
				apiParams[1].url = API_FILE_BASE .. key .. ".png"
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

local function createTableForParsePic(fileInfo)
	if (fileInfo) then
		return {name = fileInfo.name, url = fileInfo.url, ["__type"] = "File"}
	end
	return nil
end
-- details of photoList:
--   questionPic (string of "name" return from server)
--   answerPicA (string of "name" return from server)
--   answerPicB (string of "name" return from server)
--   answerPicC (string of "name" return from server)
--   answerPicD (string of "name" return from server)
function networkFunction.createPost(userId, sessionToken, postData, photoList, listener)
	local apiParams = createParamsForApiNumber(1)
	postData.post_pic = createTableForParsePic(photoList.questionPic)
	postData.ACL = {
							[userId] = {read = true, write = true},
							["*"] = {read = true},
						}
	for i = 1, #postData.choices do
		postData.choices[i].choice_pic = createTableForParsePic(photoList[POST_PIC_TABLE[i]])
	end
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = json.encode(postData)
							}
	print(apiParams[1].params.body)
	apiParams[1].url = API_FNC_BASE .. "createPost"
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, listener, "createPost")
end


---------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------


-- function networkFunction.getVorumPost([startDate, ]sessionToken[, postNumber][, tag][, listener])
function networkFunction.getVorumPost(...)
	local argIdx = 1
	local startDate, sessionToken, postNumber, tag, listener
	if (type(arg[argIdx]) == "number") then
		startDate = arg[argIdx]
		argIdx = argIdx + 1
	end
	sessionToken = arg[argIdx]
	argIdx = argIdx + 1
	if (type(arg[argIdx]) == "number") then
		postNumber = arg[argIdx]
		argIdx = argIdx + 1
	end
	if (type(arg[argIdx]) == "string") then
		tag = arg[argIdx]
		argIdx = argIdx + 1
	end
	if (type(arg[argIdx]) == "function") then
		listener = arg[argIdx]
		argIdx = argIdx + 1
	end
	local apiParams = createParamsForApiNumber(1)
	local paramsBody = {}
	if (startDate) then
		paramsBody.timeStamp = startDate
	end
	if (postNumber) then
		paramsBody.limit = postNumber
	end	
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = json.encode(paramsBody),
							}
	-- local urlParams = url.escape(string.format("?where={\"user\":{\"__type\":\"Pointer\",\"className\":\"_User\",\"objectId\":\"%s\"},\"createdAt\":{\"$gt\":{\"__type\":\"Date\",\"iso\":\"%s\"}}}&limit=%d", creator, startDate, postNumber))
	apiParams[1].method = "POST"
	apiParams[1].url = API_FNC_BASE .. "getPostAndShare"
	return networkHandler.requestNetwork(apiParams, listener, "getVorumPost")
	-- local urlParams = url.escape(string.format("?where={\"user\":{\"__type\":\"Pointer\",\"className\":\"_User\",\"objectId\":\"%s\"},\"createdAt\":{\"$gt\":{\"__type\":\"Date\",\"iso\":\"%s\"}}}&limit=%d", creator, startDate, postNumber))
	-- apiParams[1].url = API_CLASS_BASE .. "Post" .. urlParams
	-- return networkHandler.requestNetwork(apiParams, listener, "getVorumPost")
end

function networkFunction.getPostByCreator(creator, startDate, postNumber, sessionToken, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(),
							}
	local query = url.escape(string.format("?where={\"user\":{\"__type\":\"Pointer\",\"className\":\"_User\",\"objectId\":\"%s\"},\"createdAt\":{\"$gt\":{\"__type\":\"Date\",\"iso\":\"%s\"}}}&limit=%d", creator, startDate, postNumber))
	apiParams[1].url = API_CLASS_BASE .. "Post" .. query
	return networkHandler.requestNetwork(apiParams, listener, "getPostByCreator")
end

function networkFunction.searchUser(string, startIdx, resultNumber)
	
end

-- function networkFunction.getApiList1(listener)
-- 	local apiParams = createParamsForApiNumber(2)
-- 	apiParams[1].url = API_GET_NEWS
-- 	apiParams[2].url = API_REG_INVOICE
-- 	apiParams[2].params = {
-- 								body = string.format("{\"variable\":{\"member_id\":\"%s\",\"logintoken\":\"%s\",\"appid\":\"%s\"}}", "92558335", "ACL563QK7FVG9QPQ", "GF61GD9H1WDH3QHP"),
-- 								timeout = 10,
-- 							}
-- 	return networkHandler.requestNetwork(apiParams, listener, "ApiList1")
-- end

-- function networkFunction.getApiList2(listener)
-- 	local apiParams = createParamsForApiNumber(2)
-- 	apiParams[1].url = API_GET_SHOP
-- 	apiParams[2].url = API_REG_INVOICE
-- 	apiParams[2].params = {
-- 								body = string.format("{\"variable\":{\"member_id\":\"%s\",\"logintoken\":\"%s\",\"appid\":\"%s\"}}", "92558335", "ACL563QK7FVG9QPQ", "GF61GD9H1WDH3QHP"),
-- 								timeout = 10,
-- 							}
-- 	return networkHandler.requestNetwork(apiParams, listener, "ApiList2")
-- end

-- function networkFunction.getApiList3(listener)
-- 	local apiParams = createParamsForApiNumber(1)
-- 	apiParams[1].url = API_GET_SHOP
-- 	return networkHandler.requestNetwork(apiParams, listener, "ApiList3")
-- end

-- function networkFunction.getSimulatedApiList1(listener)
-- 	local apiParams = createParamsForApiNumber(2)
-- 	apiParams[1].url = API_GET_NEWS
-- 	apiParams[1].listenerEvent = simulatedNetworkHandler.makeSingleSimulatedNetworkEventResponse(false, "test1")
-- 	apiParams[2].url = API_REG_INVOICE
-- 	apiParams[2].params = {
-- 								body = string.format("{\"variable\":{\"member_id\":\"%s\",\"logintoken\":\"%s\",\"appid\":\"%s\"}}", "92558335", "ACL563QK7FVG9QPQ", "GF61GD9H1WDH3QHP"),
-- 								timeout = 10,
-- 							}
-- 	apiParams[2].listenerEvent = simulatedNetworkHandler.makeSingleSimulatedNetworkEventResponse(false, "test2")
-- 	return simulatedNetworkHandler.requestNetwork(apiParams, listener, "ApiList1")
-- end

-- function networkFunction.getSimulatedApiList2(listener)
-- 	local apiParams = createParamsForApiNumber(2)
-- 	apiParams[1].url = API_GET_SHOP
-- 	apiParams[1].listenerEvent = simulatedNetworkHandler.makeSingleSimulatedNetworkEventResponse(false, "test3")
-- 	apiParams[2].url = API_REG_INVOICE
-- 	apiParams[2].params = {
-- 								body = string.format("{\"variable\":{\"member_id\":\"%s\",\"logintoken\":\"%s\",\"appid\":\"%s\"}}", "92558335", "ACL563QK7FVG9QPQ", "GF61GD9H1WDH3QHP"),
-- 								timeout = 10,
-- 							}
-- 	apiParams[2].listenerEvent = simulatedNetworkHandler.makeSingleSimulatedNetworkEventResponse(false, "test4")
-- 	return simulatedNetworkHandler.requestNetwork(apiParams, listener, "ApiList2")
-- end

-- function networkFunction.getSimulatedApiList3(listener)
-- 	local apiParams = createParamsForApiNumber(1)
-- 	apiParams[1].url = API_GET_SHOP
-- 	apiParams[1].listenerEvent = simulatedNetworkHandler.makeSingleSimulatedNetworkEventResponse(false, "test5")
-- 	return simulatedNetworkHandler.requestNetwork(apiParams, listener, "ApiList3")
-- end







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
