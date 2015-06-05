---------------------------------------------------------------
-- TemplateScene.lua
--
-- Template for Scene
---------------------------------------------------------------

-- uncomment the below code to get the directory of the file
--local resDir = (...):match("(.-)[^%.]+$")


---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------
local widget = require ( "widget" )
require ( "SystemUtility.Debug" )
local projectObjectSetting = require( "Setting.ProjectObjectSetting" )
local localization = require("Localization.Localization")
local lfs = require( "lfs" )
-- local networkFunction = require("Network.NetworkFunction")
local sizableActivityIndicatorFnc = require("Module.SizableActivityIndicator")
local tunePhotoModule = require("Module.TunePhoto")
local functionalOption = require( "Module.FunctionalOption" )
local hardwareButtonHandler = require("ProjectObject.HardwareButtonHandler")
local newNetworkFunction = require("Network.newNetworkFunction")
---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local returnGroup = {}
local PHOTO_FUNCTION = media.PhotoLibrary 
local group_addPhoto 
local group_buttonsField
local BUTTONHEIGHT = 75
local BUTTONNUMBER = 3
local MASKPATH = "Image/RegisterPage/addPhoto_mask.png"
local DESTINATION = {}
DESTINATION.baseDir = system.TemporaryDirectory
DESTINATION.filename = nil
DESTINATION.type = "image"

local TEMPONE = "_temp1"
local TEMPTWO = "_temp2"
local RESIZESTR = "_resize"
---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
local savePathLen
local tempOnePath
local tempTwoPath
local boolean_tempOneIsExist
local boolean_tempTwoIsExist
local dotPos

local button_addPhoto

local loadingIcon

local resizedFileName
local tuneImageOption
local optionVaule
---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------
---------------------------------------------------------------
-- Functions
---------------------------------------------------------------

-------------------- image control
-- function to check file whether exist
local function setActivityIndicatorFnc(boolean_loading)
	if(not loadingIcon and boolean_loading)then
		loadingIcon = sizableActivityIndicatorFnc.newActivityIndicator(display.contentWidth,display.contentHeight)
		loadingIcon.x = display.contentCenterX
		loadingIcon.y = display.contentCenterY
		loadingIcon:setEnable(true)
	elseif(loadingIcon and boolean_loading)then
		loadingIcon:setEnable(true)
	elseif(loadingIcon and not boolean_loading)then
		loadingIcon:setEnable(false)
	end
end
local function doesFileExist( fname, path )

    local results = false

    local filePath = system.pathForFile( fname, path )

    --filePath will be 'nil' if file doesn't exist and the path is 'system.ResourceDirectory'
    if ( filePath ) then
        filePath = io.open( filePath, "r" )
		-- print("file open")
    end

    if ( filePath ) then
        -- print( "File found: " .. fname )
        --clean up file handles
        filePath:close()
        results = true
    else
        -- print( "File does not exist")
    end

    return results
end
local function getResizePicPath(filename)
	local filenameLen = string.len(filename)
	local dotPos = string.find(filename, ".",1,true)
	local newFileName = string.sub(filename,1, dotPos-1)..RESIZESTR..string.sub(filename,dotPos,filenameLen)
	return newFileName
end


local function getFilePath(fileObj,action)
	savePathLen = string.len(fileObj.savePath)
	dotPos = string.find(fileObj.savePath, ".",1,true)
	-- print(dotPos)
	tempOnePath = string.sub(fileObj.savePath,1, dotPos-1)..TEMPONE..string.sub(fileObj.savePath,dotPos,savePathLen)
	-- print("tempONEPath",tempOnePath)
	tempTwoPath = string.sub(fileObj.savePath,1, dotPos-1)..TEMPTWO..string.sub(fileObj.savePath,dotPos,savePathLen)
	-- print("tempTwoPath",tempTwoPath)
	boolean_tempOneIsExist = doesFileExist(tempOnePath,DESTINATION.baseDir)
	-- print("ONE",boolean_tempOneIsExist)
	boolean_tempTwoIsExist = doesFileExist(tempTwoPath,DESTINATION.baseDir)
	-- print("TWO",boolean_tempTwoIsExist)
	
	if(boolean_tempOneIsExist and not boolean_tempTwoIsExist and action=="new")then
		-- print("one exist, new")
		return tempTwoPath
	elseif(not boolean_tempOneIsExist and boolean_tempTwoIsExist and action=="new")then
		-- print("two exist, new")
		return tempOnePath
	elseif(boolean_tempOneIsExist and boolean_tempTwoIsExist and action=="new")then
		-- print("both exist, new")
		return tempOnePath
	elseif(not boolean_tempOneIsExist and not boolean_tempTwoIsExist and action=="new")then
		-- print("both not exist, new")
		return tempOnePath
	end
	
	if(boolean_tempOneIsExist and not boolean_tempTwoIsExist and action=="get")then
		-- print("one exist, get")
		return tempOnePath
	elseif(not boolean_tempOneIsExist and boolean_tempTwoIsExist and action=="get")then
		-- print("two exist, get")
		return tempTwoPath
	elseif(boolean_tempOneIsExist and boolean_tempTwoIsExist and action=="get")then
		-- print("both exist, get")
		return tempTwoPath
	elseif(not boolean_tempOneIsExist and not boolean_tempTwoIsExist and action=="get")then
		-- print("both not exist, get")
		return nil
	end
end

local function removeDataPhoto(action)
	local results = nil
	local reason = nil
	local resizedFileName
	resizedFileName_tempOne = getResizePicPath(tempOnePath)
	resizedFileName_tempTwo = getResizePicPath(tempTwoPath)
	if(boolean_tempOneIsExist and not boolean_tempTwoIsExist and action=="new")then
		results, reason = os.remove( system.pathForFile( tempOnePath, DESTINATION.baseDir  ) )
		results, reason = os.remove( system.pathForFile( resizedFileName_tempOne, DESTINATION.baseDir  ) )
	elseif(not boolean_tempOneIsExist and boolean_tempTwoIsExist and action=="new")then
		results, reason = os.remove( system.pathForFile( tempTwoPath, DESTINATION.baseDir  ) )
		results, reason = os.remove( system.pathForFile( resizedFileName_tempTwo, DESTINATION.baseDir  ) )
	elseif(boolean_tempOneIsExist and boolean_tempTwoIsExist and action=="new")then
		results, reason = os.remove( system.pathForFile( tempTwoPath, DESTINATION.baseDir  ) )
		results, reason = os.remove( system.pathForFile( resizedFileName_tempTwo, DESTINATION.baseDir  ) )
	elseif(not boolean_tempOneIsExist and not boolean_tempTwoIsExist and action=="new")then
	elseif(action=="delete")then
		results, reason = os.remove( system.pathForFile( tempOnePath, DESTINATION.baseDir  ) )
		results, reason = os.remove( system.pathForFile( tempTwoPath, DESTINATION.baseDir  ) )
		results, reason = os.remove( system.pathForFile( resizedFileName_tempOne, DESTINATION.baseDir  ) )
		results, reason = os.remove( system.pathForFile( resizedFileName_tempTwo, DESTINATION.baseDir  ) )
	end

end

local function removeDisplayPhoto()
	if(button_addPhoto.photo) then
		if(button_addPhoto.photo.parent) then
			button_addPhoto.photo.parent:remove(button_addPhoto.photo)
		end
		display.remove( button_addPhoto.photo )	-- remove the previous photo object
		button_addPhoto.photo = nil
		button_addPhoto:toFront()
	end
end

local function imageProcess (processedObj)
-- Scale image to fit content scaled screen
	local xScale = processedObj.width / processedObj.photo.contentWidth
	local yScale = processedObj.height / processedObj.photo.contentHeight
	
	local scale = math.max( xScale, yScale )
	processedObj.photo:scale( scale, scale )
	if(processedObj.anchorX==0)then
		processedObj.photo.x = processedObj.x +(processedObj.width-processedObj.photo.width*scale)/2
		processedObj.photo.anchorX=0
	elseif(processedObj.anchorX==0.5)then
		processedObj.photo.x = processedObj.x
		processedObj.photo.anchorX=0.5
	elseif(processedObj.anchorX==1)then
		processedObj.photo.x = processedObj.x -(processedObj.width-processedObj.photo.width*scale)/2
		processedObj.photo.anchorX=1
	else
		processedObj.photo.x = processedObj.x
		processedObj.photo.anchorX=0.5
	end
	
	if(processedObj.anchorY==0)then
		processedObj.photo.y = processedObj.y+(processedObj.height-processedObj.photo.height*scale)/2
		processedObj.photo.anchorY=0
	elseif(processedObj.anchorY==0.5)then
		processedObj.photo.y = processedObj.y
		processedObj.photo.anchorY=0.5
	elseif(processedObj.anchorY==1)then
		processedObj.photo.y = processedObj.y-(processedObj.height-processedObj.photo.height*scale)/2
		processedObj.photo.anchorY=1
	else
		processedObj.photo.y = processedObj.y
		processedObj.photo.anchorY=0.5
	end
	
	local mask = graphics.newMask( MASKPATH )
	processedObj.photo:setMask( mask )
	processedObj.photo.maskScaleX, processedObj.photo.maskScaleY = 1/scale,1/scale
	
	if(processedObj.parent) then
		processedObj.parent:insert(processedObj.photo)
	end
	processedObj:toBack()
end


local deletePhoto = function(event)
	if(event.phase=="ended" or event.phase=="cancelled")then
		
		setActivityIndicatorFnc(true)--set activity true to show loading
		
		removeDisplayPhoto()
		removeDataPhoto("delete")
		
		setActivityIndicatorFnc(false)
		
		functionalOption.hide()
		
	end
	return true
end
local function tunePhotoCallBackFnc(event)
	newNetworkFunction.resizePic(resizedFileName,resizedFileName,DESTINATION.baseDir)
	removeDisplayPhoto()
	removeDataPhoto("new")
	button_addPhoto.photo = display.newImage(resizedFileName,DESTINATION.baseDir)
	imageProcess(button_addPhoto)
end

local function tunePhoto_keyEventFunction(event)
	if event.phase == "up" and event.keyName == "back" then
		tunePhotoModule.hide()
	end
	return true
end

local function tunePhoto_setKeyEvent()
	local isActivateNow = hardwareButtonHandler.getStatus()
	if(not isActivateNow)then
		hardwareButtonHandler.activate()
	end
	hardwareButtonHandler.addCallback(tunePhoto_keyEventFunction,true)
end

local function tunePhoto_removeKeyEvent()
	local isActivateNow = hardwareButtonHandler.getStatus()
		
	if(not isActivateNow)then
		hardwareButtonHandler.activate()
	end
	hardwareButtonHandler.removeCallback(tunePhoto_keyEventFunction)
end

local function sessionComplete(event)
	
	local boolean_havePhoto = doesFileExist(DESTINATION.filename,DESTINATION.baseDir)
	if(not boolean_havePhoto)then
		setActivityIndicatorFnc(false)--set activity true to show loading
		return false
	end

	resizedFileName = getResizePicPath(DESTINATION.filename)
	tuneImageOption = {
		photoSavePath = DESTINATION.filename,
		photoSaveDir = DESTINATION.baseDir,
		newPhotoSavePath = resizedFileName,
		newPhotoSaveDir = DESTINATION.baseDir,
		doneButtonCallBackFnc = tunePhotoCallBackFnc,
		startListener = tunePhoto_setKeyEvent,
		endListener = tunePhoto_removeKeyEvent,
	}
	tunePhotoModule.tune(tuneImageOption)
	setActivityIndicatorFnc(false)--set activity true to show loading
	functionalOption.hide()
	
end

-------------- take photo begin
local function addPhoto_takePhoto(event)
	if(event.phase=="ended" or event.phase=="cancelled")then
		if media.hasSource( media.Camera ) then
			setActivityIndicatorFnc(true)
			media.capturePhoto( { listener = sessionComplete,destination = DESTINATION } )
		else
			native.showAlert("Corona", "Camera not found.")
		end
	end
	return true
end
-------------- take photo end

-------------- pick photo begin
local function addPhoto_pickPhoto(event)
	if(event.phase=="ended" or event.phase=="cancelled")then
		-- Delay some to allow the display to refresh before calling the Photo Picker
		setActivityIndicatorFnc(true)
		timer.performWithDelay( 100, function() media.selectPhoto( { listener = sessionComplete, mediaSource = PHOTO_FUNCTION, destination = DESTINATION } ) 
		end )
	end
	return true
end
--------------- pick photo end
function returnGroup.imageProcess(processedObj)
	imageProcess (processedObj)
end

function returnGroup.getImageRealPath(savePath)
	local fakeObject = {}
	fakeObject.savePath = savePath
	local curImagePath = getFilePath(fakeObject,"get")
	local curResizeImagePath = nil
	if(curImagePath)then
		curResizeImagePath = getResizePicPath(curImagePath)
	end
	return curResizeImagePath
end
function returnGroup.deleteTempImage(savePath)
	local fakeObject = {}
	fakeObject.savePath = savePath
	getFilePath(fakeObject,nil)
	removeDataPhoto("delete")
end
function returnGroup.loadPerviousPhoto(button_addPhoto)
	-- print("Load Pervious Photo")
	DESTINATION.filename = getFilePath(button_addPhoto,"get")
	-- print("DESTINATION",DESTINATION.filename)
	
	if(DESTINATION.filename~=nil and DESTINATION.filename~=false)then
		button_addPhoto.photo = display.newImage(DESTINATION.filename,DESTINATION.baseDir)
		imageProcess(button_addPhoto)
		-- print("Load Pervious Photo Success")
	end
end

local function addPhoto_keyEventFunction(event)
	if event.phase == "up" and event.keyName == "back" then
		functionalOption.hide()
	end
	return true
end

local function addPhoto_setKeyEvent()

	local isActivateNow = hardwareButtonHandler.getStatus()
		
	if(not isActivateNow)then
		hardwareButtonHandler.activate()
	end
	hardwareButtonHandler.addCallback(addPhoto_keyEventFunction,true)
end

local function addPhoto_removeKeyEvent()

	local isActivateNow = hardwareButtonHandler.getStatus()
		
	if(not isActivateNow)then
		hardwareButtonHandler.activate()
	end
	hardwareButtonHandler.removeCallback(addPhoto_keyEventFunction)
end

function returnGroup.addPhoto(event)

	button_addPhoto=event.target

	DESTINATION.filename = getFilePath(button_addPhoto,"new")
	
	optionVaule = 
	{
		choiceObj = {localization.getLocalization("addPhoto_takePhoto"), localization.getLocalization("addPhoto_pickPhoto"), localization.getLocalization("addPhoto_deletePhoto"), },
		choiceFnc = {addPhoto_takePhoto,addPhoto_pickPhoto,deletePhoto},
		cancelButtonText = localization.getLocalization("addPhoto_cancel"),
		choiceObj_fontFamily = "Helvetica",
		startListener = addPhoto_setKeyEvent,
		endListener = addPhoto_removeKeyEvent,
	}
	functionalOption.create(optionVaule)
end

return returnGroup
