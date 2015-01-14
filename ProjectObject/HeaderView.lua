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
require ( "DebugUtility.Debug" )

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

local function createVorumHeaderGroup(headerGroup, headerHeight)
	headerDisplayGroup = display.newGroup()
	local vorumLogo = display.newImage(headerDisplayGroup, LOCAL_SETTINGS.RES_DIR .. "vorum.png", true)
	vorumLogo.anchorY = 1
	vorumLogo.x = display.contentWidth * 0.5
	vorumLogo.y = headerHeight - 15
	local categoryIcon = display.newImage(headerDisplayGroup, LOCAL_SETTINGS.RES_DIR .. "category.png", true)
	categoryIcon.anchorX = 0
	categoryIcon.anchorY = 1
	categoryIcon.x = 15
	categoryIcon.y = headerHeight - 15
	local searchIcon = display.newImage(headerDisplayGroup, LOCAL_SETTINGS.RES_DIR .. "search.png", true)
	searchIcon.anchorX = 1
	searchIcon.anchorY = 1
	searchIcon.x = display.contentWidth - 15
	searchIcon.y = headerHeight - 15
	return headerDisplayGroup
end

function headerView.createHeaderGroup(currentHeader, headerId)
	if ((currentHeader ~= nil) and (currentHeader.id == headerId)) then
		return nil
	end
	local headerGroup = display.newGroup()
	local headerBg = display.newImage(headerGroup, LOCAL_SETTINGS.RES_DIR .. "bg.png", true)
	headerBg.anchorX = 0
	headerBg.anchorY = 0
	headerBg.x = 0
	headerBg.y = 0
	local headerDisplayGroup
	if (headerId == "vorum") then
		headerDisplayGroup = createVorumHeaderGroup(headerGroup, headerBg.contentHeight)
	end
	if (headerDisplayGroup) then
		headerGroup:insert(headerDisplayGroup)
		headerGroup.headerDisplayGroup = headerDisplayGroup
		headerGroup.id = headerId
	end
	return headerGroup, headerBg.contentHeight
end

return headerView
