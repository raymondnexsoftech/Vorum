---------------------------------------------------------------
-- TabbarFnc.lua
--
-- Tab Bar Function
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
local widget = require ( "widget" )

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
local tabbarObject = nil

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
local tabbarFnc = {}

function tabbarFnc.resetPosition()
end

function tabbarFnc.createNewTabbar(tabbarOption)
	if (tabbarObject) then
		display.remove(tabbarObject)
	end
	local option = {}
	for k, v in pairs(tabbarOption) do
		option[k] = v
	end
	option.width = display.contentWidth
	option.left = 0
	if (option.buttons) then
		local tabbarHeight = -1
		if (option.height) then
			tabbarHeight = option.height
		end
		for i = 1, #option.buttons do
			if ((option.buttons[i].height ~= nil) and (option.buttons[i].height > tabbarHeight)) then
				tabbarHeight = option.buttons[i].height
			end
		end
		if (tabbarHeight > 0) then
			option.height = tabbarHeight
		end
	end
	tabbarObject = widget.newTabBar(option)
	tabbarObject.anchorY = 1
	tabbarObject.y = display.contentHeight
	return tabbarObject
end

function tabbarFnc.getTabbar()
	return tabbarObject
end

return tabbarFnc
