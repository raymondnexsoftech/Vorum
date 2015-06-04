---------------------------------------------------------------
-- VorumTabScene.lua
--
-- Scene for Vorum Tab
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
--local resDir = (...):match("(.-)[^%.]+$")

-- Local Constant Setting
local LOCAL_SETTINGS = {
						NAME = "CatScreen",			-- Scene name to show in console
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
local projectObjectSetting = require( "Setting.ProjectObjectSetting" )
local returnGroup = {}
local headTabFnc = require( "ProjectObject.HeadTabFnc" )
local saveData = require( "SaveData.SaveData" )
local global = require( "GlobalVar.global" )
local json = require( "json" )
local stringUtility = require( "SystemUtility.StringUtility" )

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local iphone5 = 1136
local ANIMATION_TIME = 500
local HEADER_RATIO = 70/iphone5
local TAG_RATIO = 162/iphone5
local LATEST_RATIO = 188/iphone5
local LINE_RATIO = 118/iphone5
local LINE_SPACE_RATIO = 166/iphone5
local MOSTVOTED_RATIO = 158/iphone5
local MOSTVOTED_CHOICES_RATIO = 218/iphone5

local LINE_ONE_RATIO = 358/iphone5
local LINE_TWO_RATIO = 488/iphone5
local LINE_THREE_RATIO = 622/iphone5
local LINE_FOUR_RATIO = 754/iphone5
local LINE_FIVE_RATIO = 890/iphone5

local MOSTVOTED_CHOICES_FONTSIZE = 36
local LINE_CHOICES_FONTSIZE = 84
local LINEBOLD = 4
---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
local isDisplayNow = false
---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
-- Function for back button



--setting data
local perviousSetting -- oldData
local catData -- newData

local mostVotedSelection_background_moreWidth = 10
local mostVotedSelection_background_moreHeight = 5
local mostVotedSelection_background
local mostVotedChoice = {}
local mostId = {}
	  mostId.id_lastest = "Latest"
	  mostId.id_all = "voted_all"
	  mostId.id_week = "voted_week"
	  mostId.id_month = "voted_month"
local mostVotedSelection = mostId.id_lastest --set default
	  
local tagSelection_background_moreWidth = display.contentWidth
local tagSelection_background_moreHeight = 30
local tagSelection_background
local tagChoice = {}
local tagId = {}
	  tagId.id_appraisal = "Appraisal"
	  tagId.id_anonymous = "Anonymous"
	  tagId.id_30mins = "30mins"
	  tagId.id_general = "General"
	  tagId.id_all = "All"
local tagSelection = tagId.id_all --set default
--display transition
local display_transition_header
local display_transition_tag
local display_transition_mostVoted
local display_transition_latest
local display_transition_lineOne
local display_transition_lineTwo
local display_transition_lineThree
local display_transition_lineFour
local display_transition_lineFive



--groupObj
local group_cat
local headerGroup
local group_latest
local group_mostVoted
local group_line = {}
group_line[1] = {}
group_line[2] = {}
group_line[3] = {}
group_line[4] = {}
group_line[5] = {}
--obj
local text_latest
local text_mostVoted
local text_mostVoted_week
local text_mostVoted_all
local text_mostVoted_month

local text_30mins
local text_all
local text_anonymous
local text_appraisal
local text_general
--obj have function
local background
local touch_latest
local touch_mostVoted_week
local touch_mostVoted_all
local touch_mostVoted_month
local touch_appraisal
local touch_anonymous
local touch_30mins
local touch_general
local touch_all

--header obj
local headerTitle
local headerLeft
local headerRight

--key event
local onBackButtonPressed


local function onKeyEvent( event )
	if event.phase == "up" and event.keyName == "back" then
		onBackButtonPressed()
	end
	return true
end

local function mostVotedSelectionBackground(target)
	if (mostVotedSelection_background) then
		display.remove(mostVotedSelection_background)
		mostVotedSelection_background=nil
	end
	mostVotedSelection_background = display.newRect(target.x,target.y,target.width,target.height)
	mostVotedSelection_background:setFillColor( 123/255, 173/255, 224/255 )
	mostVotedSelection_background.alpha=0.9
	mostVotedSelection_background.anchorX = target.anchorX
	mostVotedSelection_background.anchorY = target.anchorY
	group_cat:insert(mostVotedSelection_background)
	mostVotedSelection_background:toBack();
	background:toBack();
	print(target.id)
end
local function selection_mostVoted(event)
	if (event.phase == "ended" or event.phase == "cancelled") then
		mostVotedSelection = event.target.id
		mostVotedSelectionBackground(event.target)
	end
end

local function tagSelectionBackground(target)
	if (tagSelection_background) then
		display.remove(tagSelection_background)
		tagSelection_background=nil
	end
	tagSelection_background = display.newRect(target.x,target.y,target.width,target.height)
	tagSelection_background:setFillColor( 123/255, 173/255, 224/255 )
	tagSelection_background.alpha=0.9
	tagSelection_background.anchorX = target.anchorX
	tagSelection_background.anchorY = target.anchorY
	group_cat:insert(tagSelection_background)
	tagSelection_background:toBack();
	background:toBack();
	print(target.id)
end

local function selection_tag(event)
	if (event.phase == "ended" or event.phase == "cancelled") then
		tagSelection = event.target.id
		tagSelectionBackground(event.target)
	end
end

local function background_touch(event)
	print("This is background")
	return true
end

local function cancelFnc(event)
		if(event.phase=="ended"or event.phase=="cancelled")then
			returnGroup.hide()
		end
		return true
	end
local function doneFnc(event)
	if(event.phase=="ended"or event.phase=="cancelled")then
		catData = {}
		catData.most = mostVotedSelection
		catData.tags = tagSelection
		
		saveData.save(global.catSettingDataPath,global.TEMPBASEDIR,catData)
		returnGroup.hide()
		local curSceneName = storyboard.getCurrentSceneName()
		local curScene = storyboard.getScene( curSceneName )
		curScene.refresh()
		
	end
	return true
end

function returnGroup.show()	
	if(isDisplayNow)then
		return
	end
	isDisplayNow = true
	if(mostVotedSelection_background)then
		display.remove(mostVotedSelection_background)
		mostVotedSelection_background=nil
	end
	if(tagSelection_background)then
		display.remove(tagSelection_background)
		tagSelection_background=nil
	end
	
	perviousSetting = saveData.load(global.catSettingDataPath,global.TEMPBASEDIR)
	if(perviousSetting)then
		mostVotedSelection = perviousSetting.most
		tagSelection = perviousSetting.tags
	end
	display_transition_tag = transition.to(text_tag,{time=ANIMATION_TIME,alpha=1})
	display_transition_mostVoted = transition.to(group_mostVoted,{time=ANIMATION_TIME,alpha=1,onComplete=function(event) 
		
		for i=1,#mostVotedChoice do
			if mostVotedSelection == mostVotedChoice[i].id then
				mostVotedSelectionBackground(mostVotedChoice[i])
			end
		end
		
	end})
	display_transition_header = transition.to(headerGroup,{time=ANIMATION_TIME,alpha=1})
	display_transition_latest = transition.to(group_latest,{time=ANIMATION_TIME,alpha=1})
	display_transition_lineOne = transition.to(group_line[1],{time=ANIMATION_TIME,x=0, transition=easing.inOutBack})
	display_transition_lineTwo = transition.to(group_line[2],{time=ANIMATION_TIME,x =0, transition=easing.inOutBack})
	display_transition_lineThree = transition.to(group_line[3],{time=ANIMATION_TIME,x =0, transition=easing.inOutBack})
	display_transition_lineFour = transition.to(group_line[4],{time=ANIMATION_TIME,x = 0, transition=easing.inOutBack})
	display_transition_lineFive = transition.to(group_line[5],{time=ANIMATION_TIME,x = 0, transition=easing.inOutBack,onComplete=function(event)
		for i=1,#tagChoice do
			if tagSelection == tagChoice[i].id then
				tagSelectionBackground(tagChoice[i])
			end
		end
		
		touch_latest:addEventListener( "touch", selection_mostVoted )
		touch_mostVoted_week:addEventListener( "touch", selection_mostVoted )
		touch_mostVoted_all:addEventListener( "touch", selection_mostVoted )
		touch_mostVoted_month:addEventListener( "touch", selection_mostVoted )
		touch_appraisal:addEventListener( "touch", selection_tag )
		touch_anonymous:addEventListener( "touch", selection_tag )
		touch_30mins:addEventListener( "touch", selection_tag )
		touch_general:addEventListener( "touch", selection_tag )
		touch_all:addEventListener( "touch", selection_tag )
		headerLeft:addEventListener("touch",cancelFnc)
		headerRight:addEventListener("touch",doneFnc)	
		Runtime:addEventListener( "key", onKeyEvent )
	end})
end

function returnGroup.hide()
	if(not isDisplayNow)then
		return
	end
	
	Runtime:removeEventListener( "key", onKeyEvent )
	transition.cancel (display_transition_header)
	transition.cancel (display_transition_tag)
	transition.cancel (display_transition_mostVoted)
	transition.cancel (display_transition_latest)
	transition.cancel (display_transition_lineOne)
	transition.cancel (display_transition_lineTwo)
	transition.cancel (display_transition_lineThree)
	transition.cancel (display_transition_lineFour)
	transition.cancel (display_transition_lineFive)
		
	touch_latest:removeEventListener( "touch", selection_mostVoted )
	touch_mostVoted_week:removeEventListener( "touch", selection_mostVoted )
	touch_mostVoted_all:removeEventListener( "touch", selection_mostVoted )
	touch_mostVoted_month:removeEventListener( "touch", selection_mostVoted )
	touch_appraisal:removeEventListener( "touch", selection_tag )
	touch_anonymous:removeEventListener( "touch", selection_tag )
	touch_30mins:removeEventListener( "touch", selection_tag )
	touch_general:removeEventListener( "touch", selection_tag )
	touch_all:removeEventListener( "touch", selection_tag )
	headerLeft:removeEventListener("touch",cancelFnc)
	headerRight:removeEventListener("touch",doneFnc)	
		
	if(mostVotedSelection_background)then
		display.remove(mostVotedSelection_background)
		mostVotedSelection_background=nil
	end
	if(tagSelection_background)then
		display.remove(tagSelection_background)
		tagSelection_background=nil
	end
	transition.to(headerGroup,{time=ANIMATION_TIME,alpha=0, transition=easing.inQuart })
	transition.to(group_mostVoted,{time=ANIMATION_TIME,alpha=0, transition=easing.inQuart })
	transition.to(group_latest,{time=ANIMATION_TIME,alpha=0, transition=easing.inQuart })
	transition.to(group_line[1],{time=ANIMATION_TIME,x=0-display.contentWidth, transition=easing.inQuart })
	transition.to(group_line[2],{time=ANIMATION_TIME,x =display.contentWidth, transition=easing.inQuart })
	transition.to(group_line[3],{time=ANIMATION_TIME,x =0-display.contentWidth, transition=easing.inQuart })
	transition.to(group_line[4],{time=ANIMATION_TIME,x = display.contentWidth, transition=easing.inQuart })
	transition.to(group_line[5],{time=ANIMATION_TIME,x = 0-display.contentWidth, transition=easing.inQuart ,onComplete = function(event) 
		if(group_cat)then
			display.remove(group_cat)
			group_cat=nil
		end
		isDisplayNow = false
	end})
end
onBackButtonPressed = function()
	returnGroup.hide()
end

function returnGroup.catScreenDisplay()

	if(isDisplayNow)then
		return
	end

	--temp
	local latest_line_top_x
	local latest_line_top_y
	local latest_line_top_width

	local latest_line_down_x
	local latest_line_down_y
	local latest_line_down_width

	local latest_line_x
	local latest_line_y
	local latest_line_y2

	local mostVoted_line_top_x
	local mostVoted_line_top_y
	local mostVoted_line_top_width
	local mostVoted_line_down_x
	local mostVoted_line_down_y
	local mostVoted_line_down_width
	local mostVoted_line_x
	local mostVoted_line_y
	local mostVoted_line_y2
	
	
	group_cat = display.newGroup()

	----------------------------
	background = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
	background:setFillColor( 0,0,0 )
	background.anchorX = 0
	background.anchorY = 0
	background.alpha = 0.9
	background:addEventListener("touch",background_touch)
	group_cat:insert(background)
	----------------------------
	
	---------------------------- latest part
	group_latest = display.newGroup()
	--temp
	latest_line_top_x = 0
	latest_line_top_y = display.contentHeight*LINE_RATIO
	latest_line_top_width = display.contentWidth/2
	
	latest_line_top = display.newLine(latest_line_top_x,latest_line_top_y,latest_line_top_x+latest_line_top_width,latest_line_top_y)
	latest_line_top:setStrokeColor( 243/255,243/255,243/255 )
	latest_line_top.strokeWidth = LINEBOLD
	latest_line_top.anchorX=0
	latest_line_top.anchorY=0
	group_latest:insert(latest_line_top)
	--temp
	latest_line_down_x = latest_line_top.x
	latest_line_down_y = display.contentHeight*LINE_RATIO+display.contentHeight*LINE_SPACE_RATIO
	latest_line_down_width = latest_line_top_width
	
	latest_line_down = display.newLine(latest_line_down_x,latest_line_down_y,latest_line_down_x+latest_line_down_width,latest_line_down_y)
	latest_line_down:setStrokeColor( 243/255,243/255,243/255 )
	latest_line_down.strokeWidth = LINEBOLD
	latest_line_down.anchorX=0
	latest_line_down.anchorY=0
	group_latest:insert(latest_line_down)
	
	--temp
	latest_line_x = latest_line_top_x+latest_line_top_width
	latest_line_y = latest_line_top.y
	latest_line_y2 = latest_line_down.y
	
	latest_line = display.newLine(latest_line_x,latest_line_y,latest_line_x,latest_line_y2)
	latest_line:setStrokeColor( 243/255,243/255,243/255 )
	latest_line.strokeWidth = LINEBOLD
	latest_line.anchorX=0
	latest_line.anchorY=0
	group_latest:insert(latest_line)
	
	text_latest =
	{
		text = localization.getLocalization("cat_latest"),
		x = display.contentCenterX/2,
		y = display.contentHeight*LATEST_RATIO,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=48,
		align="center"
	}
	text_latest = display.newText(text_latest);
	text_latest.id = mostId.id_lastest
	text_latest:setFillColor(1, 1, 1 )
	text_latest.anchorX=0.5
	text_latest.anchorY=0

	touch_latest = display.newRect( group_latest, text_latest.x, text_latest.y-mostVotedSelection_background_moreHeight, text_latest.width+mostVotedSelection_background_moreWidth*2, text_latest.height+mostVotedSelection_background_moreHeight*2 )
	touch_latest.id = text_latest.id
	touch_latest.anchorX=text_latest.anchorX
	touch_latest.anchorY=text_latest.anchorY
	touch_latest.alpha=0
	touch_latest.isHitTestable = true
	
	
	group_latest:insert(text_latest)
	group_latest.x = 0
	group_latest.anchorX=1
	group_latest.alpha = 0
	
	
	group_cat:insert(group_latest)
	------------------------------
	group_mostVoted = display.newGroup()

	--temp
	mostVoted_line_top_x = display.contentWidth
	mostVoted_line_top_y = display.contentHeight*LINE_RATIO
	mostVoted_line_top_width = display.contentWidth/2
	
	mostVoted_line_top = display.newLine(mostVoted_line_top_x,mostVoted_line_top_y,mostVoted_line_top_x-mostVoted_line_top_width,mostVoted_line_top_y)
	mostVoted_line_top:setStrokeColor( 243/255,243/255,243/255 )
	mostVoted_line_top.strokeWidth = LINEBOLD
	mostVoted_line_top.anchorX=0
	mostVoted_line_top.anchorY=0
	group_mostVoted:insert(mostVoted_line_top)
	--temp
	mostVoted_line_down_x = mostVoted_line_top.x
	mostVoted_line_down_y = display.contentHeight*LINE_RATIO+display.contentHeight*LINE_SPACE_RATIO
	mostVoted_line_down_width = mostVoted_line_top_width
	
	mostVoted_line_down = display.newLine(mostVoted_line_down_x,mostVoted_line_down_y,mostVoted_line_down_x-mostVoted_line_down_width,mostVoted_line_down_y)
	mostVoted_line_down:setStrokeColor( 243/255,243/255,243/255 )
	mostVoted_line_down.strokeWidth = LINEBOLD
	mostVoted_line_down.anchorX=0
	mostVoted_line_down.anchorY=0
	group_mostVoted:insert(mostVoted_line_down)

	
	
	--temp
	mostVoted_line_x = mostVoted_line_top_x-mostVoted_line_top_width
	mostVoted_line_y = mostVoted_line_top.y
	mostVoted_line_y2 = mostVoted_line_down.y
	
	mostVoted_line = display.newLine(mostVoted_line_x,mostVoted_line_y,mostVoted_line_x,mostVoted_line_y2)
	mostVoted_line:setStrokeColor( 243/255,243/255,243/255 )
	mostVoted_line.strokeWidth = LINEBOLD
	mostVoted_line.anchorX=0
	mostVoted_line.anchorY=0
	group_mostVoted:insert(mostVoted_line)
	
	text_mostVoted =
	{
		text = localization.getLocalization("cat_mostVoted"),
		x = display.contentWidth/2+display.contentWidth/4,
		y = display.contentHeight*MOSTVOTED_RATIO,
		font = "Helvetica",
		fontSize=48,
	}
	text_mostVoted = display.newText(text_mostVoted);
	text_mostVoted:setFillColor(1, 1, 1 )
	text_mostVoted.anchorX=0.5
	text_mostVoted.anchorY=0
	group_mostVoted:insert(text_mostVoted)
	
	text_mostVoted_week =
	{
		text = localization.getLocalization("cat_mostVoted_week"),
		x = display.contentWidth/2+display.contentWidth/4,
		y = display.contentHeight*MOSTVOTED_CHOICES_RATIO,
		font = "Helvetica",
		fontSize=MOSTVOTED_CHOICES_FONTSIZE,
		align="center"
	}
	
	text_mostVoted_week = display.newText(text_mostVoted_week);
	text_mostVoted_week.id = mostId.id_week
	text_mostVoted_week:setFillColor(1, 1, 1 )
	text_mostVoted_week.anchorX=0.5
	text_mostVoted_week.anchorY=0
	group_mostVoted:insert(text_mostVoted_week)
	
	touch_mostVoted_week = display.newRect( group_mostVoted, text_mostVoted_week.x, text_mostVoted_week.y-mostVotedSelection_background_moreHeight, text_mostVoted_week.width+mostVotedSelection_background_moreWidth*2, text_mostVoted_week.height+mostVotedSelection_background_moreHeight*2 )
	touch_mostVoted_week.id = text_mostVoted_week.id
	touch_mostVoted_week.anchorX=text_mostVoted_week.anchorX
	touch_mostVoted_week.anchorY=text_mostVoted_week.anchorY
	touch_mostVoted_week.alpha=0
	touch_mostVoted_week.isHitTestable = true
	
	
	
	text_mostVoted_all =
	{
		text = localization.getLocalization("cat_mostVoted_all"),
		x = text_mostVoted_week.x-text_mostVoted_week.anchorX*touch_mostVoted_week.width-26,
		y = display.contentHeight*MOSTVOTED_CHOICES_RATIO,
		font = "Helvetica",
		fontSize=MOSTVOTED_CHOICES_FONTSIZE,
		align="center"
	}
	text_mostVoted_all = display.newText(text_mostVoted_all);
	text_mostVoted_all.id = mostId.id_all
	text_mostVoted_all:setFillColor(1, 1, 1 )
	text_mostVoted_all.anchorX=1
	text_mostVoted_all.anchorY=0
	group_mostVoted:insert(text_mostVoted_all)
	
	touch_mostVoted_all = display.newRect( group_mostVoted, text_mostVoted_all.x+mostVotedSelection_background_moreWidth, text_mostVoted_all.y-mostVotedSelection_background_moreHeight, text_mostVoted_all.width+mostVotedSelection_background_moreWidth*2, text_mostVoted_all.height+mostVotedSelection_background_moreHeight*2 )
	touch_mostVoted_all.id = text_mostVoted_all.id
	touch_mostVoted_all.anchorX=text_mostVoted_all.anchorX
	touch_mostVoted_all.anchorY=text_mostVoted_all.anchorY
	touch_mostVoted_all.alpha=0
	touch_mostVoted_all.isHitTestable = true
	
	text_mostVoted_month =
	{
		text = localization.getLocalization("cat_mostVoted_month"),
		x = text_mostVoted_week.x+text_mostVoted_week.anchorX*touch_mostVoted_week.width+26,
		y = display.contentHeight*MOSTVOTED_CHOICES_RATIO,
		font = "Helvetica",
		fontSize=MOSTVOTED_CHOICES_FONTSIZE,
		align="center"
	}
	text_mostVoted_month = display.newText(text_mostVoted_month);
	text_mostVoted_month.id = mostId.id_month
	text_mostVoted_month:setFillColor(1, 1, 1 )
	text_mostVoted_month.anchorX=0
	text_mostVoted_month.anchorY=0
	group_mostVoted:insert(text_mostVoted_month)
	
	
	
	
	touch_mostVoted_month = display.newRect( group_mostVoted, text_mostVoted_month.x-mostVotedSelection_background_moreWidth, text_mostVoted_month.y-mostVotedSelection_background_moreHeight, text_mostVoted_month.width+mostVotedSelection_background_moreWidth*2, text_mostVoted_month.height+mostVotedSelection_background_moreHeight*2 )
	touch_mostVoted_month.id = text_mostVoted_month.id
	touch_mostVoted_month.anchorX=text_mostVoted_month.anchorX
	touch_mostVoted_month.anchorY=text_mostVoted_month.anchorY
	touch_mostVoted_month.alpha=0
	touch_mostVoted_month.isHitTestable = true
	

	group_mostVoted.x = 0
	group_mostVoted.anchorX=0
	group_mostVoted.alpha = 0
	
	group_cat:insert(group_mostVoted)
	------------------------------ line one
	group_line[1] = display.newGroup()
	
	text_appraisal =
	{
		text = localization.getLocalization("cat_appraisal"),
		y = display.contentHeight*LINE_ONE_RATIO,
		font = "Helvetica",
		fontSize=LINE_CHOICES_FONTSIZE,
		align="center"
	}
	text_appraisal = display.newText(text_appraisal);
	text_appraisal.id = tagId.id_appraisal
	text_appraisal:setFillColor(1, 1, 1 )
	text_appraisal.anchorX=0.5
	text_appraisal.anchorY=0
	text_appraisal.x = display.contentCenterX
	group_line[1]:insert(text_appraisal)
	
	touch_appraisal = display.newRect( group_line[1], text_appraisal.x, text_appraisal.y-tagSelection_background_moreHeight, text_appraisal.width+tagSelection_background_moreWidth*2, text_appraisal.height+tagSelection_background_moreHeight*2 )
	touch_appraisal.id = text_appraisal.id
	touch_appraisal.anchorX=text_appraisal.anchorX
	touch_appraisal.anchorY=text_appraisal.anchorY
	touch_appraisal.alpha=0
	touch_appraisal.isHitTestable = true
	
	group_line[1].x = 0-display.contentWidth
	
	
-----------------------------------	line two
	group_line[2] = display.newGroup()
	
	text_anonymous =
	{
		text = localization.getLocalization("cat_anonymous"),
		y = display.contentHeight*LINE_TWO_RATIO, 
		font = "Helvetica",
		fontSize=LINE_CHOICES_FONTSIZE,
		align="center"
	}
	text_anonymous = display.newText(text_anonymous);
	text_anonymous.id = tagId.id_anonymous
	text_anonymous:setFillColor(1, 1, 1 )
	text_anonymous.anchorX=0.5
	text_anonymous.anchorY=0
	text_anonymous.x = display.contentCenterX
	group_line[2]:insert(text_anonymous)
	
	touch_anonymous = display.newRect( group_line[2], text_anonymous.x, text_anonymous.y-tagSelection_background_moreHeight, text_anonymous.width+tagSelection_background_moreWidth*2, text_anonymous.height+tagSelection_background_moreHeight*2 )
	touch_anonymous.id = text_anonymous.id
	touch_anonymous.anchorX=text_anonymous.anchorX
	touch_anonymous.anchorY=text_anonymous.anchorY
	touch_anonymous.alpha=0
	touch_anonymous.isHitTestable = true
	
	group_line[2].x=display.contentWidth+group_line[2].width/2

--------------------------------------	line three
	group_line[3] = display.newGroup()
	
	text_30mins =
	{
		text = localization.getLocalization("cat_30mins"),
		y = display.contentHeight*LINE_THREE_RATIO,
		font = "Helvetica",
		fontSize=LINE_CHOICES_FONTSIZE,
		align="center"
	}
	text_30mins = display.newText(text_30mins);
	text_30mins.id = tagId.id_30mins
	text_30mins:setFillColor(1, 1, 1 )
	text_30mins.anchorX=0.5
	text_30mins.anchorY=0
	text_30mins.x = display.contentCenterX
	group_line[3]:insert(text_30mins)
	
	touch_30mins = display.newRect( group_line[3], text_30mins.x, text_30mins.y-tagSelection_background_moreHeight, text_30mins.width+tagSelection_background_moreWidth*2, text_30mins.height+tagSelection_background_moreHeight*2 )
	touch_30mins.id = text_30mins.id
	touch_30mins.anchorX=text_30mins.anchorX
	touch_30mins.anchorY=text_30mins.anchorY
	touch_30mins.alpha=0
	touch_30mins.isHitTestable = true
	
	group_line[3].x=0-display.contentWidth
	

	------------------------ line four
	group_line[4] = display.newGroup()
	
	text_general =
	{
		text = localization.getLocalization("cat_general"),
		y = display.contentHeight*LINE_FOUR_RATIO,
		font = "Helvetica",
		fontSize=LINE_CHOICES_FONTSIZE,
		align="center"
	}
	text_general = display.newText(text_general);
	text_general.id = tagId.id_general
	text_general:setFillColor(1, 1, 1 )
	text_general.anchorX=0.5
	text_general.anchorY=0
	text_general.x = display.contentCenterX
	group_line[4]:insert(text_general)
	
	touch_general = display.newRect( group_line[4], text_general.x, text_general.y-tagSelection_background_moreHeight, text_general.width+tagSelection_background_moreWidth*2, text_general.height+tagSelection_background_moreHeight*2 )
	touch_general.id = text_general.id
	touch_general.anchorX=text_general.anchorX
	touch_general.anchorY=text_general.anchorY
	touch_general.alpha=0
	touch_general.isHitTestable = true
	group_line[4].x=display.contentWidth+group_line[4].width/2
	
	------------------------ line five
	group_line[5] = display.newGroup()
	
	text_all =
	{
		text = localization.getLocalization("cat_all"),
		y = display.contentHeight*LINE_FIVE_RATIO,
		font = "Helvetica",
		fontSize=LINE_CHOICES_FONTSIZE,
		align="center"
	}
	text_all = display.newText(text_all);
	text_all.id = tagId.id_all
	text_all:setFillColor(1, 1, 1 )
	text_all.anchorX=0.5
	text_all.anchorY=0
	text_all.x = display.contentCenterX
	group_line[5]:insert(text_all)
	
	touch_all = display.newRect( group_line[5], text_all.x, text_all.y-tagSelection_background_moreHeight, text_all.width+tagSelection_background_moreWidth*2, text_all.height+tagSelection_background_moreHeight*2 )
	touch_all.id = text_all.id
	touch_all.anchorX=text_all.anchorX
	touch_all.anchorY=text_all.anchorY
	touch_all.alpha=0
	touch_all.isHitTestable = true
	group_line[5].x=0-display.contentWidth
	
	group_cat:insert(group_line[1])--lineOne
	group_cat:insert(group_line[2])
	group_cat:insert(group_line[3])
	group_cat:insert(group_line[4])
	group_cat:insert(group_line[5])
	
	--beginning setup begin

	mostVotedChoice[1] = touch_latest
	mostVotedChoice[2] = touch_mostVoted_all
	mostVotedChoice[3] = touch_mostVoted_week
	mostVotedChoice[4] = touch_mostVoted_month

	tagChoice[1] = touch_all
	tagChoice[2] = touch_anonymous
	tagChoice[3] = touch_appraisal
	tagChoice[4] = touch_30mins
	tagChoice[5] = touch_general

	-- header 

	
	headerGroup = display.newGroup()
	headerTitle =
	{
		text = localization.getLocalization("cat_headerTitle"), 
		font = "Helvetica",
		fontSize=40,
		x = display.contentCenterX,
		y = display.contentHeight*HEADER_RATIO,
		align = "center",
		width = 0,
		height = 0,
		
	}
	headerTitle = display.newText( headerTitle )
	headerTitle:setFillColor( 255/255, 255/255, 255/255)
	headerTitle.anchorX = 0.5
	headerTitle.anchorY = 0.5
	headerGroup:insert(headerTitle)
	
	headerLeft =
	{
		text = localization.getLocalization("cat_headerLeftButton"), 
		font = "Helvetica",
		fontSize=35.42,
		x = 80,
		y = display.contentHeight*HEADER_RATIO,
		align = "left",
		width = 0,
		height = 0,
		
	}
	headerLeft = display.newText( headerLeft )
	headerLeft:setFillColor( 255/255, 255/255, 255/255)
	headerLeft.anchorX = 0.5
	headerLeft.anchorY = 0.5
	headerGroup:insert(headerLeft)
	headerLeft.width = 150
	headerLeft.height = 80
	
	
	headerRight =
	{
		text = localization.getLocalization("cat_headerRightButton"), 
		font = "Helvetica",
		fontSize=35.42,
		x = display.contentWidth-80,
		y = display.contentHeight*HEADER_RATIO,
		align = "right",
		width = 0,
		height = 0,
	}
	headerRight = display.newText( headerRight )
	headerRight:setFillColor( 255/255, 255/255, 255/255)
	headerRight.anchorX = 0.5
	headerRight.anchorY = 0.5
	headerGroup:insert(headerRight)
	headerRight.width = 150
	headerRight.height = 80
	
	group_cat:insert(headerGroup)
	
	returnGroup.show()

	return group_cat
end
return returnGroup

