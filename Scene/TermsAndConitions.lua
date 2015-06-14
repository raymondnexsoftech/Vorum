---------------------------------------------------------------
-- TemplateScene.lua
--
-- Template for Scene
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
--local resDir = (...):match("(.-)[^%.]+$")

-- Local Constant Setting
local LOCAL_SETTINGS = {
						NAME = "TermsAndConitions",			-- Scene name to show in console
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
---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local CONTENT_TEXT = "ALLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL"
---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
--Create a storyboard scene for this module
local scene = storyboard.newScene()
local sceneGroup --scene.group

--vars
local scrollViewBeginX
local scrollViewEndX
local scrollViewBeginY
local scrollViewEneY
--obj
local background
local contentBackground
local scrollView
local scrollViewBorder
local headerTitle
local content
local confirmButton
---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
-- Function for back button
local function onBackButtonPressed()
end
local function confirmButtonFnc(event)
	if(event.phase=="ended" or event.phase=="cancelled")then
		transition.to(background,{time=400,alpha=0})
		storyboard.hideOverlay( "slideDown", 400 )
	end
	return true
end
-- Create the scene
function scene:createScene( event )
	debugLog( "Creating " .. LOCAL_SETTINGS.NAME .. " Scene")
	sceneGroup = self.view
	display.setDefault("background",0,0,0)
	
	background = display.newRect( display.contentCenterX, 0, display.contentWidth, display.contentHeight*2 )
	background:setFillColor(0,0,0 )
	background.alpha=0
	background.anchorX=0.5
	background.anchorY=0.5
	sceneGroup:insert(background)
	
	
	contentBackground = display.newRoundedRect( display.contentCenterX, display.contentHeight*0.1, display.contentWidth*0.9, display.contentHeight*0.8, 10 )
	contentBackground:setFillColor( 1,1,1 )
	contentBackground:setStrokeColor(  187/255, 235/255, 1 )
	contentBackground.strokeWidth = 8
	contentBackground.anchorX=0.5
	contentBackground.anchorY=0
	sceneGroup:insert(contentBackground)
	
	headerTitle = {
		text = localization.getLocalization("termsAndConitions_title"), 
		x = display.contentCenterX,
		y = contentBackground.y+10,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize= 46,
	}

	headerTitle = display.newText(headerTitle);
	headerTitle:setFillColor( 78/255, 184/255, 229/255 )
	headerTitle.anchorX=0.5
	headerTitle.anchorY=0
	sceneGroup:insert(headerTitle)
	
	scrollView = widget.newScrollView
	{
		x = display.contentCenterX,
		y = headerTitle.y+headerTitle.height+10,
		width = contentBackground.width*0.9,
		height = contentBackground.height*0.8,
		backgroundColor = {1,1,1},
		horizontalScrollDisabled = true,
		verticalScrollDisabled = false,
		hideBackground = true,
		hideScrollBar = false,
	}
	scrollView.anchorX = 0.5
	scrollView.anchorY = 0
	sceneGroup:insert(scrollView)
	
	scrollViewBeginX = scrollView.x-scrollView.width/2
	scrollViewEndX = scrollViewBeginX+scrollView.width
	scrollViewBeginY = scrollView.y
	scrollViewEneY = scrollViewBeginY + scrollView.height
	
	scrollViewBorder = display.newLine( scrollViewBeginX, scrollViewBeginY, scrollViewEndX, scrollViewBeginY )
	scrollViewBorder:append( scrollViewEndX,scrollViewEneY, scrollViewBeginX,scrollViewEneY, scrollViewBeginX,scrollViewBeginY)
	scrollViewBorder:setStrokeColor( 78/255, 184/255, 229/255 )
	scrollViewBorder.strokeWidth = 4
	sceneGroup:insert(scrollViewBorder)
	
	-- content = {
	-- 	text = CONTENT_TEXT, 
	-- 	x = 0,
	-- 	y = 10,
	-- 	width = scrollView.width,
	-- 	height = 0, 
	-- 	font = "Helvetica",
	-- 	fontSize= 30,
	-- }
	-- content = display.newText(content)
	-- content.anchorX=0
	-- content.anchorY=0
	-- content:setFillColor(0,0,0)
	-- scrollView:insert(content)
	
	local lastTextObj
	local tcSideOffset = 10
	local fontSize = 30
	local curY = 10
	local strIdx = 1
	local curStr = localization.getLocalization("TermsAndCondition", strIdx)
	while ((curStr ~= nil) and (curStr ~= "")) do
		local aboutTextOption = {
									text = curStr,
									x = tcSideOffset,
									y = curY,
									width = scrollView.width - (tcSideOffset * 2),
									height = 0, 
									font = "Helvetica",
									fontSize = fontSize
								}
		lastTextObj = display.newText(aboutTextOption)
		lastTextObj:setFillColor(0)
		lastTextObj.anchorX=0
		lastTextObj.anchorY=0
		scrollView:insert(lastTextObj)
		strIdx = strIdx + 1
		curStr = localization.getLocalization("TermsAndCondition", strIdx)
		curY = curY + lastTextObj.contentHeight + fontSize
	end
	scrollView:setScrollHeight(lastTextObj.y + lastTextObj.contentHeight)

	confirmButton = widget.newButton
	{
		label = localization.getLocalization("register_confirm"),
		labelColor = { default={ 1, 1, 1 }, over={  1, 1, 1  } },
		font = "Helvetica",
		fontSize = 36,
		onEvent = confirmButtonFnc,
		
		shape = "roundedRect",
		fillColor = { default={  251/255, 175/255, 93/255}, over={ 251/255, 175/255, 93/255} },
		width = 316,
		height = 78,
		cornerRadius = 10,
		strokeColor = { default={ 0, 0, 0 }, over={ 0, 0, 0 } },
		strokeWidth =0
	}
	confirmButton.x = display.contentCenterX
	confirmButton.y = scrollView.y+scrollView.height+10
	confirmButton.anchorX=0.5
	confirmButton.anchorY=0
	sceneGroup:insert(confirmButton)
	
	-- if(confirmButton.y+confirmButton.height>contentBackground.y+contentBackground.height)then
		-- scrollView.height = contentBackground.height*0.7
		-- confirmButton.y = scrollView.y+scrollView.height+10
	-- end
	contentBackground.height = confirmButton.y+confirmButton.height-contentBackground.y+10
	transition.to(background,{time=400,alpha=0.5})
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