---------------------------------------------------------------
-- Localization.lua
--
-- manage localization
---------------------------------------------------------------
local resDir = (...):match("(.-)[^%.]+$")


-- Local Constant Setting
local LOCAL_SETTINGS = {
						RES_DIR = resDir,				-- Common resource directory for scene
						DOC_DIR = "",					-- Common document directory for scene
						}

---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------
local SUPPORTED_LANGUAGE = {
							"en",
							"zh-Hant",
							"zh-Hans",
							}

local SUPPORTED_LANGUAGE_MAJOR_TABLE

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
local appLocale
local localizationList = {}
local supportLanguageMajorTable = {}

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------

local localization = {}

function localization.getFullPathOfSupportedLocale(locale)
	local localeTable = localizationList[locale]
	if (localeTable) then
		return locale
	end
	local languageMajor = string.match(locale, "^(%a+)%-*")
	locale = supportLanguageMajorTable[languageMajor]
	localeTable = localizationList[locale]
	if (localeTable) then
		return locale
	end
	return nil
end

function localization.setLocale(locale)
	if (localizationList[locale] == nil) then
		appLocale = SUPPORTED_LANGUAGE[1]
	else
		appLocale = locale
	end
	return appLocale
end

function localization.getLocale()
	return appLocale
end

function localization.getSystemLocale()
	if (system.getInfo( "platformName" ) == "Android" ) then
		return string.gsub(system.getPreference("locale", "language"), "_", "-")
	else
		return system.getPreference("ui", "language")
	end
end

function localization.setToSystemLocale()
	local systemLocale = localization.getFullPathOfSupportedLocale(localization.getSystemLocale())
	if (systemLocale) then
		localization.setLocale(systemLocale)
	end
	return systemLocale
end

function localization.getSupportedLocale()
	local returnTable = {}
	local i
	for i = 1, #SUPPORTED_LANGUAGE do
		returnTable[i] = SUPPORTED_LANGUAGE[i]
	end
	return returnTable
end

function localization.getSupportedLocaleName()
	local returnTable = {}
	local i
	for i = 1, #SUPPORTED_LANGUAGE do
		returnTable[i] = localizationList[SUPPORTED_LANGUAGE[i]].name
	end
	return returnTable
end

function localization.getLocalization(stringKey, stringArrayIndex)
	local returnData = localizationList[appLocale].list[stringKey]
	if (type(returnData) == "table") then
		local stringIndex = stringArrayIndex
		if ((type(stringIndex) ~= "number") or (stringIndex < 1)) then
			stringIndex = 1
		end
		returnData = returnData[stringIndex]
	end
	if (returnData == nil) then
		returnData = ""
	end
	return returnData
end

function localization.getLocalizationWithLocale(locale, stringKey, stringArrayIndex)
	local returnData
	if (localizationList[locale]) then
		returnData = localizationList[locale].list[stringKey]
	else
		returnData = localizationList[SUPPORTED_LANGUAGE[1]].list[stringKey]
	end
	if (type(returnData) == "table") then
		local stringIndex = stringArrayIndex
		if ((type(stringIndex) ~= "number") or (stringIndex < 1)) then
			stringIndex = 1
		end
		returnData = returnData[stringIndex]
	end
	if (returnData == nil) then
		returnData = ""
	end
	return returnData
end


-------------------------------------------------------------
-- pre-run code
-------------------------------------------------------------

for i = 1, #SUPPORTED_LANGUAGE do
	local language = SUPPORTED_LANGUAGE[i]
	localizationList[SUPPORTED_LANGUAGE[i]] = require(LOCAL_SETTINGS.RES_DIR .. language)
	local languageMajor = string.match(language, "^(%a+)%-*")
	if (supportLanguageMajorTable[languageMajor] == nil) then
		supportLanguageMajorTable[languageMajor] = language
	end
end
if (localization.setToSystemLocale() == nil) then
	appLocale = SUPPORTED_LANGUAGE[1]
end

return localization

