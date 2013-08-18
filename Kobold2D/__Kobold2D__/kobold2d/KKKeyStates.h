/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"
#import "cocos2d-extensions.h"

@interface KKKeyState : NSObject
{
@public // public for faster access
	NSUInteger timestamp;	// frame the key was first pressed down
	UInt16 keyCode;			// keyCode of the key, this can be a virtual keyCode, a mouse button or gamepad enum value
	BOOL isRepeat;			// the key is repeating beginning with frame #2
	BOOL isInvalid;			// this keyState is invalid and can be re-used (flag for state pool)
}

@end


// internal class that keeps track of key states (keyboard, mouse or gamepad)
@interface KKKeyStates : NSObject
{
@private
	// buffer holding all KKKeyState instances to reduce allocations
	CCArray* keyStatePool;
	CCArray* keysDown;
	CCArray* keysRemovedThisFrame;
	
	NSUInteger timestamp;
	
}

-(void) addKeyDown:(UInt16)keyCode;
-(void) removeKeyDown:(UInt16)keyCode;

-(void) reset;

-(BOOL) isAnyKeyDown;
-(BOOL) isAnyKeyDownThisFrame;
-(BOOL) isAnyKeyUpThisFrame;

-(BOOL) isKeyDown:(UInt16)keyCode onlyThisFrame:(BOOL)onlyThisFrame;
-(BOOL) isKeyUp:(UInt16)keyCode onlyThisFrame:(BOOL)onlyThisFrame;

-(void) update:(ccTime)delta;

@end
