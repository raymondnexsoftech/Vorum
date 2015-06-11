---------------------------------------------------------------
-- FacebookLogin.lua
--
-- Functions to handle Facebook Login
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
local facebookModule = require("Module.FacebookModule")
local json = require("json")
local localization = require("Localization.Localization")
local networkFunction = require("Network.newNetworkFunction")
local networkFile = require("Network.NetworkFile")
local lfs = require("lfs")

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local FACEBOOK_PIC_LOC = "createUser/pic"

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------

local facebookLogin = {}

function facebookLogin.login(listener)
	local facebookId, facebookToken = facebookModule.getUserInfo()
	local userId, sessionToken
	local emailLoginListener
	local userDetail

	local function linkFacebookListener(event)
		native.setActivityIndicator(false)
		if (event.isError ~= true) then
			local response = json.decode(event[1].response)
			if (response.code == 12) then
				native.showAlert(localization.getLocalization("fb_accountLinked"),
									localization.getLocalization("fb_accountLinkedSuccessfully"),
									{localization.getLocalization("ok")})
				event.isLoginSuccess = true
				event.userId = userId
				event.sessionToken = sessionToken
				event.fbToken = facebookToken
			else
				event.linkError = true
			end
		end
		listener(event)
		return
	end

	local function linkAccountListener(email, password)
		native.setActivityIndicator(true)
		networkFunction.login({email = email, password = password}, emailLoginListener)
	end

	emailLoginListener = function(event)
		if (event.isError) then
			native.setActivityIndicator(false)
			listener(event)
			return
		end
		local isLoginError = false
		local loginErrorSentence = nil
		local response = json.decode(event[1].response)
		if (response.code) then
			if (response.code == 3) then
				isLoginError = true
				loginErrorSentence = localization.getLocalization("fb_cantLoginAccToLink_Retry")
			elseif (response.code == 14) then
				isLoginError = true
				loginErrorSentence = localization.getLocalization("fb_notVerifiedAccToLink_Retry")
			else
				-- other error
				native.setActivityIndicator(false)
				listener(event)
				return
			end
		elseif (response.fb_token) then
			isLoginError = true
			loginErrorSentence = localization.getLocalization("fb_accAlreadyLinked_Retry")
		end
		if (isLoginError) then
			native.setActivityIndicator(false)
			native.showAlert(localization.getLocalization("fb_cantLoginAccToLink"),
								loginErrorSentence,
								{localization.getLocalization("retry"), localization.getLocalization("cancel")},
								function(e)
									if (e.index == 1) then
										event.linkAccountListener = linkAccountListener
										event.isLinkAccount = true
										listener(event)
										return
									else
										event.isLoginError = true
										listener(event)
										return
									end
								end)
		else
			userId = response.user_id
			sessionToken = response.session
			networkFunction.fbLinkAccount(facebookToken, linkFacebookListener)
		end
	end

	local function facebookLoginReturnCreateAcc(picLoc)
		if (picLoc) then
			userDetail.profilePic = picLoc
		end
		local event = {}
		event.isCreateNewAcc = true
		event.facebookId = facebookId
		event.facebookToken = facebookToken
		event.userDetail = userDetail
		listener(event)
	end

	local function downloadUserFacebookPicComplete(event)
		if (event.phase == "ended") then
			native.setActivityIndicator(false)
			if (event.isError) then
				facebookLoginReturnCreateAcc()
				return
			end
			facebookLoginReturnCreateAcc(event.path)
		end
	end

	local function getUserFacebookPicListener(event)
		if (event.isError) then
			native.setActivityIndicator(false)
			facebookLoginReturnCreateAcc()
			return
		end
		if (event.response) then
			local response = json.decode(event.response)
			if ((type(response.data) == "table")
				and (response.data.is_silhouette == false)
				and (response.data.url ~= nil) and (response.data.url ~= "")) then
					networkFile.getDownloadFile(response.data.url, FACEBOOK_PIC_LOC, downloadUserFacebookPicComplete)
					return
			end
		end
		native.setActivityIndicator(false)
		facebookLoginReturnCreateAcc()
	end

	local function showNoFacebookAccInServer()
		-- no Faceboook account in server
		timer.performWithDelay(1, function()
										native.showAlert(localization.getLocalization("fb_noFbAcc"),
															localization.getLocalization("fb_noFbAcc_Create"),
															{localization.getLocalization("create"), localization.getLocalization("link"), localization.getLocalization("cancel")},
															function(e)
																if (e.index == 1) then
																	native.setActivityIndicator(true)
																	local filePath = system.pathForFile(FACEBOOK_PIC_LOC, system.TemporaryDirectory)
																	if (lfs.chdir(filePath)) then
																		for file in lfs.dir(filePath) do
																			if (string.find(file, "^%.") == nil) then
																				local actualPath = filePath .. "/" .. file
																				if (lfs.attributes(actualPath,"mode") == "file") then
																					os.remove(actualPath)
																				end
																			end
																		end
																	end
																	facebookModule.request("me/picture", "GET", {redirect="false"}, getUserFacebookPicListener)
																	return
																elseif (e.index == 2) then
																	local event = {}
																	event.linkAccountListener = linkAccountListener
																	event.isLinkAccount = true
																	listener(event)
																else
																	return
																end
															end)
									end, 1)
	end

	local function checkUserEmailListener(event)
		native.setActivityIndicator(false)
		if (event.isError) then
			listener(event)
			return
		end
		local response = json.decode(event[1].response)
		local isUserFound = false
		if (response) then
			for i = 1, #response do
				if (response[i].email == userDetail.email) then
					isUserFound = true
					break
				end
			end
		end
		if (isUserFound) then
			local alertMsg = string.format(localization.getLocalization("fb_linkWithThisEmail"), userDetail.email)
			native.showAlert(localization.getLocalization("fb_foundAcc"),
								alertMsg,
								{localization.getLocalization("yes"), localization.getLocalization("no")},
								function(e)
									if (e.index == 1) then
										event.email = userDetail.email
										event.linkAccountListener = linkAccountListener
										event.isLinkAccount = true
										listener(event)
										return
									else
										showNoFacebookAccInServer()
										return
									end
								end)
		else
			showNoFacebookAccInServer()
		end
	end

	local function getUserFacebookDetailListener(event)
		if (event.isError) then
			native.setActivityIndicator(false)
			listener(event)
			return
		end
		if (event.response) then
			userDetail = json.decode(event.response)
		end
		if (userDetail.email) then
			networkFunction.searchUser({searchStr = userDetail.email}, checkUserEmailListener)
			return
		end
		native.setActivityIndicator(false)
		showNoFacebookAccInServer()
	end

	local function fbLoginlistener(event)
		if (event.isError) then
			native.setActivityIndicator(false)
			listener(event)
			return
		end
		local response = json.decode(event[1].response)
		if (response.code) then
			if (response.code == 7) then
				facebookModule.request("me", getUserFacebookDetailListener)
				return
			else
				-- other error
				listener(event)
 			end
		else
			event.isLoginSuccess = true
			event.userId = response.user_id
			event.sessionToken = response.session
			event.fbToken = facebookToken
			listener(event)
		end
		native.setActivityIndicator(false)
	end

	local function loginListener(event)
		facebookId, facebookToken = facebookModule.getUserInfo()
		if (facebookToken) then
			networkFunction.fbLogin(facebookToken, fbLoginlistener)
		else
			native.setActivityIndicator(false)
			native.showAlert(localization.getLocalization("fb_cannotRetrieveFacebookData"),
								localization.getLocalization("fb_cannotRetrieveFacebookData"),
								{localization.getLocalization("ok")})
			event.isLoginError = true
			listener(event)
		end
		return true
	end

	native.setActivityIndicator(true)
	facebookModule.login({"email"}, true, loginListener)
end

return facebookLogin

