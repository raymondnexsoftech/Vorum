---------------------------------------------------------------
-- FncForLocalization.lua
--
-- Customized function for localization
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
local localization = require("Localization.Localization")
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
local fncForLocalization = {}

function fncForLocalization.getPostCreatedAt(createdAt, lastDiffTime, curTime)
	local locale = localization.getLocale()
	if (curTime == nil) then
		curTime = os.time()
	end
	local createPostTimeStr
	if (createdAt == nil) then
		return nil
	end
	local diffTime = curTime - createdAt
	if (diffTime > 0) then
		if (diffTime < 60) then
			createPostTimeStr = localization.getLocalization("justNow")
		elseif (diffTime < 3600) then
			local minAgo = math.floor(diffTime / 60)
			if (minAgo <= 1) then
				createPostTimeStr = tostring(minAgo) .. localization.getLocalization("minAgo")
			else
				createPostTimeStr = tostring(minAgo) .. localization.getLocalization("minsAgo")
			end
		elseif (diffTime < 86400) then
			local hourAgo = math.floor(diffTime / 3600)
			if (hourAgo <= 1) then
				createPostTimeStr = tostring(hourAgo) .. localization.getLocalization("hourAgo")
			else
				createPostTimeStr = tostring(hourAgo) .. localization.getLocalization("hoursAgo")
			end
		else
			if ((lastDiffTime == nil) or (lastDiffTime < 86400)) then
				if (locale == "zh-Hant") then
					local dateInfo = os.date("*t", createdAt)
					createPostTimeStr = dateInfo.year .. localization.getLocalization("createAtYear")
											.. dateInfo.month .. localization.getLocalization("createAtMonth")
											.. dateInfo.day .. localization.getLocalization("createAtDay")
				else
					createPostTimeStr = os.date("%d %b %Y", createdAt)
				end
			else
				-- No need to update
			end
		end
	else
		createPostTimeStr = localization.getLocalization("justNow")
	end
	return createPostTimeStr, diffTime
end

return fncForLocalization
