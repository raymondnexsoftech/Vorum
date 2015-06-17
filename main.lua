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
require ( "SystemUtility.Debug" )
local global = require( "GlobalVar.global" )
local saveData = require( "SaveData.SaveData" )
local networkFunction = require("Network.newNetworkFunction")
local json = require( "json" )
local localization = require("Localization.Localization")
local notifications = require( "plugin.notifications" )
local headTabFnc = require( "ProjectObject.HeadTabFnc" )
local noticeBadge = require("ProjectObject.NoticeBadge")

local imageViewer = require("Module.ImageViewer")
local catScreen = require("ProjectObject.CatScreen")
local searchScreen = require("ProjectObject.SearchScreen")
local functionalOption = require("Module.FunctionalOption")
local addPhotoFnc = require("Function.addPhoto")
local tagSelectionFnc = require("Function.tagSelectionFnc")

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
local isOriginalDesign = saveData.load(global.isOrigDesignPath)
if ((isOriginalDesign ~= nil) and (isOriginalDesign.isOriginalDesign ~= nil)) then
	global.isOriginalDesign = isOriginalDesign.isOriginalDesign
end

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

local function notificationListener( event, isRestartApp )
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
			if (isRestartApp) then
				local loadingDataOption = {}
				loadingDataOption.params = {}
				loadingDataOption.params.isNotic = true
				storyboard.gotoScene("Scene.LoadingScene",loadingDataOption)
			else
				local curSceneName = storyboard.getCurrentSceneName()
				if ((curSceneName ~= "Scene.LoginPageScene") and (curSceneName ~= "Scene.RegisterPageScene")) then
					header = headTabFnc.getHeader()
					tabbar = headTabFnc.getTabbar()
					storyboard.hideOverlay()
					timer.performWithDelay(1 ,function(event)
						stage = display.getCurrentStage()
						if (header) then
							stage:insert( header )
						end
						if (tabbar) then
							stage:insert( tabbar )
							tabbar:setSelected(global.currentSceneNumber)  
						end
						imageViewer.forceExit()
						catScreen.hide()
						searchScreen.forceExit()
						functionalOption.hide()
						addPhotoFnc.forceExit()
						tagSelectionFnc.forceExit()
						storyboard.gotoScene("Scene.NoticeTabScene",loadingDataOption)
					end)
				end
			end
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

	notificationListener( launchArgs.notification, true )
	
end

local function simulatedReceiveNotification(event)
	if event.phase == "ended" then
		local event = {}
		event.type = "remote"
		event.applicationState = "inactive"
		notificationListener( event, false )
	end
	return true
end
local simulatedReceiveNotificationBtn = display.newRect(300, 0, 100, 100)
simulatedReceiveNotificationBtn:addEventListener("touch", simulatedReceiveNotification)
timer.performWithDelay(100, function() simulatedReceiveNotificationBtn:toFront(); end , 0)

storyboard.gotoScene("Scene.LoadingScene")
