---------------------------------------------------------------
-- main.lua
--
-- program start here
---------------------------------------------------------------

---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------
local storyboard = require ( "storyboard" )
require ( "SystemUtility.Debug" )

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

-- storyboard.gotoScene("Scene.SplashScreen")
storyboard.gotoScene("Scene.VorumTabScene")


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
