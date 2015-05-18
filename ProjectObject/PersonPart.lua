---------------------------------------------------------------
-- TemplateScene.lua
--
-- Template for Scene
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
--local resDir = (...):match("(.-)[^%.]+$")

-- Local Constant Setting
local LOCAL_SETTINGS = {
						NAME = "SettingScene",			-- Scene name to show in console
						RES_DIR = "",					-- Common resource directory for scene
						DOC_DIR = "",					-- Common document directory for scene
						}

---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------

local storyboard = require ( "storyboard" )
local widget = require ( "widget" )
require ( "DebugUtility.Debug" )
local projectObjectSetting = require( "Setting.ProjectObjectSetting" )
local localization = require("Localization.Localization")
local headerView = require( "ProjectObject.HeaderView" )
local headTabFnc = require( "ProjectObject.HeadTabFnc" )
local networkFunction = require("Network.NetworkFunction")
local saveData = require( "SaveData.SaveData" )
local json = require( "json" )
local global = require( "GlobalVar.global" )
local networkFile = require("Network.NetworkFile")
local newNetworkFunction = require("Network.newNetworkFunction")
---------------------------------------------------------------
-- Constants
---------------------------------------------------------------

local RANK_NUM_X = 356
local USERICON_WIDTH = 102
local USERICON_HEIGHT = 102
local USERICON_MASKPATH = "Image/User/creatorMask.png"
---------------------------------------------------------------
-- Variables
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
-- Function for back button
local returnGroup = {}
local userData
local userId

local personId
local relationship

local relationshipButton
local relationshipButton2
local relationshipButtonGeneration


local profileData_savePath
local oldProfileData

--set userIcon save path
local user_icon_savePath
local scrollView
local personData
--obj

local group_personPart
local background_user_part
local user_icon_background
local user_icon
local text_username
local text_userlive
local image_gold
local text_gold
local image_silver 
local text_silver
local image_brown
local text_brown
local text_totalVoted
local text_totalPosts

local requestParams = {}

local function noFnc(event)
	if ( phase == "moved" ) then
		if(scrllView)then
			local dy = math.abs( ( event.y - event.yStart ) )
			if ( dy > 10 ) then
				scrollView:takeFocus( event )
			end
		end
	end
	return true
end

local function changeRelationshiplistener(event)
	
	if (event.isError) then
		native.showAlert(localization.getLocalization("networkError_errorTitle"),localization.getLocalization("networkError_networkError"),{localization.getLocalization("ok")})
	else
		print("event",event[1].response)
		local response = json.decode(event[1].response)

		if(type(response)=="table" and response.code)then

			response.code = tonumber( response.code )

			if(response.code==37 or response.code==35)then --35 sent, 37 already send
				print("sent request")

				local addFriendList = saveData.load(global.addFriendListSavePath)

				if(type(addFriendList)~="table")then
					addFriendList = {}
				end

				addFriendList[personId] = true

				saveData.save(global.addFriendListSavePath,addFriendList)

				relationship = "pending"
			elseif(response.code==50)then
				relationship = "noRelation"
			elseif(response.code==48)then
				print("cancel request")

				local addFriendList = saveData.load(global.addFriendListSavePath)

				if(type(addFriendList)~="table")then
					addFriendList = {}
				end

				addFriendList[personId] = false

				saveData.save(global.addFriendListSavePath,addFriendList)

				relationship = "noRelation"
			elseif(response.code==36)then
				print("addFriedn each other")
				relationship = "friend"
			elseif(response.code==39)then
				print("accept")
				relationship = "friend"
			elseif(response.code==46)then
				print("reject")
				relationship = "noRelation"
			end
			print("relationship",relationship)
			relationshipButtonGeneration()
		end
	end
end
local function addFriendFnc(event)
	local phase = event.phase

	if( phase == "began" ) then
	elseif ( phase == "moved" ) then
		if(scrllView)then
			local dy = math.abs( ( event.y - event.yStart ) )
			if ( dy > 10 ) then
				scrollView:takeFocus( event )
			end
		end
	elseif ( phase == "ended" or phase == "cancelled" ) then

		newNetworkFunction.friendRequestAction(requestParams, changeRelationshiplistener)

	end
	return true
end

local function unfriendFnc(event)
	local phase = event.phase

	if( phase == "began" ) then
	elseif ( phase == "moved" ) then
		if(scrllView)then
			local dy = math.abs( ( event.y - event.yStart ) )
			if ( dy > 10 ) then
				scrollView:takeFocus( event )
			end
		end
	elseif ( phase == "ended" or phase == "cancelled" ) then
		newNetworkFunction.unfriend(requestParams, changeRelationshiplistener)
	end
	return true
end

local function approvalFnc(event)
	local phase = event.phase

	if( phase == "began" ) then
	elseif ( phase == "moved" ) then
		if(scrllView)then
			local dy = math.abs( ( event.y - event.yStart ) )
			if ( dy > 10 ) then
				scrollView:takeFocus( event )
			end
		end
	elseif ( phase == "ended" or phase == "cancelled" ) then
		newNetworkFunction.acceptFriendRequest(requestParams, changeRelationshiplistener)
	end
	return true
end

local function rejectFnc(event)
	local phase = event.phase

	if( phase == "began" ) then
	elseif ( phase == "moved" ) then
		if(scrllView)then
			local dy = math.abs( ( event.y - event.yStart ) )
			if ( dy > 10 ) then
				scrollView:takeFocus( event )
			end
		end
	elseif ( phase == "ended" or phase == "cancelled" ) then
		newNetworkFunction.rejectFriendRequest(requestParams, changeRelationshiplistener)
	end
	return true
end

local function pendingFnc(event)
	local phase = event.phase

	if( phase == "began" ) then
	elseif ( phase == "moved" ) then
		if(scrllView)then
			local dy = math.abs( ( event.y - event.yStart ) )
			if ( dy > 10 ) then
				scrollView:takeFocus( event )
			end
		end
	elseif ( phase == "ended" or phase == "cancelled" ) then
		newNetworkFunction.cancelFriendRequest(requestParams, changeRelationshiplistener)
	end
	return true
end

local function editFnc(event)
	local phase = event.phase

	if( phase == "began" ) then
	elseif ( phase == "moved" ) then
		if(scrllView)then
			local dy = math.abs( ( event.y - event.yStart ) )
			-- If the touch on the button has moved more than 10 pixels,
			-- pass focus back to the scroll view so it can continue scrolling
			if ( dy > 10 ) then
				scrollView:takeFocus( event )
			end
		end
	elseif ( phase == "ended" or phase == "cancelled" ) then
		--header
		local header = headTabFnc.getHeader()
		local tabbar = headTabFnc.getTabbar()
		if (tabbar == nil) then
			tabbar = headTabFnc.createNewTabbar(projectObjectSetting.tabbar)
		end
		local curSceneName = storyboard.getCurrentSceneName()
		local curScene = storyboard.getScene( curSceneName )
		curScene.view:insert(header)
		curScene.view:insert(tabbar)
		
		timer.performWithDelay(399,function(event) 
			local stage = display.getCurrentStage()
			stage:insert( header )
			stage:insert( tabbar )
			header:toBack()
			tabbar:toBack()
		end)
	
		local options = {}
		options.effect = "fromRight"
		options.time = 400
		
		options.params = {}
		-- options.params = personData
		storyboard.gotoScene( "Scene.EditPersonalDataPageScene",options)
		
	end
	return true
end


local userIconFnc = function(fileInfo)
	if(userIcon)then
		display.remove(userIcon)
		userIcon = nil
	end
	
	user_icon = display.newImage(fileInfo.path, fileInfo.baseDir, true)
	if(user_icon)then
		user_icon.x = user_icon_background.x
		user_icon.y = user_icon_background.y
		user_icon.anchorX=0.5
		user_icon.anchorY=0.5
	
		local xScale = USERICON_WIDTH / user_icon.contentWidth
		local yScale = USERICON_HEIGHT / user_icon.contentHeight
		local scale = math.max( xScale, yScale )
		user_icon:scale( scale, scale )
		local mask = graphics.newMask( USERICON_MASKPATH )
		user_icon:setMask( mask )
		user_icon.maskX = 0
		user_icon.maskY = 0
		user_icon.maskScaleX, user_icon.maskScaleY = 1/scale,1/scale
		group_personPart:insert(user_icon)
	end
end

local function userIconListener(event)
	if (event.isError) then
	else
		userIconFnc({path = event.path, baseDir = event.baseDir})
	end
end

function returnGroup.updateUserData(userProfileData)
	if(type(userProfileData)~="table")then
		return
	end
	
	if(userProfileData.name)then
		local temp_displayName = userProfileData.name
		
		if(string.len(temp_displayName)>10)then
		
			temp_displayName = string.sub(temp_displayName,1,10)
			local lastSpacePos = nil
			local temp_lastSpacePos = 0
			
			while(not lastSpacePos and temp_lastSpacePos and lastSpacePos==temp_lastSpacePos)do
				temp_lastSpacePos = string.find(temp_displayName," ",temp_lastSpacePos+1)
				
				if(temp_lastSpacePos)then
					lastSpacePos = temp_lastSpacePos
				else 
					
					if(not lastSpacePos)then
						lastSpacePos = 10
					end
					break
				end
				
			end
			
			temp_displayName = string.sub(temp_displayName,1,lastSpacePos)
		end
		text_username.text = temp_displayName
	end
	if(userProfileData.country)then
		text_userlive.text = userProfileData.country
	else
		text_userlive.text = ""
	end
	if(userProfileData.info)then
		if(userProfileData.info.medal)then
			if(userProfileData.info.medal.gold)then
				text_gold.text = userProfileData.info.medal.gold
			end
			if(userProfileData.info.medal.silver)then
				text_silver.text = userProfileData.info.medal.silver
			end
			if(userProfileData.info.medal.bronze)then
				text_brown.text = userProfileData.info.medal.bronze
			end
		end
		if(userProfileData.info.post_cnt)then
			text_totalPosts.text = tostring(userProfileData.info.post_cnt)..localization.getLocalization("personalInfo_posts")
		end
		if(userProfileData.info.vote_cnt)then
			text_totalVoted.text = tostring(userProfileData.info.vote_cnt)..localization.getLocalization("personalInfo_voted")
		end
	end
	if(userProfileData.profile_pic and userProfileData.profile_pic=="")then

		userIconFnc({path = "Image/User/anonymous.png", baseDir = system.ResourceDirectory})--temp image

	elseif(userProfileData.profile_pic)then

		local userIconInfo = newNetworkFunction.getVorumFile(userProfileData.profile_pic, user_icon_savePath, userIconListener)
		if ((userIconInfo ~= nil) and (userIconInfo.request == nil)) then
			userIconFnc(userIconInfo)
		end
		
	end
end
local function waitingStatusAdjustFnc()
	text_totalVoted.y = 135
	text_totalPosts.y = 135
end
local function normalStatusAdjustFnc()
	text_totalVoted.y = 150
	text_totalPosts.y = 150
end

relationshipButtonGeneration = function ()
	if(relationshipButton)then
		if(relationshipButton.parent)then
			relationshipButton.parent:remove(relationshipButton)
		end
		display.remove(relationshipButton)
		relationshipButton = nil
	end
	if(relationshipButton2)then
		if(relationshipButton2.parent)then
			relationshipButton2.parent:remove(relationshipButton2)
		end
		display.remove(relationshipButton2)
		relationshipButton2 = nil
	end

	normalStatusAdjustFnc()

	if (relationship == "friend") then
		print("Friend")
		relationship = "friend"
		relationshipButton = widget.newButton
		{
			label = localization.getLocalization("relationship_unfriend_button"),
			labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
			font = "Helvetica",
			fontSize = 30,
			onEvent = unfriendFnc,
			
			shape = "roundedRect",
			fillColor = { default={ 78/255, 184/255, 229/255}, over={ 78/255, 184/255, 229/255} },
			width = 170,
			height = 47,
			cornerRadius = 5,
			strokeColor = { default={ 0, 0, 0 }, over={ 0, 0, 0 } },
			strokeWidth =0
		}
		relationshipButton.x = 458
		relationshipButton.y = text_totalVoted.y+text_totalVoted.height+20
		relationshipButton.anchorX=0
		relationshipButton.anchorY=0
		group_personPart:insert(relationshipButton)

	elseif (relationship == "pending") then

		print("Is pending from other user")
		relationship = "pending"
		relationshipButton = widget.newButton
		{
			label = localization.getLocalization("relationship_pending_button"),
			labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
			font = "Helvetica",
			fontSize = 30,
			onEvent = pendingFnc,
			
			shape = "roundedRect",
			fillColor = { default={ 78/255, 184/255, 229/255}, over={ 78/255, 184/255, 229/255} },
			width = 170,
			height = 47,
			cornerRadius = 5,
			strokeColor = { default={ 0, 0, 0 }, over={ 0, 0, 0 } },
			strokeWidth =0
		}
		relationshipButton.x = 458
		relationshipButton.y = text_totalVoted.y+text_totalVoted.height+20
		relationshipButton.anchorX=0
		relationshipButton.anchorY=0
		group_personPart:insert(relationshipButton)

	elseif (relationship == "waiting") then

		waitingStatusAdjustFnc()

		print("Waiting your approval")
		relationship = "waiting"
		relationshipButton = widget.newButton
		{
			label = localization.getLocalization("relationship_approval_button"),
			labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
			font = "Helvetica",
			fontSize = 24,
			onEvent = approvalFnc,
			
			shape = "roundedRect",
			fillColor = { default={ 78/255, 184/255, 229/255}, over={ 78/255, 184/255, 229/255} },
			width = 170,
			height = 40,
			cornerRadius = 5,
			strokeColor = { default={ 0, 0, 0 }, over={ 0, 0, 0 } },
			strokeWidth =0
		}
		relationshipButton.x = 458
		relationshipButton.y = text_totalVoted.y+text_totalVoted.height+5
		relationshipButton.anchorX=0
		relationshipButton.anchorY=0
		group_personPart:insert(relationshipButton)
		
		relationshipButton2 = widget.newButton
		{
			label = localization.getLocalization("relationship_reject_button"),
			labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
			font = "Helvetica",
			fontSize = 24,
			onEvent = rejectFnc,
			
			shape = "roundedRect",
			fillColor = { default={ 255/255, 105/255, 180/255}, over={ 255/255, 105/255, 180/255} },
			width = 170,
			height = 40,
			cornerRadius = 5,
			strokeColor = { default={ 0, 0, 0 }, over={ 0, 0, 0 } },
			strokeWidth =0
		}
		relationshipButton2.x = 458
		relationshipButton2.y = relationshipButton.y+relationshipButton.height+10
		relationshipButton2.anchorX=0
		relationshipButton2.anchorY=0
		group_personPart:insert(relationshipButton2)

	elseif(relationship == "noRelation")then

		print("No relation")
		relationship = "noRelation"
		relationshipButton = widget.newButton
		{
			label = localization.getLocalization("relationship_addFriend_button"),
			labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
			font = "Helvetica",
			fontSize = 30,
			onEvent = addFriendFnc,
			
			shape = "roundedRect",
			fillColor = { default={ 78/255, 184/255, 229/255}, over={ 78/255, 184/255, 229/255} },
			width = 170,
			height = 47,
			cornerRadius = 5,
			strokeColor = { default={ 0, 0, 0 }, over={ 0, 0, 0 } },
			strokeWidth =0
		}
		relationshipButton.x = 458
		relationshipButton.y = text_totalVoted.y+text_totalVoted.height+20
		relationshipButton.anchorX=0
		relationshipButton.anchorY=0
		group_personPart:insert(relationshipButton)

	end
end


--listener to update infomation
local function getMemberProfileListener(event)

	if (event.isSomeApiError) then
		local errorStr = ""
		for i = 1, #event do
			errorStr = errorStr .. " " .. tostring(event[i].isError)
		end
		print(errorStr)
	else
		local response 
	
		
		if(type(event.userData)=="table")then
			response = event.userData
		else
			response = json.decode(event[1].response)			
		end
		response.posts = nil

		returnGroup.updateUserData(response)
		saveData.save(profileData_savePath,global.TEMPBASEDIR,response)

		if(relationship=="pending")then
			relationshipButtonGeneration()
			return
		end

		if(relationship ~= "self")then
			print(relationship,"relationship")
			if (tostring(response.isFriend)=="1") then
				print("Friend")
				relationship = "friend"
			elseif (event.isPending) then
				print("Is pending from other user")
				relationship = "pending"
			elseif (tostring(event.hasRequest)=="1") then
				print("Waiting your approval")
				relationship = "waiting"
			else
				print("No relation")
				relationship = "noRelation"
			end
			relationshipButtonGeneration()
			
		end

	end
end
function returnGroup.updateMemberProfileListener(event)
	getMemberProfileListener(event)
end



function returnGroup.create(input_personData,input_scrollView)
	
	personData = input_personData
	scrollView = input_scrollView
	userData = saveData.load(global.userDataPath)
	userId = userData.user_id or userData.id
	personId = personData.user_id or personData.id
	
	print("personDaata",json.encode( personData ))

	requestParams.id = personId
	
	relationship = nil
	relationshipButton = nil
	relationshipButton2 = nil
	
	if(userId == personId)then--check whether self
		relationship = "self"
	else
		local addFriendList = saveData.load(global.addFriendListSavePath)
		if(type(addFriendList)=="table")then
			if(addFriendList[personId])then
				relationship = "pending"
			end
		end
	end
	
	profileData_savePath = "user/"..personId.."/profileData.sav"
	oldProfileData = saveData.load(profileData_savePath,global.TEMPBASEDIR)
	
	--set userIcon save path
	user_icon_savePath = "user/" .. tostring(personId) .. "/img"

	
	group_personPart = display.newGroup()
	
	-------------------- user begin
	background_user_part = display.newImage("Image/Setting/background.png")
	background_user_part.x = 0
	background_user_part.y = 0
	background_user_part.anchorX=0
	background_user_part.anchorY=0
	group_personPart:insert(background_user_part)

	user_icon_background = display.newCircle(group_personPart, 73, 198, 58)
	user_icon_background.anchorX = 0.5
	user_icon_background.anchorY = 0.5

	if(string.upper(tostring(personData.gender))=="M")then
		user_icon_background:setFillColor(unpack(global.maleColor))
	elseif(string.upper(tostring(personData.gender))=="F")then
		user_icon_background:setFillColor(unpack(global.femaleColor))
	else
		user_icon_background:setFillColor(unpack(global.noGenderColor))
	end

	userIconFnc({path = "Image/User/anonymous.png", baseDir = system.ResourceDirectory})--temp image
	
	text_username =
	{
		text = "...", -- get data from server
		x = 158,
		y = 155,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=30
	}
	text_username = display.newText(text_username);
	text_username:setFillColor(1, 1, 1 )
	text_username.anchorX=0
	text_username.anchorY=0
	group_personPart:insert(text_username)

	text_userlive =
	{
		text = "...", -- get data from server
		x = 158,
		y = text_username.y+text_username.height+19,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=24
	}
	text_userlive = display.newText(text_userlive);
	text_userlive:setFillColor(1, 1, 1 )
	text_userlive.anchorX=0
	text_userlive.anchorY=0
	group_personPart:insert(text_userlive)
-----------------------------	
	
	image_gold = display.newImage("Image/Setting/gold.png")
	image_gold.x=RANK_NUM_X
	image_gold.y=150
	image_gold.anchorX=0
	image_gold.anchorY=0
	group_personPart:insert(image_gold)
	
	text_gold =
	{
		text = 0, -- get data from server
		x = image_gold.x+image_gold.width+10,
		y = image_gold.y,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=24
	}
	text_gold = display.newText(text_gold);
	text_gold:setFillColor(1, 1, 1 )
	text_gold.anchorX=0
	text_gold.anchorY=0
	group_personPart:insert(text_gold)
	
	
	image_silver = display.newImage("Image/Setting/silver.png")
	image_silver.x=RANK_NUM_X
	image_silver.y=image_gold.y+image_gold.height+10
	image_silver.anchorX=0
	image_silver.anchorY=0
	group_personPart:insert(image_silver)
	
	text_silver =
	{
		text = 0, -- get data from server
		x = image_silver.x+image_silver.width+10,
		y = image_silver.y,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=24
	}
	text_silver = display.newText(text_silver);
	text_silver:setFillColor(1, 1, 1 )
	text_silver.anchorX=0
	text_silver.anchorY=0
	group_personPart:insert(text_silver)
	
	image_brown = display.newImage("Image/Setting/brown.png")
	image_brown.x=RANK_NUM_X
	image_brown.y=image_silver.y+image_silver.height+10
	image_brown.anchorX=0
	image_brown.anchorY=0
	group_personPart:insert(image_brown)
	

	text_brown =
	{
		text = 0, -- get data from server
		x = image_brown.x+image_brown.width+10,
		y = image_brown.y,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=24
	}
	text_brown = display.newText(text_brown);
	text_brown:setFillColor(1, 1, 1 )
	text_brown.anchorX=0
	text_brown.anchorY=0
	group_personPart:insert(text_brown)
-----------------------------	
	text_totalVoted =
	{
		text = 0 .. localization.getLocalization("personalInfo_voted"), -- get data from server
		x = 458,
		y = 150,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=20
	}
	text_totalVoted = display.newText(text_totalVoted);
	text_totalVoted:setFillColor(1, 1, 1 )
	text_totalVoted.anchorX=0
	text_totalVoted.anchorY=0
	group_personPart:insert(text_totalVoted)
	
	text_totalPosts =
	{
		text = 0 .. localization.getLocalization("personalInfo_posts"), -- get data from server
		x = 624,
		y = 150,
		width = 0,
		height = 0, 
		font = "Helvetica",
		fontSize=20
	}
	text_totalPosts = display.newText(text_totalPosts);
	text_totalPosts:setFillColor(1, 1, 1 )
	text_totalPosts.anchorX=1
	text_totalPosts.anchorY=0
	group_personPart:insert(text_totalPosts)

	--updated userProfile
	returnGroup.updateUserData(oldProfileData)
	
	
	
	
	if(relationship=="self")then

		relationshipButton = widget.newButton
		{
			label = localization.getLocalization("setting_edit_button"),
			labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
			font = "Helvetica",
			fontSize = 30,
			onEvent = editFnc,
			
			shape = "roundedRect",
			fillColor = { default={ 78/255, 184/255, 229/255}, over={ 78/255, 184/255, 229/255} },
			width = 170,
			height = 47,
			cornerRadius = 5,
			strokeColor = { default={ 0, 0, 0 }, over={ 0, 0, 0 } },
			strokeWidth =0
		}
		relationshipButton.x = text_totalVoted.x
		relationshipButton.y = text_totalVoted.y+text_totalVoted.height+20
		relationshipButton.anchorX=0
		relationshipButton.anchorY=0
		group_personPart:insert(relationshipButton)
		newNetworkFunction.getUserData(getMemberProfileListener)
	else
		relationshipButton = widget.newButton
		{
			label = "...",
			labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
			font = "Helvetica",
			fontSize = 30,
			onEvent = noFnc,
			
			shape = "roundedRect",
			fillColor = { default={ 78/255, 184/255, 229/255}, over={ 78/255, 184/255, 229/255} },
			width = 170,
			height = 47,
			cornerRadius = 5,
			strokeColor = { default={ 0, 0, 0 }, over={ 0, 0, 0 } },
			strokeWidth =0
		}
		relationshipButton.x = text_totalVoted.x
		relationshipButton.y = text_totalVoted.y+text_totalVoted.height+20
		relationshipButton.anchorX=0
		relationshipButton.anchorY=0
		group_personPart:insert(relationshipButton)
		-- newNetworkFunction.getMemberData(personId,getMemberProfileListener)
	end

	
	return group_personPart
end
return returnGroup