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
require ( "DebugUtility.Debug" )

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local DEFAULT_TRANSITION_TIME = 100

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
local headerDisplayObject
local headerObject
local isHeaderBtnEnable
local onStatusBarPressedListener

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
local headerFnc = {}

local function headerTouchListener(event)
	print(event.y)
	if (event.phase == "began") then
		if (event.y < headerObject.statusBarHeight) then
			event.target.isStatusBarPressed = true
			display.getCurrentStage():setFocus(event.target)
		end
		return true
	elseif (event.target.isStatusBarPressed) then
		if (event.phase == "ended") then
			if (event.y < headerObject.statusBarHeight) then
				if (type(onStatusBarPressedListener) == "function") then
					onStatusBarPressedListener()
				end
			end
			display.getCurrentStage():setFocus(nil)
			event.target.isStatusBarPressed = false
		elseif (event.phase == "cancelled") then
			display.getCurrentStage():setFocus(nil)
			event.target.isStatusBarPressed = false
		end
		return true
	end
	if (isHeaderBtnEnable ~= true) then
		return true
	elseif (false) then	-- TODO: check if header is not fully shown
		return true
	end
end

function headerFnc.createNewHeader(headerGroup, headerHeight, onStatusBarPressedListenerCallBack)
	if (headerObject) then
		display.remove(headerObject)
	end
	onStatusBarPressedListener = onStatusBarPressedListenerCallBack
	headerObject = display.newGroup()
	headerObject:insert(headerGroup)
	headerObject = headerGroup
	headerObject.headerHeight = headerHeight
	headerDisplayObject = headerGroup.headerDisplayGroup
	-- headerObject.statusBarHeight = display.topStatusBarContentHeight / display.contentScaleY
	headerObject.statusBarHeight = display.topStatusBarContentHeight
	local headerMask = display.newRect(headerObject, 0, 0, display.contentWidth, headerHeight)
	headerMask.anchorX = 0
	headerMask.anchorY = 0
	headerMask.alpha = 0
	headerMask.isHitTestable = true
	headerMask:addEventListener("touch", headerTouchListener)
	headerObject:addEventListener("touch", function(event) return true; end)
	isHeaderBtnEnable = true
	return headerObject
end

function headerFnc.getHeader()
	return headerObject
end

function headerFnc.showHeader()
	if (headerObject.parent) then
		headerObject.y = 0
	end
end

function headerFnc.getOffset()
	if (headerObject.parent) then
		local headerOffset = -headerObject.y
		local headerOffsetInPercentage = headerOffset / (headerObject.headerHeight - headerObject.statusBarHeight)
		return headerOffset, headerOffsetInPercentage
	end
	return nil, nil
end

function headerFnc.setHeaderPosDelta(delta)
	local headerOffset, headerOffsetInPercentage
	if (headerObject.parent) then
		local newHeaderY = headerObject.y + delta
		if (newHeaderY < headerObject.statusBarHeight - headerObject.headerHeight) then
			newHeaderY = headerObject.statusBarHeight - headerObject.headerHeight
		elseif (newHeaderY > 0) then
			newHeaderY = 0
		end
		headerObject.y = newHeaderY
		headerOffset, headerOffsetInPercentage = headerFnc.getOffset()
		if (headerDisplayObject.parent) then
			headerDisplayObject.alpha = 1 - headerOffsetInPercentage
		end
	end
	return headerOffset, headerOffsetInPercentage
end

function headerFnc.toStablePosition(...)
	if (headerObject.parent) then
		if (headerObject.y < 0) then
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
			local headerDest, headerDisplauGroupAlpha
			if (isHeaderMoveDown == true) then
				transitionDistance = -headerObject.y
				headerDest = 0
				headerDisplauGroupAlpha = 1
			else
				transitionDistance = -headerObject.y - headerObject.headerHeight + headerObject.statusBarHeight
				headerDest = headerObject.statusBarHeight - headerObject.headerHeight
				headerDisplauGroupAlpha = 0
			end
			local transitionTime = math.abs(transitionDistance) * wholeTransitionTime / (headerObject.headerHeight - headerObject.statusBarHeight)
			if (headerObject.parent) then
				transition.to(headerObject, {y = headerDest, time = transitionTime, onComplete = completeListener})
			end
			if (headerDisplayObject.parent) then
				transition.to(headerDisplayObject, {alpha = headerDisplauGroupAlpha, time = transitionTime})
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
