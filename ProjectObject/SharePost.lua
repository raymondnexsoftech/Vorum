---------------------------------------------------------------
-- SharePost.lua
--
-- Share post function
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
local facebookModule = require("Module.FacebookModule")
local url = require("socket.url")
---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local VORUM_DOWNLOAD_LINK = "www.nexsoftech.com"

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
local sharePost = {}

function sharePost.byFacebook(title, listener)
	local function sharePostByFacebookLoginListener(event)
		local params = {}
		params.link = VORUM_DOWNLOAD_LINK
		params.picture = ""		-- TODO: link to Vorum Pic
		params.name = "Vorum"
		params.description = localization.getLocalization("sharePostSentence1") .. " [" .. title .. "] " .. localization.getLocalization("sharePostSentence2")
		facebookModule.showDialog("feed", params, listener)
	end
	facebookModule.login({"publish_actions"}, sharePostByFacebookLoginListener)
end

function sharePost.byWhatsapp(title, description)
	local shareSentences = localization.getLocalization("sharePostSentence1") .. "\n\n" .. title 
	if (description) then
		shareSentences = shareSentences .. "\n" .. description
	end
	shareSentences = shareSentences .. "\n\n" .. localization.getLocalization("sharePostSentence2")
	system.openURL("whatsapp://send?text=" .. url.escape(shareSentences))
end

return sharePost
