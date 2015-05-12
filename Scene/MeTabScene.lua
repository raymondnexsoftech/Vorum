---------------------------------------------------------------
-- VorumTabScene.lua
--
-- Scene for Vorum Tab
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
--local resDir = (...):match("(.-)[^%.]+$")

-- Local Constant Setting
local LOCAL_SETTINGS = {
						NAME = "MeTabScene",			-- Scene name to show in console
						RES_DIR = "",					-- Common resource directory for scene
						DOC_DIR = "",					-- Common document directory for scene
						}

---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------
local storyboard = require ( "storyboard" )
local widget = require ( "widget" )
require ( "DebugUtility.Debug" )
local localization = require("Localization.Localization")
local projectObjectSetting = require( "Setting.ProjectObjectSetting" )
local networkFunction = require("Network.NetworkFunction")
local json = require( "json" )
local scrollViewForPost = require( "ProjectObject.ScrollViewForPost" )
local headerView = require( "ProjectObject.HeaderView" )
local headTabFnc = require( "ProjectObject.HeadTabFnc" )
local global = require( "GlobalVar.global" )
local catScreen = require("ProjectObject.CatScreen")
local saveData = require( "SaveData.SaveData" )
local tableSave = require("Module.TableSave")
local optionModule = require("Module.Option")
local postView = require("ProjectObject.PostView")
local navScene = require("Function.NavScene")
local newNetworkFunction = require("Network.newNetworkFunction")
local sizableActivityIndicatorFnc = require("Module.SizableActivityIndicator")
local postButton = require("Function.postButton")
---------------------------------------------------------------
-- Constants
---------------------------------------------------------------

local getNewPostNum = 6 -- it also get post number at the beginning
local getOldPostNum = 6
---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
local post_filter = 1--default

--Create a storyboard scene for this module
local scene = storyboard.newScene()
local scrollView--scrollViewForPost



local sceneGroup
local userData
local userId
local sessionToken

local headerObjects
local header
local tabbar

local listenerTable
--scene
local sceneOptions = {}
sceneOptions.sceneName = "MeTabScene"
local temp_changeHeaderOption
local backSceneHeaderOption


local loadingIcon
local getPostParams = {}
getPostParams.pushed_time = nil
getPostParams.limit = 0

local isNotShownNoPost = false

local filterOption
---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
-- Function for back button

local function scrollViewToTop()
	if ((scrollView ~= nil) and (scrollView.parent ~= nil)) then
		local header = headTabFnc.getHeader()
		scrollView:scrollToPosition({y = header.height, time = 200})
	end
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

local function onBackButtonPressed()
end
local function cancelAllLoad()
	if(loadingIcon)then
		display.remove(loadingIcon)
		loadingIcon = nil
	end
	networkFunction.cancelAllConnection()
end

local function votingListener(postGroup, dataForVote)
	local function votingListener(event)
		if (event.isError) then
			-- TODO: display Network Error
		else
			if (event.code) then
				-- TODO: check what the error is
			elseif (event.result) then
				postGroup:updateResult(event.result)
			else
				-- TODO: unknown error
			end
		end
	end
	newNetworkFunction.votePost(dataForVote,votingListener)
end
local function pressedCreatorListener(creatorData)
	navScene.go(sceneOptions,nil,creatorData,creatorData.id)
end
local function actionButtonListener(postGroup, postPartData, creatorId)
	postButton.show(postGroup, postPartData, creatorId,scrollView)
end
local function createPostFnc(postData)
	listenerTable = {
		votingListener = votingListener,	
		pressedCreatorListener = pressedCreatorListener,
		actionButtonListener = actionButtonListener,
	}
	postView.newPost(scrollView, userId, postData, listenerTable)
end

local function createPostWithResultFnc(postData) -- used for my post
	listenerTable = {
		votingListener = votingListener,	
		pressedCreatorListener = pressedCreatorListener,
		actionButtonListener = actionButtonListener,
	}
	postView.newPost(scrollView, userId, postData,true, listenerTable)
end


local function noPostShowFnc()
	local noPostGroup = display.newGroup()
	local noPostText = {
		parent = noPostGroup,
		text = localization.getLocalization("noPost"),     
		x = display.contentCenterX,
		y = display.contentCenterY-filterOption.height-header.height,
		width = 0, 
		height = 0,
		font = "Helvetica",   
		fontSize = 108,
	}

	noPostText = display.newText( noPostText )
	noPostText.anchorX = 0.5
	noPostText.anchorY = 0.5
	noPostText:setFillColor( 0, 0, 0 )
	scrollView:addNewPost(noPostGroup, noPostText.y+noPostText.height)
end
--------------------- listener 
-- my post
local function getMyPostListener(event)
	setActivityIndicatorFnc(false)
	if (event.isError) then
		print("error")
	else
		scrollView:resetDataRequestStatus()
		if (type(event.postData)=="table") then
			if(#event.postData==0)then
				if(not isNotShownNoPost)then
					noPostShowFnc()
				end
				return
			end
			for i = 1,#event.postData do
				createPostWithResultFnc(event.postData[i])
			end
			getPostParams.pushed_time = tonumber(event.postData[#event.postData].pushed_time)-1
			
		else
			print(event[1].response)
		end
	end
end

-- voted
local function getVotedPostListener(event)
	setActivityIndicatorFnc(false)
	if(event.isError) then
	else
		scrollView:resetDataRequestStatus()
		if (type(event.postData)=="table") then
			if(#event.postData==0)then
				
				if(not isNotShownNoPost)then
					noPostShowFnc()
				end
				return false
			end

			for i = 1,#event.postData do
				createPostFnc(event.postData[i],#event.postData)
			end			
			getPostParams.pushed_time = tonumber(event.postData[#event.postData].pushed_time)-1
			
		end
	end
end
-- friends
local function getFriendPostListener(event)
	setActivityIndicatorFnc(false)
	if (event.isError) then
	else
		if (type(event.postData)=="table") then
			if(#event.postData==0)then
				if(not isNotShownNoPost)then
					noPostShowFnc()
				end
				return
			end
			for i = 1,#event.postData do
				createPostFnc(event.postData[i])
			end
			getPostParams.pushed_time = tonumber(event.postData[#event.postData].pushed_time)-1
		else
			print("no post data")
		end
	end
end

local function requestOldPost()
	print("Old")
	isNotShownNoPost = true
	getPostParams.limit = getOldPostNum
	if(post_filter == "myPost")then
		newNetworkFunction.getMyPost(getPostParams, getMyPostListener)
	elseif(post_filter == "voted")then
		newNetworkFunction.getVotedPost(getPostParams, getVotedPostListener)
	elseif (post_filter == "friends") then
		newNetworkFunction.getFriendPost(getPostParams, getFriendPostListener)
	end
end

local function reloadNewPost()
	print("New")
	cancelAllLoad()
	setActivityIndicatorFnc(true)

	isNotShownNoPost = false
	getPostParams.pushed_time = nil
	getPostParams.limit = getNewPostNum
	scrollView:deleteAllPost()
	if(post_filter == "myPost")then
		newNetworkFunction.getMyPost(getPostParams, getMyPostListener)
	elseif(post_filter == "voted")then
		newNetworkFunction.getVotedPost(getPostParams, getVotedPostListener)
	elseif (post_filter == "friends") then
		newNetworkFunction.getFriendPost(getPostParams, getFriendPostListener)
	end
end

----------------------type begin
local function type_selection(id)
	
	post_filter = id

	local meTabFilterData = {}
	meTabFilterData.searchType = post_filter
	saveData.save(global.meTabFilterDataPath,global.TEMPBASEDIR,meTabFilterData)
	--first time get post
	reloadNewPost()
end

local function touch_type_selection(event)
	scrollView:checkFocusToScrollView(event)
	if(event.phase=="ended" or event.phase=="cancelled")then
		if(post_filter~=event.target.id)then
			cancelAllLoad()--cancel all network connection
			type_selection(event.target.id)
		end
	end
	return true
end
local function default_type_selection(event)
	type_selection(event.id)
end
---------------------type end
local function headerCreateFnc(newChangeHeaderOption)
	temp_changeHeaderOption = newChangeHeaderOption or global.newSceneHeaderOption
	headerObjects = {}
	headerObjects.title = {
		text = localization.getLocalization("meTab_title"),     
		x = 0,
		y = 0,
		width = 0,    
		height = 0,
		font = "Helvetica",   
		fontSize = 40,
	}
	headerObjects.title = display.newText(headerObjects.title)
	headerObjects.leftButton = nil
	headerObjects.rightButton = headerView.searchButtonCreation(sceneOptions,nil,headerCreateFnc) 
	header = headTabFnc.changeHeaderView(headerObjects,temp_changeHeaderOption,scrollViewToTop)
	tabbar = headTabFnc.getTabbar()
	if (tabbar == nil) then
		tabbar = headTabFnc.createNewTabbar(projectObjectSetting.tabbar)
	end
	
	headTabFnc.setDisplayStatus(true)

	backSceneHeaderOption = nil
end

-- Create the scene
function scene:createScene( event )
	debugLog( "Creating " .. LOCAL_SETTINGS.NAME .. " Scene")
	display.setStatusBar( display.DefaultStatusBar )
	sceneGroup = self.view
	
	userData = saveData.load(global.userDataPath)
	userId = userData.id
	sessionToken = userData.session
	if(event.params)then
		backSceneHeaderOption = event.params.backSceneHeaderOption --now it is back scene
	else
		backSceneHeaderOption = nil
	end
	--header
		headerCreateFnc(backSceneHeaderOption)
	--

	local function svListener(event)
		headTabFnc.scrollViewCallback(event)
	end

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
													-- postSpace = -50
												}

	--------------- type (mypost, voted and friends) begin
	
	local meTabFilterData = saveData.load(global.meTabFilterDataPath,global.TEMPBASEDIR)
	if(meTabFilterData)then
		if(meTabFilterData.searchType)then
			post_filter = meTabFilterData.searchType
		end
	end
	
	filterOption = {
		choices = {localization.getLocalization("meTab_voted"),localization.getLocalization("meTab_myPost"),localization.getLocalization("meTab_friends")},
		choicesId = {"voted","myPost","friends"},
		leftImagePath_isSelected = "Image/Filter/left.png",
		leftImagePath_isNotSelected = "Image/Filter/background_left.png",
		rightImagePath_isSelected = "Image/Filter/right.png",
		rightImagePath_isNotSelected ="Image/Filter/background_right.png",
		centerImagePath_isSelected = "Image/Filter/center.png",
		centerImagePath_isNotSelected = "Image/Filter/background_center.png",
		choicesListener = touch_type_selection,
		y = 20,
		font = "Helvetica",
		fontSize = 28.06,
		textColor = { 1, 1, 1},
		choiceOffset = 2,
		default = post_filter,
		defaultListener = default_type_selection,
	}
	filterOption = optionModule.new(filterOption)
	scrollView:setScrollViewHead(filterOption, 100)
	

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
	
	tabbar = headTabFnc.getTabbar()
	if (tabbar == nil) then
		tabbar = headTabFnc.createNewTabbar(projectObjectSetting.tabbar)
	end
	tabbar:setSelected( 1 )  
	global.currentSceneNumber = 1
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