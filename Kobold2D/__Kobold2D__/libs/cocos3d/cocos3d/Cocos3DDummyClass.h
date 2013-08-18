/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2012 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import <Foundation/Foundation.h>


/**
 Currently cocos3d is incompatible with cocos2d v1.1 and 2.0 and therefore unavailable in this version of Kobold2D.
 Whether it will come back depends on future updates as well as user demand. Only a small fraction of cocos2d devs
 are using cocos3d, probably because there are far better and more popular alternatives for building 3D games (Unity, Unreal, ...).
 
 This dummy class only exists to be able to be able to link the cocos3d static library to avoid removing cocos3d entirely for the time being.
 */
@interface Cocos3DDummyClass : NSObject

@end
