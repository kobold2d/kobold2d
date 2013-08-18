/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim, Andreas Loew 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

//  Updated by Andreas Loew on 20.06.11:
//  * retina display
//  * framerate independency
//  * using TexturePacker http://www.texturepacker.com

#import "InputLayer.h"
#import "GameLayer.h"
#import "ShipEntity.h"

#import "SimpleAudioEngine.h"

@interface InputLayer (PrivateMethods)
-(void) addFireButton;
-(void) addJoystick;
@end

@implementation InputLayer

-(id) init
{
	if ((self = [super init]))
	{
		[self addFireButton];
		[self addJoystick];
		
		[self scheduleUpdate];
	}
	
	return self;
}

-(void) addFireButton
{
	float buttonRadius = 50;
	CGSize screenSize = [[CCDirector sharedDirector] winSize];

	fireButton = [SneakyButton button];
	fireButton.isHoldable = YES;
	
	SneakyButtonSkinnedBase* skinFireButton = [SneakyButtonSkinnedBase skinnedButton];
	skinFireButton.position = CGPointMake(screenSize.width - buttonRadius * 1.5f, buttonRadius * 1.5f);
    skinFireButton.defaultSprite = [CCSprite spriteWithSpriteFrameName:@"fire-button-idle.png"];
    skinFireButton.pressSprite = [CCSprite spriteWithSpriteFrameName:@"fire-button-pressed.png"];
	skinFireButton.button = fireButton;
	[self addChild:skinFireButton];
}

-(void) addJoystick
{
	float stickRadius = 50;

	joystick = [SneakyJoystick joystickWithRect:CGRectMake(0, 0, stickRadius, stickRadius)];
	joystick.autoCenter = YES;
	
	// Now with fewer directions
	joystick.isDPad = YES;
	joystick.numberOfDirections = 8;
	
	SneakyJoystickSkinnedBase* skinStick = [SneakyJoystickSkinnedBase skinnedJoystick];
	skinStick.position = CGPointMake(stickRadius * 1.5f, stickRadius * 1.5f);
    skinStick.backgroundSprite = [CCSprite spriteWithSpriteFrameName:@"joystick-back.png"];
	skinStick.thumbSprite = [CCSprite spriteWithSpriteFrameName:@"joystick-stick.png"];
	skinStick.joystick = joystick;
	[self addChild:skinStick];
}

-(void) update:(ccTime)delta
{
	totalTime += delta;

	// Continuous fire
	if (fireButton.active && totalTime > nextShotTime)
	{
		nextShotTime = totalTime + 0.3f;

		GameLayer* game = [GameLayer sharedGameLayer];
		ShipEntity* ship = [game defaultShip];
		BulletCache* bulletCache = [game bulletCache];

		// Set the position, velocity and spriteframe before shooting
		CGPoint shotPos = CGPointMake(ship.position.x + 45, ship.position.y - 19);
        
		float spread = (CCRANDOM_0_1() - 0.5f) * 0.5f;
		CGPoint velocity = CGPointMake(200, spread * 50);
		[bulletCache shootBulletFrom:shotPos velocity:velocity frameName:@"bullet.png" isPlayerBullet:YES];
		
		float pitch = CCRANDOM_0_1() * 0.2f + 0.9f;
		[[SimpleAudioEngine sharedEngine] playEffect:@"shoot1.wav" pitch:pitch pan:0.0f gain:1.0f];
	}
	
	// Allow faster shooting by quickly tapping the fire button.
	if (fireButton.active == NO)
	{
		nextShotTime = 0;
	}
	
	// Moving the ship with the thumbstick.
	GameLayer* game = [GameLayer sharedGameLayer];
	ShipEntity* ship = [game defaultShip];
	
	CGPoint velocity = ccpMult(joystick.velocity, 7000 * delta);
	if (velocity.x != 0 && velocity.y != 0)
	{
		ship.position = CGPointMake(ship.position.x + velocity.x * delta, ship.position.y + velocity.y * delta);
	}
}

@end
