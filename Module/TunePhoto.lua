local widget = require("widget")

local moduleGroup = {}
--group
local displayGroup
local optionGroup
local fieldGroup
local multLineGroup
--params
local moduleData
local widthScaleRatio
local heightScaleRatio
local scaleRatio
--transition
local multiLineTrans
--timer
local multiLineTimer
--object
local background
local selectedField
local selectedFieldBorder

local leftTopCorner
local leftDownCorner
local rightTopCorner
local rightDownCorner

local tunedImage

local optionFieldBackground
local optionField_doneButton
local optionField_cancelButton

local selectedFieldOuterBackgroundTop
local selectedFieldOuterBackgroundDown
local selectedFieldOuterBackgroundLeft
local selectedFieldOuterBackgroundRight

local selectedFieldHorLine = {}
local selectedFieldVetLine = {}


local cornerTouchFieldObj = {}
local cornerTouchFieldObjX = {}
local cornerTouchFieldObjY = {}

local saveView
--function
local dx = 0
local dy = 0
local lastX = 0
local lastY = 0

local minX = 0 
local maxX = display.contentWidth
local minY = 0
local maxY = display.contentHeight

--temp saving
local tempBeginX
local tempBeginY
local tempEndX
local tempEndY
local tempObjId
local tempObjIdVet
local tempObjIdHor

local tempMovingX
local tempMovingY
local tempOffsetX
local tempOffsetY

local tempX
local tempY
local tempWidth
local tempHeight

local optionObj_trans = nil
local allObjExceptOption_trans = nil

local keyEventFunction

local defaultVaule = {
	-- necessary
	photoSavePath = nil,
	photoSaveDir = system.TemporaryDirectory,
	newPhotoSavePath = nil,
	newPhotoSaveDir = system.TemporaryDirectory,
	-- option
	bgColor = {0,0,0},
	bgAlpha = 1,
	
	startListener = nil,
	endListener = nil,
	haveKeyEvent = false,
	keyEventHide = false,
	keyEventFnc = nil,
	
	fieldColor = {1,1,1},
	fieldAlpha = 0.3,
	
	fieldOuterBgColor = {0,0,0},
	fieldOuterBgAlpha = 0.5,
	
	fieldBorderColor = {1,1,1},
	fieldBorderWidth = 2,
	fieldBorderAlpha = 1,
	
	fieldCornerTouchAreaWidth = 100,
	fieldCornerTouchAreaHeight = 100,
	
	-- corner will get moduleData value
	-- if nil, get moduleData fieldCorner value
	-- if nil, get moduleData value
	-- if nil, get default fieldCorner value
	
	fieldCornerLength = 40,
	fieldCornerColor = {1,1,1},
	fieldCornerWidth = 12,
	fieldCornerAlpha = 1,
	
	leftTopCornerLength = 40,
	leftTopCornerColor = {1,1,1},
	leftTopCornerWidth = 12,
	leftTopCornerAlpha = 1,
	
	leftDownCornerLength = 40,
	leftDownCornerColor = {1,1,1},
	leftDownCornerWidth = 12,
	leftDownCornerAlpha = 1,
	
	rightTopCornerLength = 40,
	rightTopCornerColor = {1,1,1},
	rightTopCornerWidth = 12,
	rightTopCornerAlpha = 1,
	
	rightDownCornerLength = 40,
	rightDownCornerColor = {1,1,1},
	rightDownCornerWidth = 12,
	rightDownCornerAlpha = 1,
	
	optionFieldBgColor = {187/255,235/255,255/255},
	optionFieldBgHeight = 80,
	optionFieldAlpha = 1,
	
	doneButtonText = "Done",
	doneButtonColor = {78/255,184/255,229/255},
	doneButtonAlpha = 1,
	doneButtonFontSize = 18,
	doneButtonFontFamily = "Helvetica",
	doneButtonTextAlign = "center",
	doneButtonListener = nil,
	doneButtonCallBackFnc = nil,

	cancelButtonText = "Cancel",
	cancelButtonColor = {78/255,184/255,229/255},
	cancelButtonAlpha = 1,
	cancelButtonFontSize = 18,
	cancelButtonFontFamily = "Helvetica",
	cancelButtonTextAlign = "center",
	cancelButtonListener = nil,
	cancelButtonCallBackFnc = nil,
	
	minWidth = 60,
	minHeight = 60,
	
	displayAnimationTime = 400,
	display_scaleImageAnimation = true,
	display_scaleImageAnimationTime = 400,
	displayOptionAnimation = true,
	
	hideAnimation = true,
	hideAnimationTime = 400,
	hideFieldAnimationTime = 200,
	
	testing = false,
}
local function clearAllGraph()
	if(selectedField)then
		display.remove(selectedField)
		selectedField = nil
	end
	if(selectedFieldBorder)then
		display.remove(selectedFieldBorder)
		selectedFieldBorder = nil
	end

	if(leftTopCorner)then
		display.remove(leftTopCorner)
		leftTopCorner = nil
	end

	if(leftDownCorner)then
		display.remove(leftDownCorner)
		leftDownCorner = nil
	end

	if(rightTopCorner)then
		display.remove(rightTopCorner)
		rightTopCorner = nil
	end

	if(rightDownCorner)then
		display.remove(rightDownCorner)
		rightDownCorner = nil
	end
end


local function clearTouchField()
	for i = 1,4 do
		if(cornerTouchFieldObj[i])then
			display.remove(cornerTouchFieldObj[i])
			cornerTouchFieldObj[i] = nil
		end
	end
	cornerTouchFieldObj = nil
end

local function doneFnc(event)
	
	if(event.phase=="ended" or event.phase=="cancelled")then
		saveView = widget.newScrollView
		{
			width = selectedField.width,
			height = selectedField.height,
		}
		saveView.x=display.contentCenterX
		saveView.y=display.contentCenterY
		saveView.anchorX = 0.5
		saveView.anchorY = 0.5
		displayGroup:remove(tunedImage)
		saveView:insert(tunedImage)
		tunedImage.anchorX = 0.5
		tunedImage.anchorY = 0.5
		tunedImage.x = tunedImage.x-selectedField.x
		tunedImage.y = tunedImage.y-selectedField.y
		tunedImage.width=tunedImage.width
		tunedImage.height=tunedImage.height
		display.save( saveView, moduleData.newPhotoSavePath, moduleData.newPhotoSaveDir )
		display.remove(saveView)
		saveView = nil
		moduleGroup.hide()
		if(moduleData.doneButtonCallBackFnc)then
			moduleData.doneButtonCallBackFnc(event)
		end
	end
	if(moduleData.doneButtonListener)then
		moduleData.doneButtonListener(event)
	end
	return true
end
local function cancelFnc(event)
	if(event.phase=="ended" or event.phase=="cancelled")then
		moduleGroup.hide()
		if(moduleData.cancelButtonCallBackFnc)then
			moduleData.cancelButtonCallBackFnc(event)
		end
	end
	if(moduleData.cancelButtonListener)then
		moduleData.cancelButtonListener(event)
	end
	return true
end



function moduleGroup.hide()

	optionField_doneButton:removeEventListener("touch",doneFnc)
	optionField_cancelButton:removeEventListener("touch",cancelFnc)
	
	clearTouchField()
	
	if(optionObj_trans)then
		transition.cancel(optionObj_trans)
		optionObj_trans = nil
	end
	if(allObjExceptOption_trans)then
		transition.cancel(allObjExceptOption_trans)
		allObjExceptOption_trans = nil
	end
	
	if(moduleData.hideAnimation)then
		transition.to( fieldGroup, {time = moduleData.hideFieldAnimationTime,alpha=0} )
		transition.to( optionGroup, {time = moduleData.displayAnimationTime,y=display.contentHeight} )
		transition.to( displayGroup, {time = moduleData.hideAnimationTime,alpha=0,onComplete=function (event)
					display.remove(displayGroup)
					displayGroup = nil
					if(moduleData.haveKeyEvent)then
						Runtime:removeEventListener( "key", keyEventFunction )
					end
					if(type(moduleData.endListener)=="function")then
						moduleData.endListener()
					end
			end} )
	else
		display.remove(displayGroup)
		displayGroup = nil
		if(moduleData.haveKeyEvent)then
			Runtime:removeEventListener( "key", keyEventFunction )
		end
		if(type(moduleData.endListener)=="function")then
			moduleData.endListener()
		end
	end
end

local function scaleImage()
	widthScaleRatio = (display.contentWidth-20)/tunedImage.width
	heightScaleRatio = (display.contentHeight*0.8)/tunedImage.height
	scaleRatio = math.min(widthScaleRatio,heightScaleRatio)
	
end

local function drawSelectedFieldFnc()
	if(selectedField)then
		display.remove(selectedField)
		selectedField = nil
	end
	if(cornerTouchFieldObj[1].x<cornerTouchFieldObj[3].x)then
		tempX = cornerTouchFieldObj[1].x
		tempWidth = cornerTouchFieldObj[3].x-cornerTouchFieldObj[1].x
	else
		tempX = cornerTouchFieldObj[3].x
		tempWidth = cornerTouchFieldObj[1].x-cornerTouchFieldObj[3].x
	end
	if(cornerTouchFieldObj[1].y<cornerTouchFieldObj[3].y)then
		tempY = cornerTouchFieldObj[1].y
		tempHeight = cornerTouchFieldObj[3].y-cornerTouchFieldObj[1].y
	else
		tempY = cornerTouchFieldObj[3].y
		tempHeight = cornerTouchFieldObj[1].y-cornerTouchFieldObj[3].y
	end
	selectedField = display.newRect( tempX, tempY, tempWidth, tempHeight )
	selectedField:setFillColor( unpack(moduleData.fieldColor))
	selectedField.alpha = moduleData.fieldAlpha
	selectedField.anchorX = 0
	selectedField.anchorY = 0
	fieldGroup:insert(selectedField)

end

local function drawBorderFnc()
	if(selectedFieldBorder)then
		display.remove(selectedFieldBorder)
		selectedFieldBorder = nil
	end
	
	tempBeginX = selectedField.x
	tempBeginY = selectedField.y
	tempEndX = tempBeginX+selectedField.width
	tempEndY = tempBeginY+selectedField.height
	
	selectedFieldBorder = display.newLine( tempBeginX, tempBeginY,tempEndX, tempBeginY )
	selectedFieldBorder:append( tempEndX,tempEndY, tempBeginX,tempEndY, tempBeginX,tempBeginY)
	selectedFieldBorder:setStrokeColor( moduleData.fieldBorderColor[1],moduleData.fieldBorderColor[2],moduleData.fieldBorderColor[3] )
	selectedFieldBorder.strokeWidth = moduleData.fieldBorderWidth
	fieldGroup:insert(selectedFieldBorder)
end

local function drawCornerFnc()
	if(leftTopCorner)then
		display.remove(leftTopCorner)
		leftTopCorner = nil
	end
	if(leftDownCorner)then
		display.remove(leftDownCorner)
		leftDownCorner = nil
	end
	if(rightTopCorner)then
		display.remove(rightTopCorner)
		rightTopCorner = nil
	end
	if(rightDownCorner)then
		display.remove(rightDownCorner)
		rightDownCorner = nil
	end
	
	tempBeginX = selectedField.x+moduleData.leftTopCornerLength
	tempEndX = selectedField.x
	tempBeginY = selectedField.y
	tempEndY = selectedField.y+moduleData.leftTopCornerLength
	leftTopCorner = display.newLine( tempBeginX, tempBeginY, tempEndX, tempBeginY )
	leftTopCorner:append( tempEndX,tempEndY)
	leftTopCorner:setStrokeColor( moduleData.leftTopCornerColor[1],moduleData.leftTopCornerColor[2],moduleData.leftTopCornerColor[3] )
	leftTopCorner.strokeWidth = moduleData.leftTopCornerWidth
	leftTopCorner.alpha = moduleData.leftTopCornerAlpha
	fieldGroup:insert(leftTopCorner)
	
	tempBeginX = selectedField.x+moduleData.leftDownCornerLength
	tempEndX = selectedField.x
	tempBeginY = selectedField.y+selectedField.height
	tempEndY = selectedField.y+selectedField.height-moduleData.leftDownCornerLength
	leftDownCorner = display.newLine( tempBeginX, tempBeginY,tempEndX, tempBeginY )
	leftDownCorner:append( tempEndX,tempEndY)
	leftDownCorner:setStrokeColor( moduleData.leftDownCornerColor[1],moduleData.leftDownCornerColor[2],moduleData.leftDownCornerColor[3] )
	leftDownCorner.strokeWidth = moduleData.leftDownCornerWidth
	leftDownCorner.alpha = moduleData.leftDownCornerAlpha
	fieldGroup:insert(leftDownCorner)
	
	tempBeginX = selectedField.x+selectedField.width-moduleData.rightTopCornerLength
	tempEndX = selectedField.x+selectedField.width
	tempBeginY = selectedField.y
	tempEndY = selectedField.y+moduleData.rightTopCornerLength
	rightTopCorner = display.newLine( tempBeginX, tempBeginY,tempEndX, tempBeginY )
	rightTopCorner:append( tempEndX,tempEndY)
	rightTopCorner:setStrokeColor( moduleData.rightTopCornerColor[1],moduleData.rightTopCornerColor[2],moduleData.rightTopCornerColor[3] )
	rightTopCorner.strokeWidth = moduleData.rightTopCornerWidth
	rightTopCorner.alpha = moduleData.rightTopCornerAlpha
	fieldGroup:insert(rightTopCorner)
	
	tempBeginX = selectedField.x+selectedField.width-moduleData.rightDownCornerLength
	tempEndX = selectedField.x+selectedField.width
	tempBeginY = selectedField.y+selectedField.height
	tempEndY = selectedField.y+selectedField.height-moduleData.rightDownCornerLength
	rightDownCorner = display.newLine( tempBeginX, tempBeginY,tempEndX, tempBeginY )
	rightDownCorner:append( tempEndX,tempEndY)
	rightDownCorner:setStrokeColor( moduleData.rightDownCornerColor[1],moduleData.rightDownCornerColor[2],moduleData.rightDownCornerColor[3] )
	rightDownCorner.strokeWidth = moduleData.rightDownCornerWidth
	rightDownCorner.alpha = moduleData.rightDownCornerAlpha
	fieldGroup:insert(rightDownCorner)

end
local function drawSelectedFieldOuterBackgroundFnc()
	if(selectedFieldOuterBackgroundTop)then
		display.remove(selectedFieldOuterBackgroundTop)
		selectedFieldOuterBackgroundTop = nil
	end
	if(selectedFieldOuterBackgroundDown)then
		display.remove(selectedFieldOuterBackgroundDown)
		selectedFieldOuterBackgroundDown = nil
	end
	if(selectedFieldOuterBackgroundLeft)then
		display.remove(selectedFieldOuterBackgroundLeft)
		selectedFieldOuterBackgroundLeft = nil
	end
	if(selectedFieldOuterBackgroundRight)then
		display.remove(selectedFieldOuterBackgroundRight)
		selectedFieldOuterBackgroundRight = nil
	end
	
	tempX = display.contentCenterX
	tempY = selectedField.y
	tempWidth = display.contentWidth
	tempHeight = selectedField.y
	
	selectedFieldOuterBackgroundTop = display.newRect( tempX, tempY, tempWidth, tempHeight )
	selectedFieldOuterBackgroundTop:setFillColor( unpack(moduleData.fieldOuterBgColor) )
	selectedFieldOuterBackgroundTop.alpha = moduleData.fieldOuterBgAlpha
	selectedFieldOuterBackgroundTop.anchorX = 0.5
	selectedFieldOuterBackgroundTop.anchorY = 1
	fieldGroup:insert(selectedFieldOuterBackgroundTop)
	
	tempX = display.contentCenterX
	tempY = selectedField.y+selectedField.height
	tempWidth = display.contentWidth
	tempHeight = display.contentHeight-(selectedField.y+selectedField.height)
	
	selectedFieldOuterBackgroundDown = display.newRect( tempX, tempY, tempWidth, tempHeight )
	selectedFieldOuterBackgroundDown:setFillColor( unpack(moduleData.fieldOuterBgColor) )
	selectedFieldOuterBackgroundDown.alpha = moduleData.fieldOuterBgAlpha
	selectedFieldOuterBackgroundDown.anchorX = 0.5
	selectedFieldOuterBackgroundDown.anchorY = 0
	fieldGroup:insert(selectedFieldOuterBackgroundDown)
	
	tempX = selectedField.x
	tempY = selectedField.y
	tempWidth = selectedField.x
	tempHeight = selectedField.height
	
	selectedFieldOuterBackgroundLeft = display.newRect( tempX, tempY, tempWidth, tempHeight )
	selectedFieldOuterBackgroundLeft:setFillColor( unpack(moduleData.fieldOuterBgColor) )
	selectedFieldOuterBackgroundLeft.alpha = moduleData.fieldOuterBgAlpha
	selectedFieldOuterBackgroundLeft.anchorX = 1
	selectedFieldOuterBackgroundLeft.anchorY = 0
	fieldGroup:insert(selectedFieldOuterBackgroundLeft)
	
	tempX = selectedField.x+selectedField.width
	tempY = selectedField.y
	tempWidth = display.contentWidth-(selectedField.x+selectedField.width)
	tempHeight = selectedField.height
	
	selectedFieldOuterBackgroundRight = display.newRect( tempX, tempY, tempWidth, tempHeight )
	selectedFieldOuterBackgroundRight:setFillColor( unpack(moduleData.fieldOuterBgColor) )
	selectedFieldOuterBackgroundRight.alpha = moduleData.fieldOuterBgAlpha
	selectedFieldOuterBackgroundRight.anchorX = 0
	selectedFieldOuterBackgroundRight.anchorY = 0
	fieldGroup:insert(selectedFieldOuterBackgroundRight)
	optionGroup:toFront()
end

local function drawGraphic()
	drawSelectedFieldFnc()
	drawBorderFnc()
	drawCornerFnc()
	drawSelectedFieldOuterBackgroundFnc()
	for i=1,4 do
		cornerTouchFieldObj[i]:toFront()
	end
	leftTopCorner:toFront()
	leftDownCorner:toFront()
	rightTopCorner:toFront()
	rightDownCorner:toFront()
end
local function clearMultLine()

end
local function drawMultLine(lineNum)
	if(multiLineTrans)then
		return
	end
	if(selectedFieldHorLine)then
		for i = 1, #selectedFieldHorLine do
			display.remove(selectedFieldHorLine[i])
			selectedFieldHorLine[i]=nil
		end
	end
	if(selectedFieldVetLine)then
		for i = 1, #selectedFieldVetLine do
			display.remove(selectedFieldVetLine[i])
			selectedFieldVetLine[i]=nil
		end
	end
	if(multLineGroup)then
		display.remove(multLineGroup)
		multLineGroup = nil
	end
	multLineGroup = display.newGroup()
	multLineGroup.alpha = 0

	selectedFieldHorLine = {}
	selectedFieldVetLine = {}
	tempBeginX = selectedField.x
	tempEndX = tempBeginX+selectedField.width
	tempBeginY = selectedField.y
	tempEndY = tempBeginY+selectedField.height

	for i = 1,lineNum do
		tempY = selectedField.height/(lineNum-1) * i
		selectedFieldHorLine[i] = display.newLine(tempBeginX,tempY,tempEndX,tempY)
		multLineGroup:insert(selectedFieldHorLine[i])

		tempX = selectedField.width/(lineNum-1) * i
		selectedFieldVetLine[i] = display.newLine(tempX,tempBeginY,tempX,tempEndY)
		multLineGroup:insert(selectedFieldVetLine[i])
	end
	multiLineTrans = transition.to(multLineGroup,{time=100,alpha = 0.7, onComplete = function(event)
		multiLineTrans = nil
	end	})
end


local function changeSize(event)
	tempObjId = event.target.id
	if(tempObjId==1)then
		tempObjIdHor = 2
		tempObjIdVet = 4
	elseif(tempObjId==2)then
		tempObjIdHor = 1
		tempObjIdVet = 3
	elseif(tempObjId==3)then
		tempObjIdHor = 4	
		tempObjIdVet = 2
	elseif(tempObjId==4)then
		tempObjIdHor = 3
		tempObjIdVet = 1
	end
	
	if(event.phase=="began")then
	
		lastX = event.x
		lastY = event.y
		cornerTouchFieldObj[tempObjId]:toFront()
		
		display.getCurrentStage():setFocus(event.target)
		
	elseif(event.phase=="moved")then

		dx = event.x - lastX
		dy = event.y - lastY
		lastX = event.x
		lastY = event.y
		
		tempMovingX = cornerTouchFieldObj[tempObjId].x+dx
		tempMovingY = cornerTouchFieldObj[tempObjId].y+dy
		tempOffsetX = math.abs(cornerTouchFieldObj[tempObjId].x+dx-cornerTouchFieldObj[tempObjIdHor].x)
		tempOffsetY = math.abs(cornerTouchFieldObj[tempObjId].y+dy-cornerTouchFieldObj[tempObjIdVet].y)
		
		
		if(tempMovingX>minX and tempMovingX<maxX and tempOffsetX>moduleData.minWidth)then
			cornerTouchFieldObj[tempObjId].x = cornerTouchFieldObj[tempObjId].x+dx
			
			cornerTouchFieldObj[tempObjIdVet].x = cornerTouchFieldObj[tempObjIdVet].x+dx
		end
		if(tempMovingY>minY and tempMovingY<maxY and tempOffsetY>moduleData.minHeight)then

			cornerTouchFieldObj[tempObjId].y = cornerTouchFieldObj[tempObjId].y+dy
			cornerTouchFieldObj[tempObjIdHor].y = cornerTouchFieldObj[tempObjIdHor].y+dy
		end
		drawGraphic()
		
	elseif(event.phase=="ended" or event.phase=="cancelled")then

		display.getCurrentStage():setFocus(nil)
	end

	return true
end

local function touchField()
	if(moduleData.testing)then
		moduleData.touchFieldAlphaTesting = 0.5
	else
		moduleData.touchFieldAlphaTesting = 0
	end
	cornerTouchFieldObj = {}
	cornerTouchFieldObjX = {}
	cornerTouchFieldObjY = {}
	cornerTouchFieldObjX = {tunedImage.x-tunedImage.width/2,tunedImage.x+tunedImage.width/2,tunedImage.x+tunedImage.width/2,tunedImage.x-tunedImage.width/2}
	cornerTouchFieldObjY = {tunedImage.y-tunedImage.height/2,tunedImage.y-tunedImage.height/2,tunedImage.y+tunedImage.height/2,tunedImage.y+tunedImage.height/2}
	for i = 1,4 do
		cornerTouchFieldObj[i] = display.newRect( cornerTouchFieldObjX[i], cornerTouchFieldObjY[i], moduleData.fieldCornerTouchAreaWidth, moduleData.fieldCornerTouchAreaHeight )
		cornerTouchFieldObj[i].anchorX = 0.5
		cornerTouchFieldObj[i].anchorY = 0.5
		cornerTouchFieldObj[i].id = i
		cornerTouchFieldObj[i]:setFillColor( 0,1,1 )
		cornerTouchFieldObj[i].isHitTestable = true
		cornerTouchFieldObj[i]:addEventListener("touch",changeSize)
		fieldGroup:insert(cornerTouchFieldObj[i])
		cornerTouchFieldObj[i].alpha = moduleData.touchFieldAlphaTesting
		
	end
	
end
keyEventFunction = function(event)
	if event.phase == "up" and event.keyName == "back" then
		if(moduleData.keyEventHide)then
			moduleGroup.hide()
		end
		if(type(moduleData.keyEventFnc)=="function")then
			moduleData.keyEventFnc(event)
		end
	end
	return true
end

local function backgroundFnc(event)
	print("This is background")
	return true
end
function moduleGroup.tune(newModuleData)

	moduleData = newModuleData
	
	if(not moduleData.photoSavePath or not moduleData.newPhotoSavePath)then
		print("no photoSavePath or newPhotoSavePath")
		return
	end
	
	moduleData.photoSaveDir = moduleData.photoSaveDir or defaultVaule.photoSaveDir
	moduleData.newPhotoSaveDir = moduleData.newPhotoSaveDir or defaultVaule.newPhotoSaveDir
	
	moduleData.bgColor = moduleData.bgColor or defaultVaule.bgColor
	moduleData.bgAlpha = moduleData.bgAlpha or defaultVaule.bgAlpha
	
	moduleData.fieldColor = moduleData.fieldColor or defaultVaule.fieldColor
	moduleData.fieldAlpha = moduleData.fieldAlpha or defaultVaule.fieldAlpha
	moduleData.fieldOuterBgColor = moduleData.fieldOuterBgColor or defaultVaule.fieldOuterBgColor
	moduleData.fieldOuterBgAlpha = moduleData.fieldOuterBgAlpha or defaultVaule.fieldOuterBgAlpha
	
	
	moduleData.fieldBorderColor = moduleData.fieldBorderColor or defaultVaule.fieldBorderColor
	moduleData.fieldBorderWidth = moduleData.fieldBorderWidth or defaultVaule.fieldBorderWidth
	moduleData.fieldBorderAlpha = moduleData.fieldBorderAlpha or defaultVaule.fieldBorderAlpha
	
	moduleData.fieldCornerTouchAreaWidth = moduleData.fieldCornerTouchAreaWidth or defaultVaule.fieldCornerTouchAreaWidth
	moduleData.fieldCornerTouchAreaHeight = moduleData.fieldCornerTouchAreaHeight or defaultVaule.fieldCornerTouchAreaHeight
	
	moduleData.leftTopCornerLength = moduleData.leftTopCornerLength or moduleData.fieldCornerLength or defaultVaule.leftTopCornerLength or defaultVaule.fieldCornerLength
	moduleData.leftTopCornerColor = moduleData.leftTopCornerColor or moduleData.fieldCornerColor or defaultVaule.leftTopCornerColor or defaultVaule.fieldCornerColor
	moduleData.leftTopCornerWidth = moduleData.leftTopCornerWidth or moduleData.fieldCornerWidth or defaultVaule.leftTopCornerWidth or defaultVaule.fieldCornerWidth
	moduleData.leftTopCornerAlpha = moduleData.leftTopCornerAlpha or moduleData.fieldCornerAlpha or defaultVaule.leftTopCornerAlpha or defaultVaule.fieldCornerAlpha
	
	moduleData.leftDownCornerLength = moduleData.leftDownCornerLength or moduleData.fieldCornerLength or defaultVaule.leftDownCornerLength or defaultVaule.fieldCornerLength
	moduleData.leftDownCornerColor = moduleData.leftDownCornerColor or  moduleData.fieldCornerColor or  defaultVaule.leftDownCornerColor or defaultVaule.fieldCornerColor
	moduleData.leftDownCornerWidth = moduleData.leftDownCornerWidth or moduleData.fieldCornerWidth or defaultVaule.leftDownCornerWidth or defaultVaule.fieldCornerWidth
	moduleData.leftDownCornerAlpha = moduleData.leftDownCornerAlpha or moduleData.fieldCornerAlpha or defaultVaule.leftDownCornerAlpha or defaultVaule.fieldCornerAlpha
	
	moduleData.rightTopCornerLength = moduleData.rightTopCornerLength or moduleData.fieldCornerLength or defaultVaule.rightTopCornerLength or defaultVaule.fieldCornerLength
	moduleData.rightTopCornerColor = moduleData.rightTopCornerColor or  moduleData.fieldCornerColor or  defaultVaule.rightTopCornerColor or defaultVaule.fieldCornerColor
	moduleData.rightTopCornerWidth = moduleData.rightTopCornerWidth  or moduleData.fieldCornerWidth or defaultVaule.rightTopCornerWidth or defaultVaule.fieldCornerWidth
	moduleData.rightTopCornerAlpha = moduleData.rightTopCornerAlpha or moduleData.fieldCornerAlpha or defaultVaule.rightTopCornerAlpha or defaultVaule.fieldCornerAlpha
	
	moduleData.rightDownCornerLength = moduleData.rightDownCornerLength or moduleData.fieldCornerLength or defaultVaule.rightDownCornerLength or defaultVaule.fieldCornerLength
	moduleData.rightDownCornerColor = moduleData.rightDownCornerColor or  moduleData.fieldCornerColor or defaultVaule.rightDownCornerColor or defaultVaule.fieldCornerColor
	moduleData.rightDownCornerWidth = moduleData.rightDownCornerWidth or moduleData.fieldCornerWidth or defaultVaule.rightDownCornerWidth or defaultVaule.fieldCornerWidth
	moduleData.rightDownCornerAlpha = moduleData.rightDownCornerAlpha  or moduleData.fieldCornerAlpha or defaultVaule.rightDownCornerAlpha or defaultVaule.fieldCornerAlpha
	

	
	moduleData.optionFieldBgColor = moduleData.optionFieldBgColor or defaultVaule.optionFieldBgColor
	moduleData.optionFieldBgHeight = moduleData.optionFieldBgHeight or defaultVaule.optionFieldBgHeight
	moduleData.optionFieldAlpha = moduleData.optionFieldAlpha or defaultVaule.optionFieldAlpha
	
	moduleData.doneButtonText = moduleData.doneButtonText or defaultVaule.doneButtonText
	moduleData.doneButtonColor = moduleData.doneButtonColor or defaultVaule.doneButtonColor
	moduleData.doneButtonAlpha = moduleData.doneButtonAlpha or defaultVaule.doneButtonAlpha
	moduleData.doneButtonTextAlign = moduleData.doneButtonTextAlign or defaultVaule.doneButtonTextAlign
	moduleData.doneButtonListener = moduleData.doneButtonListener or defaultVaule.doneButtonListener
	moduleData.doneButtonCallBackFnc = moduleData.doneButtonCallBackFnc or defaultVaule.doneButtonCallBackFnc
	
	moduleData.cancelButtonText = moduleData.cancelButtonText or defaultVaule.cancelButtonText
	moduleData.cancelButtonColor = moduleData.cancelButtonColor or defaultVaule.cancelButtonColor
	moduleData.cancelButtonAlpha = moduleData.cancelButtonAlpha or defaultVaule.cancelButtonAlpha
	moduleData.cancelButtonTextAlign = moduleData.cancelButtonTextAlign or defaultVaule.cancelButtonTextAlign
	moduleData.cancelButtonListener = moduleData.cancelButtonListener or defaultVaule.cancelButtonListener
	moduleData.cancelButtonCallBackFnc = moduleData.cancelButtonCallBackFnc or defaultVaule.cancelButtonCallBackFnc
	
	moduleData.minWidth = moduleData.minWidth or defaultVaule.minWidth
	moduleData.minHeight = moduleData.minHeight or defaultVaule.minHeight
	
	moduleData.display_scaleImageAnimation = moduleData.display_scaleImageAnimation or defaultVaule.display_scaleImageAnimation
	moduleData.displayAnimationTime = moduleData.displayAnimationTime or defaultVaule.displayAnimationTime
	moduleData.display_scaleImageAnimationTime = moduleData.display_scaleImageAnimationTime or defaultVaule.display_scaleImageAnimationTime
	moduleData.displayOptionAnimation = moduleData.displayOptionAnimation or defaultVaule.displayOptionAnimation
	
	moduleData.hideAnimation = moduleData.hideAnimation or defaultVaule.hideAnimation
	moduleData.hideAnimationTime = moduleData.hideAnimationTime or defaultVaule.hideAnimationTime
	moduleData.hideFieldAnimationTime = moduleData.hideFieldAnimationTime or defaultVaule.hideFieldAnimationTime


	moduleData.testing = moduleData.testing or defaultVaule.testing--for testing

	displayGroup = display.newGroup()
	optionGroup = display.newGroup()
	fieldGroup = display.newGroup()
	
	background = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
	background:setFillColor( unpack(moduleData.bgColor) )
	background.alpha = moduleData.bgAlpha
	background.anchorX = 0.5
	background.anchorY = 0.5
	background.isHitTestable = true
	background:addEventListener("touch",backgroundFnc)
	displayGroup:insert(background)
	
	tunedImage = display.newImage(moduleData.photoSavePath,moduleData.photoSaveDir,true)
	tunedImage.x = display.contentCenterX
	tunedImage.y = display.contentCenterY
	tunedImage.anchorX=0.5
	tunedImage.anchorY=0.5
	displayGroup:insert(tunedImage)

	optionFieldBackground = display.newRect( display.contentCenterX, 0, display.contentWidth, moduleData.optionFieldBgHeight )
	optionFieldBackground:setFillColor( unpack(moduleData.optionFieldBgColor) )
	optionFieldBackground.anchorX = 0.5
	optionFieldBackground.anchorY = 0
	optionGroup:insert(optionFieldBackground)
	
	optionField_doneButton = {
		text = moduleData.doneButtonText,     
		x = display.contentWidth-20,
		y = optionFieldBackground.height/2,
		width = 0,
		height = 0,
		font = doneButtonFontFamily,   
		fontSize = doneButtonFontSize,
		align = moduleData.doneButtonTextAlign,
	}
	optionField_doneButton = display.newText(optionField_doneButton)
	optionField_doneButton.anchorX = 1
	optionField_doneButton.anchorY = 0.5
	optionField_doneButton.height = optionFieldBackground.height
	optionField_doneButton:setFillColor(unpack(moduleData.doneButtonColor))
	optionField_doneButton.alpha = moduleData.doneButtonAlpha
	optionField_doneButton:addEventListener("touch",doneFnc)
	optionGroup:insert(optionField_doneButton)
	
	optionField_cancelButton = {
		text = moduleData.cancelButtonText,     
		x = 20,
		y = optionFieldBackground.height/2,
		width = 0,
		height = 0,
		font = cancelButtonFontFamily,   
		fontSize = cancelButtonFontSize,
		align = moduleData.cancelButtonTextAlign,
	}
	optionField_cancelButton = display.newText(optionField_cancelButton)
	optionField_cancelButton.anchorX = 0
	optionField_cancelButton.anchorY = 0.5
	optionField_cancelButton.height = optionFieldBackground.height
	optionField_cancelButton:setFillColor(unpack(moduleData.cancelButtonColor))
	optionField_cancelButton.alpha = moduleData.cancelButtonAlpha
	optionField_cancelButton:addEventListener("touch",cancelFnc)
	optionGroup:insert(optionField_cancelButton)
	
	displayGroup:insert(fieldGroup)
	displayGroup:insert(optionGroup)
	
	displayGroup.alpha = 0
	
	scaleImage()
	tempWidth = tunedImage.width * scaleRatio
	tempHeight = tunedImage.height * scaleRatio
	tunedImage.width = 10
	tunedImage.height = 10
	if(moduleData.display_scaleImageAnimation)then
		transition.to( tunedImage, {time = moduleData.display_scaleImageAnimationTime,width=tempWidth,height=tempHeight,onComplete=function (event)
			minX = tunedImage.x-tunedImage.width/2
			maxX = tunedImage.x+tunedImage.width/2
			minY = tunedImage.y-tunedImage.height/2
			maxY = tunedImage.y+tunedImage.height/2
			touchField()
			drawGraphic()
		end} )
	else
		tunedImage.width = tempWidth
		tunedImage.height = tempHeight
		minX = tunedImage.x-tunedImage.width/2
		maxX = tunedImage.x+tunedImage.width/2
		minY = tunedImage.y-tunedImage.height/2
		maxY = tunedImage.y+tunedImage.height/2
		touchField()
		drawGraphic()
	end
	if(moduleData.displayOptionAnimation)then
		optionGroup.y = display.contentHeight
		optionObj_trans = transition.to( optionGroup, {time = moduleData.displayAnimationTime,y=display.contentHeight-optionFieldBackground.height} )
	else
		optionGroup.y = display.contentHeight-optionFieldBackground.height
	end
	allObjExceptOption_trans = transition.to( displayGroup, {time = moduleData.displayAnimationTime,alpha=1} )
	if(moduleData.haveKeyEvent)then
		Runtime:addEventListener( "key", keyEventFunction )
	end
	if(type(moduleData.startListener)=="function")then
		moduleData.startListener()
	end
	
	return displayGroup
end


return moduleGroup