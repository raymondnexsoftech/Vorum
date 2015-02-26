---------------------------------------------------------------
-- GeolocationUtility.lua
--
-- Utility for Geolocation
---------------------------------------------------------------

-- Local Constant Setting
local LOCAL_SETTINGS = {
						RES_DIR = "",					-- Common resource directory for scene
						DOC_DIR = "",					-- Common document directory for scene
						}

---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------
local json = require("json")
---------------------------------------------------------------
-- Constants
---------------------------------------------------------------
local EARTH_RADIUS = 6367000
local RADIAN = math.pi / 180

local SIMULATOR_LATITUDE = 22.30383			-- Assume the position is at hung hom
local SIMULATOR_LONGITUDE = 114.18297

local TIMER_TIMEOUT = 4000

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------
local getLocationListener
local isGettingLocation = false
local locationTimer = nil

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
local geolocationUtility = {}

local function cancelGeoTimer()
	if ( locationTimer ~= nil ) then
		timer.cancel(locationTimer)
		locationTimer = nil
	end
end

local function geolocationListener(event)
	geolocationUtility.cancelGetLocation()
	if (system.getInfo("environment") == "simulator") then
		event.latitude = SIMULATOR_LATITUDE
		event.longitude = SIMULATOR_LONGITUDE
	end
	if (getLocationListener) then
		getLocationListener(event)
	end
end

local function locationTimerListener()
	local event = {}

	geolocationUtility.cancelGetLocation()
	event.isGeoTimeout = true
	event.latitude = SIMULATOR_LATITUDE
	event.longitude = SIMULATOR_LONGITUDE

	if (getLocationListener) then
		getLocationListener(event)
	end
end

function geolocationUtility.getLocation(listener)
	if (isGettingLocation ~= true) then
		getLocationListener = listener
		Runtime:addEventListener( "location", geolocationListener )
		locationTimer = timer.performWithDelay( TIMER_TIMEOUT, locationTimerListener )
	end
end

function geolocationUtility.getSimulateLocation()
	local data = {}
	data.latitude = SIMULATOR_LATITUDE
	data.longitude = SIMULATOR_LONGITUDE
	return data
end

function geolocationUtility.cancelGetLocation()
	cancelGeoTimer()
	Runtime:removeEventListener( "location", geolocationListener )
	isGettingLocation = false
end

function geolocationUtility.distance(point1, point2)
	if ((point1.latitude == nil) or (point1.latitude == "")) then
		return -1
	end
	if ((point1.longitude == nil) or (point1.longitude == "")) then
		return -1
	end
	if ((point2.latitude == nil) or (point2.latitude == "")) then
		return -1
	end
	if ((point2.longitude == nil) or (point2.longitude == "")) then
		return -1
	end
	local deltaLatitude = math.sin(RADIAN * (point1.latitude - point2.latitude) /2)
	local deltaLongitude = math.sin(RADIAN * (point1.longitude - point2.longitude) / 2)
	
	local circleDistance = 2 * math.asin(math.min(1, math.sqrt(deltaLatitude * deltaLatitude +
	   math.cos(RADIAN * point1.latitude) * math.cos(RADIAN * point2.latitude) * deltaLongitude * deltaLongitude)))
	return math.abs(EARTH_RADIUS * circleDistance)
end

function geolocationUtility.getCountryByCurrentLocation(listener)
	if (type(listener) ~= "function") then
		listener = nil
	end

	local function getCountrylistener(event)
		if (event.isError) then
			if (listener) then
				listener({isNetworkError = true})
			end
		else
			local isAPIError = true
			local response = json.decode(event.response)
			if ((type(response) == "table") and (response.status == "OK")) then
				if (type(response.results) == "table") then
					local firstResult = response.results[1]
					if ((type(firstResult) == "table") and (type(firstResult.address_components) == "table")) then
						for i = 1, #firstResult.address_components do
							local types = firstResult.address_components[i].types
							if (type(types) == "table") then
								for j = 1, #types do
									if (types[j] == "country") then
										isAPIError = false
										if (listener) then
											listener({country = firstResult.address_components[i].short_name})
										end
									end
								end
							end
						end
					end
				end
			end
			if (isAPIError) then
				if (listener) then
					listener({isAPIError = true})
				end
			end
		end
	end

	local function getGeoDataListener(event)
		if (event.isGeoTimeout) then
			if (listener) then
				listener({isGPSError = true})
			end
		else
			local url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=" .. tostring(event.latitude) .. "," .. tostring(event.longitude)
			local method = "GET"
			network.request(url, method, getCountrylistener)
		end
	end

	geolocationUtility.getLocation(getGeoDataListener)
end

return geolocationUtility