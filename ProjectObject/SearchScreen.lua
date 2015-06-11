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
require ( "SystemUtility.Debug" )
local localization = require("Localization.Localization")
local projectObjectSetting = require( "Setting.ProjectObjectSetting" )
local headTabFnc = require( "ProjectObject.HeadTabFnc" )
local coronaTextField = require("Module.CoronaTextField")
local scrollViewForPost = require( "ProjectObject.ScrollViewForPost" )
local saveData = require( "SaveData.SaveData" )
local global = require( "GlobalVar.global" )
local json = require( "json" )
local stringUtility = require("SystemUtility.StringUtility")
-- local networkFunction = require("Network.NetworkFunction")
local optionModule = require("Module.Option")
local navScene = require("Function.NavScene")
local networkFile = require("Network.NetworkFile")
local newNetworkFunction = require("Network.newNetworkFunction")
local sizableActivityIndicatorFnc = require("Module.SizableActivityIndicator")
---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local COMMENT_DISPLAYLENGTH = 40
local GET_POST_NUM = 8
local GET_OLD_POST_NUM = 6
local USERICON_WIDTH = 102
local USERICON_HEIGHT = 102
local USERICON_MASKPATH = "Image/User/creatorMask.png"
local TRANSITION_TIME = 300
---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
--Create a storyboard scene for this module
local returnGroup = {}
local screenGroup
local scrollView
local filterOption

local searchType = 1--set default
-- two type
--1.post
--2.people

local SEARCHOBJECT_BEGINY = 0
local SEARCHOBJECT_HEIGHT = 124

local searchObjectY = SEARCHOBJECT_BEGINY

local clockTimer

local searchString = ""


local newSceneOptions = {}
newSceneOptions.effect = "slideLeft"
newSceneOptions.time = 600


local userData
local headerObjects
local group_searchTextField
local header

local lastSceneHeaderObjCreateFnc

local curSceneData = nil
local curSceneOptions

local searchStringPosBegin
local searchStringPosEnd
local searchStringLen

local searchParams = {}
searchParams.offset = nil
searchParams.limit = nil
searchParams.searchStr = ""

local isNotShownNoResult = false

local loadingIcon
---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
--key event
local onBackButtonPressed


local function onKeyEvent( event )
	if event.phase == "up" and event.keyName == "back" then
		onBackButtonPressed()
	end
	return true
end


local function setActivityIndicatorFnc(boolean_loadingSwitch)
	if(not loadingIcon and boolean_loadingSwitch)then
		loadingIcon = sizableActivityIndicatorFnc.newActivityIndicator(display.contentWidth,display.contentHeight)
		if(type(scrollView) == "table")then
			scrollView:insert(loadingIcon)
		end
		loadingIcon.x = display.contentCenterX
		loadingIcon.y = display.contentCenterY-header.height/2
		loadingIcon:setBgColor({0,0,0,0})
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
	newNetworkFunction.cancelAllConnection()
end


local function noResultShowFnc()
	local noResultGroup = display.newGroup()
	local noResultString
	if(searchType=="post")then
		noResultString = localization.getLocalization("search_post_noResult")
	else
		noResultString = localization.getLocalization("search_people_noResult")
	end
	local noResultText = {
		parent = noResultGroup,
		text = noResultString,     
		x = display.contentCenterX,
		y = display.contentCenterY-filterOption.height-header.height,
		width = 0, 
		height = 0,
		font = "Helvetica",   
		fontSize = 108,
	}

	noResultText = display.newText( noResultText )
	noResultText.anchorX = 0.5
	noResultText.anchorY = 0.5
	noResultText:setFillColor( 0, 0, 0 )
	scrollView:addNewPost(noResultGroup, display.contentHeight)
end


local function cancelSearchScene(isNoTransition)
	Runtime:removeEventListener( "key", onKeyEvent )
	searchString = ""--reset searchString
	cancelAllLoad()
	
	if (isNoTransition == true) then
		display.remove(screenGroup)
		screenGroup=nil
		
		lastSceneHeaderObjCreateFnc()
	else

		local changeHeaderOption = {
										dir = "right",
										time = TRANSITION_TIME,
										transition = easing.outQuad,
									}
		lastSceneHeaderObjCreateFnc()
		
		local touchMask = display.newRect(0, 0, display.contentWidth, display.contentHeight)
		touchMask.anchorX = 0
		touchMask.anchorY = 0
		touchMask.alpha = 0
		touchMask.isHitTestable = true
		touchMask:addEventListener("touch", function(event) return true; end)
		transition.to(screenGroup, {alpha = 0,
									time = TRANSITION_TIME + 1,
									onComplete = function(obj)
													display.remove(touchMask);
													display.remove(screenGroup)
													screenGroup=nil
												end
									})
	end
end
local function closeSearch(event)
	if(event.phase == "ended" or event.phase == "cancelled") then
		cancelSearchScene()
	end
	return true
end

onBackButtonPressed = function()
	cancelSearchScene()
end

local function createResult(resultData)
	print("abc",json.encode(resultData))

	local function goToNewScene(event)
		scrollView:checkFocusToScrollView(event)
		if (event.phase=="ended" or event.phase=="cancelled")then
			
			cancelSearchScene(true)
			newSceneOptions.params = resultData
	
			if(searchType=="post")then
				navScene.goPost(curSceneOptions,curSceneData,resultData,resultData.id)
			elseif(searchType=="people")then
				navScene.go(curSceneOptions,curSceneData,resultData,resultData.id)
			end
			
		end
		return true
	end

	local temp_userIconUrl = nil
	local temp_comment = ""
	local temp_creatorName
	
	local userId = "unknownUser"
	

	local function postSearchDescDisplay()
		searchStringLen = string.len(resultData.text)
		searchStringPosBegin,searchStringPosEnd = string.find(string.lower(resultData.text),string.lower(searchString))
		if(searchStringPosBegin)then
			if(searchStringLen>COMMENT_DISPLAYLENGTH)then
				if((searchStringPosEnd-searchStringPosBegin)>=COMMENT_DISPLAYLENGTH)then
					temp_comment = string.sub(resultData.text,searchStringPosBegin,searchStringPosEnd)
				else
					local searchStringLengthOffset = COMMENT_DISPLAYLENGTH-searchStringLen
					local searchStringLengthOffsetOver2 = math.floor(searchStringLengthOffset/2)
					temp_comment = string.sub(resultData.text,searchStringPosBegin-searchStringLengthOffsetOver2,searchStringPosEnd+searchStringLengthOffsetOver2)
				end
			else
				temp_comment = resultData.text
			end
		end
	end
	
	if(resultData and searchType=="people")then
		
		if(resultData.name)then
			searchStringLen = string.len(resultData.name)
			searchStringPosBegin,searchStringPosEnd = string.find(string.lower(resultData.name),string.lower(searchString))
			if(searchStringPosBegin)then
				temp_comment = resultData.name
			elseif(resultData.email)then
				searchStringLen = string.len(resultData.email)
				searchStringPosBegin,searchStringPosEnd = string.find(string.lower(resultData.email),string.lower(searchString))
				if(searchStringPosBegin)then
					temp_comment = resultData.email
				end
			end
		elseif(resultData.email)then
			searchStringLen = string.len(resultData.email)
			searchStringPosBegin,searchStringPosEnd = string.find(string.lower(resultData.email),string.lower(searchString))
			if(searchStringPosBegin)then
				temp_comment = resultData.email
			end
		end
		if(resultData)then
			if(resultData.userId)then
				userId = resultData.userId
			end
			if(resultData.profile_pic)then
				temp_userIconUrl = resultData.profile_pic
			end
		end
	
	
	elseif(resultData and searchType=="post")then
	
		if(resultData.title)then -- get desc
			searchStringLen = string.len(resultData.title)
			searchStringPosBegin,searchStringPosEnd = string.find(string.lower(resultData.title),string.lower(searchString))
			
			if(searchStringPosBegin)then
				temp_comment = resultData.title
			else
				postSearchDescDisplay()
			end
		elseif(resultData.text)then
			postSearchDescDisplay()
		end
		
		if(type(resultData.user)=="table" and resultData.user.userId)then
			userId = resultData.user.userId
		end
		if(type(resultData.creator)=="table" )then
			if(resultData.creator.profile_pic)then
				temp_userIconUrl = resultData.creator.profile_pic
			end
			if(resultData.creator.name)then
				temp_creatorName = resultData.creator.name
			end
		end
	end
	
	
	local group_thisResult = display.newGroup()
	scrollView:addNewPost(group_thisResult, SEARCHOBJECT_HEIGHT)
	
	local background = display.newRect( 0, searchObjectY, display.contentWidth, SEARCHOBJECT_HEIGHT )
	background:setFillColor( 1 )
	background.anchorX = 0
	background.anchorY = 0
	background:addEventListener("touch",goToNewScene)
	group_thisResult:insert(background)
-------------- black underline
	local line_top = display.newLine(0,searchObjectY,display.contentWidth,searchObjectY)
	line_top:setStrokeColor( 0,0,0 )
	line_top.strokeWidth = 2
	line_top.anchorX=0
	line_top.anchorY=0
	group_thisResult:insert( line_top )
-------------- black underline
	local line_bottom = display.newLine(0,searchObjectY+SEARCHOBJECT_HEIGHT,display.contentWidth,searchObjectY+SEARCHOBJECT_HEIGHT)
	line_bottom:setStrokeColor( 0,0,0 )
	line_bottom.strokeWidth = 2
	line_bottom.anchorX=0
	line_bottom.anchorY=0
	group_thisResult:insert( line_bottom )
-------------- icon blue background
	
	local user_icon_background = display.newCircle(group_thisResult, 78, 5+searchObjectY+58, 58)
	user_icon_background.anchorX = 0.5
	user_icon_background.anchorY = 0.5


	if(string.upper(tostring(resultData.gender))=="M")then
		user_icon_background:setFillColor(unpack(global.maleColor))
	elseif(string.upper(tostring(resultData.gender))=="F")then
		user_icon_background:setFillColor(unpack(global.femaleColor))
	else
		user_icon_background:setFillColor(unpack(global.noGenderColor))
	end
	

	local user_icon_savePath = "user/" .. tostring(userId) .. "/img"
	local user_icon
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
			group_thisResult:insert( user_icon )
			user_icon:addEventListener("touch",goToNewScene)
		end
	end
	
	local function userIconListener(event)
		if (event.isError) then
		elseif (event.phase == "ended") then
			userIconFnc({path = event.path, baseDir = event.baseDir})
		end
	end

	userIconFnc({path = "Image/User/anonymous.png", baseDir = system.ResourceDirectory})--temp image
	local userIconInfo = newNetworkFunction.getVorumFile(temp_userIconUrl, user_icon_savePath, userIconListener)
	
	if ((userIconInfo ~= nil) and (userIconInfo.request == nil)) then
		userIconFnc(userIconInfo)
	end
	
	----------------- text
	
	local text_comment =
	{
		text = temp_comment, 
		x = 161,
		y = 20+searchObjectY,
		width = 420,
		height = 84	, 
		font = "Helvetica",
		fontSize=30
	}
	
	text_comment = display.newText(text_comment);
	text_comment:setFillColor( 104/255, 104/255, 104/255 )
	text_comment.anchorX=0
	text_comment.anchorY=0
	text_comment:addEventListener("touch",goToNewScene)
	group_thisResult:insert( text_comment )
	
	if(searchType=="post")then
		-- local createdBy = display.newText{
		-- 	text = localization.getLocalization("searchScreen_by")..tostring(temp_creatorName), 
		-- 	x = display.contentWidth-10,
		-- 	y = line_bottom.y-6,
		-- 	width = 420,
		-- 	height = 0	, 
		-- 	font = "Helvetica",
		-- 	fontSize=22
		-- }
		-- createdBy = display.newText(createdBy);
		-- createdBy:setFillColor( 104/255, 104/255, 104/255 )
		-- createdBy.anchorX=1
		-- createdBy.anchorY=1
		-- createdBy:addEventListener("touch",goToNewScene)
		-- group_thisResult:insert( createdBy )

	end

	return group_thisResult
	
end
local function createPostResultList(event)
	setActivityIndicatorFnc(false)
	if (event[1].isError) then
		-- print("error")
		native.showAlert(localization.getLocalization("networkError_errorTitle"),localization.getLocalization("networkError_networkError"),{localization.getLocalization("ok")})
	else
		local response = json.decode(event[1].response)
		
		if (type(response)=="table") then		-- if post data exist

			if(#response==0)then
				if(not isNotShownNoResult)then
					noResultShowFnc()
				end
				return
			end

			for i = 1, #response do
				createResult(response[i])
				searchParams.offset = searchParams.offset+1
			end
			
		else							-- if error occur
			-- print(event[1].response)
		end
	end
end
local function createPeopleResultList(event)
	setActivityIndicatorFnc(false)
	if (event[1].isError) then
		-- print("error")
		native.showAlert(localization.getLocalization("networkError_errorTitle"),localization.getLocalization("networkError_networkError"),{localization.getLocalization("ok")})
	else
		local response = json.decode(event[1].response)
		-- print(event[1].response)
		if (type(response)=="table") then		-- if post data exist

			if(#response==0)then
				if(not isNotShownNoResult)then
					noResultShowFnc()
				end
				return
			end

			for i = 1, #response do
				createResult(response[i])
				searchParams.offset = searchParams.offset+1
			end
		else							-- if error occur
			-- print(event[1].response)
		end
	end
end



local function searchFnc()
	-- print("searchString",searchString)
	cancelAllLoad()
	scrollView:deleteAllPost()
	-- searchString = "c"--test
	if(searchString~="")then
		isNotShownNoResult = false

		searchParams.offset = 0
		searchParams.limit = GET_POST_NUM
		searchParams.searchStr = searchString
		
		if(clockTimer)then
			timer.cancel( clockTimer )
		end
		if(searchType =="post")then
			setActivityIndicatorFnc(true)
			clockTimer = timer.performWithDelay( 1, function(event) 
				newNetworkFunction.searchPost(searchParams, createPostResultList)
				-- print("search post")
			end)
		elseif(searchType =="people")then
			setActivityIndicatorFnc(true)
			clockTimer = timer.performWithDelay( 1, function(event) 
				newNetworkFunction.searchUser(searchParams, createPeopleResultList)
				-- print("search people")
			end)
		end	
	end
end


local function requestOldResult()
	-- print("Old")
	if(searchString~="")then
		isNotShownNoResult = true

		searchParams.limit = GET_OLD_POST_NUM
		searchParams.searchStr = searchString
		
		if(clockTimer)then
			timer.cancel( clockTimer )
		end
		if(searchType =="post")then
			clockTimer = timer.performWithDelay( 1, function(event) 
				newNetworkFunction.searchPost(searchParams, createPostResultList)
				-- print("search post")
			end)
		elseif(searchType =="people")then
			clockTimer = timer.performWithDelay( 1, function(event) 
				newNetworkFunction.searchUser(searchParams, createPeopleResultList)
				-- print("search people")
			end)
		end	
	end	
end

local function reloadNewResult()
	-- print("New")
	searchFnc()
end


local function searchType_changeFnc(id)
	searchType = id
	--
	local searchData = {}
	searchData.searchType = searchType
	saveData.save(global.searchDataPath,global.TEMPBASEDIR,searchData)
	searchFnc()
end




local function touch_searchType(event)
	if ( event.phase == "moved" ) then
		local dy = math.abs( ( event.y - event.yStart ) )

		if ( dy > 10 ) then
			scrollView:takeFocus( event )
		end
	elseif(event.phase == "ended" or event.phase == "cancelled") then
		if(searchType ~= event.target.id)then
			searchType_changeFnc(event.target.id)
		end
	end
	return true
end
local function searchType_setDefault(event)
	searchType_changeFnc(event.id)
end

local function background_touch(event)
	-- print("This is background")
	return true
end

local function searchTextListener( event )
	-- print(event.phase, event.target)

	if ( event.phase == "began" ) then

	elseif ( event.phase == "ended" or event.phase == "submitted" ) then

	elseif ( event.phase == "editing" ) then

		local emojiTrimmedString, isEmojiDetected = stringUtility.trimEmoji(event.target.text)
		if (isEmojiDetected) then
			event.target.text = emojiTrimmedString
		end
		searchString = event.target.text
		searchFnc()
	end
end



function returnGroup.searchScreenDisplay(sceneOptions,sceneData,headerCreateFnc)
	lastSceneHeaderObjCreateFnc = headerCreateFnc

	curSceneOptions = sceneOptions
	curSceneData = sceneData

	---------------------------- background setup
	screenGroup = display.newGroup()
	--get data
	userData = saveData.load(global.userDataPath)

	-- header 
	
	headerObjects={}
	group_searchTextField = display.newGroup()
	group_searchTextField.x=0
	group_searchTextField.y=0
	group_searchTextField.anchorChildren = true
	group_searchTextField.anchorX=0
	group_searchTextField.anchorY=0
	

	local textFieldWidth = 386
	local textFieldHeight = 50
	
	searchTextField = coronaTextField:new((display.contentWidth - textFieldWidth) * 0.5, 200, textFieldWidth, textFieldHeight)
	searchTextField:setFont("Helvetica",32)

	searchTextField:setUserInputListener(searchTextListener)

	group_searchTextField:insert(searchTextField)
	
	headerObjects.title = group_searchTextField
	
	headerObjects.leftButton = display.newImage("Image/Header/back.png", true)
	headerObjects.leftButton:addEventListener("touch",closeSearch)
	
	headerObjects.rightButton =
	{
		text = "", 
		font = "Helvetica",
		fontSize=35.42
	}
	headerObjects.rightButton = display.newText( headerObjects.rightButton )
	headerObjects.rightButton:setFillColor( 78/255, 184/255, 229/255)
	
	local changeHeaderOption = {
									dir = "right",
									time = TRANSITION_TIME,
									transition = easing.outQuad,
								}
	header = headTabFnc.changeHeaderView(headerObjects, changeHeaderOption)
	header:toFront()
	--
	
	scrollView = scrollViewForPost.newScrollView{
													hideBackground = true,
													backgroundColor = {243/255,243/255,243/255},
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
													-- bottomPadding = SEARCHOBJECT_HEIGHT,
													-- scrollHeight = display.contentHeight * 2,
													horizontalScrollDisabled = true,
													verticalScrollDisabled = false,	
													listener = svListener,
													requestDataListener = requestOldResult,
													reloadDataListener = reloadNewResult,
													postSpace = -0
												}
	
	
	local background = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
	background:setFillColor( 1 )
	background.anchorX = 0
	background.anchorY = 0
	-- background.alpha = 0.7
	background:addEventListener("touch",background_touch)
	screenGroup:insert(background)
	

	
	
	filterOption = {
		choices = {localization.getLocalization("search_post"),localization.getLocalization("search_people")},
		choicesId = {"post","people"},
		leftImagePath_isSelected = "Image/Filter/leftSelect.png",
		leftImagePath_isNotSelected = "Image/Filter/leftNotSelect.png",
		rightImagePath_isSelected = "Image/Filter/rightSelect.png",
		rightImagePath_isNotSelected = "Image/Filter/rightNotSelect.png",
		choicesListener = {touch_searchType,touch_searchType},
		y = 20,
		font = "Helvetica",
		fontSize = 28.06,
		textColor = { 1, 1, 1},
		choiceOffset = 2,
	}
	filterOption = optionModule.new(filterOption)
	
	scrollView:setScrollViewHead(filterOption, 100)
	--------------- search type (post and people) end
	screenGroup:insert(scrollView)
	------ set default search type	
	filterOption:setDefault(searchType,searchType_setDefault)
	local touchMask = display.newRect(0, 0, display.contentWidth, display.contentHeight)
	touchMask.anchorX = 0
	touchMask.anchorY = 0
	touchMask.alpha = 0
	touchMask.isHitTestable = true
	touchMask:addEventListener("touch", function(event) return true; end)
	screenGroup.alpha = 0
	transition.to(screenGroup, {alpha = 1,
								time = TRANSITION_TIME + 1,
								onComplete = function(obj)
												display.remove(touchMask);
												searchTextField:setKeyboardFocus();
											end
								})
	Runtime:addEventListener( "key", onKeyEvent )
end

return returnGroup
