---------------------------------------------------------------
-- Readme.txt
--
-- Instruction on Localization
---------------------------------------------------------------

local SUPPORTED_LANGUAGE 

function localization.getFullNameOfSupportedLocale(locale)
function localization.setLocale(locale)
function localization.getLocale()
function localization.getSystemLocale()
function localization.setToSystemLocale()
function localization.getSupportedLocale()
function localization.getSupportedLocaleName()
function localization.getLocalization(stringKey, stringArrayIndex)
function localization.getLocalizationWithLocale(locale, stringKey, stringArrayIndex)








---------------------------------------------------------------
Setting:

SUPPORTED_LANGUAGE						Array to save the supported language

Default language will be according to system preference
If no supported language for system, the first language in SUPPORTED_LANGUAGE[] will be selected
If the system will only return language major when getting system preference, the first appear major language will be used
eg. :
{
"en",
"zh-Hant",
"zh-Hans"
}
if system will only return "zh", then "zh-Hant" will be used






---------------------------------------------------------------
Common Function:

function localization.getFullPathOfSupportedLocale(locale)

locale:									language to get full path

return:									the language that will support for this locale








function localization.setLocale(locale)

locale:									the full path of the language to set

return:									the final language set for localization








function localization.getLocale()

return:									the language set for localization










function localization.getSystemLocale()

return:									the language get in system preference










function localization.setToSystemLocale()

return:									the language will use according to system preference, nil = no change duw to no supported language











function localization.getSupportedLocale()

return: 								the list of the supported language










function localization.getSupportedLocaleName()

return:									the list of the name of the support language









function localization.getLocalization(stringKey, stringArrayIndex)
function localization.getLocalizationWithLocale(locale, stringKey, stringArrayIndex)

locale:									language set to use
stringKey:								the key of the string/table to get
stringArrayIndex:						index of the string in localized table, default = 1

return									localized string












