/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "Plunger.h"

@interface Plunger (PrivateMethods)
-(void) attachPlunger;
@end


@implementation Plunger

-(id) initWithWorld:(b2World*)world
{
	if ((self = [super initWithShape:@"plunger" inWord:world]))
	{
		CGPoint plungerPos = CGPointMake(307, -32);
		
		body->SetTransform([Helper toMeters:plungerPos], 0);
        body->SetType(b2_dynamicBody);

		[self attachPlunger];
	}
	return self;
}

+(id) plungerWithWorld:(b2World*)world
{
	id plunger = [[self alloc] initWithWorld:world];
#ifndef KK_ARC_ENABLED
	[plunger autorelease];
#endif // KK_ARC_ENABLED
	return plunger;
}

-(void) attachPlunger
{
	// create an invisible static body to attach joint to
	b2BodyDef bodyDef;
	bodyDef.position = body->GetWorldCenter();
	b2Body* staticBody = body->GetWorld()->CreateBody(&bodyDef);
	
	// Create a prismatic joint to make plunger go up/down
	b2PrismaticJointDef jointDef;
	b2Vec2 worldAxis(0.0f, 1.0f);
	jointDef.Initialize(staticBody, body, body->GetWorldCenter(), worldAxis);
	jointDef.lowerTranslation = 0.0f;
	jointDef.upperTranslation = 0.35f;
	jointDef.enableLimit = true;
	jointDef.maxMotorForce = 80.0f;
	jointDef.motorSpeed = 40.0f;
	jointDef.enableMotor = false;
	
	joint = (b2PrismaticJoint*)body->GetWorld()->CreateJoint(&jointDef);
}
 
-(void) endPlunge:(ccTime)delta
{
    // stop the scheduling of endPlunge
	[self unschedule:_cmd];

    // stop the motor
	joint->EnableMotor(NO);
}

-(void) beginContactWithBall:(Contact*)contact
{
    // start the motor
    joint->EnableMotor(YES);

    // schedule motor to come back, unschedule in case the plunger is hit repeatedly within a short time
    [self unschedule:_cmd];
    [self schedule:@selector(endPlunge:) interval:0.5f];
}

@end
