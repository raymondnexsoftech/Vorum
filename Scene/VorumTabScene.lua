---------------------------------------------------------------
-- VorumTabScene.lua
--
-- Scene for Vorum Tab
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
--local resDir = (...):match("(.-)[^%.]+$")

-- Local Constant Setting
local LOCAL_SETTINGS = {
						NAME = "VorumTabScene",			-- Scene name to show in console
						RES_DIR = "",					-- Common resource directory for scene
						DOC_DIR = "",					-- Common document directory for scene
						}

---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------
local storyboard = require ( "storyboard" )
local widget = require ( "widget" )
require ( "DebugUtility.Debug" )
local projectObjectSetting = require( "Setting.ProjectObjectSetting" )
local scrollViewForPost = require( "ProjectObject.ScrollViewForPost" )
local headerView = require( "ProjectObject.HeaderView" )
local headTabFnc = require( "ProjectObject.HeadTabFnc" )

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
--Create a storyboard scene for this module
local scene = storyboard.newScene()

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
-- Function for back button
local function onBackButtonPressed()
end

-- Create the scene
function scene:createScene( event )
	debugLog( "Creating " .. LOCAL_SETTINGS.NAME .. " Scene")
	local group = self.view

	local header = headTabFnc.getHeader()
	local newHeaderGroup, headerHeight = headerView.createHeaderGroup(header, "vorum")
	if (newHeaderGroup) then
		header = headTabFnc.createNewHeader(newHeaderGroup, headerHeight)
	end
	local tabbar = headTabFnc.getTabbar()
	if (tabbar == nil) then
		tabbar = headTabFnc.createNewTabbar(projectObjectSetting.tabbar)
	end
	headTabFnc.setDisplayStatus(true)

	-- testing
	local scrollView
	local function svListener(event)
		headTabFnc.scrollViewCallback(event)
	end

	scrollView = scrollViewForPost.newScrollView{
													left = 0,
													top = 0,
													width = display.contentWidth,
													height = display.contentHeight,
													topPadding = header.headerHeight,
													-- scrollHeight = display.contentHeight * 2,
													horizontalScrollDisabled = true,
													listener = svListener,
													-- postSpace = -50
												}
	local function rectListener(event)
		scrollView:checkFocusToScrollView(event)
		if (event.phase == "ended") then
			local idx = event.target.parent.idx
			local origRowHeight = scrollView:getPost(idx).postCurrentHeight
			if (origRowHeight > 300) then
				scrollView:changePostHeight(idx, 200)
			else
				scrollView:changePostHeight(idx, 400)
			end
		end
		return true
	end

	for i = 0, 10 do
		local group = display.newGroup()
		local rect = display.newRect(group, 0, 0, display.contentHeight, 200)
		rect.anchorX = 0
		rect.anchorY = 0
		rect:setFillColor(i/10, 1-(i/10), 0)
		scrollView:addNewPost(group, 200)
		rect:addEventListener("touch", rectListener)
	end
	-- local svBg = display.newRect(0, 0, display.contentWidth, display.contentHeight)
	-- svBg.anchorX = 0
	-- svBg.anchorY = 0
	-- svBg:setFillColor(0, 1, 0)
	-- scrollView:insert(svBg)
	-- -- local testRect = display.newRect(100, 300, 100, 100)
	-- -- testRect:setFillColor(1, 0, 0)
	-- -- scrollView:insert(testRect)
	-- -- local testRect2 = display.newRect(100, 700, 100, 100)
	-- -- testRect2:setFillColor(1, 1, 0)
	-- -- scrollView:insert(testRect2)
	-- local group1 = display.newGroup()
	-- local testRect = display.newRect(group1, 0, 0, display.contentWidth, 100)
	-- testRect.anchorX = 0
	-- testRect.anchorY = 0
	-- testRect:setFillColor(1, 0, 0)
	-- scrollView:addNewPost(group1, 150)
	-- local group2 = display.newGroup()
	-- local testRect2 = display.newRect(group2, 0, 0, display.contentWidth, 100)
	-- testRect2.anchorX = 0
	-- testRect2.anchorY = 0
	-- testRect2:setFillColor(1, 1, 0)
	-- scrollView:addNewPost(group2, 150)
	-- testRect2:addEventListener("touch", function(event) if (event.phase == "ended") then storyboard.gotoScene("Scene.MeTabScene"); end return true; end)
	-- scrollView:setScrollHeight(display.contentHeight * 2)
	group:insert(scrollView)
end

local function onKeyEvent( event )
	if event.phase == "up" and event.keyName == "back" then
		onBackButtonPressed()
	end
	return true
end

function scene:enterScene( event )
	debugLog( "Entering " .. LOCAL_SETTINGS.NAME .. " Scene")

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

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

---------------------------------------------------------------------------------

return scene