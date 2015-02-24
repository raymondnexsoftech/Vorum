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
local networkFunction = require("Network.NetworkFunction")
local json = require("json")
local localization = require("Localization.Localization")

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

function facebookLogin.fbLoginProcedure(fbId, fbToken, email, password, listener)
	local sessionToken = ""
	local function linkFacebookListener(event)
		if (isError) then
			listener(event)
			return
		end
		local response = json.decode(event[1].response)
		if (response.code) then
		else
			native.showAlert(localization.getLocalization("fb_accountLinked"),
								localization.getLocalization("fb_accountLinkedSuccessfully"),
								{localization.getLocalization("ok")},
								function(event)
									if (event.index == 1) then
										event.isLoginSuccess = true
										event.sessionToken = sessionToken
										listener(event)
										return
									end
								end
								)
		end
	end

	local function normalLoginListener(event)
		if (isError) then
			listener(event)
			return
		end
		local response = json.decode(event[1].response)
		if (response.code) then
			if (response.code == 101) then
				native.showAlert(localization.getLocalization("fb_cantLoginAccToLink"),
									localization.getLocalization("fb_cantLoginAccToLink_Create"),
									{localization.getLocalization("ok"), localization.getLocalization("cancel")},
									function(event)
										if (event.index == 1) then
											event.isCreateNewAcc = true
											listener(event)
											return
										else
											listener(event)
											return
										end
									end
									)
			else
				-- other error
				listener(event)
				return
			end
		else
			local accObjId = response.objectId
			sessionToken = response.sessionToken
			native.showAlert(localization.getLocalization("fb_linkToAcc"),
								localization.getLocalization("fb_linkFbToAcc"),
								{localization.getLocalization("ok"), localization.getLocalization("cancel")},
								function(event)
									if (event.index == 1) then
										networkFunction.fbLinkAccount(accObjId, sessionToken, fbId, fbToken, linkFacebookListener)
									else
										native.showAlert(localization.getLocalization("fb_createAcc"),
															localization.getLocalization("fb_createNewAcc"),
															{localization.getLocalization("ok"), localization.getLocalization("cancel")},
															function(event)
																if (event.index == 1) then
																	event.isCreateNewAcc = true
																	listener(event)
																	return
																else
																	listener(event)
																	return
																end
															end)
									end
								end
								)
		end
	end

	local function fbLoginlistener(event)
		if (isError) then
			listener(event)
			return
		end
		local response = json.decode(event[1].response)
		if (response.code) then
			if (response.code == 200) then
				-- no Faceboook account in server
				if ((email ~= "") and (password ~= "")) then
					networkFunction.login(email, password, normalLoginListener)
				else
					native.showAlert(localization.getLocalization("fb_noFbAcc"),
										localization.getLocalization("fb_noFbAcc_Create"),
										{localization.getLocalization("create"), localization.getLocalization("link")},
										function(event)
											if (event.index == 1) then
												event.isCreateNewAcc = true
												listener(event)
												return
											else
												native.showAlert(localization.getLocalization("fb_inputLoginData"),
																	localization.getLocalization("fb_inputLoginDataToLink"),
																	{localization.getLocalization("ok")},
																	function(event)
																		listener(event)
																		return
																	end
																	)
												return
											end
										end
										)
				end
				return
			else
				-- other error
				listener(event)
				return
 			end
		else
			-- Login Success
			event.isLoginSuccess = true
			event.sessionToken = response.sessionToken
			listener(event)
			return
		end
	end

	networkFunction.fbLogin(fbId, fbToken, fbLoginlistener)
end

return facebookLogin

