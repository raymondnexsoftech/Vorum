local moduleGroup = {}

local defaultValue = {

	label = "button",
	labelAlign = "center",
	fontSize = 28,
	labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
	font = "Helvetica",
    shape = "roundedRect",
    width = 280,
    height = 80,
    cornerRadius = 2,
    fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
    strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
    strokeWidth = 4,
	onEvent = nothing,
	x = 0,
	y = 0,
	anchorX = 0.5,
	anchorY = 0.5,
	alpha = 1,
	isEnabled = true,
}

local function nothing(event)
	print("error",event.phase)
	return true
end
local function isWithinBounds( object, event )
	local bounds = object.contentBounds
    local x, y = event.x, event.y
	local isWithinBounds = true
		
	if "table" == type( bounds ) then
		if "number" == type( x ) and "number" == type( y ) then
			isWithinBounds = bounds.xMin <= x and bounds.xMax >= x and bounds.yMin <= y and bounds.yMax >= y
		end
	end
	print(bounds.xMin,bounds.xMax,bounds.yMin,bounds.yMax)
	return isWithinBounds
end
function moduleGroup.newButton(moduleData)
	
	moduleData.label = moduleData.label or defaultValue.label
	moduleData.labelAlign = moduleData.labelAlign or defaultValue.labelAlign
	moduleData.fontSize = moduleData.fontSize or defaultValue.fontSize
	moduleData.labelColor = moduleData.labelColor or defaultValue.labelColor
	moduleData.font = moduleData.font or defaultValue.font
    moduleData.shape = moduleData.shape or defaultValue.shape
    moduleData.width = moduleData.width or defaultValue.width
    moduleData.height = moduleData.height or defaultValue.height
    moduleData.cornerRadius = moduleData.cornerRadius or defaultValue.cornerRadius
    moduleData.fillColor = moduleData.fillColor or defaultValue.fillColor
    moduleData.strokeColor = moduleData.strokeColor or defaultValue.strokeColor
    moduleData.strokeWidth = moduleData.strokeWidth or defaultValue.strokeWidth
	moduleData.onEvent = moduleData.onEvent or defaultValue.onEvent
	moduleData.x = moduleData.x or defaultValue.x
	moduleData.y = moduleData.y or defaultValue.y
	moduleData.anchorX = moduleData.anchorX or defaultValue.anchorX
	moduleData.anchorY = moduleData.anchorY or defaultValue.anchorY
	moduleData.alpha = moduleData.alpha or defaultValue.alpha
	moduleData.isEnabled = moduleData.isEnabled or defaultValue.isEnabled
	
	local buttonGroup = display.newGroup()
	local buttonBg
	local buttonLabel

	local function onEventFnc(event)
		
		local isTriggerEvent = true
		
		if(event.phase=="began")then
			-- display.getCurrentStage():setFocus( event.target )
			-- transition.to( buttonLabel, { time = 50, alpha = 0.5 } )
			
		elseif(event.phase=="moved")then
			-- if(isWithinBounds( event.target, event ))then
				-- transition.to( buttonLabel, { time = 50, alpha = 0.5 } )
			-- else
				-- transition.to( buttonLabel, { time = 50, alpha = 1 } )
			-- end
		elseif(event.phase=="ended" or event.phase=="cancelled")then
			-- transition.to( buttonLabel, { time = 50, alpha = 1 } )
			-- display.getCurrentStage():setFocus(nil)
			-- if(not isWithinBounds( event.target, event ))then
				-- isTriggerEvent = false
			-- end
		end
		
		if(type(moduleData.onEvent)=="function" and isTriggerEvent)then
			local returnResult = moduleData.onEvent(event)
			return returnResult
		end
		
		return true
	end
	
	
	
	
	buttonBg = display.newRoundedRect(buttonGroup,0,0,moduleData.width,moduleData.height,moduleData.cornerRadius)
	buttonBg.anchorX = 0.5
	buttonBg.anchorY = 0.5
	buttonBg:setFillColor(unpack(moduleData.fillColor.default))
	buttonBg.strokeWidth = moduleData.strokeWidth
	buttonBg:setStrokeColor(unpack(moduleData.strokeColor.default))
	
	
	buttonLabel = {
		parent = buttonGroup,
		text = moduleData.label,     
		x = buttonBg.x,
		y = buttonBg.y,
		width = 0, 
		height = 0,
		font = moduleData.font,   
		fontSize = moduleData.fontSize,
		align = moduleData.labelAlign,
	}
	buttonLabel = display.newText(buttonLabel)
	buttonLabel.anchorX = 0.5
	buttonLabel.anchorY = 0.5
	buttonLabel.width = moduleData.width
	buttonLabel.height = moduleData.height
	buttonLabel:setFillColor(unpack(moduleData.labelColor.default))

	
	buttonGroup.x = moduleData.x
	buttonGroup.y = moduleData.y
	buttonGroup.anchorChildren = true
	buttonGroup.anchorX = moduleData.anchorX
	buttonGroup.anchorY = moduleData.anchorY
	buttonGroup.alpha = moduleData.alpha
	
	if(moduleData.isEnabled and type(moduleData.onEvent)=="function")then
		buttonGroup:addEventListener("touch",onEventFnc)
	end
	
	function buttonGroup:setLabel( newLabel )
		buttonLabel.text = newLabel
	end
	
	-- Function to get the button's label
	function buttonGroup:getLabel()
		return buttonLabel.text
	end
		-- Function to get the button's label
	function buttonGroup:setEnabled(boolean_turning)
	
		if(moduleData.isEnabled and not boolean_turning)then
			buttonGroup:removeEventListener("touch",onEventFnc)
			moduleData.isEnabled = boolean_turning
		elseif(not moduleData.isEnabled and boolean_turning and type(moduleData.onEvent)=="function")then
			buttonGroup:addEventListener("touch",onEventFnc)
			moduleData.isEnabled = boolean_turning
		end
		
	end
	
	return buttonGroup
end


return moduleGroup
