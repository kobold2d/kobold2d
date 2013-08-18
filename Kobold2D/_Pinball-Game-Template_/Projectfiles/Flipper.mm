/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "Flipper.h"

@interface Flipper (PrivateMethods)
-(void) attachFlipperAt:(b2Vec2)pos;
@end


@implementation Flipper

-(id) initWithWorld:(b2World*)world flipperType:(EFlipperType)flipperType
{
    NSString* name = (flipperType == kFlipperLeft) ? @"flipper-left" : @"flipper-right";
    
	if ((self = [super initWithShape:name inWord:world]))
	{
		type = flipperType;
		
        // set the position depending on the left or right side
		CGPoint flipperPos = (type == kFlipperRight) ? ccp(210,65) : ccp(90,65)	;

		// attach the flipper to a static body with a revolute joint, so it can move up/down
		[self attachFlipperAt:[Helper toMeters:flipperPos]];

#if KK_PLATFORM_IOS
		[[CCDirector sharedDirector].touchDispatcher addTargetedDelegate:self priority:0 swallowsTouches:NO];
#elif KK_PLATFORM_MAC
		[[CCDirector sharedDirector].eventDispatcher addMouseDelegate:self priority:0];
#endif
	}
	return self;
}

+(id) flipperWithWorld:(b2World*)world flipperType:(EFlipperType)flipperType
{
	id flipper = [[self alloc] initWithWorld:world flipperType:flipperType];
#ifndef KK_ARC_ENABLED
	[flipper autorelease];
#endif // KK_ARC_ENABLED
	return flipper;
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

-(void) attachFlipperAt:(b2Vec2)pos
{
    body->SetTransform(pos, 0);
    body->SetType(b2_dynamicBody);

    // the flippers move fast - in some cases
    // if the ball also moves fast it sometimes happens
    // that the flippers skip the ball
    // to avoid this we use continuous collision detection
    body->SetBullet(true);

	// create an invisible static body to attach to‘
	b2BodyDef bodyDef;
	bodyDef.position = pos;
	b2Body* staticBody = body->GetWorld()->CreateBody(&bodyDef);

    // setup joint parameters
	b2RevoluteJointDef jointDef;
	jointDef.Initialize(staticBody, body, staticBody->GetWorldCenter());
	jointDef.lowerAngle = 0.0f;
	jointDef.upperAngle = CC_DEGREES_TO_RADIANS(70);
	jointDef.enableLimit = true;
	jointDef.maxMotorTorque = 100.0f;
	jointDef.motorSpeed = -40.0f;
	jointDef.enableMotor = true;

	if (type == kFlipperRight)
	{
        // mirror speed and angle for the right flipper
		jointDef.motorSpeed *= -1;
		jointDef.lowerAngle = -jointDef.upperAngle;
		jointDef.upperAngle = 0.0f;
	}

    // create the joint
	joint = (b2RevoluteJoint*)body->GetWorld()->CreateJoint(&jointDef);
}

-(void) reverseMotor
{
	joint->SetMotorSpeed(joint->GetMotorSpeed() * -1);
}

-(bool) isTouchForMe:(CGPoint)location
{
	if ((type == kFlipperLeft) && (location.x < [Helper screenCenter].x))
	{
		return YES;
	}
	else if ((type == kFlipperRight) && (location.x > [Helper screenCenter].x))
	{
		return YES;
	}
	
	return NO;
}


#if KK_PLATFORM_IOS

-(BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent*)event
{
	BOOL touchHandled = NO;
	
	CGPoint location = [Helper locationFromTouch:touch];
	if ([self isTouchForMe:location])
	{
		touchHandled = YES;
		[self reverseMotor];
	}
	
	return touchHandled;
}

-(void) ccTouchEnded:(UITouch*)touch withEvent:(UIEvent*)event
{
	CGPoint location = [Helper locationFromTouch:touch];
	if ([self isTouchForMe:location])
	{
		[self reverseMotor];
	}
}

#elif KK_PLATFORM_MAC

-(BOOL) ccMouseDown:(NSEvent*)event
{
	// if modifier is held down trigger the right flipper
	// this is just a fallback for those with a one-button mouse
	if ([NSEvent modifierFlags] > 0)
	{
		[self ccRightMouseDown:event];
	}
	else if (type == kFlipperLeft)
	{
		[self reverseMotor];
	}
	
	return NO;
}

-(BOOL) ccMouseUp:(NSEvent*)event
{
	return [self ccMouseDown:event];
}

-(BOOL) ccRightMouseDown:(NSEvent*)event
{
	if (type == kFlipperRight)
	{
		[self reverseMotor];
	}
	
	return NO;
}

-(BOOL) ccRightMouseUp:(NSEvent*)event
{
	return [self ccRightMouseDown:event];
}

#endif

@end
