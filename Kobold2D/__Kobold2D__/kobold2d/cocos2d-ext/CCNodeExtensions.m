/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "CCNodeExtensions.h"
#import "ccMoreTypes.h"

@implementation CCNode (KoboldExtensions)

-(BOOL) containsPoint:(CGPoint)point
{
	CGRect bbox = CGRectMake(0, 0, _contentSize.width, _contentSize.height);
	CGPoint locationInNodeSpace = [self convertToNodeSpace:point];
	return CGRectContainsPoint(bbox, locationInNodeSpace);
}

#if KK_PLATFORM_IOS
-(BOOL) containsTouch:(UITouch*)touch
{
	CCDirector* director = [CCDirector sharedDirector];
	CGPoint locationGL = [director convertToGL:[touch locationInView:director.view]];
	return [self containsPoint:locationGL];
}
#endif

-(BOOL) intersectsNode:(CCNode*)other
{
	CGRect bbox1 = [self boundingBox];
	CGRect bbox2 = [other boundingBox];
	return CGRectIntersectsRect(bbox1, bbox2);
}

+(id) nodeWithScene
{
	CCScene* scene = [CCScene node];
	[scene addChild:[self node]];
	return scene;
}

-(CGPoint) boundingBoxCenter
{
	CGRect bbox = [self boundingBox];
	return CGPointMake(bbox.size.width * 0.5f + bbox.origin.x, bbox.size.height * 0.5f + bbox.origin.y);
}

-(void) transferToNode:(CCNode*)targetNode
{
	NSAssert(self.parent != nil, @"self hasn't been added as child. Use addChild in this case, transferToNode is only for reassigning child nodes to another node");
	CCNode* selfNode = [self retain];
	[self removeFromParentAndCleanup:NO];
	[targetNode addChild:selfNode z:selfNode.zOrder tag:selfNode.tag];
	[selfNode release];
}

-(CGSize) size
{
	return CGSizeZero;
}

-(void) setSize:(CGSize)size
{
	if ([self isKindOfClass:[CCLayerColor class]])
	{
		CCLayerColor* layer = (CCLayerColor*)self;
		[layer changeWidth:size.width height:size.height];
	}
}

-(void) removeChildrenInArray:(id<NSFastEnumeration>)childArray cleanup:(BOOL)cleanup
{
	for (CCNode* node in childArray)
	{
		NSAssert1([node isKindOfClass:[CCNode class]], @"can't remove %@ because it's not a CCNode object", node);
		[self removeChild:node cleanup:cleanup];
	}
}

-(void) setPositionRelativeToParentPosition:(CGPoint)pos
{
    CGPoint parentAP = _parent.anchorPoint;
    CGSize parentCS = _parent.contentSize;
    self.position = ccp(parentCS.width * parentAP.x + pos.x,
						parentCS.height * parentAP.y + pos.y);
}

@end
