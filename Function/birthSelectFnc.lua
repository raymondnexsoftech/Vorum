local widget = require( "widget" )
local localization = require("Localization.Localization")
local returnGroup = display.newGroup()
-- Create two tables to hold data for days and years 

local function get_days_in_month(month, year)
  local days_in_month = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }   
  local d = days_in_month[month]
 
  -- check for leap year
  if (month == 2) then
    if (math.mod(year,4) == 0) then
     if (math.mod(year,100) == 0)then                
      if (math.mod(year,400) == 0) then                    
          d = 29
      end
     else                
      d = 29
     end
    end
  end

  return d  
end


function returnGroup.birthdaySelection(event,year,month,day,updateFnc,scrollView)
	local returnGroup2 = display.newGroup()
	local timerRunFnc
	local pickerWheel
	local close_button
	local nowTime = os.date('*t')
	
	local days = {}
	local months = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }
	local years = {}

	-- Populate the "days" table
	for d = 1, 31 do
		days[d] = d
	end

	-- Populate the "years" table
	for y = 1, nowTime.year-1900 do
		years[y] = 1900 + y
	end


	local yearIndex = 1
	local monthIndex = 1
	local dayIndex = 1
	
	for i = 1,#years do
		if year == years[i] then
			yearIndex = i
			break
		end
	end

	for i = 1,#months do
		if month == months[i] then
			monthIndex = i
			break
		end
	end
	
	for i = 1,#days do
		if day == days[i] then
			dayIndex = i
			break
		end
	end
	
	-- print(year,month,day)
	-- print(yearIndex,monthIndex,dayIndex)
	
	local function closeFnc()
		local values = pickerWheel:getValues()
		local currentDay
		local currentMonth
		local currentYear
		local totalDaysOfMon
		local numMonth
		nowTime = os.date('*t')
		
		if(values)then
			if(values[1].value)then
				currentDay = values[1].value
				if(values[2].value)then
					currentMonth = values[2].value
					if(values[3].value)then
						currentYear = values[3].value
						for i =1,#months do
							if(currentMonth==months[i])then
								numMonth = i
								break
							end
						end
						print(nowTime.year,nowTime.month,nowTime.day)
						print(currentYear,numMonth,currentDay)
						if((tonumber(currentYear)>tonumber(nowTime.year))or(tonumber(currentYear)>=tonumber(nowTime.year)and tonumber(numMonth)>tonumber(nowTime.month))or(tonumber(currentYear)>=tonumber(nowTime.year)and tonumber(numMonth)>=tonumber(nowTime.month) and tonumber(currentDay)>tonumber(nowTime.day)))then
							native.showAlert(localization.getLocalization("birthdayError_title"),localization.getLocalization("birthdayError_overNow"),{localization.getLocalization("ok")})
							return false
						end
						totalDaysOfMon = get_days_in_month(tonumber(numMonth), tonumber(currentYear))
						if(totalDaysOfMon)then
							if(tonumber(currentDay)>tonumber(totalDaysOfMon))then
								currentDay = totalDaysOfMon
								native.showAlert(localization.getLocalization("birthdayError_title"),localization.getLocalization("birthdayError_noThatDay"),{localization.getLocalization("ok")})
								return false
							end
						end
						print("birday",totalDaysOfMon,currentDay,numMonth)
						updateFnc(currentYear,currentMonth,currentDay)
					end
				end
			end
		end
		if(scrollView)then
			scrollView:setIsLocked( false, "vertical" )--unlocked
		end
		timer.cancel(timerRunFnc)
		display.remove(returnGroup2)
		returnGroup2=nil
	end
	
	local function backgronud_touch(event)
		if(event.phase=="ended" or event.phase=="cancelled")then
			closeFnc()
		end
		return true
	end
	
	local background = display.newRect( 0, 0, display.contentWidth, display.contentHeight*2 )
	background:setFillColor( 0.5 )
	background.anchorX = 0
	background.anchorY = 0.5
	background.alpha = 0.5
	background:addEventListener("touch",backgronud_touch)
	returnGroup2:insert(background)
	
	local columnData = 
	{
		-- Days
		{
			align = "center",
			width = 60,
			startIndex = dayIndex,
			labels = days
		},
		-- Months
		{ 
			align = "center",
			width = 140,
			startIndex = monthIndex,
			labels = months
		},
		
		-- Years
		{
			align = "center",
			width = 80,
			startIndex = yearIndex,
			labels = years
		}
	}

	-- Create the widget
	pickerWheel = widget.newPickerWheel
	{
		y = event.target.y,
		x = event.target.x+event.target.width/2,
		columns = columnData
	}
	pickerWheel.anchorX=0.5
	pickerWheel.anchorY=0

	returnGroup2:insert(pickerWheel)
	
	local function returnData()
		local values = pickerWheel:getValues()
		local currentDay
		local currentMonth
		local currentYear
		
		if(values)then
			if(values[1].value)then
				currentDay = values[1].value
				if(values[2].value)then
					currentMonth = values[2].value
					if(values[3].value)then
						currentYear = values[3].value
						updateFnc(currentYear,currentMonth,currentDay)
					end
				end
			end
		end
	end
	timerRunFnc = timer.performWithDelay( 200, returnData,0 )
	

	close_button = widget.newButton
	{
		id = "exit_button",
		defaultFile = "Image/LoginPage/exit.png",
		overFile = "Image/LoginPage/exit.png",
		onEvent=backgronud_touch
	}
	close_button.x = event.target.x+event.target.width-1
	close_button.y = event.target.y-15
	close_button.anchorX=1
	close_button.anchorY=0	
	
	if(scrollView)then
		-- local curPosX 
		-- local curPosY
		-- curPosX,curPosY = scrollView:getContentPosition()
		-- pickerWheel.y = pickerWheel.y+curPosY
		-- close_button.y = close_button.y+curPosY
		-- print("AAA",curPosY,pickerWheel.y,close_button.y)
		scrollView:setIsLocked( true, "vertical" )--locked
	end
	
	returnGroup2:insert(close_button)
	return returnGroup2
end
function returnGroup.loadData(dobString,updateFnc)
	local months = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }
	if(not dobString)then
		return false
	end
	local dataYear = tonumber(string.sub(dobString,1,4))
	local dataMon  = tonumber(string.sub(dobString,6,7))
	local dataDay  = tonumber(string.sub(dobString,9,10))
	if (dataMon == 0) then
		return false
	end
	local stringMon = months[dataMon]
	
	updateFnc(dataYear,stringMon,dataDay)
end
return returnGroup