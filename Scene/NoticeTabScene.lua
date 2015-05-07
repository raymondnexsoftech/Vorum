---------------------------------------------------------------
-- TemplateScene.lua
--
-- Template for Scene
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
--local resDir = (...):match("(.-)[^%.]+$")

-- Local Constant Setting
local LOCAL_SETTINGS = {
						NAME = "NoticicationScene",			-- Scene name to show in console
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
local networkFunction = require("Network.NetworkFunction")
local saveData = require( "SaveData.SaveData" )
local json = require( "json" )
local global = require( "GlobalVar.global" )
local scrollViewForPost = require( "ProjectObject.ScrollViewForPost" )
local networkFile = require("Network.NetworkFile")
local newNetworkFunction = require("Network.newNetworkFunction")
local fncForLocalization = require("Misc.FncForLocalization")
local sizableActivityIndicatorFnc = require("Module.SizableActivityIndicator")
local noticeBadge = require("ProjectObject.NoticeBadge")
---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local ROW_HEIGHT = 124
local USERICON_WIDTH = 102
local USERICON_HEIGHT = 102
local USERICON_MASKPATH = "Image/User/creatorMask.png"
---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
--Create a storyboard scene for this module
local scene = storyboard.newScene()
local getNoticNum = 10
local sceneGroup
local headerObjects
local header
local tabbar
local scrollView

local userData
local userId


local loadingIcon
-- action 1 is adding friend
-- action 2 is voting
-- action 3 is getting a new coupon

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
-- Function for back button
local function onBackButtonPressed()
end

local function setActivityIndicatorFnc(boolean_loadingSwitch)
	if(not loadingIcon and boolean_loadingSwitch)then
		loadingIcon = sizableActivityIndicatorFnc.newActivityIndicator(display.contentWidth,display.contentHeight)
		if(type(scrollView) == "table")then
			scrollView:insert(loadingIcon)
		end
		loadingIcon.x = display.contentCenterX
		loadingIcon.y = display.contentCenterY-header.height
		loadingIcon:setEnable(true)
		loadingIcon:toBack()
	elseif(loadingIcon and boolean_loadingSwitch)then
		loadingIcon:setEnable(true)
	elseif(loadingIcon and not boolean_loadingSwitch)then
		loadingIcon:setEnable(false)
	end
	if(type(loadingIcon)=="table" and loadingIcon.parent)then
		loadingIcon:toBack()
	end
end

local function cancelAllLoad()
	if(loadingIcon)then
		display.remove(loadingIcon)
		loadingIcon = nil
	end
	networkFunction.cancelAllConnection()
end

local function noticCreation(noticData)

	local user_icon_background 
	local user_icon
	local user_icon_savePath = "user/" .. tostring(noticData.user_id) .. "/img"

	local thisPostGroup = display.newGroup()
------------ black underline
	local topLine = display.newLine(0,0,display.contentWidth,0)
	topLine:setStrokeColor( 0,0,0 )
	topLine.strokeWidth = 2
	topLine.anchorX=0
	topLine.anchorY=0
	thisPostGroup:insert( topLine )
	
	local downLine = display.newLine(0,ROW_HEIGHT,display.contentWidth,ROW_HEIGHT)
	downLine:setStrokeColor( 0,0,0 )
	downLine.strokeWidth = 2
	downLine.anchorX=0
	downLine.anchorY=0
	thisPostGroup:insert( downLine )
-------------- icon blue background
	
	user_icon_background = display.newCircle(thisPostGroup, 73, ROW_HEIGHT/2, 58)
	user_icon_background.anchorX = 0.5
	user_icon_background.anchorY = 0.5
	user_icon_background:setFillColor(88/255, 175/255, 231/255)


	local userIconFnc = function(fileInfo)
		if(userIcon)then
			display.remove(userIcon)
			userIcon = nil
		end
		
		user_icon = display.newImage(fileInfo.path, fileInfo.baseDir, true)
		if(user_icon)then
			user_icon.x = user_icon_background.x
			user_icon.y = user_icon_background.y
			user_icon.anchorX=0.5
			user_icon.anchorY=0.5
		
			local xScale = USERICON_WIDTH / user_icon.contentWidth
			local yScale = USERICON_HEIGHT / user_icon.contentHeight
			local scale = math.max( xScale, yScale )
			user_icon:scale( scale, scale )
			local mask = graphics.newMask( USERICON_MASKPATH )
			user_icon:setMask( mask )
			user_icon.maskX = 0
			user_icon.maskY = 0
			user_icon.maskScaleX, user_icon.maskScaleY = 1/scale,1/scale
			thisPostGroup:insert(user_icon)
		end
	end

	local function userIconListener(event)
		if (event.isError) then
		else
			userIconFnc({path = event.path, baseDir = event.baseDir})
		end
	end


	userIconFnc({path = "Image/User/anonymous.png", baseDir = system.ResourceDirectory})--temp image


	local userIconInfo = newNetworkFunction.getVorumFile(noticData.profile_pic, user_icon_savePath, userIconListener)
	if ((userIconInfo ~= nil) and (userIconInfo.request == nil)) then
		userIconFnc(userIconInfo)
	end

	
	----------------- when action is adding friend
	if (noticData.action == 1) then
		local text_action_addFriend =
		{
			text = noticData.username..localization.getLocalization("notice_action_addFriend"), 
			x = 161,
			y = 25,
			width = 300,
			height = 85, 
			font = "Helvetica",
			fontSize=30
		}

		text_action_addFriend = display.newText(text_action_addFriend);
		text_action_addFriend:setFillColor( 104/255, 104/255, 104/255 )
		text_action_addFriend.anchorX=0
		text_action_addFriend.anchorY=0
		thisPostGroup:insert( text_action_addFriend )
	
	--------------- when action is voting
	elseif (noticData.action == 2) then
		local text_action_voting =
		{
			text = noticData.username..localization.getLocalization("notice_action_voting"), 
			x = 161,
			y = 25,
			width = 300,
			height = 85, 
			font = "Helvetica",
			fontSize=30
		}

		text_action_voting = display.newText(text_action_voting);
		text_action_voting:setFillColor( 104/255, 104/255, 104/255 )
		text_action_voting.anchorX=0
		text_action_voting.anchorY=0
		thisPostGroup:insert( text_action_voting )
	

	
	--------------- when action is having new coupon
	elseif (noticData.action == 3) then
		local text_action_newCoupon =
		{
			text = localization.getLocalization("notice_action_newCoupon")..noticData.username,
			x = 161,
			y = 25,
			width = 300,
			height = 85, 
			font = "Helvetica",
			fontSize=28
		}

		text_action_newCoupon = display.newText(text_action_newCoupon);
		text_action_newCoupon:setFillColor( 104/255, 104/255, 104/255 )
		text_action_newCoupon.anchorX=0
		text_action_newCoupon.anchorY=0
		thisPostGroup:insert( text_action_newCoupon )
	
	end
	--------------- post time
	local tempTimeString = fncForLocalization.getPostCreatedAt(create_time,0)
	if(not tempTimeString)then
		tempTimeString = ""
	end
	local text_timeAgo =
	{
		text = tostring(tempTimeString), 
		x = 596,
		y = 46,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=30
	}

	text_timeAgo = display.newText(text_timeAgo);
	text_timeAgo:setFillColor( 159/255, 159/255, 159/255)
	text_timeAgo.anchorX=1
	text_timeAgo.anchorY=0
	thisPostGroup:insert( text_timeAgo )


	scrollView:addNewPost(thisPostGroup, ROW_HEIGHT)

	return thisPostGroup
end

local function getNotificationListListener(event)
	print(event[1].response)
	setActivityIndicatorFnc(false)
	print("set false")
	if (event.isError) then
		native.showAlert(localization.getLocalization("networkError_errorTitle"),localization.getLocalization("networkError_networkError"),{localization.getLocalization("ok")})
	else
		local response = json.decode( event[1].response )
		for i=1,#response do
			noticCreation(response[i])
		end
	end
end

local function requestOldPost()
	-- newNetworkFunction.getVorumPost(filterData,getVorumPostListener)
end
local function reloadNewPost()
	cancelAllLoad()
	setActivityIndicatorFnc(true)
	print("set true")
	scrollView:deleteAllPost()
	newNetworkFunction.getNotificationList(getNotificationListListener)
end

-- Create the scene
function scene:createScene( event )
	debugLog( "Creating " .. LOCAL_SETTINGS.NAME .. " Scene")
	display.setStatusBar( display.DefaultStatusBar )
	sceneGroup = self.view

	userData = saveData.load(global.userDataPath)
	userId = userData.user_id or userData.id

	--header
	headerObjects = headerView.createVorumHeaderObjects("notice")
	header = headTabFnc.changeHeaderView(headerObjects,global.newSceneHeaderOption)
	tabbar = headTabFnc.getTabbar()
	if (tabbar == nil) then
		tabbar = headTabFnc.createNewTabbar(projectObjectSetting.tabbar)
	end
	  
	headTabFnc.setDisplayStatus(true)
	-- --
	display.setDefault("background",1,1,1)
	-- ----------------------- notification begin
	scrollView = scrollViewForPost.newScrollView{
													backgroundColor = {243/255,243/255,243/255},
													hideScrollBar = true,
													left = 0,
													top = 0,
													width = display.contentWidth,
													height = display.contentHeight,
													topPadding = header.height,
													refreshHeader = {
													height = 0,
													textToPull="",
													textToRelease="",
													loadingText="",
													},
													bottomPadding = ROW_HEIGHT,
													-- scrollHeight = display.contentHeight * 2,
													horizontalScrollDisabled = true,
													listener = svListener,
													requestDataListener = requestOldPost,
													reloadDataListener = reloadNewPost,
													postSpace = 0
												}
											
	sceneGroup:insert(scrollView)

	if(header)then
		header:toFront()
	end
	if(tabbar)then
		tabbar:toFront()
	end

	reloadNewPost()
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
	
	tabbar = headTabFnc.getTabbar()
	-- if (tabbar == nil) then
		-- tabbar = headTabFnc.createNewTabbar(projectObjectSetting.tabbar)
	-- end
	if(tabbar)then
		tabbar:setSelected( 4 )
		global.currentSceneNumber = 4
	end
	native.setProperty("applicationIconBadgeNumber", 0)
	noticeBadge.setBadge(tabbar, 0)
	-- Place the code below
end

-- Called when scene is about to move offscreen:
function scene:exitScene()
	debugLog( "Exiting " .. LOCAL_SETTINGS.NAME .. " Scene")
	-- removing check system key event
	Runtime:removeEventListener( "key", onKeyEvent )
	
	-- Place the code below
	cancelAllLoad()
end

-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	debugLog( "Destroying " .. LOCAL_SETTINGS.NAME .. " Scene" )
	
	-- Place the code below
	scrollView:deleteAllPost()
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