/*********************************************************************
 *	
 *	Chipmunk Sprite
 *
 *	cpSprite.m
 *
 *	Chipmunk Sprite Object
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 04/24/2009.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import "cpCCSprite.h"


@implementation cpCCSprite

#if (COCOS2D_VERSION < 0x00020000)
-(id) init
{
    [super init];
    
    _implementation = [[cpCCNodeImpl alloc] initWithNode:self];
    
    return self;
}

#else

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect rotated:(BOOL)rotated
{
    if (self = [super initWithTexture:texture rect:rect rotated:rotated]) {
        
        _implementation = [[cpCCNodeImpl alloc] initWithNode:self];
    }
    
    return self;
}
#endif


#define RENDER_IN_SUBPIXEL

-(void) draw
{
#if (COCOS2D_VERSION < 0x00020000)
	cpShape *shape = _implementation.shape;
	if (shape && shape->CP_PRIVATE(klass)->type == CP_CIRCLE_SHAPE)
	{
		cpVect offset = cpCircleShapeGetOffset(shape);
		
		if (offset.x != 0 && offset.y != 0)
		{
			glPushMatrix();
			ccglTranslate(RENDER_IN_SUBPIXEL(offset.x*CC_CONTENT_SCALE_FACTOR()*cpCCNodeImpl.xScaleRatio), 
						  RENDER_IN_SUBPIXEL(offset.y*CC_CONTENT_SCALE_FACTOR()*cpCCNodeImpl.yScaleRatio), 0);
			[super draw];
			glPopMatrix();
		}
		else
			[super draw];
	}
	else
#endif
		[super draw];
}

- (void) dealloc
{
	[_implementation release];
	[super dealloc];
}

#if (COCOS2D_VERSION >= 0x00020000)
- (BOOL) dirty
{
    return YES;
}

-(CGAffineTransform) nodeToParentTransform
{
	cpBody *body = _implementation.body;
    
    // Get out quick
    if (!body)
        return [super nodeToParentTransform];
    
	cpVect rot = (_implementation.ignoreRotation ? cpvforangle(-CC_DEGREES_TO_RADIANS(self.rotation)) : body->rot);
    cpVect pos = cpBodyGetPos(body);
    
    // Translate values
    float x = pos.x*cpCCNodeImpl.xScaleRatio;
    float y = pos.y*cpCCNodeImpl.yScaleRatio;
    
    if (self.ignoreAnchorPointForPosition) {
        x += _anchorPointInPoints.x;
        y += _anchorPointInPoints.y;
    }
    
    BOOL needsSkewMatrix = ( _skewX || _skewY );
    
    // optimization:
    // inline anchor point calculation if skew is not needed
    if( !needsSkewMatrix && !CGPointEqualToPoint(_anchorPointInPoints, CGPointZero) ) {
        x += rot.x * -_anchorPointInPoints.x * _scaleX + -rot.y * -_anchorPointInPoints.y * _scaleY;
        y += rot.y * -_anchorPointInPoints.x * _scaleX +  rot.x * -_anchorPointInPoints.y * _scaleY;
    }
    
    
    // Build Transform Matrix
    _transform = CGAffineTransformMake( rot.x * _scaleX,  rot.y * _scaleX,
                                       -rot.y * _scaleY, rot.x * _scaleY,
                                       x, y );
    
    // XXX: Try to inline skew
    // If skew is needed, apply skew and then anchor point
    if( needsSkewMatrix ) {
        CGAffineTransform skewMatrix = CGAffineTransformMake(1.0f, tanf(CC_DEGREES_TO_RADIANS(_skewY)),
                                                             tanf(CC_DEGREES_TO_RADIANS(_skewX)), 1.0f,
                                                             0.0f, 0.0f );
        _transform = CGAffineTransformConcat(skewMatrix, _transform);
        
        // adjust anchor point
        if( ! CGPointEqualToPoint(_anchorPointInPoints, CGPointZero) )
            _transform = CGAffineTransformTranslate(_transform, -_anchorPointInPoints.x, -_anchorPointInPoints.y);
    }
    
    return _transform;
}
#endif

-(void)setRotation:(float)rot
{
	if([_implementation setRotation:rot])
		[super setRotation:rot];
}

-(void)setPosition:(cpVect)pos
{
	[_implementation setPosition:pos];
	[super setPosition:pos];
}

-(void) applyImpulse:(cpVect)impulse
{
	[_implementation applyImpulse:impulse offset:cpvzero];
}

-(void) applyForce:(cpVect)force
{
	[_implementation applyForce:force offset:cpvzero];
}

-(void) applyImpulse:(cpVect)impulse offset:(cpVect)offset
{
	[_implementation applyImpulse:impulse offset:offset];
}

-(void) applyForce:(cpVect)force offset:(cpVect)offset
{
	[_implementation applyForce:force offset:offset];
}

-(void) resetForces
{
	[_implementation resetForces];
}

-(void) setIgnoreRotation:(BOOL)ignore
{
	_implementation.ignoreRotation = ignore;
}

-(BOOL) ignoreRotation
{
	return _implementation.ignoreRotation;
}

-(void) setIntegrationDt:(cpFloat)dt
{
	_implementation.integrationDt = dt;
}

-(cpFloat) integrationDt
{
	return _implementation.integrationDt;
}

-(void) setShape:(cpShape*)shape
{
    _implementation.shape = shape;
    [_implementation syncNode:self];    
}

-(cpShape*) shape
{
    return _implementation.shape;
}

-(NSArray*) shapes
{
    return _implementation.shapes;
}

-(void) setBody:(cpBody*)body
{
    _implementation.body = body;
    [_implementation syncNode:self];
}

-(cpBody*) body
{
    return _implementation.body;
}

-(void) setSpaceManager:(SpaceManager*)spaceManager
{
	_implementation.spaceManager = spaceManager;
}

-(SpaceManager*) spaceManager
{
	return _implementation.spaceManager;
}

-(void) setAutoFreeShapeAndBody:(BOOL)autoFree
{
	_implementation.autoFreeShapeAndBody = autoFree;
}

-(BOOL) autoFreeShapeAndBody
{
	return _implementation.autoFreeShapeAndBody;
}

@end
