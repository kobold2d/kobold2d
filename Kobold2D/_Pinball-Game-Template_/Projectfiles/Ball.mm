/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "Ball.h"
#import "Constants.h"
#import "Helper.h"
#import "PinballTable.h"

#import "SimpleAudioEngine.h"

@interface Ball (PrivateMethods)
-(void) createBallInWorld:(b2World*)world;
-(void) setBallStartPosition;
@end


@implementation Ball

-(id) initWithWorld:(b2World*)world
{
	if ((self = [super initWithShape:@"ball" inWord:world]))
	{
        // set the parameters
        body->SetType(b2_dynamicBody);
        body->SetAngularDamping(0.9f);

        // enable continuous collision detection
        body->SetBullet(true);

        // set random starting point
        [self setBallStartPosition];

#if KK_PLATFORM_IOS
		[[CCDirector sharedDirector].touchDispatcher addTargetedDelegate:self priority:0 swallowsTouches:NO];
#elif KK_PLATFORM_MAC
		[[CCDirector sharedDirector].eventDispatcher addMouseDelegate:self priority:1];
#endif

		[self scheduleUpdate];
	}
	return self;
}

+(id) ballWithWorld:(b2World*)world
{
	id ball = [[self alloc] initWithWorld:world];
#ifndef KK_ARC_ENABLED
	[ball autorelease];
#endif // KK_ARC_ENABLED
	return ball;
}

-(void) dealloc
{
#if KK_PLATFORM_IOS
	[[CCDirector sharedDirector].touchDispatcher removeDelegate:self];
#elif KK_PLATFORM_MAC
	[[CCDirector sharedDirector].eventDispatcher removeMouseDelegate:self];
#endif
	
#ifndef KK_ARC_ENABLED
	[super dealloc];
#endif // KK_ARC_ENABLED
}

-(void) setBallStartPosition
{
    // set the ball's position
    float randomOffset = CCRANDOM_0_1() * 10.0f - 5.0f;
    CGPoint startPos = CGPointMake(305 + randomOffset, 80);
    
    body->SetTransform([Helper toMeters:startPos], 0.0f);    
    body->SetLinearVelocity(b2Vec2_zero);
    body->SetAngularVelocity(0.0f);
}

-(void) applyForceTowardsFinger
{
	b2Vec2 bodyPos = body->GetWorldCenter();
	b2Vec2 fingerPos = [Helper toMeters:fingerLocation];
	
	b2Vec2 bodyToFingerDirection = fingerPos - bodyPos;
	b2Vec2 force = 10.0f * bodyToFingerDirection;
	
	// "Real" gravity falls off by the square over distance. Feel free to try it this way:
	/*
	float distance = bodyToFingerDirection.Length();
	bodyToFingerDirection.Normalize();
	float distanceSquared = distance * distance;
	force = ((1.0f / distanceSquared) * 20.0f) * bodyToFingerDirection;
	*/
	
	body->ApplyForce(force, body->GetWorldCenter());
}

-(void) update:(ccTime)delta
{
	if (moveToFinger == YES)
	{
		// disabled by default because it interferes with flipper controls
		//[self applyForceTowardsFinger];
	}
	
	if (self.position.y < -(self.contentSize.height * 10))
	{
		// restart at a random position
		[self setBallStartPosition];
	}

    // limit speed of the ball
    const float32 maxSpeed = 6.0f;
    b2Vec2 velocity = body->GetLinearVelocity();
    float32 speed = velocity.Length();
    if (speed > maxSpeed)
    {
		velocity.Normalize();
		body->SetLinearVelocity(maxSpeed * velocity);
		//CCLOG(@"reset speed %f to %f", speed, (maxSpeed * velocity).Length());
    }

    // reset rotation of the ball to keep
    // highlight and shadow in the same place
    body->SetTransform(body->GetWorldCenter(), 0.0f);
}


#if KK_PLATFORM_IOS

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	moveToFinger = YES;
	fingerLocation = [Helper locationFromTouch:touch];
	return YES;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	fingerLocation = [Helper locationFromTouch:touch];
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	moveToFinger = NO;
}

#elif KK_PLATFORM_MAC

-(BOOL) ccMouseDown:(NSEvent*)event
{
	moveToFinger = YES;
	fingerLocation = [[CCDirector sharedDirector] convertEventToGL:event];
	return NO;
}

-(BOOL) ccMouseDragged:(NSEvent*)event
{
	fingerLocation = [[CCDirector sharedDirector] convertEventToGL:event];
	return NO;
}

-(BOOL) ccMouseUp:(NSEvent*)event
{
	moveToFinger = NO;
	return NO;
}

#endif


-(void) playSound
{
	float pitch = 0.9f + CCRANDOM_0_1() * 0.2f;
	float gain = 1.0f + CCRANDOM_0_1() * 0.3f;
	[[SimpleAudioEngine sharedEngine] playEffect:@"bumper.wav" pitch:pitch pan:0.0f gain:gain];

}

-(void) endContactWithBumper:(Contact*)contact
{
	[self playSound];
}

-(void) endContactWithPlunger:(Contact*)contact
{
	[self playSound];
}

@end
