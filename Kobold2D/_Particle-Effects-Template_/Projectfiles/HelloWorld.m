/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "HelloWorld.h"
#import "ParticleEffectSelfMade.h"

@interface HelloWorld (PrivateMethods)
-(void) runEffect;
@end

@implementation HelloWorld

-(id) init
{
	if ((self = [super init]))
	{
		CCLayerColor* layer = [CCLayerColor layerWithColor:ccc4(20, 20, 50, 255)];
		[self addChild:layer z:-1];
		
		label = [CCLabelTTF labelWithString:@"Hello Particles" fontName:@"Marker Felt" fontSize:50];
		CGSize size = [[CCDirector sharedDirector] winSize];
		label.position = CGPointMake(size.width / 2, size.height - label.contentSize.height / 2);
		[self addChild:label];
		
#if KK_PLATFORM_IOS
		self.touchEnabled = YES;
#elif KK_PLATFORM_MAC
		self.mouseEnabled = YES;
#endif
		
		[self runEffect];
	}
	return self;
}

-(void) runEffect
{
	// remove any previous particle FX
	[self removeChildByTag:1 cleanup:YES];
	
	CCParticleSystem* system;
	
	switch (particleType)
	{
			// effects designed with Particle Designer http://particledesigner.71squared.com/
		case ParticleTypeDesignedFX:
			system = [CCParticleSystemQuad particleWithFile:@"designed-fx.plist"];
			break;
		case ParticleTypeDesignedFX2:
			// uses a plist with the texture already embedded
			system = [CCParticleSystemQuad particleWithFile:@"designed-fx2.plist"];
			system.positionType = kCCPositionTypeFree;
			break;
		case ParticleTypeDesignedFX3:
			// same effect but different texture (scaled down by Particle Designer)
			system = [CCParticleSystemQuad particleWithFile:@"designed-fx3.plist"];
			system.positionType = kCCPositionTypeFree;
			break;
			
			// programmed particle effect
		case ParticleTypeSelfMade:
			system = [ParticleEffectSelfMade node];
			break;
		
			// cocos2d built-in particle effects
		case ParticleTypeExplosion:
			system = [CCParticleExplosion node];
			break;
		case ParticleTypeFire:
			system = [CCParticleFire node];
			break;
		case ParticleTypeFireworks:
			system = [CCParticleFireworks node];
			break;
		case ParticleTypeFlower:
			system = [CCParticleFlower node];
			break;
		case ParticleTypeGalaxy:
			system = [CCParticleGalaxy node];
			break;
		case ParticleTypeMeteor:
			system = [CCParticleMeteor node];
			break;
		case ParticleTypeRain:
			system = [CCParticleRain node];
			break;
		case ParticleTypeSmoke:
			system = [CCParticleSmoke node];
			break;
		case ParticleTypeSnow:
			system = [CCParticleSnow node];
			break;
		case ParticleTypeSpiral:
			system = [CCParticleSpiral node];
			break;
		case ParticleTypeSun:
			system = [CCParticleSun node];
			break;
			
		default:
			// do nothing
			break;
	}

	CGSize winSize = [[CCDirector sharedDirector] winSize];
	system.position = CGPointMake(winSize.width / 2, winSize.height / 2);
	[self addChild:system z:1 tag:1];
	
	[label setString:NSStringFromClass([system class])];
}

-(void) setNextParticleType
{
	particleType++;
	if (particleType == ParticleTypes_MAX)
	{
		particleType = 0;
	}
}

-(void) trySwitchToNextEffect
{
	// only switch to next effect if mouse didn't move
	if (touchesMoved == NO)
	{
		[self setNextParticleType];
		[self runEffect];
	}
}

#if KK_PLATFORM_IOS
-(CGPoint) locationFromTouches:(NSSet *)touches
{
	UITouch *touch = [touches anyObject];
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	touchesMoved = NO;
}

-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	touchesMoved = YES;
	CCNode* node = [self getChildByTag:1];
	node.position = [self locationFromTouches:touches];
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self trySwitchToNextEffect];
}

#elif KK_PLATFORM_MAC
-(BOOL) ccMouseMoved:(NSEvent*)event
{
	CCNode* node = [self getChildByTag:1];
	node.position = [[CCDirector sharedDirector] convertEventToGL:event];
	return YES;
}

-(BOOL) ccMouseUp:(NSEvent*)event
{
	[self trySwitchToNextEffect];
	return YES;
}

#endif

@end
