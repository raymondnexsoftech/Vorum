---------------------------------------------------------------
-- HeadTabFnc.lua
--
-- Function of Header and Tab Bar
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
require ( "DebugUtility.Debug" )
local headerFnc = require( "ProjectObject.HeaderFnc" )
local tabbarFnc = require( "ProjectObject.TabbarFnc" )

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
local isTabbarCanHide = true
local isHeadAndTabCanHide = true
local transitionTime = 100

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
local headTabFnc = {}

function headTabFnc.getHeader()
	return headerFnc.getHeader()
end

function headTabFnc.createNewHeader(headerGroup, headerHeight)
	return headerFnc.createNewHeader(headerGroup, headerHeight)
end

function headTabFnc.getTabbar()
	return tabbarFnc.getTabbar()
end

function headTabFnc.createNewTabbar(tabbarOption)
	return tabbarFnc.createNewTabbar(tabbarOption)
end

function headTabFnc.setDisplayStatus(isShow)
	if (isShow) then
		headerFnc.toStablePosition(0, true)
		tabbarFnc.setTabbarOffset(0)
	else
		headerFnc.toStablePosition(0, false)
		tabbarFnc.setTabbarOffset(1)
	end
end

function headTabFnc.setHeadAndTabCanHide(canHide)
	isHeadAndTabCanHide = canHide
	if (isHeadAndTabCanHide ~= true) then
		headerFnc.toStablePosition(0, true)
		tabbarFnc.setTabbarOffset(0)
	end
end

function headTabFnc.setTabbarCanHide(canHide)
	isTabbarCanHide = canHide
	if (isTabbarCanHide ~= true) then
		tabbarFnc.setTabbarOffset(0)
	end
end

function headTabFnc.setTransitionTime(time)
	transitionTime = time
end

local function isScrollViewCannotScroll(scrollView)
	local scrollViewGroup
	if (scrollView.getView) then
		scrollViewGroup = scrollView:getView()
	else
		scrollViewGroup = scrollView
	end
	if (scrollViewGroup._height > scrollViewGroup._scrollHeight) then
		return true
	end
	return false
end

function headTabFnc.checkScrollViewScrollHeight(scrollView)
	if (isScrollViewCannotScroll(scrollView)) then
		headTabFnc.setDisplayStatus(true)
	end
end

function headTabFnc.scrollViewCallback(event)
	if (isHeadAndTabCanHide) then
		-- if (isScrollViewCannotScroll(event.target)) then
		-- 	return
		-- end
		if (event.phase == "began") then
			event.target.htLastY = StartY
			event.target.htLastTime = nil
			event.target.htLastYDiff = 0
			event.target.htLastYSpeed = 0
		end
		if (event.phase == "moved") then
			if (event.target.htLastY) then
				local scrollViewX, scrollViewY = event.target:getContentPosition()
				local scrollViewYLimitPos = event.target:getView()._topPadding
				local delta = event.y - event.target.htLastY
				if (scrollViewY < scrollViewYLimitPos) then
					local lastScrollViewY = scrollViewY - delta
					if (lastScrollViewY >= scrollViewYLimitPos) then
						delta = scrollViewY - scrollViewYLimitPos
					end
					local offset, offsetInPercentage = headerFnc.setHeaderPosDelta(delta)
					if (isTabbarCanHide) then
						tabbarFnc.setTabbarOffset(offsetInPercentage)
					end
				else
					headerFnc.toStablePosition(0, true)
					tabbarFnc.setTabbarOffset(0)
				end
			end
		end
		if ((event.phase == "ended") or (event.phase == "cancelled")) then
			local isHeaderMoveDown = false
			if ((event.target.htLastYDiff ~= nil) and (event.target.htLastYDiff > 0)) then
				isHeaderMoveDown = true
			end
			local transitionDistance, transitionTime = headerFnc.toStablePosition(transitionTime, isHeaderMoveDown)
			if (isTabbarCanHide) then
				if (transitionDistance < -0.0001) then
					tabbarFnc.moveTabbar(1, transitionTime)
				elseif (transitionDistance > 0.0001) then
					tabbarFnc.moveTabbar(0, transitionTime)
				end
			end
			if ((transitionDistance ~= nil) and (transitionDistance ~= 0)) then
				if (math.abs(event.target.htLastYSpeed) < 1) then
					scrollViewX, scrollViewY = event.target:getContentPosition()
					event.target:scrollToPosition{
													y = scrollViewY + transitionDistance,
													time = transitionTime,
												}
				end
			end
		end
		if (event.y) then
			if ((event.target.htLastY) and (event.target.htLastTime)) then
				event.target.htLastYDiff = event.y - event.target.htLastY
				event.target.htLastYSpeed = event.target.htLastYDiff / (event.time - event.target.htLastTime)
			end
			event.target.htLastTime = event.time
			event.target.htLastY = event.y
		end
	end
end

return headTabFnc
