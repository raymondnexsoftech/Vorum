---------------------------------------------------------------
-- DayPickerWheel.lua
--
-- Day Picker Wheel
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
local widget = require("widget")

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local SCREEN_RATIO = display.pixelHeight / display.contentHeight
local ROW_HEIGHT = 30 * SCREEN_RATIO
local ROUNDED_RECT_CORNER_RADIUS = 10 * SCREEN_RATIO
local ROUNDED_RECT_STROKE_WIDTH = 4 * SCREEN_RATIO
local FONT_SIZE = ROW_HEIGHT * 0.8
local PICKER_VIEW_COLUMN_INFO = {
									{name = "day", ratio = 0.2},
									{name = "month", ratio = 0.5},
									{name = "year", ratio = 0.3},
								}
local MONTH_DIGIT_TO_WORD = {"January", "February", "March", "April", "May", "June",
								"July", "August", "September", "October", "November", "December"}
local MONTH_NORMAL_LAST_DAY = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
local COLUMN_TRANSITION_TIME = 200

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
local dayPickerWheelArray = {}

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
local dayPickerWheel = {}

local function onRowRender(event)
	local row = event.row

	local rowHeight = row.contentHeight
	local rowWidth = row.contentWidth

	if (type(row.params.text) == "string") then
		local text = display.newText(row, row.params.text, rowWidth * 0.5, rowHeight * 0.5, native.systemFont, row.params.fontSize)
		text:setFillColor(0)
	end
	row.value = row.params.value
end

local function updateColumnBottomPadding(column)
	local columnView = column._view
	local height = columnView._height
	local bottomPadding = -(height - ROW_HEIGHT) * 0.5 + ROW_HEIGHT * (column:getNumRows() - 1)
	if (bottomPadding > (height - ROW_HEIGHT) * 0.5) then
		bottomPadding = (height - ROW_HEIGHT) * 0.5
	end
	columnView._bottomPadding = bottomPadding
end

local function isLeapYearAddOneDay(year, month)
	if (month == 2) then
		if (((year % 4 == 0) and (year % 100 ~= 0)) or (year % 400 == 0)) then
			return 1
		end
	end
	return 0
end

local function compareDate(date1, date2)
	if (date1.year > date2.year) then
		return 1
	elseif (date1.year < date2.year) then
		return -1
	elseif (date1.month > date2.month) then
		return 1
	elseif (date1.month < date2.month) then
		return -1
	elseif (date1.day > date2.day) then
		return 1
	elseif (date1.day < date2.day) then
		return -1
	end
	return 0
end

local function checkNearestRow(column, topPadding, isMoving)
	local nearestRow
	if (isMoving) then
		nearestRow = math.floor((column:getContentPosition() - topPadding) / -ROW_HEIGHT) + 1
	else
		nearestRow = math.floor((column:getContentPosition() - topPadding - (ROW_HEIGHT * 0.5)) / -ROW_HEIGHT) + 1
	end
	if (isMovingUp) then
		nearestRow = nearestRow + 1
	end
	if (nearestRow < 1) then
		return 1
	elseif (nearestRow > column:getNumRows()) then
		return column:getNumRows()
	end
	return nearestRow
end

local function goToRow(column, rowIndex, topPadding, time, onColumnReachPosition)
	if (rowIndex > column:getNumRows()) then
		rowIndex = column:getNumRows()
	end
	column:scrollToY({y = topPadding - (ROW_HEIGHT * (rowIndex - 1)), time = time, onComplete = onColumnReachPosition})
end

local function updatePickerWheelWithDate(columns, startDate, endDate, curDate, topPadding, fontSize)
	if (compareDate(startDate, curDate) > 0) then
		curDate = startDate
	elseif (compareDate(endDate, curDate) < 0) then
		curDate = endDate
	end
	local startMonth = 1
	local endMonth = 12
	local startDay = 1
	local endDay
	local isUpdateMonth, isUpdateDay = false, false
	if (startDate.year == curDate.year) then
		startMonth = startDate.month
		if (startDate.month == curDate.month) then
			startDay = startDate.day
		end
	end
	if (endDate.year == curDate.year) then
		endMonth = endDate.month
		if (endDate.month == curDate.month) then
			endDay = endDate.day
		end
	end
	if (endDay == nil) then
		endDay = MONTH_NORMAL_LAST_DAY[curDate.month] + isLeapYearAddOneDay(curDate.year, curDate.month)
	end
	if ((columns.month.startMonth ~= startMonth) or (columns.month.endMonth ~= endMonth)) then
		columns.month:deleteAllRows()
		for i = startMonth, endMonth do
			columns.month:insertRow{
												rowHeight = ROW_HEIGHT,
												lineColor = {0, 0, 0, 0},
												params = {value = i, text = tostring(MONTH_DIGIT_TO_WORD[i]), fontSize = fontSize}
											}
		end
		columns.month.startMonth = startMonth
		columns.month.endMonth = endMonth
		updateColumnBottomPadding(columns.month)
	end
	if ((columns.day.startDay ~= startDay) or (columns.day.endDay ~= endDay)) then
		columns.day:deleteAllRows()
		for i = startDay, endDay do
			columns.day:insertRow{
												rowHeight = ROW_HEIGHT,
												lineColor = {0, 0, 0, 0},
												params = {value = i, text = tostring(i), fontSize = fontSize}
											}
		end
		columns.day.startDay = startDay
		columns.day.endDay = endDay
		updateColumnBottomPadding(columns.day)
	end
	goToRow(columns.year, curDate.year - startDate.year + 1, topPadding, 0)
	goToRow(columns.month, curDate.month - startMonth + 1, topPadding, 0)
	goToRow(columns.day, curDate.day - startDay + 1, topPadding, 0)
	return curDate
end

local function columnListener(event)
	local targetView = event.target
	if (event.limitReached) then
		if (targetView._view) then
			targetView = targetView._view
		end
		targetView._velocity = 0
		targetView.isLimitReached = true
	end
	if (event.phase == "began") then
		targetView.parent.parent.isNotTouching = false
	elseif (event.phase == "ended") then
		local parentScrollView = targetView
		for i = 1, 3 do
			if (parentScrollView._view) then
				break
			else
				parentScrollView = parentScrollView.parent
			end
			if (parentScrollView == nil) then
				break
			end
		end
		if (parentScrollView) then
			parentScrollView.isNotTouching = true
			parentScrollView.isMoving = (math.abs(parentScrollView._view._velocity) > 0.1)
			parentScrollView.isNeedCheckStopped = true
		end
	end
end

local function enterFrameListener()
	local i = 1
	while (i <= #dayPickerWheelArray) do
		local curPicker = dayPickerWheelArray[i]
		if (curPicker.columns.year.parent == nil) then
			table.remove(dayPickerWheelArray)
		else
			for k, v in pairs(curPicker.columns) do
				if (math.abs(v._view._velocity) > 0.1) then
					v.isNeedCheckStopped = true
				elseif ((v.isNeedCheckStopped) and (v.isNotTouching)) then
					local function onColumnReachPosition()
						local value = {}
						for k2, v2 in pairs(curPicker.columns) do
							local nearestRow = checkNearestRow(v2, curPicker.topPadding)
							value[k2] = v2:getRowAtIndex(nearestRow).value
						end
						value = updatePickerWheelWithDate(curPicker.columns, curPicker.startDate, curPicker.endDate, value, curPicker.topPadding, curPicker.fontSize)
						if (curPicker.listener) then
							curPicker.listener(value)
						end
					end
					if (v._view.isLimitReached) then
						onColumnReachPosition()
						v._view.isLimitReached = nil
					else
						local nearestRow = checkNearestRow(v, curPicker.topPadding, v.isMoving)
						goToRow(v, nearestRow, curPicker.topPadding, COLUMN_TRANSITION_TIME, onColumnReachPosition)
					end
					v.isNeedCheckStopped = false
				end
			end
			i = i + 1
		end
	end
	if (#dayPickerWheelArray <= 0) then
		Runtime:removeEventListener("enterFrame", enterFrameListener)
	end
end

-- dateTable:
-- {
--    startDate: {day = day, month = month, year = year},
--    endDate: {day = day, month = month, year = year},
--    default: {day = day, month = month, year = year},
-- }
-- function dayPickerWheel.show(left, top, width, height[, dateTable][, valueChangedListener])
function dayPickerWheel.show(left, top, width, height, ...)
	local curX = left
	local pickerWheelColumn = {}
	local startDate, endDate, default
	local topPadding = (height - ROW_HEIGHT) * 0.5
	local dateTable, valueChangedListener
	local argIdx = 1
	local greyMask, bg, selectionRect
	if (type(arg[argIdx]) == "table") then
		dateTable = arg[argIdx]
		argIdx = argIdx + 1
	else
		dateTable = {}
	end
	if (type(arg[argIdx]) == "function") then
		valueChangedListener = arg[argIdx]
		-- argIdx = argIdx + 1
	end
	if (dateTable.default) then
		default = {year = dateTable.default.year, month = dateTable.default.month, day = dateTable.default.day}
	else
		default = {year = tonumber(os.date("%Y")), month = 1, day = 1}
	end
	if (dateTable.startDate) then
		startDate = {year = dateTable.startDate.year, month = dateTable.startDate.month, day = dateTable.startDate.day}
	else
		startDate = {year = default.year - 5, month = 1, day = 1}
	end
	if (dateTable.endDate ~= nil) then
		local dateCompareResult = compareDate(dateTable.endDate, default)
		if (dateCompareResult >= 0) then
			endDate = {year = dateTable.endDate.year, month = dateTable.endDate.month, day = dateTable.endDate.day}
		end
	end
	if (endDate == nil) then
		endDate = {year = default.year + 5, month = 12, day = 31}
	end
	if (dateTable.startDate ~= nil) then
		local dateCompareResult = compareDate(dateTable.startDate, default)
		if (dateCompareResult > 0) then
			default = {year = dateTable.startDate.year, month = dateTable.startDate.month, day = dateTable.startDate.day}
		end
	end

	greyMask = display.newRect(display.contentWidth * 0.5, display.contentHeight * 0.5, display.contentWidth, display.contentHeight)
	greyMask:setFillColor(0)
	greyMask.alpha = 0.2
	local function pickerGreyMaskListener(event)
		if (event.phase == "began") then
			display.getCurrentStage():setFocus(event.target)
			event.target.isFocus = true
		elseif (event.target.isFocus) then
			if (event.phase == "ended") then
				display.getCurrentStage():setFocus(nil)
				event.target.isFocus = false
				display.remove(bg)
				display.remove(selectionRect)
				for k, v in pairs(pickerWheelColumn) do
					display.remove(v)
				end
				display.remove(greyMask)
			end
		end
	end
	greyMask:addEventListener("touch", pickerGreyMaskListener)
	bg = display.newRoundedRect(left - ROUNDED_RECT_STROKE_WIDTH, top - ROUNDED_RECT_STROKE_WIDTH, width + ROUNDED_RECT_STROKE_WIDTH * 2, height + ROUNDED_RECT_STROKE_WIDTH * 2, ROUNDED_RECT_CORNER_RADIUS)
	bg.anchorX = 0
	bg.anchorY = 0
	bg.strokeWidth = ROUNDED_RECT_STROKE_WIDTH
	bg:setStrokeColor(0)
	for i = 1, #PICKER_VIEW_COLUMN_INFO do
		local curWidth = PICKER_VIEW_COLUMN_INFO[i].ratio * width
		local newColumn = widget.newTableView{
												left = curX,
												top = top,
												width = curWidth,
												height = height,
												topPadding = topPadding,
												onRowRender = onRowRender,
												rowTouchDelay = 0,
												listener = columnListener,
											}
		newColumn.isNeedCheckStopped = true
		newColumn.isNotTouching = true
		pickerWheelColumn[PICKER_VIEW_COLUMN_INFO[i].name] = newColumn
		curX = curX + curWidth
	end
	local monthColumnWidth
	for i = 1, #PICKER_VIEW_COLUMN_INFO do
		if (PICKER_VIEW_COLUMN_INFO[i].name == "month") then
			monthColumnWidth = width * PICKER_VIEW_COLUMN_INFO[i].ratio
			break
		end
	end
	local fontSize = FONT_SIZE
	while (fontSize > 8) do
		local testingText = display.newText("September", display.contentWidth * 1.5, 0, native.systemFont, fontSize)
		if (monthColumnWidth > testingText.contentWidth) then
			display.remove(testingText)
			break
		end
		fontSize = fontSize - 1
		display.remove(testingText)
	end
	selectionRect = display.newRoundedRect(left - ROUNDED_RECT_STROKE_WIDTH * 0.5, top - ROUNDED_RECT_STROKE_WIDTH * 0.5 + topPadding, width + ROUNDED_RECT_STROKE_WIDTH, ROW_HEIGHT + ROUNDED_RECT_STROKE_WIDTH, ROUNDED_RECT_CORNER_RADIUS)
	selectionRect.anchorX = 0
	selectionRect.anchorY = 0
	selectionRect:setFillColor(0, 0.3, 0.7, 0.2)
	selectionRect.strokeWidth = ROUNDED_RECT_STROKE_WIDTH
	selectionRect:setStrokeColor(0, 0.5, 0.7)
	for i = startDate.year, endDate.year do
		pickerWheelColumn.year:insertRow{
											rowHeight = ROW_HEIGHT,
											lineColor = {0, 0, 0, 0},
											params = {value = i, text = tostring(i), fontSize = fontSize}
										}
	end
	updateColumnBottomPadding(pickerWheelColumn.year)
	if (startDate.year == endDate.year) then
		if (startDate.month >= 12) then
			startDate.month = 12
		end
		if (endDate.month >= 12) then
			endDate.month = 12
		end
		for i = startDate.month, endDate.month do
			pickerWheelColumn.month:insertRow{
												rowHeight = ROW_HEIGHT,
												lineColor = {0, 0, 0, 0},
												params = {value = i, text = tostring(MONTH_DIGIT_TO_WORD[i]), fontSize = fontSize}
											}
		end
		pickerWheelColumn.month.startMonth = startDate.month
		pickerWheelColumn.month.endMonth = endDate.month
		updateColumnBottomPadding(pickerWheelColumn.month)
		if (startDate.month == endDate.month) then
			local monthMaxDay = MONTH_NORMAL_LAST_DAY[endDate.month]
			monthMaxDay = monthMaxDay + isLeapYearAddOneDay(startDate.year, startDate.month)
			if (startDate.day >= monthMaxDay) then
				startDate.day = monthMaxDay
			end
			if (endDate.day >= monthMaxDay) then
				endDate.day = monthMaxDay
			end
			for i = startDate.day, endDate.day do
				pickerWheelColumn.day:insertRow{
													rowHeight = ROW_HEIGHT,
													lineColor = {0, 0, 0, 0},
													params = {value = i, text = tostring(i), fontSize = fontSize}
												}
			end
			pickerWheelColumn.day.startDay = startDate.day
			pickerWheelColumn.day.endDay = endDate.day
			updateColumnBottomPadding(pickerWheelColumn.day)
		end
	end
	updatePickerWheelWithDate(pickerWheelColumn, startDate, endDate, default, topPadding, fontSize)
	timer.performWithDelay(1, function()
									dayPickerWheelArray[#dayPickerWheelArray + 1] = {
																						columns = pickerWheelColumn,
																						startDate = startDate,
																						endDate = endDate,
																						topPadding = topPadding,
																						fontSize = fontSize,
																						listener = valueChangedListener,
																					}
									Runtime:removeEventListener("enterFrame", enterFrameListener)
									Runtime:addEventListener("enterFrame", enterFrameListener)
								end, 1)
end

return dayPickerWheel

-- Usage:
-- local pickerWheel = require("ProjectObject.DayPickerWheel")
-- local function changedListener(value)
-- 	for k, v in pairs(value) do
-- 		print(k, v)
-- 	end
-- end
-- local date =
-- {
-- 	-- startDate = {day = 2, month = 3, year = 2014},
-- 	-- endDate = {day = 3, month = 4, year = 2016},
-- 	-- default = {day = 2, month = 2, year = 2015},
-- 	startDate = {day = 2, month = 1, year = 2015},
-- 	endDate = {day = 3, month = 4, year = 2015},
-- 	default = {day = 5, month = 3, year = 2015},
-- 	-- startDate = {day = 3, month = 1, year = 2015},
-- 	-- endDate = {day = 20, month = 1, year = 2015},
-- 	-- default = {day = 7, month = 1, year = 2015},
-- }
-- pickerWheel.show(0, 200, display.contentWidth, 300, date, changedListener)


