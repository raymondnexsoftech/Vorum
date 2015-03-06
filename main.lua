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
local networkFunction = require("Network.NetworkFunction")

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------

---------------------------------------------------------------
-- program start
---------------------------------------------------------------

-- display.setStatusBar( display.HiddenStatusBar )
display.setStatusBar( display.TranslucentStatusBar )

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
		networkFunction.pushInstallation(deviceToken, pushInstallationListener)

	elseif ( event.type == "local" ) then
		--handle the local notification
	end
end

--The notification Runtime listener should be handled from within "main.lua"
Runtime:addEventListener( "notification", notificationListener )

if ( launchArgs and launchArgs.notification ) then
	notificationListener( launchArgs.notification )
else
	storyboard.gotoScene("Scene.VorumTabScene")
end



-- Uncomment to monitor app's lua memory/texture memory usage in terminal...

-- local function garbagePrinting()
-- 	collectgarbage("collect")
-- 	local memUsage_str = string.format( "memUsage = %.3f KB", collectgarbage( "count" ) )
-- 	print( memUsage_str )
-- 	local texMemUsage_str = system.getInfo( "textureMemoryUsed" )
-- 	texMemUsage_str = texMemUsage_str/1000
-- 	texMemUsage_str = string.format( "texMemUsage = %.3f MB", texMemUsage_str )
-- 	print( texMemUsage_str )
-- end

-- timer.performWithDelay( 1000, garbagePrinting(), 0 )
