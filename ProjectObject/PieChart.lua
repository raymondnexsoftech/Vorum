---------------------------------------------------------------
-- PieChart.lua
--
-- Create Pie Chart
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

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local PIE_CHART_SLICE_MAX_ANGLE = 120
local MAX_ANGLE_TO_PERCENTAGE = math.floor(PIE_CHART_SLICE_MAX_ANGLE * 100 / 360)

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------

local pieChart = {}

-- local function applyMaskFromPolygon(object, polygon, maskName)
--   --we use these to scale down the mask so that it looks exactly the same on any device
-- 	local pixelWidth, pixelHeight;
-- 	local contentWidth, contentHeight = display.contentWidth-(display.screenOriginX*2), display.contentHeight-(display.screenOriginY*2);
-- 	if contentWidth > contentHeight then
-- 		pixelWidth = display.pixelHeight;
-- 		pixelHeight = display.pixelWidth;
-- 	else
-- 		pixelWidth = display.pixelWidth;
-- 		pixelHeight = display.pixelHeight;
-- 	end

-- 	local maskGroup = display.newGroup();
-- 	--create a rect with width and height higher than polygon and rounded up to 2^)
-- 	local rectWidth, rectHeight = 1, 1;
-- 	while (rectWidth < polygon.contentWidth) do
-- 		rectWidth = rectWidth*2;
-- 	end
-- 	while (rectHeight < polygon.contentHeight) do
-- 		rectHeight = rectHeight*2;
-- 	end
-- 	local blackRect = display.newRect(maskGroup, 0, 0, rectWidth, rectHeight);
-- 	blackRect:setFillColor(0, 0, 0);

-- 	maskGroup:insert(polygon);
-- 	polygon.x, polygon.y = 0, 0;
-- 	polygon:setFillColor(1, 1, 1, 1);

-- 	maskGroup.x, maskGroup.y = display.contentCenterX, display.contentCenterY;

-- 	display.save(maskGroup, {filename = maskName or "mask.jpg", baseDir = system.TemporaryDirectory, isFullResolution = true});

-- 	local mask = graphics.newMask(maskName or "mask.jpg", system.TemporaryDirectory);
-- 	object:setMask(mask);

-- 	--here we scale down the mask to make it consistent across devices
-- 	object.maskScaleX = contentWidth/pixelWidth;
-- 	object.maskScaleY = object.maskScaleX;

-- 	maskGroup:removeSelf();
-- end

-- pieChart.create = function(data)
-- 	-- local snapshot = display.newSnapshot(data.radius * 2 + 10, data.radius * 2 + 10);
-- 	-- local group = snapshot.group
-- 	local group = display.newGroup()

-- 	local brush = { type="image", filename="Image/PieChart/brush.png"};

-- 	local values = data.values;
-- 	local mSin, mCos = math.sin, math.cos;
-- 	local toRad = math.pi/180;
-- 	local currAngle = -90;
-- 	local strokesSlices = {};

-- 	for i = #values, 1, -1 do
-- 	if values[i].percentage <= 0 then
-- 		table.remove(values, i);
-- 	elseif values[i].percentage == 100 then
-- 		values[i].percentage = 99.9;
-- 	end
-- 	end

-- 	for i = 1, #values do
-- 	local newAngle = values[i].percentage*360*0.01;
-- 	local midAngle1, midAngle2;
-- 	local shape;

-- 	if newAngle > 180 then
-- 		newAngle = currAngle+newAngle;
-- 		midAngle1 = currAngle+(newAngle-180-currAngle)*.5;
-- 		midAngle2 = midAngle1+(newAngle-90-midAngle1)*.5;
-- 		midAngle3 = midAngle2+(newAngle-90-midAngle2)*.5;
-- 		midAngle4 = midAngle3+(newAngle-midAngle3)*.5;
-- 		shape = {0, 0, mCos(currAngle*toRad)*data.radius*2, mSin(currAngle*toRad)*data.radius*2, mCos(midAngle1*toRad)*data.radius*2, mSin(midAngle1*toRad)*data.radius*2, mCos(midAngle2*toRad)*data.radius*2, mSin(midAngle2*toRad)*data.radius*2, 
-- 			mCos(midAngle3*toRad)*data.radius*2, mSin(midAngle3*toRad)*data.radius*2, mCos(midAngle4*toRad)*data.radius*2, mSin(midAngle4*toRad)*data.radius*2, mCos(newAngle*toRad)*data.radius*2, mSin(newAngle*toRad)*data.radius*2};
-- 	else
-- 		newAngle = currAngle+newAngle;
-- 		midAngle1 = currAngle+(newAngle-currAngle)*.5;
-- 		shape = {0, 0, mCos(currAngle*toRad)*data.radius*2, mSin(currAngle*toRad)*data.radius*2, mCos(midAngle1*toRad)*data.radius*2, mSin(midAngle1*toRad)*data.radius*2, mCos(newAngle*toRad)*data.radius*2, mSin(newAngle*toRad)*data.radius*2};
-- 	end
-- 	currAngle = newAngle;

-- 	local slice = display.newPolygon(0, 0, shape);
-- 	group:insert(slice)

-- 	slice:setFillColor(unpack(values[i].color));
-- 	slice.stroke = brush;
-- 	-- slice.strokeWidth = 2;
-- 	-- slice:setStrokeColor(unpack(values[i].color));
-- 	slice.strokeWidth = 3;
-- 	slice:setStrokeColor(81/255,81/255,81/255);

-- 	local lowerPointX, higherPointX, lowerPointY, higherPointY = 10000, -10000, 10000, -10000;
-- 	for i = 1, #shape, 2 do
-- 		if shape[i] < lowerPointX then
-- 			lowerPointX = shape[i];
-- 		end
-- 		if shape[i] > higherPointX then
-- 			higherPointX = shape[i];
-- 		end
-- 		if shape[i+1] < lowerPointY then
-- 			lowerPointY = shape[i+1];
-- 		end
-- 		if shape[i+1] > higherPointY then
-- 			higherPointY = shape[i+1];
-- 		end
-- 	end

-- 	slice.x = lowerPointX+(higherPointX-lowerPointX)*.5;
-- 	slice.y = lowerPointY+(higherPointY-lowerPointY)*.5;
-- 	end

-- 	if (data.mask) then
-- 		local mask = graphics.newMask(data.mask.path, data.mask.baseDir)
-- 		group:setMask(mask)
-- 	else
-- 		local circle = display.newCircle(0, 0, data.radius)
-- 		circle.stroke = brush;
-- 		circle.strokeWidth = 2;
-- 		applyMaskFromPolygon(group, circle);
-- 	end

-- 	return group
-- 	-- snapshot:invalidate()
-- 	-- return snapshot;
-- end

function pieChart.create(data)
	local radius = data.radius
	local pieChartData = data.values
	local transitionTime = data.time
	local easing = data.transition

	-- local pieChartSliceVertexX = radius * PIE_CHART_SLICE_VERTEX_X_CONST
	local pieChartGroup = display.newGroup()
	if (data.mask) then
		local mask = graphics.newMask(data.mask.path, data.mask.baseDir)
		pieChartGroup:setMask(mask)
	end

	local cumulativeAngle = 0

	local count = 0
	local lastPieChartSlice
	local lastPieChartSliceAngle = 0
	local pieChartSliceStrokeList = {}
	for i = 1, #pieChartData do
		local curDataRemainPercent = pieChartData[i].percentage
		while(curDataRemainPercent > 0) do
			local pieChartSliceStroke
			local pieChartSliceX3Pos, pieChartSliceY3Pos
			local angleToProcess
			local pieChartSliceVertexX
			if (curDataRemainPercent > MAX_ANGLE_TO_PERCENTAGE) then
				curDataRemainPercent = curDataRemainPercent - 25
				angleToProcess = 90
				pieChartSliceX3Pos = 0
				pieChartSliceY3Pos = 0
				pieChartSliceVertexX = radius
			else
				local pieChartSliceRadian = curDataRemainPercent * math.pi / 50
				angleToProcess = curDataRemainPercent * 3.6
				pieChartSliceVertexX = radius * math.abs(math.tan(angleToProcess * math.pi / 360))
				pieChartSliceX3Pos = radius * math.sin(pieChartSliceRadian) - pieChartSliceVertexX
				pieChartSliceY3Pos = radius * (-math.cos(pieChartSliceRadian))
				curDataRemainPercent = 0
				pieChartSliceStroke = display.newLine(pieChartGroup, 0, 0, 0, -radius)
				pieChartSliceStroke.strokeWidth = 3
				pieChartSliceStroke:setStrokeColor(81/255,81/255,81/255)
				pieChartSliceStrokeList[#pieChartSliceStrokeList + 1] = pieChartSliceStroke
			end
			local pieChartSlice = display.newRect(pieChartGroup, 0, 0, pieChartSliceVertexX, radius)
			pieChartSlice.anchorX = 0
			pieChartSlice.anchorY = 1
			pieChartSlice:setFillColor(unpack(pieChartData[i].color))
			if ((transitionTime ~= nil) and (transitionTime > 0)) then
				if (pieChartSliceStroke) then
					transition.to(pieChartSliceStroke, {rotation = cumulativeAngle + angleToProcess, time = transitionTime, transition = easing})
				end
				pieChartSlice.path.x3 = -pieChartSliceVertexX
				pieChartSlice.path.y3 = -radius
				transition.to(pieChartSlice, {rotation = cumulativeAngle, time = transitionTime, transition = easing})
				transition.to(pieChartSlice.path, {x3 = pieChartSliceX3Pos, y3 = pieChartSliceY3Pos, time = transitionTime * 0.8, transition = easing})
			else
				if (pieChartSliceStroke) then
					pieChartSliceStroke.rotation = cumulativeAngle + angleToProcess
				end
				pieChartSlice.rotation = cumulativeAngle
				pieChartSlice.path.x3 = pieChartSliceX3Pos
				pieChartSlice.path.y3 = pieChartSliceY3Pos
			end
			cumulativeAngle = cumulativeAngle + angleToProcess
			lastPieChartSlice = pieChartSlice
			lastPieChartSliceAngle = angleToProcess
		end
	end
	for i = 1, #pieChartSliceStrokeList do
		pieChartSliceStrokeList[i]:toFront()
	end
	pieChartSliceStrokeList = nil

	return pieChartGroup
end

return pieChart
