---------------------------------------------------------------
-- main.lua
--
-- program start here
---------------------------------------------------------------
local launchArgs = ...
---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------
local storyboard = require ( "storyboard" )
require ( "DebugUtility.Debug" )
local global = require( "GlobalVar.global" )
local saveData = require( "SaveData.SaveData" )
local networkFunction = require("Network.newNetworkFunction")
local json = require( "json" )
local loginFnc = require("Module.loginFnc")
local localization = require("Localization.Localization")
local notifications = require( "plugin.notifications" )
notifications.registerForPushNotifications()
---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local environment = system.getInfo( "environment" )
---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
local username 
local password
---------------------------------------------------------------
-- program start
---------------------------------------------------------------



-- display.setStatusBar( display.HiddenStatusBar )
display.setStatusBar( display.TranslucentStatusBar )

local function onSceneTransitionKeyEvent(event)
	if event.phase == "up" and event.keyName == "back" then
	end
	return true
end
Runtime:addEventListener( "key", onSceneTransitionKeyEvent )


local function notificationListener( event )
	if ( event.type == "remote" ) then
		for k, v in pairs(event) do
			if (k == "custom") then
				print(k .. ":")
				for k2, v2 in pairs(v) do
					print(" ", k2, v2)
				end
			else
				print(k, v)
			end
		end
		storyboard.gotoScene("Scene.NoticeTabScene")
		--handle the push notification
	elseif ( event.type == "remoteRegistration" ) then
		print("reg push:", tostring(event.token))
		
		local function pushInstallationListener(event)
			if (event.isError) then
				return false
			else
				print(event.response)
			end
		end

		local deviceToken = event.token
		networkFunction.setPushDeviceToken(deviceToken)
		--networkFunction.pushInstallation(deviceToken, pushInstallationListener)

	elseif ( event.type == "local" ) then
	--handle the local notification
	end
end

--The notification Runtime listener should be handled from within "main.lua"
Runtime:addEventListener( "notification", notificationListener )

if ( launchArgs and launchArgs.notification ) then

	local savedUserData = saveData.load(global.userDataPath)
	if(savedUserData)then
		if(savedUserData.password)then
			username = savedUserData.username--textField_username.text
			password = savedUserData.password--textField_password.text
			loginFnc.login(username,password,true)
			return true

		elseif(environment ~= "simulator" and savedUserData.authData)then
			if(savedUserData.authData.facebook)then
				if(savedUserData.authData.facebook.id and savedUserData.authData.facebook.access_token)then
					loginFnc.FBlogin(true)
					return true
				end
			end
		end
	end

	notificationListener( launchArgs.notification )

end


--setting language
local langSetting = saveData.load(global.languageDataPath)

if(langSetting)then
	if(langSetting.locale)then
		localization.setLocale(langSetting.locale)
	end
end
--check whether finish tutorial
local isFinishTutorial = saveData.load(global.tutorialSavePath)
if(isFinishTutorial)then --check user whether already finish tutorial
	----------automatically login
	local savedUserData = saveData.load(global.userDataPath)

	if(savedUserData)then
		
		if(savedUserData.password)then
			username = savedUserData.username--textField_username.text
			password = savedUserData.password--textField_password.text
			loginFnc.login(username,password,false)
			return true

		elseif(environment ~= "simulator" and savedUserData.authData)then
			if(savedUserData.authData.facebook)then
				if(savedUserData.authData.facebook.id and savedUserData.authData.facebook.access_token)then
					loginFnc.FBlogin(false)
					return true
				end
			end
		end
	end
	storyboard.gotoScene("Scene.LoginPageScene")
else
	storyboard.gotoScene("Scene.TutorialScene")
end

