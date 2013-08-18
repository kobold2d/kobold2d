/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import <Foundation/Foundation.h>

/** @file kobold2d_version.h */

/** Returns the Kobold2D Version string. */
NSString* kobold2dVersion();

/** Returns whether the device has a 16:9 widescreen display AND widescreen is enabled. For example, iPhone 5 is widescreen
 but unless your project includes the Default-568h@2x.png an iPhone 5 will report only 480x320 point screen size.
 
 This function returns YES only if the device HAS a widescreen display AND it is enabled by including the Default-568h@2x.png in your project. */
BOOL isWidescreenEnabled();

/** Returns the major Mac OS X version. For example, for Mac OS X 10.7.2 it will return 10. Returns 0 on iOS. */
int macOSVersionMajor();
/** Returns the minor Mac OS X version. For example, for Mac OS X 10.7.2 it will return 7. Returns 0 on iOS. */
int macOSVersionMinor();
/** Returns the bugfix Mac OS X version. For example, for Mac OS X 10.7.2 it will return 2. Returns 0 on iOS. */
int macOSVersionBugFix();
