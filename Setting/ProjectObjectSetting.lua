---------------------------------------------------------------
-- ProjectObjectSetting.lua
--
-- Project Object Setting
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
local storyboard = require ( "storyboard" )
local headTabFnc = require( "ProjectObject.HeadTabFnc" )
local global = require( "GlobalVar.global" )
---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local TABBAR_IMAGE_LOC = "Image/Tabbar/"

-- local 
local sceneOption = {}
sceneOption.effect = "fromBottom"
sceneOption.time = 400

local function goToMeTabSceneFnc(event)
	storyboard.gotoScene("Scene.MeTabScene")
	global.currentSceneNumber = 1
end
local function goToPostTabSceneFnc(event)
	local header = headTabFnc.getHeader()
	local tabbar = headTabFnc.getTabbar()
	local curSceneName = storyboard.getCurrentSceneName()
	local curScene = storyboard.getScene( curSceneName )
	
	curScene.view:insert(header)
	curScene.view:insert(tabbar)

	local options =
	{
		effect = "fromBottom",
		time = 400,
		isModal = true,
	}
	
	storyboard.showOverlay( "Scene.PostTabScene", options )
	
end
local function goToVorumTabSceneFnc(event)
	storyboard.gotoScene("Scene.VorumTabScene")
	global.currentSceneNumber = 3
end



local function goToNoticeTabSceneFnc(event)
	-- storyboard.gotoScene("Scene.NoticeTabScene")
	-- global.currentSceneNumber = 4
	local tabbar = headTabFnc.getTabbar()
	native.showAlert(localization.getLocalization("noticeNotWorkTitle"),localization.getLocalization("noticeNotWorkDesc"),{localization.getLocalization("ok")})
	timer.performWithDelay( 100, function(event)
		tabbar:setSelected(global.currentSceneNumber)  
	end
	)

end
local function goToSettingTabSceneFnc(event)
	storyboard.gotoScene("Scene.SettingTabScene")
	global.currentSceneNumber = 5
end
local SETTING = {
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
											        labelColor = { default={ 0.3, 0.3, 0.3 }, over={ 0, 0, 1 } },
											        id = "me",
											        size = 16,
											        labelYOffset = -8,
											        onPress = goToMeTabSceneFnc,
											    },
											    {
											    	width = 49,
											    	height = 56,
											        defaultFile = TABBAR_IMAGE_LOC .. "postOff.png",
											        overFile = TABBAR_IMAGE_LOC .. "postOn.png",
											        label = localization.getLocalization("post"),
											        labelColor = { default={ 0.3, 0.3, 0.3 }, over={ 0, 0, 1 } },
											        id = "post",
											        size = 16,
											        labelYOffset = -8,
											        onPress = goToPostTabSceneFnc,
											    },
											    {
											    	width = 97,
											    	height = 100,
											        defaultFile = TABBAR_IMAGE_LOC .. "vorumOff.png",
											        overFile = TABBAR_IMAGE_LOC .. "vorumOn.png",
											        id = "vorum",
											        selected = true,
											        onPress = goToVorumTabSceneFnc,
											    },
											    {
											    	width = 72,
											    	height = 58,
											        defaultFile = TABBAR_IMAGE_LOC .. "noticeOff.png",
											        overFile = TABBAR_IMAGE_LOC .. "noticeOn.png",
											        label = localization.getLocalization("notice"),
											        labelColor = { default={ 0.3, 0.3, 0.3 }, over={ 0, 0, 1 } },
											        id = "notice",
											        size = 16,
											        labelYOffset = -8,
											        -- onPress = goToNoticeTabSceneFnc,
											    },
											    {
											    	width = 59,
											    	height = 59,
											        defaultFile = TABBAR_IMAGE_LOC .. "settingOff.png",
											        overFile = TABBAR_IMAGE_LOC .. "settingOn.png",
											        label = localization.getLocalization("setting"),
											        labelColor = { default={ 0.3, 0.3, 0.3 }, over={ 0, 0, 1 } },
											        id = "setting",
											        size = 16,
											        labelYOffset = -8,
											        onPress = goToSettingTabSceneFnc,
											    },
											},
								},
				}

return SETTING
