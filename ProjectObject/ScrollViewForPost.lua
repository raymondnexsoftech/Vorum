---------------------------------------------------------------
-- ScrollViewForPost.lua
--
-- Scroll View for post
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
local widget = require ( "widget" )

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local DEFAULT_POST_SPACE = 10
local DEFAULT_CHANGE_HEIGHT_TIME = 100
local LAST_N_POST_TO_REQUEST_DATA = 3
local DEFAULT_REFRESH_HEIGHT = 50
local DEFAULT_TEXT_SIZE = 20
local DEFAULT_TEXT_TO_PULL = "Pull to refresh"
local DEFAULT_TEXT_TO_RELEASE = "Release to reload"
local DEFAULT_LOADING_TEXT = "Reloading..."
local DEFAULT_VERTICAL_PADDING_FOR_REFRESH_ICON = 5
local DEFAULT_SPACE_FOR_REFRESH_HEADER_OBJ = 30
local DEFAULT_REFRESH_ICON_MAX_ROTATION = 360

local DEFAULT_REFRESH_START_OFFSET = DEFAULT_VERTICAL_PADDING_FOR_REFRESH_ICON * 2

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
local scrollViewForPost = {}

local function touchDisplacement(event)
	if (event.x) then
		return math.sqrt(math.pow(event.xStart - event.x, 2) + math.pow(event.yStart - event.y, 2))
	end
	return nil
end

local function setScrollViewScrollHeight(scrollView, scrollHeight, transitionTime)
	local scrollViewGroup = scrollView:getView()
	local scrollViewVisibleHeight = scrollViewGroup._height
	local newScrollHeight = 0
	if (scrollHeight > scrollViewVisibleHeight) then
		newScrollHeight = scrollHeight
	else
		newScrollHeight = scrollViewVisibleHeight
	end
	scrollView:setScrollHeight(newScrollHeight)
	if ((scrollView.isDeletingPost ~= true) and (scrollView.isScrolling ~= true)) then
		local scrollX, scrollY = scrollView:getContentPosition()
		local scrollVisibleBottomY = -scrollY + scrollViewVisibleHeight
		if (newScrollHeight < scrollVisibleBottomY) then
			local destY
			scrollView.isScrolling = true
			scrollView:scrollToPosition
			{
				y = -newScrollHeight + scrollViewVisibleHeight,
				time = transitionTime,
				onComplete = function() scrollView.isScrolling = false; end,
			}
		end
	end
end

-- local function isPostVisible(scrollView, idx)
-- 	local post = scrollView:getPost(idx)
-- 	if (post) then
-- 		local scrollViewX, scrollViewY = scrollView:getContentPosition()
-- 		local scrollViewHeight = scrollView:getView()._height
-- 		if ((post.curY < -scrollViewY + scrollViewHeight) and (post.curY + post.postCurrentHeight > -scrollViewY)) then
-- 		elseif ((post.curY > -scrollViewY + scrollViewHeight) and (post.curY + post.postCurrentHeight > -scrollViewY)) then
-- 		end
-- 	end
-- end

local function scrollViewListener(event)
	local scrollView = event.target
	if (scrollView._isWidget ~= true) then
		scrollView = scrollView.parent
	end
	local scrollViewX, scrollViewY = scrollView:getContentPosition()
	local scrollViewTopPadding = scrollView:getView()._topPadding
	local scrollViewPullDownDistance = scrollViewY - DEFAULT_REFRESH_START_OFFSET - scrollViewTopPadding
	if (event.limitReached) then
		scrollView:getView()._velocity = 0
		if (event.direction == "up") then
			scrollView.isRequestDataListenerCalled = true
			if ((type(scrollView.requestDataListener) == "function") and (scrollView.isRequestDataListenerCalled ~= true)) then
				scrollView.requestDataListener(scrollView, true)
			end
		end
	elseif ((scrollViewPullDownDistance > 0) and (scrollView.refreshHeader ~= nil)) then
		local refreshHeader = scrollView.refreshHeader
		if (scrollView.isReloadDataListenerCalled ~= true) then
			if (event.phase == "ended") then
				if (scrollViewPullDownDistance > refreshHeader.headerHeight) then
					scrollView.isReloadDataListenerCalled = true
					scrollView.isRequestDataListenerCalled = true
					if (refreshHeader.refreshIcon) then
						refreshHeader.refreshIcon.rotation = refreshHeader.refreshIcon.maxRotation
					end
					refreshHeader.textToPull.alpha = 0
					refreshHeader.textToRelease.alpha = 0
					refreshHeader.loadingText.alpha = 1
					scrollView:getView()._topPadding = scrollView.origTopPadding + refreshHeader.headerHeight
					if (type(scrollView.reloadDataListener) == "function") then
						scrollView.reloadDataListener(scrollView, true)
					end
				else
					if (refreshHeader.refreshIcon) then
						transition.to(refreshHeader.refreshIcon, {rotation = 0, time = DEFAULT_CHANGE_HEIGHT_TIME})
					end
					refreshHeader.textToPull.alpha = 1
					refreshHeader.textToRelease.alpha = 0
					refreshHeader.loadingText.alpha = 0
				end
			else
				if (scrollViewPullDownDistance > refreshHeader.headerHeight) then
					if (refreshHeader.refreshIcon) then
						refreshHeader.refreshIcon.rotation = refreshHeader.refreshIcon.maxRotation
					end
					refreshHeader.textToPull.alpha = 0
					refreshHeader.textToRelease.alpha = 1
					refreshHeader.loadingText.alpha = 0
				else
					if (refreshHeader.refreshIcon) then
						refreshHeader.refreshIcon.rotation = scrollViewPullDownDistance * refreshHeader.refreshIcon.maxRotation / refreshHeader.headerHeight
					end
					refreshHeader.textToPull.alpha = 1
					refreshHeader.textToRelease.alpha = 0
					refreshHeader.loadingText.alpha = 0
				end
			end
		end
	elseif ((scrollView.isRequestDataListenerCalled ~= true) and (scrollView.isReloadDataListenerCalled ~= true)) then
		local postIdxForRequestData = scrollView:getPostTotal() - LAST_N_POST_TO_REQUEST_DATA
		if (postIdxForRequestData < 1) then
			postIdxForRequestData = 1
		end
		local post = scrollView:getPost(postIdxForRequestData)
		if (post) then
			if (post.curY - scrollView:getView()._height < -scrollViewY) then
				scrollView.isRequestDataListenerCalled = true
				if (type(scrollView.requestDataListener) == "function") then
					scrollView.requestDataListener(scrollView, false)
				end
			end
		else
			scrollView.isRequestDataListenerCalled = true
		end
	end
	if ((scrollViewPullDownDistance < 0) and (scrollView.refreshHeader ~= nil)) then
		local refreshHeader = scrollView.refreshHeader
		if (refreshHeader.refreshIcon) then
			refreshHeader.refreshIcon.rotation = 0
		end
		refreshHeader.textToPull.alpha = 1
		refreshHeader.textToRelease.alpha = 0
		refreshHeader.loadingText.alpha = 0
	end
	if (type(scrollView.userListener) == "function") then
		scrollView.userListener(event)
	end
end

--	options added:
--		postSpace: space between posts
--		requestDataListener(isRequestByReachBottom): listener on scroll view need to request new data

local function createRefreshHeaderString(parent, inputFromUser, defaultStr)
	local textObj

	if (type(inputFromUser) == "table") then
		if (inputFromUser.parent == nil) then
			textObj = display.newText(parent, defaultStr, 0, 0, native.systemFont, DEFAULT_TEXT_SIZE)
			textObj:setFillColor(0)
		else
			textObj = inputFromUser
			parent:insert(textObj)
		end
	elseif (type(inputFromUser) == "string") then
		if (inputFromUser ~= "") then
			textObj = display.newText(parent, inputFromUser, 0, 0, native.systemFont, DEFAULT_TEXT_SIZE)
			textObj:setFillColor(0)
		else
			textObj = display.newText(parent, defaultStr, 0, 0, native.systemFont, DEFAULT_TEXT_SIZE)
			textObj:setFillColor(0)
		end
	else
		textObj = display.newText(parent, defaultStr, 0, 0, native.systemFont, DEFAULT_TEXT_SIZE)
		textObj:setFillColor(0)
	end
	textObj.alpha = 0
	return textObj
end

local function setRefreshHeaderTextPos(textObj, startX, maxWidth, y)
	local offsetX = 0
	if (textObj.width > maxWidth) then
		textObj.anchorX = 0
		textObj.x = startX
	else
		textObj.anchorX = 0.5
		textObj.x = startX + maxWidth * 0.5
	end
	textObj.anchorY = 0.5
	textObj.y = y
end

local function postTransition(scrollView, postIdx, heightDiff, transitionTime)
	local postTotal = #scrollView.postArray
	local scrollViewVisibleAreaLeft, scrollViewVisibleAreaTop = scrollView:getContentPosition()
	local scrollViewVisibleAreaBottom = scrollView:getView()._height + (-scrollViewVisibleAreaTop)
	local changeHeightCompleteListener = scrollView.changeHeightCompleteListener
	local newScrollHeightForPost = scrollView:getScrollHeightForPost() + heightDiff
	if (heightDiff < 0) then
		local curRowIdx = postIdx + 1
		while (curRowIdx <= postTotal) do
			local curRow = scrollView.postArray[curRowIdx]
			curRow.curY = curRow.curY + heightDiff
			transition.to(curRow, {y = curRow.curY, time = transitionTime, transition = easing.outSine, onComplete = changeHeightCompleteListener})
			changeHeightCompleteListener = nil
			curRowIdx = curRowIdx + 1
			if (curRow.y + heightDiff > scrollViewVisibleAreaBottom) then
				break;
			end
		end
		for i = curRowIdx, postTotal do
			local curRow = scrollView.postArray[i]
			curRow.curY = curRow.curY + heightDiff
			curRow.y = curRow.curY
		end
		setScrollViewScrollHeight(scrollView, newScrollHeightForPost, transitionTime)
	elseif (heightDiff > 0) then
		local curRowIdx = postIdx + 1
		while (curRowIdx <= postTotal) do
			local curRow = scrollView.postArray[curRowIdx]
			curRow.curY = curRow.curY + heightDiff
			transition.to(curRow, {y = curRow.curY, time = transitionTime, transition = easing.outSine, onComplete = changeHeightCompleteListener})
			changeHeightCompleteListener = nil
			curRowIdx = curRowIdx + 1
			if (curRow.y > scrollViewVisibleAreaBottom) then
				break;
			end
		end
		for i = curRowIdx, postTotal do
			local curRow = scrollView.postArray[i]
			curRow.curY = curRow.curY + heightDiff
			curRow.y = curRow.curY
		end
		setScrollViewScrollHeight(scrollView, newScrollHeightForPost, transitionTime)
	end
end

local function removePostFromScrollView(post, scrollView, idx)
	if (post.parent) then
		display.remove(post)
		table.remove(scrollView.postArray, idx)
		if (scrollView.parent) then
			setScrollViewScrollHeight(scrollView, scrollView:getScrollHeightForPost(), 0)
			-- scrollView:setScrollHeight(scrollView:getScrollHeightForPost())
			local postTotal = #scrollView.postArray
			for i = 1, postTotal do
				scrollView.postArray[i].idx = i
			end
			scrollView.isDeletingPost = false
		end
	end
end

function scrollViewForPost.newScrollView(options)
	local userListener = options.listener
	options.listener = scrollViewListener
	local scrollView = widget.newScrollView(options)
	scrollView.origTopPadding = options.topPadding
	scrollView.userListener = userListener
	scrollView.postSpace = options.postSpace or DEFAULT_POST_SPACE
	scrollView.postArray = {}
	scrollView.isDeletingAllPost = false
	scrollView.isRequestDataListenerCalled = false
	scrollView.isReloadDataListenerCalled = false
	scrollView.requestDataListener = options.requestDataListener
	scrollView.reloadDataListener = options.reloadDataListener
	scrollView.isDeletingPost = false
	scrollView.isScrolling = false
	if (options.refreshHeader) then
		local refreshHeaderOption = options.refreshHeader
		if (refreshHeaderOption.height ~= nil) then
			local refreshHeader = display.newGroup()
			scrollView:insert(refreshHeader)
			local refreshHeaderHeight = refreshHeaderOption.height
			if (refreshHeaderHeight < DEFAULT_REFRESH_HEIGHT) then
				refreshHeaderHeight = DEFAULT_REFRESH_HEIGHT
			end
			refreshHeader.headerHeight = refreshHeaderHeight
			refreshHeader.y = -refreshHeaderHeight
			local textToPull = createRefreshHeaderString(refreshHeader, refreshHeaderOption.textToPull, DEFAULT_TEXT_TO_PULL)
			local textToRelease = createRefreshHeaderString(refreshHeader, refreshHeaderOption.textToRelease, DEFAULT_TEXT_TO_RELEASE)
			local loadingText = createRefreshHeaderString(refreshHeader, refreshHeaderOption.loadingText, DEFAULT_LOADING_TEXT)
			local maxTextWidth = textToPull.contentWidth
			if (maxTextWidth < textToRelease.contentWidth) then
				maxTextWidth = textToRelease.contentWidth
			end
			if (maxTextWidth < loadingText.contentWidth) then
				maxTextWidth = loadingText.contentWidth
			end
			local refreshIcon
			if (type(refreshHeaderOption.icon) == "table") then
				if (refreshHeaderOption.icon.parent) then
					refreshIcon = refreshHeaderOption.icon
				end
			elseif (type(refreshHeaderOption.icon) == "string") then
				local refreshIcon = display.newImage(refreshHeader, refreshHeaderOption.icon, true)
			end
			local textStartX, textMaxWidth = 0, options.width
			if (refreshIcon) then
				refreshIcon.maxRotation = DEFAULT_REFRESH_ICON_MAX_ROTATION
				if ((type(refreshHeaderOption.iconMaxRotation) == "number") and (refreshHeaderOption.iconMaxRotation > 0)) then
					refreshIcon.maxRotation = refreshHeaderOption.iconMaxRotation
				end
				local iconRatio = (refreshHeaderHeight - DEFAULT_VERTICAL_PADDING_FOR_REFRESH_ICON * 2) / refreshIcon.contentHeight
				refreshIcon.xScale = iconRatio
				refreshIcon.yScale = iconRatio
				refreshIcon.anchorX = 0.5
				refreshIcon.anchorY = 0.5
				refreshIcon.y = refreshHeaderHeight * 0.5
				refreshHeader:insert(refreshIcon)
				local maxRefreshHeaderWidth = DEFAULT_SPACE_FOR_REFRESH_HEADER_OBJ * 3 + refreshIcon.width + maxTextWidth
				if (maxRefreshHeaderWidth > options.width) then
					refreshIcon.x = DEFAULT_SPACE_FOR_REFRESH_HEADER_OBJ + refreshIcon.width * 0.5
					textStartX = DEFAULT_SPACE_FOR_REFRESH_HEADER_OBJ * 2 + refreshIcon.width
					textMaxWidth = options.width - textStartX - DEFAULT_SPACE_FOR_REFRESH_HEADER_OBJ
				else
					refreshIcon.x = (options.width - (DEFAULT_SPACE_FOR_REFRESH_HEADER_OBJ + maxTextWidth)) * 0.5 
					textStartX = refreshIcon.x + DEFAULT_SPACE_FOR_REFRESH_HEADER_OBJ + refreshIcon.width * 0.5
					textMaxWidth = options.width - textStartX - refreshIcon.x + refreshIcon.width * 0.5
				end
			end
			setRefreshHeaderTextPos(textToPull, textStartX, textMaxWidth, refreshHeaderHeight * 0.5)
			setRefreshHeaderTextPos(textToRelease, textStartX, textMaxWidth, refreshHeaderHeight * 0.5)
			setRefreshHeaderTextPos(loadingText, textStartX, textMaxWidth, refreshHeaderHeight * 0.5)
			textToPull.alpha = 1
			refreshHeader.textToPull = textToPull
			refreshHeader.textToRelease = textToRelease
			refreshHeader.loadingText = loadingText
			refreshHeader.refreshIcon = refreshIcon
			scrollView.refreshHeader = refreshHeader
		end
	end

	function scrollView:setScrollViewHeadHeight(height)
		if (self.headView) then
			local heightDiff = height
			if (self.headViewHeight) then
				heightDiff = heightDiff - self.headViewHeight
			end
			self.headViewHeight = height
			if (heightDiff ~= 0) then
				local postTotal = self:getPostTotal()
				for i = 1, postTotal do
					local post = self:getPost(i)
					post.y = post.y + heightDiff
					post.curY = post.curY + heightDiff
				end
			end
		end
	end

	function scrollView:setScrollViewHead(headView, height)
		if (self.headView) then
			display.remove(self.headView)
		end
		if ((headView ~= nil) and (height >= 0)) then
			self.headView = headView
			headView.y = 0
			self:insert(headView)
		else
			self.headView = nil
			height = 0
		end
		self:setScrollViewHeadHeight(height)
	end

	function scrollView:getPostTotal()
		return #self.postArray
	end

	function scrollView:getPost(idx)
		if (idx > 0) then
			return self.postArray[idx]
		end
		return nil
	end

	function scrollView:getScrollHeightForPost()
		local totalRow = #self.postArray
		if (totalRow > 0) then
			local scrollHeight = self.postArray[totalRow].curY + self.postArray[totalRow].postCurrentHeight
			if (self.postSpace > 0) then
				return scrollHeight + self.postSpace
			else
				return scrollHeight
			end
		else
			if (self.headViewHeight) then
				return self.postSpace + self.headViewHeight
			else
				return self.postSpace
			end
		end
	end

	function scrollView:addNewPost(view, postHeight)
		local newY = self:getScrollHeightForPost()
		if (self.postSpace < 0) then
			newY = newY + self.postSpace
		end
		view.curY = newY
		view.y = newY
		self:insert(view)
		view.idx = #self.postArray + 1
		self.postArray[view.idx] = view
		view.postCurrentHeight = postHeight
		local scrollHeight = view.y + postHeight
		if (self.postSpace > 0) then
			scrollHeight = scrollHeight + self.postSpace
		end
		self:resetDataRequestStatus()
		setScrollViewScrollHeight(self, scrollHeight)
		return view.idx
	end

	function scrollView:checkFocusToScrollView(event)
		local touchDisp = touchDisplacement(event)
		if (event.phase == "began") then
			if (self:getView()._velocity ~= 0) then
				self:takeFocus(event)
			end
		end
		if (touchDisp ~= nil) then
			if (touchDisp > 10) then
				if (math.abs(event.yStart - event.y) < 5) then
					event.target.isNotVerticalScroll = true
				else
					self:takeFocus(event)
				end
			end
		end
	end

	-- scrollView:changePostHeight(postIdx, newHeight, [transitionTime], [changeHeightCompleteListener])
	function scrollView:changePostHeight(...)
		local postIdx = arg[1]
		local newHeight = arg[2]
		local argIdx = 3
		local transitionTime, changeHeightCompleteListener
		if (type(arg[argIdx]) == "number") then
			transitionTime = arg[argIdx]
			argIdx = argIdx + 1
		else
			transitionTime = DEFAULT_CHANGE_HEIGHT_TIME
		end
		if (type(arg[argIdx]) == "function") then
			changeHeightCompleteListener = arg[argIdx]
			argIdx = argIdx + 1
		end
		local post = self:getPost(postIdx)
		if (post) then
			local heightDiff = newHeight - post.postCurrentHeight
			postTransition(self, postIdx, heightDiff, transitionTime)
			post.postCurrentHeight = newHeight
		end
	end

	-- scrollView:deletePost(postIdx, [transitionTime], [deleteCompleteListener])
	function scrollView:deletePost(...)
		if (self.isDeletingPost) then
			return false
		end
		local postIdx = arg[1]
		local argIdx = 2
		local transitionTime, changeHeightCompleteListener
		if (type(arg[argIdx]) == "number") then
			transitionTime = arg[argIdx]
			argIdx = argIdx + 1
		else
			transitionTime = DEFAULT_CHANGE_HEIGHT_TIME
		end
		if (type(arg[argIdx]) == "function") then
			deleteCompleteListener = arg[argIdx]
			argIdx = argIdx + 1
		end
		local post = self:getPost(postIdx)
		if (post) then
			self.deletingPostTransition = transition.to(post, {x = -scrollView:getView()._width, alpha = 0, time = transitionTime, onComplete = function(obj) self.deletingPostTransition = nil; removePostFromScrollView(obj, self, postIdx); if (deleteCompleteListener) then deleteCompleteListener(); end end})
			local heightDiff = -(post.postCurrentHeight + self.postSpace)
			postTransition(self, postIdx, heightDiff, transitionTime)
		end
		self.isDeletingPost = true
		return true
	end

	function scrollView:deleteAllPost()
		local postTotal = self:getPostTotal()
		for i = 1, postTotal do
			display.remove(self.postArray[i])
		end
		if (self.deletingPostTransition) then
			transition.cancel(self.deletingPostTransition)
			self.deletingPostTransition = nil
		end
		self.postArray = {}
		local scrollViewGroup = scrollView:getView()
		self:resetDataRequestStatus()
		self:setScrollHeight(scrollViewGroup._height)
		self.isScrolling = true
		self:scrollToPosition
		{
			y = scrollViewGroup._topPadding,
			time = 1,
			onComplete = function() self.isScrolling = false; end,
		}
	end

	function scrollView:resetDataRequestStatus()
		local refreshHeader = self.refreshHeader
		if (refreshHeader) then
			if (refreshHeader.refreshIcon) then
				refreshHeader.refreshIcon.rotation = 0
			end
			refreshHeader.textToPull.alpha = 1
			refreshHeader.textToRelease.alpha = 0
			refreshHeader.loadingText.alpha = 0
			self:getView()._topPadding = self.origTopPadding
		end
		self.isReloadDataListenerCalled = false
		self.isRequestDataListenerCalled = false
	end

	return scrollView
end

return scrollViewForPost
