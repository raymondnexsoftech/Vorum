---------------------------------------------------------------
-- NavigationControl.lua
--
-- Controller for navigation bar
---------------------------------------------------------------
-- *******************************************************************************
-- *******************************************************************************
-- ****                                                                       ****
-- ****    WARNING:                                                           ****
-- ****                                                                       ****
-- ****        1) DO NOT PURGE / REMOVE ANY SCENE WHEN USING THIS MODULE      ****
-- ****        2) BEWARE OF THE MEMORY USE SINCE CALLING THE SAME SCENE WILL  ****
-- ****               SHARE THE SAME LOCAL VARIABLE IN MODULE                 ****
-- ****               (not in scene.view)                                     ****
-- ****                                                                       ****
-- *******************************************************************************
-- *******************************************************************************
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

local fncArgUtility = require( "SystemUtility.FncArgUtility")
local storyboard = require ( "storyboard" )

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local displayW = display.contentWidth
local displayH = display.contentHeight
local effectList = {
						["iosNavigationPush"] =
						{
							["from"] =
							{
								xEnd = -displayW / 3,
								transition = easing.outQuad,
							},

							["to"] =
							{
								xStart = displayW,
								xEnd = 0,
								transition = easing.outQuad,
							},
							isToViewOnTop = true,
							transitionTime = 400,
						},
						["iosNavigationPop"] =
						{
							["from"] =
							{
								xEnd = displayW,
								transition = easing.outQuad,
							},

							["to"] =
							{
								xStart = -displayW / 3,
								xEnd = 0,
								transition = easing.outQuad,
							},
							transitionTime = 400,
						},
					}
---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
local sceneStack = {}
local sceneCount = {}
local touchMask

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
local navigationControl = {}

local function sceneViewTransition(fromView, toView, sceneOptions)
	fromView.isVisible = true
	fromView.alpha = 1
	local fx = effectList[sceneOptions.effect] or {}
	local fromOptions = {}
	local toOptions = {}
    if (fx.to) then
    	toView.x = fx.to.xStart or 0
    	toView.y = fx.to.yStart or 0
    	toView.alpha = fx.to.alphaStart or 1.0
    	toView.xScale = fx.to.xScaleStart or 1.0
    	toView.yScale = fx.to.yScaleStart or 1.0
    	toView.rotation = fx.to.rotationStart or 0
		toOptions.x = fx.to.xEnd
		toOptions.y = fx.to.yEnd
		toOptions.alpha = fx.to.alphaEnd
		toOptions.xScale = fx.to.xScaleEnd
		toOptions.yScale = fx.to.yScaleEnd
		toOptions.rotation =  fx.to.rotationEnd
		toOptions.time = sceneOptions.time or fx.transitionTime
		toOptions.time = toOptions.time or 500
		toOptions.transition = fx.to.transition
    end

    if (fx.from) then
    	fromView.x = fx.from.xStart or 0
    	fromView.y = fx.from.yStart or 0
    	fromView.alpha = fx.from.alphaStart or 1.0
    	fromView.xScale = fx.from.xScaleStart or 1.0
    	fromView.yScale = fx.from.yScaleStart or 1.0
    	fromView.rotation = fx.from.rotationStart or 0
		fromOptions.x = fx.from.xEnd
		fromOptions.y = fx.from.yEnd
		fromOptions.alpha = fx.from.alphaEnd
		fromOptions.xScale = fx.from.xScaleEnd
		fromOptions.yScale = fx.from.yScaleEnd
		fromOptions.rotation = fx.from.rotationEnd
		fromOptions.time = sceneOptions.time or fx.transitionTime
		fromOptions.time = fromOptions.time or 500
		fromOptions.transition = fx.from.transition
		fromOptions.onComplete = function(obj) obj.isVisible = false; display.remove(touchMask); touchMask = nil; end
	end

	local stage = storyboard.stage
	local fromViewIndex = table.indexOf(stage, fromView)
	local toViewIndex = table.indexOf(stage, toView)
	for i = 1, stage.numChildren do
		if (stage[i] == fromView) then
			fromViewIndex = i
		elseif (stage[i] == toView) then
			toViewIndex = i
		end
	end
	if ((fx.isToViewOnTop == true) and (fromViewIndex > toViewIndex)) then
		stage:insert(toViewIndex, fromView)
		stage:insert(fromViewIndex, toView)
	elseif (fromViewIndex < toViewIndex) then
		stage:insert(fromViewIndex, toView)
		stage:insert(toViewIndex, fromView)
	end

	touchMask = display.newRect(0, 0, display.contentWidth, display.contentHeight)
	touchMask.anchorX = 0
	touchMask.anchorY = 0
	touchMask.isVisible = false
	touchMask.isHitTestable = true
	touchMask:addEventListener("touch", function(event) return true; end)
	touchMask:toFront()
	transition.to(fromView, fromOptions)
	transition.to(toView, toOptions)
end

local pushSceneArgTable = {
							{name = "paramsForPopScene", type = "table", canSkip = true},
							{name = "newSceneName", type = "string"},
							{name = "sceneOptions", type = "table", canSkip = true},
							fncName = "pushScene"
						}
-- navigationControl.pushScene([paramsForPopScene, ]newSceneName, [sceneOptions])
function navigationControl.pushScene(...)
	local fncArg = fncArgUtility.parseArg(pushSceneArgTable, arg)
	local paramsForPopScene, newSceneName, sceneOptions = fncArg.paramsForPopScene, fncArg.newSceneName, fncArg.sceneOptions
	local currentSceneName = storyboard.getCurrentSceneName()
	if (sceneCount[currentSceneName]) then
		sceneCount[currentSceneName] = sceneCount[currentSceneName] + 1
	else
		sceneCount[currentSceneName] = 1
	end
	local sceneStackAppendData = {}
	sceneStackAppendData.name = currentSceneName
	sceneStackAppendData.params = paramsForPopScene
	sceneStackAppendData.sceneCount = sceneCount[currentSceneName]
	sceneStack[#sceneStack + 1] = sceneStackAppendData
	if (sceneOptions.effect == "default") then
		local platformName = system.getInfo("platformName")
		if (platformName == "iPhone OS") then
			sceneOptions.effect = "iosNavigationPush"
		else
			sceneOptions.effect = "slideLeft"
			sceneOptions.time = 400
		end
	end

	if (currentSceneName == newSceneName) then
		-- TODO: 
	else
		storyboard.purgeScene(newSceneName)
		if ((sceneOptions ~= nil) and (sceneOptions.effect ~= nil)) then
			if (storyboard.effectList[sceneOptions.effect]) then
				storyboard.gotoScene(newSceneName, sceneOptions)
			else
				local oldSceneName = currentSceneName
				local sceneOptionWithoutTransition = {
														params = sceneOptions.params
													}
				storyboard.gotoScene(newSceneName, sceneOptionWithoutTransition)
				if (effectList[sceneOptions.effect]) then
					local newScene = storyboard.getScene(newSceneName)
					local oldScene = storyboard.getScene(oldSceneName)
					timer.performWithDelay(1, function() sceneViewTransition(oldScene.view, newScene.view, sceneOptions); end)
				end
			end
		else
			local sceneOptionWithoutTransition = {
													params = sceneOptions.params
												}
			storyboard.gotoScene(newSceneName, sceneOptionWithoutTransition)
		end
	end
end

local popSceneArgTable = {
							{name = "transitionParams", type = "table", canSkip = true},
							{name = "numberOfSceneToPop", type = "number", canSkip = true, default = 1},
							fncName = "popScene"
						}
-- navigationControl.popScene([transitionParams, ][numberOfSceneToPop])
function navigationControl.popScene(...)
	local fncArg = fncArgUtility.parseArg(popSceneArgTable, arg)
	local transitionParams, numberOfSceneToPop = fncArg.transitionParams, fncArg.numberOfSceneToPop
	local sceneStackTotal = #sceneStack
	if (numberOfSceneToPop <= 0) then
		return
	elseif (numberOfSceneToPop > sceneStackTotal) then
		numberOfSceneToPop = sceneStackTotal
	end
	local popSceneData = sceneStack[sceneStackTotal - numberOfSceneToPop + 1]
	local currentSceneName = storyboard.getCurrentSceneName()
	if (transitionParams.effect == "default") then
		local platformName = system.getInfo("platformName")
		if (platformName == "iPhone OS") then
			transitionParams.effect = "iosNavigationPop"
		else
			transitionParams.effect = "slideRight"
			transitionParams.time = 400
		end
	end

	if (currentSceneName == popSceneData.name) then
		-- TODO: 
	else
		local popScene = storyboard.getScene(popSceneData.name)
		if (popScene.view) then
			if ((sceneCount[popSceneData.name] ~= nil) and (sceneCount[popSceneData.name] > popSceneData.sceneCount)) then
				storyboard.purgeScene(currentSceneName)
			end
		end
		if ((transitionParams ~= nil) and (transitionParams.effect ~= nil)) then
			transitionParams.params = popSceneData.params
			if (storyboard.effectList[transitionParams.effect]) then
				storyboard.gotoScene(popSceneData.name, transitionParams)
			else
				local oldSceneName = currentSceneName
				local sceneOptionWithoutTransition = {
														params = popSceneData.params
													}
				storyboard.gotoScene(popSceneData.name, sceneOptionWithoutTransition)
				if (effectList[transitionParams.effect]) then
					local newScene = storyboard.getScene(popSceneData.name)
					local oldScene = storyboard.getScene(oldSceneName)
					timer.performWithDelay(1, function() sceneViewTransition(oldScene.view, newScene.view, transitionParams); end)
				end
			end
		else
			local sceneOptionWithoutTransition = {
													params = popSceneData.params
												}
			storyboard.gotoScene(popSceneData.name, sceneOptionWithoutTransition)
		end
	end
	sceneCount[currentSceneName] = popSceneData.sceneCount - 1
	for i = sceneStackTotal - numberOfSceneToPop + 1, sceneStackTotal do
		sceneStack[i] = nil
	end
end

function navigationControl.getStackSize()
	return #sceneStack
end

function navigationControl.clearStack()
	sceneStack = {}
	sceneCount = {}
end

function navigationControl.getLastStackSceneName()
	return sceneStack[#sceneStack].name
end

return navigationControl
