/*********************************************************************
 *	
 *	cpCCNode.h
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 02/22/2009.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import "chipmunk.h"
#import "cocos2d.h"
#import "SpaceManager.h"
#import "cpCCNodeImpl.h"

@interface cpCCNode : CCNode<cpCCNodeProtocol>
{
	cpCCNodeImpl *_implementation;
}

/*! perform a self alloc with the given shape */
+ (id) nodeWithShape:(cpShape*)shape;

/*! perform a self alloc with the given body */
+ (id) nodeWithBody:(cpBody*)body;


/*! init with the given shape */
- (id) initWithShape:(cpShape*)shape;

/*! init with the given body */
- (id) initWithBody:(cpBody*)body;

@end

