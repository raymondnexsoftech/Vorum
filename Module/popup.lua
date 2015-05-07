local json = require("json")
local moduleGroup = {}
local moduleData
local displayGroup
local popupGroup

--obj
local background
local popupBackground
local doneButton
local doneButtonText
local cancelButton
local cancelButtonText
local isoLine
--transition
local transition_popupGroup
local transition_background
--temp
local temp_doneButtonX
local temp_doneButtonY
local temp_doneButtonWidth
local temp_doneButtonHeight
local temp_doneButtonAnchorX
local temp_doneButtonAnchorY

local temp_cancelButtonX
local temp_cancelButtonY
local temp_cancelButtonWidth
local temp_cancelButtonHeight
local temp_cancelButtonAnchorX
local temp_cancelButtonAnchorY

local temp_targetBeginX
local temp_targetBeginY
local temp_targetEndX
local temp_targetEndY

local defaultVaule = 
{
	--necessary
	popupObj = {},
	popupObjFncType = {},
	popupObjFnc = {},
	--option

	bgColor = {0.5,0.5,0.5},
	bgAlpha = 0.7,
	touchBgNotCancel = false,
	
	popupBgImagePath = nil,----------
	popupBgColor = {78/255,184/255,229/255},
	popupBgAlpha = 1,
	popupBgWidth = 600,
	popupBgHeight = 300,
	popupBgStrokeWidth = 0,
	popupBgStrokeColor = {0,0,0},
	
	buttonHeight = 80,
	--set all button
	buttonFont = "Helvetica",   
	buttonTextAlign = "center",  
	buttonSize = 48,
	buttonColor = {30/255,144/255,205/255},
	buttonAlpha = 1,
	buttonTextColor = {1,1,1},
	buttonTextAlpha = 1,
	buttonTouchColor = {30/255,144/255,205/255},
	buttonTouchAlpha = 0.5,
	buttonTextTouchColor = {1,1,1},
	buttonTextTouchAlpha = 1,
	
	noDoneButton = false,
	doneButtonText = "Done",
	doneButtonCallBackFnc = nil,
	doneButtonListener = nil,
	doneButtonImagePath = nil,----------
	
	doneButtonFont = "Helvetica",   
	doneButtonTextAlign = "center",  
	doneButtonSize = 48,
	doneButtonColor = {30/255,144/255,205/255},
	doneButtonAlpha = 1,
	doneButtonTextColor = {1,1,1},
	doneButtonTextAlpha = 1,
	doneButtonTouchColor = {30/255,144/255,205/255},
	doneButtonTouchAlpha = 0.5,
	doneButtonTextTouchColor = {1,1,1},
	doneButtonTextTouchAlpha = 1,
	
	noCancelButton = false,
	cancelButtonText = "Cancel",
	cancelButtonCallBackFnc = nil,
	cancelButtonListener = nil,
	cancelButtonImagePath = nil,----------
	
	cancelButtonFont = "Helvetica",   
	cancelButtonTextAlign = "center",  
	cancelButtonSize = 48,
	cancelButtonColor = {30/255,144/255,205/255},
	cancelButtonAlpha = 1,
	cancelButtonTextColor = {1,1,1},
	cancelButtonTextAlpha = 1,
	cancelButtonTouchColor = {30/255,144/255,205/255},
	cancelButtonTouchAlpha = 0.5,
	cancelButtonTextTouchColor = {1,1,1},
	cancelButtonTextTouchAlpha = 1,
	
	buttonIsoLineWidth = 3,
	buttonIsoLineColor = {1,1,1},
	
	displayAnimation = "scale",
	displayAnimationTime = 200,
	displayListener = nil,

	hideAnimation = "scale",
	hideAnimationTime = 200,
	hideListener = nil,
}

local animationOption_example = 
{
	animation = "scale",
	animationTime = 200,
}

local function clear()
	if(displayGroup)then
		display.remove(displayGroup)
		displayGroup = nil
		popupGroup = nil
	end
end
local function addObjFnc()
	for i=1,#moduleData.popupObj do
		if(type(moduleData.popupObjFncType[i])=="string" and type(moduleData.popupObjFnc[i])=="function")then
			moduleData.popupObj[i]:addEventListener(moduleData.popupObjFncType[i],moduleData.popupObjFnc[i])
		end
	end
end
local function removeObjFnc()
	for i=1,#moduleData.popupObj do
		if(type(moduleData.popupObjFncType[i])=="string" and type(moduleData.popupObjFnc[i])=="function")then
			moduleData.popupObj[i]:removeEventListener(moduleData.popupObjFncType[i],moduleData.popupObjFnc[i])
		end
	end
end
function moduleGroup.hideAnimation_scale()
	removeObjFnc()

	transition_background = transition.to(background,{time=moduleData.hideAnimationTime,alpha=0})
	transition_popupGroup = transition.scaleTo(popupGroup,{time=moduleData.hideAnimationTime,xScale=0,yScale=0,onComplete=function(event)
		clear()
		transition_popupGroup = nil
		if ( type(moduleData.hideListener)=="function") then
			moduleData.hideListener()
		end
	end})
end


function moduleGroup.displayAnimation_scale()
	
	popupGroup:scale(0,0)

	background.alpha = 0
	transition_background = transition.to(background,{time=moduleData.displayAnimationTime,alpha=moduleData.bgAlpha})
	transition_popupGroup = transition.scaleTo(popupGroup,{time=moduleData.displayAnimationTime,xScale=1,yScale=1,onComplete=function(event)
		addObjFnc()
		transition_popupGroup = nil
		if ( type(moduleData.displayListener)=="function") then
			moduleData.displayListener()
		end
	end})
end

function moduleGroup.hide(animationOption)
	if(animationOption)then
		moduleData.hideAnimation = animationOption.animation or moduleData.hideAnimation
		moduleData.hideAnimationTime = animationOption.animationTime or moduleData.hideAnimationTime
	end
	if(transition_popupGroup)then
		transition.cancel(transition_popupGroup)
	end
	if(transition_background)then
		transition.cancel(transition_background)
	end
	if(moduleData.hideAnimation=="scale")then
		moduleGroup.hideAnimation_scale()
	else
		removeObjFnc()
		clear()
		if ( type(moduleData.hideListener)=="function") then
			moduleData.hideListener()
		end
	end
end

function moduleGroup.display(animationOption)
	if(animationOption)then
		moduleData.displayAnimation = animationOption.animation or moduleData.displayAnimation
		moduleData.displayAnimationTime = animationOption.animationTime or moduleData.displayAnimationTime
	end
	if(transition_popupGroup)then
		transition.cancel(transition_popupGroup)
	end
	if(transition_background)then
		transition.cancel(transition_background)
	end
	if(moduleData.displayAnimation=="scale")then
		moduleGroup.displayAnimation_scale()
	else
		addObjFnc()
		if ( type(moduleData.displayListener)=="function") then
			moduleData.displayListener()
		end
	end
end


local function touchBackgroundCancelFnc(event)
	if(event.phase=="ended" or event.phase=="cancelled")then
		moduleGroup.hide()
	end
	return true
end

local function doneFnc(event)
	if(event.phase=="began")then
		
		doneButtonText:setFillColor(unpack(moduleData.doneButtonTextTouchColor))
		doneButtonText.alpha = moduleData.doneButtonTextTouchAlpha
		if(moduleData.doneButtonImagePath)then
		else
			event.target:setFillColor(unpack(moduleData.doneButtonTouchColor))
		end
		event.target.alpha = moduleData.doneButtonTouchAlpha
		
        display.getCurrentStage():setFocus( event.target )
	elseif(event.phase=="ended" or event.phase=="cancelled")then
	
		doneButtonText:setFillColor(unpack(moduleData.doneButtonTextColor))
		doneButtonText.alpha = moduleData.doneButtonTextAlpha
		
		if(moduleData.doneButtonImagePath)then
		else
			event.target:setFillColor(unpack(moduleData.doneButtonColor))
		end
		event.target.alpha = moduleData.doneButtonAlpha
		
        display.getCurrentStage():setFocus(nil)
		
		temp_targetBeginX = popupGroup.x+event.target.x - (event.target.width - (1-event.target.anchorX)*event.target.width)
		temp_targetEndX = temp_targetBeginX + event.target.width
		temp_targetBeginY = popupGroup.y+event.target.y - (event.target.height - (1-event.target.anchorY)*event.target.height)
		temp_targetEndY = temp_targetBeginY + event.target.height
		
		if(event.x>=temp_targetBeginX and event.x<=temp_targetEndX and event.y>=temp_targetBeginY and event.y<=temp_targetEndY)then
			moduleGroup.hide()
			if(moduleData.doneButtonCallBackFnc)then
				moduleData.doneButtonCallBackFnc(event)
			end
		end
	end
	if(moduleData.doneButtonListener)then
		moduleData.doneButtonListener(event)
	end
	return true
end

local function cancelFnc(event)
	if(event.phase=="began")then
		
		cancelButtonText:setFillColor(unpack(moduleData.cancelButtonTextTouchColor))
		cancelButtonText.alpha = moduleData.cancelButtonTextTouchAlpha
		
		if(moduleData.cancelButtonImagePath)then
		
		else
			event.target:setFillColor(unpack(moduleData.cancelButtonTouchColor))
		end
		event.target.alpha = moduleData.cancelButtonTouchAlpha
		
        display.getCurrentStage():setFocus( event.target )
		
	elseif(event.phase=="ended" or event.phase=="cancelled")then
		
		cancelButtonText:setFillColor(unpack(moduleData.cancelButtonTextColor))
		cancelButtonText.alpha = moduleData.cancelButtonTextAlpha
		
		if(moduleData.cancelButtonImagePath)then
		else
			event.target:setFillColor(unpack(moduleData.cancelButtonColor))
		end
		event.target.alpha = moduleData.cancelButtonAlpha
		
		display.getCurrentStage():setFocus(nil)
		
		temp_targetBeginX = popupGroup.x+event.target.x - (event.target.width - (1-event.target.anchorX)*event.target.width)
		temp_targetEndX = temp_targetBeginX + event.target.width
		temp_targetBeginY = popupGroup.y+event.target.y - (event.target.height - (1-event.target.anchorY)*event.target.height)
		temp_targetEndY = temp_targetBeginY + event.target.height
		
		if(event.x>=temp_targetBeginX and event.x<=temp_targetEndX and event.y>=temp_targetBeginY and event.y<=temp_targetEndY)then
			moduleGroup.hide()
			if(moduleData.cancelButtonCallBackFnc)then
				moduleData.cancelButtonCallBackFnc(event)
			end
		end
	end
	if(moduleData.cancelButtonListener)then
		moduleData.cancelButtonListener(event)
	end
	return true
end
local function noFnc(event)
	return true
end
function moduleGroup.popup(newModuleData)
	moduleData = newModuleData
	
	moduleData.popupObj = moduleData.popupObj or defaultVaule.popupObj
	moduleData.popupObjFncType = moduleData.popupObjFncType or defaultVaule.popupObjFncType
	moduleData.popupObjFnc = moduleData.popupObjFnc or defaultVaule.popupObjFnc
	--background
	moduleData.bgColor = moduleData.bgColor or defaultVaule.bgColor
	moduleData.bgAlpha = moduleData.bgAlpha or defaultVaule.bgAlpha
	moduleData.touchBgNotCancel = moduleData.touchBgNotCancel or defaultVaule.touchBgNotCancel
	--pop up background
	moduleData.popupBgColor = moduleData.popupBgColor or defaultVaule.popupBgColor
	moduleData.popupBgAlpha = moduleData.popupBgAlpha or defaultVaule.popupBgAlpha
	moduleData.popupBgWidth = moduleData.popupBgWidth or defaultVaule.popupBgWidth
	moduleData.popupBgHeight = moduleData.popupBgHeight or defaultVaule.popupBgHeight
	moduleData.popupBgStrokeWidth = moduleData.popupBgStrokeWidth or defaultVaule.popupBgStrokeWidth
	moduleData.popupBgStrokeColor = moduleData.popupBgStrokeColor or defaultVaule.popupBgStrokeColor
	--button height
	moduleData.buttonHeight = moduleData.buttonHeight or defaultVaule.buttonHeight
	--done button
	moduleData.noDoneButton = moduleData.noDoneButton or defaultVaule.noDoneButton
	moduleData.doneButtonText = moduleData.doneButtonText or defaultVaule.doneButtonText
	moduleData.doneButtonCallBackFnc = moduleData.doneButtonCallBackFnc or defaultVaule.doneButtonCallBackFnc
	moduleData.doneButtonListener = moduleData.doneButtonListener or defaultVaule.doneButtonListener
	--if done button setting nil get button setting
	moduleData.doneButtonFont = moduleData.doneButtonFont or moduleData.buttonFont
	moduleData.doneButtonTextAlign = moduleData.doneButtonTextAlign or moduleData.buttonTextAlign
	moduleData.doneButtonSize = moduleData.doneButtonSize or moduleData.buttonSize
	moduleData.doneButtonColor = moduleData.doneButtonColor or moduleData.buttonColor
	moduleData.doneButtonAlpha = moduleData.doneButtonAlpha or moduleData.buttonAlpha
	moduleData.doneButtonTextColor = moduleData.doneButtonTextColor or moduleData.buttonTextColor
	moduleData.doneButtonTextAlpha = moduleData.doneButtonTextAlpha or moduleData.buttonTextAlpha
	moduleData.doneButtonTouchColor = moduleData.doneButtonTouchColor or moduleData.buttonTouchColor 
	moduleData.doneButtonTouchAlpha = moduleData.doneButtonTouchAlpha or moduleData.buttonTouchAlpha
	moduleData.doneButtonTextTouchColor = moduleData.doneButtonTextTouchColor or moduleData.buttonTextTouchColor
	moduleData.doneButtonTextTouchAlpha = moduleData.doneButtonTextTouchAlpha or moduleData.buttonTextTouchAlpha
	--if button setting nil get done button default value
	moduleData.doneButtonFont = moduleData.doneButtonFont or defaultVaule.doneButtonFont
	moduleData.doneButtonTextAlign = moduleData.doneButtonTextAlign or defaultVaule.doneButtonTextAlign
	moduleData.doneButtonSize = moduleData.doneButtonSize or defaultVaule.doneButtonSize
	moduleData.doneButtonColor = moduleData.doneButtonColor or defaultVaule.doneButtonColor
	moduleData.doneButtonAlpha = moduleData.doneButtonAlpha or defaultVaule.doneButtonAlpha
	moduleData.doneButtonTextColor = moduleData.doneButtonTextColor or defaultVaule.doneButtonTextColor
	moduleData.doneButtonTextAlpha = moduleData.doneButtonTextAlpha or defaultVaule.doneButtonTextAlpha
	moduleData.doneButtonTouchColor = moduleData.doneButtonTouchColor or defaultVaule.doneButtonTouchColor 
	moduleData.doneButtonTouchAlpha = moduleData.doneButtonTouchAlpha or defaultVaule.doneButtonTouchAlpha
	moduleData.doneButtonTextTouchColor = moduleData.doneButtonTextTouchColor or defaultVaule.doneButtonTextTouchColor
	moduleData.doneButtonTextTouchAlpha = moduleData.doneButtonTextTouchAlpha or defaultVaule.doneButtonTextTouchAlpha
	--cancel button
	moduleData.noCancelButton = moduleData.noCancelButton or defaultVaule.noCancelButton
	moduleData.cancelButtonText = moduleData.cancelButtonText or defaultVaule.cancelButtonText
	moduleData.cancelButtonCallBackFnc = moduleData.cancelButtonCallBackFnc or defaultVaule.cancelButtonCallBackFnc
	moduleData.cancelButtonListener = moduleData.cancelButtonListener or defaultVaule.cancelButtonListener
	--if cancel button setting nil get button setting
	moduleData.cancelButtonFont = moduleData.cancelButtonFont or moduleData.buttonFont
	moduleData.cancelButtonTextAlign = moduleData.cancelButtonTextAlign or moduleData.buttonTextAlign
	moduleData.cancelButtonSize = moduleData.cancelButtonSize or moduleData.buttonSize
	moduleData.cancelButtonColor = moduleData.cancelButtonColor or moduleData.buttonColor
	moduleData.cancelButtonAlpha = moduleData.cancelButtonAlpha or moduleData.buttonAlpha
	moduleData.cancelButtonTextColor = moduleData.cancelButtonTextColor or moduleData.buttonTextColor
	moduleData.cancelButtonTextAlpha = moduleData.cancelButtonTextAlpha or moduleData.buttonTextAlpha
	moduleData.cancelButtonTouchColor = moduleData.cancelButtonTouchColor or moduleData.buttonTouchColor
	moduleData.cancelButtonTouchAlpha = moduleData.cancelButtonTouchAlpha or moduleData.buttonTouchAlpha
	moduleData.cancelButtonTextTouchColor = moduleData.cancelButtonTextTouchColor or moduleData.buttonTextTouchColor
	moduleData.cancelButtonTextTouchAlpha = moduleData.cancelButtonTextTouchAlpha or moduleData.buttonTextTouchAlpha
	--if button setting nil get cancel button default value 
	moduleData.cancelButtonFont = moduleData.cancelButtonFont or defaultVaule.cancelButtonFont
	moduleData.cancelButtonTextAlign = moduleData.cancelButtonTextAlign or defaultVaule.cancelButtonTextAlign
	moduleData.cancelButtonSize = moduleData.cancelButtonSize or defaultVaule.cancelButtonSize
	moduleData.cancelButtonColor = moduleData.cancelButtonColor or defaultVaule.cancelButtonColor
	moduleData.cancelButtonAlpha = moduleData.cancelButtonAlpha or defaultVaule.cancelButtonAlpha
	moduleData.cancelButtonTextColor = moduleData.cancelButtonTextColor or defaultVaule.cancelButtonTextColor
	moduleData.cancelButtonTextAlpha = moduleData.cancelButtonTextAlpha or defaultVaule.cancelButtonTextAlpha
	moduleData.cancelButtonTouchColor = moduleData.cancelButtonTouchColor or defaultVaule.cancelButtonTouchColor
	moduleData.cancelButtonTouchAlpha = moduleData.cancelButtonTouchAlpha or defaultVaule.cancelButtonTouchAlpha
	moduleData.cancelButtonTextTouchColor = moduleData.cancelButtonTextTouchColor or defaultVaule.cancelButtonTextTouchColor
	moduleData.cancelButtonTextTouchAlpha = moduleData.cancelButtonTextTouchAlpha or defaultVaule.cancelButtonTextTouchAlpha
	--iso line
	moduleData.buttonIsoLineWidth = moduleData.buttonIsoLineWidth or defaultVaule.buttonIsoLineWidth
	moduleData.buttonIsoLineColor = moduleData.buttonIsoLineColor or defaultVaule.buttonIsoLineColor
	--animation
	moduleData.displayAnimation = moduleData.displayAnimation or defaultVaule.displayAnimation
	moduleData.displayAnimationTime = moduleData.displayAnimationTime or defaultVaule.displayAnimationTime
	moduleData.displayListener = moduleData.displayListener or defaultVaule.displayListener

	moduleData.hideAnimation = moduleData.hideAnimation or defaultVaule.hideAnimation
	moduleData.hideAnimationTime = moduleData.hideAnimationTime or defaultVaule.hideAnimationTime
	
	
	moduleData.popupBgImagePath = moduleData.popupBgImagePath or defaultVaule.popupBgImagePath
	moduleData.doneButtonImagePath = moduleData.doneButtonImagePath or defaultVaule.doneButtonImagePath
	moduleData.cancelButtonImagePath = moduleData.cancelButtonImagePath or defaultVaule.cancelButtonImagePath
	
	displayGroup = display.newGroup()
	if(not popupGroup)then
		popupGroup = display.newGroup()
	end
	
	background = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
	background:setFillColor( unpack(moduleData.bgColor))
	background.alpha = moduleData.bgAlpha
	background.anchorX = 0.5
	background.anchorY = 0.5
	background.isHitTestable = true
	displayGroup:insert(background)
	
	if(not moduleData.touchBgNotCancel)then
		background:addEventListener("touch",touchBackgroundCancelFnc)
	end
	if(moduleData.popupBgImagePath)then
		popupBackground = display.newImage(moduleData.popupBgImagePath,true)
		popupBackground.x = 0
		popupBackground.y = 0
	else
		popupBackground = display.newRect( 0, 0, moduleData.popupBgWidth, moduleData.popupBgHeight)
		popupBackground:setFillColor( unpack(moduleData.popupBgColor))
		popupBackground.strokeWidth = moduleData.popupBgStrokeWidth
		popupBackground:setStrokeColor( unpack(moduleData.popupBgStrokeColor))
	end
	popupBackground.alpha = moduleData.popupBgAlpha
	popupBackground.anchorX = 0.5
	popupBackground.anchorY = 0.5

	popupBackground:addEventListener("touch",noFnc)
	popupGroup:insert(popupBackground)
	
	if(not moduleData.noDoneButton and not moduleData.noCancelButton)then
		temp_doneButtonX = popupBackground.x+popupBackground.width/4
		temp_doneButtonY = popupBackground.y+popupBackground.height/2
		temp_doneButtonWidth = popupBackground.width/2
		temp_doneButtonHeight = moduleData.buttonHeight
		
		temp_cancelButtonX = popupBackground.x-popupBackground.width/4
		temp_cancelButtonY = popupBackground.y+popupBackground.height/2
		temp_cancelButtonWidth = popupBackground.width/2
		temp_cancelButtonHeight = moduleData.buttonHeight
	elseif(not moduleData.noDoneButton and moduleData.noCancelButton)then
		temp_doneButtonX = popupBackground.x
		temp_doneButtonY = popupBackground.y+popupBackground.height/2
		temp_doneButtonWidth = popupBackground.width
		temp_doneButtonHeight = moduleData.buttonHeight
	elseif(moduleData.noDoneButton and not moduleData.noCancelButton)then
		temp_cancelButtonX = popupBackground.x
		temp_cancelButtonY = popupBackground.y+popupBackground.height/2
		temp_cancelButtonWidth = popupBackground.width
		temp_cancelButtonHeight = moduleData.buttonHeight
	end
	
	if(not moduleData.noDoneButton)then
	
	
		if(moduleData.doneButtonImagePath)then
			doneButton = display.newImage(moduleData.doneButtonImagePath,true)
			doneButton.x = temp_doneButtonX+1
			doneButton.y = temp_doneButtonY-moduleData.buttonHeight
		else
			doneButton = display.newRect( temp_doneButtonX, temp_doneButtonY, temp_doneButtonWidth, temp_doneButtonHeight)
			doneButton:setFillColor(unpack(moduleData.doneButtonColor))
		end
		doneButton.anchorX = 0.5
		doneButton.anchorY = 0	
		doneButton.alpha = moduleData.doneButtonAlpha
		doneButton:addEventListener("touch",doneFnc)
		popupGroup:insert(doneButton)
		
		doneButtonText = {
			text = moduleData.doneButtonText,     
			x = doneButton.x,
			y = doneButton.y+doneButton.height/2,
			width = 0,
			height = 0,
			font = moduleData.doneButtonFont,   
			fontSize = moduleData.doneButtonSize,
			align = moduleData.doneButtonTextAlign,
		}
		doneButtonText = display.newText( doneButtonText )
		doneButtonText.anchorX = 0.5
		doneButtonText.anchorY = 0.5
		doneButtonText.alpha = moduleData.doneButtonTextAlpha
		doneButtonText:setFillColor(unpack(moduleData.doneButtonTextColor))
		popupGroup:insert(doneButtonText)
		
	end
	if(not moduleData.noCancelButton)then

		if(moduleData.cancelButtonImagePath)then
			cancelButton = display.newImage(moduleData.cancelButtonImagePath,true)
			cancelButton.x = temp_cancelButtonX
			cancelButton.y = temp_cancelButtonY-moduleData.buttonHeight
		else
			cancelButton = display.newRect( temp_cancelButtonX, temp_cancelButtonY, temp_cancelButtonWidth, temp_cancelButtonHeight)
			cancelButton:setFillColor(unpack(moduleData.cancelButtonColor))
		end
		cancelButton.anchorX = 0.5
		cancelButton.anchorY = 0
		cancelButton.alpha = moduleData.cancelButtonAlpha
		cancelButton:addEventListener("touch",cancelFnc)
	
		popupGroup:insert(cancelButton)
		cancelButtonText = {
			text = moduleData.cancelButtonText,     
			x = cancelButton.x,
			y = cancelButton.y+cancelButton.height/2,
			width = 0,
			height = 0,
			font = moduleData.cancelButtonFont,   
			fontSize = moduleData.cancelButtonSize,
			align = moduleData.cancelButtonTextAlign,
		}
		cancelButtonText = display.newText( cancelButtonText )
		cancelButtonText.anchorX = 0.5
		cancelButtonText.anchorY = 0.5
		cancelButtonText.alpha = moduleData.cancelButtonTextAlpha
		cancelButtonText:setFillColor(unpack(moduleData.cancelButtonTextColor))
		popupGroup:insert(cancelButtonText)
	end
	
	if(not moduleData.noDoneButton and not moduleData.noCancelButton and not moduleData.doneButtonImagePath and not moduleData.cancelButtonImagePath)then
		isoLine = display.newLine(popupBackground.x,doneButton.y+doneButton.height/2,popupBackground.x,doneButton.y+doneButton.height)
		isoLine.strokeWidth = moduleData.buttonIsoLineWidth
		isoLine:setStrokeColor (unpack(moduleData.buttonIsoLineColor))
		popupGroup:insert(isoLine)
	end

	for i=1,#moduleData.popupObj do
		popupGroup:insert(moduleData.popupObj[i])
	end
	
	displayGroup:insert(popupGroup)
	popupGroup.x = display.contentCenterX
	popupGroup.y = display.contentCenterY

	moduleGroup.display()
	return popupGroup
end
function moduleGroup.getPopupGroup()
	if(not popupGroup)then
		popupGroup = display.newGroup()
	end
	return popupGroup
end
return moduleGroup