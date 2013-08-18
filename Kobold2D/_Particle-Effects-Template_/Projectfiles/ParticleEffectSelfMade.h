/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// Depending on the targeted device the ParticleEffectSelfMade class will either derive
// from CCPointParticleSystem or CCQuadParticleSystem (preferred for iOS 3rd and 4th Generation)
@interface ParticleEffectSelfMade : CCParticleSystemQuad 
{

}

@end
