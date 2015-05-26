---------------------------------------------------------------
-- VorumTabScene.lua
--
-- Scene for Vorum Tab
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
--local resDir = (...):match("(.-)[^%.]+$")

-- Local Constant Setting
local LOCAL_SETTINGS = {
						NAME = "RegisterPage",			-- Scene name to show in console
						RES_DIR = "",					-- Common resource directory for scene
						DOC_DIR = "",					-- Common document directory for scene
						}

---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------
local storyboard = require ( "storyboard" )
local widget = require ( "widget" )
local coronaTextField = require("Module.CoronaTextField")
require ( "DebugUtility.Debug" )
local localization = require("Localization.Localization")
local addPhotoFnc = require("Function.addPhoto")
local birthSelectFnc = require("Function.birthSelectFnc")
local networkFunction = require("Network.NetworkFunction")
local geolocationUtility = require("SystemUtility.GeolocationUtility")
local saveData = require( "SaveData.SaveData" )
local global = require( "GlobalVar.global" )
local stringUtility = require( "SystemUtility.StringUtility" )
local json = require( "json" )
local optionModule = require("Module.Option")
local newNetworkFnc = require("Network.newNetworkFunction")
local buttonModule = require("Module.buttonModule")
local hardwareButtonHandler = require("ProjectObject.HardwareButtonHandler")
---------------------------------------------------------------
-- Constants
---------------------------------------------------------------

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
local displayGroup
local scrollView


--Create a storyboard scene for this module
local scene = storyboard.newScene()
-- checkbox
local agree_checkbox = false
local agree_checkbox_background2

--add photo
local registerPhoto

--birthday
local year = 1970
local month = "March"
local day = 1
local text_birthday
local booldean_birthHadSelected = false
local month_array = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }
--textField
-- local textField_username
local email_textField
local textField_password
local textField_confirmPassword
local profile_textField_name
local userData = {}
local profilePicPath
local uploadedPic

local genderOption

local facebookData

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
-- Function for back button
local function onBackButtonPressed()
	storyboard.gotoScene( "Scene.LoginPageScene",goToLoginSceneOption)
end
local function textListener( event )
    if ( event.phase == "began" ) then
        -- user begins editing defaultField
        -- print( event.text )

    elseif ( event.phase == "ended" or event.phase == "submitted" ) then
        -- do something with defaultField text
    elseif ( event.phase == "editing" ) then

        event.target.text = stringUtility.trimStringSpace(event.target.text)

		local emojiTrimmedString, isEmojiDetected = stringUtility.trimEmoji(event.target.text)
		if (isEmojiDetected) then
			event.target.text = emojiTrimmedString
		end
    end
end


local function birthdayCallBackUpdate(data_year,data_month,data_day)
	year = tonumber(data_year)
	month = data_month
	day = tonumber(data_day)
	text_birthday.text = day.."/"..month.."/"..year
	text_birthday:setFillColor(0,0,0)
end
local function birthdaySelection(event)
	if(event.phase=="ended"or event.phase=="cancelled")then
		booldean_birthHadSelected = true
		birthSelectFnc.birthdaySelection(event,year,month,day,birthdayCallBackUpdate,scrollView)
	end

	return true
end

local function exitFnc(event)
	if ( event.phase == "moved" ) then
		local dy = math.abs( ( event.y - event.yStart ) )
		if ( dy > 10 ) then
			scrollView:takeFocus( event )
		end
	elseif(event.phase=="ended"or event.phase=="cancelled")then
		storyboard.gotoScene( "Scene.LoginPageScene",goToLoginSceneOption)
	end
	return true
end

local function addPhoto(event)
	if ( event.phase == "moved" ) then
		local dy = math.abs( ( event.y - event.yStart ) )
		if ( dy > 10 ) then
			scrollView:takeFocus( event )
		end
	elseif(event.phase=="ended" or event.phase=="cancelled")then
		addPhotoFnc.addPhoto(event)
	end
	return true
end

--checkbox
local function isAgree(event)
	local phase = event.phase

    if ( phase == "moved" ) then
        local dy = math.abs( ( event.y - event.yStart ) )
        -- If the touch on the button has moved more than 10 pixels,
        -- pass focus back to the scroll view so it can continue scrolling
        if ( dy > 10 ) then
            scrollView:takeFocus( event )
        end
	elseif(phase == "ended" or phase == "cancelled") then
		if (agree_checkbox==false) then
			agree_checkbox_background2.alpha=1
			agree_checkbox=true
		elseif (agree_checkbox==true) then
			agree_checkbox_background2.alpha=0
			agree_checkbox=false
		end
	end
    return true
end
--gender
local function genderSelectFnc(event)
    if ( event.phase == "moved" ) then
        local dy = math.abs( ( event.y - event.yStart ) )
        -- If the touch on the button has moved more than 10 pixels,
        -- pass focus back to the scroll view so it can continue scrolling
        if ( dy > 10 ) then
            scrollView:takeFocus( event )
        end
	elseif(event.phase == "ended" or event.phase == "cancelled") then
	end	
	return true
end
local function termsAndConditionsFnc(event)
    if ( event.phase == "moved" ) then
        local dy = math.abs( ( event.y - event.yStart ) )
        -- If the touch on the button has moved more than 10 pixels,
        -- pass focus back to the scroll view so it can continue scrolling
        if ( dy > 10 ) then
            scrollView:takeFocus( event )
        end
	elseif(event.phase == "ended" or event.phase == "cancelled") then
		local options =
		{
			effect = "fromBottom",
			time = 400,
			isModal = true,
		}
		
		storyboard.showOverlay( "Scene.TermsAndConitions", options )
	end	
	return true
end

local function registerUserListener(event)
	native.setActivityIndicator( false )
	
	if (event[1].isError) then
		native.showAlert(localization.getLocalization("networkError_errorTitle"),localization.getLocalization("networkError_networkError"),{localization.getLocalization("ok")})
	
	else
		
		local response = json.decode(event[1].response)
		
		if(response.code)then
			response.code = tonumber(response.code)
			print(tostring(response.code).." "..tostring(response.message))
			if(response.code==2)then
				native.showAlert(localization.getLocalization("registerFail_registerTitle"),localization.getLocalization("registerFail_emailAlreadyRegistered"),{localization.getLocalization("ok")})
			end
		else
			--register success
			print(event[1].response)
			saveData.delete("profileData.txt", system.TemporaryDirectory)
			addPhotoFnc.deleteTempImage(global.registerImagePath)
			native.showAlert(localization.getLocalization("registerSuccess_registerTitle"),localization.getLocalization("registerSuccess_register"),{localization.getLocalization("ok")})
			storyboard.gotoScene( "Scene.LoginPageScene",goToLoginSceneOption)
		end
		
	end
	
end
local function registerUser()
	print("sign up")
	if ((facebookData ~= nil) and (facebookData.token ~= nil)) then
		userData.fb_token = facebookData.token
	end
	newNetworkFnc.signup(userData, registerUserListener)
end
local function uploadPicListener(event)

	print("upload finish")
	userData.profile_pic = event.filename
	registerUser()
	-- native.setActivityIndicator( false )
end

local function registerUserFnc()
	--really register
	--upload Photo
	native.setActivityIndicator( true )
	profilePicPath = {}
	profilePicPath.path = addPhotoFnc.getImageRealPath(global.registerImagePath)
	profilePicPath.baseDir = global.TEMPBASEDIR
	
	local profileExist = newNetworkFnc.uploadProfilePic(profilePicPath, uploadPicListener)
	if(not profileExist)then
		userData.profile_pic = nil
		registerUser()
	end
	
end
--if not open GPS, choose a option
--index 1 = cancel
--index 2 = continue
local function GPSOptionsListener(event)
	if event.action == "clicked" then
        local i = event.index
        if i == 1 then
         
        elseif i == 2 then
            registerUserFnc()
        end
    end
end


local function countryCheckingAndRegister(event)
	native.setActivityIndicator( false )
	if(event.isNetworkError)then
		native.showAlert(localization.getLocalization("networkError_errorTitle"),localization.getLocalization("networkError_networkError"),{localization.getLocalization("ok")})
		return false
	elseif(event.isGPSError)then
		print("event.isGPSError",event.isGPSError)
		native.showAlert(localization.getLocalization("GPS_openGpsTitle"),localization.getLocalization("GPS_openGps"),{localization.getLocalization("GPS_openGpsOption_open"),localization.getLocalization("GPS_openGpsOption_continue")},GPSOptionsListener)
		return false
	elseif(event.isAPIError)then
		print("event.isAPIError",event.isAPIError)
		return false
	elseif(event.country)then
		print("event.country",event.country)
		--get my country
		userData.country = event.country
		registerUserFnc()
	else
		print("ERROR No data")
		return false
	end
end
local function registerFnc(event)
	local phase = event.phase

    if ( phase == "moved" ) then
        local dy = math.abs( ( event.y - event.yStart ) )
       
        if ( dy > 10 ) then
            scrollView:takeFocus( event )
        end
	elseif( phase == "ended" or  phase == "cancelled")then
		if(email_textField.text=="")then --check the email
			native.showAlert(localization.getLocalization("inputCheck_mustFillTitle"),localization.getLocalization("inputCheck_fillEmail"),{localization.getLocalization("ok")})
			return false
		end

		local atPos = string.find(email_textField.text,"@",1,true)

		if(not atPos)then
			native.showAlert(localization.getLocalization("inputCheck_emailNoAtTitle"),localization.getLocalization("inputCheck_emailNoAt"),{localization.getLocalization("ok")})
			return false
		end

		if(textField_password.text=="")then --check the password
			native.showAlert(localization.getLocalization("inputCheck_mustFillTitle"),localization.getLocalization("inputCheck_fillPassword"),{localization.getLocalization("ok")})
			return false
		end
		if(textField_confirmPassword.text=="")then --check the confirmed password
			native.showAlert(localization.getLocalization("inputCheck_mustFillTitle"),localization.getLocalization("inputCheck_fillConfirmedPassword"),{localization.getLocalization("ok")})
			return false
		end
		if(profile_textField_name.text=="")then
			native.showAlert(localization.getLocalization("inputCheck_mustFillTitle"),localization.getLocalization("inputCheck_fillName"),{localization.getLocalization("ok")})
			return false
		end
		if(not agree_checkbox)then --check the checkbox
			native.showAlert(localization.getLocalization("inputCheck_agreeCheckBoxTitle"),localization.getLocalization("inputCheck_agreeCheckBox"),{localization.getLocalization("ok")})
			return false
		end
		if(textField_password.text~=textField_confirmPassword.text)then --check password whether the same
			native.showAlert(localization.getLocalization("inputCheck_passwordDiffTitle"),localization.getLocalization("inputCheck_passwordDiff"),{localization.getLocalization("ok")})
			return false
		end



		native.setActivityIndicator( true )
		
		userData.email = string.lower(email_textField.text)
		userData.password = textField_password.text
		userData.name = profile_textField_name.text
		userData.phone = ""
		userData.gender = genderOption:getChosenId()

		local month_num
		local day_num
		if(booldean_birthHadSelected)then
			for i=1,#month_array do
				if(month==month_array[i])then
					month_num = i
					if(month_num<10)then
						month_num = "0"..tostring(month_num)
					else
						month_num = tostring(month_num)
					end
					break
				end
			end
			if(day<10)then
				day_num = "0"..tostring(day)
			else
				day_num = tostring(day)
			end
			userData.dateOfBirth = year.."-"..month_num.."-"..day_num
		
		end
		
		geolocationUtility.getCountryByCurrentLocation(countryCheckingAndRegister) 
		
    end
    return true
end


-- Create the scene
function scene:createScene( event )
	debugLog( "Creating " .. LOCAL_SETTINGS.NAME .. " Scene")
	local sceneGroup = self.view
	local displayGroup = display.newGroup()
	
	display.setStatusBar( display.HiddenStatusBar )
	display.setDefault( "background", 187/255, 235/255, 1 )	
	
	scrollView = widget.newScrollView
	{
		top = 0,
		left = 0,
		width = display.contentWidth,
		height = display.contentHeight,
		-- bottomPadding = 100,
		backgroundColor = { 187/255, 235/255, 1 },
		horizontalScrollDisabled = true,
		verticalScrollDisabled = false,
		hideScrollBar = true,
		listener = scrollListener
	}
	
	
	local image_logo = display.newImage( "Image/LoginPage/logo.png")
	image_logo.x = display.contentCenterX
	image_logo.y = 96
	image_logo.anchorX=0.5
	image_logo.anchorY=0
	displayGroup:insert(image_logo)
	
	local exit_button = widget.newButton
	{
		id = "exit_button",
		defaultFile = "Image/LoginPage/exit.png",
		overFile = "Image/LoginPage/exit.png",
		onEvent=exitFnc
	}
	exit_button.x = 610
	exit_button.y = 30
	exit_button.anchorX=1
	exit_button.anchorY=0
	displayGroup:insert(exit_button)
	---------------text field of Account part begin
	
	local account_background_textField_width = 488
	local account_background_textField_height = 231
	local account_background_textField_y = 300
	
	
	local account_background_textField = display.newRoundedRect( display.contentCenterX, account_background_textField_y, account_background_textField_width, account_background_textField_height, 1 )
	account_background_textField:setFillColor( 1,1,1 )
	account_background_textField:setStrokeColor(  172/255,  172/255,  172/255 )
	account_background_textField.strokeWidth = 2
	account_background_textField.anchorX=0.5
	account_background_textField.anchorY=0

	displayGroup:insert(account_background_textField)


	-----------------
	local account_background_textField_beginX = account_background_textField.x-(account_background_textField.anchorX*account_background_textField.width)
	local account_background_textField_endX = account_background_textField_beginX+account_background_textField.width
	local account_background_textField_twoY = (account_background_textField.y+account_background_textField.height/3)

	-----------------
	local textField_x = account_background_textField_beginX+100
	local textField_width = account_background_textField_width-100-1
	local textField_height = account_background_textField_height/3-1
	
	email_textField = coronaTextField:new( textField_x, account_background_textField.y+1, textField_width, textField_height,displayGroup,"displayGroup" )
	email_textField.anchorX=0
	email_textField.anchorY=0
	email_textField:setTopPadding(200)
	email_textField:setPlaceHolderText(localization.getLocalization("register_email_textField_placeholder"))
	email_textField.hasBackground = false
	email_textField:setFont("Helvetica",32)
	-- email_textField.isFontSizeScaled = true
	email_textField:setUserInputListener( textListener )
	
	displayGroup:insert(email_textField)

	local email_textField_total_height = email_textField.y+email_textField.height
	textField_password = coronaTextField:new( textField_x, email_textField_total_height, textField_width, textField_height,displayGroup,"displayGroup" )
	textField_password.anchorX=0
	textField_password.anchorY=0
	textField_password:setTopPadding(200)
	textField_password:setPlaceHolderText(localization.getLocalization("register_password_textField_placeholder"))
	textField_password.hasBackground = false
	textField_password.isSecure = true
	textField_password:setFont("Helvetica",32)
	-- textField_password.isFontSizeScaled = true
	-- textField_password:setUserInputListener( textListener )
	displayGroup:insert(textField_password)
	
	local textField_password_total_height = textField_password.y+textField_password.height
	textField_confirmPassword = coronaTextField:new( textField_x, textField_password_total_height, textField_width, textField_height,displayGroup,"displayGroup" )
	textField_confirmPassword.anchorX=0
	textField_confirmPassword.anchorY=0
	textField_confirmPassword:setTopPadding(200)
	textField_confirmPassword:setPlaceHolderText(localization.getLocalization("register_comfirmPassword_textField_placeholder"))
	textField_confirmPassword.hasBackground = false
	textField_confirmPassword.isSecure = true
	textField_confirmPassword:setFont("Helvetica",32)
	-- textField_confirmPassword.isFontSizeScaled = true
	-- textField_confirmPassword:setUserInputListener( textListener )
	displayGroup:insert(textField_confirmPassword)
	
	local background_underline = display.newLine(account_background_textField_beginX,account_background_textField_twoY,account_background_textField_endX,account_background_textField_twoY)
	background_underline:setStrokeColor( 204/255, 204/255, 204/255 )
	background_underline.strokeWidth = 2
	displayGroup:insert(background_underline)
	
	local background_underline2 = display.newLine(account_background_textField_beginX,textField_confirmPassword.y,account_background_textField_endX,textField_confirmPassword.y)
	background_underline2:setStrokeColor( 204/255, 204/255, 204/255 )
	background_underline2.strokeWidth = 2

	displayGroup:insert(background_underline2)
	-----------------
	
	local email_icon = display.newImage("Image/RegisterPage/email.png")
	email_icon.x = account_background_textField_beginX + 34
	email_icon.y = email_textField.y + 18
	email_icon.anchorX=0
	email_icon.anchorY=0
	displayGroup:insert(email_icon)
	
	local password_icon = display.newImage("Image/LoginPage/password.png")
	password_icon.x = account_background_textField_beginX + 34
	password_icon.y = textField_password.y + 18
	password_icon.anchorX=0
	password_icon.anchorY=0
	displayGroup:insert(password_icon)
	
	local confirmPassword_icon = display.newImage("Image/LoginPage/password.png")
	confirmPassword_icon.x = account_background_textField_beginX + 34
	confirmPassword_icon.y = textField_confirmPassword.y + 18
	confirmPassword_icon.anchorX=0
	confirmPassword_icon.anchorY=0
	displayGroup:insert(confirmPassword_icon)
			

	
	local text_acconut =
	{
		text = localization.getLocalization("register_account"), 
		x = account_background_textField_beginX,
		y = account_background_textField.y-20,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=36
	}

	text_acconut = display.newText(text_acconut);
	text_acconut:setFillColor( 78/255, 184/255, 229/255 )
	text_acconut.anchorX=0
	text_acconut.anchorY=1
	displayGroup:insert(text_acconut)
	
	---------------text field of Account part end
	
	--------------- profile part begin
	local profile_background_textField_width = 488
	local profile_background_textField_height = 121
	local profile_background_textField_y = account_background_textField.y+account_background_textField.height+80
	
	local profile_background_textField = display.newRoundedRect( display.contentCenterX, profile_background_textField_y, profile_background_textField_width, profile_background_textField_height, 5 )
	profile_background_textField:setFillColor( 1,1,1 )
	profile_background_textField:setStrokeColor(  172/255,  172/255,  172/255 )
	profile_background_textField.strokeWidth = 2
	profile_background_textField.anchorX=0.5
	profile_background_textField.anchorY=0
		
	displayGroup:insert(profile_background_textField)
		

	-----------------
	local profile_background_textField_beginX = profile_background_textField.x-(profile_background_textField.anchorX*profile_background_textField.width)
	local profile_background_textField_endX = profile_background_textField_beginX+profile_background_textField.width
	local profile_background_textField_centerY = (profile_background_textField.y+profile_background_textField.height/2)
	
	local profile_background_underline = display.newLine(profile_background_textField_beginX,profile_background_textField_centerY,profile_background_textField_endX,profile_background_textField_centerY)
	profile_background_underline:setStrokeColor( 204/255, 204/255, 204/255 )
	profile_background_underline.strokeWidth = 2
	displayGroup:insert(profile_background_underline)
	-----------------
	local profile_textField_x = profile_background_textField_beginX+121
	local profile_textField_width = profile_background_textField_width-121-1
	local profile_textField_height = profile_background_textField_height/2-1
	--already create
	profile_textField_name = coronaTextField:new( profile_textField_x, profile_background_textField.y, profile_textField_width, profile_textField_height,displayGroup,"displayGroup" )
	profile_textField_name.anchorX=0
	profile_textField_name.anchorY=0
	profile_textField_name:setTopPadding(200)
	profile_textField_name:setPlaceHolderText(localization.getLocalization("register_name_textField_placeholder"))
	profile_textField_name.hasBackground = false
	profile_textField_name:setFont("Helvetica",32)
	-- profile_textField_name.isFontSizeScaled = true
	profile_textField_name:setUserInputListener( textListener )
	displayGroup:insert(profile_textField_name)

	local profile_textField_name_total_height = profile_textField_name.y+profile_textField_name.height
	--already create
	text_birthday =
	{
		text = localization.getLocalization("register_birth_textField_placeholder"), 
		x = profile_textField_x,
		y = profile_textField_name_total_height+20,
		width = profile_textField_width,
		height = 0, 
		font = "Helvetica",
		fontSize=24,
		align="center",
	}

	text_birthday = display.newText(text_birthday);
	text_birthday:setFillColor( 172/255,  172/255,  172/255 )
	text_birthday.anchorX=0
	text_birthday.anchorY=0
	text_birthday:addEventListener("touch",birthdaySelection)
	displayGroup:insert(text_birthday)
	--------------------------------

	
	local profile_button_addPhoto = widget.newButton
	{
		id = "addPhoto_button",
		defaultFile = "Image/RegisterPage/addPhoto.png",
		overFile = "Image/RegisterPage/addPhoto.png",
		onEvent = addPhoto,
	}
	
	profile_button_addPhoto.x = profile_background_textField_beginX
	profile_button_addPhoto.y = profile_background_textField.y
	profile_button_addPhoto.anchorX = 0
	profile_button_addPhoto.anchorY = 0
	profile_button_addPhoto.savePath = global.registerImagePath
	profile_button_addPhoto.photo = nil
	displayGroup:insert(profile_button_addPhoto)
	
	local text_profile =
	{
		text = localization.getLocalization("register_profile"), 
		x = profile_background_textField_beginX,
		y = profile_background_textField.y-20,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=36
	}
	text_profile = display.newText(text_profile);
	text_profile:setFillColor( 78/255, 184/255, 229/255 )
	text_profile.anchorX=0
	text_profile.anchorY=1
	displayGroup:insert(text_profile)
	--------------- profile part end

	
	--------------- gender (male and female) begin

	genderOption = {
		choices = {localization.getLocalization("register_male"),localization.getLocalization("register_female")},
		choicesId = {"M","F"},
		leftImagePath_isSelected = "Image/Filter/leftSelect.png",
		leftImagePath_isNotSelected = "Image/Filter/leftNotSelect.png",
		rightImagePath_isSelected = "Image/Filter/rightSelect.png",
		rightImagePath_isNotSelected ="Image/Filter/rightNotSelect.png",
		choicesListener = genderSelectFnc,
		y = profile_background_textField.y+profile_background_textField.height+20,
		font = "Helvetica",
		fontSize = 28.06,
		textColor = { 1, 1, 1},
		choiceOffset = 2,
	}
	genderOption = optionModule.new(genderOption)
	displayGroup:insert(genderOption)
	--------------- gender (male and female) end
	
	
	--------------- part of ( i agree terms and conditions.) begin
	local agree_checkbox_background = display.newRect( 80, genderOption.y+genderOption.height+20, 50, 50 )
	agree_checkbox_background:setFillColor( 1,1,1 )
	agree_checkbox_background.strokeWidth = 2
	agree_checkbox_background:setStrokeColor( 0, 0, 0 )
	agree_checkbox_background.anchorX = 0
	agree_checkbox_background.anchorY = 0
	agree_checkbox_background:addEventListener("touch",isAgree)
	displayGroup:insert(agree_checkbox_background)
	
	local agree_checkbox_background2_x = agree_checkbox_background.x+11
	local agree_checkbox_background2_y = agree_checkbox_background.y+11
	local agree_checkbox_background2_width_height = 26
	--local already create
	agree_checkbox_background2 = display.newRoundedRect(agree_checkbox_background2_x ,agree_checkbox_background2_y , agree_checkbox_background2_width_height, agree_checkbox_background2_width_height,5 )
	agree_checkbox_background2:setFillColor( 78/255,184/255,229/255 )
	agree_checkbox_background2.strokeWidth = 0
	agree_checkbox_background2:setStrokeColor( 0, 0, 0 )
	agree_checkbox_background2.anchorX = 0
	agree_checkbox_background2.anchorY = 0
	agree_checkbox_background2.alpha=0
	displayGroup:insert(agree_checkbox_background2)
	
	local text_i_agree =
	{
		text = localization.getLocalization("register_iagree"), 
		x = 236,
		y = agree_checkbox_background2.y-6,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=30
	}

	text_i_agree = display.newText(text_i_agree);
	text_i_agree:setFillColor( 81/255 , 81/255 , 81/255  )
	text_i_agree.anchorX=1
	text_i_agree.anchorY=0

	displayGroup:insert(text_i_agree)
	
	
	local text_terms_and_conditions =
	{
		text = localization.getLocalization("register_terms_and_conditions"), 
		x = text_i_agree.x,
		y = text_i_agree.y,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=30
	}

	text_terms_and_conditions = display.newText(text_terms_and_conditions);
	text_terms_and_conditions:setFillColor( 78/255, 184/255, 229/255 )
	text_terms_and_conditions.anchorX=0
	text_terms_and_conditions.anchorY=0
	text_terms_and_conditions:addEventListener("touch",termsAndConditionsFnc)
	displayGroup:insert(text_terms_and_conditions)
	
	local text_terms_and_conditions_beginX = text_terms_and_conditions.x-(text_terms_and_conditions.width*text_terms_and_conditions.anchorX)
	local text_terms_and_conditions_endX = text_terms_and_conditions_beginX + text_terms_and_conditions.width
	local text_terms_and_conditions_total_height = text_terms_and_conditions.y+text_terms_and_conditions.height
	
	local underline_terms_and_conditions = display.newLine( text_terms_and_conditions_beginX, text_terms_and_conditions_total_height, text_terms_and_conditions_endX -10, text_terms_and_conditions_total_height )
	underline_terms_and_conditions:setStrokeColor( 78/255, 184/255, 229/255 )
	underline_terms_and_conditions.strokeWidth=2
	
	displayGroup:insert(underline_terms_and_conditions)
	--------------- part of ( i agree terms and conditions.) end

	--------------- confirm button begin
	local confirm_button = buttonModule.newButton
	{
		label = localization.getLocalization("register_confirm"),
		labelColor = { default={ 1, 1, 1 }, over={  1, 1, 1  } },
		font = "Helvetica",
		fontSize = 36,
		onEvent = registerFnc,
		
		shape = "roundedRect",
		fillColor = { default={ 78/255, 184/255, 229/255}, over={ 78/255, 184/255, 229/255} },
		width = 316,
		height = 78,
		cornerRadius = 10,
		strokeColor = { default={ 0, 0, 0 }, over={ 0, 0, 0 } },
		strokeWidth =0
	}
	confirm_button.x = display.contentCenterX
	confirm_button.y = agree_checkbox_background.y+agree_checkbox_background.height+20
	confirm_button.anchorX=0.5
	confirm_button.anchorY=0
	displayGroup:insert(confirm_button)
	--set next field
	email_textField:nextTextFieldFocus(textField_password, nil)
	textField_password:nextTextFieldFocus(textField_confirmPassword, nil)
	textField_confirmPassword:nextTextFieldFocus(profile_textField_name, nil)

	--------------- confirm button end
	if(displayGroup.height<=display.contentHeight)then
		scrollView:setIsLocked( true, "vertical" )
	end
	
	scrollView:insert(displayGroup)
	scrollView:setScrollHeight(displayGroup.y+displayGroup.height+100 )
	sceneGroup:insert(scrollView)
	
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
	print("reg add")
	-- Place the code below
end
function scene:enterScene( event )
	debugLog( "Entering " .. LOCAL_SETTINGS.NAME .. " Scene")

	-- removing key event for scene transition
	Runtime:removeEventListener( "key", onSceneTransitionKeyEvent )
	print("reg remove")
	-- adding check system key event
	-- Runtime:addEventListener( "key", onKeyEvent )
	hardwareButtonHandler.clearAllCallback()
	hardwareButtonHandler.activate()
	hardwareButtonHandler.addCallback(onKeyEvent, true)
	
	-- remove previous scene's view
--	storyboard.purgeScene( lastScene )
	storyboard.purgeAll()

	-- Place the code below
	facebookData = nil
	if ((event.params ~= nil) and (event.params.fb ~= nil)) then
		facebookData = event.params.fb
	end
end

-- Called when scene is about to move offscreen:
function scene:exitScene(event)
	debugLog( "Exiting " .. LOCAL_SETTINGS.NAME .. " Scene")

	-- removing check system key event
	-- Runtime:removeEventListener( "key", onKeyEvent )
	hardwareButtonHandler.removeCallback(onKeyEvent)
	hardwareButtonHandler.deactivate()
	hardwareButtonHandler.clearAllCallback()

	-- Place the code below
end

-- Called prior to the removal of scene's "view" (display group_register)
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