---------------------------------------------------------------
-- TemplateScene.lua
--
-- Template for Scene
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
--local resDir = (...):match("(.-)[^%.]+$")

-- Local Constant Setting
local LOCAL_SETTINGS = {
						NAME = "SettingScene",			-- Scene name to show in console
						RES_DIR = "",					-- Common resource directory for scene
						DOC_DIR = "",					-- Common document directory for scene
						}

---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------
local storyboard = require ( "storyboard" )
local widget = require ( "widget" )
require ( "SystemUtility.Debug" )
local projectObjectSetting = require( "Setting.ProjectObjectSetting" )
local localization = require("Localization.Localization")
local headerView = require( "ProjectObject.HeaderView" )
local headTabFnc = require( "ProjectObject.HeadTabFnc" )
local global = require( "GlobalVar.global" )
---------------------------------------------------------------
-- Constants
---------------------------------------------------------------

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
--Create a storyboard scene for this module
local scene = storyboard.newScene()
local sceneGroup --scene.group
local phoneNumberString = "+852-52-9382-57"
local phoneNumber = "+852-52-9382-57"
local email = "founder@vorumapp.com"

local emailOptions =
{
	to = email,
	-- subject = "My High Score",
	-- body = "I scored over 9000!!! Can you do better?",
	-- attachment = { baseDir=system.DocumentsDirectory,
	-- filename="Screenshot.png", type="image" },
}
---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
-- Function for back button
local function onBackButtonPressed()
	storyboard.gotoScene("Scene.SettingTabScene", global.backSceneOption)
end


local function phoneCallFnc(event)
	if(event.phase=="ended" or event.phase =="cancelled")then
		local alertString = string.format(localization.getLocalization("contact_phoneTo"), phoneNumberString)
		native.showAlert(alertString,
						alertString,
						{localization.getLocalization("yes"), localization.getLocalization("no")},
						function(e)
							if (e.index == 1) then
								system.openURL("tel:"..phoneNumber)
							end
						end)
	end
	return true
end

local function sendEmailFnc(event)
	if(event.phase=="ended" or event.phase =="cancelled")then
		native.showPopup("mail", emailOptions)
	end
	return true
end

-- Create the scene
function scene:createScene( event )
	debugLog( "Creating " .. LOCAL_SETTINGS.NAME .. " Scene")
	sceneGroup = self.view
	display.setDefault("background",243/255,243/255,243/255)
	-- Place the code below
	--header
	local headerObjects = headerView.createVorumHeaderObjects("contact")
	local header = headTabFnc.changeHeaderView(headerObjects,global.newSceneHeaderOption)
	local tabbar = headTabFnc.getTabbar()
	if (tabbar == nil) then
		tabbar = headTabFnc.createNewTabbar(projectObjectSetting.tabbar)
	end
	headTabFnc.setDisplayStatus(true)
	--
	--background
	-- local background = display.newRect( display.contentCenterX, display.contentCenterY, 526, 556 )	
	-- background:setFillColor(1)
	local background = display.newImage("Image/ContactScene/background.png")
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	background.anchorX=0.5
	background.anchorY=0.5
	sceneGroup:insert(background)
	
	
	local background_beginY = background.y-background.anchorY*background.height
	
	local text_partnership =
	{
		text = localization.getLocalization("contact_partnership"),
		x = display.contentCenterX,
		y = background_beginY+70,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=40
	}
	text_partnership = display.newText(text_partnership);
	text_partnership:setFillColor(78/255, 184/255, 229/255 )
	text_partnership.anchorX=0.5
	text_partnership.anchorY=0
	sceneGroup:insert(text_partnership)

	local content =
	{
		text = localization.getLocalization("contact_content"),
		x = display.contentCenterX,
		y = text_partnership.y+text_partnership.height+32,
		width = 420,
		height = 205, 
		font = "Helvetica",
		fontSize=30
	}
	content = display.newText(content);
	content:setFillColor(81/255, 81/255, 81/255 )
	content.anchorX=0.5
	content.anchorY=0
	sceneGroup:insert(content)
	
	local underline = display.newLine(90,background_beginY+330,display.contentWidth-90,background_beginY+330)
	underline:setStrokeColor( 149/255,149/255,149/255  )
	underline.strokeWidth = 2
	underline.anchorX=0
	underline.anchorY=0
	underline.alpha=0.5
	sceneGroup:insert(underline)
	
	local underline2 = display.newLine(90,underline.y+122,display.contentWidth-90,underline.y+122)
	underline2:setStrokeColor( 149/255,149/255,149/255  )
	underline2.strokeWidth = 2
	underline2.anchorX=0
	underline2.anchorY=0
	underline2.alpha=0.5
	sceneGroup:insert(underline2)
	
	local image_phone = display.newImage("Image/ContactScene/phone.png",true)
	image_phone.x = 90
	image_phone.y = underline.y+(underline2.y-underline.y)/2
	image_phone.anchorX=0
	image_phone.anchorY=0.5
	sceneGroup:insert(image_phone)
	
	local text_phoneNumber =
	{
		text = phoneNumberString,
		x = 165,
		y = image_phone.y,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=36
	}
	text_phoneNumber = display.newText(text_phoneNumber);
	text_phoneNumber:setFillColor(15/255, 114/255, 218/255 )
	text_phoneNumber.anchorX=0
	text_phoneNumber.anchorY=0.5
	sceneGroup:insert(text_phoneNumber)
	text_phoneNumber:addEventListener( "touch", phoneCallFnc )


	local image_email = display.newImage("Image/ContactScene/email.png",true)
	image_email.x=90
	image_email.y=background_beginY+background.height-80

	image_email.anchorX=0
	image_email.anchorY=1
	sceneGroup:insert(image_email)
	
	local text_email =
	{
		text = email,
		x = 165,
		y = image_email.y,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=36
	}
	text_email = display.newText(text_email);
	text_email:setFillColor(15/255, 114/255, 218/255)
	text_email.anchorX=0
	text_email.anchorY=image_email.anchorY
	sceneGroup:insert(text_email)
	text_email:addEventListener( "touch", sendEmailFnc )
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