--[[
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
--]]


--[[
		* Need help with the KKStartupConfig settings?
		* ------ http://www.kobold2d.com/x/ygMO ------
--]]


local config =
{
	KKStartupConfig = 
	{
		-- load first scene from a class with this name, or from a Lua script with this name with .lua appended
		FirstSceneClassName = "HelloWorldLayer",

		MaxFrameRate = 60,
		DisplayFPS = YES,

		EnableUserInteraction = YES,
		EnableMultiTouch = NO,

		-- Render settings
		DefaultTexturePixelFormat = TexturePixelFormat.RGBA8888,
		GLViewColorFormat = GLViewColorFormat.RGBA8888,	-- alpha channel is needed to display views in the background
		GLViewDepthFormat = GLViewDepthFormat.DepthNone,
		GLViewMultiSampling = NO,
		GLViewNumberOfSamples = 0,

		Enable2DProjection = NO,
		EnableRetinaDisplaySupport = YES,
		EnableGLViewNodeHitTesting = YES,	-- hit testing checks each node if a touch/click was on the node, 
											-- otherwise touch/click is passed through to background view(s)
		EnableStatusBar = YES,

		-- Orientation & Autorotation
		-- Kobold2D uses the supported orientations from the Target's Summary pane: http://cl.ly/2l132Z2f463H2O3r0M1O
		-- (same as Info.plist key UISupportedInterfaceOrientations aka "Supported interface orientations")
	
		-- iAd setup
		EnableAdBanner = NO,
		PlaceBannerOnBottom = YES,
		LoadOnlyPortraitBanners = NO,
		LoadOnlyLandscapeBanners = NO,
		AdProviders = "iAd, AdMob",	-- comma seperated list -> "iAd, AdMob" means: use iAd if available, otherwise AdMob
		AdMobRefreshRate = 15,
		AdMobFirstAdDelay = 5,
		AdMobPublisherID = "YOUR_ADMOB_PUBLISHER_ID", -- how to get an AdMob Publisher ID: http://developer.admob.com/wiki/PublisherSetup
		AdMobTestMode = YES,

		-- Mac OS specific settings
		AutoScale = NO,
		AcceptsMouseMovedEvents = NO,
		EnableFullScreen = NO,
	},
}

return config
