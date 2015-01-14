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
			return self.postArray[totalRow].y + self.postArray[totalRow].postCurrentHeight + self.postSpace
		else
			return self.postSpace
		end
	end

	function scrollView:addNewPost(view, postHeight)
		view.y = self:getScrollHeightForPost()
		self:insert(view)
		view.idx = #self.postArray + 1
		self.postArray[view.idx] = view
		view.postCurrentHeight = postHeight
		local scrollHeight = view.y + postHeight + self.postSpace
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

	function scrollView:changePostHeight(...)
		local rowIdx = arg[1]
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
		local post = scrollView:getPost(rowIdx)
		if (post) then
			local postTotal = scrollView:getPostTotal()
			local scrollViewVisibleAreaLeft, scrollViewVisibleAreaTop = self:getContentPosition()
			local scrollViewVisibleAreaBottom = self:getView()._height + (-scrollViewVisibleAreaTop)
			local heightDiff = newHeight - post.postCurrentHeight
			local changeHeightCompleteListener = self.changeHeightCompleteListener
			local newScrollHeightForPost = scrollView:getScrollHeightForPost() + heightDiff
			if (newHeight < post.postCurrentHeight) then
				local curRowIdx = rowIdx + 1
				while (curRowIdx <= postTotal) do
					local curRow = self.postArray[curRowIdx]
					transition.to(curRow, {y = curRow.y + heightDiff, time = transitionTime, onComplete = changeHeightCompleteListener})
					changeHeightCompleteListener = nil
					curRowIdx = curRowIdx + 1
					if (curRow.y + heightDiff > scrollViewVisibleAreaBottom) then
						break;
					end
				end
				for i = curRowIdx, postTotal do
					local curRow = self.postArray[i]
					curRow.y = curRow.y + heightDiff
				end
				setScrollViewScrollHeight(self, newScrollHeightForPost, transitionTime)
			elseif (newHeight > post.postCurrentHeight) then
				local curRowIdx = rowIdx + 1
				while (curRowIdx <= postTotal) do
					local curRow = self.postArray[curRowIdx]
					transition.to(curRow, {y = curRow.y + heightDiff, time = transitionTime, onComplete = changeHeightCompleteListener})
					changeHeightCompleteListener = nil
					curRowIdx = curRowIdx + 1
					if (curRow.y > scrollViewVisibleAreaBottom) then
						break;
					end
				end
				for i = curRowIdx, postTotal do
					local curRow = self.postArray[i]
					curRow.y = curRow.y + heightDiff
				end
				setScrollViewScrollHeight(self, newScrollHeightForPost, transitionTime)
			end
			post.postCurrentHeight = newHeight
		end
	end

	function scrollView:deletePost(idx)
	end

	return scrollView
end

return scrollViewForPost
