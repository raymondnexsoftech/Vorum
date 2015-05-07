---------------------------------------------------------------
-- TemplateScene.lua
--
-- Template for Scene
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
--local resDir = (...):match("(.-)[^%.]+$")


---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------
local widget = require ( "widget" )
require ( "DebugUtility.Debug" )
local projectObjectSetting = require( "Setting.ProjectObjectSetting" )
local localization = require("Localization.Localization")
local networkFunction = require("Network.NetworkFunction")
local saveData = require( "SaveData.SaveData" )
local json = require( "json" )
local global = require( "GlobalVar.global" )
local functionalOption = require( "Module.FunctionalOption" )
-- local popupOption = require("Module.popup")
local newNetworkFunction = require("Network.newNetworkFunction")
local sharePostFnc = require("ProjectObject.SharePost")
---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local FunctionGroup = {}

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
local postObj
local postData
local userData
local optionVaule
local scrollView
---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------
local pushListener
local reportListener
local shareListener
local deleteListener
local pushFnc
local reportFnc
local shareFnc
local deleteFnc

--share option
local whatsappIcon
local whatsappText
local facebookIcon
local facebookText
local popupDataValue = {}
---------------------------------------------------------------
-- Functions
---------------------------------------------------------------

local function shareOption()
	
-- whatsappIcon = display.newImage("Image/Share/whatsapp.png",true)
-- whatsappIcon.x = -170
-- whatsappIcon.y = 0
-- whatsappIcon.anchorX=0
-- whatsappIcon.anchorY=0.5

-- facebookIcon = display.newImage("Image/Share/facebook.png",true)
-- facebookIcon.x = 170
-- facebookIcon.y = 0
-- facebookIcon.anchorX=1
-- facebookIcon.anchorY=0.5


-- popupDataValue = {
	-- bgColor = {0,0,0},
	-- bgAlpha = 0,
	-- popupBgWidth = 360,
	-- popupBgHeight = 180,
	-- popupBgAlpha = 0.95,
	-- popupBgStrokeWidth = 0,
	-- popupBgStrokeColor = {187/255,235/255,255/255},
-- }

-- popupDataValue.popupObj = {whatsappIcon,facebookIcon}
-- popupOption.popup(popupDataValue)
-- -- popupObjFncType = {},
-- -- popupObjFnc = {},
end


function pushListener(event)
	if(event.isNetworkError)then
		native.showAlert(localization.getLocalization("networkError_errorTitle"),localization.getLocalization("networkError_networkError"),{localization.getLocalization("ok")})
	elseif(event.isPushedToday)then
		native.showAlert(localization.getLocalization("pushPostError_pushTitle"),localization.getLocalization("pushPostError_pushedAleady"),{localization.getLocalization("ok")})
	else
		native.showAlert(localization.getLocalization("pushPostSuccessTitle"),localization.getLocalization("pushPostSuccess"),{localization.getLocalization("ok")})
	end
end

function reportListener(event)
	if(event.isNetworkError)then
		native.showAlert(localization.getLocalization("networkError_errorTitle"),localization.getLocalization("networkError_networkError"),{localization.getLocalization("ok")})
	else
		native.showAlert(localization.getLocalization("reportPostSuccessTitle"),localization.getLocalization("reportPostSuccess"),{localization.getLocalization("ok")})
	end
end

function shareListener(event)
	if(event.isNetworkError)then
		native.showAlert(localization.getLocalization("networkError_errorTitle"),localization.getLocalization("networkError_networkError"),{localization.getLocalization("ok")})
	elseif(event.isUserShared)then
		native.showAlert(localization.getLocalization("sharePostError_shareTitle"),localization.getLocalization("sharePostError_sharedAleady"),{localization.getLocalization("ok")})
	else
		native.showAlert(localization.getLocalization("sharePostSuccessTitle"),localization.getLocalization("sharePostSuccess"),{localization.getLocalization("ok")})
	end
end

function deleteListener(event)
	if(event.isNetworkError)then
		native.showAlert(localization.getLocalization("networkError_errorTitle"),localization.getLocalization("networkError_networkError"),{localization.getLocalization("ok")})
	else
		-- native.showAlert(localization.getLocalization("deletePostSuccessTitle"),localization.getLocalization("deletePostSuccess"),{localization.getLocalization("ok")})
		scrollView:deletePost(postObj.idx,400)
	end
end

function pushFnc(event)
	if(event.phase == "ended" or event.phase == "cancelled")then
		functionalOption.hide()
		newNetworkFunction.pushPost(postData.id, pushListener)
	end
	return true
end

function reportFnc(event)
	if(event.phase == "ended" or event.phase == "cancelled")then
		functionalOption.hide()
		newNetworkFunction.reportPost(postData.id, reportListener)
	end
	return true
end

function shareFnc(event)
	if(event.phase == "ended" or event.phase == "cancelled")then
		functionalOption.hide()
		newNetworkFunction.sharePost(postData.id, shareListener)
		-- shareOption()
	end
	return true
end

function deleteFnc(event)
	if(event.phase == "ended" or event.phase == "cancelled")then
		functionalOption.hide()
		newNetworkFunction.deletePost(postData.id, deleteListener)
	end
	return true
end

local function shareToFacebookFncListener(event)
	print(json.encode(event))
	if(event.isError)then
		native.showAlert(localization.getLocalization("facebookShareErrorTitle"),localization.getLocalization("facebookShareErrorDesc"),{localization.getLocalization("ok")})
	elseif(event.didComplete)then
		native.showAlert(localization.getLocalization("facebookShareSuccessTitle"),localization.getLocalization("facebookShareSuccessDesc"),{localization.getLocalization("ok")})
	end
end

local function shareToFacebookFnc(event)
	if(event.phase == "ended" or event.phase == "cancelled")then
		functionalOption.hide()
		sharePostFnc.byFacebook(postData.title,shareToFacebookFncListener)
	end
	return true
end

local function shareToWhatsappFnc(event)
	if(event.phase == "ended" or event.phase == "cancelled")then
		functionalOption.hide()
		sharePostFnc.byWhatsapp(postData.title,postData.description)
	end
	return true
end

function FunctionGroup.show(postGroup, postPartData, creatorData,scrollViewObj)
	--		loadUserData()
	userData = {}
	userData = saveData.load(global.userDataPath)
	postObj = postGroup
	postData = postPartData
	scrollView = scrollViewObj

	optionVaule = 
	{
		choiceObj = {},
		choiceFnc = {},
		cancelButtonText = localization.getLocalization("postButton_cancel"),
		choiceObj_fontFamily = "Helvetica",
	}
	optionVaule.choiceObj[1] = localization.getLocalization("postButton_push")
	optionVaule.choiceFnc[1] = pushFnc
	optionVaule.choiceObj[2] = localization.getLocalization("postButton_report")
	optionVaule.choiceFnc[2] = reportFnc
	optionVaule.choiceObj[3] = localization.getLocalization("postButton_shareToWhatsapp")
	optionVaule.choiceFnc[3] = shareToWhatsappFnc
	optionVaule.choiceObj[4] = localization.getLocalization("postButton_shareToFacebook")
	optionVaule.choiceFnc[4] = shareToFacebookFnc
	
	if(creatorData and userData.id == creatorData.id)then
		optionVaule.choiceObj[5] = localization.getLocalization("postButton_delete")
		optionVaule.choiceFnc[5] = deleteFnc
	else
		optionVaule.choiceObj[5] = localization.getLocalization("postButton_shareToMyWall")
		optionVaule.choiceFnc[5] = shareFnc
	end
	
	functionalOption.create(optionVaule)
	
end

return FunctionGroup