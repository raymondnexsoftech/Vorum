local returnGroup = {}

function returnGroup.toString(dobData)
	
	local createdTime_array = {}
	local returnString = ""
	
	createdTime_array.year = string.sub(dobData, 1,4)
	createdTime_array.month = string.sub(dobData, 6,7)
	createdTime_array.day = string.sub(dobData, 9,10)
	
	createdTime_array.hour = string.sub(dobData, 12,13)
	createdTime_array.min = string.sub(dobData, 15,16)
	createdTime_array.sec = string.sub(dobData, 18,19)
	createdTime_array.ms = string.sub(dobData, 21,23)
	
	returnString = returnString..createdTime_array.year.."_"
	returnString = returnString..createdTime_array.month.."_"
	returnString = returnString..createdTime_array.day.."_"
	returnString = returnString..createdTime_array.hour.."_"
	returnString = returnString..createdTime_array.min.."_"
	returnString = returnString..createdTime_array.sec.."_"
	returnString = returnString..createdTime_array.ms
	return returnString
end

return returnGroup