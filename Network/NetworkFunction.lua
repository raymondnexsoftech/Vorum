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

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local IS_DEBUG_ON = false

local API_USER_BASE = "https://api.parse.com/1/users/"
local API_LOGIN_BASE = "https://api.parse.com/1/login/"
local API_RESET_PASSWORD = "https://api.parse.com/1/requestPasswordReset"
local API_CLASS_BASE = "https://api.parse.com/1/classes/"
local API_FNC_BASE = "https://api.parse.com/1/functions/"
local API_FILE_BASE = "https://api.parse.com/1/files/"
local API_PUSH_INSTALL_BASE = "https://api.parse.com/1/installations"
local API_BATCH = "https://api.parse.com/1/batch"

local CHOICE_LETTER = {"A", "B", "C", "D"}

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
	networkHandler.setDisplayDebugInfo(IS_DEBUG_ON)
	simulatedNetworkHandler.setDisplayDebugInfo(IS_DEBUG_ON)
end

-- function start

local function setACL(userId)
	return {
				[userId] = {read = true, write = true},
				["*"] = {read = true},
			}
end

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

local function createTableForParsePic(fileInfo)
	if (fileInfo) then
		return {name = fileInfo.name, url = fileInfo.url, ["__type"] = "File"}
	end
	return nil
end

local function saveUserVoteToPost(postList, postIdToIdxTable, votedDataFromServer)
	if ((type(votedDataFromServer) == "table") and (votedDataFromServer.results ~= nil)) then
		for i = 1, #votedDataFromServer.results do
			local curVoteData = votedDataFromServer.results[i]
			local postIdxToCal = postIdToIdxTable[curVoteData.post.objectId][1]
			local votedchoiceLetter
			if (postList[postIdxToCal].choices) then
				local curPostChoiceTable = postList[postIdxToCal].choices
				for j = 1, #CHOICE_LETTER do
					local curChoice = curPostChoiceTable[CHOICE_LETTER[j]]
					if (curChoice == nil) then
						break
					end
					if ((curChoice.id == curVoteData.choice.objectId) or (curChoice.objectId == curVoteData.choice.objectId)) then
						votedchoiceLetter = CHOICE_LETTER[j]
						break
					end
				end
				if (votedchoiceLetter) then
					for j = 1, #postIdToIdxTable[curVoteData.post.objectId] do
						postList[postIdToIdxTable[curVoteData.post.objectId][j]].choices[votedchoiceLetter].isUserVoted = true
					end
				end
			end
		end
	end
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



---------------------------------------------------------------------------------
-- Push Installation
---------------------------------------------------------------------------------


function networkFunction.pushInstallation(deviceToken, listeners)
	local apiParams = createParamsForApiNumber(1)
	local body = {}
	body.deviceToken = deviceToken
	local deviceOS = system.getInfo("platformName")
	if (deviceOS == "Android") then
		body.deviceType = "android"
		body.pushType = "gcm"
		body.GCMSenderId = "679562432507"
	elseif (deviceOS == "iPhone OS") then
		body.deviceType = "ios"
	end

	apiParams[1].params = {
								headers = createVorumNetworkHeader(),
								body = json.encode(body)
							}
	apiParams[1].url = API_PUSH_INSTALL_BASE
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, listener, "pushInstallation")
end




---------------------------------------------------------------------------------
-- Login / Register
---------------------------------------------------------------------------------
local uploadProfilePicArgTable = {
									{name = "sessionToken", type = "string", canSkip = true},
									{name = "path", type = "string"},
									{name = "baseDir", type = "userdata", canSkip = true},
									{name = "isPicResized", type = "boolean", canSkip = true},
									{name = "listener", type = "function", canSkip = true},
									fncName = "uploadProfilePic"
								}
-- function networkFunction.uploadProfilePic(sessionToken, path[, baseDir][, isPicResized][, listener])
function networkFunction.uploadProfilePic(...)
	local fncArg = fncArgUtility.parseArg(uploadProfilePicArgTable, arg)
	local sessionToken, path, baseDir, isPicResized, listener = fncArg.sessionToken, fncArg.path, fncArg.baseDir, fncArg.isPicResized, fncArg.listener
	print(sessionToken, path, baseDir, isPicResized, listener)
	print(tostring(isPicResized))

	local key = "userProfilePic"
	
	local function uploadPicListener(event)
		if (type(listener) == "function") then
			if (event[1].isError) then
				if (event[1].isFileNotFound) then
					event.fileNotFound = true
				elseif (event.retryTimes >= 3) then
					event.networkError = true
				end
			else
				print("network response",event[1].response)
				local response = json.decode(event[1].response)
				event.profilePicInfo = {name = response.name, url = response.url}
			end
			return listener(event)
		end
	end
	print("here2")
	if (isPicResized ~= true) then
		finalPicLoc = resizePic(path, key .. ".jpg", baseDir)
	else
		finalPicLoc = {path = path, baseDir = baseDir}
	end
	print("here3")--die
	if (finalPicLoc.path) then
		local apiParams = createParamsForApiNumber(1)
		apiParams[1].params = {
									headers = createVorumNetworkHeader(sessionToken),
									body = {
												filename = finalPicLoc.path,
												baseDirectory = finalPicLoc.baseDir,
											},
								}
		apiParams[1].params.headers["Content-Type"] = "image/jpg"
		apiParams[1].url = API_FILE_BASE .. key .. ".jpg"
		apiParams[1].method = "POST"
		return networkHandler.requestNetwork(apiParams, uploadPicListener, "uploadProfilePic")
	end
	print("here4")
	return nil
end

-- userData sample:
-- local userData = {}
-- userData.email = "test2@test.com"
-- userData.password = "abcd"
-- userData.name = "xxx"
-- userData.phone = "90123456"
-- userData.dobString = "1000-02-10T11:20:34.032Z"
-- userData.gender = "M"
-- userData.my_country = "HK"
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
function networkFunction.register(userData, profilePicInfo, listener)
	print("hey1")
	if (type(profilePicInfo) == "function")then
		listener = profilePicInfo
		profilePicInfo = nil
	end
print("hey2")
	local apiParams = createParamsForApiNumber(1)
	userData.username = userData.email
	if (userData.dobString) then
		userData.dob = {}
		userData.dob["__type"] = "Date"
		userData.dob.iso = userData.dobString
		userData.dobString = nil
	end
print("hey3")
	if (userData.gender ~= nil) then
		userData.gender = string.upper(userData.gender)
		if ((userData.gender ~= "M") and (userData.gender ~= "F")) then
			userData.gender = nil
		end
	end
print("hey4")
	if (userData.facebook) then
		userData.authData = {}
		userData.authData.facebook = userData.facebook
		userData.facebook = nil
	end
print("hey5")
	userData.searchStr = nil
	if (userData.name) then
		userData.searchStr = userData.name
	end
print("hey6")
	if (userData.email) then
		if (userData.searchStr) then
			userData.searchStr = userData.searchStr .. " " .. userData.email
		else
			userData.searchStr = userData.email
		end
	end
print("hey7")
	if (userData.searchStr) then
		userData.searchStr = string.lower(userData.searchStr)
	end
	if (profilePicInfo) then
		userData.profile_pic = createTableForParsePic(profilePicInfo)
	end
print("hey8")
	apiParams[1].params = {
								headers = createVorumNetworkHeader(),
								body = json.encode(userData)
							}
	apiParams[1].url = API_USER_BASE
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, listener, "register")
end

function networkFunction.updateUserInfo(userId, sessionToken, userData, profilePicInfo, listener)
	if (type(profilePicInfo) == "function")then
		listener = profilePicInfo
		profilePicInfo = nil
	end
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
	userData.searchStr = nil
	if (userData.name) then
		userData.searchStr = userData.name
	end
	if (userData.email) then
		if (userData.searchStr) then
			userData.searchStr = userData.searchStr .. " " .. userData.email
		else
			userData.searchStr = userData.email
		end
	end
	if (userData.searchStr) then
		userData.searchStr = string.lower(userData.searchStr)
	end
	if (profilePicInfo) then
		userData.profile_pic = createTableForParsePic(profilePicInfo)
	elseif (userData.profile_pic == nil) then
		userData.profile_pic = json.null
	end
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = json.encode(userData)
							}
	apiParams[1].url = API_USER_BASE .. userId
	apiParams[1].method = "PUT"
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
	local function loginListener(event)
		if (type(listener) == "function") then
			if (event.isError) then
			else
				local response = json.decode(event[1].response)
				if (response.code) then
					event.loginError = true
				elseif ((response.emailVerified ~= true) and (response.verifiedWithoutEmail ~= true)) then
					event.isNotVerified = true
				else
					event.userData = response
				end
			end
			return listener(event)
		end
	end

	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(),
							}

	apiParams[1].url = API_LOGIN_BASE .. string.format("?username=%s&password=%s", email, password)
	apiParams[1].method = "GET"
	return networkHandler.requestNetwork(apiParams, loginListener, "login")
end

function networkFunction.resetPassword(email, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(),
								body = "{\"email\":\"" .. email .. "\"}"
							}
	apiParams[1].url = API_RESET_PASSWORD
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, listener, "resetPassword")
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
-- Add view count
---------------------------------------------------------------------------------
local ADD_VIEW_COUNT_TABLE1 = {0, 0, 1, 1, 2, 2}
local ADD_VIEW_COUNT_TABLE2 = {
									0, 0, 0, 0, 3, 0, 0, 0, 2, 0,
									0, 2, 0, 0, 0, 0, 0, 5, 0, 0,
									0, 0, 2, 3, 0, 0, 2, 0, 0, 0,
									2, 3, 0, 4, 0, 2, 3, 2, 4, 3,
								}
local function addViewCountVal(table)
	return table[math.random(#table)]
end
function networkFunction.addPostViewCount(postList, listener)
	if ((type(postList) ~= "table") or (#postList <= 0)) then
		return nil
	end
	local requestBodyStr = ""
	local isViewCountUpdated = false
	for i = 1, #postList do
		local incVal = 0
		local curViewCount = postList[i].post.views
		if ((curViewCount == nil) or (curViewCount < 5)) then
			incVal = 1
		elseif (curViewCount < 1000) then
			incVal = addViewCountVal(ADD_VIEW_COUNT_TABLE1)
		end
		if (incVal > 0) then
			requestBodyStr = requestBodyStr .. ",{\"method\":\"PUT\",\"path\":\"/1/classes/Post/" .. postList[i].post.objectId .. "\",\"body\":{\"views\":{\"__op\":\"Increment\",\"amount\":" .. tostring(incVal) .. "}}}"
			isViewCountUpdated = true
		end
	end
	if (isViewCountUpdated) then
		requestBodyStr = "{\"requests\": [" .. string.gsub(requestBodyStr, "^(,)", "") .. "]}"
		local apiParams = createParamsForApiNumber(1)
		apiParams[1].params = {
									headers = createVorumNetworkHeader(sessionToken),
									body = requestBodyStr,
								}
		apiParams[1].method = "POST"
		apiParams[1].url = API_BATCH
		return networkHandler.requestNetwork(apiParams, listener, "addPostViewCount")
	else
		return nil
	end
end


---------------------------------------------------------------------------------
-- Create Post
---------------------------------------------------------------------------------


local function resizePostPic(photoList)
	local returnList = {}
	for k, v in pairs(photoList) do
		if (type(v) == "table") then
			returnList[k] = resizePic(v.path, k .. ".jpg", v.baseDir)
		end
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

local POST_PIC_TABLE = {"answerPicA", "answerPicB", "answerPicC", "answerPicD", "questionPic", "couponPic"}

-- details of photoList:
--   isPicResized
--   questionPic {path[, baseDir]}
--   answerPicA {path[, baseDir]}
--   answerPicB {path[, baseDir]}
--   answerPicC {path[, baseDir]}
--   answerPicD {path[, baseDir]}
--   couponPic {path[, baseDir]}
function networkFunction.uploadPostPic(sessionToken, photoList, listener)
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

	if (photoList.isPicResized ~= true) then
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
				apiParams[1].params.headers["Content-Type"] = "image/jpg"
				apiParams[1].url = API_FILE_BASE .. key .. ".jpg"
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

local createPostArgTable = {
								{name = "userId", type = "string"},
								{name = "sessionToken", type = "string"},
								{name = "photoList", type = "table", canSkip = true},
								{name = "postData", type = "table"},
								{name = "choiceData", type = "table"},
								{name = "couponText", type = "string", canSkip = true},
								{name = "listener", type = "function", canSkip = true},
								fncName = "createCoupon"
							}
-- details of photoList:
--   questionPic (string of "name" return from server)
--   answerPicA (string of "name" return from server)
--   answerPicB (string of "name" return from server)
--   answerPicC (string of "name" return from server)
--   answerPicD (string of "name" return from server)
--   couponPic (string of "name" return from server)
-- function networkFunction.createPost(userId, sessionToken[, photoList], postData, choiceData[, couponText][, listener])
function networkFunction.createPost(...)
	local fncArg = fncArgUtility.parseArg(createPostArgTable, arg)
	local userId, sessionToken, photoList, postData, choiceData, couponText, listener = fncArg.userId, fncArg.sessionToken, fncArg.photoList, fncArg.postData, fncArg.choiceData, fncArg.couponText, fncArg.listener
	local apiParams = createParamsForApiNumber(1)
	postData.user = {["__type"] = "Pointer", className = "_User", objectId = userId}
	if (type(postData.tags) == "string") then
		postData.tags = {postData.tags}
	elseif (type(postData.tags) ~= "table") then
		postData.tags = {"General"}
	end
	if (postData.tags[1] == "30mins") then
		postData.expire_time = (os.time() + 30 * 60) * 1000
	else
		postData.expire_time = 9999999999999
	end
	postData.searchStr = nil
	if (postData.description) then
		postData.searchStr = postData.description
	end
	if (postData.title) then
		if (postData.searchStr) then
			postData.searchStr = postData.searchStr .. " " .. postData.title
		else
			postData.searchStr = postData.title
		end
	end
	if (postData.searchStr) then
		postData.searchStr = string.lower(postData.searchStr)
	end
	postData.post_pic = createTableForParsePic(photoList.questionPic)
	postData.pushed_time = os.time() * 1000
	postData.views = 0
	for i = 1, #choiceData do
		choiceData[i].choice_pic = createTableForParsePic(photoList[POST_PIC_TABLE[i]])
		choiceData[i].letter = CHOICE_LETTER[i]
		choiceData[i].vote_count_male = 0
		choiceData[i].vote_count_female = 0
	end
	postData.choices = choiceData
	if ((couponText ~= nil) or (photoList.couponPic ~= nil))then
		postData.coupon = {}
		postData.coupon.text = couponText
		postData.coupon.pic = createTableForParsePic(photoList.couponPic)
	end

	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = json.encode(postData)
							}
	apiParams[1].url = API_FNC_BASE .. "createPost"
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, listener, "createPost")
end

local createCouponArgTable = {
					{name = "sessionToken", type = "string"},
					{name = "postId", type = "string"},
					{name = "couponText", type = "string", canSkip = true},
					{name = "photoList", type = "table"},
					{name = "listener", type = "function", canSkip = true},
					fncName = "createCoupon"
				}
-- function networkFunction.createCoupon(sessionToken, postId[, couponText], photoList, listener)
function networkFunction.createCoupon(...)
	local fncArg = fncArgUtility.parseArg(createCouponArgTable, arg)
	local sessionToken, postId, couponText, photoList, listener = fncArg.sessionToken, fncArg.postId, fncArg.couponText, fncArg.photoList, fncArg.listener
	local apiParams = createParamsForApiNumber(1)
	local couponData = {}
	couponData.post = {["__type"] = "Pointer", className = "Post", objectId = postId}
	if (couponText) then
		couponData.text = couponText
	end
	if (photoList.couponPic) then
		couponData.pic = createTableForParsePic(photoList.couponPic)
	end
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = json.encode(couponData)
							}
	apiParams[1].url = API_CLASS_BASE .. "Coupon"
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, listener, "createCoupon")
end

---------------------------------------------------------------------------------
-- Post Details
---------------------------------------------------------------------------------

-- function networkFunction.getPostCoupon(postIdArray, listener)
-- 	local postNumber = #postIdArray
-- 	if (postNumber <= 0) then
-- 		return nil
-- 	end
-- 	local apiParams = createParamsForApiNumber(1)
-- 	local postListToQueryStr = ""
-- 	for i = 1, postNumber do
-- 		postListToQueryStr = postListToQueryStr .. ",{\"__type\":\"Pointer\",\"className\":\"Post\",\"objectId\":\"" .. postIdArray[i] .. "\"}"
-- 	end
-- 	postListToQueryStr = string.gsub(postListToQueryStr, "^(,)", "")
-- 	apiParams[1].params = {
-- 								headers = createVorumNetworkHeader(sessionToken),
-- 							}
-- 	apiParams[1].url = API_CLASS_BASE .. "Coupon?where=" .. url.escape("{\"post\":{\"$in\":[" .. postListToQueryStr .. "]}}")
-- 	return networkHandler.requestNetwork(apiParams, listener, "getPostCoupon")
-- end

---------------------------------------------------------------------------------
-- Posts
---------------------------------------------------------------------------------

local getVorumPostArgTable = {
					{name = "userId", type = "string"},
					{name = "startDate", type = "number", canSkip = true},
					{name = "sessionToken", type = "string"},
					{name = "postNumber", type = "number", canSkip = true},
					{name = "friendList", type = "table"},
					{name = "options", type = "table", canSkip = true},
					{name = "listener", type = "function", canSkip = true},
					fncName = "getVorumPost"
				}
-- format of options:
--  sortVoted: "vote_count_all", "vote_count_month", "vote_count_week", if nil then sorted by pushed time
--  isMyCountry: only show my country post
--  tags: only show the post with the string in tag
-- function networkFunction.getVorumPost([startDate, ]sessionToken[, postNumber][, options][, listener])
function networkFunction.getVorumPost(...)
	local fncArg = fncArgUtility.parseArg(getVorumPostArgTable, arg)
	local userId, startDate, sessionToken, postNumber, friendList, options, listener = fncArg.userId, fncArg.startDate, fncArg.sessionToken, fncArg.postNumber, fncArg.friendList, fncArg.options, fncArg.listener

	local function getVorumPostListener(event)
		if (type(listener) == "function") then
			if (event.isError) then
				return listener(event)
			else
				local response = json.decode(event[1].response)
				local lastTimeStamp = -1
				local postTotal = #response.result
				if ((response.result) and (postTotal > 0)) then
					lastTimeStamp = response.result[postTotal].sort
					local i = 1
					while (i <= postTotal) do
						local postData = response.result[i].post
						local postCreatorId = postData.user.objectId
						if ((postCreatorId ~= userId) and (postData.friend_only == true) and (friendList.byId[postCreatorId] ~= true)) then
							table.remove(response.result, i)
							postTotal = postTotal - 1
						else
							i = i + 1
						end
					end
				end
				event.result = response.result
				event.lastTimeStamp = lastTimeStamp
				return listener(event)
			end
		end
	end

	local apiParams = createParamsForApiNumber(1)
	local paramsBody = {}
	paramsBody.timestamp = startDate
	paramsBody.limit = postNumber
	if (options) then
		if (type(options.tags) == "string") then
			paramsBody.tag = {options.tags}
		elseif (type(options.tags) ~= "table") then
			paramsBody.tag = nil
		end
		paramsBody.my_country_only = options.isMyCountry
		paramsBody.sort = options.sortVoted
	end
	local jsonEncodedParamsBody
	for k, v in pairs(paramsBody) do
		jsonEncodedParamsBody = json.encode(paramsBody)
		break
	end
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = jsonEncodedParamsBody,
							}
	-- local urlParams = url.escape(string.format("?where={\"user\":{\"__type\":\"Pointer\",\"className\":\"_User\",\"objectId\":\"%s\"},\"createdAt\":{\"$gt\":{\"__type\":\"Date\",\"iso\":\"%s\"}}}&limit=%d", creator, startDate, postNumber))
	apiParams[1].method = "POST"
	apiParams[1].url = API_FNC_BASE .. "getPosts"
	return networkHandler.requestNetwork(apiParams, getVorumPostListener, "getVorumPost")
	-- local urlParams = url.escape(string.format("?where={\"user\":{\"__type\":\"Pointer\",\"className\":\"_User\",\"objectId\":\"%s\"},\"createdAt\":{\"$gt\":{\"__type\":\"Date\",\"iso\":\"%s\"}}}&limit=%d", creator, startDate, postNumber))
	-- apiParams[1].url = API_CLASS_BASE .. "Post" .. urlParams
	-- return networkHandler.requestNetwork(apiParams, listener, "getVorumPost")
end

function networkFunction.getOnePost(sessionToken, postId, listener)
	local apiParams = createParamsForApiNumber(1)
	local paramsBody = {}
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = "{\"post_id\":\"" .. postId .. "\"}",
							}
	apiParams[1].method = "POST"
	apiParams[1].url = API_FNC_BASE .. "getPost"
	return networkHandler.requestNetwork(apiParams, listener, "getOnePost")
end

---------------------------------------------------------------------------------
-- Report Posts
---------------------------------------------------------------------------------

function networkFunction.reportPost(userId, sessionToken, postId, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = "{\"post_id\":\"" .. postId .. "\"}"
							}
	apiParams[1].url = API_FNC_BASE .. "reportPost"
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, listener, "reportPost")
end

function networkFunction.sharePost(userId, sessionToken, postId, listener)
	local function checkUserShareListener(event)
		if (event[1].isError) then
			if (type(listener) == "function") then
				event.isNetworkError = true
				listener(event)
			end
			return
		else
			local response = json.decode(event[1].response)
			if (response) then
				if ((response.count) and (response.count > 0)) then
					if (type(listener) == "function") then
						event.isUserShared = true
						listener(event)
					end
					return
				end
			end
			local apiParams = createParamsForApiNumber(1)
			local shareData = {}
			shareData.ACL = setACL(userId)
			shareData.post = {["__type"] = "Pointer", className = "Post", objectId = postId}
			shareData.share_time = os.time() * 1000
			shareData.user = {["__type"] = "Pointer", className = "_User", objectId = userId}
			apiParams[1].params = {
										headers = createVorumNetworkHeader(sessionToken),
										body = json.encode(shareData)
									}
			apiParams[1].url = API_CLASS_BASE .. "Share"
			apiParams[1].method = "POST"
			return networkHandler.requestNetwork(apiParams, listener, "sharePost")
		end
	end

	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
							}
	apiParams[1].url = API_CLASS_BASE .. "Share?where=" .. url.escape("{" .. string.format("\"post\":{\"__type\":\"Pointer\",\"className\":\"Post\",\"objectId\":\"%s\"},\"user\":{\"__type\":\"Pointer\",\"className\":\"_User\",\"objectId\":\"%s\"}", postId, userId) .. "}") .. "&count=1&limit=0"
	apiParams[1].method = "GET"
	networkHandler.requestNetwork(apiParams, checkUserShareListener, "checkUserShare")
end

function networkFunction.deletePost(sessionToken, postId, listener)
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = "{\"disabled\":true}"
							}
	apiParams[1].url = API_CLASS_BASE .. "Post/" .. postId
	apiParams[1].method = "PUT"
	return networkHandler.requestNetwork(apiParams, listener, "deletePost")
end

local function isTimeOnSameDay(time1, time2)
	if (type(time1) ~= "table") then
		time1 = os.date("*t", time1)
	end
	if (type(time2) ~= "table") then
		time2 = os.date("*t", time2)
	end
	if ((time1.year == time2.year) and (time1.month == time2.month) and (time1.day == time2.day)) then
		return true
	end
	return false
end

-- return:
--  isPushedToday = true    -- user already pushed the post today
--  isNetworkError = true   -- cannot get information from internet
function networkFunction.pushPost(userId, sessionToken, postId, listener)
	local function getPushListener(event)
		if (event[1].isError) then
			if (type(listener) == "function") then
				event.isNetworkError = true
				listener(event)
			end
			return
		else
			local currentTime = os.time()
			local timeShift = currentTime - os.time(os.date("!*t"))
			local response = json.decode(event[1].response)
			if (response) then
				if ((response.last_push) and (response.last_push > 0)) then
					local lastPush = math.floor(response.last_push / 1000) + timeShift
					if (isTimeOnSameDay(currentTime + timeShift, lastPush)) then
						if (type(listener) == "function") then
							event.isPushedToday = true
							listener(event)
						end
						return
					end
				end
			end
			local pushTimeStr = tostring(currentTime * 1000)
			local apiParams = createParamsForApiNumber(2)
			apiParams[1].params = {
										headers = createVorumNetworkHeader(sessionToken),
										body = "{\"last_push\":" .. pushTimeStr .. "}",
									}
			apiParams[1].url = API_USER_BASE .. userId
			apiParams[1].method = "PUT"
			apiParams[2].params = {
										headers = createVorumNetworkHeader(sessionToken),
										body = "{\"pushed_time\":" .. pushTimeStr .. "}",
									}
			apiParams[2].url = API_CLASS_BASE .. "Post/" .. postId
			apiParams[2].method = "PUT"
			networkHandler.requestNetwork(apiParams, listener, "pushPost")
		end
	end

	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
							}
	apiParams[1].url = API_USER_BASE .. userId
	apiParams[1].method = "GET"
	return networkHandler.requestNetwork(apiParams, getPushListener, "pushPostGetLastPush")
end

function networkFunction.searchPost(sessionToken, searchString, startPos, postNum, listener)
	local postList
	local postCreatorList = {}

	local function searchPostGetUserListener(event)
		if (event[1].isError) then
			if (type(listener) == "function") then
				event.isError = true
				return listener(event)
			end
		else
			local response = json.decode(event[1].response)
			local searchResultCount = #response.results
			if ((response.results) and (searchResultCount > 0)) then
				for i = 1, searchResultCount do
					local postCreatorData = response.results[i]
					local postIdxListForCreator = postCreatorList[postCreatorData.objectId]
					for j = 1, #postIdxListForCreator do
						postList[postIdxListForCreator[j]].user = postCreatorData
					end
				end
				event.postData = postList
			end
			return listener(event)
		end
	end

	local function searchPostListener(event)
		if (event[1].isError) then
			if (type(listener) == "function") then
				event.isError = true
				return listener(event)
			end
		else
			local response = json.decode(event[1].response)
			local searchResultCount = #response.result
			if ((response.result) and (searchResultCount > 0)) then
				local queryUserStr = ""
				postList = response.result
				for i = 1, searchResultCount do
					local postCreatorId = postList[i].user.objectId
					if (postCreatorList[postCreatorId]) then
						postCreatorList[postCreatorId][#postCreatorList[postCreatorId] + 1] = i
					else
						postCreatorList[postCreatorId] = {i}
						queryUserStr = queryUserStr .. ",\"" .. postCreatorId .. "\""
					end
					postList[i].user = nil
				end
				queryUserStr = string.gsub(queryUserStr, "^(,)", "")
				local apiParams = createParamsForApiNumber(1)
				apiParams[1].params = {
											headers = createVorumNetworkHeader(sessionToken),
										}
				apiParams[1].url = API_USER_BASE .. "?where=" .. url.escape("{\"objectId\":{\"$in\":[" .. queryUserStr .. "]}}")
				apiParams[1].method = "GET"
				networkHandler.requestNetwork(apiParams, searchPostGetUserListener, "searchPostGetUser")
			else
				if (type(listener) == "function") then
					return listener(event)
				end
			end
		end
	end
		-- if (type(listener) == "function") then

	local apiParams = createParamsForApiNumber(1)
	local paramsBody = {
							searchString = string.lower(searchString),
							searchResultStartNumber = startPos,
							numberOfSearchResultGet = postNum,
						}
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = json.encode(paramsBody)
							}
	apiParams[1].url = API_FNC_BASE .. "searchPost"
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, searchPostListener, "searchPost")
end

function networkFunction.searchUser(sessionToken, searchString, startPos, postNum, listener)
	local apiParams = createParamsForApiNumber(1)
	local paramsBody = {
							searchString = string.lower(searchString),
							searchResultStartNumber = startPos,
							numberOfSearchResultGet = postNum,
						}
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = json.encode(paramsBody)
							}
	apiParams[1].url = API_FNC_BASE .. "searchUser"
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, listener, "searchUser")
end

-- local CHOICE_LETTER = {"A", "B", "C", "D"}
-- function networkFunction.getPostChoiceDetail(userId, sessionToken, postData, listener)
-- 	local choiceTable = {}

-- 	local function getDetailListener(event)
-- 		event.postId = postData.post.objectId
-- 		if (event[1].isError) then
-- 		else
-- 			local response1 = json.decode(event[1].response)
-- 			if (response1.results[1]) then
-- 				event[1].choiceLetter = choiceTable[response1.results[1].choice.objectId]
-- 			end
-- 		end
-- 		if (type(listener) == "function") then
-- 			return listener(event)
-- 		end
-- 	end

-- 	if ((type(postData) ~= "table") or (type(postData.choices) ~= "table")) then
-- 		return nil
-- 	end
-- 	local apiParams = {}
-- 	local choices = postData.choices
-- 	apiParams[1] = {}
-- 	apiParams[1].params = {
-- 								headers = createVorumNetworkHeader(sessionToken),
-- 							}
-- 	apiParams[1].url = API_CLASS_BASE .. "Vote?where=" .. url.escape("{" .. string.format("\"post\":{\"__type\":\"Pointer\",\"className\":\"Post\",\"objectId\":\"%s\"},\"user\":{\"__type\":\"Pointer\",\"className\":\"_User\",\"objectId\":\"%s\"}", postData.post.objectId, userId) .. "}")
-- 	for i = 1, #CHOICE_LETTER do
-- 		local choiceDetail = choices[CHOICE_LETTER[i]]
-- 		if (choiceDetail) then
-- 			local apiParamsIdx = #apiParams + 1
-- 			apiParams[apiParamsIdx] = {}
-- 			apiParams[apiParamsIdx].params = {
-- 												headers = createVorumNetworkHeader(sessionToken),
-- 												body = json.encode({choice_id = choiceDetail.id})
-- 											}
-- 			choiceTable[choiceDetail.id] = choiceDetail.letter
-- 			apiParams[apiParamsIdx].method = "POST"
-- 			apiParams[apiParamsIdx].url = API_FNC_BASE .. "getCountByChoice"
-- 		else
-- 			break
-- 		end
-- 	end
-- 	return networkHandler.requestNetwork(apiParams, getDetailListener, "getPostChoiceDetail")
-- end

function networkFunction.getUserVotedForPost(userId, sessionToken, postArrayData, listener)
	local totalPost = #postArrayData.result
	if (totalPost <= 0) then
		return
	end

	local postIdArray = {}
	local voteReturn = {}

	local function getVotedListener(event)
		if (event[1].isError) then
		else
			local response = json.decode(event[1].response)
			if ((type(response) == "table") and (response.results ~= nil)) then
				for i = 1, #response.results do
					local curVoteData = response.results[i]
					local choiceData = postIdArray[curVoteData.choice.objectId]
					if (choiceData) then
						voteReturn[choiceData.postIdx] = choiceData.letter
					end
				end
				if (type(listener) == "function") then
					event.userChoice = voteReturn
					listener(event)
				end
				return
			end
		end
		if (type(listener) == "function") then
			listener(event)
		end
	end

	local apiParams = createParamsForApiNumber(1)
	apiParams[1] = {}
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
							}
	local queryPostStr = ""
	for i = 1, totalPost do
		local curPostId = postArrayData.result[i].post.objectId
		queryPostStr = queryPostStr .. string.format(",{\"__type\":\"Pointer\",\"className\":\"Post\",\"objectId\":\"%s\"}", curPostId)
		for j = 1, 4 do
			local choice = postArrayData.result[i].choices[CHOICE_LETTER[j]]
			if (choice == nil) then
				break
			end
			postIdArray[choice.id] = {postIdx = i, letter = CHOICE_LETTER[j]}
		end
		voteReturn[i] = ""
	end
	queryPostStr = string.gsub(queryPostStr, "^(,)", "")
	if (totalPost == 1) then
		queryPostStr = "\"post\":" .. queryPostStr
	else
		queryPostStr = "\"post\":{\"$in\":[" .. queryPostStr .. "]}"
	end
	queryPostStr = "{" .. queryPostStr .. string.format(",\"user\":{\"__type\":\"Pointer\",\"className\":\"_User\",\"objectId\":\"%s\"}", userId) .. "}"
	apiParams[1].url = API_CLASS_BASE .. "Vote?where=" .. url.escape(queryPostStr)
	return networkHandler.requestNetwork(apiParams, getVotedListener, "getUserVotedForPost")
end

function networkFunction.getVoteResultForPost(postId, listener)
	local function getVoteResultListener(event)
		if (type(listener) == "function") then
			if (event.isError) then
				return listener(event)
			else
				local postChoice = {}
				local choiceResultResponse = json.decode(event[1].response)
				local resultsList = choiceResultResponse.results
				for i = 1, #resultsList do
					postChoice[resultsList[i].letter] = resultsList[i]
				end
				event.voteData = postChoice
				return listener(event)
			end
		end
	end

	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
							}
	apiParams[1].url = API_CLASS_BASE .. "Choice?where=" .. url.escape("{" .. string.format("\"post\":{\"__type\":\"Pointer\",\"className\":\"Post\",\"objectId\":\"%s\"}", postId) .. "}")
	apiParams[1].method = "GET"
	networkHandler.requestNetwork(apiParams, getVoteResultListener, "getVoteResult")
end

-- return:
--  isUserVoted = true      -- user already voted
--  isNetworkError = true   -- cannot get information from internet
function networkFunction.votePost(userId, sessionToken, gender, postId, choiceId, isGetResult, couponId, listener)
	if (type(couponId) == "function") then		-- to check if couponId is missing
		listener = couponId
		couponId = nil
	end

	local postChoice = {}
	local returnData = {}
	local networkStillCalling = 0
	local requestList = {}

	local function voteAndCouponCompleteListener(event)
		if (event.isError) then
			if (event.retryTimes < 3) then
				return false
			end
			for i = 1, #requestList do
				cancelRequest(requestList[i])
			end
			if (type(listener) == "function") then
				returnData.isError = true
				listener(returnData)
			end
		else
			if (event.key == "getCoupon") then
				print(event[1].response)
				returnData.coupon = json.decode(event[1].response)
				networkStillCalling = networkStillCalling - 1
			else
				returnData.userVoteStatus = json.decode(event[1].response)
				networkStillCalling = networkStillCalling - 1
			end
			if (networkStillCalling == 0) then
				if (type(listener) == "function") then
					if (isGetResult) then
						returnData.updatedResult = postChoice
					end
					listener(returnData)
				end
			end
		end
	end

	local function checkVotedListener(event)
		if (event.isError) then
			if (type(listener) == "function") then
				event.isNetworkError = true
				listener(event)
			end
			return
		else
			local userVotedResponse = json.decode(event[1].response)
			if (userVotedResponse) then
				if ((userVotedResponse.count) and (userVotedResponse.count > 0)) then
					if (type(listener) == "function") then
						event.isUserVoted = true
						listener(event)
					end
					return
				end
			end
			if (isGetResult) then
				local choiceResultResponse = json.decode(event[2].response)
				local resultsList = choiceResultResponse.results
				for i = 1, #resultsList do
					postChoice[resultsList[i].letter] = resultsList[i]
				end
			end
			local apiParams = createParamsForApiNumber(1)
			local paramsBody = {
									choice = {__type = "Pointer", className = "Choice", objectId = choiceId},
									post = {__type = "Pointer", className = "Post", objectId = postId},
									user = {__type = "Pointer", className = "_User", objectId = userId},
									gender = gender,
								}
			apiParams[1].params = {
										headers = createVorumNetworkHeader(sessionToken),
										body = json.encode(paramsBody)
									}
			apiParams[1].url = API_CLASS_BASE .. "Vote"
			apiParams[1].method = "POST"
			requestList[1] = networkHandler.requestNetwork(apiParams, voteAndCouponCompleteListener, "votePost")
			networkStillCalling = networkStillCalling + 1
			print(couponId)
			if (couponId) then
				local expireTime = (os.time() + 24 * 60 * 60) * 1000
				apiParams = createParamsForApiNumber(1)
				paramsBody = {
										coupon = {__type = "Pointer", className = "Coupon", objectId = couponId},
										user = {__type = "Pointer", className = "_User", objectId = userId},
										expire = expireTime,
									}
				apiParams[1].params = {
											headers = createVorumNetworkHeader(sessionToken),
											body = json.encode(paramsBody)
										}
				apiParams[1].url = API_CLASS_BASE .. "UserCoupon"
				apiParams[1].method = "POST"
				requestList[2] = networkHandler.requestNetwork(apiParams, voteAndCouponCompleteListener, "getCoupon")
				networkStillCalling = networkStillCalling + 1
			end
		end
	end

	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
							}
	apiParams[1].url = API_CLASS_BASE .. "Vote?where=" .. url.escape("{" .. string.format("\"post\":{\"__type\":\"Pointer\",\"className\":\"Post\",\"objectId\":\"%s\"},\"user\":{\"__type\":\"Pointer\",\"className\":\"_User\",\"objectId\":\"%s\"}", postId, userId) .. "}") .. "&count=1&limit=0"
	apiParams[1].method = "GET"
	if (isGetResult) then
		apiParams[2] = {}
		apiParams[2].params = {
									headers = createVorumNetworkHeader(sessionToken),
								}
		apiParams[2].url = API_CLASS_BASE .. "Choice?where=" .. url.escape("{" .. string.format("\"post\":{\"__type\":\"Pointer\",\"className\":\"Post\",\"objectId\":\"%s\"}", postId) .. "}")
		apiParams[2].method = "GET"
	end
	networkHandler.requestNetwork(apiParams, checkVotedListener, "checkUserVoted")
end

---------------------------------------------------------------------------------
-- Friend System
---------------------------------------------------------------------------------

function networkFunction.getFriendList(userId, sessionToken, listener)
	local function getFriendListListener(event)
		if (type(listener) == "function") then
			if (event[1].isError) then
				return listener(event)
			else
				local response = json.decode(event[1].response)
				if (response.results) then
					local resultsSize = #response.results
					if (resultsSize > 0) then
						local friendIdList = {}
						friendList.byNumber = {}
						friendList.byId = {}
						for i = 1, resultsSize do
							local curResult = response.results[i]
							local friendId
							if (curResult.from.objectId == userId) then
								friendId = curResult.to.objectId
							elseif (curResult.to.objectId == userId) then
								friendId = curResult.from.objectId
							end
							friendList.byNumber[i] = friendId
							friendList.byId[friendId] = true
						end
						event.friendIdList = friendIdList
					end
				end
				return listener(event)
			end
		end
	end
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
							}
	local userPointerQuery = "{\"__type\":\"Pointer\",\"className\":\"_User\",\"objectId\":\"" .. userId .. "\"}"
	local urlQuery = "{\"$or\":[{\"from\":" .. userPointerQuery .. "},{\"to\":" .. userPointerQuery .. "}],\"approved\":true}"
	apiParams[1].url = API_CLASS_BASE .. "Friend?keys=from,to&where=" .. url.escape(urlQuery)
	return networkHandler.requestNetwork(apiParams, getFriendListListener, "getFriendList")
end

function networkFunction.addFriend(sessionToken, friendId, listener)
local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = "{\"friend_id\":\"" .. friendId .. "\"}"
							}
	apiParams[1].url = API_FNC_BASE .. "addFriend"
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, listener, "addFriend")
end

function networkFunction.acceptFriend(sessionToken, friendId, listener)
local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = "{\"friend_id\":\"" .. friendId .. "\"}"
							}
	apiParams[1].url = API_FNC_BASE .. "acceptFriend"
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, listener, "acceptFriend")
end

function networkFunction.cancelFriendRequest(sessionToken, friendId, listener)
local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = "{\"friend_id\":\"" .. friendId .. "\"}"
							}
	apiParams[1].url = API_FNC_BASE .. "cancelRequest"
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, listener, "cancelFriendRequest")
end

function networkFunction.rejectFriendRequest(sessionToken, friendId, listener)
local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = "{\"friend_id\":\"" .. friendId .. "\"}"
							}
	apiParams[1].url = API_FNC_BASE .. "rejectRequest"
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, listener, "rejectFriendRequest")
end

function networkFunction.unfriend(sessionToken, friendId, listener)
local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = "{\"friend_id\":\"" .. friendId .. "\"}"
							}
	apiParams[1].url = API_FNC_BASE .. "unfriend"
	apiParams[1].method = "POST"
	return networkHandler.requestNetwork(apiParams, listener, "unfriend")
end

---------------------------------------------------------------------------------
-- Member profile and post
---------------------------------------------------------------------------------

function networkFunction.getMemberProfile(userId, sessionToken, friendId, listener)
	if (type(friendId) == "function") then						-- check if friendId is missing
		listener = friendId
		friendId = userId
	end
	local isNotGetMyselfProfile = (userId ~= friendId)
	local function getMemberProfileListener(event)
		if (type(listener) == "function") then
			if (event.isError) then
				return listener(event)
			end
			local userDataResponse = json.decode(event[1].response)
			if (userDataResponse) then
				event.userData = userDataResponse
			end
			local userMedalResponse = json.decode(event[2].response)
			if (userMedalResponse.result) then
				event.medal = userMedalResponse.result
			end
			local userPostCountResponse = json.decode(event[3].response)
			if (userPostCountResponse.count) then
				event.postCount = userPostCountResponse.count
			end
			local userVoteCountResponse = json.decode(event[4].response)
			if (userVoteCountResponse.count) then
				event.voteCount = userVoteCountResponse.count
			end
			if (event[5]) then
				local response = json.decode(event[5].response)
				if (response.results) then
					local curResult = response.results[1]
					if (curResult) then
						if (curResult.approved) then
							event.isFriend = true
						elseif (curResult.from.objectId == userId) then
							event.isPending = true
						elseif (curResult.to.objectId == userId) then
							event.isWaitingApprove = true
						end
					end
				end
			end
			return listener(event)
		end
	end
	local apiParams = createParamsForApiNumber(4)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
							}
	apiParams[1].url = API_USER_BASE .. friendId
	apiParams[2].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = "{\"user_id\":\"" .. friendId .. "\"}",
							}
	apiParams[2].url = API_FNC_BASE .. "getMedalCountByUser"
	apiParams[2].method = "POST"
	local queryString = "?where=" .. url.escape("{\"user\":{\"__type\":\"Pointer\",\"className\":\"_User\",\"objectId\":\"" .. friendId .. "\"}}") .. "&limit=0&count=1"
	apiParams[3].params = {
								headers = createVorumNetworkHeader(sessionToken),
							}
	apiParams[3].url = API_CLASS_BASE .. "Post" .. queryString
	apiParams[4].params = {
								headers = createVorumNetworkHeader(sessionToken),
							}
	apiParams[4].url = API_CLASS_BASE .. "Vote" .. queryString
	if (isNotGetMyselfProfile) then
		apiParams[5] = {}
		apiParams[5].params = {
									headers = createVorumNetworkHeader(sessionToken),
								}
		local userPointerQuery = "{\"__type\":\"Pointer\",\"className\":\"_User\",\"objectId\":\"" .. userId .. "\"}"
		local friendPointerQuery = "{\"__type\":\"Pointer\",\"className\":\"_User\",\"objectId\":\"" .. friendId .. "\"}"
		local urlQuery = "{\"$or\":[{\"from\":" .. userPointerQuery .. ",\"to\":" .. friendPointerQuery .. "},{\"from\":" .. friendPointerQuery .. ",\"to\":" .. userPointerQuery .. "}]}"
		apiParams[5].url = API_CLASS_BASE .. "Friend?where=" .. url.escape(urlQuery)
	end
	return networkHandler.requestNetwork(apiParams, getMemberProfileListener, "getMemberProfile")
end

local getMemberPostArgTable = {
					{name = "userId", type = "string"},
					{name = "friendList", type = "table"},
					{name = "memberId", type = "string"},
					{name = "startDate", type = "number", canSkip = true},
					{name = "sessionToken", type = "string"},
					{name = "postNumber", type = "number", canSkip = true},
					{name = "getExpired", type = "boolean", canSkip = true, default = false},
					{name = "listener", type = "function", canSkip = true},
					fncName = "getMemberPost"
				}
-- function networkFunction.getMemberPost(userId, friendList, memberId, [startDate, ]sessionToken[, postNumber][, getExpired][, listener])
function networkFunction.getMemberPost(...)
	local fncArg = fncArgUtility.parseArg(getMemberPostArgTable, arg)
	local userId, friendList, memberId, startDate, sessionToken, postNumber, getExpired, listener = fncArg.userId, fncArg.friendList, fncArg.memberId, fncArg.startDate, fncArg.sessionToken, fncArg.postNumber, fncArg.getExpired, fncArg.listener
	local postIdxListForPostCreator = {}
	local postList = {}
	local postIdxList = {}
	local postIdxListForVoted = {}
	local lastTimeStamp = -1

	local function getMemberPostUserDetailListener(event)
		if (event.isError) then
			if (type(listener) == "function") then
				listener(event)
			end
			return
		else
			local response = json.decode(event[1].response)
			if ((response.results) and (#response.results > 0)) then
				for i = 1, #response.results do
					local curUserDetail = response.results[i]
					for j = 1, #postIdxListForPostCreator[curUserDetail.objectId] do
						local curPostListIdx = postIdxListForPostCreator[curUserDetail.objectId][j]
						postList[curPostListIdx].post.user = curUserDetail
					end
				end
			end
			if (type(listener) == "function") then
				event.lastTimeStamp = lastTimeStamp
				event.postData = postList
				listener(event)
			end
			return
		end
	end

	local function getMemberPostDetailListener(event)
		if (event.isError) then
			if (type(listener) == "function") then
				listener(event)
			end
			return
		else
			if (#event > 1) then
				local postResponse = json.decode(event[4].response)
				if ((postResponse.results) and (#postResponse.results > 0)) then
					for i = 1, #postResponse.results do
						local curPostDetail = postResponse.results[i]
						for j = 1, #postIdxList[curPostDetail.objectId] do
							local curPostListIdx = postIdxList[curPostDetail.objectId][j]
							postList[curPostListIdx].post = curPostDetail
						end
					end
				end
				local couponResponse = json.decode(event[3].response)
				if ((couponResponse.results) and (#couponResponse.results > 0)) then
					for i = 1, #couponResponse.results do
						local curCouponDetail = couponResponse.results[i]
						for j = 1, #postIdxList[curCouponDetail.post.objectId] do
							local curPostListIdx = postIdxList[curCouponDetail.post.objectId][j]
							postList[curPostListIdx].coupon = curCouponDetail
						end
					end
				end
				local choiceResponse = json.decode(event[2].response)
				if ((choiceResponse.results) and (#choiceResponse.results > 0)) then
					for i = 1, #choiceResponse.results do
						local curChoiceDetail = choiceResponse.results[i]
						for j = 1, #postIdxList[curChoiceDetail.post.objectId] do
							local curPostListIdx = postIdxList[curChoiceDetail.post.objectId][j]
							if (postList[curPostListIdx].choices == nil) then
								postList[curPostListIdx].choices = {}
							end
							postList[curPostListIdx].choices[curChoiceDetail.letter] = curChoiceDetail
						end
					end
				end
			end
			local response = json.decode(event[1].response)
			saveUserVoteToPost(postList, postIdxListForVoted, response)
			local queryUserString = ""
			local userCount = 0
			local i = 1
			local postTotal = #postList
			while (i <= postTotal) do
				local postData = postList[i].post
				local postCreatorId = postData.user.objectId
				if ((postCreatorId ~= userId) and (postData.friend_only == true) and (friendList.byId[postCreatorId] ~= true)) then
					table.remove(postList, i)
					postTotal = postTotal - 1
				else
					local curUserId = postList[i].post.user.objectId
					if (postIdxListForPostCreator[curUserId]) then
						postIdxListForPostCreator[curUserId][#postIdxListForPostCreator[curUserId] + 1] = i
					else
						postIdxListForPostCreator[curUserId] = {i}
						queryUserString = queryUserString .. ",\"" .. curUserId .. "\""
						userCount = userCount + 1
					end
					i = i + 1
				end
			end
			queryUserString = string.gsub(queryUserString, "^(,)", "")
			if (userCount > 1) then
				queryUserString = "{\"objectId\":{\"$in\":[" .. queryUserString .. "]}}"
			elseif (userCount == 1) then
				queryUserString = "{\"objectId\":" .. queryUserString .. "}"
			else
				if (type(listener) == "function") then
					event.lastTimeStamp = lastTimeStamp
					event.postData = postList
					listener(event)
				end
				return
			end
			local apiParams = createParamsForApiNumber(1)
			apiParams[1].params = {
										headers = createVorumNetworkHeader(sessionToken),
									}
			apiParams[1].url = API_USER_BASE .. "?where=" .. url.escape(queryUserString)
			apiParams[1].method = "GET"
			networkHandler.requestNetwork(apiParams, getMemberPostUserDetailListener, "getMemberPostUserDetail")
		end
	end

	local function getPostAndShareListener(event)
		if (event.isError) then
			if (type(listener) == "function") then
				listener(event)
			end
			return
		else
			local response = json.decode(event[1].response)
			local postTotal = #response.result
			local queryPostStr = ""
			local queryPostStrForPost = ""
			local queryPostStrForVoted = ""
			local sharePostCount = 0
			if ((response.result) and (postTotal > 0)) then
				postList = response.result
				lastTimeStamp = response.result[postTotal].sort
				for i = 1, postTotal do
					local postId = postList[i].post.objectId
					if (postList[i].post.__type == "Pointer") then
						if (postIdxList[postId]) then
							postIdxList[postId][#postIdxList[postId] + 1] = i
						else
							postIdxList[postId] = {i}
							queryPostStr = queryPostStr .. string.format(",{\"__type\":\"Pointer\",\"className\":\"Post\",\"objectId\":\"%s\"}", postId)
							queryPostStrForPost = queryPostStrForPost .. ",\"" .. postId .. "\""
							sharePostCount = sharePostCount + 1
						end
					end
					if (postIdxListForVoted[postId]) then
						postIdxListForVoted[postId][#postIdxListForVoted[postId] + 1] = i
					else
						postIdxListForVoted[postId] = {i}
						queryPostStrForVoted = queryPostStrForVoted .. string.format(",{\"__type\":\"Pointer\",\"className\":\"Post\",\"objectId\":\"%s\"}", postId)
					end
				end
			end
			if (postTotal > 0) then
				queryPostStr = string.gsub(queryPostStr, "^(,)", "")
				queryPostStrForPost = string.gsub(queryPostStrForPost, "^(,)", "")
				queryPostStrForVoted = string.gsub(queryPostStrForVoted, "^(,)", "")
				if (sharePostCount > 1) then
					queryPostStr = "{\"post\":{\"$in\":[" .. queryPostStr .. "]}}"
					queryPostStrForPost = "{\"objectId\":{\"$in\":[" .. queryPostStrForPost .. "]}}"
				else
					queryPostStr = "{\"post\":" .. queryPostStr .. "}"
					queryPostStrForPost = "{\"objectId\":" .. queryPostStrForPost .. "}"
				end
				if (#postList > 0) then
					queryPostStrForVoted = "\"post\":{\"$in\":[" .. queryPostStrForVoted .. "]}"
				end
				local apiParams = createParamsForApiNumber(1)
				apiParams[1].params = {
											headers = createVorumNetworkHeader(sessionToken),
										}
				queryPostStrForVoted = "{" .. queryPostStrForVoted .. string.format(",\"user\":{\"__type\":\"Pointer\",\"className\":\"_User\",\"objectId\":\"%s\"}", userId) .. "}"
				apiParams[1].url = API_CLASS_BASE .. "Vote?where=" .. url.escape(queryPostStrForVoted)
				apiParams[1].method = "GET"
				if (sharePostCount > 0) then
					apiParams[2] = {}
					apiParams[2].params = {
												headers = createVorumNetworkHeader(sessionToken),
											}
					apiParams[2].url = API_CLASS_BASE .. "Choice?where=" .. url.escape(queryPostStr)
					apiParams[2].method = "GET"
					apiParams[3] = {}
					apiParams[3].params = {
												headers = createVorumNetworkHeader(sessionToken),
											}
					apiParams[3].url = API_CLASS_BASE .. "Coupon?where=" .. url.escape(queryPostStr)
					apiParams[3].method = "GET"
					apiParams[4] = {}
					apiParams[4].params = {
												headers = createVorumNetworkHeader(sessionToken),
											}
					apiParams[4].url = API_CLASS_BASE .. "Post?where=" .. url.escape(queryPostStrForPost)
					apiParams[4].method = "GET"
				end
				networkHandler.requestNetwork(apiParams, getMemberPostDetailListener, "getMemberPostDetail")
			else
				if (type(listener) == "function") then
					event.lastTimeStamp = lastTimeStamp
					listener(event)
				end
			end
		end
	end

	local apiParams = createParamsForApiNumber(1)
	local paramsBody = {}
	paramsBody.user_id = memberId
	paramsBody.timestamp = startDate
	paramsBody.limit = postNumber
	paramsBody.get_expired = getExpired
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
								body = json.encode(paramsBody),
							}
	apiParams[1].method = "POST"
	apiParams[1].url = API_FNC_BASE .. "getPostAndShareByUser"
	return networkHandler.requestNetwork(apiParams, getPostAndShareListener, "getPostAndShareByUser")
end

---------------------------------------------------------------------------------
-- My post
---------------------------------------------------------------------------------

local getFriendPostArgTable = {
					{name = "userId", type = "string"},
					{name = "friendList", type = "table"},
					{name = "startPosIdx", type = "number", canSkip = true},
					{name = "sessionToken", type = "string"},
					{name = "postNumber", type = "number", canSkip = true},
					{name = "listener", type = "function", canSkip = true},
					fncName = "getFriendPost"
				}
-- function networkFunction.getMemberPost(userId, friendList[, startPosIdx], sessionToken[, postNumber][, listener])
function networkFunction.getFriendPost(...)
	local fncArg = fncArgUtility.parseArg(getFriendPostArgTable, arg)
	local userId, friendList, startPosIdx, sessionToken, postNumber, listener = fncArg.userId, fncArg.friendList, fncArg.startPosIdx, fncArg.sessionToken, fncArg.postNumber, fncArg.listener

	local postIdxListForPostCreator = {}
	local postList = {}
	local postIdxList = {}

	local function getFriendPostDetailListener(event)
		if (type(listener) == "function") then
			if (event.isError) then
				listener(event)
				return
			else
				local userResponse = json.decode(event[4].response)
				if ((userResponse.results) and (#userResponse.results > 0)) then
					for i = 1, #userResponse.results do
						local curUserDetail = userResponse.results[i]
						for j = 1, #postIdxListForPostCreator[curUserDetail.objectId] do
							local curPostListIdx = postIdxListForPostCreator[curUserDetail.objectId][j]
							postList[curPostListIdx].post.user = curUserDetail
						end
					end
				end
				local couponResponse = json.decode(event[3].response)
				if ((couponResponse.results) and (#couponResponse.results > 0)) then
					for i = 1, #couponResponse.results do
						local curCouponDetail = couponResponse.results[i]
						for j = 1, #postIdxList[curCouponDetail.post.objectId] do
							local curPostListIdx = postIdxList[curCouponDetail.post.objectId][j]
							postList[curPostListIdx].post = curCouponDetail
						end
					end
				end
				local choiceResponse = json.decode(event[2].response)
				if ((choiceResponse.results) and (#choiceResponse.results > 0)) then
					for i = 1, #choiceResponse.results do
						local curChoiceDetail = choiceResponse.results[i]
						for j = 1, #postIdxList[curChoiceDetail.post.objectId] do
							local curPostListIdx = postIdxList[curChoiceDetail.post.objectId][j]
							if (postList[curPostListIdx].choices == nil) then
								postList[curPostListIdx].choices = {}
							end
							postList[curPostListIdx].choices[curChoiceDetail.letter] = curChoiceDetail
						end
					end
				end
				local response = json.decode(event[1].response)
				saveUserVoteToPost(postList, postIdxList, response)
				event.postData = postList
				listener(event)
			end
		end
	end

	local function getFriendPostListener(event)
		if (event.isError) then
			if (type(listener) == "function") then
				listener(event)
			end
			return
		else
			local response = json.decode(event[1].response)
			if ((response.results) and (#response.results > 0)) then
				local queryPostStr = ""
				local queryUserString = ""
				local sharePostCount = 0
				postList = {}
				for i = 1, #response.results do
					postList[i] = {}
					postList[i].post = response.results[i]
					local postId = postList[i].post.objectId
					if (postIdxList[postId]) then
						postIdxList[postId][#postIdxList[postId] + 1] = i
					else
						postIdxList[postId] = {i}
						queryPostStr = queryPostStr .. string.format(",{\"__type\":\"Pointer\",\"className\":\"Post\",\"objectId\":\"%s\"}", postId)
					end
					local curUserId = postList[i].post.user.objectId
					if (postIdxListForPostCreator[curUserId]) then
						postIdxListForPostCreator[curUserId][#postIdxListForPostCreator[curUserId] + 1] = i
					else
						postIdxListForPostCreator[curUserId] = {i}
						queryUserString = queryUserString .. ",\"" .. curUserId .. "\""
					end
				end
				queryPostStr = string.gsub(queryPostStr, "^(,)", "")
				queryUserString = string.gsub(queryUserString, "^(,)", "")
				if (#postList > 0) then
					queryPostStr = "\"post\":{\"$in\":[" .. queryPostStr .. "]}"
					queryUserString = "{\"objectId\":{\"$in\":[" .. queryUserString .. "]}}"
				end
				local apiParams = createParamsForApiNumber(4)
				apiParams[1].params = {
											headers = createVorumNetworkHeader(sessionToken),
										}
				queryPostStr = "{" .. queryPostStr .. "}"
				apiParams[1].url = API_CLASS_BASE .. "Vote?where=" .. url.escape(queryPostStr)
				apiParams[1].method = "GET"
				apiParams[2].params = {
											headers = createVorumNetworkHeader(sessionToken),
										}
				apiParams[2].url = API_CLASS_BASE .. "Choice?where=" .. url.escape(queryPostStr)
				apiParams[2].method = "GET"
				apiParams[3].params = {
											headers = createVorumNetworkHeader(sessionToken),
										}
				apiParams[3].url = API_CLASS_BASE .. "Coupon?where=" .. url.escape(queryPostStr)
				apiParams[3].method = "GET"
				apiParams[4].params = {
											headers = createVorumNetworkHeader(sessionToken),
										}
				apiParams[4].url = API_USER_BASE .. "?where=" .. url.escape(queryUserString)
				apiParams[4].method = "GET"
				networkHandler.requestNetwork(apiParams, getFriendPostDetailListener, "getFriendPostDetail")
			else
				if (type(listener) == "function") then
					listener(event)
				end
			end
		end
	end

	if (#friendList.byNumber <= 0) then
		return nil
	end
	local friendQueryStr = ""
	for i = 1, #friendList.byNumber do
		friendQueryStr = friendQueryStr .. ",{\"__type\":\"Pointer\",\"className\":\"_User\",\"objectId\":\"" .. friendList.byNumber[i] .. "\"}"
	end
	friendQueryStr = string.gsub(friendQueryStr, "^(,)", "")
	local queryString
	local expireTimeStr = tostring(os.time() * 1000)
	if (#friendList.byNumber > 1) then
		queryString = "{\"user\":{\"$in\":[" .. friendQueryStr .. "]},\"expire_time\":{\"$gt\":" .. expireTimeStr .. "}}"
	else
		queryString = "{\"user\":" .. friendQueryStr .. ",\"expire_time\":{\"$gt\":" .. expireTimeStr .. "}}"
	end
	local urlEncodedString = "&order=-pushed_time"
	if (startPosIdx) then
		urlEncodedString = urlEncodedString .. "&skip=" .. tostring(startPosIdx)
	end
	if (postNumber) then
		urlEncodedString = urlEncodedString .. "&limit=" .. tostring(postNumber)
	end
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
							}
	apiParams[1].method = "GET"
	apiParams[1].url = API_CLASS_BASE .. "/Post?where=" .. url.escape(queryString) .. urlEncodedString
	return networkHandler.requestNetwork(apiParams, getFriendPostListener, "getFriendPost")
end

local getUserVotedPostArgTable = {
					{name = "userId", type = "string"},
					{name = "friendList", type = "table"},
					{name = "startPosIdx", type = "number", canSkip = true},
					{name = "sessionToken", type = "string"},
					{name = "postNumber", type = "number", canSkip = true},
					{name = "listener", type = "function", canSkip = true},
					fncName = "getUserVotedPost"
				}
-- function networkFunction.getUserVotedPost(userId, friendList[, startPosIdx], sessionToken[, postNumber][, listener])
function networkFunction.getUserVotedPost(...)
	local fncArg = fncArgUtility.parseArg(getUserVotedPostArgTable, arg)
	local userId, friendList, startPosIdx, sessionToken, postNumber, listener = fncArg.userId, fncArg.friendList, fncArg.startPosIdx, fncArg.sessionToken, fncArg.postNumber, fncArg.listener

	local postIdxListForPostCreator = {}
	local postList = {}
	local postIdxList = {}
	local votedData
	local votedDataIdxList = {}
	local isPostFilteredByFriendList

	local function getVotedPostDetailListener(event)
		if (type(listener) == "function") then
			if (event.isError) then
				listener(event)
				return
			else
				local userResponse = json.decode(event[3].response)
				if ((userResponse.results) and (#userResponse.results > 0)) then
					for i = 1, #userResponse.results do
						local curUserDetail = userResponse.results[i]
						for j = 1, #postIdxListForPostCreator[curUserDetail.objectId] do
							local curPostListIdx = postIdxListForPostCreator[curUserDetail.objectId][j]
							postList[curPostListIdx].post.user = curUserDetail
						end
					end
				end
				local couponResponse = json.decode(event[2].response)
				if ((couponResponse.results) and (#couponResponse.results > 0)) then
					for i = 1, #couponResponse.results do
						local curCouponDetail = couponResponse.results[i]
						for j = 1, #postIdxList[curCouponDetail.post.objectId] do
							local curPostListIdx = postIdxList[curCouponDetail.post.objectId][j]
							postList[curPostListIdx].coupon = curCouponDetail
						end
					end
				end
				local choiceResponse = json.decode(event[1].response)
				if ((choiceResponse.results) and (#choiceResponse.results > 0)) then
					for i = 1, #choiceResponse.results do
						local curChoiceDetail = choiceResponse.results[i]
						for j = 1, #postIdxList[curChoiceDetail.post.objectId] do
							local curPostListIdx = postIdxList[curChoiceDetail.post.objectId][j]
							if (postList[curPostListIdx].choices == nil) then
								postList[curPostListIdx].choices = {}
							end
							postList[curPostListIdx].choices[curChoiceDetail.letter] = curChoiceDetail
							if (votedDataIdxList[curChoiceDetail.objectId]) then
								postList[curPostListIdx].choices[curChoiceDetail.letter].isUserVoted = true
							end
						end
					end
				end
				event.postData = postList
				listener(event)
			end
		end
	end

	local function getUserVotedPostListener(event)
		if (event.isError) then
			if (type(listener) == "function") then
				listener(event)
			end
			return
		else
			local response = json.decode(event[1].response)
			if ((response.results) and (#response.results > 0)) then
				local queryPostStr = ""
				local queryUserString = ""
				local sharePostCount = 0
				postList = {}
				local postTotal = #response.results
				local i = 1
				while (i <= postTotal) do
					local postData = response.results[i]
					local postCreatorId = postData.user.objectId
					if ((postCreatorId ~= userId) and (postData.friend_only == true) and (friendList.byId[postCreatorId] ~= true)) then
						table.remove(response.results, i)
						postTotal = postTotal - 1
						isPostFilteredByFriendList = true
					else
						postList[i] = {}
						postList[i].post = response.results[i]
						local postId = postList[i].post.objectId
						if (postIdxList[postId]) then
							postIdxList[postId][#postIdxList[postId] + 1] = i
						else
							postIdxList[postId] = {i}
							queryPostStr = queryPostStr .. string.format(",{\"__type\":\"Pointer\",\"className\":\"Post\",\"objectId\":\"%s\"}", postId)
						end
						local curUserId = postList[i].post.user.objectId
						if (postIdxListForPostCreator[curUserId]) then
							postIdxListForPostCreator[curUserId][#postIdxListForPostCreator[curUserId] + 1] = i
						else
							postIdxListForPostCreator[curUserId] = {i}
							queryUserString = queryUserString .. ",\"" .. curUserId .. "\""
						end
						i = i + 1
					end
				end
				queryPostStr = string.gsub(queryPostStr, "^(,)", "")
				queryUserString = string.gsub(queryUserString, "^(,)", "")
				if (#postList > 0) then
					queryPostStr = "{\"post\":{\"$in\":[" .. queryPostStr .. "]}}"
					queryUserString = "{\"objectId\":{\"$in\":[" .. queryUserString .. "]}}"
					local apiParams = createParamsForApiNumber(3)
					apiParams[1].params = {
												headers = createVorumNetworkHeader(sessionToken),
											}
					apiParams[1].url = API_CLASS_BASE .. "Choice?where=" .. url.escape(queryPostStr)
					apiParams[1].method = "GET"
					apiParams[2].params = {
												headers = createVorumNetworkHeader(sessionToken),
											}
					apiParams[2].url = API_CLASS_BASE .. "Coupon?where=" .. url.escape(queryPostStr)
					apiParams[2].method = "GET"
					apiParams[3].params = {
												headers = createVorumNetworkHeader(sessionToken),
											}
					apiParams[3].url = API_USER_BASE .. "?where=" .. url.escape(queryUserString)
					apiParams[3].method = "GET"
					networkHandler.requestNetwork(apiParams, getVotedPostDetailListener, "getVotedPostDetail")
				else
					if (type(listener) == "function") then
						event.isPostFilteredByFriendList = isPostFilteredByFriendList
						listener(event)
					end
				end
			else
				if (type(listener) == "function") then
					listener(event)
				end
			end
		end
	end

	local function getUserVotedListener(event)
		if (event.isError) then
			if (type(listener) == "function") then
				listener(event)
			end
		else
			local response = json.decode(event[1].response)
			if ((response.results) and (#response.results > 0)) then
				local queryString = ""
				votedData = response.results
				for i = 1, #response.results do
					local curPostId = response.results[i].post.objectId
					local curChoiceId = response.results[i].choice.objectId
					votedDataIdxList[curChoiceId] = i
					queryString = queryString .. ",\"" .. curPostId .. "\""
				end
				queryString = string.gsub(queryString, "^(,)", "")
				queryString = "{\"objectId\":{\"$in\":[" .. queryString .. "]}}"
				local apiParams = createParamsForApiNumber(1)
				apiParams[1].params = {
											headers = createVorumNetworkHeader(sessionToken),
										}
				apiParams[1].url = API_CLASS_BASE .. "Post?where=" .. url.escape(queryString)
				apiParams[1].method = "GET"
				networkHandler.requestNetwork(apiParams, getUserVotedPostListener, "getUserVotedPost")
			else
				if (type(listener) == "function") then
					event.isUserNoVote = true
					listener(event)
				end
			end
		end
	end

	local apiParams = createParamsForApiNumber(1)
	local queryString = "{\"user\":{\"__type\":\"Pointer\",\"className\":\"_User\",\"objectId\":\"" .. userId .. "\"}}"
	local urlEncodedString = "&order=-createdAt"
	if (startPosIdx) then
		urlEncodedString = urlEncodedString .. "&skip=" .. tostring(startPosIdx)
	end
	if (postNumber) then
		urlEncodedString = urlEncodedString .. "&limit=" .. tostring(postNumber)
	end
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
							}
	apiParams[1].method = "GET"
	apiParams[1].url = API_CLASS_BASE .. "/Vote?where=" .. url.escape(queryString) .. urlEncodedString
	return networkHandler.requestNetwork(apiParams, getUserVotedListener, "getUserVoted")
end

function networkFunction.getUserCoupon(userId, sessionToken, listener)
	local couponListIdx = {}
	local couponList

	local function getCouponListener(event)
		if (type(listener) == "function") then
			if (event.isError) then
				listener(event)
			else
				local response = json.decode(event[1].response)
				if ((response.results) and (#response.results > 0)) then
					for i = 1, #response.results do
						local couponId = response.results[i].objectId
						couponList[couponListIdx[couponId]].coupon = response.results[i]
					end
				end
			end
			event.couponList = couponList
			listener(event)
		end
	end

	local function getUserCouponListener(event)
		if (event.isError) then
			if (type(listener) == "function") then
				event.couponList = {}
				listener(event)
			end
		else
			local response = json.decode(event[1].response)
			if ((response.results) and (#response.results > 0)) then
				couponList = response.results
				local queryString = ""
				for i = 1, #response.results do
					local couponId = response.results[i].coupon.objectId
					response.results[i].coupon = nil
					couponListIdx[couponId] = i
					queryString = queryString .. ",\"" .. couponId .. "\""
				end
				queryString = "{\"objectId\":{\"$in\":[" .. string.gsub(queryString, "^(,)", "") .. "]}}"
				local apiParams = createParamsForApiNumber(1)
				apiParams[1].params = {
											headers = createVorumNetworkHeader(sessionToken),
										}
				apiParams[1].method = "GET"
				apiParams[1].url = API_CLASS_BASE .. "/Coupon?where=" .. url.escape(queryString)
				networkHandler.requestNetwork(apiParams, getCouponListener, "getCoupon")
			else
				if (type(listener) == "function") then
					event.couponList = {}
					listener(event)
				end
			end
		end
	end

	local apiParams = createParamsForApiNumber(1)
	local curTime = os.time() * 1000
	local queryString = "{\"user\":{\"__type\":\"Pointer\",\"className\":\"_User\",\"objectId\":\"" .. userId .. "\"},\"expire\":{\"$gt\":" .. tostring(curTime) .. "}}"
	apiParams[1].params = {
								headers = createVorumNetworkHeader(sessionToken),
							}
	apiParams[1].method = "GET"
	apiParams[1].url = API_CLASS_BASE .. "/UserCoupon?where=" .. url.escape(queryString)
	return networkHandler.requestNetwork(apiParams, getUserCouponListener, "getUserCoupon")
end


function networkFunction.downloadImage(url, method, listener, ...)
	local params, filename, baseDirectory
	params = {}
	local argIdx = 1
	if (type(arg[argIdx]) == "table") then
		params = arg[argIdx]
		argIdx = argIdx + 1
	end
	filename = arg[argIdx]
	argIdx = argIdx + 1
	if (type(arg[argIdx]) == "userdata") then
		baseDirectory = arg[argIdx]
		argIdx = argIdx + 1
	end
	params.response = {
							filename = filename,
							baseDirectory = baseDirectory,
						}
	local apiParams = createParamsForApiNumber(1)
	apiParams[1].url = url
	apiParams[1].params = params
	apiParams[1].method = method
	return networkHandler.requestNetwork(apiParams, listener, "downloadImage")
end


-- Get Post manually if necessary
-- local json = require("json")
-- local url = require("socket.url")
-- local postGroup = event.target.parent

-- local function getChoiceNetworkListener(event)
-- 	if (event.isError) then
-- 		alert.show("network error", "network error")
-- 	else
-- 		print(event.response)
-- 	end
-- end

-- local function getPostNetworkListener(event)
-- 	if (event.isError) then
-- 		alert.show("network error", "network error")
-- 	else
-- 		if (event.response) then
-- 			local postIdAppendString = ""
-- 			local response = json.decode(event.response)
-- 			for i = 1, #response.results do
-- 				if (postIdAppendString ~= "") then
-- 					postIdAppendString = postIdAppendString .. ","
-- 				end
-- 				postIdAppendString = postIdAppendString .. "{\"__type\":\"Pointer\",\"className\":\"Post\",\"objectId\":\"" .. response.results[i].objectId .. "\"}"
-- 			end
-- 			local params = {
-- 								headers = {
-- 												["Content-Type"] = "application/json",
-- 												["X-Parse-Application-Id"] = "FeOHPlcGeWoAxydyXBYvMrNU28JBcBAKsVRagLZd",
-- 												["X-Parse-REST-API-Key"] = "X1EqrSCZ2CJAEummQiHpnegKV1Rway6ob7skEIdJ",
-- 											},
-- 							}
-- 			-- network.request("https://api.parse.com/1/classes/Choice?where=" .. url.escape("{\"$relatedTo\":{\"object\":{\"__type\":\"Pointer\",\"className\":\"Post\",\"objectId\":{\"$all\":[" .. postIdAppendString .. "]}},\"key\":\"text\"}}"), "GET", getChoiceNetworkListener, params)
-- 			print("https://api.parse.com/1/classes/Choice?where=" .. "{\"post\":{\"$in\":[" .. postIdAppendString .. "]}}")
-- 			network.request("https://api.parse.com/1/classes/Choice?where=" .. url.escape("{\"post\":{\"$in\":[" .. postIdAppendString .. "]}}"), "GET", getChoiceNetworkListener, params)
-- 		end
-- 		-- print(event.response)
-- 	end
-- end
-- local params = {
-- 					headers = {
-- 									["Content-Type"] = "application/json",
-- 									["X-Parse-Application-Id"] = "FeOHPlcGeWoAxydyXBYvMrNU28JBcBAKsVRagLZd",
-- 									["X-Parse-REST-API-Key"] = "X1EqrSCZ2CJAEummQiHpnegKV1Rway6ob7skEIdJ",
-- 								},
-- 				}
-- network.request("https://api.parse.com/1/classes/Post?where=" .. url.escape("{\"objectId\":{\"$in\":[\"GGQfjhCDZ8\",\"SizbAHiCSp\"]}}"), "GET", getPostNetworkListener, params)



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
