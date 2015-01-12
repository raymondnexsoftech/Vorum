---------------------------------------------------------------
-- ProjectSetting.lua
--
-- Project Settinf
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
local localization = require ( "Localization.Localization" )

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local TABBAR_IMAGE_LOC = "Image/Tabbar/"

return {
			tabbar = {
							height = 130,
						    backgroundFile = TABBAR_IMAGE_LOC .. "bg.png",
						    tabSelectedLeftFile = TABBAR_IMAGE_LOC .. "dummy.png",
						    tabSelectedMiddleFile = TABBAR_IMAGE_LOC .. "dummy.png",
						    tabSelectedRightFile = TABBAR_IMAGE_LOC .. "dummy.png",
						    tabSelectedFrameWidth = 1,
						    tabSelectedFrameHeight = 1,
						    buttons = {
										    {
										    	width = 49,
										    	height = 55,
										        defaultFile = TABBAR_IMAGE_LOC .. "meOff.png",
										        overFile = TABBAR_IMAGE_LOC .. "meOn.png",
										        label = localization.getLocalization("me"),
										        id = "me",
										        size = 16,
										        labelYOffset = -8,
										        -- onPress = handleTabBarEvent
										    },
										    {
										    	width = 49,
										    	height = 56,
										        defaultFile = TABBAR_IMAGE_LOC .. "postOff.png",
										        overFile = TABBAR_IMAGE_LOC .. "postOn.png",
										        label = localization.getLocalization("post"),
										        id = "post",
										        size = 16,
										        labelYOffset = -8,
										        -- onPress = handleTabBarEvent
										    },
										    {
										    	width = 97,
										    	height = 100,
										        defaultFile = TABBAR_IMAGE_LOC .. "vorumOff.png",
										        overFile = TABBAR_IMAGE_LOC .. "vorumOn.png",
										        id = "vorum",
										        selected = true,
										        -- onPress = handleTabBarEvent
										    },
										    {
										    	width = 72,
										    	height = 58,
										        defaultFile = TABBAR_IMAGE_LOC .. "noticeOff.png",
										        overFile = TABBAR_IMAGE_LOC .. "noticeOn.png",
										        label = localization.getLocalization("notice"),
										        id = "notice",
										        size = 16,
										        labelYOffset = -8,
										        -- onPress = handleTabBarEvent
										    },
										    {
										    	width = 59,
										    	height = 59,
										        defaultFile = TABBAR_IMAGE_LOC .. "settingOff.png",
										        overFile = TABBAR_IMAGE_LOC .. "settingOn.png",
										        label = localization.getLocalization("setting"),
										        id = "setting",
										        size = 16,
										        labelYOffset = -8,
										        -- onPress = handleTabBarEvent
										    },
										},
						},
		}
