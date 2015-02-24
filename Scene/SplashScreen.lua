---------------------------------------------------------------
-- SplashScreen.lua
--
-- SplashScreen
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
--local resDir = (...):match("(.-)[^%.]+$")

-- Local Constant Setting
local LOCAL_SETTINGS = {
						NAME = "SplashScreen",			-- Scene name to show in console
						RES_DIR = "",					-- Common resource directory for scene
						DOC_DIR = "",					-- Common document directory for scene
						}

---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------
local storyboard = require ( "storyboard" )
local widget = require ( "widget" )
require ( "SystemUtility.Debug" )

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
--Create a storyboard scene for this module
local scene = storyboard.newScene()

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
-- Function for back button
local function onBackButtonPressed()
end

-- Create the scene
function scene:createScene( event )
	debugLog( "Creating " .. LOCAL_SETTINGS.NAME .. " Scene")
	local group = self.view

	-- Place the code below
end

local function onKeyEvent( event )
	if event.phase == "up" and event.keyName == "back" then
		onBackButtonPressed()
	end
	return true
end

function scene:enterScene( event )
	debugLog( "Entering " .. LOCAL_SETTINGS.NAME .. " Scene")

	-- adding check system key event
	Runtime:addEventListener( "key", onKeyEvent )

	-- remove previous scene's view
--	storyboard.purgeScene( lastScene )
	storyboard.purgeAll()

	-- Place the code below
end

-- Called when scene is about to move offscreen:
function scene:exitScene()
	debugLog( "Exiting " .. LOCAL_SETTINGS.NAME .. " Scene")

	-- removing check system key event
	Runtime:removeEventListener( "key", onKeyEvent )

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

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

---------------------------------------------------------------------------------

return scene