---------------------------------------------------------------
-- main.lua
--
-- program start here
---------------------------------------------------------------

---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------
local storyboard = require ( "storyboard" )
local coronaTextField = require("Module.CoronaTextField")
require ( "SystemUtility.Debug" )
local global = require( "GlobalVar.global" )
local saveData = require( "SaveData.SaveData" )
local json = require( "json" )
local localization = require("Localization.Localization")
local headTabFnc = require( "ProjectObject.HeadTabFnc" )
local facebookLogin = require( "Misc.FacebookLogin" )
local facebook = require( "facebook" )
local popup = require("Module.popup")
local newNetworkFunction = require("Network.newNetworkFunction")
local hardwareButtonHandler = require("ProjectObject.HardwareButtonHandler")

local fbAppID = "904553419585105"  --replace with your Facebook App ID
local boolean_isNotice = false
local returnGroup = {}

-- for login
local username
local password
local sessionToken

local tabbar


local linkListener
local popupGroup
local popup_textField_username
local popup_textField_password
local popupVaule
local popup_linkAccountName
local popup_linkAccountPassword
local popup_tempLastTryAccountName = nil

local facebookLogin_responseInfo
local facebookLoginData

local isFromLoginPage

local goToRegSceneOption =
{
    effect = "fade",
    time = 400,
}


local function responseCodeAlertBox(code)
	newNetworkFunction.stopShowingSessionExpiredAlert()
	if(code==14)then -- email still not verified
		-- print("Not Verified")
		native.showAlert(localization.getLocalization("loginError_errorTitle"),
							localization.getLocalization("loginError_emailNoVerified"),
							{localization.getLocalization("yes"), localization.getLocalization("no")},
							function(event)
								if (event.index == 1) then
									if (username) then
										newNetworkFunction.resendVerificationEmail(username)
									end
									native.showAlert(localization.getLocalization("resendVerificationEmail_Title"),
														localization.getLocalization("resendVerificationEmail"),
														{localization.getLocalization("ok")})
								end
								username = nil
							end)
	elseif(code==3)then -- missing some required field(s)
		native.showAlert(localization.getLocalization("loginError_errorTitle"),localization.getLocalization("loginError_wrongData"),{localization.getLocalization("ok")})
	else
		native.showAlert(localization.getLocalization("networkError_errorTitle"),localization.getLocalization("networkError_networkError"),{localization.getLocalization("ok")})
	end
end




local function getUserDataListener(event)
	native.setActivityIndicator( false )
	if (event.isError) then
		native.showAlert(localization.getLocalization("networkError_errorTitle"),localization.getLocalization("networkError_networkError"),{localization.getLocalization("ok")})
		storyboard.gotoScene( "Scene.LoginPageScene")
	else
		local responseInfo = json.decode(event[1].response)

		if (responseInfo.code) then-- Login fail
			responseCodeAlertBox(tonumber(responseInfo.code))
			storyboard.gotoScene( "Scene.LoginPageScene")
		else
			if (isFromLoginPage) then
				saveData.delete(global.addFriendListSavePath)--delete addFriendList
				saveData.delete(global.isOrigDesignPath)--delete isOrigDesignPath
				global.isOriginalDesign = false
				isFromLoginPage = false
			end

			responseInfo.password = password

			responseInfo.sessionToken = newNetworkFunction.getSessionToken()

			newNetworkFunction.registerPushDevice()

			saveData.save(global.userDataPath,responseInfo)

			if(boolean_isNotice)then --stop to go vorum scene if this is notification
				storyboard.gotoScene( "Scene.NoticeTabScene" )
			else
				local passData={params=responseInfo}
				storyboard.gotoScene( "Scene.VorumTabScene",passData )
				tabbar = headTabFnc.getTabbar()
				tabbar:setSelected(3)
			end
		end
	end
end


function returnGroup.login(userData,input_boolean_isNotice,isComeFromLoginPage)

	native.setActivityIndicator( true )

	boolean_isNotice = input_boolean_isNotice or false

	isFromLoginPage = isComeFromLoginPage or false
	
	username = userData.username
	password = userData.password

	newNetworkFunction.updateLoginData(userData)
	newNetworkFunction.clearFbLoginData()

	newNetworkFunction.getUserData(getUserDataListener)

end




------------------- below facebook login

local function popupKeyEvent(event)
	if event.phase == "up" and event.keyName == "back" then
		popup.hide()
	end
	return true
end

local function popup_displayListener()
	popup_textField_username:setKeyboardFocus()

	hardwareButtonHandler.activate()
	hardwareButtonHandler.addCallback(popupKeyEvent, true)
end

local function popup_hideListener()
	hardwareButtonHandler.removeCallback(popupKeyEvent)
end

local function popupLinkDoneCallBackFnc(event)

	popup_linkAccountName = popup_textField_username.text
	popup_linkAccountPassword = popup_textField_password.text
	
	popup_tempLastTryAccountName = popup_linkAccountName
	
	linkListener(popup_linkAccountName,popup_linkAccountPassword)
end

local function popupLinkTextField()

	popupGroup = popup.getPopupGroup()
	
	popup_textField_username = coronaTextField.new(  -250, -130, 500, 80,popupGroup, "displayGroup")
	popup_textField_username.hasBackground = false
	popup_textField_username:setFont("Helvetica",32)
	popup_textField_username:setTopPadding(200)
	popup_textField_username:setPlaceHolderText(localization.getLocalization("login_username_textField_placeholder"))
	
	if(popup_tempLastTryAccountName)then
		popup_textField_username.text = popup_tempLastTryAccountName
	end
	
	popup_textField_password = coronaTextField.new(  -250, -30, 500, 80,popupGroup, "displayGroup")
	popup_textField_password.hasBackground = false
	popup_textField_password:setFont("Helvetica",32)
	popup_textField_password:setTopPadding(200)
	popup_textField_password.isSecure = true
	popup_textField_password:setPlaceHolderText(localization.getLocalization("login_password_textField_placeholder"))
	
	popup_textField_username:nextTextFieldFocus(popup_textField_password, nil)
	
	popupVaule = 
	{
		--necessary
		popupObj = {popup_textField_username,popup_textField_password},
		popupObjFncType = {},
		popupObjFnc = {},
		popupBgImagePath = "Image/Popup/linkAccountPrompt.png",
		popupBgColor = {187/255, 235/255, 1 },
		buttonColor={78/255, 184/255, 229/255},	
		doneButtonText = localization.getLocalization("ok"),
		cancelButtonText = localization.getLocalization("cancel"),
		doneButtonImagePath = "Image/Popup/linkAccountPromptRightBtn.png",
		cancelButtonImagePath = "Image/Popup/linkAccountPromptLeftBtn.png",
		doneButtonCallBackFnc = popupLinkDoneCallBackFnc,
		touchBgNotCancel = true,
		displayListener = popup_displayListener,
		hideListener = popup_hideListener,
	}
	popup.popup(popupVaule)

end


local function facebookLogin_getUserDataListener(event)

	native.setActivityIndicator( false )
	if (event.isError) then
		native.showAlert(localization.getLocalization("networkError_errorTitle"),localization.getLocalization("networkError_networkError"),{localization.getLocalization("ok")})
		storyboard.gotoScene( "Scene.LoginPageScene")
	else
		local responseInfo = json.decode(event[1].response)

		if (responseInfo.code) then-- Login fail
			responseCodeAlertBox(tonumber(responseInfo.code))
			storyboard.gotoScene( "Scene.LoginPageScene")
		else
			if (isFromLoginPage) then
				saveData.delete(global.addFriendListSavePath)--delete addFriendList
				saveData.delete(global.isOrigDesignPath)--delete isOrigDesignPath
				global.isOriginalDesign = false
				isFromLoginPage = false
			end

			newNetworkFunction.updateFbLoginData(facebookLoginData)

			newNetworkFunction.registerPushDevice()

			if (facebookLogin_responseInfo) then
				for k,v in pairs(facebookLogin_responseInfo) do
					responseInfo[k] = v
				end
			end

			saveData.save(global.userDataPath,responseInfo)
			
			if(boolean_isNotice)then --stop to go vorum scene if this is notification
				storyboard.gotoScene( "Scene.NoticeTabScene" )
			else
				local passData={params=responseInfo}
				storyboard.gotoScene( "Scene.VorumTabScene",passData )
				tabbar = headTabFnc.getTabbar()
				tabbar:setSelected(3)
			end
		end
	end

end

local function facebookLoginListener(event)
	
	if (event.isError) then
		-- Error
		-- print("-----------")
		-- print("Error")
		-- print("-----------")
	elseif (event.isLoginError) then
		-- Login error
		-- print("-----------")
		-- print("Login Error")
		-- print("-----------")
	else
		if (event.isLoginSuccess) then
			-- print("-----------")
			-- print("userId:", tostring(event.userId))
			-- print("Token:", tostring(event.sessionToken))
			-- print("Facebook Token", tostring(event.fbToken))
			-- print("-----------")
			-- print("data",json.encode(event))

			global.isFacebookLogin = true

			facebookLogin_responseInfo = json.decode(event[1].response)



			facebookLoginData = {}

			facebookLoginData.fbToken = tostring(event.fbToken)

			facebookLoginData.sessionToken = tostring(event.sessionToken)

			-------------------------------------------------------------

			facebookLogin_responseInfo.user_id = tostring(event.userId)

			facebookLogin_responseInfo.fbToken = facebookLoginData.fbToken

			facebookLogin_responseInfo.sessionToken = facebookLoginData.sessionToken

			newNetworkFunction.getUserData(facebookLogin_getUserDataListener)

		elseif (event.isCreateNewAcc) then
			-- print("-----------")
			-- print("create new ac", tostring(event.facebookId), tostring(event.facebookToken))
			-- print("-----------")
			local goToRegSceneOpt = {}
			goToRegSceneOpt.effect = goToRegSceneOption.effect
			goToRegSceneOpt.time = goToRegSceneOption.time
			goToRegSceneOpt.params = {
										fb = {id = event.facebookId, token = event.facebookToken},
										userDetail = event.userDetail,
									}
			storyboard.gotoScene( "Scene.RegisterPageScene" ,goToRegSceneOpt)
		elseif (event.isLinkAccount) then
			-- print("-----------")
			-- print("link acc")
			linkListener = event.linkAccountListener
			-- print("-----------")
			popup_tempLastTryAccountName = event.email
			popupLinkTextField()
		elseif (event.linkError) then
			-- print("-----------")
			-- print("link acc error")
			-- print("-----------")
		else
			-- print("-----------")
			-- print("Unknown")
			-- print("-----------")
		end
	end
	
end

function returnGroup.FBlogin(input_boolean_isNotice,isComeFromLoginPage)
	boolean_isNotice = input_boolean_isNotice or false
	isFromLoginPage = isComeFromLoginPage or false
	facebookLogin.login(facebookLoginListener)
end

function returnGroup.updateFBData(fbData,input_boolean_isNotice,isComeFromLoginPage)

	native.setActivityIndicator( true )

	boolean_isNotice = input_boolean_isNotice or false
	
	isFromLoginPage = isComeFromLoginPage or false

	newNetworkFunction.updateFbLoginData(fbData)

	facebookLoginData = fbData

	facebookLogin_responseInfo = {
										fb_id = fbData.fb_id,
										fbToken = fbData.fbToken,
										sessionToken = fbData.sessionToken,
									}

	global.isFacebookLogin = true

	newNetworkFunction.getUserData(facebookLogin_getUserDataListener)

end


return returnGroup

