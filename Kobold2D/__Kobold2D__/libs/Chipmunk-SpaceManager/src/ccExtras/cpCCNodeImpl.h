/*********************************************************************
 *	
 *	cpCCNodeImpl.h
 *
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

/*****
 Unfortunately we can't use multiple inheritance so we must
 use a pattern similar to strategy or envelope/letter, basically
 we've just added an instance of cpCCNode to whatever class
 we wish its functionality to be in. Then we create the same
 interface functions/properties and have then delegate to 
 our instance of cpCCNode, macros are defined below to help
 with this.
 
 -rkb
 *****/
 

/*! Our protocol that our CocosNode objects follow, these include:
	-cpSprite
	-cpShapeNode
	-cpAtlasSprite
 */
@protocol cpCCNodeProtocol<NSObject>

@required

/*! Set this if you don't want this object to sync with the body's rotation */
@property (nonatomic, readwrite, assign) BOOL ignoreRotation;

/*! Set this to true if you want the shape and/or body to be free'd when
 we're released */
@property (nonatomic, readwrite, assign) BOOL autoFreeShapeAndBody;

/*! If this is anything other than zero, a position change will update the
 shapes velocity using integrationDt to calculate it */
@property (nonatomic, readwrite, assign) cpFloat integrationDt;

/*! The shape, if any, that we're connected to. Setting this will also set the body */
@property (nonatomic, readwrite, assign) cpShape *shape; //This will be readonly someday

/*! The shapes, each wrapped in an NSValue, that our body is connected to */
@property (nonatomic, readonly) NSArray* shapes;

/*! The body, if any, that we're connected to. You may have a body with no shape set */
@property (nonatomic, readwrite, assign) cpBody *body;

/*! If autoFreeShapeAndBody is set, then this must be set too */
@property (nonatomic, readwrite, assign) SpaceManager *spaceManager;

@optional
-(void) applyImpulse:(cpVect)impulse;
-(void) applyImpulse:(cpVect)impulse offset:(cpVect)offset;
-(void) applyForce:(cpVect)force;
-(void) applyForce:(cpVect)force offset:(cpVect)offset;
-(void) resetForces;
@end

/*! Since we can not extend functionality from multiple
	class definitions, any class wishing to include this
	functionality must serve as a proxy and forward requests
	to a (member) object of this type, there are macros in this
	file aimed at helping achieve this
 */
@interface cpCCNodeImpl : NSObject <cpCCNodeProtocol> {

@protected
    id<cpCCNodeProtocol> _node;
    
    cpBody*         _body;
    cpShape*        _shape;
	SpaceManager*	_spaceManager;
	BOOL			_ignoreRotation;
	BOOL            _autoFreeShapeAndBody;
	cpFloat         _integrationDt;
}

- (id) initWithNode:(id<cpCCNodeProtocol>)node;
- (id) initWithShape:(cpShape*)s node:(id<cpCCNodeProtocol>)node;
- (id) initWithBody:(cpBody*)b node:(id<cpCCNodeProtocol>)node;

-(BOOL)setRotation:(float)rot;
-(void)setPosition:(cpVect)pos;

-(void) applyImpulse:(cpVect)impulse offset:(cpVect)offset;
-(void) applyForce:(cpVect)force offset:(cpVect)offset;
-(void) resetForces;

+(float) yScaleRatio;
+(void) setYScaleRatio:(float)yScaleRatio;

+(float) xScaleRatio;
+(void) setXScaleRatio:(float)xScaleRatio;

-(void) syncNode:(CCNode*)node;

@end

//The interface definitions
/*	
- (void) dealloc
{
	[_implementation release];
	[super dealloc];
}
 
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

*/

