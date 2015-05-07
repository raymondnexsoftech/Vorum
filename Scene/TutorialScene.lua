---------------------------------------------------------------
-- TemplateScene.lua
--
-- Template for Scene
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
--local resDir = (...):match("(.-)[^%.]+$")

-- Local Constant Setting
local LOCAL_SETTINGS = {
						NAME = "TutorialScene",			-- Scene name to show in console
						RES_DIR = "",					-- Common resource directory for scene
						DOC_DIR = "",					-- Common document directory for scene
						}

---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------
local storyboard = require ( "storyboard" )
local widget = require ( "widget" )
require ( "DebugUtility.Debug" )
local localization = require("Localization.Localization")
local headerView = require( "ProjectObject.HeaderView" )
local headTabFnc = require( "ProjectObject.HeadTabFnc" )
local global = require( "GlobalVar.global" )
local saveData = require( "SaveData.SaveData" )
local json = require( "json")
---------------------------------------------------------------
-- Constants
---------------------------------------------------------------

local ANIMATION_NORNALTIME = 500
local A_IMAGEACTUALWIDTH = 289
local BIGA_IMAGEACTUALWIDTH = 366
local A_IMAGEWIDTHRATIO = BIGA_IMAGEACTUALWIDTH/A_IMAGEACTUALWIDTH
local SILVER_SCALERATIO = 1.2
local GRAY_SCALERATIO = 1.8	
local MAXANIMATIONMOVEMENT = display.contentWidth

local TUT2_TITLEY

if(display.pixelWidth/display.pixelHeight==0.75)then--4:3 aspect ratio
	TUT2_TITLEY=display.contentHeight
else
	TUT2_TITLEY=display.contentHeight-210
end
---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
--Create a storyboard scene for this module
local scene = storyboard.newScene()
local sceneGroup --scene.group
local tutorialOne
local tutorialTwo
local tut1_sheetDetails
local tut2_sheetDetails
local curTutorialPage = 1
--Common
local background
local text_skip
--tutorial
local image_title
local image_background
local image_A
local image_B
local image_C
local image_D
local image_bigA
local image_three
local image_two
local image_one
--tutorial2
local image_title2
local image_background2
local image_circle_gold
local image_circle_silver
local image_circle_brown
local image_circle_gray
local image_crown
local image_result
local image_bar

local startX
local startTime
local lastCurX
local animationPercent = 0
--tutorial 1 transition
local trans_tut1Title
local trans_tut1Sheet
local trans_tut2Title
local trans_tut2Sheet
local trans_tut1Num1
local trans_tut1Num2
local trans_tut1Num3
--tutorial 2 transition
local trans_tut2Gold
local trans_tut2Sliver
local trans_tut2Brown
local trans_tut2Gray
local trans_tut2Crown
local trans_tut2Result
local trans_tut2Bar
local trans_tut2Array = {}
-- parms fix the object position
local circleGoldX
local circleGoldY
local circleSilverX
local circleSilverY
local circleBrownX
local circleBrownY
local circleGrayX
local circleGrayY
local crownX
local resultX
local resultY

--moved
local curX
local dX
local dXPercent
--ended
local lastX
local lastTime
local diffX
local diffTime
local speed
local speedPer
--animation
local animationTime = ANIMATION_NORNALTIME

local isFinishTutorialData = {}
local header
local tabbar
-- animation function
local tempImageAX
local tempImageAY
local tempSheetX
---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
-- Function for back button
local function onBackButtonPressed()
end
local function fhinishTutorialFileGeneration()
	isFinishTutorialData = {}
	isFinishTutorialData.finishTutorial = true
	saveData.save(global.tutorialSavePath,isFinishTutorialData)
end
local function tutorialOneAnimation()
	tempImageAX = image_A.x
	tempImageAY = image_A.y
	tempSheetX = tut1_sheetDetails.x

	
	transition.scaleTo(image_A, { x=image_A.x+40,y=image_A.y-30,xScale=A_IMAGEWIDTHRATIO, yScale=A_IMAGEWIDTHRATIO, time=300,onComplete = function(event)
		
		
			image_A:scale(1/A_IMAGEWIDTHRATIO,1/A_IMAGEWIDTHRATIO)
			image_A.x = tempImageAX
			image_A.y = tempImageAY
			image_A.isVisible = false
			image_bigA.isVisible = true
		if(animationPercent==0)then
			trans_tut1Num3 = transition.to(image_three, { alpha = 1, time=300})
			trans_tut1Num2 = transition.to(image_two, { alpha = 1, time=600, delay=300})
			trans_tut1Num1 = transition.to(image_one, { alpha = 1, time=600, delay=900})
		end
		
	end})
	
end
local function tutorialTwoAnimation()
	
	
	trans_tut2Array[1]=transition.to(image_circle_gold, {delay=100,x=circleGoldX+20,y=circleGoldY-20,time=200,transition=easing.inOutCirc,alpha = 1,onComplete = function(event)
		transition.to(image_circle_gold, {x=circleGoldX,y=circleGoldY,transition=easing.inOutCirc,time=200})
	end})
	trans_tut2Array[2]=transition.scaleTo(image_circle_silver, {delay=300,time=200,xScale=SILVER_SCALERATIO,yScale=SILVER_SCALERATIO,transition=easing.inOutCirc,alpha = 1,onComplete = function(event)
		transition.scaleTo(image_circle_silver, {xScale=1,yScale=1,transition=easing.inOutCirc,time=200})
	end})
	trans_tut2Array[3]=transition.to(image_circle_brown, {delay=200,x=circleBrownX-20,y=circleBrownY+30,time=200,transition=easing.inOutCirc,alpha = 1,onComplete = function(event)
		transition.to(image_circle_brown, {x=circleBrownX,y=circleBrownY,transition=easing.inOutCirc,time=200})
	end})
	trans_tut2Array[4]=transition.scaleTo(image_circle_gray, {delay=400,x=circleGrayX-10,y=circleGrayY-10,time=200,xScale=GRAY_SCALERATIO,yScale=GRAY_SCALERATIO,transition=easing.inOutCirc,alpha = 1,onComplete = function(event)
		transition.scaleTo(image_circle_gray, {x=circleGrayX,y=circleGrayY,xScale=1,yScale=1,transition=easing.inOutCirc,time=200})
	end})
	trans_tut2Array[5]=transition.to(image_crown, {delay=500,x=crownX+10,y=crownY-30,time=200,transition=easing.inOutCirc,alpha = 1,onComplete = function(event)
		transition.to(image_crown, {x=crownX,y=crownY,transition=easing.inOutCirc,time=200})
	end})
	trans_tut2Array[6]=transition.scaleTo(image_result, {delay=600,x=resultX-40,y=resultY-40,time=300,xScale=GRAY_SCALERATIO,yScale=GRAY_SCALERATIO,transition=easing.inOutCirc,alpha = 1,onComplete = function(event)
		transition.scaleTo(image_result, {x=resultX,y=resultY,xScale=1,yScale=1,transition=easing.inOutCirc,time=300})
	end})
	trans_tut2Array[7]=transition.to(image_bar, {delay=200,alpha=1,transition=easing.inOutCirc,time=200})
end
local function tutorial1MovingOutAnimation(animationPecent,isFullDis)

	if(trans_tut1Num1)then
		transition.cancel(trans_tut1Num1)
	end
	if(trans_tut1Num2)then
		transition.cancel(trans_tut1Num2)
	end
	if(trans_tut1Num3)then
		transition.cancel(trans_tut1Num3)
	end

	image_one.alpha=0
	image_two.alpha=0
	image_three.alpha=0
	image_A.isVisible = true
	image_bigA.isVisible = false

	if(not isFullDis)then
		print("1 Move Out")
		image_title.x=-image_title.width*animationPecent
		tut1_sheetDetails.x=tut1_sheetDetails.width*animationPecent
		
	else
		animationTime=ANIMATION_NORNALTIME*animationPecent
		print("1 Animation Out")
		trans_tut1Title = transition.to(image_title,{x=-image_title.width,time=animationTime})
		trans_tut1Sheet = transition.to(tut1_sheetDetails,{x=tut1_sheetDetails.width,time=animationTime,onComplete=function(event)
			--reset
			-- image_one.alpha=0
			-- image_two.alpha=0
			-- image_three.alpha=0
			-- image_A.isVisible = true
			-- image_bigA.isVisible = false
			animationPercent=1
		end})
	end

	
end

local function tutorial2MovingOutAnimation(animationPecent,isFullDis)
	--cancel transition
	for i=1,#trans_tut2Array do
		if(trans_tut2Array[i])then
			transition.pause(trans_tut2Array[i])
		end
	end
	if(not isFullDis)then
		animationPecent=1-animationPecent
		print("2 Move Out")
		image_title2.x=image_title2.width*animationPecent
		tut2_sheetDetails.x=-tut2_sheetDetails.width*animationPecent
		tut2_sheetDetails.y=-tut2_sheetDetails.height*animationPecent
	else
		animationTime=ANIMATION_NORNALTIME*animationPecent
		print("2 Animation Out")
		trans_tut2Title = transition.to(image_title2,{x=image_title2.width,time=animationTime})
		trans_tut2Sheet = transition.to(tut2_sheetDetails,{x=-tut2_sheetDetails.width,y=-tut2_sheetDetails.height,time=animationTime,onComplete=function(event)
			--cancel transition
			-- for i=1,#trans_tut2Array do
				-- if(trans_tut2Array[i])then
					-- transition.cancel(trans_tut2Array[i])
				-- end
			-- end
			--reset
			image_circle_gold.alpha = 0	
			image_circle_silver.alpha = 0
			image_circle_brown.alpha = 0
			image_circle_gray.alpha = 0
			image_crown.alpha=0
			image_result.alpha=0
			image_bar.alpha=0
			
			animationPercent=0
			
		end})
	end
end

local function tutorial1MovingInAnimation(animationPecent,isFullDis)
	if(not isFullDis)then
		print("1 Move In")
		image_title.x=-image_title.width*animationPecent
		tut1_sheetDetails.x=tut1_sheetDetails.width*animationPecent
	else
		animationTime=ANIMATION_NORNALTIME*animationPecent
		print("1 Animation In")
		trans_tut1Title = transition.to(image_title,{x=0,time=animationTime})
		trans_tut1Sheet = transition.to(tut1_sheetDetails,{x=0,time=animationTime,onComplete=function(event)
			tutorialOneAnimation()
			animationPercent=0
		end})
	end

end

local function tutorial2MovingInAnimation(animationPecent,isFullDis)
	--resume transition
	for i=1,#trans_tut2Array do
		if(trans_tut2Array[i])then
			transition.resume(trans_tut2Array[i])
		end
	end
	if(not isFullDis)then
		animationPecent=1-animationPecent
		print("2 Move In")
		image_title2.x=image_title2.width*animationPecent
		tut2_sheetDetails.x=-tut2_sheetDetails.width*animationPecent
		tut2_sheetDetails.y=-tut2_sheetDetails.height*animationPecent
	else
		animationTime=ANIMATION_NORNALTIME*animationPecent
		print("2 Animation In")
		trans_tut2Title = transition.to(image_title2,{x=0,time=animationTime})
		trans_tut2Sheet = transition.to(tut2_sheetDetails,{x=0,y=0,time=animationTime,onComplete=function(event)
			animationPercent=1
			if(image_circle_gold.alpha==0 or image_circle_silver.alpha==0 or image_circle_brown.alpha==0 or image_circle_gray.alpha==0 or image_crown.alpha==0 or image_result.alpha==0)then
				tutorialTwoAnimation()
			end
		end})
	end
end


local function pauseTrans()	
	if(trans_tut1Num1)then
		transition.pause(trans_tut1Num1)
	end
	if(trans_tut1Num2)then
		transition.pause(trans_tut1Num2)
	end
	if(trans_tut1Num3)then
		transition.pause(trans_tut1Num3)
	end

	if(trans_tut1Title)then
		transition.pause(trans_tut1Title)
	end
	if(trans_tut1Sheet)then
		transition.pause(trans_tut1Sheet)
	end
	if(trans_tut2Title)then
		transition.pause(trans_tut2Title)
	end
	if(trans_tut2Sheet)then
		transition.pause(trans_tut2Sheet)
	end
end
local function resumeTrans()	
	if(trans_tut1Num1)then
		transition.resume(trans_tut1Num1)
	end
	if(trans_tut1Num2)then
		transition.resume(trans_tut1Num2)
	end
	if(trans_tut1Num3)then
		transition.resume(trans_tut1Num3)
	end

	if(trans_tut1Title)then
		transition.resume(trans_tut1Title)
	end
	if(trans_tut1Sheet)then
		transition.resume(trans_tut1Sheet)
	end
	if(trans_tut2Title)then
		transition.resume(trans_tut2Title)
	end
	if(trans_tut2Sheet)then
		transition.resume(trans_tut2Sheet)
	end
end

local function animationMovingTouchDectection(event)
	if(event.phase == "began")then
		pauseTrans()
		display.getCurrentStage():setFocus( event.target )
		startX = event.x
		lastCurX = startX
		startTime = event.time
	elseif(event.phase == "moved")then
		pauseTrans()
		curX = event.x
		dX  = math.abs(curX-lastCurX)
		dXPercent = dX/MAXANIMATIONMOVEMENT

		if(curX<lastCurX)then
		--go to page 2
			dXPercent=animationPercent+dXPercent

			if(dXPercent>1)then
				dXPercent=1
			end
			animationPercent=dXPercent
			tutorial2MovingInAnimation(animationPercent,false)
			tutorial1MovingOutAnimation(animationPercent,false)
			curTutorialPage = 2
			-- print("gotoTwo")
		
		--go to page 1
		elseif(curX>lastCurX)then
			
			dXPercent=animationPercent-dXPercent
	
			if(dXPercent<=0)then
				dXPercent=0
			end
			animationPercent=dXPercent
		
			print("moveLeft",animationPercent)
			tutorial1MovingInAnimation(animationPercent,false)
			tutorial2MovingOutAnimation(animationPercent,false)
			curTutorialPage = 1
			-- print("gotoOne")
		end
		lastCurX = curX
	elseif(event.phase == "ended" or event.phase == "cancelled")then
		
		lastX = event.x
		lastTime = event.time
		diffX  = math.abs(lastX-startX)
		diffTime = lastTime - startTime
		speed = diffX/diffTime 
		if(speed == 0 )then --not moving
			print("0 speed")
			resumeTrans()
			return true
		end
		
		pauseTrans()
		
		if(lastX<startX and speed>=1)then
		--go to page 2
			tutorial2MovingInAnimation(1,true)
			tutorial1MovingOutAnimation(1,true)
			curTutorialPage = 2
			-- print("gotoTwo")
		--go to page 1
		elseif(lastX>startX and speed>=1)then
			tutorial1MovingInAnimation(1,true)
			tutorial2MovingOutAnimation(1,true)
			curTutorialPage = 1
			-- print("gotoOne")
		elseif(animationPercent<0.5 or (animationPercent<=0.5 and curTutorialPage == 1))then
			speedPer = animationPercent+0.5
			tutorial1MovingInAnimation(speedPer,true)
			tutorial2MovingOutAnimation(speedPer,true)
			curTutorialPage = 1
		elseif(animationPercent>0.5 or (animationPercent>=0.5 and curTutorialPage == 2))then
			speedPer = animationPercent
			tutorial2MovingInAnimation(speedPer,true)	
			tutorial1MovingOutAnimation(speedPer,true)
			curTutorialPage = 2
		end
		display.getCurrentStage():setFocus( nil )
		text_skip:toFront()
	end
	return true
end
local function skipTutorial(event)
	if(event.phase=="ended" or event.phase=="cancelled")then
		transition.cancel()
		local isFinishTutorial = saveData.load(global.tutorialSavePath)
		if(isFinishTutorial)then
			storyboard.gotoScene( "Scene.SettingTabScene")
		else
			storyboard.gotoScene("Scene.LoginPageScene")
		end
	end
	return true
end
-- Create the scene
function scene:createScene( event )
	debugLog( "Creating " .. LOCAL_SETTINGS.NAME .. " Scene")
	sceneGroup = self.view
	display.setStatusBar( display.HiddenStatusBar )
	display.setDefault("background", 187/255,235/255,255/255 )
	tutorialOne = display.newGroup()
	tutorialOne.alpha=1
	tutorialTwo = display.newGroup()
	tutorialTwo.alpha=1
	tut1_sheetDetails = display.newGroup()
	tut2_sheetDetails = display.newGroup()
	
	-- Place the code below
	--common
	background = display.newRoundedRect( 0, 0, display.contentWidth, display.contentHeight, 0 )
	background:setFillColor( 187/255,235/255,255/255 )
	background.anchorX=0
	background.anchorY=0
	sceneGroup:insert(background)
	background:addEventListener("touch",animationMovingTouchDectection)

	text_skip =
	{
		text = localization.getLocalization("tutorial_skip"), 
		x = display.contentWidth-42,
		y = 36,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=35.42
	}

	text_skip = display.newText(text_skip);
	text_skip:setFillColor( 78/255, 184/255, 229/255 )
	text_skip.anchorX=1
	text_skip.anchorY=0
	text_skip:addEventListener("touch",skipTutorial)
	text_skip.width = 120
	text_skip.height = 100
	text_skip.isHitTestable = true
	
	sceneGroup:insert(text_skip)
	
	--tutorial one

	
	image_title = display.newImage( "Image/Tutorial/title.png", true )
	image_title.x=0
	image_title.y=144
	image_title.anchorX=0
	image_title.anchorY=0
	image_title.x=-image_title.width
	tutorialOne:insert(image_title)
	
	image_background = display.newImage( "Image/Tutorial/squareBackground.png", true )
	image_background.x=display.contentWidth	
	image_background.y=440
	image_background.anchorX=1
	image_background.anchorY=0
	tut1_sheetDetails:insert(image_background)
	
	image_B = display.newImage( "Image/Tutorial/b.png", true )
	image_B.x=display.contentWidth	
	image_B.y=image_background.y+210
	image_B.anchorX=1
	image_B.anchorY=0
	tut1_sheetDetails:insert(image_B)
	
	image_D = display.newImage( "Image/Tutorial/d.png", true )
	image_D.x=display.contentWidth	
	image_D.y=image_B.y+image_B.height-54
	image_D.anchorX=1
	image_D.anchorY=0
	tut1_sheetDetails:insert(image_D)
	
	image_C = display.newImage( "Image/Tutorial/c.png", true )
	image_C.x=image_D.x-image_D.width+42
	image_C.y=image_D.y-67
	image_C.anchorX=1
	image_C.anchorY=0
	tut1_sheetDetails:insert(image_C)
	
	image_A = display.newImage( "Image/Tutorial/a.png", true )
	image_A.x=image_B.x-image_B.width+43
	image_A.y=image_background.y+143
	image_A.anchorX=1
	image_A.anchorY=0
	tut1_sheetDetails:insert(image_A)
	
	image_bigA = display.newImage( "Image/Tutorial/bigA.png", true )
	image_bigA.x=image_B.x-image_B.width+90
	image_bigA.y=image_background.y+118
	image_bigA.anchorX=1
	image_bigA.anchorY=0
	image_bigA.isVisible = false
	tut1_sheetDetails:insert(image_bigA)
	
	image_one = display.newImage( "Image/Tutorial/1.png", true )
	image_one.x=0
	image_one.y=442
	image_one.anchorX=0
	image_one.anchorY=0
	image_one.alpha=0
	-- image_one.isVisible = false
	
	image_two = display.newImage( "Image/Tutorial/2.png", true )
	image_two.x=150
	image_two.y=542
	image_two.anchorX=0
	image_two.anchorY=0
	image_two.alpha=0
	-- image_two.isVisible=false
	
	image_three = display.newImage( "Image/Tutorial/3.png", true )
	image_three.x=272
	image_three.y=618
	image_three.anchorX=0
	image_three.anchorY=0
	image_three.alpha=0
	-- image_three.isVisible=false
	
	tutorialOne:insert(image_three)
	tutorialOne:insert(image_two)
	tutorialOne:insert(image_one)
	---tutorial two

	
	image_title2 = display.newImage( "Image/Tutorial/title2.png", true )
	image_title2.x=0
	image_title2.y=TUT2_TITLEY
	image_title2.anchorX=0
	image_title2.anchorY=1
	image_title2.x=image_title2.width
	tutorialTwo:insert(image_title2)
	
	image_background2 = display.newImage( "Image/Tutorial/rectBackground.png", true )
	image_background2.x=0	
	image_background2.y=0
	image_background2.anchorX=0
	image_background2.anchorY=0
	tut2_sheetDetails:insert(image_background2)
	
	image_circle_gold = display.newImage( "Image/Tutorial/circle_gold.png", true )
	image_circle_gold.x=50
	image_circle_gold.y=34
	image_circle_gold.anchorX=0
	image_circle_gold.anchorY=0
	image_circle_gold.alpha=0
	tut2_sheetDetails:insert(image_circle_gold)
	
	image_circle_silver = display.newImage( "Image/Tutorial/circle_silver.png", true )
	image_circle_silver.x=26
	image_circle_silver.y=146
	image_circle_silver.anchorX=0
	image_circle_silver.anchorY=0
	image_circle_silver.alpha=0
	tut2_sheetDetails:insert(image_circle_silver)
	
	image_circle_brown = display.newImage( "Image/Tutorial/circle_brown.png", true )
	image_circle_brown.x=82
	image_circle_brown.y=368
	image_circle_brown.anchorX=0
	image_circle_brown.anchorY=0
	image_circle_brown.alpha=0
	tut2_sheetDetails:insert(image_circle_brown)
	
	image_circle_gray = display.newImage( "Image/Tutorial/circle_gray.png", true )
	image_circle_gray.x=248
	image_circle_gray.y=394
	image_circle_gray.anchorX=0
	image_circle_gray.anchorY=0
	image_circle_gray.alpha=0
	tut2_sheetDetails:insert(image_circle_gray)
	
	image_crown = display.newImage( "Image/Tutorial/crown.png", true )
	image_crown.x=136
	image_crown.y=36
	image_crown.anchorX=0
	image_crown.anchorY=0
	image_crown.alpha=0
	tut2_sheetDetails:insert(image_crown)
	
	image_result = display.newImage( "Image/Tutorial/resultB.png", true )
	image_result.x=174
	image_result.y=220
	image_result.anchorX=0
	image_result.anchorY=0
	image_result.alpha=0
	tut2_sheetDetails:insert(image_result)
	
	image_bar = display.newImage( "Image/Tutorial/genderBar.png", true )
	image_bar.x=126
	image_bar.y=398
	image_bar.anchorX=0
	image_bar.anchorY=0
	image_bar.alpha=0
	tut2_sheetDetails:insert(image_bar)
	
	tut1_sheetDetails.x=tut1_sheetDetails.width
	tut2_sheetDetails.x=-tut2_sheetDetails.width
	tut2_sheetDetails.y=-tut2_sheetDetails.height
	tutorialOne:insert(tut1_sheetDetails)
	tut1_sheetDetails:toBack()
	tutorialTwo:insert(tut2_sheetDetails)
	tut2_sheetDetails:toBack()
	sceneGroup:insert(tutorialOne)
	sceneGroup:insert(tutorialTwo)
	tutorial1MovingInAnimation(1,true)--call the animation
	
	--set up Pos
	circleGoldX = image_circle_gold.x
	circleGoldY = image_circle_gold.y
	circleSilverX = image_circle_silver.x
	circleSilverY = image_circle_silver.y
	circleBrownX = image_circle_brown.x
	circleBrownY = image_circle_brown.y
	circleGrayX = image_circle_gray.x
	circleGrayY = image_circle_gray.y
	crownX = image_crown.x
	crownY = image_crown.y
	resultX = image_result.x
	resultY = image_result.y
	
	--header
	header = headTabFnc.getHeader()
	tabbar = headTabFnc.getTabbar()
	if (header) then
		header:toBack()
	end
	if (tabbar) then
		tabbar:toBack()
	end
	text_skip:toFront()
end

local function onKeyEvent( event )
	if event.phase == "up" and event.keyName == "back" then
		onBackButtonPressed()
	end
	return true
end
local function onSceneTransitionKeyEvent( event )
	if event.phase == "up" and event.keyName == "back" then
	end
	return true
end

function scene:didExitScene( event )
	debugLog( "Did Exit " .. LOCAL_SETTINGS.NAME .. " Scene")

	-- Place the code below
end


function scene:willEnterScene( event )
	debugLog( "Will Enter " .. LOCAL_SETTINGS.NAME .. " Scene")

	-- adding key event for scene transition
	Runtime:addEventListener( "key", onSceneTransitionKeyEvent )

	-- Place the code below
end

function scene:enterScene( event )
	debugLog( "Entering " .. LOCAL_SETTINGS.NAME .. " Scene")
	-- removing key event for scene transition
	Runtime:removeEventListener( "key", onSceneTransitionKeyEvent )
	-- adding check system key event
	Runtime:addEventListener( "key", onKeyEvent )

	-- remove previous scene's view
--	storyboard.purgeScene( lastScene )
	storyboard.purgeAll()

	-- Place the code below
	
end

-- Called when scene is about to move offscreen:
function scene:exitScene()
	debugLog( "Exiting " .. LOCAL_SETTINGS.NAME .. " Scene")

	-- removing check system key event
	Runtime:removeEventListener( "key", onKeyEvent )
	fhinishTutorialFileGeneration()
	-- Place the code below
	transition.cancel()
end

-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	debugLog( "Destroying " .. LOCAL_SETTINGS.NAME .. " Scene" )
	
	-- Place the code below

end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "willEnterScene" event is dispatched before scene transition begins
scene:addEventListener( "willEnterScene", scene )
-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "didExitScene" event is dispatched after scene has finished transitioning out
scene:addEventListener( "didExitScene", scene )
-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )


---------------------------------------------------------------------------------

return scene