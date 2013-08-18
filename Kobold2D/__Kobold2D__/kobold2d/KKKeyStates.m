/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "KKKeyStates.h"

@implementation KKKeyState

-(id) init
{
	if ((self = [super init]))
	{
		isInvalid = YES;
	}
	return self;
}

-(void) invalidate
{
	keyCode = 0;
	timestamp = 0;
	isRepeat = NO;
	isInvalid = YES;
}

-(void) validate
{
	isInvalid = NO;
}

@end



@implementation KKKeyStates

// maximum number of keys that can be concurrently held down, including modifiers
const NSUInteger kKeyStatePoolSize = 16;

- (id)init
{
    if ((self = [super init])) 
	{
		keyStatePool = [[CCArray alloc] initWithCapacity:kKeyStatePoolSize];
		for (NSUInteger i = 0; i < kKeyStatePoolSize; i++)
		{
			KKKeyState* keyState = [[[KKKeyState alloc] init] autorelease];
			[keyStatePool addObject:keyState];
		}
		
		keysDown = [[CCArray alloc] initWithCapacity:kKeyStatePoolSize];
		keysRemovedThisFrame = [[CCArray alloc] initWithCapacity:kKeyStatePoolSize];
    }
    
    return self;
}

-(void) dealloc
{
	[keysDown release];
	[keyStatePool release];
	[keysRemovedThisFrame release];
	
	[super dealloc];
}

-(void) reset
{
	KKKeyState* keyState = nil;
	CCARRAY_FOREACH(keysDown, keyState)
	{
		[keyState invalidate];
	}
	
	CCARRAY_FOREACH(keysRemovedThisFrame, keyState)
	{
		[keyState invalidate];
	}
	
	[keysDown removeAllObjects];
	[keysRemovedThisFrame removeAllObjects];
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"%@ - keys down: %u", [super description], (unsigned int)[keysDown count]];
}

-(KKKeyState*) getInactiveKeyStateFromPool
{
	KKKeyState* keyState = nil;
	
	CCARRAY_FOREACH(keyStatePool, keyState)
	{
		if (keyState && keyState->isInvalid)
		{
			return keyState;
		}
	}
	
	return nil;
}

-(void) updateKeyDownRepeatState
{
	KKKeyState* keyState = nil;
	CCARRAY_FOREACH(keysDown, keyState)
	{
		if (keyState && keyState->isRepeat == NO && keyState->timestamp < timestamp) 
		{
			//CCLOG(@"key %u now repeats ... key timestamp: %lu < timestamp now: %lu", keyState->keyCode, keyState->timestamp, timestamp);
			keyState->isRepeat = YES;
		}
	}
}

-(void) updateKeyUpRepeatState
{
	if ([keysRemovedThisFrame count] > 0)
	{
		KKKeyState* keyState = nil;
		CCARRAY_FOREACH(keysRemovedThisFrame, keyState)
		{
			[keyState invalidate];
		}
		
		[keysRemovedThisFrame removeAllObjects];
	}
}

-(void) update:(ccTime)delta
{
	timestamp++;
	[self updateKeyDownRepeatState];
	[self updateKeyUpRepeatState];
}


-(void) addKeyDown:(UInt16)keyCode
{
	// first try updating an existing key in the list
	BOOL isKeyInList = NO;
	KKKeyState* keyState = nil;
	CCARRAY_FOREACH(keysDown, keyState)
	{
		if (keyState && keyState->keyCode == keyCode) 
		{
			isKeyInList = YES;
			break;
		}
	}
	
	// if the key isn't in the list, add it
	if (isKeyInList == NO)
	{
		keyState = [self getInactiveKeyStateFromPool];
		if (keyState)
		{
			keyState->keyCode = keyCode;
			keyState->timestamp = timestamp;
			[keyState validate];
			[keysDown addObject:keyState];
		}
	}
}

-(void) removeKeyDown:(UInt16)keyCode
{
	KKKeyState* keyState = nil;
	CCARRAY_FOREACH(keysDown, keyState)
	{
		if (keyState && keyState->keyCode == keyCode) 
		{
			[keysRemovedThisFrame addObject:keyState];
			[keysDown removeObject:keyState];
			break;
		}
	}
}

-(BOOL) isAnyKeyDown
{
	return ([keysDown count] > 0);
}

-(BOOL) isAnyKeyDownThisFrame
{
	BOOL isKeyDown = NO;
	
	KKKeyState* keyState = nil;
	CCARRAY_FOREACH(keysDown, keyState)
	{
		if (keyState && keyState->isRepeat == NO)
		{
			isKeyDown = YES;
			break;
		}
	}
	
	return isKeyDown;
}

-(BOOL) isAnyKeyUpThisFrame
{
	return ([keysRemovedThisFrame count] > 0);
}

-(BOOL) isKeyDown:(UInt16)keyCode onlyThisFrame:(BOOL)onlyThisFrame
{
	BOOL isKeyDown = NO;
	
	KKKeyState* keyState = nil;
	CCARRAY_FOREACH(keysDown, keyState)
	{
		if (keyState && keyState->keyCode == keyCode)
		{
			isKeyDown = (onlyThisFrame) ? (keyState->isRepeat == NO) : YES;
			break;
		}
	}
	
	return isKeyDown;
}

-(BOOL) isKeyUp:(UInt16)keyCode onlyThisFrame:(BOOL)onlyThisFrame
{
	BOOL isKeyUp = NO;
	KKKeyState* keyState = nil;
	
	if (onlyThisFrame)
	{
		CCARRAY_FOREACH(keysRemovedThisFrame, keyState)
		{
			if (keyState && keyState->keyCode == keyCode)
			{
				isKeyUp = YES;
				break;
			}
		}
	}
	else
	{
		isKeyUp = YES;
		CCARRAY_FOREACH(keysDown, keyState)
		{
			if (keyState && keyState->keyCode == keyCode)
			{
				isKeyUp = NO;
				break;
			}
		}
	}
	
	return isKeyUp;
}

@end
