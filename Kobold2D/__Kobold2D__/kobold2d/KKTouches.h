/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"
#import "cocos2d-extensions.h"
#import "ccMoreMacros.h"
#import "KKTouch.h"

@class KKTouch;

@interface KKTouches : NSObject
{
@private
	CCArray* touchesPool;
	CCArray* touches;
	CCArray* touchesToBeRemoved;
	CCArray* uiTouches;
	
	BOOL touchesNeedUpdate;
}

@property (nonatomic, readonly) CCArray* touches;

#if KK_PLATFORM_IOS
// Internal use only
-(void) addTouches:(NSSet*)touchesSet;
-(void) updateMovedTouches:(NSSet*)touchesSet;
-(void) removeTouch:(KKTouch*)touch invalidate:(BOOL)invalidate;
-(void) removeTouches:(NSSet*)touchesSet;
-(void) removeAllTouches;
#endif

-(void) update:(ccTime)delta;

@end
