---------------------------------------------------------------
-- VorumTabScene.lua
--
-- Scene for Vorum Tab
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
--local resDir = (...):match("(.-)[^%.]+$")

-- Local Constant Setting
local LOCAL_SETTINGS = {
						NAME = "VorumTabScene",			-- Scene name to show in console
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
local optionModule = require("Module.Option")
local postView = require("ProjectObject.PostView")
local postButton = require("Function.postButton")
local navScene = require("Function.NavScene")
local newNetworkFunction = require("Network.newNetworkFunction")
local sizableActivityIndicatorFnc = require("Module.SizableActivityIndicator")
local noticeBadge = require("ProjectObject.NoticeBadge")
---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local getPostNum = 6
local getNewPostNum = getPostNum
local getOldPostNum = 6
---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
--filter part begin
local filterChoice = 1--default 
--filter part end
--Create a storyboard scene for this module
local scene = storyboard.newScene()
local scrollView --scrollViewForPost

local sceneGroup
local userData
local userId

local postData
local response

local headerObjects
local header
local tabbar

local filterOption
local filterData = {}

--scene
local sceneOptions = {}
sceneOptions.sceneName = "VorumTabScene"

local changeHeaderOptionPassIn
local temp_changeHeaderOption
local backSceneHeaderOption

local loadingIcon
local filterOption

local isNotShownNoPost = false


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

local function cancelAllLoad()
	if(loadingIcon)then
		display.remove(loadingIcon)
		loadingIcon = nil
	end
	networkFunction.cancelAllConnection()
end

local function onBackButtonPressed()
end

local function votingListener(postGroup, dataForVote)
	local function votingListener(event)
		if (event.isError) then
			-- TODO: display Network Error
		else
			if (event.code) then
				-- TODO: check what the error is
			elseif (event.result) then
				postGroup:updateResult(event.result, event.userVoted)
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
	local listenerTable = {
							votingListener = votingListener,	
							pressedCreatorListener = pressedCreatorListener,
							actionButtonListener = actionButtonListener,
						}
	postView.newPost(scrollView, userId, postData, listenerTable)
	
end

local function getFilterData(getType)

	filterData.limit = nil
	filterData.sort = nil
	filterData.tag = nil
	filterData.isMyCountry = false

	if(getType=="old")then
		filterData.limit = getOldPostNum
	elseif(getType=="new")then
		filterData.pushed_time = nil
		filterData.offset = 0
		filterData.limit = getNewPostNum
	else
		filterData.limit = getPostNum
	end
	
	local temp_catData = saveData.load(global.catSettingDataPath,global.TEMPBASEDIR)
	local temp_vorumFilter = saveData.load(global.vorumTabFilterDataPath,global.TEMPBASEDIR)
	
	if(temp_catData)then
		if(temp_catData.most=="Latest")then
			filterData.sort = nil
		else
			filterData.sort = temp_catData.most
		end
		if(temp_catData.tags=="All")then
			filterData.tag = nil
		else
			filterData.tag = temp_catData.tags
		end
	end

	filterData.isMyCountry = filterOption:getChosenId()	

	if(filterData.isMyCountry == "myCountry" or filterData.isMyCountry == 2)then
		filterData.isMyCountry = true
	else
		filterData.isMyCountry = false
	end

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

local function getVorumPostListener(event)
	setActivityIndicatorFnc(false)
	if (event[1].isError) then
		native.showAlert(localization.getLocalization("networkError_errorTitle"),localization.getLocalization("networkError_networkError"),{localization.getLocalization("ok")})
	else
		scrollView:resetDataRequestStatus()
		if (type(event.postData)=="table") then
			if(#event.postData==0)then
				if(not isNotShownNoPost)then
					noPostShowFnc()
				end
				return
			end

			for i = 1, #event.postData do
				createPostFnc(event.postData[i])
				filterData.offset = filterData.offset+1
			end
			filterData.pushed_time = event.postData[#event.postData].pushed_time-1

		else
			print(event[1].response)
		end
	end
end

local function requestOldPost()
	isNotShownNoPost = true
	getFilterData("old")
	newNetworkFunction.getVorumPost(filterData,getVorumPostListener)
end

local function reloadNewPost()
	cancelAllLoad()

	setActivityIndicatorFnc(true)
	isNotShownNoPost = false
	getFilterData("new")
	scrollView:deleteAllPost()
	if(filterData.isMyCountry)then
		if(userData.country=="" or userData.country==nil)then
			setActivityIndicatorFnc(false)
			noPostShowFnc()
			return
		end
	end

	newNetworkFunction.getVorumPost(filterData,getVorumPostListener)
end

function scene.refresh()
	reloadNewPost()
end
----------------------type begin
local function changeFilterChoiceFnc(id)
	filterChoice = id
	
	local vorumTabFilterData = {}
	vorumTabFilterData.searchType = filterChoice
	saveData.save(global.vorumTabFilterDataPath,global.TEMPBASEDIR,vorumTabFilterData)
	reloadNewPost()
	
end
local function touch_changeFilterChoiceFnc(event)
	scrollView:checkFocusToScrollView(event)
	if(event.phase=="ended" or event.phase=="cancelled")then
		if(filterChoice~=event.target.id)then
			cancelAllLoad()--cancel all network connection
			changeFilterChoiceFnc(event.target.id)
		end
	end
	return true
end
local function setDefaultFilterFnc(event)
	changeFilterChoiceFnc(event.id)
end
---------------------type end

local function headerCreateFnc(newChangeHeaderOption)
	temp_changeHeaderOption = newChangeHeaderOption or global.newSceneHeaderOption
	headerObjects = headerView.createVorumHeaderObjects("main")
	headerObjects = {}
	headerObjects.title = display.newImage("Image/Header/vorum.png", true)
	headerObjects.leftButton = headerView.categoryButtonCreation()
	headerObjects.rightButton = headerView.searchButtonCreation(sceneOptions,nil,headerCreateFnc)
	
	header = headTabFnc.getHeader()
	header.alpha = 1
	header = headTabFnc.changeHeaderView(headerObjects,temp_changeHeaderOption, scrollViewToTop)
	
	tabbar = headTabFnc.getTabbar()
	if (tabbar == nil) then
		tabbar = headTabFnc.createNewTabbar(projectObjectSetting.tabbar)
	end
	tabbar.alpha = 1
	headTabFnc.setDisplayStatus(true)
	
	backSceneHeaderOption = nil
end
-- Create the scene
function scene:createScene( event )
	
	debugLog( "Creating " .. LOCAL_SETTINGS.NAME .. " Scene")
	display.setStatusBar( display.DefaultStatusBar )
	sceneGroup = self.view

	if(event.params)then
		changeHeaderOptionPassIn = event.params --get user data
		if(type(changeHeaderOptionPassIn)=="table")then
			backSceneHeaderOption = changeHeaderOptionPassIn.backSceneHeaderOption --now it is back scene
		end
	end
	userData = saveData.load(global.userDataPath)
	userId = userData.id
	
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
													postSpace = 35
												}

	--------------- type (global and my country) begin
	
	local vorumTabFilterData = saveData.load(global.vorumTabFilterDataPath,global.TEMPBASEDIR)
	if(vorumTabFilterData)then
		if(vorumTabFilterData.searchType)then
			filterChoice = vorumTabFilterData.searchType
		end
	end
	
	filterOption = {
		choices = {localization.getLocalization("vorum_global"),localization.getLocalization("vorum_myCountry")},
		choicesId = {"global","myCountry"},
		leftImagePath_isSelected = "Image/Filter/leftSelect.png",
		leftImagePath_isNotSelected = "Image/Filter/leftNotSelect.png",
		rightImagePath_isSelected = "Image/Filter/rightSelect.png",
		rightImagePath_isNotSelected ="Image/Filter/rightNotSelect.png",
		choicesListener = {touch_changeFilterChoiceFnc,touch_changeFilterChoiceFnc},
		y = 20,
		font = "Helvetica",
		fontSize = 28.06,
		textColor = { 1, 1, 1},
		choiceOffset = 2,
		-- default = filterChoice,
		-- defaultListener = setDefaultFilterFnc,
	}
	filterOption = optionModule.new(filterOption)
	scrollView:setScrollViewHead(filterOption, 100)
	filterOption:setDefault(filterChoice,setDefaultFilterFnc)

	sceneGroup:insert(scrollView)
	--set header and tabber toFront
	if (header) then
		header:toFront()
	end
	if (tabbar) then
		tabbar:toFront()
	end
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
	
	tabbar:setSelected( 3 )  
	global.currentSceneNumber = 3
	-- Place the code below

	local badgeNum = native.getProperty("applicationIconBadgeNumber")
	if (badgeNum == nil) then
		badgeNum = 0
	end
	tabbar = headTabFnc.getTabbar()
	noticeBadge.setBadge(tabbar, badgeNum)
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