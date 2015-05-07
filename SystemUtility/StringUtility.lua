---------------------------------------------------------------
-- StringUtility.lua
--
-- String Utility
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
local UTF8_SIZE_START = {1, 192, 224, 240, 248, 252}
local UTF8_HEADER_TO_SIZE = {}
local charSize = UTF8_SIZE_START[1]
for i = 1, #UTF8_SIZE_START - 1 do
	for j = UTF8_SIZE_START[i], UTF8_SIZE_START[i+1] do
		UTF8_HEADER_TO_SIZE[j] = i
	end
end
local EMOJI_UNICODE_RANGE = {
								{169, 169},				-- circled "C"
								{174, 174},				-- circled "R"
								{8482, 12953},			-- Uncategorized 1
								-- {9986, 10160},			-- Dingbats, enclosed in Uncategorized
								{126980, 128591},			-- Emoticons + Uncategorized 2 + Additional emoticons
								-- {126980, 128511},		-- Uncategorized 2
								-- -- {127344, 127569},		-- Enclosed characters, enclosed in Uncategorized 2
								-- -- {127757, 128359},			-- Other additional symbols, enclosed in Uncategorized 2
								-- {128513, 128591},		-- Emoticons
								-- -- {128512, 128566},		-- Additional emoticons, enclosed in Emoticons
								{128640, 128709},			-- Transport and map + Additional transport and map
								-- {128640, 128704},		-- Transport and map
								-- {128641, 128709},		-- Additional transport and map
								{65024, 65039},			-- Variation Selector
							}

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
local stringUtility = {}

local function isEmoji(unicode)
	for i = 1, #EMOJI_UNICODE_RANGE do
		if ((unicode >= EMOJI_UNICODE_RANGE[i][1]) and (unicode <= EMOJI_UNICODE_RANGE[i][2])) then
			return true
		end
	end
end

local function getUtf8CharByte(str, pos)
	local headerToByte = string.byte(str, pos)
	if (headerToByte < 128) then
		return nil, 1
	end
	local size = UTF8_HEADER_TO_SIZE[headerToByte]
	local returnVal = headerToByte - UTF8_SIZE_START[size]
	for i = pos + 1, pos + size - 1 do
		returnVal = returnVal * 64 + (string.byte(str, i) - 128)
	end
	return returnVal, size
end

function stringUtility.trimEmoji(str)
	if ((type(str) == "string") and (str ~= "")) then
		local returnStr = ""
		local startCopyLoc
		local strlen = string.len(str)
		local isEmojiDetected = false
		local i = 1
		while (i <= strlen) do
			local charByte, size = getUtf8CharByte(str, i)
			if (charByte == nil) then
				startCopyLoc = startCopyLoc or i
				i = i + 1
			else
				if (isEmoji(charByte)) then
					isEmojiDetected = true
					if (startCopyLoc) then
						returnStr = returnStr .. string.sub(str, startCopyLoc, i - 1)
						startCopyLoc = nil
					end
				else
					startCopyLoc = startCopyLoc or i
				end
				i = i + size
			end
		end
		if (startCopyLoc) then
			returnStr = returnStr .. string.sub(str, startCopyLoc, i - 1)
			startCopyLoc = nil
		end
		return returnStr, isEmojiDetected
	end
	return "", false
end

function stringUtility.trimStringSpace(str)
	local returnStr = string.gsub(str, "^%s+", "")
	returnStr = string.gsub(returnStr, "%s+$", "")
	return returnStr
end

return stringUtility
