/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

/** @file KKMain.h
 Contains the common and platform-specific startup code. Launches the Lua interpreter via Wax. */

#ifndef Kobold2D_Libraries_KKMain_h
#define Kobold2D_Libraries_KKMain_h


#import "cocos2d.h"
#import "cocos2d-extensions.h"
#import "kkLuaInitScript.h"


typedef struct
{
	__unsafe_unretained	NSString* appDelegateClassName;
} KKMainParameters;

void initMainParameters(KKMainParameters* parameters, KKMainParameters* userParameters);

/** KKMain handles the cross-platform startup of Kobold2D projects as well as the initialization of Wax and Lua.
 Kobold2D projects call this method in their main(..) method. The parameters are meant for future expansion in
 case additional per-app startup parameters need to be passed in which must be set before the AppDelegate
 takes over. */
int KKMain(int argc, char* argv[], KKMainParameters* userParameters);

#endif // Kobold2D_Libraries_KKMain_h
