local global = require( "GlobalVar.global" )
local tableSave = require("Module.TableSave")
local storyboard = require ( "storyboard" )
local json = require( "json" )

local moduleGroup = {}

function moduleGroup.back()
	local oldSceneOptions = {}
	oldSceneOptions.effect = "slideRight"
    oldSceneOptions.time = 400
	local oldData = tableSave.pop(global.sceneTransDataPath,global.TEMPBASEDIR)
	oldSceneOptions.params = oldData.params
	if(not oldSceneOptions.params)then
		oldSceneOptions.params = {}
	end
	oldSceneOptions.params.backSceneHeaderOption = global.backSceneHeaderOption
							
	if(oldData.sceneName == "OnePostScene")then
		storyboard.gotoScene("Scene.OnePostScene",oldSceneOptions)
	elseif(oldData.sceneName== "ProfileScene" )then
		storyboard.gotoScene("Scene.ProfileScene",oldSceneOptions)
	elseif(oldData.sceneName== "ProfileScene2" )then
		storyboard.gotoScene("Scene.ProfileScene2",oldSceneOptions)
	elseif(oldData.sceneName== "OnePostScene" )then
		storyboard.gotoScene("Scene.OnePostScene",oldSceneOptions)
	elseif(oldData.sceneName== "OnePostScene2" )then
		storyboard.gotoScene("Scene.OnePostScene2",oldSceneOptions)
	elseif(oldData.sceneName== "VorumTabScene" )then
		tableSave.delete(global.sceneTransDataPath,global.TEMPBASEDIR)
		storyboard.gotoScene("Scene.VorumTabScene",oldSceneOptions)
	elseif(oldData.sceneName== "MeTabScene" )then
		tableSave.delete(global.sceneTransDataPath,global.TEMPBASEDIR)
		storyboard.gotoScene("Scene.MeTabScene",oldSceneOptions)
	else
		print("error, no scene or wrong scene.")
		tableSave.delete(global.sceneTransDataPath,global.TEMPBASEDIR)
		storyboard.gotoScene("Scene.VorumTabScene",oldSceneOptions)
	end
	
end

function moduleGroup.go(sceneOptions,curData,passData,creatorId)
	local newSceneOptions = sceneOptions

	sceneOptions.params = curData
	tableSave.push(global.sceneTransDataPath,global.TEMPBASEDIR,sceneOptions)
	
	newSceneOptions.effect = "fromRight"
    newSceneOptions.time = 400
	newSceneOptions.params = passData
	
	if(sceneOptions.sceneName == "ProfileScene2")then
		storyboard.gotoScene("Scene.ProfileScene",newSceneOptions)
	elseif(sceneOptions.sceneName == "ProfileScene")then
		storyboard.gotoScene("Scene.ProfileScene2",newSceneOptions)
	else
		storyboard.gotoScene("Scene.ProfileScene",newSceneOptions)
	end

end


function moduleGroup.goPost(sceneOptions,curData,passData,creatorId)
	local newSceneOptions = sceneOptions
	sceneOptions.params = curData
	tableSave.push(global.sceneTransDataPath,global.TEMPBASEDIR,sceneOptions)
	
	newSceneOptions.effect = "fromRight"
    newSceneOptions.time = 400
    newSceneOptions.params = passData
	print("postDatata",json.encode( newSceneOptions.params))

	if(sceneOptions.sceneName == "OnePostScene2" )then
		storyboard.gotoScene("Scene.OnePostScene",newSceneOptions)
	elseif(sceneOptions.sceneName == "OnePostScene" )then
		storyboard.gotoScene("Scene.OnePostScene2",newSceneOptions)
	else
		storyboard.gotoScene("Scene.OnePostScene",newSceneOptions)
	end
end

return moduleGroup