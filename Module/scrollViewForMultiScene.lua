local widget = require("widget")

local moduleGroup = {}
local scrollView
local scrollViewData
local sceneData
local goOption
local totalSceneNum
local curSceneNum = 1
local boolean_goTrans = false


local sceneData_defaultVaule = {
	scene = {},
	sceneKeyEventFnc = {}, -- Android back button function
	defaultScene = 1,
	transTime = 400,
	sceneStartListener = {},
	sceneEndListener = {},
}
local goOption_defaultVaule = {
	scene = "next", -- "next", "previous", scene number
	transTime = 400,
}
function moduleGroup.removeKeyEvent()
	if(sceneData.sceneKeyEventFnc)then
		if(type(sceneData.sceneKeyEventFnc[curSceneNum])=="function")then
			-- print("remove key event",curSceneNum)
			Runtime:removeEventListener( "key",  sceneData.sceneKeyEventFnc[curSceneNum] )
		end
	end	
end
function moduleGroup.setKeyEvent()
	if(sceneData.sceneKeyEventFnc)then
		if(type(sceneData.sceneKeyEventFnc[curSceneNum])=="function")then
			-- print("add key event",curSceneNum)
			Runtime:addEventListener( "key", sceneData.sceneKeyEventFnc[curSceneNum] )
		end
	end
end

function moduleGroup.runSceneStartListener()
	if(sceneData.sceneStartListener)then
		if(type(sceneData.sceneStartListener[curSceneNum])=="function")then
			sceneData.sceneStartListener[curSceneNum]()
		end
	end
end

function moduleGroup.runSceneEndListener()
	if(sceneData.sceneEndListener)then
		if(type(sceneData.sceneEndListener[curSceneNum])=="function")then
			sceneData.sceneEndListener[curSceneNum]()
		end
	end
end

function moduleGroup.go(newGoOption)
	if(boolean_goTrans)then
		return curSceneNum
	end
	goOption = newGoOption
	goOption.transTime = goOption.transTime or sceneData.transTime
	goOption.transTime = goOption.transTime or goOption_defaultVaule.transTime
	goOption.transTime = goOption.transTime or sceneData_defaultVaule.transTime
	
	
	
	if(string.lower(goOption.scene)=="next")then
		if(curSceneNum<totalSceneNum)then
			moduleGroup.removeKeyEvent()
			moduleGroup.runSceneEndListener()
			curSceneNum = curSceneNum+1
			boolean_goTrans = true
		else
			-- print("It is last scene.")
		end
	elseif(string.lower(goOption.scene)=="previous")then
		if(curSceneNum>0)then
			moduleGroup.removeKeyEvent()
			moduleGroup.runSceneEndListener()
			curSceneNum = curSceneNum-1
			boolean_goTrans = true
		else
			-- print("It is first scene.")
		end
	elseif(type(goOption.scene)=="number")then
		if(goOption.scene>0 and goOption.scene<totalSceneNum and goOption.scene~=curSceneNum)then
			moduleGroup.removeKeyEvent()
			moduleGroup.runSceneEndListener()
			boolean_goTrans = true
			curSceneNum = goOption.scene
		end
	end
	if(boolean_goTrans)then

		scrollView:scrollToPosition
		{
			x = -sceneData.scene[curSceneNum].x,
			time = goOption.transTime,
			onComplete = function(event) 
				boolean_goTrans = false 
				moduleGroup.setKeyEvent() 
				moduleGroup.runSceneStartListener()
			end,
		}
	end
	
	return curSceneNum
end

function moduleGroup.new(newScrollViewData,newSceneData)
	scrollViewData = newScrollViewData
	sceneData = newSceneData
	sceneData.defaultScene = sceneData.defaultScene or sceneData_defaultVaule.defaultScene
	sceneData.transTime = sceneData.transTime or sceneData_defaultVaule.transTime

	-- curSceneNum = sceneData.defaultScene
	
	totalSceneNum = #sceneData.scene
	scrollViewData.width = display.contentWidth * totalSceneNum
	scrollViewData.horizontalScrollDisabled = true
	scrollViewData.verticalScrollDisabled = true
	scrollView = widget.newScrollView{scrollViewData}
	scrollView:setIsLocked( true, "horizontal" )
	if(totalSceneNum==0)then
		return
	end
	-- set up every scene position
	for i = 1, totalSceneNum do
		sceneData.scene[i].anchorChildren = false
		sceneData.scene[i].x = display.contentWidth * (i-1)
		scrollView:insert(sceneData.scene[i])
	end
	--set default scene
	if(type(sceneData.defaultScene)=="number" and sceneData.defaultScene~=1 )then
		curSceneNum = sceneData.defaultScene
		scrollView:scrollToPosition
		{
			x = -sceneData.scene[curSceneNum].x,
			time = 0,
			onComplete = function(event) 
				moduleGroup.setKeyEvent()
				moduleGroup.runSceneStartListener()
			end,
		}
	else
		curSceneNum = 1
		moduleGroup.setKeyEvent()
		moduleGroup.runSceneStartListener()
	end
	
	
	return scrollView
end
function moduleGroup.getCurSceneNum()
	return curSceneNum
end

return moduleGroup