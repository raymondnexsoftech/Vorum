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
local localization = require("Localization.Localization")
local notifications = require( "plugin.notifications" )
local headTabFnc = require( "ProjectObject.HeadTabFnc" )
local noticeBadge = require("ProjectObject.NoticeBadge")
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


--setting language
local langSetting = saveData.load(global.languageDataPath)

if(langSetting)then
	if(langSetting.locale)then
		localization.setLocale(langSetting.locale)
	end
end


local function onSceneTransitionKeyEvent(event)
	if event.phase == "up" and event.keyName == "back" then
	end
	return true
end
Runtime:addEventListener( "key", onSceneTransitionKeyEvent )

-- Notification
local function updateNoticeBadge(customBadgeNum)
	local badgeNum
	if (customBadgeNum) then
		badgeNum = customBadgeNum
	else
		badgeNum = native.getProperty("applicationIconBadgeNumber")
	end
	if (badgeNum == nil) then
		badgeNum = 0
	end
	tabbar = headTabFnc.getTabbar()
	noticeBadge.setBadge(tabbar, badgeNum)
end

local function notificationListener( event )
	if ( event.type == "remote" ) then
		if (system.getInfo("platformName") == "Android") then
			local badgeNum
			if ((event ~= nil) and (event.custom ~= nil) and (event.custom.badge ~= nil)) then
				badgeNum = tonumber(event.custom.badge)
			end
			updateNoticeBadge(badgeNum)
		else
			if (event.badge) then
				native.setProperty("applicationIconBadgeNumber", event.badge)
				native.setProperty("applicationIconBadgeNumber", event.badge)
			end
			updateNoticeBadge()
		end
		if (event.applicationState == "inactive") then
			storyboard.gotoScene("Scene.NoticeTabScene")
		end
		-- for k, v in pairs(event) do
		-- 	if (k == "custom") then
		-- 		print(k .. ":")
		-- 		for k2, v2 in pairs(v) do
		-- 			print(" ", k2, v2)
		-- 		end
		-- 	else
		-- 		print(k, v)
		-- 	end
		-- end
		--handle the push notification
	elseif ( event.type == "remoteRegistration" ) then
		-- print("reg push:", tostring(event.token))
		
		local deviceToken = event.token
		networkFunction.setPushDeviceToken(deviceToken)

	elseif ( event.type == "local" ) then
	--handle the local notification
	end
end

--The notification Runtime listener should be handled from within "main.lua"
Runtime:addEventListener( "notification", notificationListener )

-- Check Badge Listener
local function onSystemEventCheckBadge(event)
--	print( "System event name and type: " .. event.name, event.type )
	if (event.type == "applicationStart") then
	elseif (event.type == "applicationExit") then
	elseif (event.type == "applicationSuspend") then
	elseif (event.type == "applicationResume") then
		notifications.cancelNotification()
		updateNoticeBadge()
	end
end
Runtime:addEventListener( "system", onSystemEventCheckBadge )

if ( launchArgs and launchArgs.notification ) then

	notificationListener( launchArgs.notification )
	
end



storyboard.gotoScene("Scene.LoadingScene")
