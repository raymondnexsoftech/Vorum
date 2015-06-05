---------------------------------------------------------------
-- HeaderView.lua
--
-- File To Create views in Header
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
--local resDir = (...):match("(.-)[^%.]+$")

-- Local Constant Setting
local LOCAL_SETTINGS = {
						RES_DIR = "Image/Header/",		-- Common resource directory for scene
						DOC_DIR = "",					-- Common document directory for scene
						}

---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------
local storyboard = require ( "storyboard" )
local headTabFnc = require( "ProjectObject.HeadTabFnc" )
require ( "SystemUtility.Debug" )
local localization = require("Localization.Localization")
local catScreen = require("ProjectObject.CatScreen")
local searchScreen = require("ProjectObject.SearchScreen")
local global = require( "GlobalVar.global" )
---------------------------------------------------------------
-- Constants
---------------------------------------------------------------

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------

local headerView = {}

-- category
	
function headerView.categoryButtonCreation()
	local function catScreenDisplay(event)
		if(event.phase=="ended" or event.phase=="cancelled")then
			catScreen.catScreenDisplay()
		end
		return true
	end
	local categoryButton = display.newImage(LOCAL_SETTINGS.RES_DIR .. "category.png", true)
	categoryButton:addEventListener("touch",catScreenDisplay)
	return categoryButton
end

function headerView.searchButtonCreation(sceneOptions,sceneData,headerCreateFnc)
	-- search 
	local function searchScreenDisplay(event)
		if(event.phase=="ended" or event.phase=="cancelled")then
			searchScreen.searchScreenDisplay(sceneOptions,sceneData,headerCreateFnc)
		end
		return true
	end
	local searchButton = display.newImage(LOCAL_SETTINGS.RES_DIR .. "search.png", true)
	searchButton:addEventListener("touch",searchScreenDisplay)
	return searchButton
end
--


local function gotoSettingScene(event)
	if(event.phase=="ended" or event.phase=="cancelled")then
		storyboard.gotoScene("Scene.SettingTabScene", global.backSceneOption)
	end
	return true
end
function headerView.backToSettingButtonCreation()
	local backButton = display.newImage(LOCAL_SETTINGS.RES_DIR .. "back.png", true)
	backButton:addEventListener("touch",gotoSettingScene)
	return backButton
end
local function checkHeaderBaseExist()
	local header = headTabFnc.getHeader()
	if (header == nil) then
		local headerBg = display.newImage("Image/Header/bg.png")
		-- headerBg.alpha = 0.3
		header = headTabFnc.createNewHeader(headerBg)
	end
end

function headerView.createVorumHeaderObjects(titleObject)
	
	checkHeaderBaseExist()
	local headerObjects = {}
	if (titleObject=="main") then
		
	elseif(titleObject=="notice") then
		headerObjects.title =
		{
			text = localization.getLocalization("notice_headerTitle"), 
			font = "Helvetica",
			fontSize=40
		}
		headerObjects.title = display.newText(headerObjects.title)
		headerObjects.title:setFillColor( 78/255, 184/255, 229/255)
		headerObjects.leftButton = nil
		headerObjects.rightButton = nil
	elseif(titleObject=="setting") then
		headerObjects.title =
		{
			text = localization.getLocalization("setting_headerTitle"), 
			font = "Helvetica",
			fontSize=40
		}
		headerObjects.title = display.newText(headerObjects.title)
		headerObjects.title:setFillColor( 78/255, 184/255, 229/255)
		headerObjects.leftButton = nil
		headerObjects.rightButton = nil
	elseif(titleObject=="contact")then
		headerObjects.title =
		{
			text = localization.getLocalization("contact_headerTitle"), 
			font = "Helvetica",
			fontSize=40
		}
		headerObjects.title = display.newText(headerObjects.title)
		headerObjects.title:setFillColor( 78/255, 184/255, 229/255)
		headerObjects.leftButton = headerView.backToSettingButtonCreation()
		headerObjects.rightButton = nil
	elseif(titleObject=="redemption")then
		headerObjects.title =
		{
			text = localization.getLocalization("redemption_headerTitle"), 
			font = "Helvetica",
			fontSize=40
		}
		headerObjects.title = display.newText(headerObjects.title)
		headerObjects.title:setFillColor( 78/255, 184/255, 229/255)
		headerObjects.leftButton = headerView.backToSettingButtonCreation()
		headerObjects.rightButton = nil
	elseif(titleObject=="coupon")then
		headerObjects.title =
		{
			text = localization.getLocalization("coupon_headerTitle"), 
			font = "Helvetica",
			fontSize=40
		}
		headerObjects.title = display.newText(headerObjects.title)
		headerObjects.title:setFillColor( 78/255, 184/255, 229/255)
		headerObjects.leftButton = display.newImage(LOCAL_SETTINGS.RES_DIR .. "back.png", true)
		headerObjects.leftButton:addEventListener("touch",function(event)
																if(event.phase=="ended" or event.phase=="cancelled")then
																	local sceneOption = {
																							effect = "slideRight",
																							time = 400,
																						}
																	storyboard.gotoScene("Scene.RedemptionScene", sceneOption)
																end
																return true
															end)
		headerObjects.rightButton = nil
	elseif(titleObject=="aboutVorum")then
		headerObjects.title =
		{
			text = localization.getLocalization("aboutVorum_headerTitle"), 
			font = "Helvetica",
			fontSize=40
		}
		headerObjects.title = display.newText(headerObjects.title)
		headerObjects.title:setFillColor( 78/255, 184/255, 229/255)
		headerObjects.leftButton = headerView.backToSettingButtonCreation()
		headerObjects.rightButton = nil
	end
	
	if(headerObjects.title)then
		headerObjects.title.isHitTestable = true
	end
	if(headerObjects.leftButton)then
		headerObjects.leftButton.isHitTestable = true
	end
	if(headerObjects.rightButton)then
		headerObjects.rightButton.isHitTestable = true
	end
	return headerObjects
end

-- local function createVorumHeaderGroup(headerGroup, headerHeight)
-- 	headerDisplayGroup = display.newGroup()
-- 	local vorumLogo = display.newImage(headerDisplayGroup, LOCAL_SETTINGS.RES_DIR .. "vorum.png", true)
-- 	vorumLogo.anchorY = 1
-- 	vorumLogo.x = display.contentWidth * 0.5
-- 	vorumLogo.y = headerHeight - 15
-- 	local categoryIcon = display.newImage(headerDisplayGroup, LOCAL_SETTINGS.RES_DIR .. "category.png", true)
-- 	categoryIcon.anchorX = 0
-- 	categoryIcon.anchorY = 1
-- 	categoryIcon.x = 15
-- 	categoryIcon.y = headerHeight - 15
-- 	local searchIcon = display.newImage(headerDisplayGroup, LOCAL_SETTINGS.RES_DIR .. "search.png", true)
-- 	searchIcon.anchorX = 1
-- 	searchIcon.anchorY = 1
-- 	searchIcon.x = display.contentWidth - 15
-- 	searchIcon.y = headerHeight - 15
-- 	return headerDisplayGroup
-- end

-- function headerView.createHeaderGroup(currentHeader, headerId)
-- 	if ((currentHeader ~= nil) and (currentHeader.id == headerId)) then
-- 		return nil
-- 	end
-- 	local headerGroup = display.newGroup()
-- 	local headerBg = display.newImage(headerGroup, LOCAL_SETTINGS.RES_DIR .. "bg.png", true)
-- 	headerBg.anchorX = 0
-- 	headerBg.anchorY = 0
-- 	headerBg.x = 0
-- 	headerBg.y = 0
-- 	local headerDisplayGroup
-- 	if (headerId == "vorum") then
-- 		headerDisplayGroup = createVorumHeaderGroup(headerGroup, headerBg.contentHeight)
-- 	end
-- 	if (headerDisplayGroup) then
-- 		headerGroup:insert(headerDisplayGroup)
-- 		headerGroup.headerDisplayGroup = headerDisplayGroup
-- 		headerGroup.id = headerId
-- 	end
-- 	return headerGroup, headerBg.contentHeight
-- end

return headerView
