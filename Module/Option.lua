local saveData = require("Module.SaveData")
local moduleGroup = {}
local tempSaving

local defaultVaule = {
	choices = {},
	choicesId = {},
	leftImagePath_isSelected = "",
	leftImagePath_isNotSelected = "",
	rightImagePath_isSelected = "",
	rightImagePath_isNotSelected = "",
	centerImagePath_isSelected = "", -- 3choice use
	centerImagePath_isNotSelected = "",-- 3choice use
	choicesListener = {},
	scrollView = nil,
	y = 0,
	font = "Helvetica",
	fontSize = 28.06,
	textColor = { 1, 1, 1},
	choiceOffset = 2,
	default = nil,
	defaultListener = nil,
	boolean_isAutoSave = false,
	autoSavePath = "",
	autoSaveParam = nil,
	autoSaveDir = system.TemporaryDirectory,
	autoSaveEncryption = nil,
	isNotEnable = false,
}

local function create(choiceData)

	local displayReturnGroup = display.newGroup()
	local selectedChoiceOrder = nil
	local totalChoiceNum = #choiceData.choices
	local chosenChoice = nil

	local displayObjArray = {}
	displayObjArray.selectedImagePath = {}
	displayObjArray.notSelectedImagePath = {}
	displayObjArray.selectedImagePath[1] = choiceData.leftImagePath_isSelected
	displayObjArray.notSelectedImagePath[1] = choiceData.leftImagePath_isNotSelected
	if(totalChoiceNum==2)then
		displayObjArray.selectedImagePath[2] = choiceData.rightImagePath_isSelected
		displayObjArray.notSelectedImagePath[2] = choiceData.rightImagePath_isNotSelected
	elseif(totalChoiceNum==3)then
		displayObjArray.selectedImagePath[2] = choiceData.centerImagePath_isSelected
		displayObjArray.notSelectedImagePath[2] = choiceData.centerImagePath_isNotSelected
		displayObjArray.selectedImagePath[3] = choiceData.rightImagePath_isSelected
		displayObjArray.notSelectedImagePath[3] = choiceData.rightImagePath_isNotSelected
	end
	
	displayObjArray.imageX = {}
	displayObjArray.imageY = {}
	displayObjArray.imageAnchorX = {}
	displayObjArray.imageAnchorY = {}
	displayObjArray.imageRotation = {}
	displayObjArray.textX = {}
	displayObjArray.textY = {}

	
	

	
	local function selectProcessFnc(selectedChoice)
		for i = 1, #choiceData.choices do
			if(selectedChoice == choiceData.choicesId[i])then
				displayObjArray.imageIsSelected[i].isVisible = true
				selectedChoiceOrder = i
			else
				displayObjArray.imageIsSelected[i].isVisible = false
			end
		end
	end
	local function touch_selectFnc(event)
		
		if ( event.phase == "moved" and choiceData.scrollView) then
			local dy = math.abs( ( event.y - event.yStart ) )
			if ( dy > 10 ) then
				choiceData.scrollView:takeFocus( event )
			end
		elseif(event.phase == "ended" or event.phase == "cancelled") then
			
			if(chosenChoice~=event.target.id)then
				chosenChoice = event.target.id
				selectProcessFnc(event.target.id)	
				autoSaveParam = event.target.id
				if(choiceData.boolean_isAutoSave)then
					saveData.save(choiceData.autoSavePath,choiceData.autoSaveDir,choiceData.autoSaveParam,choiceData.autoSaveEncryption)
				end
			end
		end
		
		event.choiceId = chosenChoice
		
		if(choiceData.choicesListener[selectedChoiceOrder])then
			event.choiceOrderNumber = selectedChoiceOrder
			choiceData.choicesListener[selectedChoiceOrder](event)
		end
		
		return true
	end

	function displayReturnGroup:setDefault(defaultId,newListener)
		
		if(type(defaultId)=="nil")then
			return nil
		end
		
		newListener = newListener or choiceData.defaultListener
		
		local boolean_defaultIdIsNotOrderNumber = true

		if(type(defaultId)=="number" and defaultId<=totalChoiceNum)then

			for i = 1 ,#choiceData.choicesId do
				if(defaultId==choiceData.choicesId[i])then
					boolean_defaultIdIsNotOrderNumber = true
					break
				else
					boolean_defaultIdIsNotOrderNumber = false
				end
			end
		end

		if(boolean_defaultIdIsNotOrderNumber)then
			chosenChoice = defaultId

		else
			chosenChoice = choiceData.choicesId[defaultId]
			
		end

		selectProcessFnc(chosenChoice)
		
		local event = {}
		event.id = chosenChoice
		event.orderNumber = selectedChoiceOrder
		event.phase = "default"
		if(newListener==true)then
			choiceData.choicesListener[selectedChoiceOrder](event)
		elseif(newListener)then
			newListener(event)
		end
		
		return selectedChoiceOrder
	end
	
	function displayReturnGroup:getChosenId()
		if(selectedChoiceOrder)then
			return choiceData.choicesId[selectedChoiceOrder]
		else
			return selectedChoiceOrder
		end
	end
	
	function displayReturnGroup:getChosenOrderNum()
		return selectedChoiceOrder
	end
	
	if(totalChoiceNum==2)then
		
		displayObjArray.imageX[1] = display.contentCenterX-choiceData.choiceOffset/2
		displayObjArray.imageY[1] = 0
		displayObjArray.imageAnchorX[1] = 1
		displayObjArray.imageAnchorY[1] = 0
		displayObjArray.imageRotation[1] = 0
	
		displayObjArray.imageX[2] = display.contentCenterX+choiceData.choiceOffset/2
		displayObjArray.imageY[2] = 0
		displayObjArray.imageAnchorX[2] = 0
		displayObjArray.imageAnchorY[2] = 0
		displayObjArray.imageRotation[2] = 0
		
	elseif(totalChoiceNum==3)then
		displayObjArray.imageX[1] = 60
		displayObjArray.imageY[1] = 0
		displayObjArray.imageAnchorX[1] = 0
		displayObjArray.imageAnchorY[1] = 0
		displayObjArray.imageRotation[1] = 0
	
		displayObjArray.imageX[2] = display.contentCenterX
		displayObjArray.imageY[2] = 0
		displayObjArray.imageAnchorX[2] = 0.5
		displayObjArray.imageAnchorY[2] = 0
		displayObjArray.imageRotation[2] = 0
		
		displayObjArray.imageX[3] = display.contentWidth-60
		displayObjArray.imageY[3] = 0
		displayObjArray.imageAnchorX[3] = 1
		displayObjArray.imageAnchorY[3] = 0
		displayObjArray.imageRotation[3] = 0
	end

	displayObjArray.imageIsNotSelected = {}
	displayObjArray.imageIsSelected = {}
	displayObjArray.text = {}
	
	for i = 1, totalChoiceNum do
		displayObjArray.imageIsNotSelected[i] =  display.newImage( displayObjArray.notSelectedImagePath[i] )
		displayObjArray.imageIsNotSelected[i].x = displayObjArray.imageX[i]
		displayObjArray.imageIsNotSelected[i].y = displayObjArray.imageY[i]
		displayObjArray.imageIsNotSelected[i].anchorX = displayObjArray.imageAnchorX[i]
		displayObjArray.imageIsNotSelected[i].anchorY = displayObjArray.imageAnchorY[i]
		displayObjArray.imageIsNotSelected[i].rotation = displayObjArray.imageRotation[i]
		displayObjArray.imageIsNotSelected[i].id = choiceData.choicesId[i]
		if(not choiceData.isNotEnable)then
			displayObjArray.imageIsNotSelected[i]:addEventListener("touch",touch_selectFnc)
		end
		displayObjArray.imageIsSelected[i] =  display.newImage( displayObjArray.selectedImagePath[i] )
		displayObjArray.imageIsSelected[i].x = displayObjArray.imageX[i]
		displayObjArray.imageIsSelected[i].y = displayObjArray.imageY[i]
		displayObjArray.imageIsSelected[i].anchorX = displayObjArray.imageAnchorX[i]
		displayObjArray.imageIsSelected[i].anchorY = displayObjArray.imageAnchorY[i]
		displayObjArray.imageIsSelected[i].rotation = displayObjArray.imageRotation[i]
		displayObjArray.imageIsSelected[i].isVisible = false
		displayObjArray.imageIsSelected[i].id = choiceData.choicesId[i]
		if(totalChoiceNum==2 and i==2)then
			tempSaving = displayObjArray.imageIsNotSelected[i].x+displayObjArray.imageIsNotSelected[i].width/2
		else
			tempSaving = displayObjArray.imageIsNotSelected[i].x-displayObjArray.imageIsNotSelected[i].width/2
		end
		if(totalChoiceNum==3 and i==1)then
			tempSaving = displayObjArray.imageIsNotSelected[i].x+displayObjArray.imageIsNotSelected[i].width/2
		elseif(totalChoiceNum==3 and i==2)then
			tempSaving = displayObjArray.imageIsNotSelected[i].x
		elseif(totalChoiceNum==3 and i==3)then
			tempSaving = displayObjArray.imageIsNotSelected[i].x-displayObjArray.imageIsNotSelected[i].width/2
		end

		displayObjArray.text[i] =
		{
			text = choiceData.choices[i], 
			x = tempSaving,
			y = displayObjArray.imageIsNotSelected[i].y+displayObjArray.imageIsNotSelected[i].height/2,
			width = 0,
			height = 0, 
			font = choiceData.font,
			fontSize= choiceData.fontSize
		}

		displayObjArray.text[i] = display.newText(displayObjArray.text[i]);
		displayObjArray.text[i]:setFillColor(unpack(choiceData.textColor))
		displayObjArray.text[i].anchorX=0.5
		displayObjArray.text[i].anchorY=0.5
		displayObjArray.text[i].id = choiceData.choicesId[i]
		
		
		displayReturnGroup:insert(displayObjArray.imageIsNotSelected[i])
		displayReturnGroup:insert(displayObjArray.imageIsSelected[i])
		displayReturnGroup:insert(displayObjArray.text[i])
	end
	
	displayObjArray.selectedImagePath = nil
	displayObjArray.notSelectedImagePath = nil
	displayObjArray.imageX = nil
	displayObjArray.imageY = nil
	displayObjArray.imageAnchorX = nil
	displayObjArray.imageAnchorY = nil
	displayObjArray.imageRotation = nil
	displayObjArray.textX = nil
	displayObjArray.textY = nil
	
	return displayReturnGroup
end
function moduleGroup.arrayFormatConvert(var,arrayTotalNum)
	if(type(var)=="table")then
		return var
	end
	local obj = var
	var = {}
	for i =1,arrayTotalNum do
		var[i] = obj
	end
	return var
end
function moduleGroup.new(newChoiceData)
	
	local returnGroup
	local choiceData = newChoiceData
	choiceData.y = choiceData.y or defaultVaule.y
	choiceData.font = choiceData.font or defaultVaule.font
	choiceData.fontSize = choiceData.fontSize or defaultVaule.fontSize
	choiceData.textColor = choiceData.textColor or defaultVaule.textColor
	choiceData.choiceOffset = choiceData.choiceOffset or defaultVaule.choiceOffset
	choiceData.choicesListener = choiceData.choicesListener or defaultVaule.choicesListener
	choiceData.choicesListener = moduleGroup.arrayFormatConvert(choiceData.choicesListener,#choiceData.choices)
	choiceData.isNotEnable = choiceData.isNotEnable or defaultVaule.isNotEnable
	
	returnGroup = create(choiceData)
	returnGroup.y = choiceData.y
	
	if(choiceData.default)then
		returnGroup:setDefault(choiceData.default,choiceData.defaultListener)
	end
	
	return returnGroup

end


return moduleGroup