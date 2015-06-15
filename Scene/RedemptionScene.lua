---------------------------------------------------------------
-- TemplateScene.lua
--
-- Template for Scene
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
--local resDir = (...):match("(.-)[^%.]+$")

-- Local Constant Setting
local LOCAL_SETTINGS = {
						NAME = "RedemptionScene",		-- Scene name to show in console
						RES_DIR = "Image/Redemption/",	-- Common resource directory for scene
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
local headerView = require( "ProjectObject.HeaderView" )
local headTabFnc = require( "ProjectObject.HeadTabFnc" )
local json = require( "json" )
local scrollViewForPost = require( "ProjectObject.ScrollViewForPost" )
local sizableActivityIndicator = require("Module.SizableActivityIndicator")
local global = require( "GlobalVar.global" )
local saveData = require( "SaveData.SaveData" )
local networkFunction = require("Network.newNetworkFunction")
local stringUtility = require("SystemUtility.StringUtility")
local networkFile = require("Network.NetworkFile")
local customSpinner = require("ProjectObject.CustomSpinner")

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
-- local ROW_HEIGHT = 124
local couponMask = graphics.newMask(LOCAL_SETTINGS.RES_DIR .. "RedemptionMask.png")
local COUPON_WIDTH = 200
local COUPON_HEIGHT = 160
local COUPON_X = 110
local COUPON_Y = 90
local TEXT_X = 250
local TEXT_Y = 70
local TIMER_Y_WITH_TEXT = 130
local TIMER_Y_NO_TEXT = 100

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
--Create a storyboard scene for this module
local scene = storyboard.newScene()
local getNoticNum = 10
local getCouponTimer
local activityIndicator
local couponData
local couponGroupBgArray
local countDownTimer

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
	storyboard.gotoScene("Scene.SettingTabScene", global.backSceneOption)
end

local function decCountDownTimer()
	if (couponGroupBgArray) then
		for i = 1, #couponGroupBgArray do
			couponTimer = couponGroupBgArray[i].couponTimer
			couponTimer.remainTime = couponTimer.remainTime - 1
			local displayText = couponTimer.displayText
			if (displayText.parent) then
				if (couponTimer.remainTime > 86400) then			-- more than 1 day
					displayText.text = localization.getLocalization("redemption_MoreThan1Day")
					displayText:setFillColor(0, 0.5, 0)
				elseif (couponTimer.remainTime > 0) then			-- less than 1 day but still valid
					local secRemain = couponTimer.remainTime % 60
					local minRemain = math.floor(couponTimer.remainTime / 60) % 60
					local hourRemain = math.floor(couponTimer.remainTime / 3600)
					displayText.text = localization.getLocalization("redemption_Remain")
											.. tostring(hourRemain) .. localization.getLocalization("redemption_Hour")
											.. tostring(minRemain) .. localization.getLocalization("redemption_Min")
											.. tostring(secRemain) .. localization.getLocalization("redemption_Sec")
					displayText:setFillColor(0, 0.5, 0)
				else										-- expired
					displayText.text = localization.getLocalization("redemption_Invalid")
					displayText:setFillColor(1, 0, 0)
				end
			end
		end
	end
end

local function resetCouponTimer()
	if (couponGroupBgArray) then
		if (countDownTimer) then
			timer.cancel(countDownTimer)
			countDownTimer = nil
		end
		local curTime = os.time()
		for i = 1, #couponGroupBgArray do
			couponGroupBgArray[i].couponTimer.remainTime = couponGroupBgArray[i].couponTimer.expireTime - curTime + 1
		end
		decCountDownTimer()
		countDownTimer = timer.performWithDelay(1000, decCountDownTimer, 0)
	end
end

local function systemListener(event)
	if (event.type == "applicationSuspend") then
		if (countDownTimer) then
			timer.cancel(countDownTimer)
			countDownTimer = nil
		end
	elseif (event.type == "applicationResume") then
		resetCouponTimer()
	end
end

-- Create the scene
function scene:createScene( event )
	debugLog( "Creating " .. LOCAL_SETTINGS.NAME .. " Scene")
	display.setStatusBar( display.DefaultStatusBar )
	local sceneGroup = self.view

	--header
	local header = headTabFnc.getHeader()
	local tabbar = headTabFnc.getTabbar()
	if (tabbar == nil) then
		tabbar = headTabFnc.createNewTabbar(projectObjectSetting.tabbar)
	end
	headTabFnc.setDisplayStatus(true)
	--
	display.setDefault("background",1,1,1)

	local scrollView = scrollViewForPost.newScrollView{
												backgroundColor = {243/255,243/255,243/255},
												left = 0,
												top = header.headerHeight,
												width = display.contentWidth,
												height = display.contentHeight - header.headerHeight,
												bottomPadding = 0,
												-- scrollHeight = display.contentHeight * 2,
												horizontalScrollDisabled = true,
												listener = svListener,
												postSpace = 0
											}

	local userData = saveData.load(global.userDataPath)

	local getUserCouponFnc

	local function couponTouchListener(event)
		if (event.phase == "began") then
			if (scrollView:getView()._velocity ~= 0) then
				scrollView:takeFocus(event)
				return false
			end
		end
		if (math.abs(event.yStart - event.y) > 5) then
			scrollView:takeFocus(event)
			return false
		end
		if (event.phase == "ended") then
			local couponTime = event.target.couponTimer.remainTime
			if (couponTime > 0) then
				local sceneOption = {
										effect = "slideLeft",
										time = 400,
										params =
										{
											couponData = event.target.couponData,
										}
									}
				storyboard.gotoScene("Scene.CouponScene", sceneOption)
			end
		end
		return true
	end

	-- local function loadCouponCompleteListener(couponGroup, couponImg)
	-- 	if ((couponImg ~= nil) and (couponGroup.parent ~= nil)) then
	-- 		if (couponGroup.couponPlaceHolderBg) then
	-- 			display.remove(couponGroup.couponPlaceHolderBg)
	-- 			couponGroup.couponPlaceHolderBg = nil
	-- 		end
	-- 		if (couponGroup.couponPlaceHolderPic) then
	-- 			display.remove(couponGroup.couponPlaceHolderPic)
	-- 			couponGroup.couponPlaceHolderPic = nil
	-- 		end
	-- 		couponGroup:insert(couponImg)
	-- 		local couponNewScale
	-- 		if (couponImg.contentWidth < COUPON_WIDTH) then
	-- 			couponNewScale = COUPON_WIDTH / couponImg.contentWidth
	-- 		end
	-- 		if (couponImg.contentHeight < COUPON_HEIGHT) then
	-- 			couponNewScale = COUPON_HEIGHT / couponImg.contentHeight
	-- 		end
	-- 		if (couponNewScale) then
	-- 			couponImg.xScale = couponNewScale
	-- 			couponImg.yScale = couponNewScale
	-- 		end
	-- 		couponImg.x = COUPON_X
	-- 		couponImg.y = COUPON_Y
	-- 		couponImg:setMask(couponMask)
	-- 	elseif (couponImg) then
	-- 		display.remove(couponImg)
	-- 	end
	-- end

	local function getUserCouponListener(event)
		if (event.isError) then
			getCouponTimer = timer.performWithDelay(1000, getUserCouponFnc)
		else
			couponGroupBgArray = {}
			timer.cancel(getCouponTimer)
			getCouponTimer = nil
			activityIndicator:setEnable(false)
			local couponData = event.couponData
			local scrollViewGroup = scrollView:getView()
			local postHeight = 180
			local couponCount = 0
			if ((couponData ~= nil) and (#couponData > 0)) then
				scrollView:setIsLocked(false)
				local couponTotal = #couponData
				local systemTime = os.time()
				for i = 1, couponTotal do
					local curCouponData = couponData[i]
					local couponExpireTimeInSec = curCouponData.expire_time
					local couponTimeRemain = couponExpireTimeInSec - systemTime
					if ((curCouponData ~= nil) and (couponTimeRemain > 0)) then
						couponCount = couponCount + 1
						local couponGroup = display.newGroup()
						local couponGroupBg = display.newRect(couponGroup, display.contentWidth * 0.5, postHeight * 0.5, display.contentWidth + 10, postHeight)
						couponGroupBg:setFillColor(1)
						couponGroupBg:setStrokeColor(0)
						couponGroupBg.strokeWidth = 2
						couponGroupBg.couponData = curCouponData
						couponGroupBg:addEventListener("touch", couponTouchListener)
						local couponPlaceHolderBg = display.newRect(couponGroup, COUPON_X, COUPON_Y, COUPON_WIDTH, COUPON_HEIGHT)
						couponPlaceHolderBg:setFillColor(0.7)
						if ((type(curCouponData.pic) == "string") and (curCouponData.pic ~= "")) then
							local couponPlaceHolderPic = customSpinner.new(300)
							couponGroup:insert(couponPlaceHolderPic)
							couponPlaceHolderPic.xScale = 100 / couponPlaceHolderPic.width
							couponPlaceHolderPic.yScale = 100 / couponPlaceHolderPic.height
							couponPlaceHolderPic.x = COUPON_X
							couponPlaceHolderPic.y = COUPON_Y
							-- couponGroup.couponPlaceHolderBg = couponPlaceHolderBg
							-- couponGroup.couponPlaceHolderPic = couponPlaceHolderPic
							local function insertCouponPic(fileInfo)
								if (couponGroup.parent ~= nil) then
									local couponPic = display.newImage(couponGroup, fileInfo.path, fileInfo.baseDir, true)
									if (couponPic ~= nil) then 
										if (couponPlaceHolderBg) then
											display.remove(couponPlaceHolderBg)
										end
										if (couponPlaceHolderPic) then
											display.remove(couponPlaceHolderPic)
										end
										local newScale = COUPON_WIDTH / couponPic.contentWidth
										if ((COUPON_HEIGHT / couponPic.contentHeight) > newScale) then
											newScale = COUPON_HEIGHT / couponPic.contentHeight
										end
										couponPic.xScale = newScale
										couponPic.yScale = newScale
										couponPic.x = COUPON_X
										couponPic.y = COUPON_Y
										couponPic:setMask(couponMask)
										couponPic.maskScaleX = 1 / newScale
										couponPic.maskScaleY = 1 / newScale
									end
								end
							end
							local function couponPicListener(event)
								if (event.isError) then
								else
									insertCouponPic({path = event.path, baseDir = event.baseDir})
								end
							end
							local couponPicFilePath = "coupon/" .. tostring(curCouponData.id) .. "/img"
							local couponPicInfo = networkFunction.getVorumFile(curCouponData.pic, couponPicFilePath, couponPicListener)
							if ((couponPicInfo ~= nil) and (couponPicInfo.request == nil)) then
								insertCouponPic(couponPicInfo)
							end
						else
							couponPlaceHolderBg:setStrokeColor(0)
							couponPlaceHolderBg.strokeWidth = 1
							local noCouponLine = display.newLine(couponGroup, COUPON_X - COUPON_WIDTH * 0.5, COUPON_Y - COUPON_HEIGHT * 0.5, COUPON_X + COUPON_WIDTH * 0.5, COUPON_Y + COUPON_HEIGHT * 0.5)
							noCouponLine:setStrokeColor(0)
						end
						local timerY = TIMER_Y_NO_TEXT
						if (curCouponData.text) then
		
							local couponTextToDisplay = curCouponData.text
							local couponTextStartCutIdx = string.find(couponTextToDisplay, " ", 50)
							if ((couponTextStartCutIdx == nil) and (string.len(couponTextToDisplay) > 50)) then
								couponTextStartCutIdx = 50
							end
							if (couponTextStartCutIdx) then
								couponTextStartCutIdx = couponTextStartCutIdx + 1
								local charSize = stringUtility.getUtf8Size(string.byte(couponTextToDisplay, couponTextStartCutIdx, couponTextStartCutIdx + 1))
								while ((charSize ~= nil) and (charSize <= 0)) do
									couponTextStartCutIdx = couponTextStartCutIdx + 1
									charSize = stringUtility.getUtf8Size(string.byte(couponTextToDisplay, couponTextStartCutIdx, couponTextStartCutIdx + 1))
								end
								couponTextStartCutIdx = couponTextStartCutIdx - 1
								if (charSize) then
									couponTextToDisplay = string.sub(couponTextToDisplay, 1, couponTextStartCutIdx) .. "..."
								else
									couponTextToDisplay = string.sub(couponTextToDisplay, 1, couponTextStartCutIdx)
								end									
							end
							local couponText = display.newText(couponGroup, couponTextToDisplay, TEXT_X, TEXT_Y, display.contentWidth - TEXT_X - 20, 0, "Helvetica", 24)
							couponText.anchorX = 0
							couponText:setFillColor(0)
							timerY = TIMER_Y_WITH_TEXT
						end
						local couponCountDownText = display.newText(couponGroup, " ", TEXT_X, timerY, "Helvetica", 24)
						couponCountDownText.anchorX = 0
						couponGroupBgArray[couponCount] = couponGroupBg
						couponGroupBg.couponTimer = {displayText = couponCountDownText, expireTime = couponExpireTimeInSec}
						scrollView:addNewPost(couponGroup, postHeight)
					end
				end
				local bottomPadding = display.contentHeight - (couponTotal * postHeight + header.headerHeight)
				if(bottomPadding > tabbar.height) then
					bottomPadding = 0
				elseif (bottomPadding <= 0) then
					bottomPadding = tabbar.height
				else
					bottomPadding = tabbar.height - bottomPadding
				end
				scrollViewGroup._bottomPadding = bottomPadding
			end
			if (couponCount == 0) then
				local couponGroup = display.newGroup()
				local noCouponText = display.newText(couponGroup, localization.getLocalization("redemption_noCoupon"), display.contentWidth * 0.5, display.contentHeight * 0.5 - header.headerHeight - 100, "Helvetica", 72)
				noCouponText:setFillColor(0)
				local getCouponTextOption = {
												parent = couponGroup,
												text = localization.getLocalization("redemption_getCouponByVoting"),
												x = display.contentWidth * 0.5,
												y = noCouponText.y + noCouponText.contentHeight,
												width = display.contentWidth * 0.9,
												font = "Helvetica",
												fontSize = 48,
												align = "center",
											}
				local getCouponText = display.newText(getCouponTextOption)
				getCouponText.anchorY = 0
				getCouponText:setFillColor(0)
				scrollView:addNewPost(couponGroup, 200)
				scrollViewGroup._bottomPadding = 0
				scrollView:setIsLocked(true)
			else
				resetCouponTimer()
			end
		end
	end

	getUserCouponFnc = function()
		networkFunction.getUserCoupon(getUserCouponListener)
		-- networkFunction.getUserCoupon(userData.user_id, userData.session, getUserCouponListener)
	end

	getCouponTimer = timer.performWithDelay(1, getUserCouponFnc)
	if (activityIndicator == nil) then
		activityIndicator = sizableActivityIndicator.newActivityIndicator(display.contentWidth, display.contentHeight)
		activityIndicator.x = display.contentWidth * 0.5
		activityIndicator.y = display.contentHeight * 0.5
		scrollView:insert(activityIndicator)
	end
	activityIndicator:setEnable(true)

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
	debugLog( "Will enter " .. LOCAL_SETTINGS.NAME .. " Scene")

	local sceneOption = {}
	for k, v in pairs(global.newSceneHeaderOption) do
		sceneOption[k] = v
	end
	if (storyboard.getPrevious() == "Scene.CouponScene") then
		sceneOption.dir = "right"
	end

	local headerObjects = headerView.createVorumHeaderObjects("redemption")
	local header = headTabFnc.changeHeaderView(headerObjects, sceneOption)
	-- adding key event for scene transition
	Runtime:addEventListener( "key", onSceneTransitionKeyEvent )

	-- Place the code below
end

function scene:enterScene( event )
	debugLog( "Entering " .. LOCAL_SETTINGS.NAME .. " Scene")
	
	Runtime:removeEventListener( "key", onSceneTransitionKeyEvent )
	-- adding check system key event
	Runtime:addEventListener( "key", onKeyEvent )

	-- remove previous scene's view
	-- storyboard.purgeScene( "Scene.CouponScene" )
	storyboard.purgeAll()

	-- Place the code below
	resetCouponTimer()
	Runtime:addEventListener("system", systemListener)
end

-- Called when scene is about to move offscreen:
function scene:exitScene()
	debugLog( "Exiting " .. LOCAL_SETTINGS.NAME .. " Scene")
	-- removing check system key event
	Runtime:removeEventListener( "key", onKeyEvent )

	-- Place the code below
	if (countDownTimer) then
		timer.cancel(countDownTimer)
		countDownTimer = nil
	end
	if (getCouponTimer) then
		timer.cancel(getCouponTimer)
		getCouponTimer = nil
	end
	couponData = nil
	networkFunction.cancelAllConnection()
	-- loadImage.cancelAllDowload()
	Runtime:removeEventListener("system", systemListener)
end

-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	debugLog( "Destroying " .. LOCAL_SETTINGS.NAME .. " Scene" )
	
	-- Place the code below
	if (activityIndicator) then
		display.remove(activityIndicator)
		activityIndicator = nil
	end
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