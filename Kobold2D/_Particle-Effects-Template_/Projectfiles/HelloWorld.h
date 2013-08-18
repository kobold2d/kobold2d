/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"

typedef enum
{
	ParticleTypeDesignedFX = 0,
	ParticleTypeDesignedFX2,
	ParticleTypeDesignedFX3,

	ParticleTypeSelfMade,
	
	ParticleTypeExplosion,
	ParticleTypeFire,
	ParticleTypeFireworks,
	ParticleTypeFlower,
	ParticleTypeGalaxy,
	ParticleTypeMeteor,
	ParticleTypeRain,
	ParticleTypeSmoke,
	ParticleTypeSnow,
	ParticleTypeSpiral,
	ParticleTypeSun,

	ParticleTypes_MAX,
} ParticleTypes;

@interface HelloWorld : CCLayer
{
	CCLabelTTF* label;
	ParticleTypes particleType;
	bool touchesMoved;
}


@end
