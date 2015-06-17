---------------------------------------------------------------
-- CoronaTextField.lua
--
-- Text field for corona (V2.0)
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
local SCREEN_WIDTH_FOR_SETTING = 320
local IS_RESCALE_FOR_SCREEN = true

local INPUTFIELD_TO_TOP_SPACE = 100
local INPUTFIELD_TO_EDGE_SPACE = 100
local IPHONE_SIM_KEYBOARD_HEIGHT = 216
local IPHONE_SIM_CANDIDATE_HEIGHT = 36
local DISPLAY_TEXT_PADDING = 5
local CORNER_RADIUS = 5

-- DO NOT EDIT THE FOLLOWING CONSTANTS UNTIL YOU KNOW THE MEANING
if (IS_RESCALE_FOR_SCREEN) then
	local rescaleScale = display.contentWidth / SCREEN_WIDTH_FOR_SETTING
	INPUTFIELD_TO_TOP_SPACE = INPUTFIELD_TO_TOP_SPACE * rescaleScale
	INPUTFIELD_TO_EDGE_SPACE = INPUTFIELD_TO_EDGE_SPACE * rescaleScale
	IPHONE_SIM_KEYBOARD_HEIGHT = IPHONE_SIM_KEYBOARD_HEIGHT * rescaleScale
	IPHONE_SIM_CANDIDATE_HEIGHT = IPHONE_SIM_CANDIDATE_HEIGHT * rescaleScale
	DISPLAY_TEXT_PADDING = DISPLAY_TEXT_PADDING * rescaleScale
	CORNER_RADIUS = CORNER_RADIUS * rescaleScale
end
local DEVICE_PLATFORM = system.getInfo("platformName")
local DEVICE_ENVIRONMENT = system.getInfo("environment")
local IS_TEXTFIELD_NEED_PADDING = ((DEVICE_PLATFORM == "iPhone OS") or (DEVICE_ENVIRONMENT == "simulator"))
local DEFAULT_FONT = native.systemFont
local DEFAULT_SIZE = 16
local DEFAULT_TEXT_COLOR = {0, 0, 0, 1}
local TRANSITION_TIME = 200
local IPHONE_SIM_KEYBOARD_TRANS_TIME = 200

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
local activeTextFieldBaseGroup = nil

local textFieldParentResetTimer

local screenMask
local disableMaskTouch = true

local curParent
local curParentOrigX
local curParentOrigY
local curParentLastX
local curParentLastY

local simulatedKeyboard
local simulatedKeyboardTransition
local simulatedCandidate
local simulatedCandidateTransition
---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------
local screenMaskTouchListener
local textFieldUserInputListener
local destroyInputField
local textFieldEndEditing

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
local coronaTextField = {}

local function copyTable(origTable)
	local newTable
	if (type(origTable) == "table") then
		newTable = {}
		for k, v in pairs(origTable) do
			newTable[k] = copyTable(v)
		end
	else
		newTable = origTable
	end
	return newTable
end

local function stopSimulatedKeyboardTransition()
	if (simulatedKeyboardTransition) then
		transition.cancel(simulatedKeyboardTransition)
		simulatedKeyboardTransition = nil
	end
	if (simulatedCandidateTransition) then
		transition.cancel(simulatedCandidateTransition)
		simulatedCandidateTransition = nil
	end
end

local function showSimulatedKeyboard()
	if (DEVICE_ENVIRONMENT == "simulator") then
		stopSimulatedKeyboardTransition()
		if (simulatedKeyboard == nil) then
			simulatedKeyboard = display.newRect(display.contentWidth * 0.5, display.contentHeight + IPHONE_SIM_CANDIDATE_HEIGHT + (IPHONE_SIM_KEYBOARD_HEIGHT * 0.5
				), display.contentWidth, IPHONE_SIM_KEYBOARD_HEIGHT)
			simulatedKeyboard:setFillColor(0.5, 0.5, 0.5, 1)
		end
		if (simulatedCandidate == nil) then
			simulatedCandidate = display.newRect(display.contentWidth * 0.5, display.contentHeight + (IPHONE_SIM_CANDIDATE_HEIGHT * 0.5), display.contentWidth, IPHONE_SIM_CANDIDATE_HEIGHT)
			simulatedCandidate:setFillColor(0.5, 0.5, 0.5, 0.5)
		end
		simulatedKeyboardTransition = transition.to(simulatedKeyboard, {y = display.contentHeight - (IPHONE_SIM_KEYBOARD_HEIGHT * 0.5), time = IPHONE_SIM_KEYBOARD_TRANS_TIME})
		simulatedCandidateTransition = transition.to(simulatedCandidate, {y = display.contentHeight - IPHONE_SIM_KEYBOARD_HEIGHT - (IPHONE_SIM_CANDIDATE_HEIGHT * 0.5), time = IPHONE_SIM_KEYBOARD_TRANS_TIME})
	end
end

local function afterHideKeyboardListener(obj)
	display.remove(simulatedKeyboard)
	simulatedKeyboard = nil
end

local function afterHideCandidateListener(obj)
	display.remove(simulatedCandidate)
	simulatedCandidate = nil
end

local function hideSimulatedKeyboard()
	stopSimulatedKeyboardTransition()
	if (simulatedKeyboard) then
		simulatedKeyboardTransition = transition.to(simulatedKeyboard, {y = display.contentHeight + IPHONE_SIM_CANDIDATE_HEIGHT + (IPHONE_SIM_KEYBOARD_HEIGHT * 0.5), time = IPHONE_SIM_KEYBOARD_TRANS_TIME, onComplete = afterHideKeyboardListener})
	end
	if (simulatedCandidate) then
		simulatedCandidateTransition = transition.to(simulatedCandidate, {y = display.contentHeight + (IPHONE_SIM_CANDIDATE_HEIGHT * 0.5), time = IPHONE_SIM_KEYBOARD_TRANS_TIME, onComplete = afterHideCandidateListener})
	end
end

local function getTextViewWordHeight(baseGroup)
	local testText = "Ag"
	local textView = display.newText(testText, -1000, -1000, 0, 0, baseGroup._font, baseGroup._size)
	textView.size = baseGroup._size
	local wordHeight = textView.height
	display.remove(textView)
	textView = nil
	return wordHeight
end

local function checkParentType(parent)
	if (type(parent) ~= "table") then
		return nil
	elseif (parent._widgetType) then
		return parent._widgetType		-- "scrollView", "tableView"
	else
		return "displayGroup"			-- Assume not the others
	end
end

local function stopResetTimer()
	if (textFieldParentResetTimer) then
		timer.cancel(textFieldParentResetTimer)
		textFieldParentResetTimer = nil
	end
end

local function backButtonTouchListener(event)
	if ((event.phase == "down") and (event.keyName == "back")) then
		textFieldEndEditing()
		-- destroyInputField(activeTextFieldBaseGroup)
	end
end

local function createTouchMask()
	if (screenMask == nil) then
		screenMask = display.newRect(display.contentWidth * 0.5, display.contentHeight * 0.5, display.contentWidth, display.contentHeight)
		screenMask.alpha = 0
		screenMask.isHitTestable = true
		screenMask:addEventListener("touch", screenMaskTouchListener)
	 	activeTextFieldBaseGroup = baseGroup
	 	Runtime:addEventListener("key", backButtonTouchListener)
	end
end

local function updatePlaceHolderVisiblility(baseGroup)
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

local function setInputFieldProperty(baseGroup, property)
	local _property = "_" .. property
	if (baseGroup[_property] ~= nil) then
		baseGroup.inputField[property] = baseGroup[_property]
	end
end

local function parentReturnTransition(listener)
	if (curParent ~= nil) then
		if ((curParent.x ~= curParentOrigX) or (curParent.y ~= curParentOrigY)) then
			local curParentType = checkParentType(curParent)
			if (curParentType == "scrollView") then
				local scrollViewX, scrollViewY = curParent:getContentPosition()
				local scrollViewGroup = curParent:getView()
				if (scrollViewGroup._height - scrollViewGroup._scrollHeight > scrollViewY) then
					scrollViewY = scrollViewGroup._height - scrollViewGroup._scrollHeight
				end
				curParent:scrollToPosition{y = scrollViewY, time = TRANSITION_TIME, onComplete = listener}
			elseif (curParentType == "tableView") then
				-- TODO: table view reset
			elseif (curParentType == "displayGroup") then
				transition.to(curParent, {y = curParentOrigY, time = TRANSITION_TIME, transition = easing.outSine, onComplete = listener})
			end
		end
		curParentOrigX = 0
		curParentOrigY = 0
		curParent =  nil
	elseif (type(listener) == "function") then
		listener()
	end
end

local function createInputField(baseGroup)
	createTouchMask()
	disableMaskTouch = false
	if (baseGroup.inputField == nil) then
		baseGroup.displayText.isVisible = false
		local textFieldContentX, textFieldContentY = baseGroup.textFieldBg:localToContent( 0, 0 )
		local textFieldWidth, textFieldHeight = baseGroup.textFieldBg.width, baseGroup.textFieldBg.height
		if (IS_TEXTFIELD_NEED_PADDING) then
			textFieldWidth = textFieldWidth - DISPLAY_TEXT_PADDING * 2
			textFieldHeight = textFieldHeight - DISPLAY_TEXT_PADDING * 2
		end
		baseGroup.inputField = native.newTextField(textFieldContentX, textFieldContentY, textFieldWidth, textFieldHeight)
		baseGroup.inputField.hasBackground = false
		setInputFieldProperty(baseGroup, "align")
		setInputFieldProperty(baseGroup, "inputType")
		setInputFieldProperty(baseGroup, "isSecure")
		baseGroup.inputField.font = native.newFont(baseGroup._font)
		setInputFieldProperty(baseGroup, "size")
		setInputFieldProperty(baseGroup, "text")
		baseGroup.inputField.isFontSizeScaled = true
		if (baseGroup.fillColor ~= nil) then
			baseGroup.inputField:setTextColor(unpack(baseGroup.fillColor))
			-- baseGroup.inputField:setTextColor(baseGroup.fillColor[1] * 255, baseGroup.fillColor[2] * 255, baseGroup.fillColor[3] * 255, baseGroup.fillColor[4] * 255)
		end
		if (baseGroup.returnKey ~= nil) then
			baseGroup.inputField:setReturnKey(baseGroup.returnKey)
		end
		baseGroup.inputField.baseGroup = baseGroup
		baseGroup.inputField:addEventListener("userInput", textFieldUserInputListener)
		native.setKeyboardFocus(baseGroup.inputField)
		showSimulatedKeyboard()
	end
	activeTextFieldBaseGroup = baseGroup
	updatePlaceHolderVisiblility(baseGroup)
end

local function updateDisplayText(baseGroup)
	if (baseGroup) then
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
		-- baseGroup.displayText.anchorY = 0.5
		-- baseGroup.displayText.y = baseGroup.textFieldBg.height * 0.5
		-- if (baseGroup._align == "right") then
		-- 	baseGroup.displayText.anchorX = 1
		-- 	baseGroup.displayText.x = baseGroup.textFieldBg.width
		-- elseif (baseGroup.align == "center") then
		-- 	baseGroup.displayText.anchorX = 0.5
		-- 	baseGroup.displayText.x = baseGroup.textFieldBg.width * 0.5
		-- else
		-- 	baseGroup.displayText.anchorX = 0
		-- 	baseGroup.displayText.x = 0
		-- end
		updatePlaceHolderVisiblility(baseGroup)
	end
end

local function remakeDisplayText(baseGroup)
	if (baseGroup.displayText ~= nil) then
		display.remove(baseGroup.displayText)
		baseGroup.displayText = nil
	end
	local wordHeight = getTextViewWordHeight(baseGroup)
	local textOptions =
	{
	    text = baseGroup._text,
	    x = DISPLAY_TEXT_PADDING,
	    y = DISPLAY_TEXT_PADDING,
	    width = baseGroup.textFieldBg.width - (DISPLAY_TEXT_PADDING * 2),
	    height = wordHeight,
	    font = baseGroup._font,
	    fontSize = baseGroup._size,
	    align = baseGroup._align,
	}
	baseGroup.displayText = display.newText( textOptions )
	baseGroup.displayText.anchorX = 0
	baseGroup.displayText.anchorY = 0
	-- baseGroup.displayText = display.newText(baseGroup._text, 0, 0, baseGroup.textFieldBg.width, baseGroup._size + 3, baseGroup._font, baseGroup._size)

	baseGroup.displayText.baseGroup = baseGroup
	if (baseGroup.inputField ~= nil) then
		baseGroup.displayText.isVisible = false
	end
	if (baseGroup.fillColor ~= nil) then
		baseGroup.displayText:setFillColor(unpack(baseGroup.fillColor))
	end
	baseGroup:insert(baseGroup.displayText)
	updateDisplayText(baseGroup)
end

destroyInputField = function()
	if (activeTextFieldBaseGroup) then
		if (screenMask) then
		 	Runtime:removeEventListener("key", backButtonTouchListener)
			display.remove(screenMask)
			screenMask = nil
		end
		if (activeTextFieldBaseGroup.inputField ~= nil) then
			activeTextFieldBaseGroup.inputField.isVisible = false
			activeTextFieldBaseGroup._text = activeTextFieldBaseGroup.inputField.text
			activeTextFieldBaseGroup.inputField:removeEventListener("userInput", textFieldUserInputListener)
			display.remove(activeTextFieldBaseGroup.inputField)
			activeTextFieldBaseGroup.inputField = nil
			activeTextFieldBaseGroup.displayText.isVisible = true
			updateDisplayText(activeTextFieldBaseGroup)
		end
	 	activeTextFieldBaseGroup = nil
		native.setKeyboardFocus(nil)
		hideSimulatedKeyboard()
	end
end

local function textFieldLoseFocus()
	destroyInputField()
	parentReturnTransition()
end

textFieldEndEditing = function()
	if (activeTextFieldBaseGroup) then
		if (activeTextFieldBaseGroup.userInputListener ~= nil) then
			activeTextFieldBaseGroup._text = activeTextFieldBaseGroup.inputField.text
			local userInputEvent = {
									name = "userInput",
									target = activeTextFieldBaseGroup.inputField,
									phase = "ended"
									}
			activeTextFieldBaseGroup.userInputListener(userInputEvent)
		end
		textFieldLoseFocus()
	end
end

screenMaskTouchListener = function(event)
	if (event.phase == "began") then
		textFieldParentResetTimer = timer.performWithDelay(1, textFieldEndEditing, 1)
	end
end

textFieldUserInputListener = function(event)
	local isLoseFocus = false
	local baseGroup = event.target.baseGroup
	if (event.phase == "editing") then
	elseif (event.phase == "ended") then
		baseGroup._text = baseGroup.inputField.text
		-- isLoseFocus = true
	elseif (event.phase == "submitted") then
		baseGroup._text = baseGroup.inputField.text
		if ((baseGroup.jumpNextCallback == nil) or (baseGroup.jumpNextCallback(baseGroup))) then
			if (baseGroup.nextTextField) then
				baseGroup.nextTextField:enterEditMode()
			else
				isLoseFocus = true
			end
		end
		-- if (baseGroup.nextTextField) then
		-- 	if ((baseGroup.jumpNextCallback == nil) or (baseGroup.jumpNextCallback(baseGroup))) then
		-- 		-- destroyInputField(baseGroup)
		-- 		-- parentTransition(baseGroup.nextTextField, baseGroup.parentOffsetX, baseGroup.parentOffsetY)
		-- 		-- baseGroup.parentOffsetX = 0
		-- 		-- baseGroup.parentOffsetY = 0
		-- 		baseGroup.nextTextField:enterEditMode()
		-- 	end
		-- else
		-- 	isLoseFocus = true
		-- end
	end
	if (baseGroup.userInputListener ~= nil) then
		baseGroup.userInputListener(event)
	end
	if (isLoseFocus) then
		textFieldLoseFocus()
	end
end

local function parentTransitionCompleteListener(baseGroup)
	return function()
				createInputField(baseGroup)
			end
end

local function parentTransition(baseGroup)
	local isCreateTextFieldNow = false
	if (baseGroup.parentForShifting ~= nil) then
		if (curParent ~= baseGroup.parentForShifting) then
			curParent = baseGroup.parentForShifting
			curParentOrigX = curParent.x
			curParentOrigY = curParent.y
			curParentLastX = nil
			curParentLastY = nil
		end
		local textFieldScreenPosX, textFieldScreenPosY = baseGroup.textFieldBg:localToContent(0, 0)
		local parentOffsetX = 0
		local parentOffsetY = baseGroup.topPadding - textFieldScreenPosY + (baseGroup.textFieldBg.height * 0.5)
		-- if (parentOffsetY > 0) then
		-- 	parentOffsetY = 0
		-- end
		local parentType = checkParentType(baseGroup.parentForShifting)
		if (parentType == "scrollView") then
			local scrollViewX, scrollViewY = baseGroup.parentForShifting:getContentPosition()
			local scrollViewGroup = baseGroup.parentForShifting:getView()
			local newScrollX = scrollViewX
			local newScrollY = scrollViewY
			if (scrollViewGroup._isHorizontalScrollingDisabled ~= true) then
				if ((textFieldScreenPosX - (baseGroup.textFieldBg.width * 0.5) < 0)
					or (baseGroup.textFieldBg.width + baseGroup.edgePadding * 2 > display.contentWidth)) then
					parentOffsetX = baseGroup.edgePadding - textFieldScreenPosX + (baseGroup.textFieldBg.width * 0.5)
				elseif (textFieldScreenPosX + (baseGroup.textFieldBg.width * 0.5) > display.contentWidth) then
					parentOffsetX = display.contentWidth - baseGroup.edgePadding - textFieldScreenPosX - (baseGroup.textFieldBg.width * 0.5)
				end
				if (curParentLastX) then
					newScrollX = curParentLastX + parentOffsetX
				else
					newScrollX = scrollViewX + parentOffsetX
				end
				if (newScrollX > 0) then
					newScrollX = 0
					parentOffsetX = newScrollX - scrollViewX
				elseif (scrollViewGroup._width - scrollViewGroup._scrollWidth > newScrollX) then
					newScrollX = scrollViewGroup._width - scrollViewGroup._scrollWidth
					parentOffsetX = newScrollX - scrollViewX
				end
			end
			if (scrollViewGroup._isVerticalScrollingDisabled ~= true) then
				if (curParentLastY) then
					newScrollY = curParentLastY + parentOffsetY
				else
					newScrollY = scrollViewY + parentOffsetY
				end
				if (newScrollY > 0) then
					newScrollY = 0
					parentOffsetY = newScrollY - parentOffsetY
				end
			else
				parentOffsetY = 0
			end
			curParentLastX = newScrollX
			curParentLastY = newScrollY
			if ((parentOffsetX ~= 0) or (parentOffsetY ~= 0)) then
				local onScrollCompleteListener = parentTransitionCompleteListener(baseGroup)
				baseGroup.parentForShifting:scrollToPosition{x = newScrollX, y = newScrollY, time = TRANSITION_TIME, onComplete = onScrollCompleteListener}
			else
				isCreateTextFieldNow = true
			end
		elseif (parentType == "tableView") then
			-- TODO: table view moving
		elseif (parentType == "displayGroup") then
			if (parentOffsetY > 0) then
				parentOffsetY = 0
			end
			if (parentOffsetY ~= 0) then
				curParentLastX = 0
				curParentLastY = baseGroup.parentForShifting.y + parentOffsetY
				local onTransitionCompleteListener = parentTransitionCompleteListener(baseGroup)
				transition.to(baseGroup.parentForShifting, {y = baseGroup.parentForShifting.y + parentOffsetY, time = TRANSITION_TIME, transition = easing.outSine, onComplete = onTransitionCompleteListener})
			else
				isCreateTextFieldNow = true
			end
		else
			isCreateTextFieldNow = true
		end
	else
		isCreateTextFieldNow = true
	end
	createTouchMask()
	disableMaskTouch = true
	if (isCreateTextFieldNow) then
		createInputField(baseGroup)
	end
end

local function checkResetlastParent(baseGroup)
	if (activeTextFieldBaseGroup) then
		destroyInputField()
	end
	if (curParent ~= baseGroup.parentForShifting) then
		parentReturnTransition(function()
									parentTransition(baseGroup)
								end)
	else
		parentTransition(baseGroup)
	end
end

local function textFieldTouchListener(event)
	local baseGroup = event.target.parent
	if (baseGroup.touchListener ~= nil) then
		if (baseGroup.touchListener(event) ~= true) then
			if (event.target.isFocus) then
				event.target.isFocus = false
				display.getCurrentStage():setFocus(nil)
			end
			return false
		end
	end
	if (event.phase == "began") then
		stopResetTimer()
		event.target.isFocus = true
		display.getCurrentStage():setFocus(event.target)
	elseif (event.target.isFocus) then
		if (event.phase == "ended") then
			baseGroup:enterEditMode()
		end
		if ((event.phase == "ended") or (event.phase == "cancelled")) then
			event.target.isFocus = false
			display.getCurrentStage():setFocus(nil)
		end
	end
	return true
end

-- function coronaTextField.new(parent, centerX, centerY, width, height, [, isRoundedRect][, parentForShifting])
function coronaTextField.new(...)
	local baseGroup = display.newGroup()
	local argIdx = 1
	if (type(arg[argIdx]) == "table") then
		arg[argIdx]:insert(baseGroup)
		argIdx = argIdx + 1
	end

	baseGroup.x = arg[argIdx]
	baseGroup.y = arg[argIdx+1]
	local width = arg[argIdx+2]
	local height = arg[argIdx+3]
	argIdx = argIdx + 4
	local isRoundedRect
	if (type(arg[argIdx]) == "boolean") then
		isRoundedRect = arg[argIdx]
		argIdx = argIdx + 1
	end
	if (type(arg[argIdx]) == "table") then
		baseGroup.parentForShifting = arg[argIdx]
	end
	baseGroup.topPadding = INPUTFIELD_TO_TOP_SPACE
	baseGroup.edgePadding = INPUTFIELD_TO_EDGE_SPACE

	baseGroup._text = ""
	baseGroup._font = DEFAULT_FONT
	baseGroup._size = DEFAULT_SIZE

	if (isRoundedRect) then
		baseGroup.textFieldBg = display.newRoundedRect(width * 0.5, height * 0.5, width, height, CORNER_RADIUS)
	else
		baseGroup.textFieldBg = display.newRect(width * 0.5, height * 0.5, width, height)
	end
	-- baseGroup.textFieldBg.baseGroup = baseGroup
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

	function baseGroup:setFillColor(...)
		self.fillColor = arg

		if (self.inputField) then
			self.inputField:setTextColor(unpack(self.fillColor))
		end
		if (self.displayText) then
			self.displayText:setFillColor(unpack(self.fillColor))
		end
	end

	baseGroup.inputField = nil
	baseGroup:setFillColor(unpack(DEFAULT_TEXT_COLOR))

	function baseGroup:setReturnKey(key)
		self.returnKey = key

		if (self.inputField) then
			self.inputField:setReturnKey(self.returnKey)
		end
	end

	function baseGroup:setBackgroundColor(...)
		self.textFieldBg:setFillColor(unpack(arg))
	end

	function baseGroup:setFont(font, size)
		self._font = font
		self._size = size
		-- if (self.inputField) then
		-- 	destroyInputField(self)
		-- 	createInputField(self)
		-- end
		remakeDisplayText(self)
	end

	function baseGroup:setTouchListener(listener)
		self.touchListener = listener
	end

	function baseGroup:setUserInputListener(listener)
		self.userInputListener = listener
	end

	-- function baseGroup:enableInput()
	-- 	createInputField(self)
	-- end

	function baseGroup:enterEditMode()
		checkResetlastParent(baseGroup)
		-- parentTransition(baseGroup)
	end

	function baseGroup:inputEnd()
		textFieldEndEditing()
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
		if ((text == nil) or (text == "")) then
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
			updatePlaceHolderVisiblility(self)
		end
	end

	baseGroup.textFieldBg:addEventListener("touch", textFieldTouchListener)

	return baseGroup
end

local function coronaTextFieldSyetemEvent(event)
--	print( "System event name and type: " .. event.name, event.type )
	if (event.type == "applicationStart") then
	elseif (event.type == "applicationExit") then
	elseif (event.type == "applicationSuspend") then
		textFieldEndEditing()
	elseif (event.type == "applicationResume") then
	end
end
Runtime:addEventListener("system", coronaTextFieldSyetemEvent)

return coronaTextField
