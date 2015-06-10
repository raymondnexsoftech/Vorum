---------------------------------------------------------------
-- VorumTabScene.lua
--
-- Scene for Vorum Tab
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
--local resDir = (...):match("(.-)[^%.]+$")

-- Local Constant Setting
local LOCAL_SETTINGS = {
						NAME = "LoadingScene",			-- Scene name to show in console
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
local headerView = require( "ProjectObject.HeaderView" )
local headTabFnc = require( "ProjectObject.HeadTabFnc" )
local loginFnc = require("Module.loginFnc")
local global = require( "GlobalVar.global" )
local saveData = require( "SaveData.SaveData" )
local json = require("json")
---------------------------------------------------------------
-- Constants
---------------------------------------------------------------

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
local slogan = "Gather thoughts for a better world"
--Create a storyboard scene for this module
local scene = storyboard.newScene()

local enteringAppDelayTime = 300
local enteringAppOption = {
	effect="fade",
	time=300,
}

local isGoToNotice = false
---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
-- Function for back button
local function onBackButtonPressed()
end

local function animationFinishFnc() 
	--login
		
	--check whether finish tutorial
	local isFinishTutorial = saveData.load(global.tutorialSavePath)

	if(isFinishTutorial)then --check user whether already finish tutorial
		----------automatically login
		local savedUserData = saveData.load(global.userDataPath)

		if(savedUserData)then

			if(savedUserData.password)then

				loginFnc.login(savedUserData,isGoToNotice,false)

				return true

			elseif(environment ~= "simulator" and savedUserData.fb_id and savedUserData.fbToken)then
			
				loginFnc.updateFBData(savedUserData, isGoToNotice,false)

				return true
			end
		end
		storyboard.gotoScene("Scene.LoginPageScene",enteringAppOption)
	else
		storyboard.gotoScene("Scene.TutorialScene",enteringAppOption)
	end
end

-- Create the scene
function scene:createScene( event )
	--var
	if(type(event.params)=="table")then
		isGoToNotice = event.params.isNotic or false
	else
		isGoToNotice = false
	end

	SceneGroup = self.view
	local image_earth
	local image_o
	local image_v
	local image_rum
	local text_world
	local group_earth
	local group_earthV
	local group_vorum
	
	--header
	local header = headTabFnc.getHeader()
	local tabbar = headTabFnc.getTabbar()
	if (header) then
		header:toBack()
	end
	if (tabbar) then
		tabbar:toBack()
	end
	
	--set up
	debugLog( "Creating " .. LOCAL_SETTINGS.NAME .. " Scene")
	display.setStatusBar( display.HiddenStatusBar )
	display.setDefault( "background", 187/255, 235/255, 1 )	
	-- code begin
	
	image_earth = display.newImage("Image/Loading/earth.png")
	image_earth.x = display.contentCenterX
	image_earth.y = display.contentCenterY
	image_earth.anchorX = 0.5
	image_earth.anchorY = 0.5
	
	image_o = display.newImage("Image/Loading/o.png")
	image_o.x = display.contentCenterX
	image_o.y = display.contentCenterY
	image_o.anchorX = 0.5
	image_o.anchorY = 0.5
	
	group_earth = display.newGroup()
	group_earth:insert(image_earth)
	group_earth:insert(image_o)
	
	image_v = display.newImage("Image/Loading/v.png")
	image_v.x = display.contentCenterX
	image_v.y = display.contentCenterY
	image_v.anchorX = 0.5
	image_v.anchorY = 0.5
	image_v.alpha = 0
	
	group_earthV = display.newGroup()
	group_earthV:insert(group_earth)
	group_earthV:insert(image_v)
	
	
	
	transition.to(image_v,{transition=easing.inOutSine,time=500,x=image_v.x-image_v.width/2+20,alpha=1})
	transition.to(group_earth,{transition=easing.inOutSine,time=500,x=group_earth.x+group_earth.width/2-20,onComplete = function(event) 
		image_rum = display.newImage("Image/Loading/rum.png")
		image_rum.x = image_o.x+image_o.width-15
		image_rum.y = image_o.y
		image_rum.anchorX = 0
		image_rum.anchorY = 0.5
		-- image_rum.alpha = 0
		group_vorum = display.newGroup()
		group_vorum:insert(group_earthV)
		group_vorum:insert(image_rum)
		-- group_vorum.anchorChildren = true
		-- group_vorum.anchorX=0.5
		-- group_vorum.anchorY=0.5
		SceneGroup:insert(group_vorum)--add to this scene
		
		transition.to(image_earth,{delay=200,transition=easing.outSine,time=1000,alpha=0,rotation=360})
		
		transition.scaleTo(group_vorum,{delay=200,transition=easing.outSine,time=1000,xScale = 0.38,yScale = 0.38,x=10,y=display.contentCenterY-group_vorum.height,onComplete=function(event)
			local text_world_property = {
			text = slogan,
			x = display.contentCenterX,
			y = group_vorum.y+group_vorum.height,
			font = HelveticaBold,
			fontSize = 35.38
			}
			
			text_world = display.newText(text_world_property)
			text_world.anchorX = 0.5
			text_world.anchorY = 0
			text_world:setFillColor( 77/255, 184/255, 228/255 )
			text_world.alpha = 0
			
			SceneGroup:insert(text_world) --add to this scene
			transition.to(text_world,{transition=easing.outSine,time=500,alpha=1,onComplete=function()--loading finished
				timer.performWithDelay(enteringAppDelayTime,function(event)
					--animation finish
					animationFinishFnc()	
				end)
			end})
		end})
	end})
	
	

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