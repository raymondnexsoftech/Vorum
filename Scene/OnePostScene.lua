---------------------------------------------------------------
-- ProfileScene.lua
--
-- Scene for ProfileScene Tab
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
--local resDir = (...):match("(.-)[^%.]+$")

-- Local Constant Setting
local LOCAL_SETTINGS = {
						NAME = "OnePostScene",			-- Scene name to show in console
						RES_DIR = "",					-- Common resource directory for scene
						DOC_DIR = "",					-- Common document directory for scene
						}

---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------
local storyboard = require ( "storyboard" )
local widget = require ( "widget" )
require ( "SystemUtility.Debug" )
local localization = require("Localization.Localization")
local projectObjectSetting = require( "Setting.ProjectObjectSetting" )
-- local networkFunction = require("Network.NetworkFunction")
local json = require( "json" )
local scrollViewForPost = require( "ProjectObject.ScrollViewForPost" )
local headerView = require( "ProjectObject.HeaderView" )
local headTabFnc = require( "ProjectObject.HeadTabFnc" )
local global = require( "GlobalVar.global" )
local saveData = require( "SaveData.SaveData" )
local personPart = require( "ProjectObject.PersonPart" )
local navScene = require("Function.NavScene")
local postView = require("ProjectObject.PostView")
local newNetworkFunction = require("Network.newNetworkFunction")
local sizableActivityIndicatorFnc = require("Module.SizableActivityIndicator")
local postButton = require("Function.postButton")
---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local getPostNum = 6
local getNewPostNum = 6
local getOldPostNum = 6

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------

--Create a storyboard scene for this module
local scene = storyboard.newScene()
local scrollView --scrollViewForPost

local sceneGroup
local userData
local userId
local postData
local postId
-- local group_personPart
--header
local headerObjects
local header
local tabbar
--scene
local sceneOptions = {}
sceneOptions.sceneName = "OnePostScene"
local temp_changeHeaderOption

local backSceneHeaderOption

local loadingIcon
---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------
local reCreationFnc
---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
-- Function for back button

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

local function onBackButtonPressed()
	navScene.back()
end

local function cancelAllLoad()
	if(loadingIcon)then
		display.remove(loadingIcon)
		loadingIcon = nil
	end
	newNetworkFunction.cancelAllConnection()
end

local function votingListener(postGroup, dataForVote)
	local function votingFinishedListener(event)
		if (event.isError) then
			-- TODO: display Network Error
		else
			if (event.code) then
				-- TODO: check what the error is
			elseif (event.result) then
				postGroup:updateResult(event.result, event.userVoted)
			elseif (event.postNotExist) then
				native.showAlert(localization.getLocalization("postDoesNotExist"),
									localization.getLocalization("postDoesNotExist"),
									{localization.getLocalization("ok")},
									function(e)
										scrollView:deletePost(postGroup.idx, 200)
									end)
			else
				-- TODO: unknown error
			end
		end
	end
	newNetworkFunction.votePost(dataForVote,votingFinishedListener)
end

local function pressedCreatorListener(creatorData)
	if(creatorData.id~=postId)then
		navScene.go(sceneOptions,postData,creatorData,creatorData.id)
	end
end
local function actionButtonListener(postGroup, postPartData, creatorId)
	postButton.show(postGroup, postPartData, creatorId,scrollView)
end
local function createPostFnc(postData)
	local listenerTable = {
		votingListener = votingListener,	
		pressedCreatorListener = pressedCreatorListener,
		actionButtonListener = actionButtonListener,
	}
	postView.newPost(scrollView, userId, postData, listenerTable)
end

local function getOnePostListener(event)
	setActivityIndicatorFnc(false)
	if (event[1].isError) then
		native.showAlert(localization.getLocalization("networkError_errorTitle"),localization.getLocalization("networkError_networkError"),{localization.getLocalization("ok")})
	else
		scrollView:resetDataRequestStatus()

		if (event.postData) then
			createPostFnc(event.postData)
		else
			-- print(event[1].response)
		end
	end
end

local function requestOldPost()

end

local function reloadNewPost()
	cancelAllLoad()
	-- print("New")
	setActivityIndicatorFnc(true)
	scrollView:deleteAllPost()
	newNetworkFunction.getPost(postId,getOnePostListener)
end

local function svListener(event)
	headTabFnc.scrollViewCallback(event)
end

local function backLastSceneFnc(event)
	scrollView:checkFocusToScrollView(event)
	if(event.phase=="ended" or event.phase=="cancelled")then
		navScene.back()
	end
	return true
end
local function headerCreateFnc(newChangeHeaderOption)
	temp_changeHeaderOption = newChangeHeaderOption or global.newSceneHeaderOption
	temp_headerTitle = ""
	if(postData.title)then
		temp_headerTitle = postData.title
	end
	--header
	headerObjects = {}
	headerObjects.title = {
		text = temp_headerTitle, 
		width = 0,
		height = 0, 
		font = "Helvetica", 
		fontSize=40
	}
	headerObjects.title = display.newText(headerObjects.title)

	if(headerObjects.title.width>320)then
		display.remove(headerObjects.title)
		headerObjects.title = {
			text = temp_headerTitle, 
			width = 320,
			height = 50, 
			font = "Helvetica", 
			fontSize=40
		}
		headerObjects.title = display.newText(headerObjects.title)
	end

	headerObjects.title:setFillColor( 78/255, 184/255, 229/255)
	headerObjects.leftButton = display.newImage("Image/Header/back.png", true)
	headerObjects.leftButton:addEventListener("touch",backLastSceneFnc)
	headerObjects.rightButton = headerView.searchButtonCreation(sceneOptions,postData,headerCreateFnc)
	
	header = headTabFnc.changeHeaderView(headerObjects,temp_changeHeaderOption)
	tabbar = headTabFnc.getTabbar()
	if (tabbar == nil) then
		tabbar = headTabFnc.createNewTabbar(projectObjectSetting.tabbar)
	end
	headTabFnc.setDisplayStatus(true)
	
	backSceneHeaderOption = nil
end

local function sceneCreation()
	--header
	headerCreateFnc(backSceneHeaderOption)
	
	scrollView = scrollViewForPost.newScrollView{
													backgroundColor = {243/255,243/255,243/255},
													hideScrollBar = true,
													left = 0,
													top = 0,
													width = display.contentWidth,
													height = display.contentHeight,
													topPadding = header.headerHeight,
													refreshHeader = {
													height = 0,
													textToPull="",
													textToRelease="",
													loadingText="",
													},
													bottomPadding = 40,
													-- scrollHeight = display.contentHeight * 2,
													horizontalScrollDisabled = true,
													listener = svListener,
													requestDataListener = requestOldPost,
													reloadDataListener = reloadNewPost,
													postSpace = 35
												}
	-- print(json.encode(postData))
	-- group_personPart = personPart.create(postData,scrollView)
	-- scrollView:setScrollViewHead(group_personPart, group_personPart.height)
	
	sceneGroup:insert(scrollView)

	--GET DATA

	reloadNewPost()
	--set header and tabber toFront
	if (header) then
		header:toFront()
	end
	if (tabbar) then
		tabbar:toFront()
	end

end

-- Create the scene
function scene:createScene( event )
	
	debugLog( "Creating " .. LOCAL_SETTINGS.NAME .. " Scene")
	display.setStatusBar( display.DefaultStatusBar )
	sceneGroup = self.view
	userData = saveData.load(global.userDataPath)
	userId = userData.user_id
	postData = event.params --get user data
	postId = postData.id
	
	backSceneHeaderOption = postData.backSceneHeaderOption
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