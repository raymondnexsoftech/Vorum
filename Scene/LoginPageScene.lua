---------------------------------------------------------------
-- VorumTabScene.lua
--
-- Scene for Vorum Tab
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
--local resDir = (...):match("(.-)[^%.]+$")

-- Local Constant Setting
local LOCAL_SETTINGS = {
						NAME = "LoginPage",			-- Scene name to show in console
						RES_DIR = "",					-- Common resource directory for scene
						DOC_DIR = "",					-- Common document directory for scene
						}

---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------
local storyboard = require ( "storyboard" )
local widget = require ( "widget" )
require ( "SystemUtility.Debug" )
local coronaTextField = require("Module.CoronaTextField")
local localization = require("Localization.Localization")
-- local networkFunction = require("Network.NetworkFunction")
local saveData = require( "SaveData.SaveData" )
local json = require( "json" )
local facebook = require( "facebook" )
local global = require( "GlobalVar.global" )
local loginFnc = require("Module.loginFnc")
local stringUtility = require( "SystemUtility.StringUtility" )
local fbAppID = "904553419585105"  --replace with your Facebook App ID
local popup = require("Module.popup")
local buttonModule = require("Module.buttonModule")
local newNetworkFunction = require("Network.newNetworkFunction")
local hardwareButtonHandler = require("ProjectObject.HardwareButtonHandler")
---------------------------------------------------------------
-- Constants
---------------------------------------------------------------

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
--Create a storyboard scene for this module
local scene = storyboard.newScene()
local scrollView
local textField_username
local textField_password
local loginData

--facebook login
local facebookLoginId
local facebook_accessToken

local goToRegSceneOption =
{
    effect = "fade",
    time = 400,
}
local forgetPasswordPopupFnc
local forgetPassword_popupGroup
local forgetPassword_popup_textField_username
local forgetPassword_popupVaule
local forgetPassword_popup_textField_username_tempValue
---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
-- Function for back button
local function onBackButtonPressed()
end



local function loginFacebook(event)
	local phase = event.phase

    if( phase == "began" ) then
	elseif ( phase == "moved" ) then
        local dy = math.abs( ( event.y - event.yStart ) )
        -- If the touch on the button has moved more than 10 pixels,
        -- pass focus back to the scroll view so it can continue scrolling
        if ( dy > 10 ) then
            scrollView:takeFocus( event )
        end
    elseif ( phase == "ended" or phase == "cancelled" ) then
		loginFnc.FBlogin(false,true)
	end
    return true
end

local function forgetPasswordNoEmailListener(event)
	 if event.action == "clicked" then
        local i = event.index
        if i == 1 then
          forgetPasswordPopupFnc()
        elseif i == 2 then
          forgetPassword_popup_textField_username_tempValue = ""
        end
    end
end

local function forgetPasswordListener(event)
	native.setActivityIndicator( false )
	local response = json.decode(event[1].response)
	if(response.code)then
		response.code = tonumber( response.code )
		if(response.code==9)then
			native.showAlert( localization.getLocalization("forgetPasswordSuccessTitle"), localization.getLocalization("forgetPasswordSuccessDesc") ,{localization.getLocalization("ok") })
		elseif(response.code==10)then
			native.showAlert( localization.getLocalization("forgetPasswordErrorTitle_noEmail"), localization.getLocalization("forgetPasswordErrorDesc_noEmail") ,{localization.getLocalization("ok"),localization.getLocalization("cancel") },forgetPasswordNoEmailListener)
		end
	end
end
local function forgetPasswordPopupDoneFnc()
	native.setActivityIndicator( true )
	forgetPassword_popup_textField_username_tempValue = forgetPassword_popup_textField_username.text
	newNetworkFunction.forgetPassword(forgetPassword_popup_textField_username.text, forgetPasswordListener)
end

local function forgetPasswordPopupCheckingFnc()
	local atPos = string.find(forgetPassword_popup_textField_username.text,"@",1,true)
	if(not atPos)then
		native.showAlert(localization.getLocalization("inputCheck_emailNoAtTitle"),localization.getLocalization("inputCheck_emailNoAt"),{localization.getLocalization("ok")})
		return false
	end
end

local function popupKeyEvent(event)
	if event.phase == "up" and event.keyName == "back" then
		popup.hide()
	end
	return true
end

local function popup_displayListener()
	forgetPassword_popup_textField_username:setKeyboardFocus()
	hardwareButtonHandler.addCallback(popupKeyEvent, true)
end

local function popup_hideListener()
	hardwareButtonHandler.removeCallback(popupKeyEvent)
end

forgetPasswordPopupFnc = function ()
	
	forgetPassword_popupGroup = popup.getPopupGroup()
	
	forgetPassword_popup_textField_username = coronaTextField:new(  -250, -80, 500, 80,forgetPassword_popupGroup, "displayGroup")
	forgetPassword_popup_textField_username.hasBackground = false
	forgetPassword_popup_textField_username:setFont("Helvetica",32)
	forgetPassword_popup_textField_username:setTopPadding(200)
	forgetPassword_popup_textField_username:setPlaceHolderText(localization.getLocalization("login_username_textField_placeholder"))
	-- forgetPassword_popup_textField_username.text = textField_username.text
	forgetPassword_popup_textField_username.text = forgetPassword_popup_textField_username_tempValue
	
	
	forgetPassword_popupVaule = 
	{
		--necessary
		popupObj = {forgetPassword_popup_textField_username},
		popupObjFncType = {},
		popupObjFnc = {},
		popupBgImagePath = "Image/Popup/forgetPasswordPrompt.png",
		popupBgColor = {187/255, 235/255, 1 },
		buttonColor={78/255, 184/255, 229/255},	
		doneButtonText = localization.getLocalization("ok"),
		cancelButtonText = localization.getLocalization("cancel"),
		doneButtonImagePath = "Image/Popup/linkAccountPromptRightBtn.png",
		cancelButtonImagePath = "Image/Popup/linkAccountPromptLeftBtn.png",
		doneButtonCheckingFnc = forgetPasswordPopupCheckingFnc,
		doneButtonCallBackFnc = forgetPasswordPopupDoneFnc,
		touchBgNotCancel = true,
		displayListener = popup_displayListener,
		hideListener = popup_hideListener,
	}
	popup.popup(forgetPassword_popupVaule)
	
end

local function forgetPasswordFnc(event)
	local phase = event.phase

    if( phase == "began" ) then
	elseif ( phase == "moved" ) then
        local dy = math.abs( ( event.y - event.yStart ) )
        -- If the touch on the button has moved more than 10 pixels,
        -- pass focus back to the scroll view so it can continue scrolling
        if ( dy > 10 ) then
            scrollView:takeFocus( event )
        end
    elseif ( phase == "ended" or phase == "cancelled" ) then
    	forgetPassword_popup_textField_username_tempValue = textField_username.text
		forgetPasswordPopupFnc()
		
	end
    return true
end

local function signIn(event)
	local phase = event.phase

    if( phase == "began" ) then
	elseif ( phase == "moved" ) then
        local dy = math.abs( ( event.y - event.yStart ) )
        -- If the touch on the button has moved more than 10 pixels,
        -- pass focus back to the scroll view so it can continue scrolling
        if ( dy > 10 ) then
            scrollView:takeFocus( event )
        end
    elseif ( phase == "ended" or phase == "cancelled" ) then
		
		if(textField_username.text=="")then
			native.showAlert(localization.getLocalization("loginError_errorTitle"),localization.getLocalization("loginError_emptyUsername"),{localization.getLocalization("ok")})
			return false
		end
		
		if(textField_password.text=="")then
			native.showAlert(localization.getLocalization("loginError_errorTitle"),localization.getLocalization("loginError_emptyPassword"),{localization.getLocalization("ok")})
			return false
		end
		
		local atPos = string.find(textField_username.text,"@",1,true)
		if(not atPos)then
			native.showAlert(localization.getLocalization("loginError_errorTitle"),localization.getLocalization("loginError_emailNoAt"),{localization.getLocalization("ok")})
			return false
		end

		loginData = {}
		loginData.username = string.lower(textField_username.text)
		loginData.password = textField_password.text
		
		loginFnc.login(loginData,false,true)
	    
	end
    return true
end

local function createAccount(event)
	local phase = event.phase

    if( phase == "began" ) then
	elseif ( phase == "moved" ) then
        local dy = math.abs( ( event.y - event.yStart ) )
        if ( dy > 10 ) then
            scrollView:takeFocus( event )
        end
    elseif ( phase == "ended" or phase == "cancelled" ) then
		storyboard.gotoScene( "Scene.RegisterPageScene" ,goToRegSceneOption)
	end
    return true
end

local function exitFnc(event)
	os.exit()
end

-- Create the scene
function scene:createScene( event )
	SceneGroup = self.view
	local group_login = display.newGroup()
	debugLog( "Creating " .. LOCAL_SETTINGS.NAME .. " Scene")

	display.setStatusBar( display.HiddenStatusBar )
	display.setDefault( "background", 187/255, 235/255, 1 )	

	scrollView = widget.newScrollView
	{
		top = 0,
		left = 0,
		bottomPadding = 40,
		width = display.contentWidth,
		height = display.contentHeight,
		backgroundColor = { 187/255, 235/255, 1 },
		horizontalScrollDisabled = true,
		verticalScrollDisabled = false,
		hideScrollBar = true,
		listener = scrollListener
	}
	
	local image_logo = display.newImage( "Image/LoginPage/logo.png")
	image_logo.x = display.contentCenterX
	image_logo.y = 180
	image_logo.anchorX=0.5
	image_logo.anchorY=0
	group_login:insert(image_logo)
	
	local exit_button = widget.newButton
	{
		id = "exit_button",
		defaultFile = "Image/LoginPage/exit.png",
		overFile = "Image/LoginPage/exit.png",
		onRelease=exitFnc,
	}
	exit_button.x = 610
	exit_button.y = 30
	exit_button.anchorX=1
	exit_button.anchorY=0
	group_login:insert(exit_button)
	
	local facebookLogin_button = widget.newButton
	{
		onEvent = loginFacebook,
		
		shape = "roundedRect",
		fillColor = { default={ 92/255, 119/255, 180/255}, over={ 92/255, 119/255, 180/255 } },
		width = 488,
		height = 94,
		cornerRadius = 10,
		strokeColor = { default={ 0, 0, 0 }, over={ 0, 0, 0 } },
		strokeWidth =0
	}
	facebookLogin_button.x = display.contentCenterX
	facebookLogin_button.y = 415
	facebookLogin_button.anchorX=0.5
	facebookLogin_button.anchorY=0
	group_login:insert(facebookLogin_button)
	
	local facebookLogin_buttonText = {
		text = localization.getLocalization("login_loginWithFacebook"), 
		x = facebookLogin_button.x+28,
		y = facebookLogin_button.y+facebookLogin_button.height/2,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=36
	}
	facebookLogin_buttonText = display.newText(facebookLogin_buttonText)
	facebookLogin_buttonText.anchorX = 0.5
	facebookLogin_buttonText.anchorY = 0.5
	group_login:insert(facebookLogin_buttonText)
	
	local image_facebookIcon = display.newImage( "Image/LoginPage/facebook.png")
	image_facebookIcon.x = 25+facebookLogin_button.x-(facebookLogin_button.anchorX*facebookLogin_button.width)
	image_facebookIcon.y = facebookLogin_button.y + 17
	image_facebookIcon.anchorX=0
	image_facebookIcon.anchorY=0
	group_login:insert(image_facebookIcon)
	
	---------------text field begin
	background_textField_width = 488
	background_textField_height = 154
	
	local background_textField = display.newRoundedRect( display.contentCenterX, 535, background_textField_width, background_textField_height, 10 )
	background_textField:setFillColor( 1,1,1 )
	background_textField:setStrokeColor(  172/255,  172/255,  172/255 )
	background_textField.strokeWidth = 2
	background_textField.anchorX=0.5
	background_textField.anchorY=0
	group_login:insert(background_textField)
	-----------------
	
	local background_textField_beginX = background_textField.x-(background_textField.anchorX*background_textField.width)
	local background_textField_endX = background_textField_beginX+background_textField.width
	local background_textField_centerY = (background_textField.y+background_textField.height/2)
	
	local background_underline = display.newLine(background_textField_beginX,background_textField_centerY,background_textField_endX,background_textField_centerY)
	background_underline:setStrokeColor( 204/255, 204/255, 204/255 )
	background_underline.strokeWidth = 2
	group_login:insert(background_underline)
	
	-----------------
	
	local username_icon = display.newImage("Image/LoginPage/username.png")
	username_icon.x = background_textField_beginX + 34
	username_icon.y = background_textField.y + 18
	username_icon.anchorX=0
	username_icon.anchorY=0
	group_login:insert(username_icon)
	
	local password_icon = display.newImage("Image/LoginPage/password.png")
	password_icon.x = background_textField_beginX + 34
	password_icon.y = background_textField_centerY + 18
	password_icon.anchorX=0
	password_icon.anchorY=0
	group_login:insert(password_icon)
	
	-----------------
	local textField_x = background_textField_beginX+100
	local textField_width = background_textField_width-100-3
	local textField_height = background_textField_height/2-1
	
	textField_username = coronaTextField:new( textField_x, background_textField.y+1, textField_width, textField_height,group_login, "displayGroup" )
	textField_username:setFont("Helvetica",32)
	textField_username.anchorX=0
	textField_username.anchorY=0
	textField_username:setTopPadding(200)
	textField_username:setPlaceHolderText(localization.getLocalization("login_username_textField_placeholder"))
	textField_username.hasBackground = false
	-- textField_username.isFontSizeScaled = true
	group_login:insert(textField_username)
	
	local textField_username_total_height = textField_username.y+textField_username.height
	textField_password = coronaTextField:new( textField_x, textField_username_total_height, textField_width, textField_height,group_login, "displayGroup" )
	textField_password:setFont("Helvetica",32)
	textField_password.anchorX=0
	textField_password.anchorY=0
	textField_password:setTopPadding(200)
	textField_password:setPlaceHolderText(localization.getLocalization("login_password_textField_placeholder"))
	textField_password.hasBackground = false
	textField_password.isSecure = true
	-- textField_password.isFontSizeScaled = true
	group_login:insert(textField_password)
	--set next field
	textField_username:nextTextFieldFocus(textField_password, nil)
	
	background_underline:toFront()--display the line
	---------------text field end

	local text_forgetPassword =
	{
		text = localization.getLocalization("login_forgetPassword"), 
		x = display.contentCenterX,
		y = background_textField.y+background_textField.height+27,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=30,
	}

	text_forgetPassword = display.newText(text_forgetPassword);
	text_forgetPassword:setFillColor( 78/255, 184/255, 229/255 )
	text_forgetPassword.anchorX=0.5
	text_forgetPassword.anchorY=0
	text_forgetPassword:addEventListener("touch",forgetPasswordFnc)
	group_login:insert(text_forgetPassword)
	
	local beginX_text_forgetPassword_width = text_forgetPassword.x-(text_forgetPassword.width*text_forgetPassword.anchorX)
	local endX_text_forgetPassword_width = beginX_text_forgetPassword_width + text_forgetPassword.width

	local total_text_forgetPassword_height = text_forgetPassword.y+text_forgetPassword.height
	
	local underline_forgetPassword = display.newLine( beginX_text_forgetPassword_width, total_text_forgetPassword_height, endX_text_forgetPassword_width, total_text_forgetPassword_height )
	underline_forgetPassword:setStrokeColor( 78/255, 184/255, 229/255 )
	underline_forgetPassword.strokeWidth=2
	group_login:insert(underline_forgetPassword)

	local signIn_button = buttonModule.newButton
	{
		label = localization.getLocalization("login_signIn"),
		labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
		font = "Helvetica",
		fontSize = 36,
		onEvent = signIn,
		
		shape = "roundedRect",
		fillColor = { default={ 78/255, 184/255, 229/255}, over={ 78/255, 184/255, 229/255 } },
		width = 316,
		height = 78,
		cornerRadius = 10,
		strokeColor = { default={ 0, 0, 0 }, over={ 0, 0, 0 } },
		strokeWidth =0
	}
	signIn_button.x = display.contentCenterX
	signIn_button.y = text_forgetPassword.y+text_forgetPassword.height+18
	signIn_button.anchorX=0.5
	signIn_button.anchorY=0
	group_login:insert(signIn_button)
	

	local createAccount_button = buttonModule.newButton
	{
		label = localization.getLocalization("login_createAccount"),
		labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
		font = "Helvetica",
		fontSize = 36,
		onEvent = createAccount,
		
		shape = "roundedRect",
		fillColor = { default={ 251/255, 175/255, 93/255}, over={ 251/255, 175/255, 93/255 } },
		width = 316,
		height = 78,
		cornerRadius = 10,
		strokeColor = { default={ 0, 0, 0 }, over={ 0, 0, 0 } },
		strokeWidth =0
	}
	createAccount_button.x = display.contentCenterX
	createAccount_button.y = signIn_button.y+signIn_button.height+42
	createAccount_button.anchorX=0.5
	createAccount_button.anchorY=0
	group_login:insert(createAccount_button)
	
	
	if(group_login.height<=display.contentHeight)then
		scrollView:setIsLocked( true, "vertical" )
	end
	
	scrollView:insert(group_login)

	SceneGroup:insert(scrollView)
	
end

local function onKeyEvent( event )
	if event.phase == "up" and event.keyName == "back" then
		onBackButtonPressed()
	end
	return true
end

local function onSceneTransitionKeyEvent( event )
	if event.phase == "up" and event.keyName == "back" then
	end
	return true
end

function scene:didExitScene( event )
	debugLog( "Did Exit " .. LOCAL_SETTINGS.NAME .. " Scene")

	-- Place the code below
end


function scene:willEnterScene( event )
	debugLog( "Will Enter " .. LOCAL_SETTINGS.NAME .. " Scene")

	-- adding key event for scene transition
	Runtime:addEventListener( "key", onSceneTransitionKeyEvent )
	-- Place the code below
end
function scene:enterScene( event )
	debugLog( "Entering " .. LOCAL_SETTINGS.NAME .. " Scene")
	-- removing key event for scene transition
	Runtime:removeEventListener( "key", onSceneTransitionKeyEvent )
	-- adding check system key event
	-- Runtime:addEventListener( "key", onKeyEvent )
	hardwareButtonHandler.clearAllCallback()
	hardwareButtonHandler.activate()
	hardwareButtonHandler.addCallback(onKeyEvent, true)
	-- remove previous scene's view
--	storyboard.purgeScene( lastScene )
	storyboard.purgeAll()

	-- Place the code below
	global.isFacebookLogin = false
end

-- Called when scene is about to move offscreen:
function scene:exitScene()
	debugLog( "Exiting " .. LOCAL_SETTINGS.NAME .. " Scene")

	-- removing check system key event
	-- Runtime:removeEventListener( "key", onKeyEvent )
	hardwareButtonHandler.removeCallback(onKeyEvent)
	hardwareButtonHandler.deactivate()
	hardwareButtonHandler.clearAllCallback()
	-- Place the code below
end

-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	debugLog( "Destroying " .. LOCAL_SETTINGS.NAME .. " Scene" )

	-- Place the code below
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "willEnterScene" event is dispatched before scene transition begins
scene:addEventListener( "willEnterScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )
-- "didExitScene" event is dispatched after scene has finished transitioning out
scene:addEventListener( "didExitScene", scene )
-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )


---------------------------------------------------------------------------------

return scene