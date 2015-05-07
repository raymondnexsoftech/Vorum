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
require ( "DebugUtility.Debug" )
local projectObjectSetting = require( "Setting.ProjectObjectSetting" )
local localization = require("Localization.Localization")
local headerView = require( "ProjectObject.HeaderView" )
local headTabFnc = require( "ProjectObject.HeadTabFnc" )
local global = require( "GlobalVar.global" )
---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local LEFTPADDING = 20
local CONTENTWIDTH = display.contentWidth-LEFTPADDING*2
---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
--Create a storyboard scene for this module
local scene = storyboard.newScene()
local sceneGroup --scene.group
local headerObjects
local header
local tabbar
local scrollView


local contentText = "Vorum is a voting forum. Opinions are gathered to generate meaning insight."
local contentText2 = "Vorum is the 1st ever profit sharing mobile App. Any users can get a chance to share the profit from the sale of meaning insight."
local contentText3 = "Find out more on:"
local contentText4 = "Facebook: "
local contentText5 = "Email: "
local facebookText = "www.facebook.com/VorumApp"
local facebookLink = "https://m.facebook.com/VorumApp"
local emailText = "Founder@VorumApp.com"
local emailLink = ""

local emailOptions =
{
	to = emailText,
	-- subject = "My High Score",
	-- body = "I scored over 9000!!! Can you do better?",
	-- attachment = { baseDir=system.DocumentsDirectory,
	-- filename="Screenshot.png", type="image" },
}
--obj
local content
local content2
local content3
local content4 
local text_facebook
local content5
local text_email
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
local function openFacebook(event)
	local phase = event.phase
    if( phase == "began" ) then
	elseif ( phase == "moved" ) then
        local dy = math.abs( ( event.y - event.yStart ) )
        if ( dy > 10 ) then
            scrollView:takeFocus( event )
        end
    elseif ( phase == "ended" or phase == "cancelled" ) then
		system.openURL( facebookLink )
	end
    return true
end
local function openEmail(event)
	local phase = event.phase
    if( phase == "began" ) then
	elseif ( phase == "moved" ) then
        local dy = math.abs( ( event.y - event.yStart ) )
        if ( dy > 10 ) then
            scrollView:takeFocus( event )
        end
    elseif ( phase == "ended" or phase == "cancelled" ) then
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
	headerObjects = headerView.createVorumHeaderObjects("aboutVorum")
	header = headTabFnc.changeHeaderView(headerObjects,global.newSceneHeaderOption)
	tabbar = headTabFnc.getTabbar()
	if (tabbar == nil) then
		tabbar = headTabFnc.createNewTabbar(projectObjectSetting.tabbar)
	end
	headTabFnc.setDisplayStatus(true)
	--
	scrollView = widget.newScrollView
	{
		top = 0,
		left = 0,
		width = display.contentWidth,
		height = display.contentHeight,
		-- bottomPadding = 100,
		backgroundColor = { 243/255,243/255,243/255 },
		horizontalScrollDisabled = true,
		verticalScrollDisabled = false,
		hideScrollBar = true,
	}
	content =
	{
		text = contentText,
		x = LEFTPADDING,
		y = 180,
		width = CONTENTWIDTH,
		height = 0, 
		font = "Helvetica",
		fontSize=30
	}
	content = display.newText(content);
	content:setFillColor(81/255, 81/255, 81/255 )
	content.anchorX=0
	content.anchorY=0
	scrollView:insert(content)
	sceneGroup:insert(scrollView)
	
	content2 =
	{
		text = contentText2,
		x = LEFTPADDING,
		y = content.y+content.height,
		width = CONTENTWIDTH,
		height = 0, 
		font = "Helvetica",
		fontSize=30
	}
	content2 = display.newText(content2);
	content2:setFillColor(81/255, 81/255, 81/255 )
	content2.anchorX=0
	content2.anchorY=0
	scrollView:insert(content2)
	sceneGroup:insert(scrollView)
	
	content3 =
	{
		text = contentText3,
		x = LEFTPADDING,
		y = content2.y+content2.height,
		width = CONTENTWIDTH,
		height = 0, 
		font = "Helvetica",
		fontSize=30
	}
	content3 = display.newText(content3);
	content3:setFillColor(81/255, 81/255, 81/255 )
	content3.anchorX=0
	content3.anchorY=0
	scrollView:insert(content3)
	sceneGroup:insert(scrollView)
	
	content4 =
	{
		text = contentText4,
		x = LEFTPADDING,
		y = content3.y+content3.height,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=30
	}
	content4 = display.newText(content4);
	content4:setFillColor(81/255, 81/255, 81/255 )
	content4.anchorX=0
	content4.anchorY=0
	scrollView:insert(content4)
	sceneGroup:insert(scrollView)
	
	text_facebook = 
	{
		text = facebookText,
		x = content4.x+content4.width,
		y = content4.y,
		width = CONTENTWIDTH-content4.width,
		height = 0, 
		font = "Helvetica",
		fontSize=30
	}
	text_facebook = display.newText(text_facebook);
	text_facebook:setFillColor(15/255, 114/255, 218/255)
	text_facebook.anchorX=0
	text_facebook.anchorY=0
	text_facebook:addEventListener("touch",openFacebook)
	scrollView:insert(text_facebook)
	sceneGroup:insert(scrollView)
	
	
	content5 =
	{
		text = contentText5,
		x = LEFTPADDING,
		y = content4.y+content4.height,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=30
	}
	content5 = display.newText(content5);
	content5:setFillColor(81/255, 81/255, 81/255 )
	content5.anchorX=0
	content5.anchorY=0
	scrollView:insert(content5)
	sceneGroup:insert(scrollView)
	
	text_email = 
	{
		text = emailText,
		x = content5.x+content5.width,
		y = content5.y,
		width = CONTENTWIDTH-content5.width,
		height = 0, 
		font = "Helvetica",
		fontSize=30
	}
	text_email = display.newText(text_email)
	text_email:setFillColor(15/255, 114/255, 218/255)
	text_email.anchorX=0
	text_email.anchorY=0
	text_email:addEventListener("touch",openEmail)
	scrollView:insert(text_email)
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