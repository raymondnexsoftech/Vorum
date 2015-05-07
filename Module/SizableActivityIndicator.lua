---------------------------------------------------------------
-- SizableActivityIndicator.lua
--
-- Sizable activity indicator
---------------------------------------------------------------

-- Local Constant Setting
local LOCAL_SETTINGS = {
						RES_DIR = "",					-- Common resource directory for scene
						DOC_DIR = "",					-- Common document directory for scene
						}

---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------
local widget = require("widget")

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
local sizableActivityIndicatorFnc = {}

local function activityIndicatorTouchEvent(event)
	return true
end

local function copyTable(origTable)
	local newTable
	if (type(origTable) == "table") then
		newTable = {}
		for k, v in pairs(origTable) do
			newTable[k] = copyTable(origTable[k])
		end
	else
		newTable = origTable
	end
	return newTable
end

function sizableActivityIndicatorFnc.newActivityIndicator(...)
	local argIndex = 1
	local parent = nil
	local width, height = display.contentWidth, display.contentHeight
	if (type(arg[argIndex]) == "table") then
		parent = arg[argIndex]
		argIndex = argIndex + 1
	end
	if (type(arg[argIndex]) == "number") then
		width = arg[argIndex]
		argIndex = argIndex + 1
	end
	if (type(arg[argIndex]) == "number") then
		height = arg[argIndex]
		argIndex = argIndex + 1
	end
	if (argIndex == 1) then
		return nil				-- no correct argument, not create object
	end
	local group = display.newGroup()
	rawset(group, "_anchorX", 0)
	rawset(group, "_anchorY", 0)
--	group.anchorX = 0.5
--	group.anchorY = 0.5
	local origMetatable = getmetatable(group)
	local newMetatable = copyTable(origMetatable)
	local origMtIndex = origMetatable.__index
	local origMtNewIndex = origMetatable.__newindex
	newMetatable.__index = function(t, k)
							if (k == "x") then
								return origMtIndex(t, "x") + rawget(t, "_anchorX") * t.bg.contentWidth
							elseif (k == "y") then
								return origMtIndex(t, "y") + rawget(t, "_anchorY") * t.bg.contentHeight
							elseif (k == "anchorX") then
								return rawget(t, "_anchorX")
							elseif (k == "anchorY") then
								return rawget(t, "_anchorY")
							end
							return origMtIndex(t, k)
						end
	newMetatable.__newindex = function(t, k, v)
								if (k == "x") then
									local newX = v - (t.anchorX * t.bg.contentWidth)
									origMtNewIndex(t, k, newX)
								elseif (k == "y") then
									local newY = v - (t.anchorY * t.bg.contentHeight)
									origMtNewIndex(t, k, newY)
								elseif (k == "anchorX") then
									if (v > 1) then
										v = 1
									elseif (v < 0) then
										v = 0
									end
									local newX = t.x - (v * t.bg.contentWidth)
									origMtNewIndex(t, "x", newX)
									rawset(t, "_anchorX", v)
								elseif (k == "anchorY") then
									if (v > 1) then
										v = 1
									elseif (v < 0) then
										v = 0
									end
									local newY = t.y - (v * t.bg.contentHeight)
									origMtNewIndex(t, "y", newY)
									rawset(t, "_anchorY", v)
								else
									origMtNewIndex(t, k, v)
								end
							end
	setmetatable(group, newMetatable)
	
	
	group:addEventListener("touch", activityIndicatorTouchEvent)
	group.bg = display.newRect(group, 0, 0, width, height)
	group.bg.anchorX = 0
	group.bg.anchorY = 0
	group.bg:setFillColor(0, 0, 0, 0.5)
	local spinnerSize = width
	if (height < width) then
		spinnerSize = height
	end
	if (spinnerSize > 80) then
		spinnerSize = 80
	end
	group.spinner = widget.newSpinner{
										width = spinnerSize,
										height = spinnerSize,
										deltaAngle = 30,
										incrementEvery = 100
										}
	group.spinner.x = width / 2
	group.spinner.y = height / 2
	group:insert(group.spinner)
	group.isVisible = false
	group.anchorX = 0.5
	group.anchorY = 0.5

	function group:setBgColor(color)
		if(type(color)=="string")then
			color = tonumber(color)
		end

		if(type(color)=="table")then
			group.bg:setFillColor(unpack(color))
		elseif(type(color)=="number")then
			group.bg:setFillColor(color)
		end
	end

	function group:setEnable(en)
		if (en == true) then
			if (group.isVisible == false) then
				group.isVisible = true
				group:toFront()
				group.spinner:start()
			end
		else
			if (group.isVisible == true) then
				group.isVisible = false
				group.spinner:stop()
			end
		end
	end

	return group
end

return sizableActivityIndicatorFnc
