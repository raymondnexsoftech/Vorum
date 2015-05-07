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
local personPart = require( "ProjectObject.PersonPart" )
local saveData = require( "SaveData.SaveData" )
local json = require( "json" )
local global = require( "GlobalVar.global" )
local networkFunction = require("Network.NetworkFunction")
local scrollViewForPost = require( "ProjectObject.ScrollViewForPost" )
local newNetworkFunction = require("Network.newNetworkFunction")
---------------------------------------------------------------
-- Constants
---------------------------------------------------------------

local ROW_HEIGHT = 85 -- language button height
local NEXSOFT_LINK = "http://nexsoftech.com/en/contactus"
local SCENE_OPTION = {
						effect = "slideLeft",
						time = 400,
					}
---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
--Create a storyboard scene for this module
local scene = storyboard.newScene()
local sceneCreation
local sceneGroup --scene.group
local scrollView
local LANGUAGE_BEGIN_Y = 688 -- language button Y

local userData

local headerObjects
local header
local tabbar

local tabName = {"me","post",nil,"notice","setting"}

local temp_changeHeaderOption
local backSceneHeaderOption
---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
-- Function for back button
local function onBackButtonPressed()
end

local function tutorialFnc(event)
	local phase = event.phase

    if( phase == "began" ) then
	elseif ( phase == "moved" ) then
        local dy = math.abs( ( event.y - event.yStart ) )
        if ( dy > 10 ) then
            scrollView:takeFocus( event )
        end
    elseif ( phase == "ended" or phase == "cancelled" ) then
		storyboard.gotoScene( "Scene.TutorialScene")
	end
    return true
end

local function redemptionFnc(event)
	local phase = event.phase

    if( phase == "began" ) then
	elseif ( phase == "moved" ) then
        local dy = math.abs( ( event.y - event.yStart ) )
        if ( dy > 10 ) then
            scrollView:takeFocus( event )
        end
    elseif ( phase == "ended" or phase == "cancelled" ) then
		storyboard.gotoScene( "Scene.RedemptionScene", SCENE_OPTION)
	end
    return true
end

local function aboutVorumFnc(event)
	local phase = event.phase

    if( phase == "began" ) then
	elseif ( phase == "moved" ) then
        local dy = math.abs( ( event.y - event.yStart ) )
        if ( dy > 10 ) then
            scrollView:takeFocus( event )
        end
    elseif ( phase == "ended" or phase == "cancelled" ) then
		storyboard.gotoScene( "Scene.AboutVorumScene", SCENE_OPTION)
	end
    return true
end

local function contactFnc(event)
	local phase = event.phase

    if( phase == "began" ) then
	elseif ( phase == "moved" ) then
        local dy = math.abs( ( event.y - event.yStart ) )
        if ( dy > 10 ) then
            scrollView:takeFocus( event )
        end
    elseif ( phase == "ended" or phase == "cancelled" ) then
		storyboard.gotoScene( "Scene.ContactScene", SCENE_OPTION)
	end
    return true
end

local function signOutFnc(event)
	local phase = event.phase

    if( phase == "began" ) then
	elseif ( phase == "moved" ) then
        local dy = math.abs( ( event.y - event.yStart ) )
        if ( dy > 10 ) then
            scrollView:takeFocus( event )
        end
    elseif ( phase == "ended" or phase == "cancelled" ) then
		newNetworkFunction.logout()
	end
    return true
end

local function changeLanguageFnc(event)
	local curLocale = localization.getLocale()
	local target = event.target
	local locale = target.id
	
	if ( curLocale ~= locale ) then
		local langSetting = {}
		langSetting.locale = locale
		saveData.save(global.languageDataPath,langSetting)
		localization.setLocale(locale)
		sceneCreation()
		print(locale)
		for i=1,5 do
			if(tabName[i])then
				headTabFnc.updateTabbarText(i, localization.getLocalization(tabName[i]))
			end
		end
	end
	
	return true
end

local function nexsoftTouchListener(event)
	if (event.phase == "moved") then
		local dy = math.abs( ( event.y - event.yStart ) )
        if ( dy > 10 ) then
            scrollView:takeFocus( event )
        end
	elseif (event.phase == "ended") then
		system.openURL(NEXSOFT_LINK)
	end
	return true
end

local function changeHeaderFnc(newChangeHeaderOption)
	temp_changeHeaderOption = newChangeHeaderOption or global.newSceneHeaderOption
	
	headerObjects = headerView.createVorumHeaderObjects("setting")
	
	header = headTabFnc.changeHeaderView(headerObjects,temp_changeHeaderOption)
	
	backSceneHeaderOption = nil
end

sceneCreation = function()
	
	--header
	changeHeaderFnc(backSceneHeaderOption)
	
	header = headTabFnc.getHeader()
	tabbar = headTabFnc.getTabbar()
	if (tabbar == nil) then
		tabbar = headTabFnc.createNewTabbar(projectObjectSetting.tabbar)
	end
	 
	headTabFnc.setDisplayStatus(true)
	--
	if(scrollView)then
		display.remove(scrollView)
		scrollView=nil
		sceneGroup:remove(scrollView)
	end
	scrollView = scrollViewForPost.newScrollView
	{
		top = 0,
		left = 0,
		width = display.contentWidth,
		height = display.contentHeight,
		bottomPadding = 100,
		backgroundColor = { 243/255,243/255,243/255 },
		horizontalScrollDisabled = true,
		verticalScrollDisabled = false,
		hideScrollBar = true,
		listener = scrollListener
	}
	--person details part

	local group_personPart = personPart.create(userData,scrollView)
	scrollView:setScrollViewHead(group_personPart,group_personPart.height)

	--------------------- tutorial
	local tutorial_button = widget.newButton
	{
		id = "tutorial",
		label = localization.getLocalization("setting_tutorial"),
		labelColor = { default={ 81/255, 81/255, 81/255 }, over={  1, 1, 1  } },
		font = "Helvetica",
		fontSize = 30,
		labelAlign = "left",
		labelXOffset = 36,
		onEvent = tutorialFnc,
		
		shape = "roundedRect",
		fillColor = { default={ 255/255, 255/255, 255/255}, over={ 78/255, 184/255, 229/255} },
		width = display.contentWidth,
		height = 82,
		cornerRadius = 0,
		strokeColor = { default={ 225/255, 225/255, 225/255 }, over={ 225/255, 225/255, 225/255 } },
		strokeWidth =2,
	}
	tutorial_button.x = 0
	tutorial_button.y = 312
	tutorial_button.anchorX=0
	tutorial_button.anchorY=0
	scrollView:insert(tutorial_button)

	tutorial_image_arrow = display.newImage("Image/Setting/arrow.png")
	tutorial_image_arrow.x = display.contentWidth-45
	tutorial_image_arrow.y = tutorial_button.y+tutorial_button.height/2
	tutorial_image_arrow.anchorX=1
	tutorial_image_arrow.anchorY=0.5
	scrollView:insert(tutorial_image_arrow)
	--------------------- redemption
	local redemption_button = widget.newButton
	{
		id = "redemption",
		label = localization.getLocalization("setting_redemption"),
		labelColor = { default={ 81/255, 81/255, 81/255 }, over={  1, 1, 1  } },
		font = "Helvetica",
		fontSize = 30,
		labelAlign = "left",
		labelXOffset = 36,
		onEvent = redemptionFnc,
		
		shape = "roundedRect",
		fillColor = { default={ 255/255, 255/255, 255/255}, over={ 78/255, 184/255, 229/255} },
		width = display.contentWidth,
		height = 82,
		cornerRadius = 0,
		strokeColor = { default={ 225/255, 225/255, 225/255 }, over={ 225/255, 225/255, 225/255 } },
		strokeWidth =2
	}
	redemption_button.x = 0
	redemption_button.y = tutorial_button.y+tutorial_button.height+3
	redemption_button.anchorX=0
	redemption_button.anchorY=0
	scrollView:insert(redemption_button)

	redemption_image_arrow = display.newImage("Image/Setting/arrow.png")
	redemption_image_arrow.x = display.contentWidth-45
	redemption_image_arrow.y = redemption_button.y+redemption_button.height/2
	redemption_image_arrow.anchorX=1
	redemption_image_arrow.anchorY=0.5
	scrollView:insert(redemption_image_arrow)
	
	--------------------- about VORUM
	local aboutVorum_button = widget.newButton
	{
		id = "aboutVorum",
		label = localization.getLocalization("setting_aboutVorum"),
		labelColor = { default={ 81/255, 81/255, 81/255 }, over={  1, 1, 1  } },
		font = "Helvetica",
		fontSize = 30,
		labelAlign = "left",
		labelXOffset = 36,
		onEvent = aboutVorumFnc,
		
		shape = "roundedRect",
		fillColor = { default={ 255/255, 255/255, 255/255}, over={ 78/255, 184/255, 229/255} },
		width = display.contentWidth,
		height = 82,
		cornerRadius = 0,
		strokeColor = { default={ 225/255, 225/255, 225/255 }, over={ 225/255, 225/255, 225/255 } },
		strokeWidth =2
	}
	aboutVorum_button.x = 0
	aboutVorum_button.y = redemption_button.y+redemption_button.height+3
	aboutVorum_button.anchorX=0
	aboutVorum_button.anchorY=0
	scrollView:insert(aboutVorum_button)
	
	aboutVorum_image_arrow = display.newImage("Image/Setting/arrow.png")
	aboutVorum_image_arrow.x = display.contentWidth-45
	aboutVorum_image_arrow.y = aboutVorum_button.y+aboutVorum_button.height/2
	aboutVorum_image_arrow.anchorX=1
	aboutVorum_image_arrow.anchorY=0.5
	scrollView:insert(aboutVorum_image_arrow)
	
	--------------------- contact
	local contact_button = widget.newButton
	{
		id = "contact",
		label = localization.getLocalization("setting_contact"),
		labelColor = { default={ 81/255, 81/255, 81/255 }, over={  1, 1, 1  } },
		font = "Helvetica",
		fontSize = 30,
		labelAlign = "left",
		labelXOffset = 36,
		onEvent = contactFnc,
		
		shape = "roundedRect",
		fillColor = { default={ 255/255, 255/255, 255/255}, over={ 78/255, 184/255, 229/255} },
		width = display.contentWidth,
		height = 82,
		cornerRadius = 0,
		strokeColor = { default={ 225/255, 225/255, 225/255 }, over={ 225/255, 225/255, 225/255 } },
		strokeWidth =2
	}
	contact_button.x = 0
	contact_button.y = aboutVorum_button.y+aboutVorum_button.height+3
	contact_button.anchorX=0
	contact_button.anchorY=0
	scrollView:insert(contact_button)
	
	contact_image_arrow = display.newImage("Image/Setting/arrow.png")
	contact_image_arrow.x = display.contentWidth-45
	contact_image_arrow.y = contact_button.y+contact_button.height/2
	contact_image_arrow.anchorX=1
	contact_image_arrow.anchorY=0.5
	scrollView:insert(contact_image_arrow)
	
	------------------- language
	local localeNameList = localization.getSupportedLocaleName()
	local localeTotal = #localeNameList
	local curObjectY = LANGUAGE_BEGIN_Y
	for i = 1, localeTotal do
		local curLocale = localization.getSupportedLocale()

		local language_button = display.newRect( 0, curObjectY, display.contentWidth, ROW_HEIGHT )
		language_button.anchorX=0
		language_button.anchorY=0
		language_button.id = curLocale[i]
		language_button.strokeWidth = 2
		language_button:setFillColor( 1 )
		language_button:setStrokeColor( 225/255, 225/255, 225/255 )
		language_button:addEventListener("tap",changeLanguageFnc)
		scrollView:insert(language_button)
		
		local language_text_property = 
		{
			text = localeNameList[i],
			x = 50,
			y = language_button.y+language_button.height/2,
			width = 0,
			font = "Helvetica",
			fontSize = 30
		}
		local language_text = display.newText( language_text_property )
		language_text.anchorX=0
		language_text.anchorY=0.5
		language_text:setFillColor( 170/255, 170/255, 170/255 )
		scrollView:insert(language_text)
		
		
		local language_background_circle = display.newCircle( display.contentWidth-45, language_button.y+language_button.height/2, 20 )
		language_background_circle:setFillColor( 1,1,1 )
		language_background_circle.strokeWidth = 5
		language_background_circle:setStrokeColor( 225/255, 225/255, 225/255 )
		language_background_circle.anchorX=1
		language_background_circle.anchorY=0.5
		scrollView:insert(language_background_circle)
		
		
		local language_switch = widget.newSwitch
		{
			x = display.contentWidth-45,
			y = language_button.y+language_button.height/2,
			style = "radio",
			id = curLocale[i],
			initialSwitchState = false,
			onPress = changeLanguageFnc,
			width = language_background_circle.width,
			height = language_background_circle.height
		}
		language_switch.anchorX=1
		language_switch.anchorY=0.5
		scrollView:insert(language_switch)
		
		local locale = localization.getLocale()
		if ( locale == curLocale[i] ) then
			language_switch:setState({isOn=true})
			language_text:setFillColor( 127/255, 127/255, 127/255 )
		end
		curObjectY = curObjectY + ROW_HEIGHT
	end
	
	--------------------- sign out
	local signOut_button = widget.newButton
	{
		label = localization.getLocalization("setting_signOut"),
		labelColor = { default={ 81/255, 81/255, 81/255 }, over={ 1, 1, 1,1 } },
		font = "Helvetica",
		fontSize = 30,
		labelAlign = "left",
		labelXOffset = 36,
		onEvent = signOutFnc,
		
		shape = "roundedRect",
		fillColor = { default={ 255/255, 255/255, 255/255}, over={ 78/255, 184/255, 229/255} },
		width = display.contentWidth,
		height = 82,
		cornerRadius = 0,
		strokeColor = { default={ 225/255, 225/255, 225/255 }, over={ 225/255, 225/255, 225/255 } },
		strokeWidth =2
	}
	signOut_button.x = 0
	signOut_button.y = curObjectY+37
	signOut_button.anchorX=0
	signOut_button.anchorY=0
	scrollView:insert(signOut_button)
	--------------------- company logo
	local companyLogo_button = widget.newButton
	{
		id = "companyLogo_button",
		defaultFile = "Image/Setting/companyLogo.png",
		overFile = "Image/Setting/companyLogo.png",
		onEvent = nexsoftTouchListener,
	}
	companyLogo_button.x = display.contentCenterX
	companyLogo_button.y = signOut_button.y+signOut_button.height+28
	companyLogo_button.anchorX=0.5
	companyLogo_button.anchorY=0
	scrollView:insert(companyLogo_button)
	--- insert to scene
	sceneGroup:insert(scrollView)
	--set header and tabber toFront
	
	if (header) then
		header:toFront()
	end
	if (tabbar) then
		tabbar:toFront()
	end
	return scrollView
end

-- Create the scene
function scene:createScene( event )
	debugLog( "Creating " .. LOCAL_SETTINGS.NAME .. " Scene")
	display.setStatusBar( display.DefaultStatusBar )
	sceneGroup = self.view
	
	display.setDefault("background",243/255,243/255,243/255)
	-- Place the code below
	userData = saveData.load(global.userDataPath)

	if(event.params)then
		backSceneHeaderOption = event.params.changeHeaderOption --now it is back scene
	else
		backSceneHeaderOption = nil
	end
	
	sceneCreation()
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

	Runtime:addEventListener( "key", onSceneTransitionKeyEvent )
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
	
	tabbar = headTabFnc.getTabbar()
	if (tabbar == nil) then
		tabbar = headTabFnc.createNewTabbar(projectObjectSetting.tabbar)
	end
	tabbar:setSelected( 5 ) 
	global.currentSceneNumber = 5
	-- Place the code below
	
end

-- Called when scene is about to move offscreen:
function scene:exitScene()
	debugLog( "Exiting " .. LOCAL_SETTINGS.NAME .. " Scene")

	-- removing check system key event
	Runtime:removeEventListener( "key", onKeyEvent )
	-- Place the code below
	networkFunction.cancelAllConnection()
end

-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	debugLog( "Destroying " .. LOCAL_SETTINGS.NAME .. " Scene" )
	
	-- Place the code below
	display.remove( scrollView )
	scrollView = nil
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