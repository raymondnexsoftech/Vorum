

local heightRatio = display.pixelHeight/display.pixelWidth

application = 
{
	content = 
	{
		width = 640,
		height = 640 * heightRatio,
		fps = 60,
                antialias = true,
                xalign = "center",
                yalign = "center",
    },

	notification = 
	{
		iphone =
		{
			types = { "badge", "sound", "alert", },
		},
		google =
		{
			projectNumber = "1046322746315",
		},
	},
}

--[[
 local targetDevice = ( system.getInfo( "model" ) ) 
 local isiOSDevice = string.find(system.getInfo( "model" ), "iP") == 1
 local isTalliOSDevice = ( isiOSDevice == true ) and ( display.pixelHeight >=2048 )
 local heightRatio = display.pixelHeight/display.pixelWidth

 if (isiOSDevice == true) then
 	if (isTalliOSDevice == true) then
 		application = 
 		{
 			content = 
 			{
 				width = 640 ,
 				height = 640 * heightRatio *1.2 ,
				
 				fps = 60,
 		                antialias = true,
 		                xalign = "center",
 		                yalign = "center",
 		    },
 		}
 	else
 		application = 
 		{
 			content = 
 			{
 				width = 640,
 				height = 640 * heightRatio,
 				scale = "letterbox",
 				fps = 60,
 		                antialias = true,
 		                xalign = "center",
 		                yalign = "center",
 				imageSuffix = 
 		        {
 		            ["@2x"] = 2,
 		        },
 		    },
 		}
 	end
 else
 	application = 
 	{
 		content = 
 		{
 			width = 320,
 			height = 320*heightRatio,
 			scale = "letterbox",
 			fps = 60,
 	                antialias = true,
 	                xalign = "center",
 	                yalign = "center",
 			imageSuffix = 
 	        {
 	            ["@2x"] = 2,
 	        },
 	    },
 	}
 end
 --]]