---------------------------------------------------------------
-- CustomSpinner.lua
--
-- Custom Spinner
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
local resDir = (...):match("(.-)[^%.]+$")
local resPath = string.gsub(resDir, "%.", "/")

-- Local Constant Setting
local LOCAL_SETTINGS = {
						RES_DIR = "",					-- Common resource directory for scene
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

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
local customSpinner = {}

function customSpinner.new(size, time)
	if (time == nil) then
		if (size == nil) then
			size = 300
		end
		time = 100
	end
	
	local customSpinnerImg = display.newImageRect(resPath .. "CustomSpinner.png", size, size)

	if (customSpinnerImg) then
		local function timerFnc()
			if (customSpinnerImg.parent == nil) then
				timer.cancel(customSpinnerImg.spinTimer)
				customSpinnerImg.spinTimer = nil
				return
			end
			if (customSpinnerImg.rotation >= 360) then
				customSpinnerImg.rotation = customSpinnerImg.rotation - 360
			end
			customSpinnerImg.rotation = customSpinnerImg.rotation + 30
		end

		customSpinnerImg.spinTimer = timer.performWithDelay(time, timerFnc, 0)
	end
	return customSpinnerImg
end

return customSpinner
