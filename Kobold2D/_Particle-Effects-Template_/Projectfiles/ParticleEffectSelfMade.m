/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "ParticleEffectSelfMade.h"


@implementation ParticleEffectSelfMade

-(id) init
{
	return [self initWithTotalParticles:250];
}

-(id) initWithTotalParticles:(NSUInteger)numParticles
{
	if ((self = [super initWithTotalParticles:numParticles]))
	{
		// DURATION
		// most effects use infinite duration
		self.duration = kCCParticleDurationInfinity;
		// for timed effects use a number in seconds how long particles should be emitted
		//self.duration = 2.0f;
		// If the particle system runs for a fixed time, this will remove the particle system node from
		// its parent once all particles have died. Has no effect for infinite particle systems.
		self.autoRemoveOnFinish = YES;

		// MODE
		// particles are affected by gravity
		self.emitterMode = kCCParticleModeGravity;
		// particles move in a circle instead
		//self.emitterMode = kCCParticleModeRadius;
		
		// some properties must only be used with a specific emitterMode!
		if (self.emitterMode == kCCParticleModeGravity)
		{
			// sourcePosition determines the offset where particles appear. The actual
			// center of gravity is the node's position.
			self.sourcePosition = CGPointMake(-15, 0);
			// gravity determines the particle's speed in the x and y directions
			self.gravity = CGPointMake(-50, -90);
			// radial acceleration affects how fast particles move depending on their distance to the emitter
			// positive radialAccel means particles speed up as they move away, negative means they slow down
			self.radialAccel = -90;
			self.radialAccelVar = 20;
			// tangential acceleration lets particles rotate around the emitter position, 
			// and they speed up as they rotate around (slingshot effect)
			self.tangentialAccel = 120;
			self.tangentialAccelVar = 10;
			// speed is of course how fast particles move in general
			self.speed = 15;
			self.speedVar = 4;
		}
		else if (self.emitterMode == kCCParticleModeRadius)
		{
			// the distance from the emitter position that particles will be spawned and sent out
			// in a radial (circular) fashion
			self.startRadius = 100;
			self.startRadiusVar = 0;
			// the end radius the particles move towards, if less than startRadius particles will move
			// inwards, if greater than startRadius particles will move outward
			// you can use the keyword kCCParticleStartRadiusEqualToEndRadius to create a perfectly circular rotation
			self.endRadius = 10;
			self.endRadiusVar = 0;
			// how fast the particles rotate around
			self.rotatePerSecond = 180;
			self.rotatePerSecondVar = 0;
		}

		// EMITTER POSITION
		// emitter position is at the center of the node (default)
		// this is where new particles will appear
		self.position = CGPointZero;
		self.posVar = CGPointZero;
		// The positionType determines if existing particles should be repositioned when the node is moving
		// (kCCPositionTypeGrouped) or if the particles should remain where they are (kCCPositionTypeFree).
		self.positionType = kCCPositionTypeFree;
		
		// PARTICLE SIZE
		// size of individual particles in pixels
		self.startSize = 40.0f;
		self.startSizeVar = 0.0f;
		self.endSize = kCCParticleStartSizeEqualToEndSize;
		self.endSizeVar = 0;

		// ANGLE (DIRECTION)
		// the direction in which particles are emitted, 0 means upwards
		self.angle = 0;
		self.angleVar = 0;
		
		// PARTICLE LIFETIME
		// how long each individual particle will "life" (eg. stay on screen)
		self.life = 5.0f;
		self.lifeVar = 0.0f;
		
		// PARTICLE EMISSION RATE
		// how many particles per second are created (emitted)
		// particle creation stops if self.particleCount >= self.totalParticles
		// you can use this to create short burst effects with pauses between each burst
		self.emissionRate = 30;
		// normally set with initWithTotalParticles but you can change that number
		self.totalParticles = 250;

		// PARTICLE COLOR
		// A valid startColor must be set! Otherwise the particles may be invisible. The other colors are optional.
		// These colors determine the color of the particle at the start and the end of its lifetime.
		_startColor.r = 1.0f;
		_startColor.g = 0.25f;
		_startColor.b = 0.12f;
		_startColor.a = 1.0f;

		_startColorVar.r = 0.0f;
		_startColorVar.g = 0.0f;
		_startColorVar.b = 0.0f;
		_startColorVar.a = 0.0f;
		
		_endColor.r = 0.0f;
		_endColor.g = 0.0f;
		_endColor.b = 0.0f;
		_endColor.a = 1.0f;
		
		_endColorVar.r = 0.0f;
		_endColorVar.g = 0.0f;
		_endColorVar.b = 1.0f;
		_endColorVar.a = 0.0f;
		
		// BLEND FUNC
		// blend func influences how transparent colors are calculated
		// the first parameter is for the source, the second for the target
		// available blend func parameters are:
		// GL_ZERO   GL_ONE   GL_SRC_COLOR   GL_ONE_MINUS_SRC_COLOR   GL_SRC_ALPHA 
		// GL_ONE_MINUS_SRC_ALPHA   GL_DST_ALPHA   GL_ONE_MINUS_DST_ALPHA
		self.blendFunc = (ccBlendFunc){GL_SRC_ALPHA, GL_DST_ALPHA};
		// shortcut to set the blend func to: GL_SRC_ALPHA, GL_ONE
		//self.blendAdditive = YES;
		
		// PARTICLE TEXTURE
		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];
	}
	
	return self;
}

@end
