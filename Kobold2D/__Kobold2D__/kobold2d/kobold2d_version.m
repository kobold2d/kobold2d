/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "kobold2d_version.h"
#import "ccMoreMacros.h"

/** this string is output to log on startup and used by the kkprep tool that creates the installer package */
static NSString* version = @"Kobold2D™ v2.1.0";

/** Returns the Kobold2D Version string. */
NSString* kobold2dVersion()
{	
	return version;
}

BOOL isWidescreenEnabled()
{
#if KK_PLATFORM_IOS
	return (BOOL)(fabs((double)[UIScreen mainScreen].bounds.size.height - (double)568) < DBL_EPSILON);
#else
	return NO;
#endif
}

int macOSVersionMajor()
{
#if KK_PLATFORM_MAC
	SInt32 versionMajor = 0;
	Gestalt(gestaltSystemVersionMajor, &versionMajor);
	return versionMajor;
#else
	return 0;
#endif
}

int macOSVersionMinor()
{
#if KK_PLATFORM_MAC
	SInt32 versionMinor = 0;
	Gestalt(gestaltSystemVersionMinor, &versionMinor);
	return versionMinor;
#else
	return 0;
#endif
}

int macOSVersionBugFix()
{
#if KK_PLATFORM_MAC
	SInt32 versionBugFix = 0;
	Gestalt(gestaltSystemVersionBugFix, &versionBugFix);
	return versionBugFix;
#else
	return 0;
#endif
}
