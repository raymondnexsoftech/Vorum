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
local LEFTPADDING = 20
local CONTENTWIDTH = display.contentWidth-LEFTPADDING*2
local LINESPACE = 20
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


local facebookText = "www.facebook.com/VorumApp"
local facebookLink = "https://m.facebook.com/VorumApp"
local emailText = "Founder@VorumApp.com"
local emailLink = "founder@vorumapp.com"
local websiteText = "http://www.vorumapp.com/"
local websiteLink = "http://www.vorumapp.com/"


local emailOptions =
{
	to = emailLink,
	-- subject = "My High Score",
	-- body = "I scored over 9000!!! Can you do better?",
	-- attachment = { baseDir=system.DocumentsDirectory,
	-- filename="Screenshot.png", type="image" },
}
--obj
local text_appIntro
local text_appDesc
local text_contactWay
local text_facebookIntro 
local text_facebook
local text_emailIntro
local text_email
local text_webisteIntro
local text_website
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

local function openWebsite(event)
	local phase = event.phase
    if( phase == "began" ) then
	elseif ( phase == "moved" ) then
        local dy = math.abs( ( event.y - event.yStart ) )
        if ( dy > 10 ) then
            scrollView:takeFocus( event )
        end
    elseif ( phase == "ended" or phase == "cancelled" ) then
		system.openURL( websiteLink )
	end
    return true
end

local function combineAboutString(aboutStringKey)
	local aboutTextStr = ""
	local strIdx = 1
	local curStr = localization.getLocalization(aboutStringKey, strIdx)
	while (true) do
		aboutTextStr = aboutTextStr .. curStr
		strIdx = strIdx + 1
		curStr = localization.getLocalization(aboutStringKey, strIdx)
		if ((curStr ~= nil) and (curStr ~= "")) then
			curStr = "\n\n" .. curStr
		else
			return aboutTextStr
		end
	end
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
	sceneGroup:insert(scrollView)

	local aboutText1Str = combineAboutString("aboutVorumDesc1")
	local aboutText1Option = {
								text = aboutText1Str,
								x = LEFTPADDING,
								y = 150,
								width = CONTENTWIDTH,
								height = 0, 
								font = "Helvetica",
								fontSize=30
							}
	local aboutText1 = display.newText(aboutText1Option);
	aboutText1:setFillColor(81/255, 81/255, 81/255 )
	aboutText1.anchorX=0
	aboutText1.anchorY=0
	scrollView:insert(aboutText1)

	local websiteDisplayTextOption = {
									text = websiteText .. "\n",
									x = LEFTPADDING,
									y = aboutText1.y + aboutText1.contentHeight,
									width = CONTENTWIDTH,
									height = 0, 
									font = "Helvetica",
									fontSize=30
								}
	local websiteDisplayText = display.newText(websiteDisplayTextOption);
	websiteDisplayText:setFillColor(15/255, 114/255, 218/255)
	websiteDisplayText.anchorX=0
	websiteDisplayText.anchorY=0
	websiteDisplayText:addEventListener("touch",openWebsite)
	scrollView:insert(websiteDisplayText)

	local aboutText2Str = combineAboutString("aboutVorumDesc2")
	local aboutText2Option = {
								text = aboutText2Str,
								x = LEFTPADDING,
								y = websiteDisplayText.y + websiteDisplayText.contentHeight,
								width = CONTENTWIDTH,
								height = 0, 
								font = "Helvetica",
								fontSize=30
							}
	local aboutText2 = display.newText(aboutText2Option);
	aboutText2:setFillColor(81/255, 81/255, 81/255 )
	aboutText2.anchorX=0
	aboutText2.anchorY=0
	scrollView:insert(aboutText2)

	local emailDisplayTextOption = {
										text = emailText .. "\n",
										x = LEFTPADDING,
										y = aboutText2.y + aboutText2.contentHeight,
										width = CONTENTWIDTH,
										height = 0, 
										font = "Helvetica",
										fontSize=30
									}
	local emailDisplayText = display.newText(emailDisplayTextOption)
	emailDisplayText:setFillColor(15/255, 114/255, 218/255)
	emailDisplayText.anchorX=0
	emailDisplayText.anchorY=0
	emailDisplayText:addEventListener("touch",openEmail)
	scrollView:insert(emailDisplayText)

	scrollView:setScrollHeight(emailDisplayText.y + emailDisplayText.contentHeight + tabbar.height)

	-- text_appIntro =
	-- {
	-- 	text = localization.getLocalization("aboutVorum_appIntro"),
	-- 	x = LEFTPADDING,
	-- 	y = 180,
	-- 	width = CONTENTWIDTH,
	-- 	height = 0, 
	-- 	font = "Helvetica",
	-- 	fontSize=30
	-- }
	-- text_appIntro = display.newText(text_appIntro);
	-- text_appIntro:setFillColor(81/255, 81/255, 81/255 )
	-- text_appIntro.anchorX=0
	-- text_appIntro.anchorY=0
	-- scrollView:insert(text_appIntro)
	
	-- text_appDesc =
	-- {
	-- 	text = localization.getLocalization("aboutVorum_appDesc"),
	-- 	x = LEFTPADDING,
	-- 	y = text_appIntro.y+text_appIntro.height+LINESPACE,
	-- 	width = CONTENTWIDTH,
	-- 	height = 0, 
	-- 	font = "Helvetica",
	-- 	fontSize=30
	-- }
	-- text_appDesc = display.newText(text_appDesc);
	-- text_appDesc:setFillColor(81/255, 81/255, 81/255 )
	-- text_appDesc.anchorX=0
	-- text_appDesc.anchorY=0
	-- scrollView:insert(text_appDesc)
	
	
	-- text_contactWay =
	-- {
	-- 	text = localization.getLocalization("aboutVorum_contactWay"),
	-- 	x = LEFTPADDING,
	-- 	y = text_appDesc.y+text_appDesc.height+LINESPACE,
	-- 	width = CONTENTWIDTH,
	-- 	height = 0, 
	-- 	font = "Helvetica",
	-- 	fontSize=30
	-- }
	-- text_contactWay = display.newText(text_contactWay);
	-- text_contactWay:setFillColor(81/255, 81/255, 81/255 )
	-- text_contactWay.anchorX=0
	-- text_contactWay.anchorY=0
	-- scrollView:insert(text_contactWay)
	
	-- text_facebookIntro =
	-- {
	-- 	text = localization.getLocalization("aboutVorum_facebookContact"),
	-- 	x = LEFTPADDING,
	-- 	y = text_contactWay.y+text_contactWay.height+LINESPACE,
	-- 	width = 0,
	-- 	height = 0, 
	-- 	font = "Helvetica",
	-- 	fontSize=30
	-- }
	-- text_facebookIntro = display.newText(text_facebookIntro);
	-- text_facebookIntro:setFillColor(81/255, 81/255, 81/255 )
	-- text_facebookIntro.anchorX=0
	-- text_facebookIntro.anchorY=0
	-- scrollView:insert(text_facebookIntro)
	
	-- text_facebook = 
	-- {
	-- 	text = facebookText,
	-- 	x = text_facebookIntro.x+text_facebookIntro.width,
	-- 	y = text_facebookIntro.y,
	-- 	width = CONTENTWIDTH-text_facebookIntro.width,
	-- 	height = 0, 
	-- 	font = "Helvetica",
	-- 	fontSize=30
	-- }
	-- text_facebook = display.newText(text_facebook);
	-- text_facebook:setFillColor(15/255, 114/255, 218/255)
	-- text_facebook.anchorX=0
	-- text_facebook.anchorY=0
	-- text_facebook:addEventListener("touch",openFacebook)
	-- scrollView:insert(text_facebook)
	
	-- text_emailIntro =
	-- {
	-- 	text = localization.getLocalization("aboutVorum_emailContact"),
	-- 	x = LEFTPADDING,
	-- 	y = text_facebookIntro.y+text_facebookIntro.height+LINESPACE,
	-- 	width = 0,
	-- 	height = 0, 
	-- 	font = "Helvetica",
	-- 	fontSize=30
	-- }
	-- text_emailIntro = display.newText(text_emailIntro);
	-- text_emailIntro:setFillColor(81/255, 81/255, 81/255 )
	-- text_emailIntro.anchorX=0
	-- text_emailIntro.anchorY=0
	-- scrollView:insert(text_emailIntro)
	
	-- text_email = 
	-- {
	-- 	text = emailText,
	-- 	x = text_emailIntro.x+text_emailIntro.width,
	-- 	y = text_emailIntro.y,
	-- 	width = CONTENTWIDTH-text_emailIntro.width,
	-- 	height = 0, 
	-- 	font = "Helvetica",
	-- 	fontSize=30
	-- }
	-- text_email = display.newText(text_email)
	-- text_email:setFillColor(15/255, 114/255, 218/255)
	-- text_email.anchorX=0
	-- text_email.anchorY=0
	-- text_email:addEventListener("touch",openEmail)
	-- scrollView:insert(text_email)


	-- text_webisteIntro =
	-- {
	-- 	text = localization.getLocalization("aboutVorum_websiteContact"),
	-- 	x = LEFTPADDING,
	-- 	y = text_emailIntro.y+text_emailIntro.height+LINESPACE,
	-- 	width = 0,
	-- 	height = 0, 
	-- 	font = "Helvetica",
	-- 	fontSize=30
	-- }
	-- text_webisteIntro = display.newText(text_webisteIntro);
	-- text_webisteIntro:setFillColor(81/255, 81/255, 81/255 )
	-- text_webisteIntro.anchorX=0
	-- text_webisteIntro.anchorY=0
	-- scrollView:insert(text_webisteIntro)

	-- text_website = 
	-- {
	-- 	text = websiteText,
	-- 	x = text_webisteIntro.x+text_webisteIntro.width,
	-- 	y = text_webisteIntro.y,
	-- 	width = CONTENTWIDTH-text_webisteIntro.width,
	-- 	height = 0, 
	-- 	font = "Helvetica",
	-- 	fontSize=30
	-- }
	-- text_website = display.newText(text_website);
	-- text_website:setFillColor(15/255, 114/255, 218/255)
	-- text_website.anchorX=0
	-- text_website.anchorY=0
	-- text_website:addEventListener("touch",openWebsite)
	-- scrollView:insert(text_website)

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