---------------------------------------------------------------
-- Readme.txt
--
-- Instruction on Network Handler / Simulated Network Handler
---------------------------------------------------------------

function networkHandler.requestNetwork(apiParamsArray, listener, keyForRequest)
function networkHandler.suspendRequest(key)
function networkHandler.suspendAllRequest()
function networkHandler.resumeRequest(key)
function networkHandler.resumeAllRequest()
function networkHandler.cancelRequest(key)
function networkHandler.cancelAllRequest()
function networkHandler.setDisplayDebugInfo(enable)
function networkHandler.printRequestOfNetworkHandling()												*** debug only ***


function simulatedNetworkHandler.makeSingleSimulatedNetworkEventResponse(isError, response)			*** this is for simulated only ***
function simulatedNetworkHandler.setMinDelayTimeMs(time)											*** this is for simulated only ***
function simulatedNetworkHandler.setMaxDelayTimeMs(time)											*** this is for simulated only ***





---------------------------------------------------------------
Common Function:

function networkHandler.requestNetwork(apiParamsArray, listener, keyForRequest)

apiParamsArray: 						network request parameters
	[]									array size same as APIs call
		url:							url for the API
		method:							HTTP method, default = "GET"
		params:							same params in Network.Request()
		isResumeAfterSystemSuspend:		will resume connection if system suspended, default = true
		listenerEvent:					event table for simulated network handler return				*** this is for simulated only ***
	triggerEventOnCancel:				will call listener on cancel request, default = false
listener:								listener funtion if all API complete, see below for more detail
keyForRequest:							Just a string for custom use

return:									system generater key for network connection, use in other function in NetworkHandler

	listener for requestNetwork:
		function(event)

		event:							event table array for APIs
			key:						keyForRequest in "requestNetwork"
			retryTimes:					retry times for this request
			[]:							network.request event table for individual API

		return:							false to retry network request, otherwise end request







function networkHandler.suspendRequest(key)

key:									key from "requestNetwork"





function networkHandler.resumeRequest(key)

key:									key from "requestNetwork"





function networkHandler.cancelRequest(key)

key:									key from "requestNetwork"





function networkHandler.setDisplayDebugInfo(enable)

enable:									true to display debug log, default false on program run










---------------------------------------------------------------
Simulated Only Function:

function simulatedNetworkHandler.makeSingleSimulatedNetworkEventResponse(isError, response)

isError:								set network listener event value "isError"
response:								set network listener event value "response"

return:									network listener event table for simulated network handler






function simulatedNetworkHandler.setMinDelayTimeMs(time)

time:									minimum delay time for simlated network






function simulatedNetworkHandler.setMaxDelayTimeMs(time)

time:									maximum delay time for simlated network
















