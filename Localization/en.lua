---------------------------------------------------------------
-- en.lua
--
-- Localization for en
---------------------------------------------------------------

-- Local Constant Setting
local LOCAL_SETTINGS = {
						RES_DIR = "",					-- Common resource directory for scene
						DOC_DIR = "",					-- Common document directory for scene
						}

---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------

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
return {
			name = "English",
			list = {
					-- Main Tab
					notice = "Notice",
					post = "Post",
					me = "Me",
					setting = "Setting",

					ok = "OK",
					cancel = "Cancel",

					-- Facebook Login Procedure
					fb_inputLoginData = "Please input data",
					fb_inputLoginDataToLink = "Please input the login data below",
					fb_noFbAcc = "Cannot find account",
					fb_noFbAcc_Create = "Cannot find an account linked with Facebook. Create new account or Link the existing account?",
					create = "Create",
					link = "Link",
					fb_createAcc = "Create account",
					fb_createNewAcc = "Create new account?",
					fb_linkToAcc = "Link to account",
					fb_linkFbToAcc = "Link the Facebook account to existing account?",
					fb_cantLoginAccToLink = "Cannot login to Account",
					fb_cantLoginAccToLink_Create = "Cannot login to Account. Create New Account?",					
					fb_accountLinked = "Account linked",
					fb_accountLinkedSuccessfully = "The Facebook account is linked to existing Vorum account successfully",




					helloString = "Hello",
					listString = {
									"Row 1",
									"Row 2",
									"Row 3",
									},
					},
		}
