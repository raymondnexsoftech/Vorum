---------------------------------------------------------------
-- CouponScene.lua
--
-- Coupon Scene
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
--local resDir = (...):match("(.-)[^%.]+$")

-- Local Constant Setting
local LOCAL_SETTINGS = {
						NAME = "CouponScene",			-- Scene name to show in console
						RES_DIR = "Image/Redemption/",	-- Common resource directory for scene
						DOC_DIR = "",					-- Common document directory for scene
						}

---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------
local storyboard = require ( "storyboard" )
local widget = require ( "widget" )
require ( "SystemUtility.Debug" )
local headerView = require( "ProjectObject.HeaderView" )
local headTabFnc = require( "ProjectObject.HeadTabFnc" )
local networkFunction = require("Network.newNetworkFunction")
local localization = require("Localization.Localization")
local global = require( "GlobalVar.global" )
local networkFile = require("Network.NetworkFile")
local customSpinner = require("ProjectObject.CustomSpinner")

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
--Create a storyboard scene for this module
local scene = storyboard.newScene()

local countDownTimer
local couponCountDownText
local couponExpireTime
local couponRemainTime
local couponPicGroup
local couponTextGroup
---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
-- Function for back button
local function onBackButtonPressed()
	storyboard.gotoScene("Scene.RedemptionScene", global.backSceneOption)
end

local function decCountDownTimer()
	couponRemainTime = couponRemainTime - 1
	if (couponCountDownText.parent) then
		if (couponRemainTime > 86400) then			-- more than 1 day
			couponCountDownText.text = localization.getLocalization("redemption_MoreThan1Day")
			couponCountDownText:setFillColor(0, 0.5, 0)
		elseif (couponRemainTime > 0) then			-- less than 1 day but still valid
			local secRemain = couponRemainTime % 60
			local minRemain = math.floor(couponRemainTime / 60) % 60
			local hourRemain = math.floor(couponRemainTime / 3600)
			couponCountDownText.text = localization.getLocalization("redemption_Remain")
									.. tostring(hourRemain) .. localization.getLocalization("redemption_Hour")
									.. tostring(minRemain) .. localization.getLocalization("redemption_Min")
									.. tostring(secRemain) .. localization.getLocalization("redemption_Sec")
			couponCountDownText:setFillColor(0, 0.5, 0)
		else										-- expired
			couponCountDownText.text = localization.getLocalization("redemption_Invalid")
			couponCountDownText:setFillColor(1, 0, 0)
		end
	end
end

local function resetCouponTimer()
	if (countDownTimer) then
		timer.cancel(countDownTimer)
		countDownTimer = nil
	end
	if (couponCountDownText) then
		couponRemainTime = couponExpireTime - os.time() + 1
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
	local group = self.view

	-- Place the code below
	--header
	local header = headTabFnc.getHeader()
	local tabbar = headTabFnc.getTabbar()
	if (tabbar == nil) then
		tabbar = headTabFnc.createNewTabbar(projectObjectSetting.tabbar)
	end
	headTabFnc.setDisplayStatus(true)
	--
	display.setDefault("background",1,1,1)

	local displayText
	local couponTimer

	local scrollView = widget.newScrollView{
												backgroundColor = {243/255,243/255,243/255},
												left = 0,
												top = header.headerHeight,
												width = display.contentWidth,
												height = display.contentHeight - header.headerHeight,
												bottomPadding = 0,
												-- scrollHeight = display.contentHeight * 2,
												horizontalScrollDisabled = true,
											}

	local curCouponData = event.params.couponData
	if (curCouponData) then
		local couponGroup = display.newGroup()
		couponTextGroup = display.newGroup()
		couponTextGroup.y = 20
		scrollView:insert(couponTextGroup)
		couponCountDownText = display.newText(couponTextGroup, " ", display.contentWidth * 0.5, 0, "Helvetica", 30)
		couponCountDownText.anchorY = 0
		couponExpireTime = curCouponData.expire_time
		if (curCouponData.text) then
			local couponTextOption = {
										parent = couponTextGroup,
										text = curCouponData.text,     
										x = display.contentWidth * 0.05,
										y = 70,
										width = display.contentWidth * 0.9,
										font = "Helvetica",   
										fontSize = 30,
										align = "left",
									}
			local couponText = display.newText(couponTextOption)
			couponText.anchorX = 0
			couponText.anchorY = 0
			couponText:setFillColor(0)
		end
		if ((type(curCouponData.pic) == "string") and (curCouponData.pic ~= "")) then
			couponPicGroup = display.newGroup()
			scrollView:insert(couponPicGroup)
			local couponPlaceHolderWidth = display.contentWidth * 0.9
			local couponPlaceHolderHeight = couponPlaceHolderWidth * 0.8
			local couponPlaceHolderX = display.contentWidth * 0.5
			local couponPlaceHolderY = couponPlaceHolderHeight * 0.5 + 10
			local couponPlaceHolderBg = display.newRect(couponPicGroup, couponPlaceHolderX, couponPlaceHolderY, couponPlaceHolderWidth, couponPlaceHolderHeight)
			couponPlaceHolderBg:setFillColor(0.7)
			-- local couponPlaceHolderPic = display.newImage(couponPicGroup, LOCAL_SETTINGS.RES_DIR .. "placeholder.png", true)
			local couponPlaceHolderPic = customSpinner.new(300)
			couponPicGroup:insert(couponPlaceHolderPic)
			couponPlaceHolderPic.x = couponPlaceHolderX
			couponPlaceHolderPic.y = couponPlaceHolderY
			local function insertCouponPic(fileInfo)
				if (couponPicGroup.parent ~= nil) then
					local couponPic = display.newImage(couponPicGroup, fileInfo.path, fileInfo.baseDir, true)
					if (couponPic ~= nil) then
						if (couponPlaceHolderBg) then
							display.remove(couponPlaceHolderBg)
						end
						if (couponPlaceHolderPic) then
							display.remove(couponPlaceHolderPic)
						end
						local couponWidth = display.contentWidth * 0.9
						local couponX = display.contentWidth * 0.5
						local couponNewScale = couponWidth / couponPic.contentWidth
						couponPic.xScale = couponNewScale
						couponPic.yScale = couponNewScale
						couponPic.x = couponX
						couponPic.y = couponPic.contentHeight * 0.5 + 10
						couponTextGroup.y = couponPic.contentHeight + 30
						local tabbar = headTabFnc.getTabbar()
						scrollView:setScrollHeight(couponTextGroup.y + couponTextGroup.contentHeight + tabbar.height)
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
			if (couponPlaceHolderBg.parent ~= nil) then
				couponTextGroup.y = couponPlaceHolderY + (couponPlaceHolderHeight * 0.5) + 30
			end
		end
		resetCouponTimer()
	else
		-- TODO: coupon data not found
	end
	group:insert(scrollView)
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
	local headerObjects = headerView.createVorumHeaderObjects("coupon")
	local header = headTabFnc.changeHeaderView(headerObjects, global.newSceneHeaderOption)
end

function scene:enterScene( event )
	debugLog( "Entering " .. LOCAL_SETTINGS.NAME .. " Scene")
		
	-- removing key event for scene transition
	Runtime:removeEventListener( "key", onSceneTransitionKeyEvent )
	-- adding check system key event
	Runtime:addEventListener( "key", onKeyEvent )

	-- remove previous scene's view
--	storyboard.purgeScene( lastScene )
	-- storyboard.purgeAll()

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
	Runtime:removeEventListener("system", systemListener)
	-- loadImage.cancelAllDowload()
end

-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	debugLog( "Destroying " .. LOCAL_SETTINGS.NAME .. " Scene" )

	-- Place the code below
	if (couponPicGroup) then
		display.remove(couponPicGroup)
		couponPicGroup = nil
	end
	if (couponTextGroup) then
		display.remove(couponTextGroup)
		couponTextGroup = nil
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