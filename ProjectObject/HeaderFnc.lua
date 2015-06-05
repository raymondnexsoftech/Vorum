---------------------------------------------------------------
-- HeaderFnc.lua
--
-- Header Function
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
--local resDir = (...):match("(.-)[^%.]+$")

-- Local Constant Setting
local LOCAL_SETTINGS = {
						RES_DIR = "",					-- Common resource directory for scene
						DOC_DIR = "",					-- Common document directory for scene
						}

---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------
require ( "SystemUtility.Debug" )

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local DEFAULT_TRANSITION_TIME = 100
local BUTTON_TO_EDGE_SPACING = 15
local TRANSITION_OFFSET = 100

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
local headerBase
local headerView
local headerViewBg
local headerLeftBtn
local headerRightBtn
local headerTitle
local headerMask
local newHeaderMask
local transitionLockCount = 0
local subHeader



local headerDisplayObject
local headerObject
local isHeaderBtnEnable = true
local onHeaderPressedListener
local onStatusBarPressedListener

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
local headerFnc = {}

local function headerMaskingTouchListener(event)
	-- if (event.phase == "began") then
	-- 	if (event.y < headerBase.statusBarHeight) then
	-- 		event.target.isStatusBarPressed = true
	-- 		display.getCurrentStage():setFocus(event.target)
	-- 	end
	-- 	-- return true
	-- elseif (event.target.isStatusBarPressed) then
	-- 	if (event.phase == "ended") then
	-- 		if (event.y < headerBase.statusBarHeight) then
	-- 			if (type(onStatusBarPressedListener) == "function") then
	-- 				onStatusBarPressedListener()
	-- 			end
	-- 		end
	-- 		display.getCurrentStage():setFocus(nil)
	-- 		event.target.isStatusBarPressed = false
	-- 	elseif (event.phase == "cancelled") then
	-- 		display.getCurrentStage():setFocus(nil)
	-- 		event.target.isStatusBarPressed = false
	-- 	end
	-- 	return true
	-- end
	if ((isHeaderBtnEnable ~= true) or (transitionLockCount > 0)) then
		return true
	elseif (headerBase.y < 0) then
		return true
	end
end

local function headerBgTouchListener(event)
	if (event.phase == "began") then
		display.getCurrentStage():setFocus(event.target)
		event.target.isHeaderBgPressed = true
	elseif (event.target.isHeaderBgPressed) then
		if (event.phase == "ended") then
			if (type(onHeaderPressedListener) == "function") then
				onHeaderPressedListener()
			end
			display.getCurrentStage():setFocus(nil)
			event.target.isHeaderBgPressed = false
		elseif (event.phase == "cancelled") then
			display.getCurrentStage():setFocus(nil)
			event.target.isHeaderBgPressed = false
		end
	end
	return true
end

function headerFnc.createNewHeader(bg)
	if (type(bg) == "string") then
		bg = display.newImage(bg, true)
	end
	if ((type(bg) == "table") and (bg.parent ~= nil)) then
		bg.anchorX = 0
		bg.anchorY = 0
		bg.x = 0
		bg.y = 0
	else
		return false
	end
	if (headerBase) then
		display.remove(headerBase)
	end
	headerBase = display.newGroup()
	headerBase:insert(bg)
	bg:addEventListener("touch", headerBgTouchListener)
	headerBase.headerHeight = bg.contentHeight
	headerBase.statusBarHeight = display.topStatusBarContentHeight
	headerView = display.newGroup()
	headerBase:insert(headerView)
	headerMask = display.newRect(headerBase, 0, 0, display.contentWidth, headerBase.headerHeight)
	headerMask.anchorX = 0
	headerMask.anchorY = 0
	headerMask.alpha = 0
	headerMask.isHitTestable = true
	headerMask:addEventListener("touch", headerMaskingTouchListener)
	return true
end

local function btnTransitionFunction(oldObj, newObj, offset, transitionParams)
	if (offset ~= 0) then
		if (transitionLockCount < 0) then
			transitionLockCount = 0
		end
		if (newObj) then
			local destX = newObj.x
			newObj.x = newObj.x + offset
			newObj.alpha = 0
			transition.to(newObj, {
									x = destX,
									alpha = 1,
									transition = transitionParams.transition,
									time = transitionParams.time,
									onComplete = function(obj)
										transitionLockCount = transitionLockCount - 1
									end
									})
			transitionLockCount = transitionLockCount + 1
		end
		if (oldObj) then
			transition.to(oldObj, {
									x = oldObj.x - offset,
									alpha = 0,
									transition = transitionParams.transition,
									time = transitionParams.time,
									onComplete = function(obj)
										transitionLockCount = transitionLockCount - 1
										display.remove(obj)
									end
									})
			transitionLockCount = transitionLockCount + 1
		end
	else
		if (oldObj) then
			display.remove(oldObj)
		end
	end
	return newObj
end

local function titleTransitionFunction(oldObj, newObj, offset, transitionParams)
	local returnObj = oldObj
	if (offset ~= 0) then
		if (transitionLockCount < 0) then
			transitionLockCount = 0
		end
		if (newObj) then
			local destX = newObj.x
			newObj.x = newObj.x + offset
			newObj.alpha = 0
			transition.to(newObj, {
									x = destX,
									alpha = 1,
									transition = transitionParams.transition,
									time = transitionParams.time,
									onComplete = function(obj)
										transitionLockCount = transitionLockCount - 1
									end
									})
			transitionLockCount = transitionLockCount + 1
			if (oldObj) then
				transition.to(oldObj, {
										x = oldObj.x - offset,
										alpha = 0,
										transition = transitionParams.transition,
										time = transitionParams.time,
										onComplete = function(obj)
											transitionLockCount = transitionLockCount - 1
											display.remove(obj)
										end
										})
				transitionLockCount = transitionLockCount + 1
			end
			returnObj = newObj
		end
	else
		if (newObj ~= nil) then
			if (oldObj ~= nil) then
				display.remove(oldObj)
			end
			returnObj = newObj
		end
	end
	return returnObj
end

local function bgTransitionFunction(oldBg, newBg, transitionParams)
	if ((type(transitionParams) == "table") and (transitionParams.time ~= nil) and (transitionParams.time > 0)) then
		if (transitionLockCount < 0) then
			transitionLockCount = 0
		end
		if (newBg) then
			newBg.alpha = 0
			transition.to(newBg, {
									alpha = 1,
									transition = transitionParams.transition,
									time = transitionParams.time,
									onComplete = function(obj)
										transitionLockCount = transitionLockCount - 1
									end
									})
			transitionLockCount = transitionLockCount + 1
		end
		if (oldBg) then
			transition.to(oldBg, {
									alpha = 0,
									transition = transitionParams.transition,
									time = transitionParams.time,
									onComplete = function(obj)
										transitionLockCount = transitionLockCount - 1
										display.remove(obj)
									end
									})
			transitionLockCount = transitionLockCount + 1
		end
	else
		if (oldBg) then
			display.remove(oldBg)
		end
	end
	return newBg
end

-- format of headerObjects
--   [leftButton] (displayObject)
--   [rightButton] (displayObject)
--   [title] (displayObject)
--   [bg] (displayObject)
-- format of transitionParams
--   dir
--   [transition]
--   time
-- headerFnc.changeHeaderView(headerObjects, [transitionParams], onStatusBarPressedListenerCallBack)
function headerFnc.changeHeaderView(...)
	if (headerBase == nil) then
		return nil
	end
	local headerObjects, transitionParams, onStatusBarPressedListenerCallBack
	headerObjects = arg[1]
	local argIdx = 2
	if (type(arg[argIdx]) == "table") then
		transitionParams = arg[argIdx]
		argIdx = argIdx + 1
	end
	onStatusBarPressedListenerCallBack = arg[argIdx]
onHeaderPressedListener = onStatusBarPressedListenerCallBack
	if (subHeader) then
		display.remove(subHeader)
		subHeader = nil
	end
	if (headerObjects.leftButton) then
		headerObjects.leftButton.anchorX = 0
		headerObjects.leftButton.anchorY = 1
		headerObjects.leftButton.x = BUTTON_TO_EDGE_SPACING
		headerObjects.leftButton.y = headerBase.height - BUTTON_TO_EDGE_SPACING
		headerView:insert(headerObjects.leftButton)
	end
	if (headerObjects.rightButton) then
		headerObjects.rightButton.anchorX = 1
		headerObjects.rightButton.anchorY = 1
		headerObjects.rightButton.x = display.contentWidth - BUTTON_TO_EDGE_SPACING
		headerObjects.rightButton.y = headerBase.height - BUTTON_TO_EDGE_SPACING
		headerView:insert(headerObjects.rightButton)
	end
	if (headerObjects.title) then
		headerObjects.title.anchorX = 0.5
		headerObjects.title.anchorY = 1
		headerObjects.title.x = display.contentWidth * 0.5
		headerObjects.title.y = headerBase.height - BUTTON_TO_EDGE_SPACING
		headerView:insert(headerObjects.title)
	end
	if (headerObjects.bg) then
		headerObjects.bg.anchorX = 0.5
		headerObjects.bg.anchorY = 0
		headerObjects.bg.x = display.contentWidth * 0.5
		headerObjects.bg.y = 0
		headerView:insert(headerObjects.bg)
		headerObjects.bg:toBack()
	end
	if (headerObjects.subHeader) then
		subHeader = headerObjects.subHeader
		headerBase:insert(headerObjects.subHeader)
		headerObjects.subHeader.y = headerObjects.subHeader.y + headerBase.height
	end
	local objectOffset = 0
	if (type(transitionParams) == "table") then
		if ((transitionParams.time ~= nil) and (transitionParams.time > 0)) then
			if (transitionParams.dir == "left") then
				objectOffset = TRANSITION_OFFSET
			elseif (transitionParams.dir == "right") then
				objectOffset = -TRANSITION_OFFSET
			end
		end
	else
		transitionParams = {}
	end
	headerLeftBtn = btnTransitionFunction(headerLeftBtn, headerObjects.leftButton, objectOffset, transitionParams)
	headerRightBtn = btnTransitionFunction(headerRightBtn, headerObjects.rightButton, objectOffset, transitionParams)
	headerTitle = titleTransitionFunction(headerTitle, headerObjects.title, objectOffset, transitionParams)
	headerViewBg = bgTransitionFunction(headerViewBg, headerObjects.bg, transitionParams)
	return headerBase
end

function headerFnc.getHeader()
	return headerBase
end

function headerFnc.getOffset()
	if (headerBase.parent) then
		local headerOffset = -headerBase.y
		local headerOffsetInPercentage = headerOffset / (headerBase.headerHeight - headerBase.statusBarHeight)
		return headerOffset, headerOffsetInPercentage
	end
	return nil, nil
end

function headerFnc.setHeaderPosDelta(delta)
	local headerOffset, headerOffsetInPercentage
	if (headerBase.parent) then
		local newHeaderY = headerBase.y + delta
		if (newHeaderY < headerBase.statusBarHeight - headerBase.headerHeight) then
			newHeaderY = headerBase.statusBarHeight - headerBase.headerHeight
		elseif (newHeaderY > 0) then
			newHeaderY = 0
		end
		headerBase.y = newHeaderY
		headerOffset, headerOffsetInPercentage = headerFnc.getOffset()
		if (headerView.parent) then
			headerView.alpha = 1 - headerOffsetInPercentage
		end
	end
	return headerOffset, headerOffsetInPercentage
end

function headerFnc.toStablePosition(...)
	if (headerBase.parent) then
		if (headerBase.y < 0) then
			local argIdx = 1
			local completeListener, wholeTransitionTime, isHeaderMoveDown
			if (type(arg[argIdx]) == "function") then
				completeListener = arg[argIdx]
				argIdx = argIdx + 1
			end
			if (type(arg[argIdx]) == "number") then
				wholeTransitionTime = arg[argIdx]
				argIdx = argIdx + 1
			end
			if (type(arg[argIdx]) == "boolean") then
				isHeaderMoveDown = arg[argIdx]
				argIdx = argIdx + 1
			end
			if (wholeTransitionTime == nil) then
				wholeTransitionTime = DEFAULT_TRANSITION_TIME
			end
			local transitionDistance
			local headerDest, headerViewAlpha
			if (isHeaderMoveDown == true) then
				transitionDistance = -headerBase.y
				headerDest = 0
				headerViewAlpha = 1
			else
				transitionDistance = -headerBase.y - headerBase.headerHeight + headerBase.statusBarHeight
				headerDest = headerBase.statusBarHeight - headerBase.headerHeight
				headerViewAlpha = 0
			end
			local transitionTime = math.abs(transitionDistance) * wholeTransitionTime / (headerBase.headerHeight - headerBase.statusBarHeight)
			if (headerBase.parent) then
				transition.to(headerBase, {y = headerDest, time = transitionTime, onComplete = completeListener})
			end
			if (headerView.parent) then
				transition.to(headerView, {alpha = headerViewAlpha, time = transitionTime})
			end
			return transitionDistance, transitionTime
		end
		return 0
	end
end

function headerFnc.setHeaderBtnEnable(enable)
	isHeaderBtnEnable = enable
end

return headerFnc
