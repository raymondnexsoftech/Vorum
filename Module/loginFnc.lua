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
require ( "DebugUtility.Debug" )
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

local data
local responseInfo
local tabbar

local username
local password

local linkListener
local popupGroup
local popup_textField_username
local popup_textField_password
local popupVaule
local popup_linkAccountName
local popup_linkAccountPassword
local popup_tempLastTryAccountName = nil

local goToRegSceneOption =
{
    effect = "fade",
    time = 400,
}


local function responseCodeAlertBox(code)
	if(code==14)then -- email still not verified
		print("Not Verified")
		native.showAlert(localization.getLocalization("loginError_errorTitle"),
							localization.getLocalization("loginError_emailNoVerified"),
							{localization.getLocalization("yes"), localization.getLocalization("no")},
							function(event)
								if (event.index == 1) then
									newNetworkFunction.resendVerificationEmail(username)
									native.showAlert(localization.getLocalization("resendVerificationEmail"),
														localization.getLocalization("resendVerificationEmail"),
														{localization.getLocalization("ok")})
								end
							end)
	elseif(code==3)then -- missing some required field(s)
		native.showAlert(localization.getLocalization("loginError_errorTitle"),localization.getLocalization("loginError_wrongData"),{localization.getLocalization("ok")})
	else
		native.showAlert(localization.getLocalization("networkError_errorTitle"),localization.getLocalization("networkError_networkError"),{localization.getLocalization("ok")})
	end
end


local tokennn
local function getUserDataListener(event)
	native.setActivityIndicator( false )
	if (event.isError) then
		native.showAlert(localization.getLocalization("networkError_errorTitle"),localization.getLocalization("networkError_networkError"),{localization.getLocalization("ok")})
		storyboard.gotoScene( "Scene.LoginPageScene")
	else
		responseInfo = json.decode(event[1].response)
	print(event[1].response)
		if (responseInfo.code) then-- Login fail
			responseCodeAlertBox(tonumber(responseInfo.code))
			storyboard.gotoScene( "Scene.LoginPageScene")
		else
			responseInfo.session = sessionToken
			responseInfo.password = password
			print("login data",json.encode(responseInfo))
			saveData.save(global.userDataPath,responseInfo)
			if(boolean_isNotice)then --stop to go vorum scene if this is notification
				
			else
				data={params=responseInfo}
				storyboard.gotoScene( "Scene.VorumTabScene",data )
				tabbar = headTabFnc.getTabbar()
				tabbar:setSelected(3)
			end
		end
	end
end

local function loginListener(event)
	if (event.isError) then
		native.setActivityIndicator( false )
		native.showAlert(localization.getLocalization("networkError_errorTitle"),localization.getLocalization("networkError_networkError"),{localization.getLocalization("ok")})
		storyboard.gotoScene( "Scene.LoginPageScene")
	else
		print("login response",event[1].response)
		responseInfo = json.decode(event[1].response)
		if (responseInfo.code) then-- Login fail
			native.setActivityIndicator( false )
			responseCodeAlertBox(tonumber(responseInfo.code))
			storyboard.gotoScene( "Scene.LoginPageScene")
		else--Login Success
			sessionToken = responseInfo.session
			newNetworkFunction.getUserData(getUserDataListener)
		end
	end
	
end

function returnGroup.login(input_username,input_password,input_boolean_isNotice)

	username = input_username
	password = input_password

	native.setActivityIndicator( true )
	boolean_isNotice = input_boolean_isNotice or false
	
	local loginData = {}
	loginData.email = username
	loginData.password = password
	
	newNetworkFunction.login(loginData,loginListener)
	--parse
	-- networkFunction.login(username,password,loginListener)
end
------------------- below facebook login


local function popupKeyEvent(event)
	if event.phase == "up" and event.keyName == "back" then
		popup.hide()
	end
	return true
end

local function popup_displayListener()
	forgetPassword_popup_textField_username:setKeyboardFocus()

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
	
	popup_textField_username = coronaTextField:new(  -250, -130, 500, 80,popupGroup, "displayGroup")
	popup_textField_username.hasBackground = false
	popup_textField_username:setFont("Helvetica",32)
	popup_textField_username:setTopPadding(200)
	popup_textField_username:setPlaceHolderText(localization.getLocalization("login_username_textField_placeholder"))
	
	if(popup_tempLastTryAccountName)then
		popup_textField_username.text = popup_tempLastTryAccountName
	end
	
	popup_textField_password = coronaTextField:new(  -250, -30, 500, 80,popupGroup, "displayGroup")
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

local function facebookLoginListener(event)
	print("fb",json.encode(event))
	if (event.isError) then
		-- Error
		print("-----------")
		print("Error")
		print("-----------")
	elseif (event.isLoginError) then
		-- Login error
		print("-----------")
		print("Login Error")
		print("-----------")
	else
		if (event.isLoginSuccess) then
			print("-----------")
			print("userId:", tostring(event.userId))
			print("Token:", tostring(event.sessionToken))
			print("-----------")
			print("data",json.encode(event))
			responseInfo = json.decode(event[1].response)
			saveData.save(global.userDataPath,responseInfo)
			newNetworkFunction.registerPushDevice()
			if(boolean_isNotice)then --stop to go vorum scene if this is notification
			else
				data={params=responseInfo}
				storyboard.gotoScene( "Scene.VorumTabScene",data )
				tabbar = headTabFnc.getTabbar()
				tabbar:setSelected(3)
			end
		elseif (event.isCreateNewAcc) then
			print("-----------")
			print("create new ac", tostring(event.facebookId), tostring(event.facebookToken))
			print("-----------")
			storyboard.gotoScene( "Scene.RegisterPageScene" ,goToRegSceneOption)
		elseif (event.isLinkAccount) then
			print("-----------")
			print("link acc")
			linkListener = event.linkAccountListener
			print("-----------")
			popupLinkTextField()
		elseif (event.linkError) then
			print("-----------")
			print("link acc error")
			print("-----------")
		else
			print("-----------")
			print("Unknown")
			print("-----------")
		end
	end
	
end

function returnGroup.FBlogin(input_boolean_isNotice)
	boolean_isNotice = input_boolean_isNotice or false
	facebookLogin.login(facebookLoginListener)
end

return returnGroup

