local moduleGroup = {}

local boolean_isDisplay = false --use to check display
local group_displayScreen -- group to save all object
local group_buttonsField -- group to save choice button
local moduleData -- save pass in data
local buttonNumber -- button number
local objY -- new objY
local background_choiceField_beginX
local background_choiceField_endX
local lineObjY
local temp_bgWidth = 0
local temp_bgHeight
local temp_bgCornerRadius = 0
local displayTransPos = 0
local hideTransPos = display.contentHeight
local keyEventFunction
local bgTrans
local buttonTrans
local bgcanCancel = false

local defaultValue = 
{
	choiceObj = {},--if text, display text. if image, image path
	choiceObjType = {},--text,image
	choiceFncType = {},--touch
	choiceFnc = {},
	--option
	startListener = nil,
	endListener = nil,
	haveKeyEvent = false,
	keyEventHide = false,
	keyEventFnc = nil,
	rowHeight = 80,
	bgColor = {0.5,0.5,0.5},
	bgAlpha = 0.9,
	boolean_bgTouchNotCancel = false,
	choiceFieldBgColor = {255/255,255/255,255/255},
	choiceFieldStrokeColor = {30/255, 144/255, 255/255},
	choiceFieldStrokeWidth = 2,
	choiceFieldBgAlpha = 0.8,
	choiceFieldBgCornerRadius = 10,
	choiceFieldBgLineWidth = 2,
	choiceFieldBgLilneColor = { 204/255, 204/255, 204/255 },
	choiceFieldBgLineAlpha = 0.8,
	
	
	boolean_noCancelButton = false,
	offsetBtwChoiceAndCancel = 10,
	offsetBtwCancelAndBottom = 10,
	cancelButtonText = "Cancel",
	choiceObj_fontSize = 48,
	choiceObj_fontFamily = "Helvetica",
	choiceObj_textColor = {30/255, 144/255, 255/255},
	choiceObj_align = "center",
	displayTransTime = 300,
	hideTransTime = 300,
	boolean_isNotShowBegin = false,
}
function moduleGroup.noFncTouch(event)
	return true
end
function moduleGroup.choiceObjTypeConvertFnc(objectTypeArray)
	
	if(type(objectTypeArray)~="table")then
		objectTypeArray = {}
	end
	if(#objectTypeArray<buttonNumber)then
		for i = #objectTypeArray+1,buttonNumber do
			objectTypeArray[i] = true --operate field
		end
	end
	for i = 1, #objectTypeArray do
		objectTypeArray[i] = string.lower(tostring(objectTypeArray[i]))
		if(objectTypeArray[i]~="text" and objectTypeArray[i]~="image")then
			objectTypeArray[i]="text"
		end
	end
	return objectTypeArray
end
function moduleGroup.choiceFncTypeConvertFnc(fncTypeArray)
	if(type(fncTypeArray)~="table")then
		fncTypeArray = {}
	end
	if(#fncTypeArray<buttonNumber)then
		for i = #fncTypeArray+1,buttonNumber do
			fncTypeArray[i] = true --operate field
		end
	end
	for i = 1, #fncTypeArray do
		if(type(fncTypeArray[i])=="string")then
			fncTypeArray[i] = string.lower(fncTypeArray[i])
		end
		if(fncTypeArray[i]~="touch" and fncTypeArray[i]~="tap")then
			fncTypeArray[i]="touch"
		end
	end
	return fncTypeArray
end
function moduleGroup.choiceFncConvertFnc(fncArray)
	if(type(fncArray)~="table")then
		fncArray = {}
	end
	if(#fncArray<buttonNumber)then
		for i = #fncArray+1,buttonNumber do
			fncArray[i] = true --operate field
		end
	end
	for i = 1, #fncArray do
		if(type(fncArray[i])~="function")then
			fncArray[i] = moduleGroup.noFncTouch
		end
	end
	return fncArray
end

function moduleGroup.display()
	if(moduleData.haveKeyEvent)then
		Runtime:addEventListener( "key", keyEventFunction )
	end
	if(bgTrans)then
		transition.cancel(bgTrans)
		bgTrans = nil
	end
	
	if(buttonTrans)then
		transition.cancel(buttonTrans)
		buttonTrans = nil
	end
	
	boolean_isDisplay=true
	group_displayScreen.alpha = 1
	
	transition.to( background, { time=moduleData.displayTransTime, alpha=1})
	transition.to( group_buttonsField, { time=moduleData.displayTransTime, y=displayTransPos,onComplete = function(event)
		--set up object function
		for i = 1, #moduleData.choiceFnc do
			moduleData.obj[i]:addEventListener(moduleData.choiceFncType[i],moduleData.choiceFnc[i])
		end
		bgcanCancel = true
		if(type(moduleData.startListener)=="function")then
			moduleData.startListener()
		end
	end})
end
function moduleGroup.hide()
	--remove object function
	bgcanCancel = false
	for i = 1, #moduleData.choiceFnc do
		moduleData.obj[i]:removeEventListener(moduleData.choiceFncType[i],moduleData.choiceFnc[i])
	end
	
	if(bgTrans)then
		transition.cancel(bgTrans)
		bgTrans = nil
	end
	
	if(buttonTrans)then
		transition.cancel(buttonTrans)
		buttonTrans = nil
	end
	
	bgTrans = transition.to( background, { time=moduleData.hideTransTime, alpha=0})
	buttonTrans = transition.to( group_buttonsField, { time=moduleData.hideTransTime, y=hideTransPos,onComplete = function(event)
		group_displayScreen.alpha = 0
		boolean_isDisplay = false
		if(moduleData.haveKeyEvent)then
			Runtime:removeEventListener( "key", keyEventFunction )
		end
		if(type(moduleData.endListener)=="function")then
			moduleData.endListener()
		end
	end})
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

local function cancelButtonFnc(event)
	if(event.phase=="ended" or event.phase=="cancelled")then
		moduleGroup.hide()
	end
	return true
end

local function backgronud_touch(event)
	if(event.phase=="ended" or event.phase=="cancelled")then
		print("This is background.")
		--
		if(not moduleData.boolean_bgTouchNotCancel and bgcanCancel)then
			--cancel menu
			moduleGroup.hide()
		end
	end
	return true
end

function moduleGroup.create(newModuleData)
	if(group_displayScreen) then
		display.remove(group_displayScreen)
		group_displayScreen = nil
	end
	moduleData = newModuleData
	
	--setting
	--row height
	moduleData.rowHeight = moduleData.rowHeight or defaultValue.rowHeight
	
	--background setting
	moduleData.bgAlpha = moduleData.bgAlpha or defaultValue.bgAlpha
	moduleData.bgColor = moduleData.bgColor or defaultValue.bgColor
	--background color convert
	-- moduleData.bgColor = moduleGroup.colorFormatConvert(moduleData.bgColor)
	moduleData.boolean_bgTouchNotCancel = moduleData.boolean_bgTouchNotCancel or defaultValue.boolean_bgTouchNotCancel
	--Choice Field Color background setting
	moduleData.choiceFieldStrokeWidth = moduleData.choiceFieldStrokeWidth or defaultValue.choiceFieldStrokeWidth
	moduleData.choiceFieldBgAlpha = moduleData.choiceFieldBgAlpha or defaultValue.choiceFieldBgAlpha
	moduleData.choiceFieldBgCornerRadius = moduleData.choiceFieldBgCornerRadius or defaultValue.choiceFieldBgCornerRadius
	moduleData.choiceFieldBgColor = moduleData.choiceFieldBgColor or defaultValue.choiceFieldBgColor
	--Choice Field Background Color convert
	-- moduleData.choiceFieldBgColor = moduleGroup.colorFormatConvert(moduleData.choiceFieldBgColor)
	moduleData.choiceFieldStrokeColor = moduleData.choiceFieldStrokeColor or defaultValue.choiceFieldStrokeColor
	--Choice Field Stroke Color convert
	-- moduleData.choiceFieldStrokeColor = moduleGroup.colorFormatConvert(moduleData.choiceFieldStrokeColor)
	
	--Choice Field background line setting
	--if not set line width, it will get choice field stroke width firstly. if both not, get default value
	moduleData.choiceFieldBgLineWidth = moduleData.choiceFieldBgLineWidth or moduleData.choiceFieldStrokeWidth or defaultValue.choiceFieldBgLineWidth or defaultValue.choiceFieldStrokeWidth
	--if not set line alpha, it will get choice field alpha firstly. if both not, get default value
	moduleData.choiceFieldBgLineAlpha = moduleData.choiceFieldBgLineAlpha or moduleData.choiceFieldBgAlpha or defaultValue.choiceFieldBgLineAlpha or defaultValue.choiceFieldBgAlpha
	--
	moduleData.choiceFieldBgLilneColor = moduleData.choiceFieldBgLilneColor or defaultValue.choiceFieldBgLilneColor
	-- moduleData.choiceFieldBgLilneColor = moduleGroup.colorFormatConvert(moduleData.choiceFieldBgLilneColor)

	--object and object function setting
	moduleData.choiceObj = moduleData.choiceObj or defaultValue.choiceObj
	buttonNumber = #moduleData.choiceObj --get total button number
	moduleData.choiceObjType = moduleData.choiceObjType or defaultValue.choiceObjType
	--object type convert
	moduleData.choiceObjType = moduleGroup.choiceObjTypeConvertFnc(moduleData.choiceObjType)
	
	--fontSize and fontFamily setting
	moduleData.choiceObj_fontSize = moduleData.choiceObj_fontSize or defaultValue.choiceObj_fontSize
	moduleData.choiceObj_fontFamily = moduleData.choiceObj_fontFamily or defaultValue.choiceObj_fontFamily
	moduleData.choiceObj_align = moduleData.choiceObj_align or defaultValue.choiceObj_align
	moduleData.choiceObj_textColor = moduleData.choiceObj_textColor or defaultValue.choiceObj_textColor
	--text color convert
	-- moduleData.choiceObj_textColor = moduleGroup.colorFormatConvert(moduleData.choiceObj_textColor)
	--function type set up
	moduleData.choiceFnc = moduleData.choiceFnc or defaultValue.choiceFnc
	moduleData.choiceFnc = moduleGroup.choiceFncConvertFnc(moduleData.choiceFnc)
	moduleData.choiceFncType = moduleData.choiceFncType or defaultValue.choiceFncType
	--function type convert
	moduleData.choiceFncType = moduleGroup.choiceFncTypeConvertFnc(moduleData.choiceFncType)
	--cancel button setting
	moduleData.boolean_noCancelButton = moduleData.boolean_noCancelButton or defaultValue.boolean_noCancelButton
	moduleData.cancelButtonText = moduleData.cancelButtonText or defaultValue.cancelButtonText
	moduleData.offsetBtwChoiceAndCancel = moduleData.offsetBtwChoiceAndCancel or defaultValue.offsetBtwChoiceAndCancel
	moduleData.offsetBtwCancelAndBottom = moduleData.offsetBtwCancelAndBottom or defaultValue.offsetBtwCancelAndBottom
	--animation setting
	moduleData.displayTransTime = moduleData.displayTransTime or defaultValue.displayTransTime
	moduleData.hideTransTime = moduleData.hideTransTime or defaultValue.hideTransTime
	moduleData.boolean_isNotShowBegin = moduleData.boolean_isNotShowBegin or defaultValue.boolean_isNotShowBegin
	--check
	if(buttonNumber==0)then
		print("No button object")
		return
	end
	group_displayScreen = display.newGroup()
	group_buttonsField = display.newGroup()
	
	--black background
	moduleData.bgObj = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
	
	moduleData.bgObj:setFillColor( unpack(moduleData.bgColor) )
	moduleData.bgObj.anchorX = 0.5
	moduleData.bgObj.anchorY = 0.5
	moduleData.bgObj.alpha = moduleData.bgAlpha
	moduleData.bgObj:addEventListener("touch",backgronud_touch)

	group_displayScreen:insert(moduleData.bgObj)		
	--white background
	moduleData.choiceBgObj = display.newRoundedRect( display.contentCenterX, 0, display.contentWidth-20, moduleData.rowHeight*buttonNumber, moduleData.choiceFieldBgCornerRadius )
	moduleData.choiceBgObj:setFillColor( unpack(moduleData.choiceFieldBgColor) )
	moduleData.choiceBgObj:setStrokeColor(  unpack(moduleData.choiceFieldStrokeColor) )
	moduleData.choiceBgObj.strokeWidth = moduleData.choiceFieldStrokeWidth
	moduleData.choiceBgObj.anchorX=0.5
	moduleData.choiceBgObj.anchorY=0
	moduleData.choiceBgObj.alpha = moduleData.choiceFieldBgAlpha
	group_buttonsField:insert(moduleData.choiceBgObj)

	moduleData.obj = {}
	
	for i = 1,buttonNumber do
		objY = moduleData.choiceBgObj.y+moduleData.rowHeight/2+(i-1)*moduleData.rowHeight
		
		if(moduleData.choiceObjType[i]=="text")then
			moduleData.obj[i] = {
				text = moduleData.choiceObj[i], 
				x = display.contentCenterX,
				y = objY,
				width = moduleData.choiceBgObj.width,
				height = 0, 
				font = moduleData.choiceObj_fontFamily,
				fontSize = moduleData.choiceObj_fontSize,
				align = moduleData.choiceObj_align
			}
			moduleData.obj[i] = display.newText(moduleData.obj[i])
			moduleData.obj[i].anchorX = 0.5
			moduleData.obj[i].anchorY = 0.5
			moduleData.obj[i]:setFillColor( unpack(moduleData.choiceObj_textColor) )
			group_buttonsField:insert(moduleData.obj[i])
			moduleData.obj[i].height=moduleData.rowHeight
			
		elseif(moduleData.choiceObjType[i]=="image")then
			moduleData.obj[i] = display.newImage(moduleData.choiceObj[i])
			moduleData.obj[i].x = display.contentCenterX
			moduleData.obj[i].y = objY
			moduleData.obj[i].anchorX = 0.5
			moduleData.obj[i].anchorY = 0.5
			group_buttonsField:insert(moduleData.obj[i])
		else
			moduleData.obj[i] = {}
			print("object num "..i.." is wrong type, not text and image.")
		end
		
	end
	
	--choice field background line 
	background_choiceField_beginX = moduleData.choiceBgObj.x-moduleData.choiceBgObj.width*moduleData.choiceBgObj.anchorX+moduleData.choiceBgObj.strokeWidth
	--
	background_choiceField_endX = background_choiceField_beginX+moduleData.choiceBgObj.width-moduleData.choiceBgObj.strokeWidth-1
	--
	lineObjY = moduleData.choiceBgObj.y+moduleData.rowHeight
	
	for i =1,buttonNumber-1 do
		moduleData.choiceBgLineObj = display.newLine(background_choiceField_beginX,lineObjY,background_choiceField_endX,lineObjY)
		moduleData.choiceBgLineObj:setStrokeColor( unpack(moduleData.choiceFieldBgLilneColor) )
		moduleData.choiceBgLineObj.strokeWidth = moduleData.choiceFieldBgLineWidth
		moduleData.choiceBgLineObj.alpha = moduleData.choiceFieldBgLineAlpha
		group_buttonsField:insert(moduleData.choiceBgLineObj)
		lineObjY = lineObjY+moduleData.rowHeight
	end
	--cancel button
	--cancel button background
	if(not moduleData.boolean_noCancelButton)then
	
		moduleData.cancelButtonBg = display.newRoundedRect( display.contentCenterX, moduleData.choiceBgObj.y+moduleData.choiceBgObj.height+moduleData.offsetBtwChoiceAndCancel, moduleData.choiceBgObj.width, moduleData.rowHeight, moduleData.choiceFieldBgCornerRadius )
		moduleData.cancelButtonBg:setFillColor( unpack(moduleData.choiceFieldBgColor))
		moduleData.cancelButtonBg:setStrokeColor( unpack(moduleData.choiceFieldStrokeColor) )
		moduleData.cancelButtonBg.strokeWidth = moduleData.choiceFieldStrokeWidth
		moduleData.cancelButtonBg.anchorX=0.5
		moduleData.cancelButtonBg.anchorY=0
		moduleData.cancelButtonBg.alpha = moduleData.choiceFieldBgAlpha
		group_buttonsField:insert(moduleData.cancelButtonBg)
		--cancel button
		moduleData.cancelButtonObj = {
			text = moduleData.cancelButtonText, 
			x = display.contentCenterX,
			y = moduleData.cancelButtonBg.y+moduleData.rowHeight/2,
			width = moduleData.choiceBgObj.width,
			height = 0, 
			font = moduleData.choiceObj_fontFamily,
			fontSize=moduleData.choiceObj_fontSize,
			align=moduleData.choiceObj_align
		}
		moduleData.cancelButtonObj = display.newText(moduleData.cancelButtonObj)
		moduleData.cancelButtonObj.anchorX = 0.5
		moduleData.cancelButtonObj.anchorY = 0.5
		moduleData.cancelButtonObj:setFillColor( unpack(moduleData.choiceObj_textColor) )
		moduleData.cancelButtonObj:addEventListener("touch",cancelButtonFnc)
		group_buttonsField:insert(moduleData.cancelButtonObj)
		moduleData.cancelButtonObj.height = moduleData.rowHeight
	end
	
	--group setting
	
	group_buttonsField.y = display.contentHeight
	group_displayScreen:insert(group_buttonsField)
	group_displayScreen.y = 0
	group_displayScreen.alpha = 0
	
	displayTransPos = display.contentHeight-group_buttonsField.height-moduleData.offsetBtwCancelAndBottom
	hideTransPos = display.contentHeight
	
	if(not moduleData.boolean_isNotShowBegin)then
		if(not boolean_isDisplay)then
			moduleGroup.display()
		else
			moduleGroup.hide()
		end
	end
	
	return group_displayScreen
end





return moduleGroup