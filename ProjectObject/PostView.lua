---------------------------------------------------------------
-- PostView.lua
--
-- Post View Object for Vorum
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
--local resDir = (...):match("(.-)[^%.]+$")

-- Local Constant Setting
local LOCAL_SETTINGS = {
						RES_DIR = "Image/PostView/",	-- Common resource directory for scene
						DOC_DIR = "",					-- Common document directory for scene
						}

---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------
require ( "SystemUtility.Debug" )
local widget = require ( "widget" )
local networkFunction = require("Network.newNetworkFunction")
-- local networkFile = require("Network.NetworkFile")
local localization = require("Localization.Localization")
local scrollViewForPost = require("ProjectObject.ScrollViewForPost")
local imageViewer = require("Module.ImageViewer")
local pieChart = require("ProjectObject.PieChart")
local fncForLocalization = require("Misc.FncForLocalization")
local global = require("GlobalVar.global")

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local isAndroid = system.getInfo("platformName") == "Android"

local USER_IMG_PATH = "Image/User/"
local POST_VIEW_COMMON_FONT = "Helvetica"
local POST_WIDTH = display.contentWidth * 0.95
local CREATOR_PIC_X = 90
local CREATOR_PIC_Y = 70
local CREATOR_NAME_FONTSIZE = 30
local CREATOR_NAME_X = 160
local CREATOR_NAME_Y = 40
local CREATOR_NAME_WIDTH = 380
local ACTION_BTN_X = POST_WIDTH - 30
local ACTION_BTN_Y = CREATOR_NAME_Y
local CREATE_TIME_X = CREATOR_NAME_X
local CREATE_TIME_Y = CREATOR_NAME_Y + 45
local CREATE_TIME_FONTSIZE = 24
local TAG_TEXT_Y = CREATE_TIME_Y
local TAG_TEXT_FONTSIZE = 24
local REWARD_TEXT_X = CREATE_TIME_X + 425
local REWARD_TEXT_Y = CREATE_TIME_Y
local REWARD_TEXT_FONTSIZE = 24
local POST_TITLE_Y = 130
local POST_TITLE_WIDTH = display.contentWidth * 0.8
local HOR_SCROLL_HEIGHT = 400
local POST_TITLE_FONTSIZE = 56
local CHOICE_PIC_WIDTH = 260
local CHOICE_PIC_HEIGHT = 180
local CHOICE_CROWN_X = CHOICE_PIC_WIDTH * 0.5 - 30
local CHOICE_CROWN_Y = -CHOICE_PIC_HEIGHT * 0.5 + 30
local CHOICE_CROWN_Y2 = -CHOICE_PIC_HEIGHT + 30
local CHOICE_CROWN_SCALE = 0.4
local CHOICE_PIC_LARGE_HEIGHT = 320
local CHOICE_PIC_OBJECT_WIDTH = 520
local CHOICE_PIC_OBJECT_SPACE = display.contentWidth * 0.05
local CHOICE_LARGE_TEXT_FONTSIZE = 40
local CHOICE_LETTER_FONTSIZE = 30
local CHOICE_TEXT_FONTSIZE = 16
local VIEWS_TEXT_X = display.contentWidth * 0.48
local VOTED_TEXT_X = display.contentWidth * 0.52
local VIEWS_AND_VOTED_TEXT_FONTSIZE = 24

local POST_COUPON_TEXT_FONTSIZE = 30

local RESULT_DEFAULT_HEIGHT = 420
local RESULT_HIDDEN_DEFAULT_HEIGHT = 150
local RESULT_TITLE_FONTSIZE = 30
local RESULT_PIE_CHART_X = 200
local RESULT_PIE_CHART_Y = 200
local RESULT_NO_VOTE_FONTSIZE = 35
local RESULT_VOTE_LIST_X = 410
local RESULT_VOTE_LIST_Y = {110, 170, 230, 290}
local RESULT_VOTE_LIST_FONTSIZE = 20
local RESULT_VOTE_GENDER_Y = 370
local RESULT_VOTE_GENDER_BG_WIDTH = display.contentWidth * 0.7
local RESULT_VOTE_GENDER_BG_HEIGHT = 30
local RESULT_VOTE_MALE_COLOR = {88/255, 175/255, 231/255}
local RESULT_VOTE_FEMALE_COLOR = {255/255, 167/255, 177/255}


local POST_DETAIL_PIC_WIDTH = 512
local POST_DETAIL_PIC_HEIGHT = 320
local POST_DETAIL_TEXT_X = display.contentWidth * 0.1
local POST_DETAIL_TEXT_WIDTH = display.contentWidth * 0.8
local POST_DETAIL_TEXT_FONTSIZE = 24
local POST_DETAIL_DEFAULT_MIN_HEIGHT = 40

local CHOICE_PIC_SELECTED_SCALE = 1.1

local MAX_TIME_FOR_TOUCH_SPEED = 200
local TOUCH_MIN_SPEED_TRIGGER = 0.5

local CHOICE_LETTER_TABLE = {"A", "B", "C", "D"}
local CHOICE_PIC_SIZE_AND_POS = {
									{},
									{
										{width = CHOICE_PIC_WIDTH, height = CHOICE_PIC_HEIGHT * 2, x = CHOICE_PIC_WIDTH * 0.5, y = CHOICE_PIC_HEIGHT},
										{width = CHOICE_PIC_WIDTH, height = CHOICE_PIC_HEIGHT * 2, x = CHOICE_PIC_WIDTH * 1.5, y = CHOICE_PIC_HEIGHT},
									},
									{
										{width = CHOICE_PIC_WIDTH, height = CHOICE_PIC_HEIGHT * 2, x = CHOICE_PIC_WIDTH * 0.5, y = CHOICE_PIC_HEIGHT},
										{width = CHOICE_PIC_WIDTH, height = CHOICE_PIC_HEIGHT, x = CHOICE_PIC_WIDTH * 1.5, y = CHOICE_PIC_HEIGHT * 0.5},
										{width = CHOICE_PIC_WIDTH, height = CHOICE_PIC_HEIGHT, x = CHOICE_PIC_WIDTH * 1.5, y = CHOICE_PIC_HEIGHT * 1.5},
									},
									{
										{width = CHOICE_PIC_WIDTH, height = CHOICE_PIC_HEIGHT, x = CHOICE_PIC_WIDTH * 0.5, y = CHOICE_PIC_HEIGHT * 0.5},
										{width = CHOICE_PIC_WIDTH, height = CHOICE_PIC_HEIGHT, x = CHOICE_PIC_WIDTH * 1.5, y = CHOICE_PIC_HEIGHT * 0.5},
										{width = CHOICE_PIC_WIDTH, height = CHOICE_PIC_HEIGHT, x = CHOICE_PIC_WIDTH * 0.5, y = CHOICE_PIC_HEIGHT * 1.5},
										{width = CHOICE_PIC_WIDTH, height = CHOICE_PIC_HEIGHT, x = CHOICE_PIC_WIDTH * 1.5, y = CHOICE_PIC_HEIGHT * 1.5},
									},
								}
local COUNT_DOWN_PIC = {
							LOCAL_SETTINGS.RES_DIR .. "num3.png",
							LOCAL_SETTINGS.RES_DIR .. "num2.png",
							LOCAL_SETTINGS.RES_DIR .. "num1.png",
						}

local MEDAL_COLOR = {
						{245/255, 210/255, 0},
						{195/255, 195/255, 195/255},
						{165/255, 49/255, 0},
						{92/255, 92/255, 92/255}
					}
local MEDAL_BLOCK_FILENAME = {
								"gold.png",
								"silver.png",
								"bronze.png",
								"grey.png",
							}

local POST_CHANGE_HEIGHT_TRANSITION_TIME = 200
local SHOW_RESULT_TRANSITION_TIME = 1000
local RESULT_BG_FADE_OUT_TIME = 300
local EXPIRE_TIMER_REFRESH_TIME = 1000
local CREATED_AT_TIMER_REFRESH_TIME = 60000		-- 1 minute

local EXPIRE_TIME_MAX_VALUE = 9999999999
---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
local creatorMask = graphics.newMask(USER_IMG_PATH .. "creatorMask.png")
local twoChoiceMask = graphics.newMask(LOCAL_SETTINGS.RES_DIR .. "twoChoiceMask.png")
local fourChoiceMask = graphics.newMask(LOCAL_SETTINGS.RES_DIR .. "fourChoiceMask.png")
local choiceBgMask = graphics.newMask(LOCAL_SETTINGS.RES_DIR .. "choiceBgMask.png")
local largeChoiceMask = graphics.newMask(LOCAL_SETTINGS.RES_DIR .. "largeChoiceMask.png")
local couponPicMask = graphics.newMask(LOCAL_SETTINGS.RES_DIR .. "couponPicMask.png")
local postDetailPicMask = graphics.newMask(LOCAL_SETTINGS.RES_DIR .. "postDetailPicMask.png")
local postHiddenPartMask = graphics.newMask(LOCAL_SETTINGS.RES_DIR .. "postHiddenPartMask.png")

local expireTimerList = {}
local expireTimer
local createdAtTimerList = {}
local createdAtTimer

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
local postView = {}

local function scaleImageFillArea(img, width, height)
	local newScale = img.xScale
	newScale = width / img.contentWidth
	if ((height / img.contentHeight) > newScale) then
		newScale = height / img.contentHeight
	end
	img.xScale = newScale
	img.yScale = newScale
	return img
end

local function insertCreatorImg(postGroup, fileInfo, touchListener)
	if (postGroup.parent) then
		local img = display.newImage(fileInfo.path, fileInfo.baseDir, true)
		if (img) then
			local imgBg = display.newCircle(postGroup, CREATOR_PIC_X, CREATOR_PIC_Y, 50)
			postGroup:insert(img)
			local imgOriginalScale = img.xScale
			img = scaleImageFillArea(img, 100, 100)
			img:setMask(creatorMask)
			img.maskScaleX = imgOriginalScale / img.xScale
			img.maskScaleY = imgOriginalScale / img.yScale
			img.x = CREATOR_PIC_X
			img.y = CREATOR_PIC_Y
			if (touchListener) then
				imgBg:addEventListener("touch", touchListener)
			end
		end
		return img
	end
	return nil
end

local function insertPostDetailPic(postDetailGroup, fileInfo, posY, postDetailPicPlaceHolderBg, postDetailPicPlaceHolderFg, touchListener)
	if (postDetailGroup.parent) then
		local img = display.newImage(postDetailGroup, fileInfo.path, fileInfo.baseDir, true)
		if (img) then
			display.remove(postDetailPicPlaceHolderBg)
			display.remove(postDetailPicPlaceHolderFg)
			local imgOriginalScale = img.xScale
			local newScale = POST_DETAIL_PIC_HEIGHT / img.contentHeight
			img.xScale = newScale
			img.yScale = newScale
			img:setMask(postDetailPicMask)
			img.maskScaleX = imgOriginalScale / img.xScale
			img.maskScaleY = imgOriginalScale / img.yScale
			img.x = display.contentWidth * 0.5
			img.y = posY
			img.anchorY = 0
			img:addEventListener("touch", touchListener)
		end
		return img
	end
	return nil
end

local function convertNumToNotationString(num)
	if (type(num) == "number") then
		if (num > 1000000) then			-- 1M
			return string.format("%d.%02dM", math.floor(num / 1000000), math.floor(num / 10000) % 100)
		elseif (num > 1000) then			-- 1M
			return string.format("%d.%02dk", math.floor(num / 1000), math.floor(num / 10) % 100)
		end
		return tostring(num)
	end
	return "0"
end

local function refreshExpireTimer(expireTimerTable)
	if (expireTimerTable.textObject.parent == nil) then
		return false
	end
	if (expireTimerTable.remainTime > 1800) then		-- more than 30 mins
		expireTimerTable.textObject.text = localization.getLocalization("expireTime_MoreThan30Mins")
		expireTimerTable.textObject:setFillColor(0, 0.7, 0)
	elseif (expireTimerTable.remainTime <= 0) then
		expireTimerTable.textObject.text = localization.getLocalization("expireTime_Expired")
		expireTimerTable.textObject:setFillColor(1, 0, 0)
		return false
	else
		local remainMins = math.floor(expireTimerTable.remainTime / 60)
		local remainSecs = math.floor(expireTimerTable.remainTime % 60)
		expireTimerTable.textObject.text = localization.getLocalization("expireTime_Remain") .. string.format("%02d:%02d", remainMins, remainSecs)
		expireTimerTable.textObject:setFillColor(0, 0.7, 0)
	end
	return true
end

local function expireTimerEvent()
	local expireTimerListTotal = #expireTimerList
	local i = 1
	while (i <= expireTimerListTotal) do
		local expireTimerTable = expireTimerList[i]
		expireTimerTable.remainTime = expireTimerTable.remainTime - 1
		if (refreshExpireTimer(expireTimerTable)) then
			i = i + 1
		else
			expireTimerList[i] = expireTimerList[expireTimerListTotal]
			expireTimerList[expireTimerListTotal] = nil
			expireTimerListTotal = expireTimerListTotal - 1
		end
	end
	if (expireTimerListTotal == 0) then
		if (expireTimer) then
			timer.cancel(expireTimer)
			expireTimer = nil
		end
	end
end

local function expireTimerRestart()
	local curTime = os.time()
	local expireTimerListTotal = #expireTimerList
	local i = 1
	while (i <= expireTimerListTotal) do
		local expireTimerTable = expireTimerList[i]
		expireTimerTable.remainTime = expireTimerTable.expireTime - curTime
		if (refreshExpireTimer(expireTimerTable)) then
			i = i + 1
		else
			expireTimerList[i] = expireTimerList[expireTimerListTotal]
			expireTimerList[expireTimerListTotal] = nil
			expireTimerListTotal = expireTimerListTotal - 1
		end
	end
	if (expireTimerListTotal > 0) then
		if (expireTimer) then
			timer.cancel(expireTimer)
		end
		expireTimer = timer.performWithDelay(EXPIRE_TIMER_REFRESH_TIME, expireTimerEvent, 0)
	end
end

local function addExpireTimerTable(expireTime, textObject, curTime)
	local newTable = {
						textObject = textObject,
						expireTime = expireTime,
						remainTime = expireTime - curTime,
					}
	if (refreshExpireTimer(newTable)) then
		local expireTimerListTotal = #expireTimerList
		expireTimerList[expireTimerListTotal + 1] = newTable
		if (expireTimer == nil) then
			expireTimer = timer.performWithDelay(EXPIRE_TIMER_REFRESH_TIME, expireTimerEvent, 0)
		end
	end
end

local function refreshCreatedAtTimer(createdAtTimerTable, curTime, forceRefreshLayout)
	local textObject = createdAtTimerTable.textObject
	if (textObject.parent == nil) then
		return false
	end
	local isKeepRefreshing = true
	local createdAtStr, diffTime = fncForLocalization.getPostCreatedAt(createdAtTimerTable.createdAt, createdAtTimerTable.lastDiffTime, curTime)
	if (createdAtStr == nil) then
		isKeepRefreshing = false
	else
		forceRefreshLayout = true
	end
	if (forceRefreshLayout) then
		if (createdAtStr) then
			textObject.text = createdAtStr
		end
		createdAtTimerTable.lastDiffTime = diffTime
		local tagXLeftRef = textObject.x + textObject.contentWidth
		createdAtTimerTable.tagText.x = (tagXLeftRef + createdAtTimerTable.tagXRightRef) * 0.5
	end
	return isKeepRefreshing
end

local function createdAtTimerEvent()
	local createdAtTimerListTotal = #createdAtTimerList
	local i = 1
	while (i <= createdAtTimerListTotal) do
		local createdAtTimerTable = createdAtTimerList[i]
		if (refreshCreatedAtTimer(createdAtTimerTable, curTime)) then
			i = i + 1
		else
			createdAtTimerList[i] = createdAtTimerList[createdAtTimerListTotal]
			createdAtTimerList[createdAtTimerListTotal] = nil
			createdAtTimerListTotal = createdAtTimerListTotal - 1
		end
	end
	if (createdAtTimerListTotal == 0) then
		if (createdAtTimer) then
			timer.cancel(createdAtTimer)
			createdAtTimer = nil
		end
	end
end

local function creratedAtTimerRestart()
	local curTime = os.time()
	local createdAtTimerListTotal = #createdAtTimerList
	local i = 1
	while (i <= createdAtTimerListTotal) do
		local createdAtTimerTable = createdAtTimerList[i]
		if (refreshCreatedAtTimer(createdAtTimerTable, curTime)) then
			i = i + 1
		else
			createdAtTimerList[i] = createdAtTimerList[createdAtTimerListTotal]
			createdAtTimerList[createdAtTimerListTotal] = nil
			createdAtTimerListTotal = createdAtTimerListTotal - 1
		end
	end
	if (createdAtTimerListTotal > 0) then
		if (createdAtTimer) then
			timer.cancel(createdAtTimer)
		end
		createdAtTimer = timer.performWithDelay(CREATED_AT_TIMER_REFRESH_TIME, createdAtTimerEvent, 0)
	end
end

local function addCreatedAtTimerTable(createdAt, textObject, tagText, tagXRightRef, curTime)
	local newTable = {
						textObject = textObject,
						createdAt = createdAt,
						tagText = tagText,
						tagXRightRef = tagXRightRef,
					}
	if (refreshCreatedAtTimer(newTable, curTime)) then
		local createdAtTimerListTotal = #createdAtTimerList
		createdAtTimerList[createdAtTimerListTotal + 1] = newTable
		if (createdAtTimer == nil) then
			createdAtTimer = timer.performWithDelay(CREATED_AT_TIMER_REFRESH_TIME, createdAtTimerEvent, 0)
		end
	end
end

local function getPostHeightAndDetailPos(postBasicPartHeight, resultGroup, resultGroupHeight, detailGroup, detailGroupHeight)
	local postHeight = postBasicPartHeight
	local detailPartPos
	if (resultGroup.isHidden ~= true) then
		postHeight = postHeight + resultGroupHeight
	end
	detailPartPos = postHeight
	if (detailGroup ~= nil) then
		if (detailGroup.isHidden ~= true) then
			postHeight = postHeight + detailGroupHeight
		else
			detailPartPos = detailPartPos - detailGroupHeight
		end
		postHeight = postHeight + POST_DETAIL_DEFAULT_MIN_HEIGHT
	end
	return postHeight, detailPartPos
end

local function resultGroupDisplayResult(resultGroup, isHideResult, resultGroupDisplayHeight, choiceData, isAnimating)
	if (resultGroup.isHaveResult == true) then
		isAnimating = false
	end
	if (isHideResult) then
		local couponInstructionTextOption = {
												parent = resultGroup,
												text = localization.getLocalization("post_PleaseGoToSettingRedemptionToSeeCoupon"),
												x = display.contentWidth * 0.5,
												y = resultGroupDisplayHeight * 0.4,
												width = display.contentWidth * 0.8,
												height = 0,
												font = POST_VIEW_COMMON_FONT,
												fontSize = POST_COUPON_TEXT_FONTSIZE,
												align = "center",
											}
		local couponInstructionText = display.newText(couponInstructionTextOption)
		couponInstructionText:setFillColor(1, 0, 0)
		if (isAnimating) then
			couponInstructionText.alpha = 0
			transition.to(couponInstructionText, {alpha = 1, time = SHOW_RESULT_TRANSITION_TIME, transition = easing.outSine})
		end
	else
		local totalVoted, totalVotedMale, totalVotedFemale = 0, 0, 0
		local pieChartData = {}
		local medalTable = {}
		local resultText = display.newText(resultGroup, localization.getLocalization("post_Result"), display.contentWidth * 0.5, 35, POST_VIEW_COMMON_FONT, RESULT_TITLE_FONTSIZE)
		resultText:setFillColor(0)
		local choiceTotal = 1
		while (choiceTotal <= 4) do
			local currentChoiceData = choiceData[CHOICE_LETTER_TABLE[choiceTotal]]
			if (currentChoiceData == nil) then
				choiceTotal = choiceTotal - 1
				break
			end
			totalVoted = totalVoted + currentChoiceData.count.total
			totalVotedMale = totalVotedMale + currentChoiceData.count.male
			totalVotedFemale = totalVotedFemale + currentChoiceData.count.female
			local medalIdx = #medalTable
			while (medalIdx >= 1) do
				local curMedal = medalTable[medalIdx]
				if (curMedal.vote > currentChoiceData.count.total) then
					local newMedal = {choice = {CHOICE_LETTER_TABLE[choiceTotal]}, vote = currentChoiceData.count.total}
					table.insert(medalTable, medalIdx + 1, newMedal)
					break
				elseif (curMedal.vote == currentChoiceData.count.total) then
					curMedal.choice[#curMedal.choice + 1] = CHOICE_LETTER_TABLE[choiceTotal]
					break
				end
				medalIdx = medalIdx - 1
			end
			if (medalIdx == 0) then
				local newMedal = {choice = {CHOICE_LETTER_TABLE[choiceTotal]}, vote = currentChoiceData.count.total}
				table.insert(medalTable, 1, newMedal)
			end
			choiceTotal = choiceTotal + 1
		end
		if (choiceTotal > 4) then
			choiceTotal = 4
		end
		if (totalVoted > 0) then
			local pieChartDataTotalPercentage = 0
			local pieChartDataCount = 0
			for i = 1, #medalTable do
				local medalChoiceList = medalTable[i].choice
				for j = 1, #medalChoiceList do
					local currentChoiceData = choiceData[medalChoiceList[j]]
					local curChoicePercentage = math.floor(currentChoiceData.count.total * 100 / totalVoted + 0.5)
					pieChartDataTotalPercentage = pieChartDataTotalPercentage + curChoicePercentage
					pieChartDataCount = pieChartDataCount + 1
					pieChartData[pieChartDataCount] = {
															percentage = curChoicePercentage,
															color = MEDAL_COLOR[i],
														}
					local choiceMedalBlock = display.newImage(resultGroup, LOCAL_SETTINGS.RES_DIR .. MEDAL_BLOCK_FILENAME[i], true)
					choiceMedalBlock.anchorX = 0
					choiceMedalBlock.x = RESULT_VOTE_LIST_X
					if (choiceTotal <= 2) then
						choiceMedalBlock.y = RESULT_VOTE_LIST_Y[pieChartDataCount + 1]
					else
						choiceMedalBlock.y = RESULT_VOTE_LIST_Y[pieChartDataCount]
					end
					local choiceLetterText = display.newText(resultGroup, medalChoiceList[j], RESULT_VOTE_LIST_X + 50, choiceMedalBlock.y, POST_VIEW_COMMON_FONT, RESULT_VOTE_LIST_FONTSIZE)
					choiceLetterText:setFillColor(0)
					local choicePercentText = display.newText(resultGroup, tostring(curChoicePercentage) .. "%", RESULT_VOTE_LIST_X + 110, choiceMedalBlock.y, POST_VIEW_COMMON_FONT, RESULT_VOTE_LIST_FONTSIZE)
					choicePercentText:setFillColor(0)
				end
			end
			if (pieChartDataTotalPercentage < 100) then
				pieChartData[1].percentage = pieChartData[1].percentage + (100 - pieChartDataTotalPercentage)
			end
			local pieChartOption = {
										radius = 124,
										values = pieChartData,
										mask = {path = LOCAL_SETTINGS.RES_DIR .. "pieChartMask.png"},
									}
			if (isAnimating) then
				pieChartOption.time = SHOW_RESULT_TRANSITION_TIME
				pieChartOption.transition = easing.outSine
			end
			local resultPieChart = pieChart.create(pieChartOption)
			resultPieChart.x = RESULT_PIE_CHART_X
			resultPieChart.y = RESULT_PIE_CHART_Y
			resultGroup:insert(resultPieChart)
		else
			for i = 1, choiceTotal do
				local choiceMedalBlock = display.newImage(resultGroup, LOCAL_SETTINGS.RES_DIR .. "grey.png", true)
				choiceMedalBlock.anchorX = 0
				choiceMedalBlock.x = RESULT_VOTE_LIST_X
				if (choiceTotal <= 2) then
					choiceMedalBlock.y = RESULT_VOTE_LIST_Y[i + 1]
				else
					choiceMedalBlock.y = RESULT_VOTE_LIST_Y[i]
				end
				local choiceLetterText = display.newText(resultGroup, CHOICE_LETTER_TABLE[i], RESULT_VOTE_LIST_X + 50, choiceMedalBlock.y, POST_VIEW_COMMON_FONT, RESULT_VOTE_LIST_FONTSIZE)
				choiceLetterText:setFillColor(0)
				local choicePercentText = display.newText(resultGroup, "0%", RESULT_VOTE_LIST_X + 110, choiceMedalBlock.y, POST_VIEW_COMMON_FONT, RESULT_VOTE_LIST_FONTSIZE)
				choicePercentText:setFillColor(0)
			end
		end
		local pieChartShadow = display.newImage(resultGroup, LOCAL_SETTINGS.RES_DIR .. "pieChartShadow.png", true)
		pieChartShadow.x = RESULT_PIE_CHART_X
		pieChartShadow.y = RESULT_PIE_CHART_Y
		local whiteCircle = display.newCircle(resultGroup, RESULT_PIE_CHART_X, RESULT_PIE_CHART_Y, 90)
		whiteCircle:setFillColor(1)

		if (totalVoted > 0) then
			local crown = display.newImage(resultGroup, LOCAL_SETTINGS.RES_DIR .. "crown.png", true)
			crown.anchorY = 1
			crown.x = RESULT_PIE_CHART_X
			crown.y = RESULT_PIE_CHART_Y - 10
			local goldChoiceText
			local goldChoiceFontSize = 45
			local goldChoiceTextOffsetY = 0
			if (#medalTable == 1) then
				goldChoiceText = display.newText(resultGroup, localization.getLocalization("post_same"), RESULT_PIE_CHART_X, RESULT_PIE_CHART_Y, POST_VIEW_COMMON_FONT, goldChoiceFontSize)
			else
				local goldChoiceArray = medalTable[1].choice
				local goldChoiceTotal = #goldChoiceArray
				local goldChoiceTextStr = goldChoiceArray[1]
				for i = 2, goldChoiceTotal do
					goldChoiceTextStr = goldChoiceTextStr .. " " .. goldChoiceArray[i]
				end
				if (goldChoiceTotal <= 1) then
					goldChoiceTextOffsetY = -5
					goldChoiceFontSize = 55
				elseif (goldChoiceTotal <= 2) then
					goldChoiceFontSize = 50
				end
				goldChoiceText = display.newText(resultGroup, goldChoiceTextStr, RESULT_PIE_CHART_X, RESULT_PIE_CHART_Y + goldChoiceTextOffsetY, POST_VIEW_COMMON_FONT, goldChoiceFontSize)
			end
			goldChoiceText.anchorY = 0
			goldChoiceText:setFillColor(0)
		else
			local noVoteTextOption = {
										parent = resultGroup,
										text = localization.getLocalization("post_noVote"),
										x = RESULT_PIE_CHART_X,
										y = RESULT_PIE_CHART_Y,
										width = 150,
										height = 0,
										font = POST_VIEW_COMMON_FONT,
										fontSize = RESULT_NO_VOTE_FONTSIZE,
										align = "center",
									}
			local noVoteText = display.newText(noVoteTextOption)
			noVoteText:setFillColor(0)
		end
		local resultGenderBg = display.newRect(resultGroup, display.contentWidth * 0.5, RESULT_VOTE_GENDER_Y, RESULT_VOTE_GENDER_BG_WIDTH, RESULT_VOTE_GENDER_BG_HEIGHT)
		resultGenderBg:setFillColor(0.9)
		local totalVotedMaleRatio, totalVotedFemaleRatio = 0, 0
		local totalVotedGender = totalVotedMale + totalVotedFemale
		if (totalVotedGender > 0) then
			totalVotedMaleRatio = totalVotedMale / totalVotedGender
			totalVotedFemaleRatio = totalVotedFemale / totalVotedGender
		end
		local resultMaleBar
		local resultMaleBarX = resultGenderBg.x + RESULT_VOTE_GENDER_BG_WIDTH * 0.5
		local resultMaleBarWidth = RESULT_VOTE_GENDER_BG_WIDTH * totalVotedMaleRatio
		local resultFemaleBar
		local resultFemaleBarX = resultGenderBg.x - RESULT_VOTE_GENDER_BG_WIDTH * 0.5
		local resultFemaleBarWidth = RESULT_VOTE_GENDER_BG_WIDTH * totalVotedFemaleRatio
		if (totalVotedFemaleRatio > 0) then
			if (isAnimating) then
				resultFemaleBar = display.newRect(resultGroup, resultFemaleBarX, RESULT_VOTE_GENDER_Y, 0, RESULT_VOTE_GENDER_BG_HEIGHT)
				transition.to(resultFemaleBar, {width = resultFemaleBarWidth, time = SHOW_RESULT_TRANSITION_TIME, transition = easing.outSine})
			else
				resultFemaleBar = display.newRect(resultGroup, resultFemaleBarX, RESULT_VOTE_GENDER_Y, resultFemaleBarWidth, RESULT_VOTE_GENDER_BG_HEIGHT)
			end
			resultFemaleBar.anchorX = 0
			resultFemaleBar:setFillColor(unpack(RESULT_VOTE_FEMALE_COLOR))
		end
		if (totalVotedMaleRatio > 0) then
			if (isAnimating) then
				resultMaleBar = display.newRect(resultGroup, resultMaleBarX, RESULT_VOTE_GENDER_Y, 0, RESULT_VOTE_GENDER_BG_HEIGHT)
				transition.to(resultMaleBar, {width = resultMaleBarWidth, time = SHOW_RESULT_TRANSITION_TIME, transition = easing.outSine})
			else
				resultMaleBar = display.newRect(resultGroup, resultMaleBarX, RESULT_VOTE_GENDER_Y, resultMaleBarWidth, RESULT_VOTE_GENDER_BG_HEIGHT)
			end
			resultMaleBar.anchorX = 1
			resultMaleBar:setFillColor(unpack(RESULT_VOTE_MALE_COLOR))
		end
		local resultFemaleText = display.newText(resultGroup, localization.getLocalization("post_femaleLetter"), resultFemaleBarX - 35, RESULT_VOTE_GENDER_Y - 12, POST_VIEW_COMMON_FONT, 18)
		resultFemaleText:setFillColor(unpack(RESULT_VOTE_FEMALE_COLOR))
		local resultFemalePercentText = display.newText(resultGroup, tostring(math.floor(totalVotedFemaleRatio * 100)) .. "%", resultFemaleBarX - 35, RESULT_VOTE_GENDER_Y + 12, POST_VIEW_COMMON_FONT, 18)
		resultFemalePercentText:setFillColor(unpack(RESULT_VOTE_FEMALE_COLOR))
		local resultMaleText = display.newText(resultGroup, localization.getLocalization("post_maleLetter"), resultMaleBarX + 35, RESULT_VOTE_GENDER_Y - 12, POST_VIEW_COMMON_FONT, 18)
		resultMaleText:setFillColor(unpack(RESULT_VOTE_MALE_COLOR))
		local resultMalePercentText = display.newText(resultGroup, tostring(math.floor(totalVotedMaleRatio * 100)) .. "%", resultMaleBarX + 35, RESULT_VOTE_GENDER_Y + 12, POST_VIEW_COMMON_FONT, 18)
		resultMalePercentText:setFillColor(unpack(RESULT_VOTE_MALE_COLOR))
		if (isAnimating) then
			resultGroup.alpha = 0
			transition.to(resultGroup, {alpha = 1, time = SHOW_RESULT_TRANSITION_TIME * 0.5, transition = easing.outSine})
		end
		resultGroup.isHaveResult = true
	end
end


---------------------------------------------------------------
-- Horizontal Scroll View
---------------------------------------------------------------
local function getTouchSpeed(newX, lastX, timeDiff)
	if ((newX ~= nil) and (lastX ~= nil) and (timeDiff <= MAX_TIME_FOR_TOUCH_SPEED)) then
		return (newX - lastX) / timeDiff
	end
end

local function horScrollViewObjIndexToX(index)
	return -((CHOICE_PIC_OBJECT_WIDTH + CHOICE_PIC_OBJECT_SPACE) * (index - 1))
end

local function horScrollViewXToRegionIndex(scrollView, scrollViewScrollWidth, offsetX)
	local scrollViewX, scrollViewY = scrollView:getContentPosition()
	if (scrollViewX > 0) then
		return 1
	elseif (scrollViewX < -(scrollViewScrollWidth - display.contentWidth + offsetX)) then
		scrollViewX = -(scrollViewScrollWidth - display.contentWidth + offsetX)
	end
	return math.floor(-(scrollViewX - offsetX) /  (CHOICE_PIC_OBJECT_WIDTH + CHOICE_PIC_OBJECT_SPACE)) + 1
end

local function insertBgToChoiceGroup(choiceGroup, choicePosAndSize, origBg, img)
	local imgX, imgY = CHOICE_PIC_WIDTH - choicePosAndSize.x, CHOICE_PIC_HEIGHT - choicePosAndSize.y
	if ((origBg ~= nil) and (origBg.parent ~= nil)) then
		origBg.alpha = 0
	end
	if (img) then
		local choiceBgCover = display.newRect(choiceGroup, 0, 0, choicePosAndSize.width, choicePosAndSize.height)
		choiceBgCover.alpha = 0.7
		choiceBgCover:toBack()
	else
		img = display.newImage(LOCAL_SETTINGS.RES_DIR .. "choiceSelectGroupBg.png", true)
	end
	local imgOriginalScale = img.xScale
	img = scaleImageFillArea(img, CHOICE_PIC_WIDTH * 2, CHOICE_PIC_HEIGHT * 2, 1)
	if (choicePosAndSize.height > CHOICE_PIC_HEIGHT + 1) then
		img:setMask(twoChoiceMask)
	else
		img:setMask(fourChoiceMask)
	end
	img.maskScaleX = imgOriginalScale / img.xScale
	img.maskScaleY = imgOriginalScale / img.yScale
	img.x = imgX
	img.y = imgY
	img.maskX = -imgX / img.xScale
	img.maskY = -imgY / img.yScale
	choiceGroup:insert(img)
	img:toBack()
	return img
end

local function createPostChoiceScrollView(parentScrollView, postData, userId, isHideResult, votingListener)
	local postId = postData.id
	local choiceTable = postData.choices
	local userVoted = postData.userVoted
	local choiceTotal = #CHOICE_LETTER_TABLE
	-- local choiceDisplayLayoutSize = 4
	local choicePicTotal = 0
	local horizontalScrollViewXMax = 0
	local horizontalScrollViewScrollWidth = 0
	local choiceSelectGroup = display.newGroup()
	local choiceSelectGroupX2
	local countDownTransition = nil
	local countDownPic = nil
	local countDownPic2 = nil
	choiceSelectGroup.choicePicGroup = {}
	for i = 2, #CHOICE_LETTER_TABLE do
		if (choiceTable[CHOICE_LETTER_TABLE[i]] == nil) then
			choiceTotal = i - 1
			break
		end
	end
	-- if (choiceTable[CHOICE_LETTER_TABLE[3]] == nil) then
	-- 	choiceDisplayLayoutSize = 2
	-- end
	local function horScrollViewListener(event)
		if (event.phase == "began") then
			event.target.isNotVerticalScroll = false
		end
		if (event.target.isNotVerticalScroll ~= true) then
			if (event.x ~= nil) then
				if (math.abs(event.xStart - event.x) < 10) then
					if ((parentScrollView ~= nil) and (parentScrollView.parent ~= nil)) then
						if (parentScrollView:checkFocusToScrollView(event) == true) then
							return false
						end
					end
				else
					event.target.isNotVerticalScroll = true
				end
			end
		end
		local scrollViewX, scrollViewY = event.target:getContentPosition()
		if (event.phase == "began") then
			event.target.lastX = event.xStart
			event.target.lastTime = event.time
		elseif (event.phase == "moved") then
			if ((event.target.lastTime ~= nil) and (event.target.lastX ~= nil)) then
				event.target.lastSpeed = getTouchSpeed(event.x, event.target.lastX, event.time - event.target.lastTime)
			end
			event.target.lastX = event.x
			event.target.lastTime = event.time
			if (choicePicTotal > 1) then
				if (scrollViewX > display.contentWidth * -1.5) then
					choiceSelectGroup.x = display.contentWidth * 0.5 - CHOICE_PIC_WIDTH
				else
					if (choicePicTotal >= 1) then
						choiceSelectGroup.x = choiceSelectGroupX2
					end
				end
			end
		elseif (event.phase == "ended") then
			local scrollToX
			if (event.time - event.target.lastTime < MAX_TIME_FOR_TOUCH_SPEED) then
				if ((event.target.lastSpeed) and (choicePicTotal >= 1)) then
					local region = horScrollViewXToRegionIndex(event.target, horizontalScrollViewScrollWidth, 0)
					if (event.target.lastSpeed > TOUCH_MIN_SPEED_TRIGGER) then
						scrollToX = horScrollViewObjIndexToX(region)
					elseif (event.target.lastSpeed < -TOUCH_MIN_SPEED_TRIGGER) then
						local indexToPos = region + 1
						if (choicePicTotal > 1) then
							if (indexToPos > choicePicTotal + 2) then
								indexToPos = choicePicTotal + 2
							end
						elseif (choicePicTotal == 1) then
							if (indexToPos > 2) then
								indexToPos = 2
							end
						end
						scrollToX = horScrollViewObjIndexToX(indexToPos)
					end
				end
			end
			if (scrollToX ==  nil) then
				local region = horScrollViewXToRegionIndex(event.target, horizontalScrollViewScrollWidth, display.contentWidth * 0.5)
				scrollToX = horScrollViewObjIndexToX(region)
			end
			event.target:scrollToPosition{
											x = scrollToX,
											time = 200,
										}
			if (choicePicTotal > 1) then
				if (scrollToX > display.contentWidth * -1.5) then
					choiceSelectGroup.x = display.contentWidth * 0.5 - CHOICE_PIC_WIDTH
				else
					if (choicePicTotal >= 1) then
						choiceSelectGroup.x = choiceSelectGroupX2
					end
				end
			end
		end
	end
	local horizontalScrollView = widget.newScrollView
	{
		left = 0,
		top = 0,
		width = display.contentWidth,
		height = HOR_SCROLL_HEIGHT,
		verticalScrollDisabled = true,
		hideBackground = true,
		-- backgroundColor = {0, 1, 0},
		listener = horScrollViewListener,
	}
	local function checkScrollViewFocus(event)
		if (event.phase == "began") then
			if (horizontalScrollView:getView()._velocity ~= 0) then
				horizontalScrollView:takeFocus(event)
				return true
			end
		end
		if (event.x ~= nil) then
			if (math.abs(event.xStart - event.x) < 10) then
				if ((parentScrollView ~= nil) and (parentScrollView.parent ~= nil)) then
					if (parentScrollView:checkFocusToScrollView(event) == true) then
						return true
					end
				end
			else
				horizontalScrollView:takeFocus(event)
				return true
			end
		end
		return false
	end
	local function countDownTransitionListener(obj)
		local isJustVoted = (obj.picIndex == 0)
		countDownTransition = nil
		if (obj.parent) then
			local picIndex = obj.picIndex
			local choice = obj.choice
			local choiceId = obj.choiceId
			local votingListener = obj.votingListener
			if (picIndex >= #COUNT_DOWN_PIC) then
				display.remove(countDownPic)
				display.remove(countDownPic2)
				userVoted = CHOICE_LETTER_TABLE[choice]
				votingListener(choiceId)
			else
				local parent = obj.parent
				picIndex = picIndex + 1
				display.remove(countDownPic)
				display.remove(countDownPic2)
				countDownPic = display.newImage(parent, COUNT_DOWN_PIC[picIndex], true)
				countDownPic2 = display.newImage(COUNT_DOWN_PIC[picIndex], true)
				countDownPic.picIndex = picIndex
				countDownPic.choice = choice
				countDownPic.choiceId = choiceId
				countDownPic.votingListener = votingListener
				transition.to(countDownPic2, {alpha = 0, time = 1000})
				countDownTransition = transition.to(countDownPic, {alpha = 0, time = 1000, onComplete = countDownTransitionListener})
				votingListener(choiceId, countDownPic2, isJustVoted)
			end
		end
	end
	local choicePicArrayForImageViewer = {}
	local choicePicPath = {}
	local choiceLargePicList = {}
	local choiceGroupList = {}
	-- local choiceSelectGroupBgGroup = display.newGroup()
	-- choiceSelectGroup:insert(choiceSelectGroupBgGroup)
	-- choiceSelectGroupBgGroup.x = CHOICE_PIC_WIDTH
	-- choiceSelectGroupBgGroup.y = CHOICE_PIC_HEIGHT
	-- -- Choice background
	-- if ((postData.post_pic ~= nil) and (postData.post_pic ~= "")) then
	-- 	local choiceBgPlaceHolderBg, choiceBgPlaceHolderFg
	-- 	local choiceBgCover = display.newRect(choiceSelectGroupBgGroup, 0, 0, CHOICE_PIC_WIDTH * 2, CHOICE_PIC_HEIGHT * 2)
	-- 	choiceBgCover.alpha = 0.7
	-- 	local postPicPath = "post/" .. tostring(postData.id) .. "/img"
	-- 	local function insertChoiceBg(fileInfo)
	-- 		if (choiceSelectGroupBgGroup.parent) then
	-- 			choiceBg = display.newImage(choiceSelectGroupBgGroup, fileInfo.path, fileInfo.baseDir, true)
	-- 			if (choiceBg) then
	-- 				choiceBg:toBack()
	-- 				display.remove(choiceBgPlaceHolderBg)
	-- 				choiceBgPlaceHolderBg = nil
	-- 				display.remove(choiceBgPlaceHolderFg)
	-- 				choiceBgPlaceHolderFg = nil
	-- 				local imgOriginalScale = choiceBg.xScale
	-- 				choiceBg = scaleImageFillArea(choiceBg, CHOICE_PIC_WIDTH * 2, CHOICE_PIC_HEIGHT * 2)
	-- 				choiceBg:setMask(choiceBgMask)
	-- 				choiceBg.maskScaleX = imgOriginalScale / choiceBg.xScale
	-- 				choiceBg.maskScaleY = imgOriginalScale / choiceBg.yScale
	-- 			end
	-- 		end
	-- 	end
	-- 	local function postPicListener(event)
	-- 		if (event.isError) then
	-- 		elseif (event.phase == "ended") then
	-- 			insertChoiceBg({path = event.path, baseDir = event.baseDir})
	-- 		end
	-- 	end
	-- 	-- local postDetailPicInfo = networkFile.getDownloadFile(postData.post_pic, postPicPath, postPicListener)
	-- 	local postDetailPicInfo = networkFunction.getVorumFile(postData.post_pic, postPicPath, postPicListener)
	-- 	if (postDetailPicInfo ~= nil) then
	-- 		if (postDetailPicInfo.request) then
	-- 			choiceBgPlaceHolderBg = display.newRect(choiceSelectGroupBgGroup, 0, 0, CHOICE_PIC_WIDTH * 2, CHOICE_PIC_HEIGHT * 2)
	-- 			choiceBgPlaceHolderBg:setFillColor(187/255, 235/255, 255/255)
	-- 			choiceBgPlaceHolderFg = display.newImageRect(choiceSelectGroupBgGroup, LOCAL_SETTINGS.RES_DIR .. "placeholder.png", 150, 150)
	-- 		else
	-- 			insertChoiceBg(postDetailPicInfo)
	-- 		end
	-- 	end
	-- else
	-- 	display.newImage(choiceSelectGroupBgGroup, LOCAL_SETTINGS.RES_DIR .. "choiceSelectGroupBg.png", true)
	-- end

	function horizontalScrollView.cancelPostCountDown()
		if (countDownTransition) then
			transition.cancel(countDownTransition)
			countDownTransition = nil
		end
		display.remove(countDownPic)
		display.remove(countDownPic2)
		countDownPic = nil
		countDownPic2 = nil
		for j = 1, 4 do
			if (choiceSelectGroup.choicePicGroup[j] == nil) then
				break
			end
			local curChoiceGp = choiceSelectGroup.choicePicGroup[j]
			curChoiceGp.xScale = 1
			curChoiceGp.yScale = 1
			-- if ((curChoiceGp.nonPicBg) and (curChoiceGp.nonPicBg.parent)) then
			-- 	curChoiceGp.nonPicBg.alpha = 0
			-- end
		end
	end

	function horizontalScrollView.getCountingDownChoice()
		if ((countDownPic ~= nil) and (countDownPic.choice)) then
			return {
						postId = postId,
						choice = countDownPic.choice,
					}
		end
		return nil
	end

	for i = 1, #CHOICE_LETTER_TABLE do
		local curChoice = choiceTable[CHOICE_LETTER_TABLE[i]]
		local choiceTouchListener
		if (curChoice == nil) then
			break
		end
		local curChoiceId = curChoice.id
		local choicePicSizeAndPos = CHOICE_PIC_SIZE_AND_POS[choiceTotal][i]
		local choiceDisplayHeight = choicePicSizeAndPos.height
		local curChoiceGroup = display.newGroup()
		curChoiceGroup.groupHeight = choiceDisplayHeight
		choiceSelectGroup.choicePicGroup[i] = curChoiceGroup
		-- local picX = (CHOICE_PIC_WIDTH) * (1.5 - (i % 2))
		-- local picY = (choiceDisplayHeight) * (math.floor((i - 1) / 2) + 0.5)
		local picX = choicePicSizeAndPos.x
		local picY = choicePicSizeAndPos.y
		local picPlaceHolderBg
		local choicePic
		if ((curChoice.choice_pic == nil) or (curChoice.choice_pic == "")) then
			picPlaceHolderBg = display.newRect(curChoiceGroup, 0, 0, CHOICE_PIC_WIDTH, CHOICE_PIC_HEIGHT)
			picPlaceHolderBg.isHitTestable = true
			picPlaceHolderBg:setFillColor(187/255, 235/255, 255/255)
			picPlaceHolderBg.height = choiceDisplayHeight
			if ((postData.post_pic ~= nil) and (postData.post_pic ~= "")) then
				local postPicPath = "post/" .. tostring(postData.id) .. "/img"
				local function choiceBgListener(event)
					if (event.isError) then
						insertBgToChoiceGroup(curChoiceGroup, choicePicSizeAndPos, picPlaceHolderBg)
					elseif (event.phase == "ended") then
						choiceBg = display.newImage(event.path, event.baseDir, true)
						insertBgToChoiceGroup(curChoiceGroup, choicePicSizeAndPos, picPlaceHolderBg, choiceBg)
					end
				end
				local postDetailPicInfo = networkFunction.getVorumFile(postData.post_pic, postPicPath, choiceBgListener)
				if (postDetailPicInfo ~= nil) then
					if (postDetailPicInfo.request == nil) then
						choiceBg = display.newImage(postDetailPicInfo.path, postDetailPicInfo.baseDir, true)
						insertBgToChoiceGroup(curChoiceGroup, choicePicSizeAndPos, picPlaceHolderBg, choiceBg)
					end
				end
			else
				insertBgToChoiceGroup(curChoiceGroup, choicePicSizeAndPos, picPlaceHolderBg)
			end
			if (curChoice.text) then
				local textOption = {
										parent = curChoiceGroup,
										text = curChoice.text,
										y = -10,
										width = CHOICE_PIC_WIDTH - 10,
										font = POST_VIEW_COMMON_FONT,
										fontSize = CHOICE_LARGE_TEXT_FONTSIZE,
										align = "center",
									}
				local choiceText = display.newText(textOption)
				choiceText:setFillColor(0)
			end
		else
			picPlaceHolderBg = insertBgToChoiceGroup(curChoiceGroup, choicePicSizeAndPos, picPlaceHolderBg)
			-- picPlaceHolderBg = display.newRect(curChoiceGroup, 0, 0, CHOICE_PIC_WIDTH, choiceDisplayHeight)
			-- picPlaceHolderBg:setFillColor(187/255, 235/255, 255/255)
			local picPlaceHolderFg = display.newImageRect(curChoiceGroup, LOCAL_SETTINGS.RES_DIR .. "placeholder.png", 100, 100)
			local function insertChoicePic(fileInfo)
				if (curChoiceGroup.parent) then
					choicePic = display.newImage(fileInfo.path, fileInfo.baseDir, true)
					if (choicePic) then
						display.remove(picPlaceHolderFg)
						local imgOriginalScale = choicePic.xScale
						choicePic = scaleImageFillArea(choicePic, CHOICE_PIC_WIDTH, choiceDisplayHeight)
						-- if (choiceDisplayLayoutSize <= 2) then
						-- 	choicePic:setMask(twoChoiceMask)
						-- else
						-- 	choicePic:setMask(fourChoiceMask)
						-- end
						if (choiceDisplayHeight > CHOICE_PIC_HEIGHT + 1) then
							choicePic:setMask(twoChoiceMask)
						else
							choicePic:setMask(fourChoiceMask)
						end
						choicePic.maskScaleX = imgOriginalScale / choicePic.xScale
						choicePic.maskScaleY = imgOriginalScale / choicePic.yScale
						curChoiceGroup:insert(choicePic)
						choicePic:toBack()
						picPlaceHolderBg:toBack()
					end
				end
			end
			local function choicePicListener(event)
				if (event.isError) then
				elseif (event.phase == "ended") then
					insertChoicePic({path = event.path, baseDir = event.baseDir})
				end
			end
			local choicePicFilePath = "post/" .. tostring(postId) .. "/choiceImg" .. CHOICE_LETTER_TABLE[i]
			-- local choiceImgInfo = networkFile.getDownloadFile(curChoice.choice_pic, choicePicFilePath, choicePicListener)
			local choiceImgInfo = networkFunction.getVorumFile(curChoice.choice_pic, choicePicFilePath, choicePicListener)
			if ((choiceImgInfo ~= nil) and (choiceImgInfo.request == nil)) then
				insertChoicePic(choiceImgInfo)
			end
			choicePicArrayForImageViewer[#choicePicArrayForImageViewer + 1] = {path = choiceImgInfo.path, baseDir = choiceImgInfo.baseDir}
			choicePicPath[#choicePicPath + 1] = {url = curChoice.choice_pic, path = choicePicFilePath}
		end
		local choiceShadow = display.newImage(curChoiceGroup, LOCAL_SETTINGS.RES_DIR .. "choiceShadow.png", true)
		choiceShadow.y = choiceDisplayHeight * 0.5
		choiceShadow.anchorY = 1
		local choiceLetterOption = {
								parent = curChoiceGroup,
								text = CHOICE_LETTER_TABLE[i],
								x = 30 - CHOICE_PIC_WIDTH * 0.5,
								y = choiceShadow.y - 5,
								font = POST_VIEW_COMMON_FONT,
								fontSize = CHOICE_LETTER_FONTSIZE,
							}
		local choiceLetterText = display.newText(choiceLetterOption)
		choiceLetterText.anchorY = 1
		if (curChoice.text) then
			local choiceTextOption = {
									parent = curChoiceGroup,
									text = curChoice.text,
									x = 60 - CHOICE_PIC_WIDTH * 0.5,
									y = choiceShadow.y - 22,
									width = CHOICE_PIC_WIDTH * 0.7,
									font = POST_VIEW_COMMON_FONT,
									fontSize = CHOICE_TEXT_FONTSIZE,
								}
			local choiceText = display.newText(choiceTextOption)
			-- choiceText.anchorY = 1
			choiceText.anchorX = 0
		end
		choiceSelectGroup:insert(curChoiceGroup)
		curChoiceGroup.x = picX
		curChoiceGroup.y = picY
		if (userVoted == CHOICE_LETTER_TABLE[i]) then
			curChoiceGroup.xScale = CHOICE_PIC_SELECTED_SCALE
			curChoiceGroup.yScale = CHOICE_PIC_SELECTED_SCALE
			curChoiceGroup:toFront()
			-- if ((curChoiceGroup.nonPicBg) and (curChoiceGroup.nonPicBg.parent)) then
			-- 	curChoiceGroup.nonPicBg.alpha = 1
			-- end
		else
			curChoiceGroup:toBack()
			-- choiceSelectGroupBgGroup:toBack()
		end

		if (userVoted == nil) then
			choiceTouchListener = function(event)
				if (checkScrollViewFocus(event)) then
					return false
				end
				if ((event.phase == "ended") and (userVoted == nil)) then
					local lastChoiceIndex
					if (countDownPic) then
						lastChoiceIndex = countDownPic.choice
					end
					horizontalScrollView.cancelPostCountDown()
					if (curChoiceId) then
						if (lastChoiceIndex == i) then
							votingListener()
						else
							local curChoicePicGroup = choiceSelectGroup.choicePicGroup[i]
							curChoicePicGroup:toFront()
							curChoicePicGroup.xScale = CHOICE_PIC_SELECTED_SCALE
							curChoicePicGroup.yScale = CHOICE_PIC_SELECTED_SCALE
							-- if ((curChoicePicGroup.nonPicBg) and (curChoicePicGroup.nonPicBg.parent)) then
							-- 	curChoicePicGroup.nonPicBg.alpha = 1
							-- end
							countDownTransitionListener{
															parent = curChoicePicGroup,
															picIndex = 0,
															choice = i,
															choiceId = curChoiceId,
															votingListener = votingListener,
														}
						end
					end
				end
				return true
			end
			if ((picPlaceHolderBg ~= nil) and (picPlaceHolderBg.parent ~= nil)) then
				picPlaceHolderBg:addEventListener("touch", choiceTouchListener)
			end
		end
		choiceGroupList[CHOICE_LETTER_TABLE[i]] = curChoiceGroup
	end
	choicePicTotal = #choicePicPath
	local function imageViewerListener(event)
		local imageInScrollView = choiceLargePicList[event.index]
		if (event.phase == "changePic") then
			horizontalScrollView:scrollToPosition{
													x = horScrollViewObjIndexToX(event.index + 1),
													time = 1,
												}
			if ((imageInScrollView ~= nil) and (imageInScrollView.parent ~= nil)) then
				imageInScrollView.alpha = 0
			end
			local prevImageInScrollView = choiceLargePicList[event.prevIndex]
			if ((prevImageInScrollView ~= nil) and (prevImageInScrollView.parent ~= nil)) then
				prevImageInScrollView.alpha = 1
			end
		else
			if ((imageInScrollView ~= nil) and (imageInScrollView.parent ~= nil)) then
				if (event.phase == "startExit") then
					imageInScrollView.alpha = 0
					return {imgPos = imageViewer.getImagePosForImageViewer(imageInScrollView)}
				elseif (event.phase == "endExit") then
					imageInScrollView.alpha = 1
				end
			end
		end
	end
	for i = 1, choicePicTotal do
		local function largePicTouchListener(event)
			if (checkScrollViewFocus(event)) then
				return false
			end
			if (event.phase == "ended") then
				local imageDataList = {
											imageData = choicePicArrayForImageViewer,
											imageToDisplayIdx = i,
											imagePos = imageViewer.getImagePosForImageViewer(event.target),
										}
				if (choiceLargePicList[i]) then
					choiceLargePicList[i].alpha = 0
				end
				imageViewer.openImageViewer(imageDataList, imageViewerListener)
				horizontalScrollView:scrollToPosition{
												x = horScrollViewObjIndexToX(i + 1),
												time = 200,
											}
			end
			return true
		end
		local largePicX = display.contentWidth * 0.5 + (CHOICE_PIC_OBJECT_WIDTH + CHOICE_PIC_OBJECT_SPACE) * i
		local largePicY = HOR_SCROLL_HEIGHT * 0.5
		local largePicPlaceHolderBg = display.newRect(largePicX, largePicY, CHOICE_PIC_OBJECT_WIDTH, CHOICE_PIC_LARGE_HEIGHT)
		local largePicPlaceHolderFg = display.newImageRect(LOCAL_SETTINGS.RES_DIR .. "placeholder.png", 250, 250)
		largePicPlaceHolderFg.x = largePicX
		largePicPlaceHolderFg.y = largePicY
		largePicPlaceHolderBg:addEventListener("touch", largePicTouchListener)
		horizontalScrollView:insert(largePicPlaceHolderBg)
		horizontalScrollView:insert(largePicPlaceHolderFg)
		local function insertChoiceLargePic(fileInfo)
			if (horizontalScrollView.parent) then
				local choiceLargePic = display.newImage(fileInfo.path, fileInfo.baseDir, true)
				if (choiceLargePic) then
					display.remove(largePicPlaceHolderBg)
					display.remove(largePicPlaceHolderFg)
					horizontalScrollView:insert(choiceLargePic)
					local imgOriginalScale = choiceLargePic.xScale
					choiceLargePic = scaleImageFillArea(choiceLargePic, CHOICE_PIC_OBJECT_WIDTH, CHOICE_PIC_LARGE_HEIGHT)
					choiceLargePic:setMask(largeChoiceMask)
					choiceLargePic.maskScaleX = imgOriginalScale / choiceLargePic.xScale
					choiceLargePic.maskScaleY = imgOriginalScale / choiceLargePic.yScale
					choiceLargePic.x = largePicX
					choiceLargePic.y = largePicY
					choiceLargePic:addEventListener("touch", largePicTouchListener)
					choiceLargePicList[i] = choiceLargePic
					imageViewer.reloadImage()
					horizontalScrollView:setScrollWidth(horizontalScrollViewScrollWidth)
				end
			end
		end
		local function choiceLargePicListener(event)
			if (event.isError) then
			elseif (event.phase == "ended") then
				insertChoiceLargePic({path = event.path, baseDir = event.baseDir})
			end
		end
		-- local choiceImgInfo = networkFile.getDownloadFile(choicePicPath[i].url, choicePicPath[i].path, choiceLargePicListener)
		local choiceImgInfo = networkFunction.getVorumFile(choicePicPath[i].url, choicePicPath[i].path, choiceLargePicListener)
		if ((choiceImgInfo ~= nil) and (choiceImgInfo.request == nil)) then
			insertChoiceLargePic(choiceImgInfo)
		end
	end
	if (choicePicTotal > 1) then
		horizontalScrollViewXMax = display.contentWidth * (choicePicTotal + 1)
		horizontalScrollViewScrollWidth = display.contentWidth + (CHOICE_PIC_OBJECT_WIDTH * (choicePicTotal + 1)) + (CHOICE_PIC_OBJECT_SPACE * (choicePicTotal + 1))
		horizontalScrollView:setScrollWidth(horizontalScrollViewScrollWidth)
		choiceSelectGroupX2 = -horScrollViewObjIndexToX(choicePicTotal + 1) + CHOICE_PIC_OBJECT_SPACE + (display.contentWidth + CHOICE_PIC_OBJECT_WIDTH) * 0.5
	elseif (choicePicTotal == 1) then
		horizontalScrollViewXMax = display.contentWidth
		horizontalScrollViewScrollWidth = display.contentWidth + (CHOICE_PIC_OBJECT_WIDTH * 1) + (CHOICE_PIC_OBJECT_SPACE * choicePicTotal)
		horizontalScrollView:setScrollWidth(horizontalScrollViewScrollWidth)
		choiceSelectGroupX2 = -horScrollViewObjIndexToX(1) + CHOICE_PIC_OBJECT_SPACE + (display.contentWidth + CHOICE_PIC_OBJECT_WIDTH) * 0.5
	else
		horizontalScrollView:setIsLocked(true)
	end
	horizontalScrollView:insert(choiceSelectGroup)
	choiceSelectGroup.x = display.contentWidth * 0.5 - CHOICE_PIC_WIDTH
	choiceSelectGroup.y = HOR_SCROLL_HEIGHT * 0.5 - CHOICE_PIC_HEIGHT

	function horizontalScrollView.updateCrown(choiceData)
		local goldMedalChoiceLetterList = {}
		local goldMedalVoteCount = 0
		if ((isHideResult ~= true) and (userVoted ~= nil)
			or ((postData.creator ~= nil) and (userId == postData.creator.id))) then
			for k, curChoice in pairs(choiceData) do
				if ((curChoice.count.total ~= nil) and (curChoice.count.total > 0)) then
					if ((goldMedalChoiceLetterList == nil) or (curChoice.count.total > goldMedalVoteCount)) then
						goldMedalChoiceLetterList = {}
						goldMedalChoiceLetterList[k] = true
						goldMedalVoteCount = curChoice.count.total
					elseif (curChoice.count.total == goldMedalVoteCount) then
						goldMedalChoiceLetterList[k] = true
					end
				end
			end
		end
		for k, choiceGroup in pairs(choiceGroupList) do
			if (goldMedalChoiceLetterList[k]) then
				if (choiceGroup.crownImg == nil) then
					local crownImg = display.newImage(choiceGroup, LOCAL_SETTINGS.RES_DIR .. "crown.png", true)
					crownImg.x = CHOICE_CROWN_X
					-- if (choiceDisplayLayoutSize <= 2) then
					-- 	crownImg.y = CHOICE_CROWN_Y2
					-- else
					-- 	crownImg.y = CHOICE_CROWN_Y
					-- end
					if (choiceGroup.groupHeight > CHOICE_PIC_HEIGHT + 1) then
						crownImg.y = CHOICE_CROWN_Y2
					else
						crownImg.y = CHOICE_CROWN_Y
					end
					crownImg.xScale = CHOICE_CROWN_SCALE
					crownImg.yScale = CHOICE_CROWN_SCALE
					choiceGroup.crownImg = crownImg
				end
			else
				if (choiceGroup.crownImg) then
					display.remove(choiceGroup.crownImg)
					choiceGroup.crownImg = nil
				end
			end
		end
	end
	if (isHideResult ~= true) then
		horizontalScrollView.updateCrown(choiceTable)
	end

	return horizontalScrollView
end

---------------------------------------------------------------
-- Create Post
---------------------------------------------------------------
-- ListenerTable:
--   votingListener(postGroup, dataForVote)
--   pressedCreatorListener(creatorData)
--   actionButtonListener(postGroup, postData, creatorData)

-- functions:
--   postGroup.cancelPostCountDown()	-- not use
--   postGroup.getCountingDownChoice()	-- not use
--   postGroup:updateResult(choiceData)	-- pass new choiceData to update result
--   postGroup:readyForDelete()			-- show "deleting" post
--   postView.newPost(parentScrollView, userId, postData[, isShowMyPostResult][, listenerTable][, curTime])
function postView.newPost(parentScrollView, userId, postData, ...)
	local isShowMyPostResult, curTime
	local votingListener, pressedCreatorListener, actionButtonListener
	local argIdx = 1
	if (type(arg[argIdx]) == "boolean") then
		isShowMyPostResult = arg[argIdx]
		argIdx = argIdx + 1
	else
		isShowMyPostResult = false
	end
	if (type(arg[argIdx]) == "table") then
		votingListener = arg[argIdx].votingListener
		pressedCreatorListener = arg[argIdx].pressedCreatorListener
		actionButtonListener = arg[argIdx].actionButtonListener
		argIdx = argIdx + 1
	end
	if (type(arg[argIdx]) == "number") then
		curTime = arg[argIdx]
		argIdx = argIdx + 1
	end
	if ((postData == nil)
		or (postData.choices == nil) or (postData.choices[CHOICE_LETTER_TABLE[1]] == nil) or (postData.choices[CHOICE_LETTER_TABLE[2]] == nil)) then
		return nil
	end
	if (curTime == nil) then
		curTime = os.time()
	end
	local locale = localization.getLocale()
	local postId = postData.id
	local postGroup = display.newGroup()
	local resultGroup
	local detailsGroup
	local postBasicPartHeight = 0
	local resultGroupDisplayHeight = RESULT_DEFAULT_HEIGHT
	local isHideResult = ((postData.hide_result ~= "1")
							and (postData.coupon ~= nil)
							and ((postData.creator == nil) or (userId ~= postData.creator.id)))
	if (isHideResult) then
		resultGroupDisplayHeight = RESULT_HIDDEN_DEFAULT_HEIGHT
	end
	local postDetailPartHeight = 0
	-- postGroup.postData = postData
	local postBg = display.newRect(postGroup, display.contentWidth * 0.5, 0, POST_WIDTH, 200)
	postBg.anchorY = 0

	-- Post Creator Info
	local isAnonymous = ((postData.anonymous == "1") or (postData.anonymous == nil) or (postData.Tag == "Anonymous"))
	local creatorData
	if (postData.creator == nil) then
		isAnonymous = true
	else
		creatorData = postData.creator
	end
	local creatorName
	local function touchCreatorListener(event)
		if ((parentScrollView ~= nil) and (parentScrollView.parent ~= nil)) then
			if (parentScrollView:checkFocusToScrollView(event) == true) then
				return false
			end
		end
		if (event.phase == "ended") then
			if ((isAnonymous ~= true) and (creatorData ~= nil)) then
				pressedCreatorListener(creatorData)
			end
		end
		return true
	end
	-- Post Creator Pic
	local creatorPicBg = display.newCircle(postGroup, CREATOR_PIC_X, CREATOR_PIC_Y, 58)
	if (creatorData ~= nil) then
		if (creatorData.gender == "M") then
			creatorPicBg:setFillColor(unpack(global.maleColor))
		elseif (creatorData.gender == "M") then
			creatorPicBg:setFillColor(unpack(global.femaleColor))
		else
			creatorPicBg:setFillColor(unpack(global.noGenderColor))
		end
	end

	if (isAnonymous) then
		local userPlaceHolderImg = insertCreatorImg(postGroup, {path = USER_IMG_PATH .. "anonymous.png"})
		creatorName = localization.getLocalization("anonymous")
	else
		local userPlaceHolderImg = insertCreatorImg(postGroup, {path = USER_IMG_PATH .. "anonymous.png"}, touchCreatorListener)
		local creatorPicFilePath = "user/" .. tostring(postData.creator.id) .. "/img"
		if (postData.creator.profile_pic) then
			local function creatorImgListener(event)
				if (event.isError) then
				elseif (event.phase == "ended") then
					local userImg = insertCreatorImg(postGroup, {path = event.path, baseDir = event.baseDir}, touchCreatorListener)
					if (userImg) then
						display.remove(userPlaceHolderImg)
					end
				end
			end
			-- local creatorImgInfo = networkFile.getDownloadFile(postData.creator.profile_pic, creatorPicFilePath, creatorImgListener)
			local creatorImgInfo = networkFunction.getVorumFile(postData.creator.profile_pic, creatorPicFilePath, creatorImgListener)
			if ((creatorImgInfo ~= nil) and (creatorImgInfo.request == nil)) then
				insertCreatorImg(postGroup, creatorImgInfo, touchCreatorListener)
			end
		end
		creatorName = postData.creator.name
	end
	-- Post Creator Name
	local userNameText = display.newText(creatorName, CREATOR_NAME_X, CREATOR_NAME_Y, POST_VIEW_COMMON_FONT, CREATOR_NAME_FONTSIZE)
	if (userNameText.contentWidth > CREATOR_NAME_WIDTH) then
		display.remove(userNameText)
		local userNameHeight = CREATOR_NAME_FONTSIZE
		local userNameTextOption = {
										text = creatorName,
										x = CREATOR_NAME_X,
										y = CREATOR_NAME_Y,
										width = CREATOR_NAME_WIDTH,
										height = userNameHeight,
										font = POST_VIEW_COMMON_FONT,
										fontSize = CREATOR_NAME_FONTSIZE,
									}
		if (isAndroid) then
			userNameTextOption.height = userNameTextOption.height + 5
		end
		userNameText = display.newText(userNameTextOption)
	end
	userNameText.anchorX = 0
	userNameText:setFillColor(0)
	postGroup:insert(userNameText)
	-- Post Creator touch Listener
	if (isAnonymous ~= true) then
		creatorPicBg:addEventListener("touch", touchCreatorListener)
		userNameText:addEventListener("touch", touchCreatorListener)
	end

	-- Action button
	local function actionBtnListener(event)
		if ((parentScrollView ~= nil) and (parentScrollView.parent ~= nil)) then
			if (parentScrollView:checkFocusToScrollView(event) == true) then
				return false
			end
		end
		if (event.phase == "ended") then
			actionButtonListener(postGroup, postData, creatorData)
		end
		return true
	end
	local actionButton = display.newImage(postGroup, LOCAL_SETTINGS.RES_DIR .. "actionBtn.png", true)
	actionButton.x = ACTION_BTN_X
	actionButton.y = ACTION_BTN_Y
	actionButton:addEventListener("touch", actionBtnListener)

	-- My Post / Reward Indicator
	local specialStrText
	local specialStrBg
	if ((isAnonymous ~= true) and (creatorData ~= nil) and (creatorData.id == userId)) then
		specialStrText = display.newText(localization.getLocalization("post_MyPost"), REWARD_TEXT_X, REWARD_TEXT_Y, POST_VIEW_COMMON_FONT, REWARD_TEXT_FONTSIZE)
		specialStrText:setFillColor(1)--(0.7, 0.7, 0)
		specialStrBg = display.newRect(REWARD_TEXT_X + 10, REWARD_TEXT_Y, specialStrText.contentWidth + 20, specialStrText.contentHeight + 6)
		specialStrBg:setFillColor(0.4, 0.6, 0.9)
		specialStrText.anchorX = 1
		specialStrBg.anchorX = 1
		postGroup:insert(specialStrBg)
		postGroup:insert(specialStrText)
	elseif ((postData.coupon ~= nil) and ((postData.coupon.pic ~= nil) or (postData.coupon.text ~= nil))) then
		specialStrText = display.newText(localization.getLocalization("post_Rewards"), REWARD_TEXT_X, REWARD_TEXT_Y, POST_VIEW_COMMON_FONT, REWARD_TEXT_FONTSIZE)
		specialStrText:setFillColor(1)--(0.7, 0.7, 0)
		specialStrBg = display.newRect(REWARD_TEXT_X + 10, REWARD_TEXT_Y, specialStrText.contentWidth + 20, specialStrText.contentHeight + 6)
		specialStrBg:setFillColor(0.9, 0.7, 0.2)--(0.4, 0.6, 0.9)
		specialStrText.anchorX = 1
		specialStrBg.anchorX = 1
		postGroup:insert(specialStrBg)
		postGroup:insert(specialStrText)
	end

	-- Tag, tag of X will set in "Create Time"
	local postExpireTime = tonumber(postData.expire_time)
	local tagText
	if ((postExpireTime ~= nil)
		and (postExpireTime < EXPIRE_TIME_MAX_VALUE)
		and (postExpireTime > 0)) then
		tagText = display.newText(" ", 0, TAG_TEXT_Y, POST_VIEW_COMMON_FONT, TAG_TEXT_FONTSIZE)
		addExpireTimerTable(postExpireTime, tagText, curTime)
	elseif ((type(postData.tags) == "table") and (postData.tags[1] ~= nil) and (postData.tags[1] ~= "")) then
		tagText = display.newText(localization.getLocalization(postData.tags[1]), 0, TAG_TEXT_Y, POST_VIEW_COMMON_FONT, TAG_TEXT_FONTSIZE)
		tagText:setFillColor(0.5)
	else
		tagText = display.newText(localization.getLocalization("General"), 0, TAG_TEXT_Y, POST_VIEW_COMMON_FONT, TAG_TEXT_FONTSIZE)
		tagText:setFillColor(0.5)
	end
	postGroup:insert(tagText)


	-- Create Time
	local createPostTimeText = display.newText(postGroup, "-", CREATE_TIME_X, CREATE_TIME_Y, POST_VIEW_COMMON_FONT, CREATE_TIME_FONTSIZE)
	local tagXRightRef = REWARD_TEXT_X
	if (specialStrBg) then
		tagXRightRef = tagXRightRef - specialStrBg.contentWidth + 10
	end
	createPostTimeText.anchorX = 0
	createPostTimeText:setFillColor(0.5)
	if (postData.createdAt) then
		addCreatedAtTimerTable(postData.createdAt, createPostTimeText, tagText, tagXRightRef, curTime)
	else
		local newTable = {
					textObject = createPostTimeText,
					tagText = tagText,
					tagXRightRef = tagXRightRef,
				}
		refreshCreatedAtTimer(newTable, curTime, true)
	end

	-- Post Title
	local postTitleStr = postData.title
	local postTitle
	if ((type(postTitleStr) ~= "string") or (postTitleStr == "")) then
		postTitleStr = " "
		postTitle = display.newText(postGroup, postTitleStr, display.contentWidth * 0.5, POST_TITLE_Y, POST_VIEW_COMMON_FONT, POST_TITLE_FONTSIZE)
	else
		display.remove(postTitle)
		local postTitleOption = {
									parent = postGroup,
									text = postTitleStr,
									x = display.contentWidth * 0.5,
									y = POST_TITLE_Y,
									width = POST_TITLE_WIDTH,
									font = POST_VIEW_COMMON_FONT, 
									fontSize = POST_TITLE_FONTSIZE,
									align = "center"
								}
		postTitle = display.newText(postTitleOption)
	end
	postTitle.anchorY = 0
	postTitle:setFillColor(0)

	-- Choices
	local function removeResultGroupObject()
		if (resultGroup.hasMask) then
			resultGroup:setMask(nil)
			resultGroup.hasMask = nil
		end
		if (resultGroup.noResultBg) then
			display.remove(resultGroup.noResultBg)
			resultGroup.noResultBg = nil
		end
	end
	local function hideResultGroup()
		if (resultGroup.transition) then
			transition.cancel(resultGroup.transition)
		end
		if (resultGroup.hasResult) then
			resultGroup.transition = transition.to(resultGroup.noResultBg, {alpha = 0, transition = easing.outSine, time = POST_CHANGE_HEIGHT_TRANSITION_TIME, onComplete = removeResultGroupObject})
		else
			resultGroup.isHidden = true
			local postHeight, detailPartPos = getPostHeightAndDetailPos(postBasicPartHeight, resultGroup, resultGroupDisplayHeight, detailsGroup, postDetailPartHeight)
			resultGroup.transition = transition.to(resultGroup, {y = postBasicPartHeight - resultGroupDisplayHeight, maskY = resultGroupDisplayHeight, transition = easing.outSine, time = POST_CHANGE_HEIGHT_TRANSITION_TIME, onComplete = removeResultGroupObject})
			transition.to(detailsGroup, {y = detailPartPos, transition = easing.outSine, time = POST_CHANGE_HEIGHT_TRANSITION_TIME})
			transition.to(postBg, {height = postHeight, transition = easing.outSine, time = POST_CHANGE_HEIGHT_TRANSITION_TIME})
			parentScrollView:changePostHeight(postGroup.idx, postHeight, POST_CHANGE_HEIGHT_TRANSITION_TIME)
		end
	end
	local function votingResultListener(choiceId, countDownImg, isJustVoted)
		if (resultGroup.parent) then
			if (choiceId) then
				if (countDownImg) then
					if (isJustVoted) then
						if (resultGroup.transition) then
							transition.cancel(resultGroup.transition)
						end
						if (resultGroup.hasResult) then
							if (resultGroup.noResultBg == nil) then
								resultGroup.noResultBg = display.newRect(resultGroup, display.contentWidth * 0.5, resultGroupDisplayHeight * 0.5, display.contentWidth * 0.9, resultGroupDisplayHeight * 0.9)
								resultGroup.noResultBg:setFillColor(0.7)
								resultGroup.noResultBg.alpha = 0
								resultGroup.transition = transition.to(resultGroup.noResultBg, {alpha = 1, transition = easing.outSine, time = POST_CHANGE_HEIGHT_TRANSITION_TIME})
							end
						else
							if ((resultGroup.noResultBg == nil) and (resultGroupDisplayHeight > RESULT_HIDDEN_DEFAULT_HEIGHT + 50)) then
								resultGroup.noResultBg = display.newRect(resultGroup, display.contentWidth * 0.5, resultGroupDisplayHeight * 0.5, display.contentWidth * 0.9, resultGroupDisplayHeight * 0.9)
								resultGroup.noResultBg:setFillColor(0.7)
							end
							if (resultGroup.hasMask ~= true) then
								resultGroup:setMask(postHiddenPartMask)
								resultGroup.maskY = resultGroupDisplayHeight
								resultGroup.hasMask = true
							end
							resultGroup.isHidden = false
							local postHeight, detailPartPos = getPostHeightAndDetailPos(postBasicPartHeight, resultGroup, resultGroupDisplayHeight, detailsGroup, postDetailPartHeight)
							resultGroup.transition = transition.to(resultGroup, {y = postBasicPartHeight, maskY = 0, transition = easing.outSine, time = POST_CHANGE_HEIGHT_TRANSITION_TIME})
							transition.to(detailsGroup, {y = detailPartPos, transition = easing.outSine, time = POST_CHANGE_HEIGHT_TRANSITION_TIME})
							transition.to(postBg, {height = postHeight, transition = easing.outSine, time = POST_CHANGE_HEIGHT_TRANSITION_TIME})
							parentScrollView:changePostHeight(postGroup.idx, postHeight, POST_CHANGE_HEIGHT_TRANSITION_TIME)
						end
					end
					countDownImg.x = display.contentWidth * 0.5
					countDownImg.y = resultGroupDisplayHeight * 0.5
					resultGroup:insert(countDownImg)
				else
					local function noResultBgFadeOutListener(obj)
						if (obj.parent) then
							display.remove(obj)
						end
					end
					local noResultBg = resultGroup.noResultBg
					if (resultGroup.hasResult) then
						local resultGroupY = resultGroup.y
						if (noResultBg) then
							postGroup:insert(noResultBg)
							noResultBg.y = resultGroupY + noResultBg.y
							transition.to(noResultBg, {alpha = 0, time = RESULT_BG_FADE_OUT_TIME, onComplete = noResultBgFadeOutListener})
						end
						display.remove(resultGroup)
						resultGroup = display.newGroup()
						postGroup:insert(resultGroup)
						resultGroup.y = resultGroupY
						resultGroup.isHidden = false
					else
						if (noResultBg) then
							transition.to(noResultBg, {alpha = 0, time = RESULT_BG_FADE_OUT_TIME, onComplete = noResultBgFadeOutListener})
							resultGroup.noResultBg = nil
						end
					end
					local updatingResultText = display.newText(resultGroup, localization.getLocalization("post_updatingResult"), display.contentWidth * 0.5, resultGroupDisplayHeight * 0.5 - 40, POST_VIEW_COMMON_FONT, 30)
					updatingResultText:setFillColor(0)
					updatingResultText.alpha = 0
					transition.to(updatingResultText, {alpha = 1, time = RESULT_BG_FADE_OUT_TIME})
					resultGroup.updatingResultText = updatingResultText
					local loadingSpin = widget.newSpinner{
															width = 80,
															height = 80,
															deltaAngle = 30,
															incrementEvery = 100,
														}
					loadingSpin:start()
					loadingSpin.x = display.contentWidth * 0.5
					loadingSpin.y = resultGroupDisplayHeight * 0.5 + 20
					resultGroup:insert(loadingSpin)
					resultGroup.loadingSpin = loadingSpin
					votingListener(postGroup, {post_id = postId, choice_id = choiceId})
				end
			else
				hideResultGroup()
			end
		end
	end
	local choiceScrollView = createPostChoiceScrollView(parentScrollView, postData, userId, isHideResult, votingResultListener)
	choiceScrollView.y = postTitle.y + postTitle.contentHeight + HOR_SCROLL_HEIGHT * 0.5
	postGroup:insert(choiceScrollView)

	-- Views and Votes
	local viewsAndVotesY = choiceScrollView.y + HOR_SCROLL_HEIGHT * 0.5 + 20
	local viewTextStr = "0"
	local noOfViews = tonumber(postData.views)
	if (noOfViews) then
		viewTextStr = convertNumToNotationString(noOfViews)
		if (noOfViews <= 1) then
			viewTextStr = viewTextStr .. localization.getLocalization("view")
		else
			viewTextStr = viewTextStr .. localization.getLocalization("views")
		end
	end
	local viewText = display.newText(postGroup, viewTextStr, VIEWS_TEXT_X, viewsAndVotesY, POST_VIEW_COMMON_FONT, VIEWS_AND_VOTED_TEXT_FONTSIZE)
	viewText.anchorX = 1
	viewText:setFillColor(0.5)
	local votedCount = 0
	for k, choice in pairs(postData.choices) do
		if (choice.count.total) then
			votedCount = votedCount + choice.count.total
		end
	end
	votedTextStr = convertNumToNotationString(votedCount) .. localization.getLocalization("voted")
	local votedText = display.newText(postGroup, votedTextStr, VOTED_TEXT_X, viewsAndVotesY, POST_VIEW_COMMON_FONT, VIEWS_AND_VOTED_TEXT_FONTSIZE)
	votedText.anchorX = 0
	votedText:setFillColor(0.5)
	postBasicPartHeight = viewsAndVotesY + viewText.contentHeight * 0.5 + 20

	-- Result
	resultGroup = display.newGroup()
	postGroup:insert(resultGroup)
	if (((isShowMyPostResult) and (postData.creator.id == userId)) or (postData.userVoted ~= nil)) then
		resultGroupDisplayResult(resultGroup, isHideResult, resultGroupDisplayHeight, postData.choices, false)
		resultGroup.y = postBasicPartHeight
		resultGroup.hasResult = true
		resultGroup.isHidden = false
	else
		resultGroup.y = postBasicPartHeight - resultGroupDisplayHeight
		resultGroup.isHidden = true
	end


	function postGroup.cancelPostCountDown()
		local countingDownChoice = choiceScrollView.getCountingDownChoice()
		choiceScrollView.cancelPostCountDown()
		hideResultGroup()
		return countingDownChoice
	end

	function postGroup.getCountingDownChoice()
		return choiceScrollView.getCountingDownChoice()
	end

	-- Details
	if (postData.post_pic == "") then
		postData.post_pic = nil
	end
	if (postData.description == "") then
		postData.description = nil
	end
	if (postData.link == "") then
		postData.link = nil
	end
	if ((postData.post_pic ~= nil) or (postData.description ~= nil) or (postData.link ~= nil)) then
		detailsGroup = display.newGroup()
		local detailObjectY = 0
		local detailPicArray = {}
		local detailPic
		local upArrow = display.newImage(detailsGroup, LOCAL_SETTINGS.RES_DIR .. "upArrow.png", true)
		upArrow.isHitTestable = true
		upArrow.x = display.contentWidth * 0.5
		upArrow.y = 11
		detailObjectY = detailObjectY + upArrow.contentHeight + 20 - 11
		if (postData.post_pic ~= nil) then
			local postDetailPicPosY = detailObjectY
			local function imageViewerPostDetailPicListener(event)
				if (event.phase == "startExit") then
					return {imgPos = imageViewer.getImagePosForImageViewer(detailPic)}
				elseif (event.phase == "endExit") then
					if (detailPic) then
						detailPic.alpha = 1
					end
				end
			end
			local function postDetailPicTouchListener(event)
				if ((parentScrollView ~= nil) and (parentScrollView.parent ~= nil)) then
					if (parentScrollView:checkFocusToScrollView(event) == true) then
						return false
					end
				end
				if (event.phase == "ended") then
					local imageDataList = {
												imageData = detailPicArray,
												imageToDisplayIdx = 1,
												imagePos = imageViewer.getImagePosForImageViewer(event.target),
											}
					imageViewer.openImageViewer(imageDataList, imageViewerPostDetailPicListener)
					if (detailPic) then
						detailPic.alpha = 0
					end
				end
				return true
			end
			local postDetailPicPlaceHolderBg
			local postDetailPicPlaceHolderFg
			local postPicPath = "post/" .. tostring(postData.id) .. "/img"
			local function postPicListener(event)
				if (event.isError) then
				elseif (event.phase == "ended") then
					detailPic = insertPostDetailPic(detailsGroup, {path = event.path, baseDir = event.baseDir}, postDetailPicPosY, postDetailPicPlaceHolderBg, postDetailPicPlaceHolderFg, postDetailPicTouchListener)
				end
			end
			-- local postDetailPicInfo = networkFile.getDownloadFile(postData.post_pic, postPicPath, postPicListener)
			local postDetailPicInfo = networkFunction.getVorumFile(postData.post_pic, postPicPath, postPicListener)
			if (postDetailPicInfo ~= nil) then
				if (postDetailPicInfo.request) then
					postDetailPicPlaceHolderBg = display.newRect(detailsGroup, display.contentWidth * 0.5, postDetailPicPosY, POST_DETAIL_PIC_WIDTH, POST_DETAIL_PIC_HEIGHT)
					postDetailPicPlaceHolderBg.anchorY = 0
					postDetailPicPlaceHolderFg = display.newImageRect(detailsGroup, LOCAL_SETTINGS.RES_DIR .. "placeholder.png", 200, 200)
					postDetailPicPlaceHolderFg.x = display.contentWidth * 0.5
					postDetailPicPlaceHolderFg.y = detailObjectY + (postDetailPicPlaceHolderBg.contentHeight - postDetailPicPlaceHolderFg.contentHeight) * 0.5 + 20
					postDetailPicPlaceHolderFg.anchorY = 0
					postDetailPicPlaceHolderBg:addEventListener("touch", postDetailPicTouchListener)
				else
					detailPic = insertPostDetailPic(detailsGroup, postDetailPicInfo, postDetailPicPosY, postDetailPicPlaceHolderBg, postDetailPicPlaceHolderFg, postDetailPicTouchListener)
				end
				detailPicArray[#detailPicArray + 1] = {path = postDetailPicInfo.path, baseDir = postDetailPicInfo.baseDir}
				detailObjectY = detailObjectY + POST_DETAIL_PIC_HEIGHT + 20
			end
		end
		if (postData.description ~= nil) then
			local postDescriptionText = display.newText(detailsGroup, postData.description, POST_DETAIL_TEXT_X, detailObjectY, POST_DETAIL_TEXT_WIDTH, 0, POST_VIEW_COMMON_FONT, POST_DETAIL_TEXT_FONTSIZE)
			postDescriptionText.anchorX = 0
			postDescriptionText.anchorY = 0
			postDescriptionText:setFillColor(0)
			detailObjectY = detailObjectY + postDescriptionText.contentHeight + 20
		end
		if (postData.link ~= nil) then
			local postLinkText = display.newText(detailsGroup, postData.link, POST_DETAIL_TEXT_X, detailObjectY, POST_DETAIL_TEXT_WIDTH, 0, POST_VIEW_COMMON_FONT, POST_DETAIL_TEXT_FONTSIZE)
			postLinkText.anchorX = 0
			postLinkText.anchorY = 0
			postLinkText:setFillColor(0, 0, 1)
			postLinkText.isHitTestable = true
			postLinkText:addEventListener("touch", function(event)
														if ((parentScrollView ~= nil) and (parentScrollView.parent ~= nil)) then
															if (parentScrollView:checkFocusToScrollView(event) == true) then
																return false
															end
														end
														if (event.phase == "ended") then
															system.openURL(postData.link)
														end
														return true
													end)
			detailObjectY = detailObjectY + postLinkText.contentHeight + 20
		end
		local detailBtn = display.newImage(detailsGroup, LOCAL_SETTINGS.RES_DIR .. "detailBtn.png", true)
		detailBtn.isHitTestable = true
		detailBtn.x = display.contentWidth * 0.5
		detailBtn.y = detailObjectY + 12
		local function detailBtnTouchListener(event)
			if ((parentScrollView ~= nil) and (parentScrollView.parent ~= nil)) then
				if (parentScrollView:checkFocusToScrollView(event) == true) then
					return false
				end
			end
			if (event.phase == "ended") then
				if (detailsGroup.isHidden) then
					detailsGroup.isHidden = false
					local postHeight, detailPartPos = getPostHeightAndDetailPos(postBasicPartHeight, resultGroup, resultGroupDisplayHeight, detailsGroup, postDetailPartHeight)
					transition.to(detailsGroup, {y = detailPartPos, maskY = 0, transition = easing.outSine, time = POST_CHANGE_HEIGHT_TRANSITION_TIME})
					transition.to(postBg, {height = postHeight, transition = easing.outSine, time = POST_CHANGE_HEIGHT_TRANSITION_TIME})
					parentScrollView:changePostHeight(postGroup.idx, postHeight, POST_CHANGE_HEIGHT_TRANSITION_TIME)
				else
					detailsGroup.isHidden = true
					local postHeight, detailPartPos = getPostHeightAndDetailPos(postBasicPartHeight, resultGroup, resultGroupDisplayHeight, detailsGroup, postDetailPartHeight)
					transition.to(detailsGroup, {y = detailPartPos, maskY = postDetailPartHeight - 8, transition = easing.outSine, time = POST_CHANGE_HEIGHT_TRANSITION_TIME})
					transition.to(postBg, {height = postHeight, transition = easing.outSine, time = POST_CHANGE_HEIGHT_TRANSITION_TIME})
					parentScrollView:changePostHeight(postGroup.idx, postHeight, POST_CHANGE_HEIGHT_TRANSITION_TIME)
				end
			end
			return true
		end
		upArrow:addEventListener("touch", detailBtnTouchListener)
		detailBtn:addEventListener("touch", detailBtnTouchListener)

		postDetailPartHeight = detailObjectY
		detailsGroup:setMask(postHiddenPartMask)
		detailsGroup.maskX = display.contentWidth * 0.5
		detailsGroup.maskY = postDetailPartHeight - 8
		detailsGroup.isHidden = true
		detailsGroup.y = postBasicPartHeight - postDetailPartHeight
		if (resultGroup.isHidden ~= true) then
			detailsGroup.y = detailsGroup.y + resultGroupDisplayHeight
		end
		postGroup:insert(detailsGroup)
	end

	-- functions
	function postGroup:updateResult(choiceData)
		if (postGroup.parent) then
			resultGroupDisplayResult(resultGroup, isHideResult, resultGroupDisplayHeight, choiceData, true)
			local votedCount = 0
			for k, choice in pairs(choiceData) do
				if (choice.count.total) then
					votedCount = votedCount + choice.count.total
				end
			end
			votedText.text = convertNumToNotationString(votedCount) .. localization.getLocalization("voted")
			if (resultGroup.updatingResultText ~= nil) then
				display.remove(resultGroup.updatingResultText)
				resultGroup.updatingResultText = nil
			end
			if (resultGroup.loadingSpin ~= nil) then
				display.remove(resultGroup.loadingSpin)
				resultGroup.loadingSpin = nil
			end
			if (isHideResult ~= true) then
				choiceScrollView.updateCrown(choiceData)
			end
		end
	end

	function postGroup:readyForDelete()
		local postHeight = getPostHeightAndDetailPos(postBasicPartHeight, resultGroup, resultGroupDisplayHeight, detailsGroup, postDetailPartHeight)
		local deletingCover = display.newRect(postGroup, display.contentWidth * 0.5, 0, POST_WIDTH, postHeight)
		deletingCover.anchorY = 0
		deletingCover.alpha = 0.9
		deletingCover:setFillColor(0.5)
		self.deletingCover = deletingCover
		local deletingWord = display.newText(postGroup, localization.getLocalization("post_deleting"), display.contentWidth * 0.5, postHeight * 0.5 - 40, POST_VIEW_COMMON_FONT, 40)
		deletingWord:setFillColor(0)
		self.deletingWord = deletingWord
		local deletingSpin = widget.newSpinner{
													width = 80,
													height = 80,
													deltaAngle = 30,
													incrementEvery = 100,
												}
		deletingSpin.x = display.contentWidth * 0.5
		deletingSpin.y = postHeight * 0.5 + 50
		deletingSpin:start()
		postGroup:insert(deletingSpin)
		self.deletingSpin = deletingSpin
	end

	postBg.height = getPostHeightAndDetailPos(postBasicPartHeight, resultGroup, resultGroupDisplayHeight, detailsGroup, postDetailPartHeight)
	parentScrollView:addNewPost(postGroup, postBg.height)
	return postGroup
end

local function onSystemEventExpireTimerHandler(event)
--	print( "System event name and type: " .. event.name, event.type )
	if (event.type == "applicationStart") then
	elseif (event.type == "applicationExit") then
	elseif (event.type == "applicationSuspend") then
		if (expireTimer) then
			timer.cancel(expireTimer)
			expireTimer = nil
		end
		if (createdAtTimer) then
			timer.cancel(createdAtTimer)
			createdAtTimer = nil
		end
	elseif (event.type == "applicationResume") then
		expireTimerRestart()
		creratedAtTimerRestart()
	end
end
Runtime:addEventListener( "system", onSystemEventExpireTimerHandler )

return postView
