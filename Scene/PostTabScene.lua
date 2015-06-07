---------------------------------------------------------------
-- TemplateScene.lua
--
-- Template for Scene
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
--local resDir = (...):match("(.-)[^%.]+$")

-- Local Constant Setting
local LOCAL_SETTINGS = {
						NAME = "PostScene",				-- Scene name to show in console
						RES_DIR = "Image/Post/",		-- Common resource directory for scene
						DOC_DIR = "",					-- Common document directory for scene
						}

---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------
local storyboard = require ( "storyboard" )
local widget = require ( "widget" )
require ( "SystemUtility.Debug" )
local projectObjectSetting = require( "Setting.ProjectObjectSetting" )
local headerView = require( "ProjectObject.HeaderView" )
local headTabFnc = require( "ProjectObject.HeadTabFnc" )
local localization = require("Localization.Localization")
local coronaTextField = require("Module.CoronaTextField")
local saveData = require( "SaveData.SaveData" )
local global = require( "GlobalVar.global" )
local json = require( "json" )
local addPhotoFnc = require("Function.addPhoto")
local stringUtility = require("SystemUtility.StringUtility")
local scrollViewForMultiScene = require("Module.scrollViewForMultiScene")
local optionModule = require("Module.Option")
local tagSelectionFnc = require("Function.tagSelectionFnc")
-- local networkFunction = require("Network.NetworkFunction")
local newNetworkFunction = require("Network.newNetworkFunction")
local hardwareButtonHandler = require("ProjectObject.HardwareButtonHandler")
---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local BASEDIR = system.TemporaryDirectory
local ROW_HEIGHT = 187


local choiceData = {}
choiceData[1] = { label="A",savePath=global.post2ChoiceAImage}
choiceData[2] = { label="B",savePath=global.post2ChoiceBImage}
choiceData[3] = { label="C",savePath=global.post2ChoiceCImage}
choiceData[4] = { label="D",savePath=global.post2ChoiceDImage}

local POST_INPUT_FIELD_TEXT_INFO =
{
	title = {x = 205, y = 269, width = 253, height = 65},
	desc = {x = 205, y = 408, width = 388, height = 65},
	link = {x = 205, y = 510, width = 388, height = 65},
	choice = {x = 287, y = 0, width = 316, height = 65},			-- y will be set individually
	couponTitle = {x = 158, y = 0, width = 300, height = 65},		-- y will be set individually
}
local POST_INPUT_FIELD_CORNER_RADIUS = 5

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------


--Create a storyboard scene for this module


--common
local scene = storyboard.newScene()

local sceneGroup --self.view
local scrollView
local header
local tabbar
local stage

local textLen
local limitedText
local goNextSceneOption = {
	scene = "next",
	transTime = 400,
}
local goPreviousSceneOption = {
	scene = "previous", 
	transTime = 400,
}
local curSceneNum = 1
--post1
local post1_title_textField
local post1_description_textField
local post1_linkToSite_textField


--post2


--post3
local hideResult_checkbox_background2
local isHideResult
local post3_title_textField
local tag_button_text
local filterOption

local postData = {}

local postTag = "General"

local uploadedPic = nil
---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
-- Function for back button


local function backLastScene()


	saveData.delete("postPicData.txt", system.TemporaryDirectory)
	
	addPhotoFnc.deleteTempImage(global.post1TitleImage)
	addPhotoFnc.deleteTempImage(global.post2ChoiceAImage)
	addPhotoFnc.deleteTempImage(global.post2ChoiceBImage)
	addPhotoFnc.deleteTempImage(global.post2ChoiceCImage)
	addPhotoFnc.deleteTempImage(global.post2ChoiceDImage)
	
	addPhotoFnc.deleteTempImage(global.post3CouponImage)-- coupon image
	
	header = headTabFnc.getHeader()
	tabbar = headTabFnc.getTabbar()
	
	storyboard.hideOverlay( "slideDown", 400 )
	timer.performWithDelay( 400 ,function(event)
		stage = display.getCurrentStage()
		stage:insert( header )
		stage:insert( tabbar )
		tabbar:setSelected(global.currentSceneNumber)  
	end)
end



local function backSceneFnc(event)
	if(event.phase=="ended" or event.phase=="cancelled")then
		curSceneNum = scrollViewForMultiScene.go(goPreviousSceneOption)
	end
	return true
end

local function addPhotoFunction(event)
	local phase = event.phase

	if ( phase == "moved" ) then
		local dy = math.abs( ( event.y - event.yStart ) )
		if ( dy > 10 ) then
			scrollView:takeFocus( event )
		end
	elseif(phase=="ended" or phase=="cancelled")then
		addPhotoFnc.addPhoto(event)
	end
	return true
end

local function createPostTextFieldBg(parent, detail, y)
	if (y == nil) then
		y = detail.y
	end
	-- local newTextFieldBg = display.newRoundedRect(detail.x, y, detail.width, detail.height, POST_INPUT_FIELD_CORNER_RADIUS)
	-- newTextFieldBg:setFillColor(1)
	-- newTextFieldBg:setStrokeColor(54/255 ,54/255 ,54/255)
	-- newTextFieldBg.strokeWidth = 2
	-- newTextFieldBg.anchorX=0
	-- newTextFieldBg.anchorY=0
	-- parent:insert(newTextFieldBg)
	local textFieldBgLeft = display.newImage(LOCAL_SETTINGS.RES_DIR .. "textFieldBgLeft.png", true)
	textFieldBgLeft.x = detail.x
	textFieldBgLeft.y = y
	textFieldBgLeft.anchorX=0
	textFieldBgLeft.anchorY=0
	parent:insert(textFieldBgLeft)
	local textFieldBgMiddle = display.newImage(LOCAL_SETTINGS.RES_DIR .. "textFieldBgMiddle.png", true)
	textFieldBgMiddle.x = detail.x + 20
	textFieldBgMiddle.y = y
	textFieldBgMiddle.xScale = (detail.width - 40) / 20
	textFieldBgMiddle.anchorX=0
	textFieldBgMiddle.anchorY=0
	parent:insert(textFieldBgMiddle)
	local textFieldBgRight = display.newImage(LOCAL_SETTINGS.RES_DIR .. "textFieldBgRight.png", true)
	textFieldBgRight.x = detail.x + detail.width - 20
	textFieldBgRight.y = y
	textFieldBgRight.anchorX=0
	textFieldBgRight.anchorY=0
	parent:insert(textFieldBgRight)

	return textFieldBgLeft
end

local function createPostTextField(parent, parentType, detail, y, userInputListener)
	if (y == nil) then
		y = detail.y
	end
	local newTextFieldBg = createPostTextFieldBg(parent, detail, y)
	local newTextField = coronaTextField:new(detail.x + 10, y + 10, detail.width - 20, detail.height - 20, parent, parentType)
	newTextField:setFont("Helvetica", 32)
	newTextField:setTopPadding(200)
	newTextField.hasBackground = false
	newTextField:setUserInputListener(userInputListener)
	parent:insert(newTextField)
	return newTextField, newTextFieldBg
end

local function post1_textListener( event )
    if ( event.phase == "began" ) then

    elseif ( event.phase == "ended" or event.phase == "submitted" ) then
		post1_title_textField.text = stringUtility.trimStringSpace(post1_title_textField.text)
		post1_description_textField.text = stringUtility.trimStringSpace(post1_description_textField.text)
		
    elseif ( event.phase == "editing" ) then
	
		textLen = string.len(post1_title_textField.text)
		if(textLen>30)then
			limitedText = string.sub(post1_title_textField.text,1,30)
			post1_title_textField.text = limitedText
			native.showAlert(localization.getLocalization("inputCheck_title"),localization.getLocalization("inputQuestion_limited"),{localization.getLocalization("ok")})
		end
		textLen = string.len(post1_description_textField.text)
		if(textLen>100)then
			limitedText = string.sub(post1_description_textField.text,1,100)
			event.text = limitedText
			post1_description_textField.text = limitedText                                  
			native.showAlert(localization.getLocalization("inputCheck_title"),localization.getLocalization("inputDesc_limited"),{localization.getLocalization("ok")})
		end
		local emojiTrimmedString, isEmojiDetected = stringUtility.trimEmoji(event.target.text)
		if (isEmojiDetected) then
			event.target.text = emojiTrimmedString
		end
    end
end


local function goToPost2Fnc(event)
	if(event.phase=="ended"or event.phase=="cancelled")then
		if(string.len(post1_title_textField.text)==0)then
			native.showAlert(localization.getLocalization("necessaryInput_title"),localization.getLocalization("necessaryInput_post1Title"),{localization.getLocalization("ok")})
			return false
		end
		curSceneNum = scrollViewForMultiScene.go(goNextSceneOption)
	end
	return true
end

local function touch_backLastSceneFnc(event)
	if(event.phase=="ended"or event.phase=="cancelled")then
		backLastScene()
	end
	return true
end

local function createScene1()

	local displayGroup = display.newGroup()
	
	-- local backButton = display.newImage("Image/RegisterPage/backButton.png", true)
	-- backButton:addEventListener("touch",touch_backLastSceneFnc)
	-- backButton.x = 60
	-- backButton.y = 60
	-- backButton.anchorX=0
	-- backButton.anchorY=0
	-- displayGroup:insert(backButton)

	local quitButton =
	{
		text = localization.getLocalization("post_quit"), 
		font = "Helvetica",
		fontSize=35.42,
		x = 60,
		y = 70,
		width = 0,
		height = 0, 
	}
	quitButton = display.newText( quitButton )
	quitButton:setFillColor( 78/255, 184/255, 229/255)
	quitButton:addEventListener("touch",touch_backLastSceneFnc)
	quitButton.anchorX=0
	quitButton.anchorY=0
	displayGroup:insert(quitButton)

	local nextButton =
	{
		text = localization.getLocalization("post_headerRightButton"), 
		font = "Helvetica",
		fontSize=35.42,
		x = display.contentWidth-60,
		y = 70,
		width = 0,
		height = 0, 
	}
	nextButton = display.newText( nextButton )
	nextButton:setFillColor( 78/255, 184/255, 229/255)
	nextButton:addEventListener("touch",goToPost2Fnc)
	nextButton.anchorX=1
	nextButton.anchorY=0
	displayGroup:insert(nextButton)
	
	
	---------------------- text begin
	local text_question =
	{
		text = localization.getLocalization("post_question"), 
		x = display.contentCenterX,
		y = 192,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=49.81
	}

	text_question = display.newText(text_question);
	text_question:setFillColor( 78/255, 184/255, 229/255)
	text_question.anchorX=0.5
	text_question.anchorY=0
	displayGroup:insert(text_question)
	
	local text_title =
	{
		text = localization.getLocalization("post_title"), 
		x = 192,
		y = 281,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=30
	}

	text_title = display.newText(text_title);
	text_title:setFillColor( 78/255, 184/255, 229/255)
	text_title.anchorX=1
	text_title.anchorY=0				
	displayGroup:insert(text_title)
	
	local text_titleStar =
	{
		text = "*", 
		x = text_title.x-text_title.width,
		y = 272,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=72
	}

	text_titleStar = display.newText(text_titleStar);
	text_titleStar:setFillColor( 78/255, 184/255, 229/255)
	text_titleStar.anchorX=1
	text_titleStar.anchorY=0
	displayGroup:insert(text_titleStar)
	
	local text_description =
	{
		text = localization.getLocalization("post_description"), 
		x = 192,
		y = 419,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=30
	}

	text_description = display.newText(text_description);
	text_description:setFillColor( 78/255, 184/255, 229/255)
	text_description.anchorX=1
	text_description.anchorY=0
	displayGroup:insert(text_description)

	local text_linkToSite =
	{
		text = localization.getLocalization("post_linkToSite"), 
		x = 192,
		y = 524,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=30
	}

	text_linkToSite = display.newText(text_linkToSite);
	text_linkToSite:setFillColor( 78/255, 184/255, 229/255)
	text_linkToSite.anchorX=1
	text_linkToSite.anchorY=0
	displayGroup:insert(text_linkToSite)
	------------------------- text end
	------------------------- textfield begin
	-- local title_background_textField_width = 253
	-- local title_background_textField_height = 65
	-- local title_background_textField_x = 205
	-- local title_background_textField_y = 269
	
	-- local title_background_textField = display.newRoundedRect( title_background_textField_x, title_background_textField_y, title_background_textField_width, title_background_textField_height, 3 )
	-- title_background_textField:setFillColor( 1,1,1 )
	-- title_background_textField:setStrokeColor(  54/255 ,54/255 ,54/255 )
	-- title_background_textField.strokeWidth = 1
	-- title_background_textField.anchorX=0
	-- title_background_textField.anchorY=0
	-- displayGroup:insert(title_background_textField)
	
	-- post1_title_textField = coronaTextField:new( title_background_textField.x, title_background_textField.y, title_background_textField.width, title_background_textField.height,displayGroup,"displayGroup" )
	-- post1_title_textField:setFont("Helvetica",32)
	-- post1_title_textField:setTopPadding(200)
	-- post1_title_textField.hasBackground = false
	-- post1_title_textField:setUserInputListener( post1_textListener )
	-- displayGroup:insert(post1_title_textField)
	local title_background_textField
	post1_title_textField, title_background_textField = createPostTextField(displayGroup, "displayGroup", POST_INPUT_FIELD_TEXT_INFO.title, nil, post1_textListener)
	---------------
	-- local description_background_textField_width = 388
	-- local description_background_textField_height = 65
	-- local description_background_textField_x = 205
	-- local description_background_textField_y = 408
	
	-- local description_background_textField = display.newRoundedRect( description_background_textField_x, description_background_textField_y, description_background_textField_width, description_background_textField_height, 3 )
	-- description_background_textField:setFillColor( 1,1,1 )
	-- description_background_textField:setStrokeColor(  54/255 ,54/255 ,54/255 )
	-- description_background_textField.strokeWidth = 2
	-- description_background_textField.anchorX=0
	-- description_background_textField.anchorY=0
	-- displayGroup:insert(description_background_textField)
	
	-- post1_description_textField = coronaTextField:new( description_background_textField.x, description_background_textField.y, description_background_textField.width, description_background_textField.height,displayGroup,"displayGroup" )
	-- post1_description_textField:setTopPadding(200)
	-- post1_description_textField:setFont("Helvetica",32)
	-- post1_description_textField.hasBackground = false
	-- post1_description_textField:setUserInputListener( post1_textListener )
	-- displayGroup:insert(post1_description_textField)
	local description_background_textField
	post1_description_textField, description_background_textField = createPostTextField(displayGroup, "displayGroup", POST_INPUT_FIELD_TEXT_INFO.desc, nil, post1_textListener)
	-----------------------
	-- local linkToSite_background_textField_width = 388
	-- local linkToSite_background_textField_height = 65
	-- local linkToSite_background_textField_x = 205
	-- local linkToSite_background_textField_y = 510
	
	-- local linkToSite_background_textField = display.newRoundedRect( linkToSite_background_textField_x, linkToSite_background_textField_y, linkToSite_background_textField_width, linkToSite_background_textField_height, 3 )
	-- linkToSite_background_textField:setFillColor( 1,1,1 )
	-- linkToSite_background_textField:setStrokeColor(  54/255 ,54/255 ,54/255 )
	-- linkToSite_background_textField.strokeWidth = 2
	-- linkToSite_background_textField.anchorX=0
	-- linkToSite_background_textField.anchorY=0
	-- displayGroup:insert(linkToSite_background_textField)
	
	-- post1_linkToSite_textField = coronaTextField:new( linkToSite_background_textField.x, linkToSite_background_textField.y, linkToSite_background_textField.width, linkToSite_background_textField.height,displayGroup,"displayGroup" )
	-- post1_linkToSite_textField:setFont("Helvetica",32)
	-- post1_linkToSite_textField:setTopPadding(200)
	-- post1_linkToSite_textField.hasBackground = false
	-- post1_linkToSite_textField:setUserInputListener( post1_textListener )
	-- displayGroup:insert(post1_linkToSite_textField)
	local linkToSite_background_textField
	post1_linkToSite_textField, linkToSite_background_textField = createPostTextField(displayGroup, "displayGroup", POST_INPUT_FIELD_TEXT_INFO.link, nil, post1_textListener)
	
	local text_linkToSite_desc =
	{
		text = localization.getLocalization("post_linkToSite_desc"), 
		x = POST_INPUT_FIELD_TEXT_INFO.link.x,
		y = POST_INPUT_FIELD_TEXT_INFO.link.y+POST_INPUT_FIELD_TEXT_INFO.link.height+22,
		width = POST_INPUT_FIELD_TEXT_INFO.link.width,
		height = 0, 
		font = "Helvetica",
		fontSize=24
	}
	text_linkToSite_desc = display.newText(text_linkToSite_desc)
	text_linkToSite_desc:setFillColor( 215/255, 215/255, 215/255)
	text_linkToSite_desc.anchorX=0
	text_linkToSite_desc.anchorY=0
	displayGroup:insert(text_linkToSite_desc)
	------------------------- textfield end
	local text_title_desc =
	{
		text = localization.getLocalization("post_title_desc"), 
		x = POST_INPUT_FIELD_TEXT_INFO.title.x,
		y = POST_INPUT_FIELD_TEXT_INFO.title.y+POST_INPUT_FIELD_TEXT_INFO.title.height+6,
		width = POST_INPUT_FIELD_TEXT_INFO.title.width,
		height = 0, 
		font = "Helvetica",
		fontSize=24
	}
	
	text_title_desc = display.newText(text_title_desc);
	text_title_desc:setFillColor( 159/255, 159/255, 159/255)
	text_title_desc.anchorX=0
	text_title_desc.anchorY=0
	displayGroup:insert(text_title_desc)
	
	local line = display.newLine(36,669,display.contentWidth-36,669)
	line:setStrokeColor( 85/255, 85/255, 85/255 )
	line.strokeWidth = 2
	displayGroup:insert(line)
	
	local attention_text_star =
	{
		text = "*", 
		x = 50,
		y = 730,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=72
	}

	attention_text_star = display.newText(attention_text_star);
	attention_text_star:setFillColor( 159/255, 159/255, 159/255)
	attention_text_star.anchorX=0
	attention_text_star.anchorY=0.5
	displayGroup:insert(attention_text_star)
	
	local attention_text =
	{
		text = localization.getLocalization("post_attention"),
		x = 86,
		y = 715,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=24
	}
	attention_text = display.newText(attention_text);
	attention_text:setFillColor( 159/255, 159/255, 159/255)
	attention_text.anchorX=0
	attention_text.anchorY=0.5
	displayGroup:insert(attention_text)
	--------------------
	
	local button_addPhoto = widget.newButton
	{
		
		defaultFile = "Image/RegisterPage/addPhoto.png",
		overFile = "Image/RegisterPage/addPhoto.png",
		onEvent = addPhotoFunction,
	}
	button_addPhoto.x = POST_INPUT_FIELD_TEXT_INFO.title.x+POST_INPUT_FIELD_TEXT_INFO.title.width+18
	button_addPhoto.y = POST_INPUT_FIELD_TEXT_INFO.title.y
	button_addPhoto.anchorX = 0
	button_addPhoto.anchorY = 0
	button_addPhoto.savePath = global.post1TitleImage
	button_addPhoto.photo = nil
	displayGroup:insert(button_addPhoto)
	--set next field
	post1_title_textField:nextTextFieldFocus(post1_description_textField, nil)
	post1_description_textField:nextTextFieldFocus(post1_linkToSite_textField, nil)
	return displayGroup
end


local function post2_textListener( event )
    if ( event.phase == "began" ) then

    elseif ( event.phase == "ended" or event.phase == "submitted" ) then
		
		choiceData[1].textField.text = stringUtility.trimStringSpace(choiceData[1].textField.text)
		choiceData[2].textField.text = stringUtility.trimStringSpace(choiceData[2].textField.text)
		choiceData[3].textField.text = stringUtility.trimStringSpace(choiceData[3].textField.text)
		choiceData[4].textField.text = stringUtility.trimStringSpace(choiceData[4].textField.text)
		
    elseif ( event.phase == "editing" ) then
		local emojiTrimmedString, isEmojiDetected = stringUtility.trimEmoji(event.target.text)
		local textALen = string.len(choiceData[1].textField.text)
		local textBLen = string.len(choiceData[2].textField.text)
		local textCLen = string.len(choiceData[3].textField.text)
		local textDLen = string.len(choiceData[4].textField.text)
		
		if(textALen>30)then
			limitedText = string.sub(choiceData[1].textField.text,1,30)
			event.text = limitedText
			choiceData[1].textField.text = limitedText                                  
			native.showAlert(localization.getLocalization("inputCheck_title"),localization.getLocalization("inputPost2Desc_limited"),{localization.getLocalization("ok")})
		elseif(textBLen>30)then
			limitedText = string.sub(choiceData[2].textField.text,1,30)
			event.text = limitedText
			choiceData[2].textField.text = limitedText                                  
			native.showAlert(localization.getLocalization("inputCheck_title"),localization.getLocalization("inputPost2Desc_limited"),{localization.getLocalization("ok")})
		elseif(textCLen>30)then
			limitedText = string.sub(choiceData[3].textField.text,1,30)
			event.text = limitedText
			choiceData[3].textField.text = limitedText                                  
			native.showAlert(localization.getLocalization("inputCheck_title"),localization.getLocalization("inputPost2Desc_limited"),{localization.getLocalization("ok")})
		elseif(textDLen>30)then
			limitedText = string.sub(choiceData[4].textField.text,1,30)
			event.text = limitedText
			choiceData[4].textField.text = limitedText                                  
			native.showAlert(localization.getLocalization("inputCheck_title"),localization.getLocalization("inputPost2Desc_limited"),{localization.getLocalization("ok")})
		end
		
		if (isEmojiDetected) then
			event.target.text = emojiTrimmedString
		end
    end
end


local function goToPost3Fnc(event)
	if(event.phase=="ended"or event.phase=="cancelled")then
		local choiceAImagePath = addPhotoFnc.getImageRealPath(global.post2ChoiceAImage)
		local choiceBImagePath = addPhotoFnc.getImageRealPath(global.post2ChoiceBImage)
		local choiceCImagePath = addPhotoFnc.getImageRealPath(global.post2ChoiceCImage)
		local choiceDImagePath = addPhotoFnc.getImageRealPath(global.post2ChoiceDImage)
		
		local choiceADesc = choiceData[1].textField.text
		local choiceBDesc = choiceData[2].textField.text
		local choiceCDesc = choiceData[3].textField.text
		local choiceDDesc = choiceData[4].textField.text
		
		if(not choiceAImagePath and string.len(choiceADesc)==0)then
			native.showAlert(localization.getLocalization("necessaryInput_title"),localization.getLocalization("necessaryInput_post2ChoiceA"),{localization.getLocalization("ok")})
			return false
		elseif(not choiceBImagePath and string.len(choiceBDesc)==0)then
			native.showAlert(localization.getLocalization("necessaryInput_title"),localization.getLocalization("necessaryInput_post2ChoiceB"),{localization.getLocalization("ok")})
			return false
		elseif((not choiceCImagePath and string.len(choiceCDesc)==0)and(choiceDImagePath or string.len(choiceDDesc)>0))then
			native.showAlert(localization.getLocalization("necessaryInput_title"),localization.getLocalization("necessaryInput_post2FillChoiceDEmptyChoiceC"),{localization.getLocalization("ok")})
			return false
		end
		curSceneNum = scrollViewForMultiScene.go(goNextSceneOption)
	end
	return true
end


local function createScene2()
	local displayGroup = display.newGroup()
	
	-- local backButton = display.newImage("Image/RegisterPage/backButton.png", true)
	-- backButton:addEventListener("touch",backSceneFnc)
	-- backButton.x = 60
	-- backButton.y = 60
	-- backButton.anchorX=0
	-- backButton.anchorY=0
	-- displayGroup:insert(backButton)
	
	local backButton =
	{
		text = localization.getLocalization("post_back"), 
		font = "Helvetica",
		fontSize=35.42,
		x = 60,
		y = 70,
		width = 0,
		height = 0, 
	}
	backButton = display.newText( backButton )
	backButton:setFillColor( 78/255, 184/255, 229/255)
	backButton:addEventListener("touch",backSceneFnc)
	backButton.anchorX=0
	backButton.anchorY=0
	displayGroup:insert(backButton)

	local nextButton =
	{
		text = localization.getLocalization("post_headerRightButton"), 
		font = "Helvetica",
		fontSize=35.42,
		x = display.contentWidth-60,
		y = 70,
		width = 0,
		height = 0, 
	}
	nextButton = display.newText( nextButton )
	nextButton:setFillColor( 78/255, 184/255, 229/255)
	nextButton:addEventListener("touch",goToPost3Fnc)
	nextButton.anchorX=1
	nextButton.anchorY=0
	displayGroup:insert(nextButton)
	
	local text_choices =
	{
		text = localization.getLocalization("post2_choices"),
		x = display.contentCenterX,
		y = 192,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=49.81
	}
		
	text_choices = display.newText(text_choices);
	text_choices:setFillColor( 78/255, 184/255, 229/255)
	text_choices.anchorX=0.5
	text_choices.anchorY=0
	displayGroup:insert(text_choices)
	
	---------------------- line begin
	
	local line = display.newLine(36,266,display.contentWidth-36,266)
	line:setStrokeColor( 85/255, 85/255, 85/255 )
	line.strokeWidth = 2
	displayGroup:insert(line)	
	---------------------- line end
	local choiceCircle_x = 20
	local choiceCircle_y = text_choices.y+text_choices.height+31
	local button_addPhoto_x = 150
	local button_addPhoto_y = text_choices.y+text_choices.height+31
	local background_textField_width = 316
	local background_textField_height = 84
	local background_textField_x = 287
	local background_textField_y = text_choices.y+text_choices.height+31
	local line_y = text_choices.y+text_choices.height+ROW_HEIGHT
	
	for i=1,4 do ----------------
	
		local choiceCircle = widget.newButton
		{
			id = "circle",
			label = choiceData[i].label,
			labelColor = { default={ 243/255, 243/255, 243/255}, over={ 243/255, 243/255, 243/255} },
			fontSize = 72,
			shape = "circle",
			fillColor = { default={ 64/255, 216/255, 226/255}, over={ 64/255, 216/255, 226/255} },
			strokeColor = { default={ 64/255, 216/255, 226/255}, over={ 64/255, 216/255, 226/255} },
			strokeWidth = 0,
			radius = 60,
			isEnabled = false,
		}

		choiceCircle.x = choiceCircle_x
		choiceCircle.y = choiceCircle_y
		choiceCircle.anchorX = 0
		choiceCircle.anchorY = 0
		displayGroup:insert(choiceCircle)	
		choiceCircle_y = choiceCircle_y+ROW_HEIGHT
		
		choiceData[i].button_addPhoto = widget.newButton
		{
			defaultFile = "Image/RegisterPage/addPhoto.png",
			overFile = "Image/RegisterPage/addPhoto.png",
			onEvent = addPhotoFunction,
		}
		
		choiceData[i].button_addPhoto.x = button_addPhoto_x
		choiceData[i].button_addPhoto.y = button_addPhoto_y
		choiceData[i].button_addPhoto.anchorX = 0
		choiceData[i].button_addPhoto.anchorY = 0
		choiceData[i].button_addPhoto.savePath = choiceData[i].savePath
		choiceData[i].button_addPhoto.photo = nil
		displayGroup:insert(choiceData[i].button_addPhoto)	
		button_addPhoto_y = button_addPhoto_y+ROW_HEIGHT
		
		------------------------- textfield begin
		-- local background_textField = display.newRoundedRect( background_textField_x, background_textField_y, background_textField_width, background_textField_height, 3 )
		-- background_textField:setFillColor( 1,1,1 )
		-- background_textField:setStrokeColor(  54/255 ,54/255 ,54/255 )
		-- background_textField.strokeWidth = 2
		-- background_textField.anchorX=0
		-- background_textField.anchorY=0
		-- displayGroup:insert(background_textField)	
		
		-- choiceData[i].textField = coronaTextField:new( background_textField.x, background_textField.y, background_textField.width, background_textField.height,displayGroup,"displayGroup" )
		-- choiceData[i].textField.anchorX=0
		-- choiceData[i].textField.anchorY=0
		-- choiceData[i].textField:setTopPadding(200)
		-- choiceData[i].textField:setPlaceHolderText(localization.getLocalization("post2_textField_placeholder"))
		-- choiceData[i].textField:setFont("Helvetica",32)
		-- -- textField.isFontSizeScaled = true
		-- choiceData[i].textField.hasBackground = false
		-- choiceData[i].textField:setUserInputListener( post2_textListener )
		-- displayGroup:insert(choiceData[i].textField)	
		local background_textField
		choiceData[i].textField, background_textField = createPostTextField(displayGroup, "displayGroup", POST_INPUT_FIELD_TEXT_INFO.choice, background_textField_y, post2_textListener)
		choiceData[i].textField:setPlaceHolderText(localization.getLocalization("post2_textField_placeholder"))
		background_textField_y = background_textField_y+ROW_HEIGHT
		------------------------- textfield end
		
		---------------------- text begin
		local description_text =
		{
			text = localization.getLocalization("post2_description"), 
			x = 445,
			y = choiceData[i].textField.y+choiceData[i].textField.height+20,
			width = 0,
			height = 0, 
			font = "Helvetica",
			fontSize=24
		}
		description_text = display.newText(description_text);
		description_text:setFillColor( 159/255, 159/255, 159/255)
		description_text.anchorX=0.5
		description_text.anchorY=0
		displayGroup:insert(description_text)
		------------------------- text end
		local line = display.newLine(36,line_y,display.contentWidth-36,line_y)
		line:setStrokeColor( 85/255, 85/255, 85/255 )
		line.strokeWidth = 2
		displayGroup:insert(line)
		line_y = line_y+ROW_HEIGHT
	end
	--set next field
	for i = 1,#choiceData-1 do
		choiceData[i].textField:nextTextFieldFocus(choiceData[i+1].textField, nil)
	end

	return displayGroup
end
local function createCouponListener(event)
	if (event[1].isError) then
		native.showAlert(localization.getLocalization("networkError_errorTitle"),localization.getLocalization("networkError_newCoupon"),{localization.getLocalization("ok")})
	else
		-- print(event[1].response)
		
	end
end
local function createPostListener(event)
	if (event[1].isError) then
		native.showAlert(localization.getLocalization("networkError_errorTitle"),localization.getLocalization("networkError_newPost"),{localization.getLocalization("ok")})
	else
		-- print(event[1].response)
		if(isVip and couponText)then
			native.showAlert(localization.getLocalization("newCouponSuccessTitle"),localization.getLocalization("newCouponSuccess"),{localization.getLocalization("ok")})
		else
			native.showAlert(localization.getLocalization("newPostSuccessTitle"),localization.getLocalization("newPostSuccess"),{localization.getLocalization("ok")})
		end
		

		saveData.delete("postPicData.txt", system.TemporaryDirectory)
		
		addPhotoFnc.deleteTempImage(global.post1TitleImage)
		addPhotoFnc.deleteTempImage(global.post2ChoiceAImage)
		addPhotoFnc.deleteTempImage(global.post2ChoiceBImage)
		addPhotoFnc.deleteTempImage(global.post2ChoiceCImage)
		addPhotoFnc.deleteTempImage(global.post2ChoiceDImage)
		
		addPhotoFnc.deleteTempImage(global.post3CouponImage)-- coupon image
		-- create finish
		storyboard.hideOverlay( "slideDown", 400 )
		timer.performWithDelay( 400 ,function(event)
			stage = display.getCurrentStage()
			stage:insert( header )
			stage:insert( tabbar )
			tabbar:setSelected(global.currentSceneNumber)  
		end) 

	end
	native.setActivityIndicator( false )
end

local uploadedSuccessList = {}
local function createPost()
	postData.photoList = uploadedPic
	newNetworkFunction.createPost(postData, createPostListener)
end

local function uploadPicListener(event)

	if (event.uploadedData) then
		uploadedSuccessList[event.uploadedData.key] = event.uploadedData.filename
		-- print(event.uploadedData.key)
	end
	if (event.isFinished) then
		-- print("Finished")
		saveData.save("postPicData.txt", system.TemporaryDirectory, uploadedSuccessList)
		if (event.uploadErrorList) then
			local errorMsg = "Error:"
			for i = 1, #event.uploadErrorList do
				errorMsg = errorMsg .. " " .. event.uploadErrorList[i].key
			end
			errorMsg = errorMsg .. ". Continue?"
			native.showAlert("Error", errorMsg, {"OK", "Cancel"}, function(event)
																		if (event.index == 1) then
																			uploadedPic = uploadedSuccessList
																			createPost()
																		elseif (event.index == 2) then
																			native.showAlert("Cancel create post", "Cancel create post")
																		end
																	end)
		else
			uploadedPic = uploadedSuccessList
			createPost()
		end
	end
end
--end upload Picture
local function newPostFnc(event)
	if(event.phase=="ended" or event.phase=="cancelled")then
		-- Check coupon text and pic are both exist
		local isCouponTextExist = false
		if ((post3_title_textField ~= nil) and (string.len(post3_title_textField.text) > 0)) then
			isCouponTextExist = true
		end
		if (addPhotoFnc.getImageRealPath(global.post3CouponImage)) then
			if (not(isCouponTextExist)) then
				native.showAlert(localization.getLocalization("post3CouponDataNotEnoughTitle"),localization.getLocalization("post3CouponDataNotEnough"),{localization.getLocalization("ok")})	
				return true
			end
		else
			if (isCouponTextExist) then
				native.showAlert(localization.getLocalization("post3CouponDataNotEnoughTitle"),localization.getLocalization("post3CouponDataNotEnough"),{localization.getLocalization("ok")})	
				return true
			end
		end
		if ((not(isCouponTextExist)) and (isHideResult)) then
			native.showAlert(localization.getLocalization("post3InputCheckTitle"),localization.getLocalization("post3InputCheck_noCouponHideResult"),{localization.getLocalization("ok")})	
			return true
		end

		-- if(post3_title_textField)then
		-- 	if(post3_title_textField.text)then
		-- 		if(string.len(post3_title_textField.text)==0 and isHideResult)then
		-- 			native.showAlert(localization.getLocalization("post3InputCheckTitle"),localization.getLocalization("post3InputCheck_noCouponHideResult"),{localization.getLocalization("ok")})	
		-- 			return false
		-- 		end
		-- 	end
		-- end
		--get data
		native.setActivityIndicator( true )
		local userData = saveData.load(global.userDataPath)
		--get image path
		local temp_post1TitleImagePath = addPhotoFnc.getImageRealPath(global.post1TitleImage)
		local temp_post2ChoiceAImage = addPhotoFnc.getImageRealPath(global.post2ChoiceAImage)
		local temp_post2ChoiceBImage = addPhotoFnc.getImageRealPath(global.post2ChoiceBImage)
		local temp_post2ChoiceCImage = addPhotoFnc.getImageRealPath(global.post2ChoiceCImage)
		local temp_post2ChoiceDImage = addPhotoFnc.getImageRealPath(global.post2ChoiceDImage)
		
		postData = {}
		postData.post = {}
		postData.post.choices = {}
		postData.photoList = {}
		postData.photoList.isPicResized = true
		--get photo
		
		if(temp_post1TitleImagePath)then
			postData.photoList.questionPic = {}
			postData.photoList.questionPic.path = temp_post1TitleImagePath
			postData.photoList.questionPic.baseDir = BASEDIR 
			-- print("get question Image",postData.photoList.questionPic.path)
		end
		if(temp_post2ChoiceAImage)then
			postData.photoList.answerPicA = {}
			postData.photoList.answerPicA.path = temp_post2ChoiceAImage
			postData.photoList.answerPicA.baseDir = BASEDIR 
			-- print("get post2 choice A Image",postData.photoList.answerPicA.path)
		end
		if(temp_post2ChoiceBImage)then
			postData.photoList.answerPicB = {}
			postData.photoList.answerPicB.path = temp_post2ChoiceBImage
			postData.photoList.answerPicB.baseDir = BASEDIR 
			-- print("get post2 choice B Image",postData.photoList.answerPicB.path)
		end
		if(temp_post2ChoiceCImage)then
			postData.photoList.answerPicC = {}
			postData.photoList.answerPicC.path = temp_post2ChoiceCImage
			postData.photoList.answerPicC.baseDir = BASEDIR
			-- print("get post2 choice C Image",postData.photoList.answerPicC.path)			
		end
		if(temp_post2ChoiceDImage)then
			postData.photoList.answerPicD = {}
			postData.photoList.answerPicD.path = temp_post2ChoiceDImage
			postData.photoList.answerPicD.baseDir = BASEDIR 
			-- print("get post2 choice D Image",postData.photoList.answerPicD.path)	
		end
		--set question title desc link
		
		postData.post.title = post1_title_textField.text
		postData.post.text = post1_description_textField.text
		postData.post.link = post1_linkToSite_textField.text

		postData.post.tag = postTag

		--set anonymous
		if(postData.post.tag=="Anonymous")then
			-- postData.post.anonymous = true
			postData.post.anonymous = "1"
		else
			postData.post.anonymous = "0"
		end

		if(postData.post.tag=="30mins")then
			postData.post.post_duration = 30*60
		end

		postData.post.choices[1] = {}
		postData.post.choices[1].text = choiceData[1].textField.text
		-- print("get choice A text",postData.post.choices[1].text)	
		
		postData.post.choices[2] = {}
		postData.post.choices[2].text = choiceData[2].textField.text
		-- print("get choice B text",postData.post.choices[2].text)	
		
		if((choiceData[3].textField.text and choiceData[3].textField.text~="") or temp_post2ChoiceCImage)then
		postData.post.choices[3] = {}
		postData.post.choices[3].text = choiceData[3].textField.text
		-- print("get choice C text",postData.post.choices[3].text)	
		
			if((choiceData[4].textField.text and choiceData[4].textField.text~="") or temp_post2ChoiceDImage)then
				postData.post.choices[4] = {}
				postData.post.choices[4].text = choiceData[4].textField.text
				-- print("get choice D text",postData.post.choices[4].text)	
			end
		end

		local filterOptionData = filterOption:getChosenOrderNum()

		if(filterOptionData == 2 )then
			postData.post.friend_only = true
		else
			postData.post.friend_only = false
		end
		
		--set country
		if(userData.country)then
			postData.post.country = userData.country
			-- print("set country",postData.post.country)
		end
		
		--VIP
		isVip = false
		if((userData.vip ~= nil) and (tonumber(userData.vip) > 0))then
			isVip = true
			-- print("is Vip",isVip)
			
			if (isCouponTextExist) then
				couponText = post3_title_textField.text
				postData.post.coupon = {}
				postData.post.coupon.text = couponText
				-- print("get coupon text",couponText)
			else
				couponText = nil
				-- print("no coupon text",nil)
			end
			--set hide result

			-- postData.hide_result = isHideResult
			if (isHideResult) then
				postData.post.hide_result = "1"
			else
				postData.post.hide_result = "0"
			end

			--set photo
			local temp_couponPic = addPhotoFnc.getImageRealPath(global.post3CouponImage)
			if(temp_couponPic)then
				postData.photoList.couponPic = {}
				postData.photoList.couponPic.path = temp_couponPic
				postData.photoList.couponPic.baseDir = BASEDIR 
				-- print("get coupon Picture",postData.photoList.couponPic.path)
			end
		end
		--
		uploadedPic = saveData.load("postPicData.txt", system.TemporaryDirectory)
		if (uploadedPic) then
			createPost()
			-- print("already upload photo and create post")
		else
			if(postData.photoList)then
			
				local boolean_haveUploadedPhoto

				boolean_haveUploadedPhoto = newNetworkFunction.uploadPostPic( postData.photoList, uploadPicListener)
	
				if(not boolean_haveUploadedPhoto)then
					uploadedPic = {}
					createPost()
				end
				
			end
		end
	end
	return true
end

local function post3_textListener( event )
    if ( event.phase == "began" ) then
    elseif ( event.phase == "ended" or event.phase == "submitted" ) then
		post3_title_textField.text = stringUtility.trimStringSpace(post3_title_textField.text)
    elseif ( event.phase == "editing" ) then

		if(string.len(post3_title_textField.text)>200)then
			local limitedText = string.sub(post3_title_textField.text,1,200)
			post3_title_textField.text = limitedText
			native.showAlert(localization.getLocalization("inputCheck_title"),localization.getLocalization("inputCouponTitle_limited"),{localization.getLocalization("ok")})
		end

		local emojiTrimmedString, isEmojiDetected = stringUtility.trimEmoji(event.target.text)
		if (isEmojiDetected) then
			event.target.text = emojiTrimmedString
		end
    end
end


local function hideResultCheckboxFnc(event)
	local phase = event.phase

    if ( phase == "moved" ) then
        local dy = math.abs( ( event.y - event.yStart ) )
        if ( dy > 10 ) then
            scrollView:takeFocus( event )
        end
	elseif(phase == "ended" or phase == "cancelled") then
	
		if (not isHideResult) then
			isHideResult=true
			hideResult_checkbox_background2.alpha=1
		elseif (isHideResult) then
			isHideResult=false
			hideResult_checkbox_background2.alpha=0
		end

	end
    return true
end

--------------------
-------------- tag drop down list begin

local function selectionTag_callBackFnc(tags)
	postTag = tags
	tags = "cat_"..tostring(string.lower(tags))
	tag_button_text.text = localization.getLocalization(tags)
	tag_button_text:setFillColor( 0,0,0 )
end
local function tagSelection(event)
	if(event.phase=="ended"or event.phase=="cancelled")then
		tagSelectionFnc.tagSelection(selectionTag_callBackFnc)
	end
	return true
end

local function createScene3()

	local displayGroup = display.newGroup()
	-- local backButton = display.newImage("Image/RegisterPage/backButton.png", true)
	-- backButton:addEventListener("touch",backSceneFnc)
	-- backButton.x = 60
	-- backButton.y = 60
	-- backButton.anchorX=0
	-- backButton.anchorY=0
	-- displayGroup:insert(backButton)
	
	local backButton =
	{
		text = localization.getLocalization("post_back"), 
		font = "Helvetica",
		fontSize=35.42,
		x = 60,
		y = 70,
		width = 0,
		height = 0, 
	}
	backButton = display.newText( backButton )
	backButton:setFillColor( 78/255, 184/255, 229/255)
	backButton:addEventListener("touch",backSceneFnc)
	backButton.anchorX=0
	backButton.anchorY=0
	displayGroup:insert(backButton)

	local newPostButton =
	{
		text = localization.getLocalization("post3_headerRightButton"), 
		font = "Helvetica",
		fontSize=35.42,
		x = display.contentWidth-60,
		y = 70,
		width = 0,
		height = 0, 
	}
	newPostButton = display.newText( newPostButton )
	newPostButton:setFillColor( 78/255, 184/255, 229/255)
	newPostButton:addEventListener("touch",newPostFnc)
	newPostButton.anchorX=1
	newPostButton.anchorY=0
	displayGroup:insert(newPostButton)
	
	---------------------- text begin
	local text_audience =
	{
		text = localization.getLocalization("post3_audience"), 
		x = display.contentCenterX,
		y = 192,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=49.81
	}

	text_audience = display.newText(text_audience);
	text_audience:setFillColor( 78/255, 184/255, 229/255)
	text_audience.anchorX=0.5
	text_audience.anchorY=0
	displayGroup:insert(text_audience)
	
	local text_tag =
	{
		text = localization.getLocalization("post3_tag"), 
		x = display.contentCenterX,
		y = 442,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=49.81
	}

	text_tag = display.newText(text_tag);
	text_tag:setFillColor( 78/255, 184/255, 229/255)
	text_tag.anchorX=0.5
	text_tag.anchorY=0
		
	displayGroup:insert(text_tag)
	------------------------- text end
	---------------- public and friends only begin

	filterOption = {
		choices = {localization.getLocalization("post3_public"),localization.getLocalization("post3_friendsOnly")},
		choicesId = {"public","friendsOnly"},
		leftImagePath_isSelected = "Image/Filter/leftSelect.png",
		leftImagePath_isNotSelected = "Image/Filter/leftNotSelect.png",
		rightImagePath_isSelected = "Image/Filter/rightSelect.png",
		rightImagePath_isNotSelected ="Image/Filter/rightNotSelect.png",
		choicesListener = {touch_audience_selection,touch_audience_selection},
		y = 273,
		font = "Helvetica",
		fontSize = 28.06,
		textColor = { 1, 1, 1},
		choiceOffset = 2,
		default = 1,
	}
	filterOption = optionModule.new(filterOption)
	displayGroup:insert(filterOption)
	
	---------------- public and friends only end
	
	------------------------- line begin
	
	local line = display.newLine(36,401,display.contentWidth-36,401)
	line:setStrokeColor( 85/255,85/255,85/255  )
	line.strokeWidth = 2
	line.anchorX=0
	line.anchorY=0
				
	displayGroup:insert(line)
	
	
	------------------------- line end
	-------------------------

	-- local tag_button_background = display.newRoundedRect(display.contentCenterX,text_tag.y+text_tag.height+45,390,50,8)
	-- tag_button_background.strokeWidth = 2
	-- tag_button_background:setFillColor( 1, 1, 1 )
	-- tag_button_background:setStrokeColor( 54/255, 54/255, 54/255 )
	-- tag_button_background.anchorX=0.5
	-- tag_button_background.anchorY=0
	-- displayGroup:insert(tag_button_background)
	local tagButtonBgDetail = {y = text_tag.y+text_tag.height+45, width = 390, height = 50}
	tagButtonBgDetail.x = display.contentCenterX - (tagButtonBgDetail.width * 0.5)
	local tag_button_background = createPostTextFieldBg(displayGroup, tagButtonBgDetail)
	-- tag_button_background.anchorX=0.5

	-- local tag_button_background_beginX = tag_button_background.x-tag_button_background.width*tag_button_background.anchorX
	local tag_button_background_beginX = tag_button_background.x
	local tag_button_background_centerY = tag_button_background.y+tag_button_background.height/2
	
	tag_button_text =
	{
		text = localization.getLocalization("post3_select_tag"), -- get data from server
		x = display.contentCenterX,
		y = tag_button_background_centerY,
		width = tagButtonBgDetail.width,		-- tag_button_background.width,
		height = 0, 
		font = "Helvetica",
		fontSize=30,
		align = "center",
	}
	tag_button_text = display.newText(tag_button_text);
	tag_button_text:setFillColor(214/255, 214/255, 214/255 )
	tag_button_text.anchorX=0.5
	tag_button_text.anchorY=0.5
	tag_button_text:addEventListener("touch",tagSelection)

	displayGroup:insert(tag_button_text)
	
	local text_tag_description =
	{
		text = localization.getLocalization("post3_tag_description"), 
		x = display.contentCenterX,
		y = tag_button_background.y+tag_button_background.height+10,
		width = display.contentWidth,
		height = 0, 
		font = "Helvetica",
		fontSize=20,
		align = "center"
	}

	text_tag_description = display.newText(text_tag_description);
	text_tag_description:setFillColor(0, 0, 0)
	text_tag_description.anchorX=0.5
	text_tag_description.anchorY=0
	
	displayGroup:insert(text_tag_description)

	local line2 = display.newLine(36,text_tag_description.y+text_tag_description.height+10,display.contentWidth-36,text_tag_description.y+text_tag_description.height+10)
	line2:setStrokeColor( 85/255,85/255,85/255  )
	line2.strokeWidth = 2
	line2.anchorX=0
	line2.anchorY=0

	displayGroup:insert(line2)
	
	-------------------------
	
	--VIP
	local savedUserData = saveData.load(global.userDataPath)
	if((savedUserData.vip ~= nil) and (tonumber(savedUserData.vip) > 0))then
		
		local text_vip =
		{
			text = localization.getLocalization("post3_VIP"), 
			x = display.contentCenterX,
			y = line2.y+line2.height+40,
			width = 0,
			height = 0, 
			font = "Helvetica",
			fontSize=49.81
		}

		local text_vip = display.newText(text_vip);
		text_vip:setFillColor( 78/255, 184/255, 229/255)
		text_vip.anchorX=0.5
		text_vip.anchorY=0
		displayGroup:insert(text_vip)
		
		-- local title_background_textField_width = 300
		-- local title_background_textField_height = 70
		-- local title_background_textField_x = 158
		local title_background_textField_y = text_vip.y+text_vip.height+40
		
		-- local title_background_textField = display.newRoundedRect( title_background_textField_x, title_background_textField_y, title_background_textField_width, title_background_textField_height, 3 )
		-- title_background_textField:setFillColor( 1,1,1 )
		-- title_background_textField:setStrokeColor(  54/255 ,54/255 ,54/255 )
		-- title_background_textField.strokeWidth = 2
		-- title_background_textField.anchorX=0
		-- title_background_textField.anchorY=0
		-- displayGroup:insert(title_background_textField)
		
		-- post3_title_textField = coronaTextField:new( title_background_textField.x, title_background_textField.y, title_background_textField.width, title_background_textField.height,displayGroup,"displayGroup" )
		-- post3_title_textField:setTopPadding(200)
		-- post3_title_textField:setFont("Helvetica",32)
		-- post3_title_textField:setPlaceHolderText(localization.getLocalization("post3_title"))
		-- post3_title_textField.hasBackground = false
		-- post3_title_textField:setUserInputListener( post3_textListener )
		-- displayGroup:insert(post3_title_textField)
		local title_background_textField
		post3_title_textField, title_background_textField = createPostTextField(displayGroup, "displayGroup", POST_INPUT_FIELD_TEXT_INFO.couponTitle, title_background_textField_y, post3_textListener)
		post3_title_textField:setPlaceHolderText(localization.getLocalization("post3_title"))
		
		local text_coupon =
		{
			text = localization.getLocalization("post3_coupon"), 
			x = title_background_textField.x-10,
			y = title_background_textField.y+title_background_textField.height/2,
			width = 0,
			height = 0, 
			font = "Helvetica",
			fontSize=30
		}

		text_coupon = display.newText(text_coupon);
		text_coupon:setFillColor( 78/255, 184/255, 229/255)
		text_coupon.anchorX=1
		text_coupon.anchorY=0.5
		displayGroup:insert(text_coupon)
		
		local button_addPhoto = widget.newButton
		{
			
			defaultFile = "Image/RegisterPage/addPhoto.png",
			overFile = "Image/RegisterPage/addPhoto.png",
			onEvent = addPhotoFunction,
		}

		button_addPhoto.x = POST_INPUT_FIELD_TEXT_INFO.couponTitle.x + POST_INPUT_FIELD_TEXT_INFO.couponTitle.width + 20 -- title_background_textField.x+title_background_textField.width+20
		button_addPhoto.y = title_background_textField_y
		button_addPhoto.anchorX = 0
		button_addPhoto.anchorY = 0
		button_addPhoto.savePath = global.post3CouponImage
		displayGroup:insert(button_addPhoto)
		
		---------- checkbox
		local hideResult_checkbox_background_x = title_background_textField.x
		local hideResult_checkbox_background_y = title_background_textField.y+title_background_textField.height+20
		local hideResult_checkbox_background_width_height = 50
		
		local hideResult_checkbox_background = display.newRect( hideResult_checkbox_background_x, hideResult_checkbox_background_y, hideResult_checkbox_background_width_height, hideResult_checkbox_background_width_height )
		hideResult_checkbox_background:setFillColor( 1,1,1 )
		hideResult_checkbox_background.strokeWidth = 2
		hideResult_checkbox_background:setStrokeColor( 0, 0, 0 )
		hideResult_checkbox_background.anchorX = 0
		hideResult_checkbox_background.anchorY = 0
		hideResult_checkbox_background:addEventListener("touch",hideResultCheckboxFnc)
		displayGroup:insert(hideResult_checkbox_background)
		-- blue
		local hideResult_checkbox_background2_x = hideResult_checkbox_background.x+10
		local hideResult_checkbox_background2_y = hideResult_checkbox_background.y+10
		local hideResult_checkbox_background2_width_height = 26
		hideResult_checkbox_background2 = display.newRoundedRect(hideResult_checkbox_background2_x ,hideResult_checkbox_background2_y , hideResult_checkbox_background2_width_height, hideResult_checkbox_background2_width_height,5 )
		hideResult_checkbox_background2:setFillColor( 78/255,184/255,229/255 )
		hideResult_checkbox_background2.strokeWidth = 0
		hideResult_checkbox_background2:setStrokeColor( 0, 0, 0 )
		hideResult_checkbox_background2.anchorX = 0
		hideResult_checkbox_background2.anchorY = 0
		hideResult_checkbox_background2.alpha=0
		displayGroup:insert(hideResult_checkbox_background2)

		local text_hideResult =
		{
			text = localization.getLocalization("post3_hideResult"), 
			x = hideResult_checkbox_background.x+hideResult_checkbox_background.width+20,
			y = hideResult_checkbox_background.y+hideResult_checkbox_background.height/2,
			width = 0,
			height = 0, 
			font = "Helvetica",
			fontSize=30
		}

		text_hideResult = display.newText(text_hideResult);
		text_hideResult:setFillColor( 78/255, 184/255, 229/255)
		text_hideResult.anchorX=0
		text_hideResult.anchorY=0.5
		displayGroup:insert(text_hideResult)
	
	end
	-- filterOption:setDefault(1)--default public
	
	return displayGroup
end


local function scene1_onKeyEvent( event )
	if event.phase == "up" and event.keyName == "back" then
		backLastScene()
	end
	return true
end
local function scene2_onKeyEvent( event )
	if event.phase == "up" and event.keyName == "back" then
		curSceneNum = scrollViewForMultiScene.go(goPreviousSceneOption)
	end
	return true
end
local function scene3_onKeyEvent( event )
	if event.phase == "up" and event.keyName == "back" then
		curSceneNum = scrollViewForMultiScene.go(goPreviousSceneOption)
	end
	return true
end

local function scene1_addKeyEvent()
	hardwareButtonHandler.addCallback(scene1_onKeyEvent)
end
local function scene2_addKeyEvent()
	hardwareButtonHandler.addCallback(scene2_onKeyEvent)
	
end
local function scene3_addKeyEvent()
	hardwareButtonHandler.addCallback(scene3_onKeyEvent)
end
local function scene1_removeKeyEvent()
	hardwareButtonHandler.removeCallback(scene1_onKeyEvent)
end
local function scene2_removeKeyEvent()
	hardwareButtonHandler.removeCallback(scene2_onKeyEvent)
end
local function scene3_removeKeyEvent()
	
	hardwareButtonHandler.removeCallback(scene3_onKeyEvent)
end

-- Create the scene
function scene:createScene( event )
	debugLog( "Creating " .. LOCAL_SETTINGS.NAME .. " Scene")
	display.setStatusBar( display.DefaultStatusBar )
	sceneGroup = self.view
	
	header = headTabFnc.getHeader()
	tabbar = headTabFnc.getTabbar()
	
	display.setDefault("background",243/255,243/255,243/255)

	
	addPhotoFnc.deleteTempImage(global.post1TitleImage)
	addPhotoFnc.deleteTempImage(global.post2ChoiceAImage)
	addPhotoFnc.deleteTempImage(global.post2ChoiceBImage)
	addPhotoFnc.deleteTempImage(global.post2ChoiceCImage)
	addPhotoFnc.deleteTempImage(global.post2ChoiceDImage)
	
	addPhotoFnc.deleteTempImage(global.post3CouponImage)-- coupon image
	
	local scene1 = createScene1()
	local scene2 = createScene2()
	local scene3 = createScene3()

	local sceneData = {
		scene = {
			scene1,
			scene2,
			scene3,
		},
		sceneStartListener = {
			scene1_addKeyEvent,
			scene2_addKeyEvent,
			scene3_addKeyEvent,
		},
		sceneEndListener = {
			scene1_removeKeyEvent,
			scene2_removeKeyEvent,
			scene3_removeKeyEvent,
		}
	}
	local scrollViewData = {
		top = 0,
		left = 0,
		width = display.contentWidth,
		height = display.contentHeight,
		backgroundColor = { 243/255,243/255,243/255 },
		horizontalScrollDisabled = true,
		verticalScrollDisabled = false,
		hideScrollBar = true,
	}
	scrollView = scrollViewForMultiScene.new(scrollViewData,sceneData)
	sceneGroup:insert(scrollView)

	scrollView:setScrollHeight( 1050 )
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
	-- Runtime:addEventListener( "key", onSceneTransitionKeyEvent )

	-- Place the code below
end
function scene:enterScene( event )
	debugLog( "Entering " .. LOCAL_SETTINGS.NAME .. " Scene")
	hardwareButtonHandler.clearAllCallback()
	hardwareButtonHandler.activate()
	-- -- removing key event for scene transition
	-- Runtime:removeEventListener( "key", onSceneTransitionKeyEvent )
	-- adding check system key event
	-- Runtime:addEventListener( "key", onKeyEvent )

	-- remove previous scene's view

	-- Place the code below
end

-- Called when scene is about to move offscreen:
function scene:exitScene()
	debugLog( "Exiting " .. LOCAL_SETTINGS.NAME .. " Scene")
	hardwareButtonHandler.deactivate()
	hardwareButtonHandler.clearAllCallback()
	-- removing check system key event
	-- Runtime:removeEventListener( "key", onKeyEvent )
	scrollViewForMultiScene.removeKeyEvent()
	-- Place the code below
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