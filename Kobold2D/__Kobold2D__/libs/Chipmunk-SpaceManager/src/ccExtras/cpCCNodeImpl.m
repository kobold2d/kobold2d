/*********************************************************************
 *	
 *	cpCCNodeImpl.m
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 02/22/2009.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import "cpCCNode.h"

#define kSmgrEpsilon 0.00001f

static float    _xScaleRatio = 1.0;
static float    _yScaleRatio = 1.0;

static void collectBodyShapes(cpBody *body, cpShape *shape, void *data)
{
    NSMutableArray* outShapes = (NSMutableArray*)(data);
    [outShapes addObject:[NSValue valueWithPointer:(id)shape]];
}

static void collectBodyFirstShape(cpBody *body, cpShape *shape, void *data)
{
    cpShape** outShape = (cpShape**)(data);
    *outShape = shape;
}

static void rehashBodyShapes(cpBody *body, cpShape *shape, void *data)
{
    SpaceManager *smgr = (SpaceManager*)data;
    [smgr rehashShape:shape];
}

static void freeBodyShapes(cpBody *body, cpShape *shape, void *data)
{
    SpaceManager *smgr = (SpaceManager*)data;
    [smgr removeAndFreeShape:shape];
}

@implementation cpCCNodeImpl

@synthesize ignoreRotation = _ignoreRotation;
@synthesize integrationDt = _integrationDt;
@synthesize spaceManager = _spaceManager;
@synthesize autoFreeShapeAndBody = _autoFreeShapeAndBody;

- (id) initWithNode:(id<cpCCNodeProtocol>)node
{
	return [self initWithBody:nil node:node];
}

- (id) initWithShape:(cpShape*)s node:(id<cpCCNodeProtocol>)node
{	
    if (s)
        return [self initWithBody:s->body node:node];
    else
        return [self initWithBody:nil node:node];
}

- (id) initWithBody:(cpBody*)b node:(id<cpCCNodeProtocol>)node
{
    [super init];
    
    _integrationDt = 0.0;
    _node = node;
    
    self.body = b;
    
    return self;
}

-(void) setShape:(cpShape*)shape
{
    _shape = shape;
    
    if (shape)
    {
        [self setBody:shape->body];
        shape->data = _node;
    }
    else
        [self setBody:nil];
}

-(cpShape*) shape
{
    cpShape* shape;
    if (_body)
        cpBodyEachShape(_body, collectBodyFirstShape, &shape);
    
    return shape;
}

-(NSArray*) shapes
{
    NSMutableArray *shapes = nil;
    
    if (_body)
    {
        shapes = [NSMutableArray array];
        cpBodyEachShape(_body, collectBodyShapes, shapes);
    }

    return shapes;
}

-(void) setBody:(cpBody*)body
{
    _body = body;
    
    if (body)
        body->data = _node;
}

-(cpBody*) body
{
    return _body;
}

-(void) dealloc
{
    if (_body && _autoFreeShapeAndBody)
    {
        assert(_spaceManager != nil);
        
        cpBodyEachShape(_body, freeBodyShapes, _spaceManager);
        
        _body->data = NULL;
        [_spaceManager removeAndFreeBody:_body];
    }
    _body = nil;
    
	[super dealloc];
}

-(BOOL)setRotation:(float)rot
{	
	if (!_ignoreRotation)
	{	
		//Needs a calculation for angular velocity and such
		if (_body != nil)
        {
            cpFloat rad = -CC_DEGREES_TO_RADIANS(rot);
            
            //fuzzy equals
            if (fabs(rad-_body->a) > kSmgrEpsilon)
                cpBodySetAngle(_body, rad);
        }
	}
	
	return !_ignoreRotation;
}

-(void)setPosition:(cpVect)pos
{	
	if (_body != nil)
	{		
        //Scale it appropriately
        pos = cpv(pos.x/_xScaleRatio, pos.y/_yScaleRatio);

		//If we're out of sync with chipmunk
        if (fabs(_body->p.x - pos.x) > kSmgrEpsilon || 
            fabs(_body->p.y - pos.y) > kSmgrEpsilon)
		{
			//(Basic Euler integration)
			if (_integrationDt)
			{
				cpBodyActivate(_body);
				cpBodySetVel(_body, cpvmult(cpvsub(pos, cpBodyGetPos(_body)), 1.0f/_integrationDt));
			}
			
			//update position
			_body->p = pos;
			
			//If we're a static shape, we need to tell our space that we've changed
			if (_spaceManager && _body->m == STATIC_MASS)
                cpBodyEachShape(_body, rehashBodyShapes, (void*)_spaceManager);                

            //else activate!, could be sleeping
            else
				cpBodyActivate(_body);
		}
	}
}

-(void) applyImpulse:(cpVect)impulse offset:(cpVect)offset
{
	if (_body != nil)
		cpBodyApplyImpulse(_body, impulse, offset);
}

-(void) applyForce:(cpVect)force offset:(cpVect)offset
{
	if (_body != nil)
		cpBodyApplyForce(_body, force, offset);	
}

-(void) resetForces
{
	if (_body != nil)
		cpBodyResetForces(_body);
}

+(float) yScaleRatio
{
    return _yScaleRatio;
}

+(void) setYScaleRatio:(float)yScaleRatio
{
    _yScaleRatio = yScaleRatio;
}

+(float) xScaleRatio
{
    return _xScaleRatio;
}

+(void) setXScaleRatio:(float)xScaleRatio
{
    _xScaleRatio = xScaleRatio;
}

-(void) syncNode:(CCNode*)node
{
    if (_body)
    {
        CGPoint pt = cpBodyGetPos(_body);
        float r = cpBodyGetAngle(_body);
        
        pt.x *= _xScaleRatio;
        pt.y *= _yScaleRatio;
        
        [node setPosition:pt];
        [node setRotation:-CC_RADIANS_TO_DEGREES(r)];
    }
}

@end
