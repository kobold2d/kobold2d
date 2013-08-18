/*********************************************************************
 *	
 *	Chipmunk Sprite
 *
 *	cpSprite.h
 *
 *	Chipmunk Sprite Object
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 04/24/2009.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import "cocos2d.h"
#import "chipmunk.h"
#import "cpCCNode.h"

/*! A Cocos2d CCSprite that conforms to the cpCCNodeProtocol */
@interface cpCCSprite : CCSprite<cpCCNodeProtocol>
{
	cpCCNodeImpl *_implementation;
}
@end
