---------------------------------------------------------------
-- ImageViewer.lua
--
-- Image Viewer
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
local TRANSITION_TIME = 200
local ZOOM_TIME = 300
local PIC_SPACING = 30
local PIC_FULLSCREEN_WIDTH = display.contentWidth
local PIC_FULLSCREEN_HEIGHT = display.contentHeight
local PIC_MAX_ZOOM = 3
local RESISTOR_PARAMETER_FOR_DRAG = display.contentWidth * 0.25
local PULLDOWN_TO_EXIT_RATIO = 0.25
local MAX_TIME_FOR_TOUCH_SPEED = 200
local TOUCH_MIN_SPEED_TRIGGER = 0.5

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
local galleryBg
local prevImage
local currentImage
local nextImage

local currentImageIdx
local imageData
local isHideImageBg

local touchArray = {}
local centerPoint
local actionType = nil

local transitionArray = {}

local galleryListenerFnc
---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------
local onKeyEvent

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
local imageViewer = {}

local function resistanceFunction(parameter1, parameter2)
	return (math.log(1 + parameter1 / parameter2) * parameter2)
end

local function cancelTransitions()
	for i = 1, #transitionArray do
		transition.cancel(transitionArray[i])
		transitionArray[i] = nil
	end
end

local function loadImage(imgData, isZoomToFullScreen)
	local image
	if (imgData.baseDir) then
		image = display.newImage(imgData.path, imgData.baseDir)
	else
		image = display.newImage(imgData.path)
	end
	if (image) then
		local screenRatio = PIC_FULLSCREEN_WIDTH / PIC_FULLSCREEN_HEIGHT
		local imgRatio = image.width / image.height
		local fullScreenScale
		if (imgRatio >= screenRatio) then
			fullScreenScale = PIC_FULLSCREEN_WIDTH / image.width
		else
			fullScreenScale = PIC_FULLSCREEN_HEIGHT / image.height
		end
		local imageGroup = display.newGroup()
		local imageBg = display.newRect(0, 0, image.contentWidth, image.contentHeight)
		if (imgData.isHideImageBg ~= nil) then
			if (imgData.isHideImageBg == true) then
				imageBg.alpha = 0
			end
		elseif (isHideImageBg == true) then
			imageBg.alpha = 0
		end
		imageGroup:insert(imageBg)
		imageGroup:insert(image)
		image = imageGroup
		image.imageBg = imageBg
		image.fullScreenScale = fullScreenScale
		image.curScale = 1
		if (isZoomToFullScreen ~= false) then
			image.xScale = fullScreenScale
			image.yScale = fullScreenScale
		end
		image.isRealImg = true
	else
		image = display.newRect(display.contentWidth * 0.5, display.contentHeight * 0.5, display.contentWidth, display.contentHeight)
		image:setFillColor(0)
		image.fullScreenScale = 1
	end
	return image
end

local function removeImage(image)
	if (image) then
		display.remove(image.imageBg)
		image.imageBg = nil
		display.remove(image)
	end
end

local function setPrevImageX(curImage, prevImage, curImageX)
	local widthForCurImage = math.max(curImage.contentWidth, display.contentWidth)
	local widthForPrevImage = math.max(prevImage.contentWidth, display.contentWidth)
	if (curImageX == nil) then
		curImageX = curImage.x
	end
	return curImageX - ((widthForCurImage + widthForPrevImage) * 0.5) - PIC_SPACING
end

local function loadPrevImage(curImage, x)
	if (imageData == nil) then
		return nil
	end
	local img
	if (currentImageIdx > 1) then
		local prevImageData = imageData[currentImageIdx - 1]
		img = loadImage(prevImageData)
		if (x) then
			img.x = x
		else
			img.x = setPrevImageX(curImage, img)
		end
		img.y = display.contentHeight * 0.5
		img.curX = img.x
		img.curY = img.y
	end
	return img
end

local function setNextImageX(curImage, nextImage, curImageX)
	local widthForCurImage = math.max(curImage.contentWidth, display.contentWidth)
	local widthForNextImage = math.max(nextImage.contentWidth, display.contentWidth)
	if (curImageX == nil) then
		curImageX = curImage.x
	end
	return curImageX + ((widthForCurImage + widthForNextImage) * 0.5) + PIC_SPACING
end

local function loadNextImage(curImage, x)
	if (imageData == nil) then
		return nil
	end
	local img
	if (currentImageIdx < #imageData) then
		local nextImageData = imageData[currentImageIdx + 1]
		img = loadImage(nextImageData)
		if (x) then
			img.x = x
		else
			img.x = setNextImageX(curImage, img)
		end
		img.y = display.contentHeight * 0.5
		img.curX = img.x
		img.curY = img.y
	end
	return img
end

local function pointDistance(p1, p2)
	return ((p1.x - p2.x) ^ 2 + (p1.y - p2.y) ^ 2) ^ 0.5
end

local function calTouchCenter()
	local totalTouch = #touchArray
	if (totalTouch == 0) then
		return nil, nil
	end
	local centerX, centerY = 0, 0
	for i = 1, totalTouch do
		local touch = touchArray[i]
		centerX = centerX + touch.x
		centerY = centerY + touch.y
	end
	centerPoint = {x = centerX / totalTouch, y = centerY / totalTouch}
end

local function initTouchToCenterDistance()
	local totalTouch = #touchArray
	for i = 1, totalTouch do
		local touch = touchArray[i]
		touch.distance = pointDistance(centerPoint, touch)
	end
end

local function updateTouch()
	local newScaleSummation = 0
	local newScaleSummationPointTotal = 0
	calTouchCenter()
	local totalTouch = #touchArray
	for i = 1, totalTouch do
		local touch = touchArray[i]
		local prevDistance = touch.distance
		touch.distance = pointDistance(centerPoint, touch)
		if ((touch.distance ~= 0) and (prevDistance ~= 0)) then
			newScaleSummation = newScaleSummation + (touch.distance / prevDistance)
			newScaleSummationPointTotal = newScaleSummationPointTotal + 1
		end
	end
	local newScale = 1
	if (newScaleSummationPointTotal > 1) then
		newScale = newScaleSummation / newScaleSummationPointTotal
	end
	return newScale
end

local function getTouchSpeed(newData, lastData)
	if ((newData ~= nil) and (lastData ~= nil)) then
		local timeDiff = newData.time - lastData.time
		if (timeDiff <= MAX_TIME_FOR_TOUCH_SPEED) then
			if ((newData.x ~= nil) and (newData.y ~= nil) and (lastData.x ~= nil) and (lastData.y ~= nil)) then
				return (newData.x - lastData.x) / timeDiff, (newData.y - lastData.y) / timeDiff
			end
		end
	end
	return nil, nil
end

local function touchPointListener(event)
	event.lastSpeedDetail = event.target.lastSpeedDetail
	local lastSpeedX, lastSpeedY = getTouchSpeed(event, event.target)
	if ((lastSpeedX ~= nil) and (lastSpeedY ~= nil)) then
		event.target.lastSpeedDetail = {
											x = lastSpeedX,
											y = lastSpeedY,
											time = event.time
										}
	end
	if (event.x) then
		event.target.x = event.x
		event.target.y = event.y
		event.target.time = event.time
	end
	event.target.parentObj:dispatchEvent(event)
	if ((event.phase == "ended") or (event.phase == "cancelled")) then
		display.getCurrentStage():setFocus(event.target, nil)
		event.target.parentObj = nil
		display.remove(event.target)
	end
end

local function newTouchPoint(event)
	local touchPoint = display.newCircle(event.x, event.y, 20)
	touchPoint.time = event.time
	touchPoint.lastSpeedDetail = {
									x = 0,
									y = 0,
									time = event.time
									}
	touchPoint.parentObj = event.target
	touchPoint.alpha = 0
	touchPoint:addEventListener("touch", touchPointListener)
	display.getCurrentStage():setFocus(touchPoint, event.id)
	return touchPoint
end

local function setImageAlpha(img, alpha)
	if (img ~= nil) then
		img.alpha = alpha
	end
end

local function canAddNewTouch()
	local totalTouch = #touchArray
	if (actionType == "horizontal") then
		if (totalTouch >= 1) then
			return false
		end
	elseif (actionType == "vertical") then
		return false
	elseif (actionType == "zoom") then
		if ((totalTouch <= 0) or (totalTouch >= 2)) then
			return false
		elseif (#transitionArray > 0) then
			return false
		end
	elseif ((actionType == "fadeIn") or (actionType == "fadeOut") or (actionType == "tapZooming")) then
		return false
	end
	return true
end

local function estimateNewActionType(curActionType, numberOfTouch, touchEvent)
	if (curActionType) then
		return curActionType
	end
	setImageAlpha(prevImage, 0)
	setImageAlpha(nextImage, 0)
	if (numberOfTouch >= 2) then
		return "zoom"
	end
	local dx = touchEvent.x - touchEvent.xStart
	if (math.abs(dx) > 10) then
		if (currentImage.isRealImg) then
			if (((dx > 0) and (currentImage.x - currentImage.contentWidth * 0.5 >= 0))
				or ((dx < 0) and (currentImage.x + currentImage.contentWidth * 0.5 <= display.contentWidth))) then
				setImageAlpha(prevImage, 1)
				setImageAlpha(nextImage, 1)
				return "horizontal"
			else
				return "zoom"
			end
		else
			setImageAlpha(prevImage, 1)
			setImageAlpha(nextImage, 1)
			return "horizontal"
		end
	end
	local dy = touchEvent.y - touchEvent.yStart
	if (math.abs(dy) > 10) then
		if (currentImage.isRealImg) then
			if (((dy > 0) and (currentImage.y - currentImage.contentHeight * 0.5 >= 0))
				or ((dy < 0) and (currentImage.y + currentImage.contentHeight * 0.5 <= display.contentHeight))) then
				return "vertical"
			else
				return "zoom"
			end
		else
			return "vertical"
		end
	end
	return nil
end

local function resetObjectStatus(obj)
	if (obj) then
		obj.curX = obj.x
		obj.curY = obj.y
	end
end

local function resetObjectStatusWithClearAction(obj)
	if (obj) then
		obj.curX = obj.x
		obj.curY = obj.y
	end
	actionType = nil
end

local function currentImageHorizontalBounceBackValue(imageWidth)
	if (imageWidth == nil) then
		imageWidth = currentImage.contentWidth
	end
	if ((currentImage.x + imageWidth * 0.5 < display.contentWidth) or
		(currentImage.x - imageWidth * 0.5 > 0)) then
		local newCurImgX
		local widthForCal = math.max(imageWidth, display.contentWidth)
		if (currentImage.x < display.contentWidth * 0.5) then
			return display.contentWidth - widthForCal * 0.5
		else
			return widthForCal * 0.5
		end
	end
	return nil
end

local function currentImageVerticalBounceBackValue(imageHeight)
	if (imageHeight == nil) then
		imageHeight = currentImage.contentHeight
	end
	if ((currentImage.y + imageHeight * 0.5 < display.contentHeight) or
		(currentImage.y - imageHeight * 0.5 > 0)) then
		local newCurImgY
		local heightForCal = math.max(imageHeight, display.contentHeight)
		if (currentImage.y < display.contentHeight * 0.5) then
			return display.contentHeight - heightForCal * 0.5
		else
			return heightForCal * 0.5
		end
	end
	return nil
end

local function changePrevImgToCur()
	if (prevImage) then
		removeImage(nextImage)
		nextImage = currentImage
		currentImage = prevImage
		currentImageIdx = currentImageIdx - 1
		prevImage = loadPrevImage(currentImage)
		nextImage.curX = setNextImageX(currentImage, nextImage)
		nextImage.x = nextImage.curX
		if (galleryListenerFnc) then
			local eventForListener = {
										phase = "changePic",
										prevIndex = currentImageIdx + 1,
										index = currentImageIdx,
										canLoadImage = currentImage.isRealImg,
									}
			galleryListenerFnc(eventForListener)
		end
	end
end

local function changeNextImgToCur()
	if (nextImage) then
		removeImage(prevImage)
		prevImage = currentImage
		currentImage = nextImage
		currentImageIdx = currentImageIdx + 1
		nextImage = loadNextImage(currentImage)
		prevImage.curX = setPrevImageX(currentImage, prevImage)
		prevImage.x = prevImage.curX
		if (galleryListenerFnc) then
			local eventForListener = {
										phase = "changePic",
										prevIndex = currentImageIdx - 1,
										index = currentImageIdx,
										canLoadImage = currentImage.isRealImg,
									}
			galleryListenerFnc(eventForListener)
		end
	end
end

local function exitViewerComplete(obj)
	system.deactivate("multitouch")
	Runtime:removeEventListener( "key", onKeyEvent )
	cancelTransitions()
	display.remove(galleryBg)
	galleryBg = nil
	removeImage(prevImage)
	prevImage = nil
	removeImage(currentImage)
	prevImage = nil
	removeImage(nextImage)
	prevImage = nil
	imageData = nil
	touchArray = {}
	centerPoint = nil
	actionType = nil
	isHideImageBg = nil
	if (galleryListenerFnc) then
		local eventForListener = {
									phase = "endExit",
									index = currentImageIdx,
								}
		galleryListenerFnc(eventForListener)
	end
	galleryListenerFnc = nil
end

local function onExitViewer(exitDir)
	if (galleryListenerFnc) then
		local eventForListener = {
									phase = "startExit",
									index = currentImageIdx,
								}
		local returnImgPos = galleryListenerFnc(eventForListener)
		actionType = "fadeOut"
		if ((returnImgPos ~= nil) and (returnImgPos.imgPos)) then
			local newX = returnImgPos.imgPos.centerX
			local newY = returnImgPos.imgPos.centerY
			local newXScale = returnImgPos.imgPos.width / currentImage.width
			local newYScale = returnImgPos.imgPos.height / currentImage.height
			transitionArray[1] = transition.to(currentImage, {x = newX, y = newY, xScale = newXScale, yScale = newYScale, transition = easing.outSine, time = TRANSITION_TIME, onComplete = exitViewerComplete})
		else
			local newY
			if (exitDir == "up") then
				newY = currentImage.y - display.contentHeight
			else
				newY = currentImage.y + display.contentHeight
			end
			transitionArray[1] = transition.to(currentImage, {alpha = 0, y = newY, time = TRANSITION_TIME, onComplete = exitViewerComplete})
		end
		transitionArray[2] = transition.to(galleryBg, {alpha = 0, time = TRANSITION_TIME})
		if (currentImage.imageBg) then
			transitionArray[3] = transition.to(currentImage.imageBg, {alpha = 0, transition = easing.outSine, time = TRANSITION_TIME})
		end
	end
end

onKeyEvent = function(event)
	if (actionType == nil) then
		if ((event.phase == "up") and (event.keyName == "back")) then
			onExitViewer()
		end
	end
	return true
end

local function galleryBgTouchListener(event)
	if (event.phase == "began") then
		local totalTouch = #touchArray
		if (canAddNewTouch()) then
			for i = 1, #transitionArray do
				transition.cancel(transitionArray[i])
				transitionArray[i] = nil
			end
			touchArray[totalTouch + 1] = newTouchPoint(event)
			calTouchCenter()
			initTouchToCenterDistance()
			resetObjectStatus(currentImage)
			resetObjectStatus(prevImage)
			resetObjectStatus(nextImage)
		end
	else
		local touchIdx = table.indexOf(touchArray, event.target)
		if (touchIdx) then
			if (event.phase == "moved") then
				actionType = estimateNewActionType(actionType, #touchArray, event)
				if (actionType) then
					local prevCenterPoint = centerPoint
					local newScale = updateTouch()
					local prevImageScale, imageDisplayScale = 1, 1
					if (currentImage.isRealImg) then
						-- control the scaling of the image
						prevImageScale = currentImage.xScale
						currentImage.curScale = currentImage.curScale * newScale
						imageDisplayScale = currentImage.curScale
						if (imageDisplayScale > PIC_MAX_ZOOM) then
							imageDisplayScale = PIC_MAX_ZOOM + resistanceFunction(imageDisplayScale - PIC_MAX_ZOOM, 1)
						elseif (imageDisplayScale < 1) then
							imageDisplayScale = 1 - resistanceFunction(1 - imageDisplayScale, 1)
						end
						imageDisplayScale = imageDisplayScale * currentImage.fullScreenScale
						currentImage.xScale = imageDisplayScale
						currentImage.yScale = imageDisplayScale
					end
					if (actionType ~= "vertical") then
						currentImage.curX = (currentImage.curX - prevCenterPoint.x) * (imageDisplayScale / prevImageScale) + centerPoint.x
						local newX = currentImage.curX
						local widthForCalResistance = math.max(currentImage.contentWidth, display.contentWidth)
						if (actionType ~= "horizontal") then
							if (newX - (widthForCalResistance * 0.5) > 0) then
								newX = resistanceFunction(newX - (widthForCalResistance * 0.5), RESISTOR_PARAMETER_FOR_DRAG) + widthForCalResistance * 0.5
							elseif (newX + (widthForCalResistance * 0.5) < display.contentWidth) then
								newX = display.contentWidth - resistanceFunction(display.contentWidth - newX - (widthForCalResistance * 0.5), RESISTOR_PARAMETER_FOR_DRAG) - widthForCalResistance * 0.5
							end
						else
							if (newX - (widthForCalResistance * 0.5) > 0) then
								if (prevImage == nil) then
									newX = resistanceFunction(newX - (widthForCalResistance * 0.5), RESISTOR_PARAMETER_FOR_DRAG) + widthForCalResistance * 0.5
								end
							elseif (newX + (widthForCalResistance * 0.5) < display.contentWidth) then
								if (nextImage == nil) then
									newX = display.contentWidth - resistanceFunction(display.contentWidth - newX - (widthForCalResistance * 0.5), RESISTOR_PARAMETER_FOR_DRAG) - widthForCalResistance * 0.5
								end
							end
						end
						currentImage.x = newX
					end
					if (actionType ~= "horizontal") then
						currentImage.curY = (currentImage.curY - prevCenterPoint.y) * (imageDisplayScale / prevImageScale) + centerPoint.y
						local newY = currentImage.curY
						local heightForCalResistance = math.max(currentImage.contentHeight, display.contentHeight)
						if (actionType ~= "vertical") then
							if (newY - (heightForCalResistance * 0.5) > 0) then
								newY = resistanceFunction(newY - (heightForCalResistance * 0.5), RESISTOR_PARAMETER_FOR_DRAG) + heightForCalResistance * 0.5
							elseif (newY + (heightForCalResistance * 0.5) < display.contentHeight) then
								newY = display.contentHeight - resistanceFunction(display.contentHeight - newY - (heightForCalResistance * 0.5), RESISTOR_PARAMETER_FOR_DRAG) - heightForCalResistance * 0.5
							end
						else
							local bgAlpha = math.abs((event.y - event.yStart) / (display.contentHeight * PULLDOWN_TO_EXIT_RATIO * 2))
							if (bgAlpha > 1) then
								bgAlpha = 1
							end
							galleryBg.alpha = 1 - bgAlpha
						end
						currentImage.y = newY
					end
					if (prevImage) then
						prevImage.curX = setPrevImageX(currentImage, prevImage)
						prevImage.x = prevImage.curX
					end
					if (nextImage) then
						nextImage.curX = setNextImageX(currentImage, nextImage)
						nextImage.x = nextImage.curX
					end
					if (actionType == "horizontal") then
						local widthForCal = math.max(currentImage.contentWidth, display.contentWidth)
						if ((currentImage.x - (widthForCal * 0.5) - PIC_SPACING) >= (display.contentWidth * 0.5)) then
							changePrevImgToCur()
						elseif ((currentImage.x + (widthForCal * 0.5) + PIC_SPACING) <= (display.contentWidth * 0.5)) then
							changeNextImgToCur()
						end
					end
				end
			elseif ((event.phase == "ended") or (event.phase == "cancelled"))then
				table.remove(touchArray, touchIdx)
				calTouchCenter()
				initTouchToCenterDistance()
				if (actionType == "zoom") then
					if (currentImage.isRealImg) then
						local newScale
						if (#touchArray > 0) then
							if (currentImage.curScale > PIC_MAX_ZOOM) then
								newScale = PIC_MAX_ZOOM
							elseif (currentImage.curScale < 1) then
								newScale = 1
							end
							touchArray = {}
						end
						if (#touchArray == 0) then
							local newCurImgX, newCurImgY
							if (newScale) then
								newCurImgX = currentImageHorizontalBounceBackValue(currentImage.width * newScale * currentImage.fullScreenScale)
								newCurImgY = currentImageVerticalBounceBackValue(currentImage.height * newScale * currentImage.fullScreenScale)
							else
								newCurImgX = currentImageHorizontalBounceBackValue()
								newCurImgY = currentImageVerticalBounceBackValue()
							end
							local transitionTimeRatioX = 0
							local transitionTimeRatioY = 0
							if (newCurImgX ~= nil) then
								transitionTimeRatioX = math.abs(newCurImgX - currentImage.x) / display.contentWidth
							else
								newCurImgX = currentImage.x
							end
							if (newCurImgY ~= nil) then
								transitionTimeRatioY = math.abs(newCurImgY - currentImage.y) / display.contentHeight
							else
								newCurImgY = currentImage.y
							end
							local transitionTimeRatio = math.max(transitionTimeRatioX, transitionTimeRatioY)
							if (transitionTimeRatio > 0) then
								local displayScale
								if (newScale) then
									currentImage.curScale = newScale
								end
								displayScale = currentImage.curScale * currentImage.fullScreenScale
								local transitionTime = ZOOM_TIME * transitionTimeRatio
								cancelTransitions()
								transitionArray[1] = transition.to(currentImage, {x = newCurImgX, y = newCurImgY, xScale = displayScale, yScale = displayScale, transition = easing.outSine, time = transitionTime, onComplete = resetObjectStatusWithClearAction})
							elseif (newScale) then
								cancelTransitions()
								currentImage.curScale = newScale
								local scaleForDisplay = newScale * currentImage.fullScreenScale
								transitionArray[1] = transition.to(currentImage, {xScale = scaleForDisplay, yScale = scaleForDisplay, transition = easing.outSine, time = TRANSITION_TIME, onComplete = function(obj) transitionArray[1] = nil; resetObjectStatusWithClearAction(obj); end})
							else
								resetObjectStatusWithClearAction(currentImage)
							end
						end
					else
						resetObjectStatusWithClearAction(currentImage)
					end
				elseif (#touchArray == 0) then
					if (actionType == "horizontal") then
						if (event.lastSpeedDetail) then
							if (event.time - event.lastSpeedDetail.time < MAX_TIME_FOR_TOUCH_SPEED) then
								local widthForCal = math.max(currentImage.contentWidth, display.contentWidth)
								if (event.lastSpeedDetail.x > TOUCH_MIN_SPEED_TRIGGER) then
									local imageLeftEdge = currentImage.x - widthForCal * 0.5 - PIC_SPACING
									if ((imageLeftEdge > 0) and (imageLeftEdge <= display.contentWidth * 0.5)) then
										changePrevImgToCur()
									end
								elseif (event.lastSpeedDetail.x < -TOUCH_MIN_SPEED_TRIGGER) then
									local imageRightEdge = currentImage.x + widthForCal * 0.5 + PIC_SPACING
									if ((imageRightEdge >= display.contentWidth * 0.5) and (imageRightEdge < display.contentWidth)) then
										changeNextImgToCur()
									end
								end
							end
						end
						local newCurImgX = currentImageHorizontalBounceBackValue()
						if (newCurImgX) then
							local transitionTime = TRANSITION_TIME * math.abs(newCurImgX - currentImage.x) / display.contentWidth
							cancelTransitions()
							transitionArray[1] = transition.to(currentImage, {x = newCurImgX, transition = easing.outSine, time = transitionTime, onComplete = resetObjectStatusWithClearAction})
							if (prevImage) then
								local newPrevImgX = setPrevImageX(currentImage, prevImage, newCurImgX)
								transitionArray[#transitionArray + 1] = transition.to(prevImage, {x = newPrevImgX, transition = easing.outSine, time = transitionTime, onComplete = resetObjectStatus})
							end
							if (nextImage) then
								local newNextImgX = setNextImageX(currentImage, nextImage, newCurImgX)
								transitionArray[#transitionArray + 1] = transition.to(nextImage, {x = newNextImgX, transition = easing.outSine, time = transitionTime, onComplete = resetObjectStatus})
							end
						end
					elseif (actionType == "vertical") then
						local exitViewerDir = nil
						if (event.lastSpeedDetail) then
							if (event.time - event.lastSpeedDetail.time < MAX_TIME_FOR_TOUCH_SPEED) then
								if (event.lastSpeedDetail.y > TOUCH_MIN_SPEED_TRIGGER) then
									exitViewerDir = "down"
								elseif (event.lastSpeedDetail.y < -TOUCH_MIN_SPEED_TRIGGER) then
									exitViewerDir = "up"
								end
							end
						end
						if ((exitViewerDir == nil) and (galleryBg.alpha < 0.5)) then
							if (currentImage.y < display.contentHeight * 0.5) then
								exitViewerDir = "up"
							elseif (currentImage.y > display.contentHeight * 0.5) then
								exitViewerDir = "down"
							end
						end
						if (exitViewerDir) then
							onExitViewer(exitViewerDir)
						else
							local newCurImgY = currentImageVerticalBounceBackValue()
							if (newCurImgY) then
								local transitionTime = TRANSITION_TIME * math.abs(newCurImgY - currentImage.y) / display.contentWidth
								cancelTransitions()
								transitionArray[1] = transition.to(currentImage, {y = newCurImgY, transition = easing.outSine, time = transitionTime, onComplete = resetObjectStatusWithClearAction})
								transitionArray[2] = transition.to(galleryBg, {alpha = 1, transition = easing.outSine, time = transitionTime})
							end
						end
					else
						actionType = nil
					end
				end
			end
		end
	end
	return true
end

local function galleryBgTapListener(event)
	if (currentImage.isRealImg ~= true) then
		return
	end
	if (event.numTaps < 2) then
		return
	end
	if ((actionType == "tapZooming") or (actionType == "fadeIn") or (actionType == "fadeOut")) then
		return
	end
	if (#touchArray ~= 0) then
		return
	end
	actionType = "tapZooming"
	if (currentImage.curScale > 1) then
		currentImage.curScale = 1
		local transitionTime = ZOOM_TIME * math.abs(PIC_MAX_ZOOM - currentImage.curScale) / (PIC_MAX_ZOOM - 1)
		cancelTransitions()
		transitionArray[1] = transition.to(currentImage, {x = display.contentWidth * 0.5, y = display.contentHeight * 0.5, xScale = currentImage.fullScreenScale, yScale = currentImage.fullScreenScale, transition = easing.outQuart, time = transitionTime, onComplete = resetObjectStatusWithClearAction})
	else
		local newScale = currentImage.fullScreenScale * PIC_MAX_ZOOM
		local newX = display.contentWidth * 0.5
		local newWidth = currentImage.width * newScale
		if (newWidth > display.contentWidth) then
			newX = newX + (currentImage.x - event.x) * PIC_MAX_ZOOM
			if ((newX - (newWidth * 0.5)) > 0) then
				newX = newWidth * 0.5
			elseif ((newX + (newWidth * 0.5)) < display.contentWidth) then
				newX = display.contentWidth - (newWidth * 0.5)
			end
		end
		local newY = display.contentHeight * 0.5
		local newHeight = currentImage.height * newScale
		if (newHeight > display.contentHeight) then
			newY = newY + (currentImage.y - event.y) * PIC_MAX_ZOOM
			if ((newY - (newHeight * 0.5)) > 0) then
				newY = newHeight * 0.5
			elseif ((newY + (newHeight * 0.5)) < display.contentHeight) then
				newY = display.contentHeight - (newHeight * 0.5)
			end
		end
		cancelTransitions()
		currentImage.curScale = PIC_MAX_ZOOM
		transitionArray[1] = transition.to(currentImage, {x = newX, y = newY, xScale = newScale, yScale = newScale, transition = easing.outQuart, time = ZOOM_TIME, onComplete = resetObjectStatusWithClearAction})
	end
end

-- imageDataList:
--   imageData[array]
--     baseDir (default: ResourceDirectory)
--     path
--     desc
--     isHideImageBg
--   isHideImageBg
--   imageToDisplayIdx
--   imageDescFont
--   imageDescSize
--   imagePos
--     centerX
--     centerY
--     width
--     height
--   imageVisiblePos
--     centerX
--     centerY
--     width
--     height

function imageViewer.getImagePosForImageViewer(img)
	local imgPosTable
	if ((img ~= nil) and (img.anchorX ~= nil)) then
		local imgX, imgY = img:localToContent(0, 0)
		imgPosTable = {}
		imgPosTable.centerX = imgX-- + (0.5 - img.anchorX) * img.contentWidth
		imgPosTable.centerY = imgY-- + (0.5 - img.anchorY) * img.contentHeight
		imgPosTable.width = img.contentWidth
		imgPosTable.height = img.contentHeight
	end
	return imgPosTable
end

function imageViewer.openImageViewer(imageDataList, galleryListener)
	if ((type(imageDataList) ~= "table") and (type(imageDataList.imageData) ~= "table")) then
		return false
	end
	if (#imageDataList.imageData <= 0) then
		return false
	end
	system.activate("multitouch")
	Runtime:addEventListener( "key", onKeyEvent )
	galleryBg = display.newRect(0, 0, display.contentWidth, display.contentHeight)
	galleryBg:setFillColor(0)
	galleryBg.anchorX = 0
	galleryBg.anchorY = 0
	galleryBg.alpha = 0
	galleryBg.isHitTestable = true
	galleryBg:addEventListener("touch", galleryBgTouchListener)
	galleryBg:addEventListener("tap", galleryBgTapListener)
	actionType = "fadeIn"
	isHideImageBg = imageDataList.isHideImageBg

	imageData = imageDataList.imageData
	currentImageIdx = imageDataList.imageToDisplayIdx
	if (currentImageIdx < 1) then
		currentImageIdx = 1
	elseif (currentImageIdx > #imageData) then
		currentImageIdx = #imageData
	end
	local curImageData = imageData[currentImageIdx]
	currentImage = loadImage(curImageData, false)
	if (currentImage) then
		currentImage.anchorX = 0.5
		currentImage.anchorY = 0.5
		if (imageDataList.imagePos) then
			currentImage.x = imageDataList.imagePos.centerX
			currentImage.y = imageDataList.imagePos.centerY
			currentImage.xScale = imageDataList.imagePos.width / currentImage.width
			currentImage.yScale = imageDataList.imagePos.height / currentImage.height
		else
			currentImage.x = display.contentWidth * 0.5
			currentImage.y = display.contentHeight * 0.5
			currentImage.alpha = 0
			currentImage.xScale = currentImage.fullScreenScale * 0.5
			currentImage.yScale = currentImage.fullScreenScale * 0.5
		end
		currentImage.curX = display.contentWidth * 0.5
		currentImage.curY = display.contentHeight * 0.5
	end

	prevImage = loadPrevImage(currentImage, -display.contentWidth * 0.5)
	nextImage = loadNextImage(currentImage, display.contentWidth * 1.5)

	if (type(galleryListener) == "function") then
		galleryListenerFnc = galleryListener
	else
		galleryListenerFnc = nil
	end
	transition.to(galleryBg, {alpha = 1, time = TRANSITION_TIME, onComplete=function(obj) actionType = nil; end})
	transition.to(currentImage, {alpha = 1, x = display.contentWidth * 0.5, y = display.contentHeight * 0.5, xScale = currentImage.fullScreenScale, yScale = currentImage.fullScreenScale, transition = easing.outSine, time = TRANSITION_TIME})
	if ((currentImage.imageBg) and (currentImage.imageBg.alpha > 0)) then
		currentImage.imageBg.alpha = 0
		transition.to(currentImage.imageBg, {alpha = 1, transition = easing.outSine, time = TRANSITION_TIME})
	end
	return true
end

function imageViewer.reloadImage()
	if (imageData) then
		if (prevImage) then
			if (not(prevImage.isRealImg)) then
				removeImage(prevImage)
				prevImage = loadPrevImage(currentImage)
			end
		end
		if (nextImage) then
			if (not(nextImage.isRealImg)) then
				removeImage(nextImage)
				nextImage = loadNextImage(currentImage)
			end
		end
		if (currentImage) then
			if (not(currentImage.isRealImg)) then
				local curImgX = currentImage.x
				local curImgCurX = currentImage.curX
				local curImgY = currentImage.y
				local curImgCurY = currentImage.curY
				removeImage(currentImage)
				currentImage = loadImage(imageData[currentImageIdx])
				currentImage.x = curImgX
				currentImage.y = curImgY
				currentImage.curX = curImgCurX
				currentImage.curY = curImgCurY
			end
		end
	end
end

function imageViewer.forceExit()
	exitViewerComplete()
end

return imageViewer

-- TODO: slide inertia on zoom
