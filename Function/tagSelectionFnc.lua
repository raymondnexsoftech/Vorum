---------------------------------------------------------------
-- VorumTabScene.lua
--
-- Scene for Vorum Tab
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
--local resDir = (...):match("(.-)[^%.]+$")
---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------
local storyboard = require ( "storyboard" )
local widget = require ( "widget" )
require ( "DebugUtility.Debug" )
local localization = require("Localization.Localization")
local projectObjectSetting = require( "Setting.ProjectObjectSetting" )
local saveData = require( "SaveData.SaveData" )
local global = require( "GlobalVar.global" )
local json = require( "json" )
local stringUtility = require("SystemUtility.StringUtility")

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local iphone5 = 1136
local ANIMATION_TIME = 250

local LINE_ONE_RATIO = 308/iphone5
local LINE_TWO_RATIO = 438/iphone5
local LINE_THREE_RATIO = 572/iphone5
local LINE_FOUR_RATIO = 704/iphone5

local LINE_CHOICES_FONTSIZE = 84
local LINEBOLD = 4
---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
local returnGroup = {}
---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
-- Function for back button
local boolean_isDisplay = false

local group_cat
local group_lineOne
local group_lineTwo
local group_lineThree
local group_lineFour
local group_lineFive

local background

local text_30mins
local text_anonymous
local text_appraisal
local text_general
	  
local tagSelection_background_moreWidth = display.contentWidth
local tagSelection_background_moreHeight = 30
local tagSelection_background
local tagChoice = {}
local tagId = {}
	  tagId.id_appraisal = "Appraisal"
	  tagId.id_anonymous = "Anonymous"
	  tagId.id_30mins = "30mins"
	  tagId.id_general = "General"
local tagSelection = tagId.id_general --set default

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------

local function background_touch(event)
	print("This is background")
	return true
end
function returnGroup.loadData(callBackFnc)
	local tagsData = saveData.load(global.post3TagsDataPath,global.TEMPBASEDIR)
	
	if(tagsData)then
		callBackFnc(tagsData.tags)
	else
		callBackFnc(tagSelection)
	end
end
function returnGroup.tagSelection(callBackFnc)
	local function selection_tag(event)
		if (event.phase == "ended" or event.phase == "cancelled") then
			-- tagSelection = event.target.id
			transition.to(group_cat,{time=ANIMATION_TIME,alpha=0,onComplete = function(event)
				if(group_cat)then
					display.remove(group_cat)
					group_cat=nil
				end
				boolean_display = false
			end})
			callBackFnc(event.target.id)
		end
	end
	if(boolean_display)then
	else
		boolean_display = true
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
		------------------------------ line one
		group_lineOne = display.newGroup()
		
		local text_appraisal_property =
		{
			text = localization.getLocalization("cat_appraisal"),
			y = display.contentHeight*LINE_ONE_RATIO,
			font = "Helvetica",
			fontSize=LINE_CHOICES_FONTSIZE,
			align="center"
		}
		text_appraisal = display.newText(text_appraisal_property);
		text_appraisal.id = tagId.id_appraisal
		text_appraisal:setFillColor(1, 1, 1 )
		text_appraisal.anchorX=0.5
		text_appraisal.anchorY=0
		text_appraisal.x = display.contentCenterX
		-- text_appraisal:addEventListener( "touch", selection_tag )
		group_lineOne:insert(text_appraisal)
		
		local touch_appraisal = display.newRect( group_lineOne, text_appraisal.x, text_appraisal.y-tagSelection_background_moreHeight, text_appraisal.width+tagSelection_background_moreWidth*2, text_appraisal.height+tagSelection_background_moreHeight*2 )
		touch_appraisal.id = text_appraisal.id
		touch_appraisal.anchorX=text_appraisal.anchorX
		touch_appraisal.anchorY=text_appraisal.anchorY
		touch_appraisal.alpha=0
		touch_appraisal.isHitTestable = true
		touch_appraisal:addEventListener( "touch", selection_tag )

		-- group_lineOne.x = 0-display.contentWidth
		
		
	-----------------------------------	line two
		group_lineTwo = display.newGroup()
		
		local text_anonymous_property =
		{
			text = localization.getLocalization("cat_anonymous"),
			y = display.contentHeight*LINE_TWO_RATIO, 
			font = "Helvetica",
			fontSize=LINE_CHOICES_FONTSIZE,
			align="center"
		}
		text_anonymous = display.newText(text_anonymous_property);
		text_anonymous.id = tagId.id_anonymous
		text_anonymous:setFillColor(1, 1, 1 )
		text_anonymous.anchorX=0.5
		text_anonymous.anchorY=0
		text_anonymous.x = display.contentCenterX
		-- text_anonymous:addEventListener( "touch", selection_tag )
		group_lineTwo:insert(text_anonymous)
		
		local touch_anonymous = display.newRect( group_lineTwo, text_anonymous.x, text_anonymous.y-tagSelection_background_moreHeight, text_anonymous.width+tagSelection_background_moreWidth*2, text_anonymous.height+tagSelection_background_moreHeight*2 )
		touch_anonymous.id = text_anonymous.id
		touch_anonymous.anchorX=text_anonymous.anchorX
		touch_anonymous.anchorY=text_anonymous.anchorY
		touch_anonymous.alpha=0
		touch_anonymous.isHitTestable = true
		touch_anonymous:addEventListener( "touch", selection_tag )
		
		-- group_lineTwo.x=display.contentWidth+group_lineTwo.width/2

	--------------------------------------	line three
		group_lineThree = display.newGroup()
		
		local text_30mins_property =
		{
			text = localization.getLocalization("cat_30mins"),
			y = display.contentHeight*LINE_THREE_RATIO,
			font = "Helvetica",
			fontSize=LINE_CHOICES_FONTSIZE,
			align="center"
		}
		text_30mins = display.newText(text_30mins_property);
		text_30mins.id = tagId.id_30mins
		text_30mins:setFillColor(1, 1, 1 )
		text_30mins.anchorX=0.5
		text_30mins.anchorY=0
		text_30mins.x = display.contentCenterX
		-- text_30mins:addEventListener( "touch", selection_tag )
		group_lineThree:insert(text_30mins)
		
		local touch_30mins = display.newRect( group_lineThree, text_30mins.x, text_30mins.y-tagSelection_background_moreHeight, text_30mins.width+tagSelection_background_moreWidth*2, text_30mins.height+tagSelection_background_moreHeight*2 )
		touch_30mins.id = text_30mins.id
		touch_30mins.anchorX=text_30mins.anchorX
		touch_30mins.anchorY=text_30mins.anchorY
		touch_30mins.alpha=0
		touch_30mins.isHitTestable = true
		touch_30mins:addEventListener( "touch", selection_tag )
		
		
		-- group_lineThree.x=0-display.contentWidth
		

		------------------------ line four
		group_lineFour = display.newGroup()
		
		local text_general_property =
		{
			text = localization.getLocalization("cat_general"),
			y = display.contentHeight*LINE_FOUR_RATIO,
			font = "Helvetica",
			fontSize=LINE_CHOICES_FONTSIZE,
			align="center"
		}
		text_general = display.newText(text_general_property);
		text_general.id = tagId.id_general
		text_general:setFillColor(1, 1, 1 )
		text_general.anchorX=0.5
		text_general.anchorY=0
		text_general.x = display.contentCenterX
		-- text_all:addEventListener( "touch", selection_tag )
		group_lineFour:insert(text_general)
		
		local touch_general = display.newRect( group_lineFour, text_general.x, text_general.y-tagSelection_background_moreHeight, text_general.width+tagSelection_background_moreWidth*2, text_general.height+tagSelection_background_moreHeight*2 )
		touch_general.id = text_general.id
		touch_general.anchorX=text_general.anchorX
		touch_general.anchorY=text_general.anchorY
		touch_general.alpha=0
		touch_general.isHitTestable = true
		touch_general:addEventListener( "touch", selection_tag )
		
		-- group_lineFour.x=display.contentWidth+group_lineFour.width/2
		
		group_cat:insert(group_lineOne)--lineOne
		group_cat:insert(group_lineTwo)
		group_cat:insert(group_lineThree)
		group_cat:insert(group_lineFour)
		
		--beginning setup begin

		tagChoice[1] = touch_anonymous
		tagChoice[2] = touch_appraisal
		tagChoice[3] = touch_30mins
		tagChoice[4] = touch_general
		
		group_cat.alpha=0
		transition.to(group_cat,{time=ANIMATION_TIME,alpha=1})--, transition=easing.inOutBack
		
		return group_cat
	end
end
return returnGroup

