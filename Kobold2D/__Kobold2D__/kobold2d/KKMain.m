
/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#include "KKMain.h"

#import "kobold2d_version.h"
#import "KKConfig.h"
#import "KKLua.h"
#import "KKStartupConfig.h"
#import "kkLuaInitScript.h"

/*
void initMainParameters(KKMainParameters* parameters, KKMainParameters* userParameters)
{
	// set default values
	parameters->appDelegateClassName = @"AppDelegate";
	
	// override defaults if necessary
	if (userParameters != NULL)
	{
		parameters = userParameters;
	}
	
	// Sanity checks here:
	//assert(parameters->appDelegateClassName != nil && "KKMain - parameters.appDelegateClassName is nil!");
}
*/

int KKMain(int argc, char* argv[], KKMainParameters* userParameters)
{
	@autoreleasepool 
	{
		KKMainParameters parameters;
		parameters.appDelegateClassName = @"AppDelegate";
		//initMainParameters(&parameters, userParameters);
		
		// wax setup is sufficient for all intents and purposes
		lua_setup();
		
		[KKLua doString:kLuaInitScript];
		[KKLua doString:kLuaInitScriptPlatformSpecific];
		
		// This loads the config.lua file
		[KKConfig loadConfigLua];
		
		// run the app with the provided general-purpose AppDelegate which handles a lot of tedious stuff for you
#ifdef KK_PLATFORM_IOS
		int retVal = UIApplicationMain(argc, argv, nil, parameters.appDelegateClassName);
#elif KK_PLATFORM_MAC
		// Mac OS X specific startup code
		int retVal = NSApplicationMain(argc, (const char**)argv);
#endif
		
		return retVal;
	}
}
