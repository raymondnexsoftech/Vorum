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

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------

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

	local function fbLoginlistener(event)
		native.setActivityIndicator(false)
		if (event.isError) then
			listener(event)
			return
		end
		local response = json.decode(event[1].response)
		if (response.code) then
			if (response.code == 7) then
				-- no Faceboook account in server
				native.showAlert(localization.getLocalization("fb_noFbAcc"),
									localization.getLocalization("fb_noFbAcc_Create"),
									{localization.getLocalization("create"), localization.getLocalization("link"), localization.getLocalization("cancel")},
									function(e)
										if (e.index == 1) then
											event.isCreateNewAcc = true
											event.facebookId = facebookId
											event.facebookToken = facebookToken
											listener(event)
											return
										elseif (e.index == 2) then
											event.linkAccountListener = linkAccountListener
											event.isLinkAccount = true
											listener(event)
										else
											return
										end
									end)
			else
				-- other error
				listener(event)
				return
 			end
		else
			event.isLoginSuccess = true
			event.userId = response.user_id
			event.sessionToken = response.session
			event.fbToken = facebookToken
			listener(event)
			return
		end
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
	facebookModule.login(true, loginListener)
end

return facebookLogin

