
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
require ( "SystemUtility.Debug" )
local localization = require("Localization.Localization")
local addPhotoFnc = require("Function.addPhoto")
local saveData = require( "SaveData.SaveData" )
-- local networkFunction = require("Network.NetworkFunction")
local geolocationUtility = require("SystemUtility.GeolocationUtility")
local global = require( "GlobalVar.global" )
local headerView = require( "ProjectObject.HeaderView" )
local headTabFnc = require( "ProjectObject.HeadTabFnc" )
local stringUtility = require( "SystemUtility.StringUtility" )
local json = require( "json" )
local networkFile = require("Network.NetworkFile")
local sizableActivityIndicatorFnc = require("Module.SizableActivityIndicator")
local optionModule = require("Module.Option")
local newNetworkFunction = require("Network.newNetworkFunction")
local hardwareButtonHandler = require("ProjectObject.HardwareButtonHandler")
local geolocationUtility = require("SystemUtility.GeolocationUtility")
local dayPickerWheel = require("ProjectObject.DayPickerWheel")

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local MONTH_ARRAY = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
local sceneGroup
local displayGroup
local scrollView



--Create a storyboard scene for this module
local scene = storyboard.newScene()

--birthday
local year
local month
local day
local text_birthday
local booldean_birthHadSelected = false
--textField
-- local textField_username
local email_textField
local textField_password
local textField_confirmPassword
local profile_textField_name
local userData
local newUserData
local userId
local userName
local userGender
local profilePicPath
local uploadedPic

local genderOption

local temp_userIconUrl

local profile_button_addPhoto
local havePhoto = false

local setupCountry_checkbox_trueBox
local needSetupCountry = false
---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------


---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
-- Function for back button
local function onBackButtonPressed()
	if (dayPickerWheel.isPickerWheelExist()) then
		dayPickerWheel.forceExit()
	else
		storyboard.gotoScene("Scene.SettingTabScene", global.backSceneOption)
	end
end


local function setActivityIndicatorFnc(boolean_loading)
	if(not loadingIcon and boolean_loading)then
		loadingIcon = sizableActivityIndicatorFnc.newActivityIndicator(display.contentWidth,display.contentHeight)
		loadingIcon.x = display.contentCenterX
		loadingIcon.y = display.contentCenterY
		loadingIcon:setEnable(true)
	elseif(loadingIcon and boolean_loading)then
		loadingIcon:setEnable(true)
	elseif(loadingIcon and not boolean_loading)then
		loadingIcon:setEnable(false)
	end
end

local function textListener( event )
    if ( event.phase == "began" ) then

    	event.target.text = stringUtility.trimStringSpace(event.target.text)

    elseif ( event.phase == "ended" or event.phase == "submitted" ) then

  		event.target.text = stringUtility.trimStringSpace(event.target.text)

    elseif ( event.phase == "editing" ) then
      
		local emojiTrimmedString, isEmojiDetected = stringUtility.trimEmoji(event.target.text)
		if (isEmojiDetected) then
			event.target.text = emojiTrimmedString
		end
    end
end


local function changedListener(value)
	year = tonumber(value.year)
	month = tonumber(value.month)
	day = tonumber(value.day)
	text_birthday.text = day.."/"..tostring(MONTH_ARRAY[month]).."/"..year
	text_birthday:setFillColor(0,0,0)
end
local function birthdaySelection(event)
	if(event.phase=="ended"or event.phase=="cancelled")then
		booldean_birthHadSelected = true
		local currentTime = os.date("*t")
		
		local date = {
			startDate = {day = 1, month = 1, year = 1900},
			endDate = {day = tonumber(currentTime.day), month = tonumber(currentTime.month), year = tonumber(currentTime.year)},
		}
		if ((year ~= nil) and (month ~= nil) and (day ~= nil)) then
			date.default = {day = day, month = month, year = year}
		else
			date.default = {day = tonumber(currentTime.day), month = tonumber(currentTime.month), year = tonumber(currentTime.year)}
		end
		dayPickerWheel.show(20, display.contentHeight-300-20, display.contentWidth - 40, 300, date, changedListener)
	end
	return true
end

local function addPhoto(event)
	local phase = event.phase

	if ( phase == "moved" ) then
		local dy = math.abs( ( event.y - event.yStart ) )
		if ( dy > 10 ) then
			scrollView:takeFocus( event )
		end
	elseif(phase=="ended" or phase=="cancelled")then
		addPhotoFnc.addPhoto(event)
	end
	return true
end


local function goBackSettingScene(event)
	 if ( event.phase == "moved" ) then
        local dy = math.abs( ( event.y - event.yStart ) )
        -- If the touch on the button has moved more than 10 pixels,
        -- pass focus back to the scroll view so it can continue scrolling
        if ( dy > 10 ) then
            scrollView:takeFocus( event )
        end
	elseif( event.phase == "ended" or  event.phase == "cancelled")then
		
		storyboard.gotoScene( "Scene.SettingTabScene",global.backSceneOption)
	end
	return true
end

local function updateUserListener(event)
	native.setActivityIndicator( false )
	if(event.isNetworkError)then
		native.showAlert(localization.getLocalization("networkError_errorTitle"),localization.getLocalization("networkError_networkError"),{localization.getLocalization("ok")})
	else
		native.showAlert(localization.getLocalization("updateUserDataSuccess_updateTitle"),localization.getLocalization("updateUserDataSuccess_update"),{localization.getLocalization("ok")})

		if(newUserData.profile_pic and userData.profile_pic~=newUserData.profile_pic)then
			userData.profile_pic = newUserData.profile_pic
		end

		if(newUserData.password)then
			userData.password = newUserData.password
			newNetworkFunction.updateLoginData({password = userData.password})
		end
		
		if(newUserData.name)then
			userData.name = newUserData.name
		end

		if(newUserData.gender)then
			userData.gender = newUserData.gender
		end

		if(booldean_birthHadSelected)then
		
			if(not userData.dateOfBirth)then
				userData.dateOfBirth = {}
			end
			userData.dateOfBirth = newUserData.dateOfBirth
		end

		if(newUserData.country)then
			userData.country = newUserData.country
		end	

		if(profilePicPath=="")then
			userData.profile_pic = nil
		end

		addPhotoFnc.deleteTempImage(global.updateIconImage)

		saveData.delete("profileData.txt", system.TemporaryDirectory)

		saveData.save(global.userDataPath,userData)

		storyboard.gotoScene( "Scene.SettingTabScene")
	end
end

local function updateUserData()
	newNetworkFunction.updateUserData(newUserData,updateUserListener)
end


local function uploadPicListener(event)

	if (event.fileNotFound) then
		-- print("File not found")
	elseif (event.networkError) then
		-- print("Network Error")
	else
		saveData.save("profileData.txt", system.TemporaryDirectory, event.filename)
		uploadedPic = event.filename
		newUserData.profile_pic = event.filename
		-- print("newUserData.profile_pic",newUserData.profile_pic)
		updateUserData()
		
		return
	end
	native.setActivityIndicator( false )
end


local function uploadedPictureFnc()
	--get icon path
	profilePicPath = addPhotoFnc.getImageRealPath(global.updateIconImage)
	if(not profilePicPath)then
		if(havePhoto and not profile_button_addPhoto.photo)then
			newUserData.profile_pic = ""
		end
	end

	uploadedPic = saveData.load("profileData.txt", system.TemporaryDirectory)

	if type(profilePicPath)=="nil" then
		updateUserData()
	else
		local picTable = {
							path = profilePicPath,
							baseDir = system.TemporaryDirectory
						}
		newNetworkFunction.uploadProfilePic(picTable,uploadPicListener)
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
			uploadedPictureFnc()
        end
    end
end

local function countryChecking(event)
	native.setActivityIndicator( false )
		-- print("bb")
	if(event.isNetworkError)then
		native.showAlert(localization.getLocalization("networkError_errorTitle"),localization.getLocalization("networkError_networkError"),{localization.getLocalization("ok")})
		return false
	elseif(event.isGPSError)then
		-- print("event.isGPSError",event.isGPSError)
		native.showAlert(localization.getLocalization("GPS_openGpsTitle"),localization.getLocalization("GPS_openGps"),{localization.getLocalization("GPS_openGpsOption_open"),localization.getLocalization("GPS_openGpsOption_continue")},GPSOptionsListener)
		return false
	elseif(event.isAPIError)then
		-- print("event.isAPIError",event.isAPIError)
		return false
	elseif(event.country)then
		-- print("event.country",event.country)
		--get my country
		newUserData.country = event.country
		uploadedPictureFnc()
	else
		-- print("ERROR No data")
		return false
	end
end



local function updateFnc(event)
	if((string.len(textField_password.text)>0 or string.len(textField_confirmPassword.text)>0) and(textField_password.text~=textField_confirmPassword.text))then --check password whether the same
		native.showAlert(localization.getLocalization("inputCheck_passwordDiffTitle"),localization.getLocalization("inputCheck_passwordDiff"),{localization.getLocalization("ok")})
		return false
	end

	if(profile_textField_name.text=="")then
		native.showAlert(localization.getLocalization("inputCheck_mustFillTitle"),localization.getLocalization("inputCheck_fillName"),{localization.getLocalization("ok")})
		return false
	end

	native.setActivityIndicator( true )
	
	if((string.len(textField_password.text)>0 or string.len(textField_confirmPassword.text)>0) and(textField_password.text==textField_confirmPassword.text))then --check password whether the same
		newUserData.password = textField_password.text
	end
	if(profile_textField_name.text~=userName)then
		newUserData.name = profile_textField_name.text
	end

	newUserData.gender = genderOption:getChosenId()
	
	if(newUserData.gender and not(string.upper(newUserData.gender)=="M" or string.upper(newUserData.gender)=="F"))then
		newUserData.gender = nil
	end

	local month_num
	local day_num
	
	if(booldean_birthHadSelected)then
		if(month<10)then
			month_num = "0"..tostring(month)
		else
			month_num = tostring(month)
		end
		if(day<10)then
			day_num = "0"..tostring(day)
		else
			day_num = tostring(day)
		end
		newUserData.dateOfBirth = year.."-"..month_num.."-"..day_num
	end
	
	if(needSetupCountry)then
		geolocationUtility.getCountryByCurrentLocation(countryChecking) 
	else
		uploadedPictureFnc()
	end
end

local function touch_updateFnc(event)
	local phase = event.phase
	if ( phase == "moved" ) then
		local dy = math.abs( ( event.y - event.yStart ) )
		if ( dy > 10 ) then
			scrollView:takeFocus( event )
		end
	elseif( phase == "ended" or  phase == "cancelled")then
		updateFnc(event)	 
	end
	return true
end

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

local userIconFnc = function(fileInfo)

	profile_button_addPhoto.photo = display.newImage(fileInfo.path, fileInfo.baseDir, true)
	if(profile_button_addPhoto.photo)then
		addPhotoFnc.imageProcess(profile_button_addPhoto)
		displayGroup:insert(profile_button_addPhoto.photo)
		havePhoto = true
	end
	setActivityIndicatorFnc(false)
end

local function userIconListener(event)
	if (event.isError) then
	else
		userIconFnc({path = event.path, baseDir = event.baseDir})
	end
end

local function changeSetupCountryStatusFnc(event)
	 if ( event.phase == "moved" ) then
        local dy = math.abs( ( event.y - event.yStart ) )
        -- If the touch on the button has moved more than 10 pixels,
        -- pass focus back to the scroll view so it can continue scrolling
        if ( dy > 10 ) then
            scrollView:takeFocus( event )
        end
	elseif(event.phase == "ended" or event.phase == "cancelled") then
		if ( needSetupCountry == false ) then
			setupCountry_checkbox_trueBox.alpha = 1
			needSetupCountry = true
		elseif ( needSetupCountry == true) then
			setupCountry_checkbox_trueBox.alpha = 0
			needSetupCountry = false
		end
	end	
	return true
end

-- Create the scene
function scene:createScene( event )
	debugLog( "Creating " .. LOCAL_SETTINGS.NAME .. " Scene")
	sceneGroup = self.view

	booldean_birthHadSelected = false

	displayGroup = display.newGroup()

	newUserData = {}
	userData = saveData.load(global.userDataPath)




	userId = userData.id

	addPhotoFnc.deleteTempImage(global.updateIconImage)
	saveData.delete("profileData.txt", system.TemporaryDirectory)
	
	temp_userIconUrl = userData.profile_pic
	
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
		isBounceEnabled = false,
		listener = scrollListener
	}
	
	---------------text field of Account part begin
	
	local account_background_textField_width = 488
	local account_background_textField_height = 231
	local account_background_textField_y = 150
	
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
	local background_line = display.newLine(account_background_textField_beginX,account_background_textField_twoY,account_background_textField_endX,account_background_textField_twoY)
	background_line:setStrokeColor( 204/255, 204/255, 204/255 )
	background_line.strokeWidth = 2
	displayGroup:insert(background_line)
	-----------------
	local textField_x = account_background_textField_beginX+100
	local textField_width = account_background_textField_width-100-1
	local textField_height = account_background_textField_height/3-1
	
	local email_textField =
	{
		text = "", 
		x = textField_x,
		y = account_background_textField_y+textField_height/2,
		width = textField_width,
		height = 0, 
		font = "Helvetica",
		fontSize=32
	}
	email_textField = display.newText(email_textField);
	email_textField:setFillColor(0,0,0,1)
	email_textField.anchorX=0
	email_textField.anchorY=0.5
	displayGroup:insert(email_textField)

	local email_grayBackground = display.newRoundedRect( display.contentCenterX, account_background_textField_twoY, account_background_textField_width, textField_height, 1 )
	email_grayBackground:setFillColor( 0.7, 0.7, 0.7, 0.6)
	email_grayBackground.anchorX=0.5
	email_grayBackground.anchorY=1
	displayGroup:insert(email_grayBackground)
	
	local email_textField_total_height = account_background_textField_y + 77 -- original value: 297
	textField_password = coronaTextField.new( textField_x, email_textField_total_height, textField_width, textField_height,displayGroup,"displayGroup" )
	textField_password.anchorX=0
	textField_password.anchorY=0
	textField_password:setTopPadding(200)
	textField_password:setPlaceHolderText(localization.getLocalization("register_password_textField_placeholder"))
	textField_password:setBackgroundColor(0, 0, 0, 0)
	-- textField_password.hasBackground = false
	textField_password.isSecure = true
	textField_password:setFont("Helvetica",32)
	-- textField_password.isFontSizeScaled = true
	-- textField_password:setUserInputListener( textListener )
	displayGroup:insert(textField_password)
	
	local textField_password_total_height = textField_password.y+textField_password.height
	textField_confirmPassword = coronaTextField.new( textField_x, textField_password_total_height, textField_width, textField_height,displayGroup,"displayGroup" )
	textField_confirmPassword.anchorX=0
	textField_confirmPassword.anchorY=0
	textField_confirmPassword:setTopPadding(200)
	textField_confirmPassword:setPlaceHolderText(localization.getLocalization("register_comfirmPassword_textField_placeholder"))
	textField_confirmPassword:setBackgroundColor(0, 0, 0, 0)
	-- textField_confirmPassword.hasBackground = false
	textField_confirmPassword.isSecure = true
	textField_confirmPassword:setFont("Helvetica",32)
	-- textField_confirmPassword.isFontSizeScaled = true
	-- textField_confirmPassword:setUserInputListener( textListener )
	displayGroup:insert(textField_confirmPassword)
	
	local background_line2 = display.newLine(account_background_textField_beginX,textField_confirmPassword.y,account_background_textField_endX,textField_confirmPassword.y)
	background_line2:setStrokeColor( 204/255, 204/255, 204/255 )
	background_line2.strokeWidth = 2
	displayGroup:insert(background_line2)
	-----------------
	
	local email_icon = display.newImage("Image/RegisterPage/email.png")
	email_icon.x = account_background_textField_beginX + 28
	email_icon.y = email_textField.y
	email_icon.anchorX=0
	email_icon.anchorY=0.5
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
	
	local text_account =
	{
		text = localization.getLocalization("register_account"), 
		x = account_background_textField_beginX,
		y = account_background_textField.y-20,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=36
	}

	text_account = display.newText(text_account);
	text_account:setFillColor( 78/255, 184/255, 229/255 )
	text_account.anchorX=0
	text_account.anchorY=1
	displayGroup:insert(text_account)
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
	
	local profile_background_line = display.newLine(profile_background_textField_beginX,profile_background_textField_centerY,profile_background_textField_endX,profile_background_textField_centerY)
	profile_background_line:setStrokeColor( 204/255, 204/255, 204/255 )
	profile_background_line.strokeWidth = 2
	displayGroup:insert(profile_background_line)
	-----------------
	local profile_textField_x = profile_background_textField_beginX+121
	local profile_textField_width = profile_background_textField_width-121-1
	local profile_textField_height = profile_background_textField_height/2-1
	
	profile_textField_name = coronaTextField.new( profile_textField_x, profile_background_textField.y, profile_textField_width, profile_textField_height,displayGroup,"displayGroup" )
	profile_textField_name.anchorX=0
	profile_textField_name.anchorY=0
	profile_textField_name:setTopPadding(200)
	profile_textField_name:setPlaceHolderText(localization.getLocalization("register_name_textField_placeholder"))
	profile_textField_name:setBackgroundColor(0, 0, 0, 0)
	-- profile_textField_name.hasBackground = false
	profile_textField_name:setFont("Helvetica",32)
	-- profile_textField_name.isFontSizeScaled = true
	profile_textField_name:setUserInputListener( textListener )
	displayGroup:insert(profile_textField_name)
	
	
	
	local profile_textField_name_total_height = profile_textField_name.y+profile_textField_name.height
	
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

	profile_button_addPhoto = widget.newButton
	{
		defaultFile = "Image/RegisterPage/addPhoto.png",
		overFile = "Image/RegisterPage/addPhoto.png",
		onEvent = addPhoto,
	}
	
	profile_button_addPhoto.x = profile_background_textField_beginX
	profile_button_addPhoto.y = profile_background_textField.y
	profile_button_addPhoto.anchorX = 0
	profile_button_addPhoto.anchorY = 0
	profile_button_addPhoto.savePath = global.updateIconImage
	profile_button_addPhoto.photo = nil
	displayGroup:insert(profile_button_addPhoto)
	
	
	local user_icon_savePath = "user/" .. tostring(userId) .. "/img"
	
	local userIconInfo = newNetworkFunction.getVorumFile(temp_userIconUrl, user_icon_savePath, userIconListener)
	
	if ((userIconInfo ~= nil) and (userIconInfo.request == nil)) then
		setActivityIndicatorFnc(true)
		userIconFnc(userIconInfo)
	end
	
	
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
		y = profile_background_textField.y+profile_background_textField.height+20,
		choicesListener = genderSelectFnc,
		font = "Helvetica",
		fontSize = 28.06,
		textColor = { 1, 1, 1},
		choiceOffset = 2,
	}
	if(userData and userData.gender and (string.upper(userData.gender)=="M" or string.upper(userData.gender)=="F"))then
		genderOption.default = userData.gender
		genderOption.isNotEnable = true
	end

	genderOption = optionModule.new(genderOption)
	displayGroup:insert(genderOption)
	--------------- gender (male and female) end
	local setupCountry_checkbox
	if( (type(userData)=="table") and (not userData.country or userData.country=="") )then

		setupCountry_checkbox = display.newRect( 160, genderOption.y+genderOption.height+20, 50, 50 )
		setupCountry_checkbox:setFillColor( 1,1,1 )
		setupCountry_checkbox.strokeWidth = 2
		setupCountry_checkbox:setStrokeColor( 0, 0, 0 )
		setupCountry_checkbox.anchorX = 0
		setupCountry_checkbox.anchorY = 0
		setupCountry_checkbox:addEventListener("touch",changeSetupCountryStatusFnc)
		displayGroup:insert(setupCountry_checkbox)
		
		local setupCountry_checkbox_x = setupCountry_checkbox.x+11
		local setupCountry_checkbox_y = setupCountry_checkbox.y+11
		local setupCountry_checkbox_width_height = 26
		--local already create
		setupCountry_checkbox_trueBox = display.newRoundedRect(setupCountry_checkbox_x ,setupCountry_checkbox_y , setupCountry_checkbox_width_height, setupCountry_checkbox_width_height,5 )
		setupCountry_checkbox_trueBox:setFillColor( 78/255,184/255,229/255 )
		setupCountry_checkbox_trueBox.strokeWidth = 0
		setupCountry_checkbox_trueBox:setStrokeColor( 0, 0, 0 )
		setupCountry_checkbox_trueBox.anchorX = 0
		setupCountry_checkbox_trueBox.anchorY = 0
		setupCountry_checkbox_trueBox.alpha = 0
		displayGroup:insert(setupCountry_checkbox_trueBox)

		local text_i_agree =
		{
			text = localization.getLocalization("edit_setupMyCountry"), 
			x = setupCountry_checkbox.x+setupCountry_checkbox.width+20,
			y = setupCountry_checkbox_trueBox.y-6,
			width = 0,
			height = 0, 
			font = "Helvetica",
			fontSize=30
		}

		text_i_agree = display.newText(text_i_agree);
		text_i_agree:setFillColor( 81/255 , 81/255 , 81/255  )
		text_i_agree.anchorX = 0
		text_i_agree.anchorY = 0
		displayGroup:insert(text_i_agree)
	end



	--------------- update button begin
	local update_button = widget.newButton
	{
		label = localization.getLocalization("edit_update"),
		labelColor = { default={ 1, 1, 1 }, over={  1, 1, 1  } },
		font = "Helvetica",
		fontSize = 36,
		onEvent = touch_updateFnc,
		
		shape = "roundedRect",
		fillColor = { default={ 78/255, 184/255, 229/255}, over={ 78/255, 184/255, 229/255} },
		width = 316,
		height = 78,
		cornerRadius = 10,
		strokeColor = { default={ 0, 0, 0 }, over={ 0, 0, 0 } },
		strokeWidth =0
	}
	update_button.x = display.contentCenterX

	if(setupCountry_checkbox)then
		update_button.y = setupCountry_checkbox.y+setupCountry_checkbox.height+20
	else
		update_button.y = genderOption.y+genderOption.height+20
	end

	update_button.anchorX=0.5
	update_button.anchorY=0
	displayGroup:insert(update_button)
	--set next field
	textField_password:nextTextFieldFocus(textField_confirmPassword, nil)
	textField_confirmPassword:nextTextFieldFocus(profile_textField_name, nil)
	




	--------------- update button end
	-- the following 2 variables are for calculating the properties of the edit area
	local editAreaCenter = (text_profile.y + text_profile.contentHeight * (1 - text_profile.anchorY)) - 50

	-- local back_button = widget.newButton
	-- {
	-- 	defaultFile = "Image/RegisterPage/backButton.png",
	-- 	overFile = "Image/RegisterPage/backButton.png",
	-- 	onEvent = goBackSettingScene,
	-- }
	-- back_button.x = 35
	-- back_button.y = editAreaCenter - display.contentHeight * 0.5 + 90
	-- back_button.anchorX=0
	-- displayGroup:insert(back_button)
	local back_button = display.newText(localization.getLocalization("post_back"), 35, editAreaCenter - display.contentHeight * 0.5 + 90, "Helvetica", 32)
	back_button.anchorX=0
	back_button:setFillColor(0.4)
	back_button:addEventListener("touch", goBackSettingScene)
	displayGroup:insert(back_button)

	local text_title_updateInfo_property =
	{
		text = localization.getLocalization("edit_updateInfo"), 
		x = display.contentWidth * 0.5,
		y = back_button.y,
		font = "Helvetica",
		fontSize=40
	}
	local editUserTitle = display.newText(text_title_updateInfo_property)
	editUserTitle:setFillColor( 78/255, 184/255, 229/255 )
	displayGroup:insert(editUserTitle)

	scrollView:insert(displayGroup)
	scrollView:setScrollHeight(displayGroup.y+displayGroup.height+100 )
	displayGroup.y = display.contentHeight * 0.5 - editAreaCenter
	displayGroup.anchorX = 0.5
	displayGroup.anchorY = 0.5
	sceneGroup:insert(scrollView)
	
	email_grayBackground:toFront()
	
	--load data
	if(userData)then
		if(userData.email)then
			email_textField.text = userData.email
		end
		if(userData.name)then
			profile_textField_name.text = userData.name
		end
		year, month, day = nil, nil, nil
		if(userData.dateOfBirth)then
			local tempYear = tonumber(string.sub(userData.dateOfBirth,1,4))
			local tempMonth = tonumber(string.sub(userData.dateOfBirth,6,7))
			local tempDay = tonumber(string.sub(userData.dateOfBirth,9,10))
			if ((tempYear > 0) and (tempMonth > 0) and (tempDay > 0)) then
				year, month, day = tempYear, tempMonth, tempDay
				text_birthday.text = day.."/"..tostring(MONTH_ARRAY[month]).."/"..year
			end
		end
	end
	
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