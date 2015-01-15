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
require ( "DebugUtility.Debug" )
local widget = require ( "widget" )

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local DEFAULT_POST_SPACE = 10
local DEFAULT_CHANGE_HEIGHT_TIME = 100

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
	local scrollViewVisibleHeight = scrollView:getView()._height
	local newScrollHeight = 0
	if (scrollHeight > scrollViewVisibleHeight) then
		newScrollHeight = scrollHeight
	else
		newScrollHeight = scrollViewVisibleHeight
	end
	scrollView:setScrollHeight(newScrollHeight)
	local scrollX, scrollY = scrollView:getContentPosition()
	local scrollVisibleBottomY = -scrollY + scrollViewVisibleHeight
	if (newScrollHeight < scrollVisibleBottomY) then
		scrollView:scrollToPosition
		{
			y = -newScrollHeight + scrollViewVisibleHeight,
			time = transitionTime,
		}
	end
end

function scrollViewForPost.newScrollView(options)
	local scrollView = widget.newScrollView(options)
	scrollView.postSpace = options.postSpace or DEFAULT_POST_SPACE
	scrollView.postArray = {}

	function scrollView:getPostTotal()
		return #self.postArray
	end

	function scrollView:getPost(idx)
		return self.postArray[idx]
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
			return self.postSpace
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
		setScrollViewScrollHeight(self, scrollHeight)
		return view.idx
	end

	function scrollView:checkFocusToScrollView(event)
		local touchDisp = touchDisplacement(event)
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
				transition.to(curRow, {y = curRow.curY, time = transitionTime, onComplete = changeHeightCompleteListener})
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
				transition.to(curRow, {y = curRow.curY, time = transitionTime, onComplete = changeHeightCompleteListener})
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

	local function removePostFromScrollView(post, scrollView, idx)
		display.remove(post)
		table.remove(scrollView.postArray, idx)
		scrollView:setScrollHeight(scrollView:getScrollHeightForPost())
		local postTotal = #scrollView.postArray
		for i = 1, postTotal do
			scrollView.postArray[i].idx = i
		end
	end

	-- scrollView:deletePost(postIdx, [transitionTime], [deleteCompleteListener])
	function scrollView:deletePost(...)
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
			transition.to(post, {x = -scrollView:getView()._width, alpha = 0, time = transitionTime, onComplete = function(obj) removePostFromScrollView(obj, self, postIdx); if (deleteCompleteListener) then deleteCompleteListener(); end end})
			local heightDiff = -(post.postCurrentHeight + self.postSpace)
			postTransition(self, postIdx, heightDiff, transitionTime)
		end
	end

	return scrollView
end

return scrollViewForPost
