/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"
#import "CCDirectorExtensions.h"


/** @file ccMoreTypes.h - Adding some missing type declarations and helpers that are not in ccTypes.h */


/** Quick and dirty rectangle drawing. Should be improved to render a triangle strip instead. */
static inline void kkDrawRect(CGRect rect);
static inline void kkDrawRect(CGRect rect)
{
	CGPoint pt1 = rect.origin;
	CGPoint pt2 = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y);
	CGPoint pt3 = CGPointMake(pt2.x, rect.origin.y + rect.size.height);
	CGPoint pt4 = CGPointMake(rect.origin.x, pt3.y);
	ccDrawLine(pt1, pt2);
	ccDrawLine(pt2, pt3);
	ccDrawLine(pt3, pt4);
	ccDrawLine(pt4, pt1);
}

//! Cyan Color (0,255,255)
static const ccColor3B ccCYAN = {0,255,255};

/** creates and returns a ccBlendFunc struct */
static inline ccBlendFunc ccBlendFuncMake(GLenum src, GLenum dst)
{
	ccBlendFunc blendFunc = {src, dst};
	return blendFunc;
}

/** Converts a point that's relative to the current screen size to a regular point. Typical value range is from 0.0f to 1.0f to create a point
 within the screen boundary. A relative point of 1, 1 equals the current screen size. Negative values and values > 1.0f are allowed 
 if you want to create a point that lies outside of the screen boundary. Relative points are useful to scale your user interface or game
 depending on the screen resolution. This is most useful when writing games that run on both iPad and iPhone/iPod. */
static inline CGPoint CGRelativePointToPoint(CGPoint relativeToScreenSize)
{
	CGSize screenSize = [[CCDirector sharedDirector] screenSize];
	return CGPointMake(screenSize.width * relativeToScreenSize.x, screenSize.height * relativeToScreenSize.y);
}

/** Like CGRelativePointToPoint but returns a pixel coordinates instead of point coordinates. */
static inline CGPoint CGRelativePointToPointInPixels(CGPoint relativeToScreenSize)
{
	CGSize screenSizeInPixels = [[CCDirector sharedDirector] screenSizeInPixels];
	return CGPointMake(screenSizeInPixels.width * relativeToScreenSize.x, screenSizeInPixels.height * relativeToScreenSize.y);
}

/** Converts a regular point to one that's relative to the current screen size. */
static inline CGPoint CGPointToRelativePoint(CGPoint point)
{
	CGSize screenSize = [[CCDirector sharedDirector] screenSize];
	return CGPointMake(point.x / screenSize.width, point.y / screenSize.height);
}

/** Like CGPointToRelativePoint but returns a point that's relative to the current screen size in pixels. */
static inline CGPoint CGPointToRelativePointInPixels(CGPoint point)
{
	CGSize screenSizeInPixels = [[CCDirector sharedDirector] screenSizeInPixels];
	return CGPointMake(point.x / screenSizeInPixels.width, point.y / screenSizeInPixels.height);
}
