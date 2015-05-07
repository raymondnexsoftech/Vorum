---------------------------------------------------------------
-- CoronaTextField.lua
--
-- Text field for corona
---------------------------------------------------------------

---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local DEFAULT_FONT = native.systemFont
local DEFAULT_SIZE = 16
local DEFAULT_TEXT_COLOR = {0, 0, 0, 1}
local INPUTFIELD_TO_TOP_SPACE = 20
local INPUTFIELD_TO_EDGE_SPACE = 20
local TRANSITION_TIME = 200
local TRANSITION_ON_COMPLETE_TIME = TRANSITION_TIME + 10
local IPHONE_SIM_KEYBOARD_HEIGHT = 216
local IPHONE_SIM_CANDIDATE_HEIGHT = 36
local IPHONE_SIM_KEYBOARD_TRANS_TIME = 200

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
local simulatedKeyboard = nil
local simulatedCandidate = nil

local activeTextFieldBaseGroup = nil

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------
local updatePlaceHolderVisible
local setInputFieldProperty
local updateDisplayText
local remakeDisplayText
local textFieldLoseFocus
local createInputField
local destroyInputField
local copyTable
local parentTransition
local backButtonTouchListener
local textFieldEndEditing
local screenMaskTouchListener
local textFieldUserInputListener
local textFieldTouchListener
local getFocusTransitionCompleteHandler
local lossFocusTransitionCompleteHandler
local showSimulatedKeyboard
local afterHideKeyboardListener
local afterHideCandidateListener
local hideSimulatedKeyboard

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
local CoronaTextField = {}


local function getTextViewWordHeight(baseGroup)
	local testText = "Ag"
	local textView = display.newText(testText,-1000,-1000,0,0)
	textView.size = baseGroup._size
	local wordHeight = textView.height
	display:remove(textView)
	textView = nil
	return wordHeight
end

updatePlaceHolderVisible = function(baseGroup)
	if (baseGroup.placeHolder) then
		if (baseGroup.inputField) then
			baseGroup.placeHolder.isVisible = false
		else
			if (baseGroup.displayText) then
				baseGroup.placeHolder.isVisible = (baseGroup.displayText.text == "")
			else
				baseGroup.placeHolder.isVisible = true
			end
		end
	end
end

updateDisplayText = function(baseGroup)
	if (baseGroup.isSecure == true) then
		local textLen = 0
		if (baseGroup._text) then
			textLen = string.len(baseGroup._text)
		end
		local newText = ""
		for i = 1, textLen do
			newText = newText .. "*"
		end
		baseGroup.displayText.text = newText
	else
		baseGroup.displayText.text = baseGroup._text
	end
--	baseGroup.displayText:setReferencePoint(display.TopRightReferencePoint)
	baseGroup.displayText.anchorY = 0.5
	baseGroup.displayText.y = baseGroup.textFieldBg.height * 0.5
	if (baseGroup._align == "right") then
		baseGroup.displayText.anchorX = 1
		baseGroup.displayText.x = baseGroup.textFieldBg.width
	elseif (baseGroup.align == "center") then
		baseGroup.displayText.anchorX = 0.5
		baseGroup.displayText.x = baseGroup.textFieldBg.width * 0.5
	else
		baseGroup.displayText.anchorX = 0
		baseGroup.displayText.x = 0
	end
	updatePlaceHolderVisible(baseGroup)
end

remakeDisplayText = function(baseGroup)
	if (baseGroup.displayText ~= nil) then
		-- baseGroup.displayText:removeEventListener("touch", textFieldTouchListener)
		baseGroup.displayText:removeSelf()
		baseGroup.displayText = nil
	end
	local wordHeight = getTextViewWordHeight(baseGroup)
	local TextOptions =
	{
	    text = baseGroup._text,
	    x = 0,
	    y = 0,
	    width = baseGroup.textFieldBg.width,
	    height = wordHeight,
	    font = baseGroup._font,
	    fontSize = baseGroup._size,
	    align = baseGroup._align,
	}
	baseGroup.displayText = display.newText( TextOptions )
	-- baseGroup.displayText = display.newText(baseGroup._text, 0, 0, baseGroup.textFieldBg.width, baseGroup._size + 3, baseGroup._font, baseGroup._size)

	baseGroup.displayText.baseGroup = baseGroup
	if (baseGroup.inputField ~= nil) then
		baseGroup.displayText.isVisible = false
	end
	if (baseGroup.fillColor ~= nil) then
		baseGroup.displayText:setFillColor(baseGroup.fillColor[1], baseGroup.fillColor[2], baseGroup.fillColor[3], baseGroup.fillColor[4])
	end
	baseGroup:insert(baseGroup.displayText)
	updateDisplayText(baseGroup)
	-- baseGroup.displayText:addEventListener("touch", textFieldTouchListener)
end

setInputFieldProperty = function(baseGroup, property)
	local _property = "_" .. property
	if (baseGroup[_property] ~= nil) then
		baseGroup.inputField[property] = baseGroup[_property]
	end
end

textFieldLoseFocus = function(baseGroup)
	if (baseGroup.parentForShifting ~= nil) then
		if ((baseGroup.parentOffsetX ~= 0) or (baseGroup.parentOffsetY ~= 0)) then
			if (baseGroup.parentType == "scrollView") then
				local scrollViewX, scrollViewY = baseGroup.parentForShifting:getContentPosition()
				if (baseGroup.parentForShifting._view._height - baseGroup.parentForShifting._view._scrollHeight > scrollViewY) then
					scrollViewY = baseGroup.parentForShifting._view._height - baseGroup.parentForShifting._view._scrollHeight
				end
				baseGroup.parentForShifting:scrollToPosition{y = scrollViewY, time = TRANSITION_TIME}
				timer.performWithDelay( TRANSITION_ON_COMPLETE_TIME, lossFocusTransitionCompleteHandler(baseGroup) )					
			elseif (baseGroup.parentType == "displayGroup") then
				transition.to(baseGroup.parentForShifting, {y = baseGroup.parentForShifting.y - baseGroup.parentOffsetY, time = TRANSITION_TIME})
				timer.performWithDelay( TRANSITION_ON_COMPLETE_TIME, lossFocusTransitionCompleteHandler(baseGroup) )					
			else
				destroyInputField(baseGroup)
			end
			baseGroup.parentOffsetX = 0
			baseGroup.parentOffsetY = 0
		else
			destroyInputField(baseGroup)
		end
	else
		destroyInputField(baseGroup)
	end
	baseGroup.parentOffsetY = 0
end

createInputField = function(baseGroup)
	if (baseGroup.screenMask == nil) then
		baseGroup.screenMask = display.newRect(display.contentWidth * 0.5, display.contentHeight * 0.5, display.contentWidth, display.contentHeight)
		baseGroup.screenMask.baseGroup = baseGroup
		baseGroup.screenMask:setFillColor(0, 0, 0, 0.01)
		baseGroup.screenMask:addEventListener("touch", screenMaskTouchListener)
	 	activeTextFieldBaseGroup = baseGroup
	 	Runtime:addEventListener("key", backButtonTouchListener)
	end
	if (baseGroup.inputField == nil) then
		baseGroup.displayText.isVisible = false
		local textFieldContentX, textFieldContentY = baseGroup.textFieldBg:localToContent( 0, 0 )
		textFieldContentX = textFieldContentX + baseGroup.parentOffsetX
		textFieldContentY = textFieldContentY + baseGroup.parentOffsetY
		baseGroup.parentOffsetX = baseGroup.parentOffsetX + baseGroup.prevOffsetX
		baseGroup.parentOffsetY = baseGroup.parentOffsetY + baseGroup.prevOffsetY
		baseGroup.prevOffsetX = 0
		baseGroup.prevOffsetY = 0
		local textFieldWidth, textFieldHeight = baseGroup.textFieldBg.width, baseGroup.textFieldBg.height
		textFieldContentX = textFieldContentX
		textFieldContentY = textFieldContentY
		baseGroup.inputField = native.newTextField(textFieldContentX, textFieldContentY, textFieldWidth, textFieldHeight)
		baseGroup.inputField.hasBackground = false
		setInputFieldProperty(baseGroup, "align")
		setInputFieldProperty(baseGroup, "inputType")
		setInputFieldProperty(baseGroup, "isSecure")
		baseGroup.inputField.font = native.newFont(baseGroup._font)
		setInputFieldProperty(baseGroup, "size")
		baseGroup.inputField.isFontSizeScaled = true
		setInputFieldProperty(baseGroup, "text")
		if (baseGroup.fillColor ~= nil) then
--			baseGroup.inputField:setTextColor(baseGroup.fillColor[1], baseGroup.fillColor[2], baseGroup.fillColor[3], baseGroup.fillColor[4])
			baseGroup.inputField:setTextColor(baseGroup.fillColor[1] * 255, baseGroup.fillColor[2] * 255, baseGroup.fillColor[3] * 255, baseGroup.fillColor[4] * 255)
		end
		if (baseGroup.returnKey ~= nil) then
			baseGroup.inputField:setReturnKey(baseGroup.returnKey)
		end
		baseGroup.inputField.baseGroup = baseGroup
		baseGroup.inputField:addEventListener("userInput", textFieldUserInputListener)
		native.setKeyboardFocus(baseGroup.inputField)
	end
	updatePlaceHolderVisible(baseGroup)
	showSimulatedKeyboard()
end

destroyInputField = function(baseGroup)
	if (baseGroup.screenMask) then
		baseGroup.screenMask:removeEventListener("touch", screenMaskTouchListener)
	 	activeTextFieldBaseGroup = nil
	 	Runtime:removeEventListener( "key", backButtonTouchListener )
		baseGroup.screenMask:removeSelf()
		baseGroup.screenMask = nil
	end
	if (baseGroup.inputField ~= nil) then
		baseGroup.inputField.isVisible = false
		baseGroup._text = baseGroup.inputField.text
		baseGroup.inputField:removeEventListener("userInput", textFieldUserInputListener)
		baseGroup.inputField:removeSelf()
		baseGroup.inputField = nil
		baseGroup.displayText.isVisible = true
		updateDisplayText(baseGroup)
	end
	native.setKeyboardFocus(nil)
	hideSimulatedKeyboard()
end

copyTable = function(origTable)
	local newTable
	if (type(origTable) == "table") then
		newTable = {}
		for k, v in pairs(origTable) do
			newTable[k] = copyTable(origTable[k])
		end
	else
		newTable = origTable
	end
	return newTable
end

parentTransition = function(baseGroup, prevOffsetX, prevOffsetY)
	baseGroup.prevOffsetX = prevOffsetX
	baseGroup.prevOffsetY = prevOffsetY
	if (baseGroup.parentType == "custom") then
		-- Bypass the "createInputField" and let user call "enableInput" manually
	elseif (baseGroup.parentForShifting ~= nil) then
		local textFieldScreenPosX, textFieldScreenPosY = baseGroup.textFieldBg:localToContent( 0, 0 )
		baseGroup.parentOffsetX = 0
		baseGroup.parentOffsetY = baseGroup.topPadding - textFieldScreenPosY + (baseGroup.textFieldBg.height * 0.5)
		if (baseGroup.parentOffsetY > 0) then
			baseGroup.parentOffsetY = 0
		end
		if (baseGroup.parentType == "scrollView") then
			local scrollViewX, scrollViewY = baseGroup.parentForShifting:getContentPosition()
			local newScrollX = scrollViewX
			local newScrollY = scrollViewY
			if (baseGroup.parentForShifting._view._isHorizontalScrollingDisabled == false) then
				if ((textFieldScreenPosX - (baseGroup.textFieldBg.width * 0.5) < 0)
					or (baseGroup.textFieldBg.width + baseGroup.edgePadding * 2 > display.contentWidth)) then
					baseGroup.parentOffsetX = baseGroup.edgePadding - textFieldScreenPosX + (baseGroup.textFieldBg.width * 0.5)
				elseif (textFieldScreenPosX + (baseGroup.textFieldBg.width * 0.5) > display.contentWidth) then
					baseGroup.parentOffsetX = display.contentWidth - baseGroup.edgePadding - textFieldScreenPosX - (baseGroup.textFieldBg.width * 0.5)
				end
				newScrollX = scrollViewX + baseGroup.parentOffsetX
				if (newScrollX > 0) then
					newScrollX = 0
					baseGroup.parentOffsetX = newScrollX - scrollViewX
				elseif (baseGroup.parentForShifting._view._width - baseGroup.parentForShifting._view._scrollWidth > newScrollX) then
					newScrollX = baseGroup.parentForShifting._view._width - baseGroup.parentForShifting._view._scrollWidth
					baseGroup.parentOffsetX = newScrollX - scrollViewX
				end
			end
			if (baseGroup.parentForShifting._view._isVerticalScrollingDisabled == false) then
				newScrollY = scrollViewY + baseGroup.parentOffsetY
				if (newScrollY > 0) then
					newScrollY = 0
					baseGroup.parentOffsetY = newScrollY - baseGroup.parentOffsetY
				end
			else
				baseGroup.parentOffsetY = 0
			end
			if ((baseGroup.parentOffsetX ~= 0) or (baseGroup.parentOffsetY ~= 0)) then
				baseGroup.parentForShifting:scrollToPosition{x = newScrollX, y = newScrollY, time = TRANSITION_TIME}
				timer.performWithDelay( TRANSITION_ON_COMPLETE_TIME, getFocusTransitionCompleteHandler(baseGroup) )					
			else
				createInputField(baseGroup)
			end
		elseif (baseGroup.parentType == "displayGroup") then
			if (baseGroup.parentOffsetY > 0) then
				baseGroup.parentOffsetY = 0
			end
			if (baseGroup.parentOffsetY ~= 0) then
				transition.to(baseGroup.parentForShifting, {y = baseGroup.parentForShifting.y + baseGroup.parentOffsetY, time = TRANSITION_TIME})
				timer.performWithDelay( TRANSITION_ON_COMPLETE_TIME, getFocusTransitionCompleteHandler(baseGroup) )					
			else
				createInputField(baseGroup)
			end
		else
			createInputField(baseGroup)
		end
	else
		createInputField(baseGroup)
	end
end

backButtonTouchListener = function(event)
	if ((event.phase == "down") and (event.keyName == "back")) then
		textFieldEndEditing(activeTextFieldBaseGroup)
		-- destroyInputField(activeTextFieldBaseGroup)
	end
end

textFieldEndEditing = function(baseGroup)
	if (baseGroup.userInputListener ~= nil) then
		baseGroup._text = baseGroup.inputField.text
		local userInputEvent = {
								name = "userInput",
								target = baseGroup.inputField,
								phase = "ended"
								}
		baseGroup.userInputListener(userInputEvent)
	end
	textFieldLoseFocus(baseGroup)
end

screenMaskTouchListener = function(event)
	if (event.phase == "ended") then
		textFieldEndEditing(event.target.baseGroup)
	end
	return true
end

textFieldUserInputListener = function(event)
	local isLoseFocus = false
	local baseGroup = event.target.baseGroup
	if (event.phase == "editing") then
	elseif (event.phase == "ended") then
		baseGroup._text = baseGroup.inputField.text
		isLoseFocus = true
	elseif (event.phase == "submitted") then
		baseGroup._text = baseGroup.inputField.text
		if (baseGroup.nextTextField) then
			if ((baseGroup.jumpNextCallback == nil) or (baseGroup.jumpNextCallback(baseGroup))) then
				destroyInputField(baseGroup)
				parentTransition(baseGroup.nextTextField, baseGroup.parentOffsetX, baseGroup.parentOffsetY)
				baseGroup.parentOffsetX = 0
				baseGroup.parentOffsetY = 0
			end
		else
			isLoseFocus = true
		end
    end
	if (baseGroup.userInputListener ~= nil) then
		baseGroup.userInputListener(event)
	end
	if (isLoseFocus) then
		textFieldLoseFocus(baseGroup)
	end
end

textFieldTouchListener = function(event)
	local baseGroup = event.target.baseGroup
	if (event.phase == "began") then
		event.target.isFocus = true
		display.getCurrentStage():setFocus(event.target)
	elseif (event.phase == "ended") then
		if (event.target.isFocus == true) then
			parentTransition(baseGroup, 0, 0)
		end
		event.target.isFocus = false
		display.getCurrentStage():setFocus(nil)
	end
	if (baseGroup.touchListener ~= nil) then
		if (baseGroup.touchListener(event) == true) then
			return true
		end
	end
	return true
end

getFocusTransitionCompleteHandler = function(baseGroup)
	createInputField(baseGroup)
end

lossFocusTransitionCompleteHandler = function(baseGroup)
	destroyInputField(baseGroup)
end

showSimulatedKeyboard = function()
	if (simulatedKeyboard ~= nil) then
		simulatedKeyboard:removeSelf()
		simulatedKeyboard = nil
	end
	if (system.getInfo("environment") == "simulator") then 
		if (system.getInfo( "model" ) == "iPhone") then
			simulatedKeyboard = display.newRect(display.contentWidth * 0.5, display.contentHeight + IPHONE_SIM_CANDIDATE_HEIGHT + (IPHONE_SIM_KEYBOARD_HEIGHT * 0.5
				), display.contentWidth, IPHONE_SIM_KEYBOARD_HEIGHT)
			simulatedKeyboard:setFillColor(0.5, 0.5, 0.5, 1)
			simulatedCandidate = display.newRect(display.contentWidth * 0.5, display.contentHeight + (IPHONE_SIM_CANDIDATE_HEIGHT * 0.5), display.contentWidth, IPHONE_SIM_CANDIDATE_HEIGHT)
			simulatedCandidate:setFillColor(0.5, 0.5, 0.5, 0.5)
			transition.to(simulatedKeyboard, {y = display.contentHeight - (IPHONE_SIM_KEYBOARD_HEIGHT * 0.5), time = IPHONE_SIM_KEYBOARD_TRANS_TIME})
			transition.to(simulatedCandidate, {y = display.contentHeight - IPHONE_SIM_KEYBOARD_HEIGHT - (IPHONE_SIM_CANDIDATE_HEIGHT * 0.5), time = IPHONE_SIM_KEYBOARD_TRANS_TIME})
		end
	end
end

afterHideKeyboardListener = function(obj)
	simulatedKeyboard:removeSelf()
	simulatedKeyboard = nil
end

afterHideCandidateListener = function(obj)
	simulatedCandidate:removeSelf()
	simulatedCandidate = nil
end

hideSimulatedKeyboard = function()
	if (system.getInfo( "model" ) == "iPhone") then
		transition.to(simulatedKeyboard, {y = display.contentHeight + IPHONE_SIM_CANDIDATE_HEIGHT + (IPHONE_SIM_KEYBOARD_HEIGHT * 0.5), time = IPHONE_SIM_KEYBOARD_TRANS_TIME, onComplete = afterHideKeyboardListener})
		transition.to(simulatedCandidate, {y = display.contentHeight + (IPHONE_SIM_CANDIDATE_HEIGHT * 0.5), time = IPHONE_SIM_KEYBOARD_TRANS_TIME, onComplete = afterHideCandidateListener})
	end
end


function CoronaTextField:new(left, top, width, height, parentForShifting, parentType)
	local baseGroup = display.newGroup()

	baseGroup.x = left
	baseGroup.y = top
	baseGroup.parentForShifting = parentForShifting
	baseGroup.parentType = parentType
	baseGroup.parentOffsetX = 0
	baseGroup.parentOffsetY = 0
	baseGroup.prevOffsetX = 0
	baseGroup.prevOffsetY = 0
	baseGroup.topPadding = INPUTFIELD_TO_TOP_SPACE
	baseGroup.edgePadding = INPUTFIELD_TO_EDGE_SPACE

	baseGroup._text = ""
	baseGroup._font = DEFAULT_FONT
	baseGroup._size = DEFAULT_SIZE

	baseGroup.textFieldBg = display.newRect(width * 0.5, height * 0.5, width, height)
	baseGroup.textFieldBg.baseGroup = baseGroup
	baseGroup:insert(baseGroup.textFieldBg)
	remakeDisplayText(baseGroup)

	local originalMT = getmetatable(baseGroup)
	local baseGroupMT = copyTable(originalMT)
	local origMtIndex = originalMT.__index
	baseGroupMT.__index = function(t, k)
							local _k = "_" .. k
							if (rawget(t, "inputField") ~= nil) then
								if (k == "text") then
									return t.inputField[k]
								end
							end
							if ((k == "align")
								or (k == "inputType")
								or (k == "isSecure")
								or (k == "size")
								or (k == "text")) then
									return rawget(t, _k)
							end
							return origMtIndex(t, k)
						end
	baseGroupMT.__newindex = function(t, k, v)
								local normalUpdateTable = true
								local _k = "_" .. k
								if (t.inputField ~= nil) then
									if ((k == "align")
										or (k == "inputType")
										or (k == "isSecure")
										or (k == "size")
										or (k == "text")) then
											t[_k] = v
											normalUpdateTable = false
											t.inputField[k] = v
									end
								end
								if (k == "align") then
									t[_k] = v
									normalUpdateTable = false
									remakeDisplayText(t)
								elseif ((k == "isSecure")
									or (k == "text")) then
										t[_k] = v
										normalUpdateTable = false
										updateDisplayText(t)
								elseif (k == "size") then
									t[_k] = v
									normalUpdateTable = false
									remakeDisplayText(t)
								elseif ((k == "parentForShifting")
									or (k == "parentType")) then
										normalUpdateTable = false
								end
								if (normalUpdateTable) then
									rawset(t, k, v)
								end
							end
	setmetatable(baseGroup, baseGroupMT)

	function baseGroup:touchListener(listener)
		self.touchListener = listener
	end

	function baseGroup:setFillColor(...)
		self.fillColor = arg

		if (#self.fillColor >= 3) then
			if (#self.fillColor < 4) then
				self.fillColor[#self.fillColor + 1] = 1
			end
			if (self.inputField ~= nil) then
				self.inputField:setTextColor(self.fillColor[1] * 255, self.fillColor[2] * 255, self.fillColor[3] * 255, self.fillColor[4] * 255)
			end
			self.displayText:setFillColor(self.fillColor[1], self.fillColor[2], self.fillColor[3], self.fillColor[4])
		end
	end

	baseGroup:setFillColor(DEFAULT_TEXT_COLOR[1], DEFAULT_TEXT_COLOR[2], DEFAULT_TEXT_COLOR[3], DEFAULT_TEXT_COLOR[4])
	baseGroup.inputField = nil

	function baseGroup:setReturnKey(...)
		self.returnKey = {...}

		if (self.inputField ~= nil) then
			self.inputField:setReturnKey(...)
		end
	end

	function baseGroup:setBackgroundColor(...)
		self.textFieldBg:setFillColor(...)
	end

	function baseGroup:setFont(font, size)
		self._font = font
		self._size = size
		if (self.inputField ~= nil) then
			destroyInputField(self)
			createInputField(self)
		end
		remakeDisplayText(self)
	end

	function baseGroup:setTouchListener(listener)
		self.touchListener = listener
	end

	function baseGroup:setUserInputListener(listener)
		self.userInputListener = listener
	end

	function baseGroup:enableInput()
		createInputField(self)
	end

	function baseGroup:inputEnd()
		textFieldEndEditing(self)
	end

	function baseGroup:setTopPadding(topPadding)
		self.topPadding = topPadding
	end

	function baseGroup:setEdgePadding(edgePadding)
		self.edgePadding = edgePadding
	end

	function baseGroup:nextTextFieldFocus(nextTextField, jumpNextCallback)
		self.nextTextField = nextTextField
		self.jumpNextCallback = jumpNextCallback
	end

	function baseGroup:setKeyboardFocus()
		parentTransition(baseGroup, 0, 0)
	end

	function baseGroup:setPlaceHolderText(text)
		if (text == "") then
			if (self.placeHolder) then
				display.remove(self.placeHolder)
				self.placeHolder = nil
			end
		else
			if (self.placeHolder == nil) then
				local wordHeight = getTextViewWordHeight(baseGroup)
				self.placeHolder = display.newText(text, 5, baseGroup.textFieldBg.height * 0.5, baseGroup.textFieldBg.width - 10, wordHeight, baseGroup._font, baseGroup._size)
				self.placeHolder.anchorX = 0
				self.placeHolder:setFillColor(0.7, 0.7, 0.7, 1)
				self:insert(self.placeHolder)
			else
				self.placeHolder.text = text
			end
			updatePlaceHolderVisible(baseGroup)
		end
	end

	baseGroup.textFieldBg:addEventListener("touch", textFieldTouchListener)

	return baseGroup
end

return CoronaTextField
