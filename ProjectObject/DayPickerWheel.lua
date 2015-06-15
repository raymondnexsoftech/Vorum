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
local ROW_HEIGHT = 30 * display.pixelHeight / display.contentHeight
local PICKER_VIEW_COLUMN_INFO = {
									{name = "day", ratio = 0.1},
									{name = "month", ratio = 0.55},
									{name = "year", ratio = 0.35},
								}
local MONTH_DIGIT_TO_WORD = {"January", "February", "March", "April", "May", "June",
								"July", "August", "September", "November", "December"}
local MONTH_NORMAL_LAST_DAY = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------

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

	if (type(params.text) == "string") then
		local text = display.newText(row, params.text, rowWidth * 0.5, rowHeight * 0.5, native.systemFont, ROW_HEIGHT)
		text:setFillColor(0)
	end
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

local function updatePickerWheelWithDate(columns, startDate, endDate, curDate)
	if (compareDate(startDate, curDate) > 0) then
		curDate = StartDate
	elseif (compareDate(endDate, curDate) < 0) then
		curDate = endDate
	end
	local isKeepCheckingDate = true
	-- if (startDate.year ~= endDate.year) then
	-- end
	-- if (curDate.year == startDate.year) then
	-- 	columns.month:deleteAllRows()
	-- 	for i = 1, startDate.month do
	-- 		columns.month:insertRow{
	-- 									rowHeight = ROW_HEIGHT,
	-- 									lineColor = {0, 0, 0, 0},
	-- 									params = {text = toString(MONTH_DIGIT_TO_WORD[i])}
	-- 								}
	-- 	end
	-- 	if (curDate.month == startDate.month) then
	-- 	end

	-- end
end

-- dateTable:
-- {
--    startDate: {day = day, month = month, year = year},
--    endDate: {day = day, month = month, year = year},
--    default: {day = day, month = month, year = year},
-- }
function dayPickerWheel.show(left, top, width, height, dateTable)
	local bg = display.newRect(display.contentWidth * 0.5, display.contentHeight * 0.5, display.contentWidth, display.contentHeight)
	bg:setFillColor(0)
	bg.alpha = 0.2
	local curX = left
	local pickerWheelColumn = {}
	local startDate, endDate, default
	if (dateTable.startDate) then
		startDate = {year = dateTable.endDate.year, month = dateTable.endDate.month, day = dateTable.endDate.day}
	else
		startDate = {year = os.date("%Y") - 5, month = 1, day = 1}
	end
	if ((dateTable.endDate ~= nil) and (dateTable.default ~= nil)) then
		local dateCompareResult = compareDate(dateTable.endDate, dateTable.default)
		if (dateCompareResult >= 0) then
			endDate = {year = dateTable.endDate.year, month = dateTable.endDate.month, day = dateTable.endDate.day}
		end
	end
	if (endDate == nil) then
		endDate = {year = os.date("%Y") + 5, month = 12, day = 31}
	end
	if ((dateTable.startDate ~= nil) and (dateTable.default ~= nil)) then
		local dateCompareResult = compareDate(dateTable.startDate, dateTable.default)
		if (dateCompareResult <= 0) then
			default = {year = dateTable.endDate.year, month = dateTable.endDate.month, day = dateTable.endDate.day}
		end
	end
	if (default == nil) then
		default = {year = startDate.year, month = startDate.month, day = startDate.day}
	end
	for i = 1, #PICKER_VIEW_COLUMN_INFO do
		local curWidth = PICKER_VIEW_COLUMN_INFO[i].ratio * width
		pickerWheelColumn[PICKER_VIEW_COLUMN_INFO[i].name] = widget.newTableView{
													left = curX,
													top = top,
													width = curWidth,
													height = height,
													topPadding = (height - ROW_HEIGHT) * 0.5,
													onRowRender = onRowRender,
												}
		curX = curX + curWidth
	end
	for i = startDate.year, endDate.year do
		pickerWheelColumn.year:insertRow{
											rowHeight = ROW_HEIGHT,
											lineColor = {0, 0, 0, 0},
											params = {text = toString(i)}
										}
	end
	if (startDate.year == endDate.year) then
		if (startDate.month <= 12) then
			startDate.month = 12
		end
		if (endDate.month <= 12) then
			endDate.month = 12
		end
		for i = startDate.month, endDate.month do
			pickerWheelColumn.year:insertRow{
												rowHeight = ROW_HEIGHT,
												lineColor = {0, 0, 0, 0},
												params = {text = toString(MONTH_DIGIT_TO_WORD[i])}
											}
		end
		if (startDate.month == endDate.month) then
			local monthMaxDay = MONTH_NORMAL_LAST_DAY[endDate.month]
			-- TODO: calculate leap
			if ((startDate.year % 4 == 0) and (startDate.month == 2)) then
				monthMaxDay = monthMaxDay + 1
			end
			if (startDate.day <= monthMaxDay) then
				startDate.day = monthMaxDay
			end
			if (endDate.day <= monthMaxDay) then
				endDate.day = monthMaxDay
			end
			for i = startDate.day, endDate.day do
				pickerWheelColumn.year:insertRow{
													rowHeight = ROW_HEIGHT,
													lineColor = {0, 0, 0, 0},
													params = {text = toString(MONTH_DIGIT_TO_WORD[i])}
												}
			end
		end
	end
	updatePickerWheelWithDate(pickerWheelColumn, startDate, endDate, default)
end

		-- for k, v in pairs(pickerWheelColumn[i]._view) do
		-- 	print(k, v)
		-- end
		-- print("====")


return dayPickerWheel
