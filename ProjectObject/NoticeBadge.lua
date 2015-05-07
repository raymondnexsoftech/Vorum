---------------------------------------------------------------
-- NoticeBadge.lua
--
-- Notice Badge Setting
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
--local resDir = (...):match("(.-)[^%.]+$")

-- Local Constant Setting
local LOCAL_SETTINGS = {
						RES_DIR = "Image/Tabbar/",		-- Common resource directory for scene
						DOC_DIR = "",					-- Common document directory for scene
						}

---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------
require ( "SystemUtility.Debug" )

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
local badgeGroup

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
local noticeBadge = {}

function noticeBadge.setBadge(parent, number)
	if ((parent ~= nil) and (parent.parent ~= nil)) then
		if (badgeGroup) then
			display.remove(badgeGroup)
			badgeGroup = nil
		end
		if (number > 0) then
			badgeGroup = display.newGroup()
			badgeGroup.x = 490
			badgeGroup.y = 50
			local badgeBg = display.newImage(badgeGroup, LOCAL_SETTINGS.RES_DIR .. "noticeBadge.png", true)
			local badgeNumber
			if (number > 9) then
				badgeNumber = "9+"
			else
				badgeNumber = tostring(number)
			end
			local badgeNumberText = display.newText(badgeGroup, badgeNumber, 0, 0, native.systemFont, 18)
			badgeNumberText.y = 5
			badgeNumberText.y = -2
			parent:insert(badgeGroup)
		end
	end
end

return noticeBadge
