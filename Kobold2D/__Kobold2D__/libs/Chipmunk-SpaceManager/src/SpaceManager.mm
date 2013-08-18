/*********************************************************************
 *	
 *	Space Manager
 *
 *	SpaceManager.m
 *
 *	Manage the space for the application
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 02/22/2009.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import "SpaceManager.h"
#import "chipmunk_unsafe.h"
#import "cpSpaceSerializer.h"

/* Private Method Declarations */
@interface SpaceManager (PrivateMethods)
-(void) setupDefaultShape:(cpShape*)s;
-(void) removeAndMaybeFreeShape:(cpShape*)shape freeShape:(BOOL)freeShape;
-(void) removeAndMaybeFreeBody:(cpBody*)body freeBody:(BOOL)freeBody;
@end

@interface RayCastInfoValue : NSValue
@end
@implementation RayCastInfoValue
- (void) dealloc
{
	cpSegmentQueryInfo *info = (cpSegmentQueryInfo*)[self pointerValue];
	free(info);
	
	[super dealloc];
}
@end

@interface SmgrInvocation : NSObject
{
@public
    cpCollisionType a;
    cpCollisionType b;
    
    NSInvocation *invocation;
}
@property (readwrite, retain) NSInvocation *invocation;
@end

@implementation SmgrInvocation

@synthesize invocation;

-(void)dealloc
{
    self.invocation = nil;
    [super dealloc];
}

@end

typedef struct ExplosionQueryContext {
	cpLayers layers;
	cpGroup group;
	cpVect at;
	float radius;
	float maxForce;
} ExplosionQueryContext;

class cpSSDelegate : public cpSpaceSerializerDelegate 
{
public:
	
	cpSSDelegate(NSObject<SpaceManagerSerializeDelegate>* delegate) : _delegate(delegate){}
	
	CPSS_ID makeId(cpShape* shape) 
	{
		if ([_delegate respondsToSelector:@selector(makeShapeId:)])
			return [_delegate makeShapeId:shape];		
		else
			return CPSS_DEFAULT_MAKE_ID(shape);
	}
	
	CPSS_ID makeId(cpBody* body) 
	{
		if ([_delegate respondsToSelector:@selector(makeBodyId:)])
			return [_delegate makeBodyId:body];		
		else
			return CPSS_DEFAULT_MAKE_ID(body);
	}
	
	CPSS_ID makeId(cpConstraint* constraint) 
	{
		if ([_delegate respondsToSelector:@selector(makeConstraintId:)])
			return [_delegate makeConstraintId:constraint];		
		else
			return CPSS_DEFAULT_MAKE_ID(constraint);
	}
	
	bool writing(cpShape *shape, CPSS_ID shapeId) 
	{
		if ([_delegate respondsToSelector:@selector(aboutToWriteShape:shapeId:)])
			return [_delegate aboutToWriteShape:shape shapeId:shapeId];		
		else
			return true;
	}
	
	bool writing(cpBody *body, CPSS_ID bodyId) 
	{
		if ([_delegate respondsToSelector:@selector(aboutToWriteBody:bodyId:)])
			return [_delegate aboutToWriteBody:body bodyId:bodyId];		
		else
			return true;
	}
	
	bool writing(cpConstraint *constraint, CPSS_ID constraintId) 
	{
		if ([_delegate respondsToSelector:@selector(aboutToWriteConstraint:constraintId:)])
			return [_delegate aboutToWriteConstraint:constraint constraintId:constraintId];		
		else
			return true;
	}
	
	bool reading(cpShape *shape, CPSS_ID shapeId) 
	{
		if ([_delegate respondsToSelector:@selector(aboutToReadShape:shapeId:)])
			return [_delegate aboutToReadShape:shape shapeId:shapeId];		
		else
			return true;
		
	}
	bool reading(cpBody *body, CPSS_ID bodyId) 
	{
		if ([_delegate respondsToSelector:@selector(aboutToReadBody:bodyId:)])
			return [_delegate aboutToReadBody:body bodyId:bodyId];		
		else
			return true;
	}
	bool reading(cpConstraint *constraint, CPSS_ID constraintId) 
	{
		if ([_delegate respondsToSelector:@selector(aboutToReadConstraint:constraintId:)])
			return [_delegate aboutToReadConstraint:constraint constraintId:constraintId];		
		else
			return true;
	}
	
private:
	NSObject<SpaceManagerSerializeDelegate>* _delegate;
};

typedef struct { cpCollisionType a, b; } cpCollisionTypePair;

static inline cpBool
bbIntersects(const cpBB a, const cpBB b)
{
	return (a.l <= b.r && b.l <= a.r && a.b <= b.t && b.b <= a.t);
}

static void ExplosionQueryHelper(cpBB *bb, cpShape *shape, ExplosionQueryContext *context)
{
	if (!(shape->group && context->group == shape->group) && 
		(context->layers&shape->layers) &&
		bbIntersects(*bb, shape->bb))
	{
		//incredibly cheesy explosion effect (works decent with small objects)
		cpVect dxdy = cpvsub(shape->body->p, context->at);
		float distsq = cpvlengthsq(dxdy);
		
		// [Factor] = [Distance]/[Explosion Radius] 
		// [Force] = (1.0 - [Factor]) * [Total Force]
		// Apply -> [Direction] * [Force]
		if (distsq <= context->radius*context->radius)
		{
			//Distance
			float dist = cpfsqrt(distsq);
			
			//normalize for direction
			dxdy = cpvmult(dxdy, 1.0f/dist);
			cpBodyApplyImpulse(shape->body, cpvmult(dxdy, context->maxForce*(1.0f - (dist/context->radius))), cpvzero);
		}
	}
}

static int handleInvocations(CollisionMoment moment, cpArbiter *arb, struct cpSpace *space, void *data)
{
    SmgrInvocation *info = (SmgrInvocation*)data;
	NSInvocation *invocation = info->invocation;
	[invocation setArgument:&moment atIndex:2];
	[invocation setArgument:&arb atIndex:3];
	[invocation setArgument:&space atIndex:4];
	
	[invocation invoke];
	
	//default is yes, thats what it is in chipmunk
	BOOL retVal = YES;
	
	//not sure how heavy these methods are...
	if ([[invocation methodSignature]  methodReturnLength] > 0)
		[invocation getReturnValue:&retVal];
	
	return retVal;
}

static int collBegin(cpArbiter *arb, struct cpSpace *space, void *data)
{
	return handleInvocations(COLLISION_BEGIN, arb, space, data);
}

static int collPreSolve(cpArbiter *arb, struct cpSpace *space, void *data)
{
	return handleInvocations(COLLISION_PRESOLVE, arb, space, data);
}

static void collPostSolve(cpArbiter *arb, struct cpSpace *space, void *data)
{
	handleInvocations(COLLISION_POSTSOLVE, arb, space, data);
}

static void collSeparate(cpArbiter *arb, struct cpSpace *space, void *data)
{
	handleInvocations(COLLISION_SEPARATE, arb, space, data);
}

static int collIgnore(cpArbiter *arb, struct cpSpace *space, void *data)
{
	return 0;
}

static void collectAllArbiters(cpBody *body, cpArbiter *arbiter, void *outArbiters)
{
	[(NSMutableArray *)outArbiters addObject:[NSValue valueWithPointer:arbiter]];
}

static void collectAllConstraints(cpConstraint *constraint, void *outConstraints)
{
	[(NSMutableArray *)outConstraints addObject:[NSValue valueWithPointer:constraint]];    
}

static void collectAllShapes(cpShape *shape, NSMutableArray *outShapes)
{
	[outShapes addObject:[NSValue valueWithPointer:shape]];
}

static void collectAllCollidingShapes(cpShape *shape, cpContactPointSet *points, NSMutableArray *outShapes)
{
	[outShapes addObject:[NSValue valueWithPointer:shape]];	
}

static void collectAllShapesOnBody(cpBody *body, cpShape *shape, void *outShapes)
{
    [(NSMutableArray*)outShapes addObject:[NSValue valueWithPointer:shape]];
}

static void collectAllBodyConstraints(cpBody *body, cpConstraint *constraint,  void *outConstraints)
{
    [(NSMutableArray*)outConstraints addObject:[NSValue valueWithPointer:constraint]];
}

static void collectAllSegmentQueryInfos(cpShape *shape, cpFloat t, cpVect n, NSMutableArray *outInfos)
{
	cpSegmentQueryInfo *info = (cpSegmentQueryInfo*)malloc(sizeof(cpSegmentQueryInfo));
	info->shape = shape;
	info->t = t;
	info->n = n;
	[outInfos addObject:[RayCastInfoValue valueWithPointer:info]];
}

static void collectAllSegmentQueryShapes(cpShape *shape, cpFloat t, cpVect n, NSMutableArray *outShapes)
{
	[outShapes addObject:[NSValue valueWithPointer:shape]];
}

static void updateBBCache(cpShape *shape, void *unused)
{
	cpShapeCacheBB(shape);
}

static void removeShape(cpSpace *space, void *obj, void *data)
{
	[(SpaceManager*)(data) removeAndMaybeFreeShape:(cpShape*)(obj) freeShape:NO];
}

static void removeAndFreeShape(cpSpace *space, void *shape, void *data)
{
	[(SpaceManager*)(data) removeAndMaybeFreeShape:(cpShape*)(shape) freeShape:YES];
}

static void removeBody(cpSpace *space, void *obj, void *data)
{
	[(SpaceManager*)(data) removeAndMaybeFreeBody:(cpBody*)(obj) freeBody:NO];
}

static void removeAndFreeBody(cpSpace *space, void *body, void *data)
{
	[(SpaceManager*)(data) removeAndMaybeFreeBody:(cpBody*)(body) freeBody:YES];
}

static void countBodyReferences(cpBody *body, cpShape *shape, void *data)
{
    int *count = (int*)data;
    (*count)++;
}

static void clearBodyReferenceFromShape(cpBody *body, cpShape *shape, void *data)
{
    shape->body = NULL;
}

static void freeShapesHelper(cpShape *shape, void *data)
{
	cpSpace *space = (cpSpace*)data;
    
    //Do this for rogue bodies (Free them, clear any references to ensure this only happens once)
	if (shape)
    {
        cpBody* body = shape->body;

        if (body 
            && body != space->staticBody            //not the spaces own static body
            && !cpSpaceContainsBody(space, body))   //rogue body
        {
            //clear refs from all shapes
            cpBodyEachShape(body, clearBodyReferenceFromShape, NULL);
            cpBodyFree(body);
        }
        
        cpShapeFree(shape);
    }
}

static void freeBodiesHelper(cpBody *body, void *data)
{
	//cpSpace *space = (cpSpace*)data;    
	if (body)
        cpBodyFree(body);
}

static void freeConstraintsHelper(cpConstraint *constraint, void *data)
{
	//cpSpace *space = (cpSpace*)data;    
	if (constraint)
        cpConstraintFree(constraint);
}

static void addBody(cpSpace *space, void *obj, void *data)
{
	cpBody *body = (cpBody*)(obj);
	
	if (body->m != STATIC_MASS && !cpSpaceContainsBody(space, body))
		cpSpaceAddBody(space, body);
}

static void addShape(cpSpace *space, void *obj, void *data)
{
	cpShape *shape = (cpShape*)(obj);
	cpSpaceAddShape(space, shape);
}

static void removeCollision(cpSpace *space, void *collisionPair, void *inv_list)
{
    cpCollisionTypePair *ids = (cpCollisionTypePair*)collisionPair;
    NSMutableArray *invocations = (NSMutableArray*)inv_list;
    SmgrInvocation *found_info = nil; 
    
    /* Find our invocation info so we can remove it */
    for (SmgrInvocation *info in invocations) 
    {
        if ((info->a == ids->a && info->b == ids->b) ||
            (info->b == ids->a && info->a == ids->b))
        {
            found_info = info;
            break;
        }
    }
    
    if (found_info)
        [invocations removeObject:found_info];
    
    cpSpaceRemoveCollisionHandler(space, ids->a, ids->b);
    
    /* This was allocated earlier, free it now */
    free(ids);
}

@interface RayCastInfoArray : NSMutableArray
@end

@implementation SpaceManager
{
    cpSpaceSerializer _reader;
}

@synthesize space = _space;
@synthesize topWall,bottomWall,rightWall,leftWall;
@synthesize steps = _steps;
@synthesize lastDt = _lastDt;
@synthesize rehashStaticEveryStep = _rehashStaticEveryStep;
@synthesize iterateFunc = _iterateFunc;
@synthesize eachFunc = _eachFunc;
@synthesize constantDt = _constantDt;
@synthesize cleanupBodyDependencies = _cleanupBodyDependencies;
@synthesize constraintCleanupDelegate = _constraintCleanupDelegate;
//gravity and damping are written out manually

+(id) spaceManager
{
	return [[[self alloc] init] autorelease];
}

+(id) spaceManagerWithSize:(int)size count:(int)count;
{
	return [[[self alloc] initWithSize:size count:count] autorelease];
}

+(id) spaceManagerWithSpace:(cpSpace*)space;
{
	return [[[self alloc] initWithSpace:space] autorelease];	
}

-(id) init
{
	//totally arbitrary initialization values
	return [self initWithSize:20 count:50];
}

-(id) initWithSize:(int)size count:(int)count
{
	id me = [self initWithSpace:cpSpaceNew()];
	
    cpSpaceUseSpatialHash(_space, size, count);
	
	return me;
}

-(id) initWithSpace:(cpSpace*)space
{	
	[super init];
	
	static BOOL initialized = NO;	
	if (!initialized)
	{
		cpInitChipmunk();
		initialized = YES;
	}
	
	_space = space;
	
	//hmmm this gravity is silly.... sorry -rkb
	_space->gravity = cpv(0, -9.8*10);
	_space->sleepTimeThreshold = .4;	//this is actually a "large" value
	//_space->idleSpeedThreshold = 0;	//default is zero, chipmunk decides best speed
	
	topWall = bottomWall = rightWall = leftWall = nil;
	_steps = 2;
	_rehashStaticEveryStep = NO;
	_cleanupBodyDependencies = YES;
	_constantDt = 0.0f;
	_timeAccumulator = 0.0f;
	
	_iterateFunc = NULL;
	_invocations = [[NSMutableArray alloc] init];
	
	return self;
}

-(void) dealloc
{		
    if (_space != nil)
	{
		//Clear all "unowned" static bodies
		cpSpaceEachShape(_space, freeShapesHelper, _space);
        cpSpaceEachBody(_space, freeBodiesHelper, _space);
        cpSpaceEachConstraint(_space, freeConstraintsHelper, _space);
		cpSpaceFree(_space);
	}	
	
	[_invocations release];
	
	[super dealloc];
}

- (cpBody*) staticBody
{
	if (_space)
		return _space->staticBody;
	else
		return nil;
}

- (BOOL) loadSpaceFromUserDocs:(NSString*)file delegate:(NSObject<SpaceManagerSerializeDelegate>*)delegate
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:file];
	
	return [self loadSpaceFromPath:path delegate:delegate];
}

- (BOOL) saveSpaceToUserDocs:(NSString*)file delegate:(NSObject<SpaceManagerSerializeDelegate>*)delegate
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:file];	
	
	return [self saveSpaceToPath:path delegate:delegate];
}

- (BOOL) loadSpaceFromPath:(NSString*)path delegate:(NSObject<SpaceManagerSerializeDelegate>*)delegate
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])
	{
		cpSSDelegate cpssdel(delegate);
		
		_reader.delegate = &cpssdel;
		_reader.load(_space, [path cStringUsingEncoding:NSASCIIStringEncoding]);
        _reader.delegate = NULL;
		
		return YES;
	}
	else
		return NO;
}

- (BOOL) saveSpaceToPath:(NSString*)path delegate:(NSObject<SpaceManagerSerializeDelegate>*)delegate
{
	cpSSDelegate cpssdel(delegate);
	cpSpaceSerializer writer(&cpssdel);	
	return writer.save(_space, [path cStringUsingEncoding:NSASCIIStringEncoding]);
}

- (cpShape*) loadedShapeForId:(UInt64) shapeId
{
    cpSpaceSerializer::ShapeMap::iterator itr = _reader.shapeMap().find(shapeId);
    if (itr != _reader.shapeMap().end())
        return itr->second;
    else
        return NULL;
}

- (cpBody*) loadedBodyForId:(UInt64) bodyId
{
    cpSpaceSerializer::BodyMap::iterator itr = _reader.bodyMap().find(bodyId);
    if (itr != _reader.bodyMap().end())
        return itr->second;
    else
        return NULL;
}

-(void) setGravity:(cpVect)gravity
{
	_space->gravity = gravity;
}

-(cpVect) gravity
{
	return _space->gravity;
}

-(void) setDamping:(cpFloat)damping
{
	_space->damping = damping;
}

-(cpFloat) damping
{
	return _space->damping;
}

-(NSArray*) addWindowContainmentWithFriction:(cpFloat)friction elasticity:(cpFloat)elasticity size:(CGSize)wins inset:(cpVect)inset radius:(cpFloat)radius
{
    return [self addWindowContainmentWithFriction:friction 
                                       elasticity:elasticity 
                                             rect:CGRectMake(0, 0, wins.width, wins.height) 
                                            inset:inset 
                                           radius:radius];
}

-(NSArray*) addWindowContainmentWithFriction:(cpFloat)friction elasticity:(cpFloat)elasticity rect:(CGRect)rect inset:(cpVect)inset radius:(cpFloat)radius
{	
    NSMutableArray *shapes = [NSMutableArray arrayWithCapacity:4];
    cpVect bl = cpv(rect.origin.x + inset.x, rect.origin.y + inset.y);
    cpVect br = cpv(rect.size.width - inset.x, rect.origin.y + inset.y);
    cpVect tr = cpv(rect.size.width - inset.x, rect.size.height - inset.y);
    cpVect tl = cpv(rect.origin.x + inset.x, rect.size.height - inset.y);
    
	bottomWall = [self addSegmentAtWorldAnchor:bl
								 toWorldAnchor:br
										  mass:STATIC_MASS 
										radius:radius];
	
	topWall = [self addSegmentAtWorldAnchor:tl
							  toWorldAnchor:tr
									   mass:STATIC_MASS 
									 radius:radius];
	
	leftWall = [self addSegmentAtWorldAnchor:bl
							   toWorldAnchor:tl
										mass:STATIC_MASS
									  radius:radius];
	
	rightWall = [self addSegmentAtWorldAnchor:br
								toWorldAnchor:tr
										 mass:STATIC_MASS 
									   radius:radius];
	
	bottomWall->e = topWall->e = leftWall->e = rightWall->e = elasticity;
	bottomWall->u = topWall->u = leftWall->u = rightWall->u = friction;
    
    [shapes addObject:[NSValue valueWithPointer:topWall]];
    [shapes addObject:[NSValue valueWithPointer:bottomWall]];
    [shapes addObject:[NSValue valueWithPointer:leftWall]];
    [shapes addObject:[NSValue valueWithPointer:rightWall]];
    
    return shapes;
}

-(void) step: (ccTime) delta
{		
	//re-calculate static shape positions if this is set
	if (_rehashStaticEveryStep)
		cpSpaceReindexStatic(_space);
	
	_lastDt = delta;
	
	if (!_constantDt)
	{	
		cpFloat dt = delta/_steps;
		for(int i=0; i<_steps; i++)
			cpSpaceStep(_space, dt);
	}
	else 
	{
		cpFloat dt = _constantDt/_steps;
		delta += _timeAccumulator;
		while(delta >= _constantDt) 
		{
			for(int i=0; i<_steps; i++)
				cpSpaceStep(_space, dt);
			
			delta -= _constantDt;
		}
		
		_timeAccumulator = delta > 0 ? delta : 0.0f;
	}
	
	if (_iterateFunc)
        _iterateFunc(_space, _eachFunc);
}

-(BOOL) isBodyShared:(cpBody*)body
{
    return [self shapesOnBody:body] > 1;
}

-(int) shapesOnBody:(cpBody*)body
{
    int countShared = 0;		
    
    //anyone else have this body? - should prob not count static..?
    cpBodyEachShape(body, countBodyReferences, &countShared);
    
    return countShared;
}

-(void) removeAndMaybeFreeBody:(cpBody*)body freeBody:(BOOL)freeBody
{
    //in this space?
    if (cpSpaceContainsBody(_space, body))
        cpSpaceRemoveBody(_space, body);
    
    //Free it
    if (freeBody)
    {
        //cleanup any constraints
        if (_cleanupBodyDependencies)
            [self removeAndFreeConstraintsOnBody:body];
        
        cpBodyFree(body);
    }
}

-(void) removeAndMaybeFreeShape:(cpShape*)shape freeShape:(BOOL)freeShape
{	
    //This space owns it?
    if (cpSpaceContainsShape(_space, shape))
       cpSpaceRemoveShape(_space, shape);
	
	//Make sure it's not our static body
	if (shape->body != _space->staticBody)
	{
		// If zero shapes on this body, get rid of it
		if ([self shapesOnBody:shape->body] == 0)
            [self removeAndMaybeFreeBody:shape->body freeBody:freeShape];
	}
	
	if (freeShape)
		cpShapeFree(shape);	
}

-(cpShape*) removeShape:(cpShape*)shape
{
	if ([self isSpaceLocked])
		cpSpaceAddPostStepCallback(_space, removeShape, shape, self);
	else
		[self removeAndMaybeFreeShape:shape freeShape:NO];
	
	return shape;
}

-(void) removeAndFreeShape:(cpShape*)shape
{
	if ([self isSpaceLocked])
		cpSpaceAddPostStepCallback(_space, removeAndFreeShape, shape, self);
	else
		[self removeAndMaybeFreeShape:shape freeShape:YES];
}

-(void) setupDefaultShape:(cpShape*) s
{
	//Remember to set these later, if you want different values
	s->e = .5; 
	s->u = .5;
	s->collision_type = 0;
	s->data = nil;
}

-(cpShape*) addCircleAt:(cpVect)pos mass:(cpFloat)mass radius:(cpFloat)radius
{
    cpBody* body;
	if (mass != STATIC_MASS)
        body = cpBodyNew(mass, cpMomentForCircle(mass, radius, radius, cpvzero));
	else
        body = cpBodyNewStatic();
    
    cpBodySetPos(body, pos);
    
    [self addBody:body];
	
	return [self addCircleToBody:body radius:radius];
}

-(cpShape*) addCircleToBody:(cpBody*)body radius:(cpFloat)radius
{
    return [self addCircleToBody:body radius:radius offset:cpvzero];
}

-(cpShape*) addCircleToBody:(cpBody*)body radius:(cpFloat)radius offset:(CGPoint)offset
{
    cpShape* shape;
    
    shape = cpCircleShapeNew(body, radius, cpvzero);
    cpCircleShapeSetOffset(shape, offset);
	
	[self setupDefaultShape:shape];
	[self addShape:shape];
    
    return shape;
}

-(cpShape*) addRectAt:(cpVect)pos mass:(cpFloat)mass width:(cpFloat)width height:(cpFloat)height rotation:(cpFloat)r 
{	
	const cpFloat halfHeight = height/2.0f;
	const cpFloat halfWidth = width/2.0f;
	return [self addPolyAt:pos mass:mass rotation:r numPoints:4 points:		
																	cpv(-halfWidth, halfHeight),	/* top-left */ 
																	cpv( halfWidth, halfHeight),	/* top-right */
																	cpv( halfWidth,-halfHeight),	/* bottom-right */
																	cpv(-halfWidth,-halfHeight)];	/* bottom-left */
}

-(cpShape*) addRectToBody:(cpBody*)body width:(cpFloat)width height:(cpFloat)height rotation:(cpFloat)r
{
    return [self addRectToBody:body width:width height:height rotation:r offset:cpvzero];
}

-(cpShape*) addRectToBody:(cpBody*)body width:(cpFloat)width height:(cpFloat)height rotation:(cpFloat)r offset:(CGPoint)offset
{
    const cpFloat halfHeight = height/2.0f;
	const cpFloat halfWidth = width/2.0f;
    cpVect verts[4] = {
        cpv(-halfWidth, halfHeight),	/* top-left */ 
        cpv( halfWidth, halfHeight),	/* top-right */
        cpv( halfWidth,-halfHeight),	/* bottom-right */
        cpv(-halfWidth,-halfHeight)     /* bottom-left */
    };

    return [self addPolyToBody:body rotation:r numPoints:4 pointsArray:verts offset:offset];		                                                                        
}

-(cpShape*) addPolyAt:(cpVect)pos mass:(cpFloat)mass rotation:(cpFloat)r numPoints:(int)numPoints points:(cpVect)pt, ...
{
	cpShape* shape = nil;
	
	va_list args;
	va_start(args,pt);
		
	//Setup our vertices
	cpVect verts[numPoints];
	verts[0] = pt;
	for (int i = 1; i < numPoints; i++)
		verts[i] = va_arg(args, cpVect);
		
	shape = [self addPolyAt:pos mass:mass rotation:r numPoints:numPoints pointsArray:verts];
		
	va_end(args);
	
	return shape;	
}

-(cpShape*) addPolyAt:(cpVect)pos mass:(cpFloat)mass rotation:(cpFloat)r points:(NSArray*)points
{	
	//Setup our vertices
	int numPoints = [points count];
	cpVect verts[numPoints];
	for (int i = 0; i < numPoints; i++)
	{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		verts[i] = [[points objectAtIndex:i] CGPointValue];
#else
		verts[i] = [[points objectAtIndex:i] pointValue];	
#endif
	}
	return [self addPolyAt:pos mass:mass rotation:r numPoints:numPoints pointsArray:verts];	
}

//patch submitted by ja...@nuts.pl for c-style arrays
-(cpShape*) addPolyAt:(cpVect)pos mass:(cpFloat)mass rotation:(cpFloat)r numPoints:(int)numPoints pointsArray:(cpVect*)points
{
	if (numPoints >= 3)
	{		
		//Setup our poly shape
		cpBody *body;
        if (mass != STATIC_MASS)
            body = cpBodyNew(mass, cpMomentForPoly(mass, numPoints, points, cpvzero));
        else
            body = cpBodyNewStatic();

        cpBodySetPos(body, pos);
        cpBodySetAngle(body, r);
        
        [self addBody:body];
        
        //rotation should be zero now
        return [self addPolyToBody:body rotation:0 numPoints:numPoints pointsArray:points];
	}
    else
        return nil;
}

-(cpShape*) addPolyToBody:(cpBody*)body rotation:(cpFloat)r points:(NSArray*)points
{
    return [self addPolyToBody:body rotation:r points:points offset:cpvzero];
}

-(cpShape*) addPolyToBody:(cpBody*)body rotation:(cpFloat)r points:(NSArray*)points offset:(CGPoint)offset
{
    //Setup our vertices
	int numPoints = [points count];
	cpVect verts[numPoints];
	for (int i = 0; i < numPoints; i++)
	{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		verts[i] = [[points objectAtIndex:i] CGPointValue];
#else
		verts[i] = [[points objectAtIndex:i] pointValue];	
#endif
	}
	return [self addPolyToBody:body rotation:r numPoints:numPoints pointsArray:verts offset:offset];	
}

-(cpShape*) addPolyToBody:(cpBody*)body rotation:(cpFloat)r numPoints:(int)numPoints pointsArray:(cpVect*)points
{
    return [self addPolyToBody:body rotation:r numPoints:numPoints pointsArray:points offset:cpvzero];
}

-(cpShape*) addPolyToBody:(cpBody*)body rotation:(cpFloat)r numPoints:(int)numPoints pointsArray:(cpVect*)points offset:(CGPoint)offset
{
    cpShape *shape = nil;
    
    if (numPoints >= 3)
    {
        if (r != 0.0f)
        {
            cpVect angle = cpvforangle(r);
            for (int i = 0; i < numPoints; i++)
                points[i] = cpvrotate(points[i], angle);
        }
        
        shape = cpPolyShapeNew(body, numPoints, points, offset);
		
		[self setupDefaultShape:shape];
		[self addShape:shape];
    }
    
    return shape;
}


-(cpShape*) addSegmentAtWorldAnchor:(cpVect)fromPos toWorldAnchor:(cpVect)toPos mass:(cpFloat)mass radius:(cpFloat)radius
{
	cpVect pos = cpvmult(cpvsub(toPos,fromPos), .5);
	return [self addSegmentAt:cpvadd(fromPos,pos) fromLocalAnchor:cpvmult(pos,-1) toLocalAnchor:pos mass:mass radius:radius];
}

-(cpShape*) addSegmentAt:(cpVect)pos fromLocalAnchor:(cpVect)fromPos toLocalAnchor:(cpVect)toPos mass:(cpFloat)mass radius:(cpFloat)radius
{
    cpBody* body;
	if (mass != STATIC_MASS)
        body = cpBodyNew(mass, cpMomentForSegment(mass, fromPos, toPos));
    else
        body = cpBodyNewStatic();
    
    cpBodySetPos(body, pos);
    
    [self addBody:body];

    return [self addSegmentToBody:body fromLocalAnchor:fromPos toLocalAnchor:toPos radius:radius];
}

-(cpShape*) addSegmentToBody:(cpBody*)body fromLocalAnchor:(cpVect)fromPos toLocalAnchor:(cpVect)toPos radius:(cpFloat)radius
{
    cpShape* shape;

	shape = cpSegmentShapeNew(body, fromPos, toPos, radius);
	
	[self setupDefaultShape:shape];
	[self addShape:shape];
	
	return shape;    
}

-(cpShape*) getShapeAt:(cpVect)pos layers:(cpLayers)layers group:(cpLayers)group
{
	return cpSpacePointQueryFirst(_space, pos, layers, group);
}

-(cpShape*) getShapeAt:(cpVect)pos
{
	return [self getShapeAt:pos layers:CP_ALL_LAYERS group:CP_NO_GROUP];
}

-(void) rehashActiveShapes
{
	cpSpatialIndexEach(_space->CP_PRIVATE(activeShapes), (cpSpatialIndexIteratorFunc)&updateBBCache, NULL);
	cpSpatialIndexReindex(_space->CP_PRIVATE(activeShapes));
}

-(void) rehashStaticShapes
{
	cpSpaceReindexStatic(_space);
}

-(void) rehashShape:(cpShape*)shape
{
	cpSpaceReindexShape(_space, shape);
}

-(NSArray*) getShapesAt:(cpVect)pos layers:(cpLayers)layers group:(cpLayers)group
{
	NSMutableArray *shapes = [NSMutableArray array];
	cpSpacePointQuery(_space, pos, layers, group, (cpSpacePointQueryFunc)collectAllShapes, shapes);
		
	return shapes;
}

-(NSArray*) getShapesAt:(cpVect)pos
{
	return [self getShapesAt:pos layers:CP_ALL_LAYERS group:CP_NO_GROUP];
}

-(NSArray*) getShapesAt:(cpVect)pos radius:(float)radius layers:(cpLayers)layers group:(cpLayers)group;
{
	NSMutableArray *shapes = [NSMutableArray array];
	
	cpCircleShape circle;
	cpCircleShapeInit(&circle, [self staticBody], radius, pos);
	circle.shape.layers = layers;
	circle.shape.group = group;
	
	cpSpaceShapeQuery(_space, (cpShape*)(&circle), (cpSpaceShapeQueryFunc)collectAllCollidingShapes, shapes);
	
	return shapes;
}

-(NSArray*) getShapesAt:(cpVect)pos radius:(float)radius
{
	return [self getShapesAt:pos radius:radius layers:CP_ALL_LAYERS group:CP_NO_GROUP];
}

-(NSArray*) getShapesOnBody:(cpBody*)body
{
    NSMutableArray *shapes = [NSMutableArray array]; 
    cpBodyEachShape(body, collectAllShapesOnBody, shapes);

    return shapes;
}

-(cpShape*) getShapeFromRayCastSegment:(cpVect)start end:(cpVect)end layers:(cpLayers)layers group:(cpGroup)group
{
	return cpSpaceSegmentQueryFirst(_space, start, end, layers, group, NULL);
}

-(cpShape*) getShapeFromRayCastSegment:(cpVect)start end:(cpVect)end
{
	return [self getShapeFromRayCastSegment:start end:end layers:CP_ALL_LAYERS group:CP_NO_GROUP];
}

-(cpSegmentQueryInfo) getInfoFromRayCastSegment:(cpVect)start end:(cpVect)end layers:(cpLayers)layers group:(cpGroup)group
{
	cpSegmentQueryInfo info;
	cpSpaceSegmentQueryFirst(_space, start, end, layers, group, &info);
	
	return info;
}
	 
-(cpSegmentQueryInfo) getInfoFromRayCastSegment:(cpVect)start end:(cpVect)end
{
	return [self getInfoFromRayCastSegment:start end:end layers:CP_ALL_LAYERS group:CP_NO_GROUP];
}

-(NSArray*) getShapesFromRayCastSegment:(cpVect)start end:(cpVect)end layers:(cpLayers)layers group:(cpGroup)group
{
	NSMutableArray *array = [NSMutableArray array];
	
	cpSpaceSegmentQuery(_space, start, end, layers, group, (cpSpaceSegmentQueryFunc)collectAllSegmentQueryShapes, array);
	
	return array;
}

-(NSArray*) getShapesFromRayCastSegment:(cpVect)start end:(cpVect)end
{
	return [self getShapesFromRayCastSegment:start end:end layers:CP_ALL_LAYERS group:CP_NO_GROUP];
}

-(NSArray*) getInfosFromRayCastSegment:(cpVect)start end:(cpVect)end layers:(cpLayers)layers group:(cpGroup)group
{
	NSMutableArray *array = [NSMutableArray array];
	
	cpSpaceSegmentQuery(_space, start, end, layers, group, (cpSpaceSegmentQueryFunc)collectAllSegmentQueryInfos, array);
	
	return array;
}

-(NSArray*) getInfosFromRayCastSegment:(cpVect)start end:(cpVect)end
{
	return [self getInfosFromRayCastSegment:start end:end layers:CP_ALL_LAYERS group:CP_NO_GROUP];
}

-(void) applyLinearExplosionAt:(cpVect)at radius:(cpFloat)radius maxForce:(cpFloat)maxForce
{	
	[self applyLinearExplosionAt:at radius:radius maxForce:maxForce layers:CP_ALL_LAYERS group:CP_NO_GROUP];
}

-(void) applyLinearExplosionAt:(cpVect)at radius:(cpFloat)radius maxForce:(cpFloat)maxForce layers:(cpLayers)layers group:(cpGroup)group;
{
	cpBB bb = {at.x-radius, at.y-radius, at.x+radius, at.y+radius};
	ExplosionQueryContext context = {layers, group, at, radius, maxForce};
	cpSpatialIndexQuery(_space->CP_PRIVATE(activeShapes), &bb, bb, (cpSpatialIndexQueryFunc)ExplosionQueryHelper, &context);
}

-(BOOL) isPersistentContactOnShape:(cpShape*)shape contactShape:(cpShape*)shape2
{    
    NSArray *array = [self persistentContactInfosOnShape:shape];
	
    for (NSValue *val in array)
    {
        cpArbiter *arb = (cpArbiter*)[val pointerValue];
        
        CP_ARBITER_GET_SHAPES(arb, a, b)

        /* If a or b is shape2 return true */
        if (shape2 == a || shape2 == b)
            return true;
    }
    
	return false;
}

-(cpShape*) persistentContactOnShape:(cpShape*)shape
{
	cpShape *contactShape = NULL;
    
    NSArray *array = [self persistentContactInfosOnShape:shape];
    
    if ([array count] != 0)
    { 
        cpArbiter *arb = (cpArbiter*)[[array objectAtIndex:0] pointerValue];
        
		CP_ARBITER_GET_SHAPES(arb, a, b)
        
        /* Get the shape that isn't the one passed in */
		contactShape = (a == shape) ? b : a;
	}
	return contactShape;
}

-(cpArbiter*) persistentContactInfoOnShape:(cpShape*)shape
{
	cpArbiter *retArb = NULL;
    
    NSArray *array = [self persistentContactInfosOnShape:shape];
    
    if ([array count] != 0)
        retArb = (cpArbiter*)[[array objectAtIndex:0] pointerValue];
	
	return retArb;
}

-(NSArray*) persistentContactInfosOnShape:(cpShape*)shape
{
    NSMutableArray *array = [NSMutableArray array];
    cpBodyEachArbiter(shape->body, collectAllArbiters, array);
    
    return array;
}

-(NSArray*) getConstraints
{
    NSMutableArray *constraints = [NSMutableArray array];
    cpSpaceEachConstraint(_space, collectAllConstraints, constraints);
    
	return constraints;
}

-(NSArray*) getConstraintsOnBody:(cpBody*)body
{
	NSMutableArray *constraints = [NSMutableArray array];
    cpBodyEachConstraint(body, collectAllBodyConstraints, constraints);
    
	return constraints;
}

-(BOOL) isSpaceLocked
{
    return _space->CP_PRIVATE(locked) != 0;
}

-(void) addShape:(cpShape*)shape
{
	if ([self isSpaceLocked])
		cpSpaceAddPostStepCallback(_space, addShape, shape, self);
	else
		addShape(_space, shape, self);	
}

-(void) removeAndFreeBody:(cpBody*)body
{
    if ([self isSpaceLocked])
		cpSpaceAddPostStepCallback(_space, removeAndFreeBody, body, self);
	else
		[self removeAndMaybeFreeBody:body freeBody:YES];
}

-(void) removeBody:(cpBody*)body
{
  	if ([self isSpaceLocked])
		cpSpaceAddPostStepCallback(_space, removeBody, body, self);
	else
		[self removeAndMaybeFreeBody:body freeBody:NO];  
}

-(void) addBody:(cpBody*)body
{
	if ([self isSpaceLocked])
		cpSpaceAddPostStepCallback(_space, addBody, body, self);
	else
		addBody(_space, body, self);	
}

-(cpShape*) morphShapeToStatic:(cpShape*)shape
{
	return [self morphShapeToActive:shape mass:STATIC_MASS];
}

-(cpShape*) morphShapeToActive:(cpShape*)shape mass:(cpFloat)mass
{
    //TODO: Make this truly static
    
    //Grab the current body
    cpBody *oldBody = shape->body;
    cpBody *newBody;
 
    //Remove the shape from the space while we're messing with it
    [self removeShape:shape];
    
    if (mass == STATIC_MASS)
        newBody = cpBodyNewStatic();
    else
    {  
        cpFloat moment = INFINITY;
        
        switch(shape->CP_PRIVATE(klass)->type)
        {
            case CP_CIRCLE_SHAPE:
                moment = cpMomentForCircle(mass, cpCircleShapeGetRadius(shape), cpCircleShapeGetRadius(shape), cpvzero);
                break;
            case CP_SEGMENT_SHAPE:
                moment = cpMomentForSegment(mass, cpSegmentShapeGetA(shape), cpSegmentShapeGetB(shape));
                break;
            case CP_POLY_SHAPE:
                moment = cpMomentForPoly(mass, cpPolyShapeGetNumVerts(shape), ((cpPolyShape*)shape)->verts, cpvzero);
                break;
            default:
                break;
        }
        
        newBody = cpBodyNew(mass, moment);
    }
    //Copy over all the fields that matter (hopefully)
    cpBodySetPos(newBody, cpBodyGetPos(oldBody));
    cpBodySetAngle(newBody, cpBodyGetAngle(oldBody));
    cpBodySetVel(newBody, cpBodyGetVel(oldBody));
    cpBodySetAngVel(newBody, cpBodyGetAngVel(oldBody));
    newBody->velocity_func = oldBody->velocity_func;
    newBody->data = oldBody->data;
    
    //If no one else is using this body get rid of it
    if ([self isBodyShared:oldBody])
        [self removeAndFreeBody:oldBody];
    
    shape->body = newBody;
    
    [self addShape:shape];
    if (mass != STATIC_MASS)
        [self addBody:newBody];
    	
	return shape;
}

-(cpShape*) morphShapeToKinematic:(cpShape*)shape
{
    if (cpSpaceContainsBody(_space, shape->body))
        cpSpaceRemoveBody(_space, shape->body);
	return shape;
}

-(NSArray*) fragmentShape:(cpShape*)shape piecesNum:(int)pieces eachMass:(float)mass
{
	cpShapeType type = shape->CP_PRIVATE(klass)->type;
	NSArray* fragments = nil;
	
	if (type == CP_CIRCLE_SHAPE)
	{
		cpCircleShape *circle = (cpCircleShape*)shape;
		fragments = [self fragmentCircle:circle piecesNum:pieces eachMass:mass];
	}
	else if (type == CP_SEGMENT_SHAPE)
	{
		cpSegmentShape *segment = (cpSegmentShape*)shape;
		fragments = [self fragmentSegment:segment piecesNum:pieces eachMass:mass];
	}
	else if (type == CP_POLY_SHAPE)
	{
		cpPolyShape *poly = (cpPolyShape*)shape;
		
		//get a square grid size number
		pieces = (int)sqrt((double)pieces);
		
		//only support rects right now
		fragments = [self fragmentRect:poly rowPiecesNum:pieces colPiecesNum:pieces eachMass:mass];
	}
	
	return fragments;
}

-(NSArray*) fragmentRect:(cpPolyShape*)poly rowPiecesNum:(int)rows colPiecesNum:(int)cols eachMass:(float)mass;
{
	NSMutableArray* fragments = nil;
	cpBody *body = ((cpShape*)poly)->body;
	
	if (poly->numVerts == 4)
	{
		fragments = [NSMutableArray array];
		cpShape *fragment;
		
		//use the opposing endpoints (diagonal) to calc width & height
		float w = fabs(poly->verts[0].x - poly->verts[1].x);
		float h = fabs(poly->verts[1].y - poly->verts[2].y);
		
		float fw = w/cols;
		float fh = h/rows;
		
		for (int i = 0; i < cols; i++)
		{
			for (int j = 0; j < rows; j++)
			{
				cpVect pt = cpvadd(cpv(fw/2.0f,fh/2.0f), cpv((i*fw)-w/2.0f,(j*fh)-h/2.0f));
		
				pt = cpBodyLocal2World(body, pt);
				
				fragment = [self addRectAt:pt mass:mass width:fw height:fh rotation:cpBodyGetAngle(body)];
				
				[fragments addObject:[NSValue valueWithPointer:fragment]];
			}
		}
		
		[self removeAndFreeShape:(cpShape*)poly];
	}
	
	return fragments;
}

-(NSArray*) fragmentCircle:(cpCircleShape*)circle piecesNum:(int)pieces eachMass:(float)mass
{
	NSMutableArray* fragments = [NSMutableArray array];
	
	cpBody *body = ((cpShape*)circle)->body;
	float radius = circle->r;
	
	
	cpShape *fragment;
	float radians = 2*M_PI/pieces;
	float a = radians;
	cpVect pt1, pt2, pt3, avg;
	
	pt1 = cpv(radius, 0);
	
	for (int i = 0; i < pieces; i++)
	{		
		pt2 = cpvmult(cpvforangle(a), radius);
		
		//get the centroid
		avg = cpvmult(cpvadd(pt1,pt2), 1.0/3.0f);
		pt3 = cpvadd(body->p, avg);
		
		fragment = [self addPolyAt:pt3 mass:mass rotation:0 numPoints:3 points:cpvsub(cpvzero,avg),cpvsub(pt2,avg),cpvsub(pt1,avg)];
		[fragments addObject:[NSValue valueWithPointer:fragment]];
		
		pt1 = pt2;
		a += radians;
	}
	
	[self removeAndFreeShape:(cpShape*)circle];
	
	return fragments;
}

-(NSArray*) fragmentSegment:(cpSegmentShape*)segment piecesNum:(int)pieces eachMass:(float)mass
{
	NSMutableArray* fragments = [NSMutableArray array];
	
	cpBody *body = ((cpShape*)segment)->body;
	
	cpShape *fragment;
	cpVect pt = segment->a;
	cpVect diff = cpvsub(segment->b, segment->a);
	cpVect dxdy = cpvmult(diff, 1.0f/(float)pieces);
	float len = cpvlength(dxdy);
	float rad = cpvtoangle(diff);
	
	for (int i = 0; i < pieces; i++)
	{
		fragment = [self addRectAt:cpBodyLocal2World(body,pt) mass:mass width:len height:segment->r*2 rotation:rad];
		[fragments addObject:[NSValue valueWithPointer:fragment]];
		pt = cpvadd(pt, dxdy);
	}
	
	[self removeAndFreeShape:(cpShape*)segment];
	
	return fragments;	
}

-(void) combineShapes:(cpShape*)shapes, ...
{
	NSMutableArray *ss = [NSMutableArray arrayWithCapacity:2];
    
	va_list args;
	va_start(args, shapes);
	
	cpShape *shape = shapes;
	cpBody *body = shape->body; 
	
	//Setup initial data
	cpVect mr = cpvmult(body->p, body->m);
	cpFloat total_mass = body->m;
    [ss addObject:[NSValue valueWithPointer:shape]];
	
	while ((shape = va_arg(args, cpShape*)))
	{
		body = shape->body;
		
		//Calculate the sum of the "first mass moments"
		//Treating each shape/body as a particle
		mr = cpvadd(mr, cpvmult(body->p, body->m));
		total_mass += body->m;
		
		[ss addObject:[NSValue valueWithPointer:shape]];
	}
	va_end(args);
    
	int count = [ss count];
	
	//Make sure no funny business
	if (count > 1)
	{
		//Calculate the center of mass
		cpVect cm = cpvmult(mr, 1.0f/(total_mass));
		cpFloat moi = 0;
		
		//Grab first shape
		cpShape *first_shape = (cpShape*)[[ss objectAtIndex:0] pointerValue];
		
		//Calculate the new moment of inertia
		for(int i=0; i < count; i++)
		{
			shape = (cpShape*)[[ss objectAtIndex:i] pointerValue];
			body = shape->body;
			
			cpVect offset = cpvsub(body->p, cm);
			
			//apply the offset (based off type)
			[self offsetShape:shape offset:offset];
			
			//summation of inertia
			moi += (body->i + body->m*cpvdot(offset, offset));
			
			//Remove all but first body (for reuse)
			if (i)
			{
                //This will correctly take the shape from the body's list
                cpSpaceRemoveShape(_space, shape);
                
                //New body for this shape
                cpShapeSetBody(shape, first_shape->body);
                
                //cleanup old body, unless first
                if (body != first_shape->body)
				{
                    //Only remove if in the space
                    if (cpSpaceContainsBody(_space, body))
                        cpSpaceRemoveBody(_space, body);
				
                    if (body != _space->staticBody)
                        cpBodyFree(body);
                }
                
                //Put the shape back
                cpSpaceAddShape(_space, shape);
			}
		}
		
		//New mass and moment of inertia
		cpBodySetMass(first_shape->body, total_mass);
		cpBodySetMoment(first_shape->body, moi);
		
		//New pos
		cpBodySetPos(first_shape->body, cm);
	}
}

-(void) offsetShape:(cpShape*)shape offset:(cpVect)offset;
{
	switch(shape->CP_PRIVATE(klass)->type)
	{
		case CP_CIRCLE_SHAPE:
			cpCircleShapeSetOffset(shape, offset);
			break;
		case CP_SEGMENT_SHAPE:
		{
			cpVect a = cpSegmentShapeGetA(shape);
			cpVect b = cpSegmentShapeGetB(shape);
			
			cpSegmentShapeSetEndpoints(shape, cpvadd(a, offset), cpvadd(b, offset));
			break;
		}
		case CP_POLY_SHAPE:
		{
			int numVerts = cpPolyShapeGetNumVerts(shape);
			cpVect *verts = (cpVect*)malloc(sizeof(cpVect)*numVerts);
			
			//have to copy... oh well
			for (int i = 0; i < numVerts; i++)
				verts[i] = cpPolyShapeGetVert(shape, i);
			
			cpPolyShapeSetVerts(shape, numVerts, verts, offset);
			
			free(verts);
			break;
		}
		default:
			break;
	}	
}

-(void) addConstraint:(cpConstraint*)constraint
{
    cpSpaceAddConstraint(_space, constraint);
}

-(cpConstraint*) removeConstraint:(cpConstraint*)constraint
{
    if (cpSpaceContainsConstraint(_space, constraint))
        cpSpaceRemoveConstraint(_space, constraint);	
	
    return constraint;
}

-(void) removeAndFreeConstraint:(cpConstraint*)constraint
{
	[self removeConstraint:constraint];
	cpConstraintFree(constraint);
}

-(void) removeAndFreeConstraintsOnBody:(cpBody*)body
{
    NSMutableArray *array = [NSMutableArray array];
    cpBodyEachConstraint(body, collectAllBodyConstraints, array);
	cpConstraint *constraint;
	
	for (NSValue *val in array)
    {
        //Callback for about to free constraint
        //reason: it's the only thing that may be deleted arbitrarily
        //because of the cleanupBodyDependencies
        constraint = (cpConstraint*)[val pointerValue];
        
        [_constraintCleanupDelegate aboutToFreeConstraint:constraint];
        cpSpaceRemoveConstraint(_space, constraint);
        
	}
}

-(cpConstraint*) addSpringToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody toBodyAnchor:(cpVect)anchr1 fromBodyAnchor:(cpVect)anchr2 restLength:(cpFloat)rest stiffness:(cpFloat)stiff damping:(cpFloat)damp
{
	cpConstraint *spring = cpDampedSpringNew(toBody, fromBody, anchr1, anchr2, rest, stiff, damp);
	return cpSpaceAddConstraint(_space, spring);
}

-(cpConstraint*) addSpringToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody restLength:(cpFloat)rest stiffness:(cpFloat)stiff damping:(cpFloat)damp
{
	return [self addSpringToBody:toBody fromBody:fromBody toBodyAnchor:cpvzero fromBodyAnchor:cpvzero restLength:rest stiffness:stiff damping:damp];
}

-(cpConstraint*) addSpringToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody stiffness:(cpFloat)stiff
{	
	return [self addSpringToBody:toBody fromBody:fromBody restLength:0.0 stiffness:stiff damping:1.0f];
}

-(cpConstraint*) addGrooveToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody grooveAnchor1:(cpVect)groove1 grooveAnchor2:(cpVect)groove2 fromBodyAnchor:(cpVect)anchor2
{
	cpConstraint *groove = cpGrooveJointNew(toBody, fromBody, groove1, groove2, anchor2);
	return cpSpaceAddConstraint(_space, groove);
}

-(cpConstraint*) addGrooveToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody grooveLength:(cpFloat)length isHorizontal:(bool)horiz fromBodyAnchor:(cpVect)anchor2
{
	cpVect diff = cpvzero;
	
	if (horiz)
		diff = cpv(length/2.0,0.0);
	else
		diff = cpv(0.0,length/2.0);
	
	return [self addGrooveToBody:toBody fromBody:fromBody grooveAnchor1:cpvsub(toBody->p, diff) grooveAnchor2:cpvadd(toBody->p, diff) fromBodyAnchor:anchor2];
}

-(cpConstraint*) addGrooveToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody grooveLength:(cpFloat)length isHorizontal:(bool)horiz
{
	return [self addGrooveToBody:toBody fromBody:fromBody grooveLength:length isHorizontal:horiz fromBodyAnchor:cpvzero];
}

-(cpConstraint*) addSlideToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody toBodyAnchor:(cpVect)anchr1 fromBodyAnchor:(cpVect)anchr2 minLength:(cpFloat)min maxLength:(cpFloat)max;
{	
	cpConstraint *slide = cpSlideJointNew(toBody, fromBody, anchr1, anchr2, min, max);
	return cpSpaceAddConstraint(_space, slide);
}

-(cpConstraint*) addSlideToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody toBodyAnchor:(cpVect)anchr1 fromBodyAnchor:(cpVect)anchr2 minLength:(cpFloat)min;
{	
    cpFloat max = cpvdist(cpBodyLocal2World(toBody, anchr1), cpBodyLocal2World(fromBody, anchr2));
	return [self addSlideToBody:toBody fromBody:fromBody toBodyAnchor:anchr1 fromBodyAnchor:anchr2 minLength:min maxLength:max];
}

-(cpConstraint*) addSlideToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody minLength:(cpFloat)min maxLength:(cpFloat)max
{
	return [self addSlideToBody:toBody fromBody:fromBody toBodyAnchor:cpvzero fromBodyAnchor:cpvzero minLength:min maxLength:max];
}

-(cpConstraint*) addPinToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody toBodyAnchor:(cpVect)anchr1 fromBodyAnchor:(cpVect)anchr2
{
	cpConstraint *pin = cpPinJointNew(toBody, fromBody, anchr1, anchr2);
	return cpSpaceAddConstraint(_space, pin);
}

-(cpConstraint*) addPinToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody
{
	return [self addPinToBody:toBody fromBody:fromBody toBodyAnchor:cpvzero fromBodyAnchor:cpvzero];
}

-(cpConstraint*) addPivotToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody toBodyAnchor:(cpVect)anchr1 fromBodyAnchor:(cpVect)anchr2
{
	cpConstraint *pin = cpPivotJointNew2(toBody, fromBody, anchr1, anchr2);
	return cpSpaceAddConstraint(_space, pin);
}

-(cpConstraint*) addPivotToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody worldAnchor:(cpVect)anchr
{
	cpConstraint *pin = cpPivotJointNew(toBody, fromBody, anchr);
	return cpSpaceAddConstraint(_space, pin);	
}

-(cpConstraint*) addPivotToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody
{
	return [self addPivotToBody:toBody fromBody:fromBody toBodyAnchor:cpvzero fromBodyAnchor:cpvzero];
}

-(cpConstraint*) addMotorToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody rate:(cpFloat)rate
{
	cpConstraint *motor = cpSimpleMotorNew(toBody, fromBody, rate);
	return cpSpaceAddConstraint(_space, motor);
}

-(cpConstraint*) addMotorToBody:(cpBody*)toBody rate:(cpFloat)rate
{
	return [self addMotorToBody:toBody fromBody:_space->staticBody rate:rate];
}

-(cpConstraint*) addGearToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody phase:(cpFloat)phase ratio:(cpFloat)ratio
{
	cpConstraint *gear = cpGearJointNew(toBody, fromBody, phase, ratio);
	return cpSpaceAddConstraint(_space, gear);
}

-(cpConstraint*) addGearToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody ratio:(cpFloat)ratio
{
	return [self addGearToBody:toBody fromBody:fromBody phase:0.0 ratio:ratio];
}

-(cpConstraint*) addBreakableToConstraint:(cpConstraint*)breakConstraint maxForce:(cpFloat)max
{
	//cpConstraint *breakable = cpBreakableJointNew(breakConstraint, _space);
	//breakable->maxForce = max;
	//return cpSpaceAddConstraint(_space, breakable);
	return NULL;
}

-(cpConstraint*) addRotaryLimitToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody min:(cpFloat)min max:(cpFloat)max
{
	cpConstraint* rotaryLimit = cpRotaryLimitJointNew(toBody, fromBody, min, max);
	return cpSpaceAddConstraint(_space, rotaryLimit);
}

-(cpConstraint*) addRotaryLimitToBody:(cpBody*)toBody min:(cpFloat)min max:(cpFloat)max
{
	return [self addRotaryLimitToBody:toBody fromBody:_space->staticBody min:min max:max];
}

-(cpConstraint*) addRatchetToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody phase:(cpFloat)phase rachet:(cpFloat)ratchet
{
	cpConstraint *rachet = cpRatchetJointNew(toBody, fromBody, phase, ratchet);
	return cpSpaceAddConstraint(_space, rachet);
}

-(cpConstraint*) addRatchetToBody:(cpBody*)toBody phase:(cpFloat)phase rachet:(cpFloat)ratchet
{
	return [self addRatchetToBody:toBody fromBody:_space->staticBody phase:phase rachet:ratchet];
}

-(void) ignoreCollisionBetweenType:(unsigned int)type1 otherType:(unsigned int)type2
{
	cpSpaceAddCollisionHandler(_space, type1, type2, NULL, collIgnore, NULL, NULL, NULL);
}

-(cpConstraint*) addRotarySpringToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody restAngle:(cpFloat)restAngle stiffness:(cpFloat)stiff damping:(cpFloat)damp
{
	cpConstraint* rotarySpring = cpDampedRotarySpringNew(toBody, fromBody, restAngle, stiff, damp);
	return cpSpaceAddConstraint(_space, rotarySpring);
}

-(cpConstraint*) addRotarySpringToBody:(cpBody*)toBody restAngle:(cpFloat)restAngle stiffness:(cpFloat)stiff damping:(cpFloat)damp
{
	return [self addRotarySpringToBody:toBody fromBody:_space->staticBody restAngle:restAngle stiffness:stiff damping:damp];
}

-(cpConstraint*) addPulleyToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody pulleyBody:(cpBody*)pulleyBody
					toBodyAnchor:(cpVect)anchor1 fromBodyAnchor:(cpVect)anchor2
				  toPulleyAnchor:(cpVect)anchor3a fromPulleyAnchor:(cpVect)anchor3b
						   ratio:(cpFloat)ratio
{
	cpConstraint* pulley = cpPulleyJointNew(toBody, fromBody, pulleyBody, anchor1, anchor2, anchor3a, anchor3b, ratio);
	return cpSpaceAddConstraint(_space, pulley);
}

-(cpConstraint*) addPulleyToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody
					toBodyAnchor:(cpVect)anchor1 fromBodyAnchor:(cpVect)anchor2
			 toPulleyWorldAnchor:(cpVect)anchor3a fromPulleyWorldAnchor:(cpVect)anchor3b
						   ratio:(cpFloat)ratio
{
	return [self addPulleyToBody:toBody fromBody:fromBody pulleyBody:_space->staticBody 
					toBodyAnchor:anchor1 fromBodyAnchor:anchor2
			 toPulleyAnchor:anchor3a fromPulleyAnchor:anchor3b ratio:ratio];
}

-(void) addCollisionCallbackBetweenType:(unsigned int)type1 otherType:(unsigned int) type2 target:(id)target selector:(SEL)selector
{
	//set up the invocation
	NSMethodSignature * sig = [[target class] instanceMethodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
	
	[invocation setTarget:target];
	[invocation setSelector:selector];
    
    SmgrInvocation *info = [[[SmgrInvocation alloc] init] autorelease];
    info->a = type1;
    info->b = type2;
    info.invocation = invocation;
	
	//add the callback to chipmunk
	cpSpaceAddCollisionHandler(_space, type1, type2, collBegin, collPreSolve, collPostSolve, collSeparate, info);
	
	//we'll keep a ref so it won't disappear, prob could just retain and clear hash later
	[_invocations addObject:info];
}

-(void) addCollisionCallbackBetweenType:(unsigned int)type1 
							  otherType:(unsigned int)type2 
								 target:(id)target 
							   selector:(SEL)selector
								moments:(CollisionMoment)moment, ...
{
	//set up the invocation
	NSMethodSignature * sig = [[target class] instanceMethodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
	
	[invocation setTarget:target];
	[invocation setSelector:selector];
    
    SmgrInvocation *info = [[[SmgrInvocation alloc] init] autorelease];
    info->a = type1;
    info->b = type2;
    info.invocation = invocation;
	
	cpCollisionBeginFunc begin = NULL;
	cpCollisionPreSolveFunc preSolve = NULL;
	cpCollisionPostSolveFunc postSolve = NULL;
	cpCollisionSeparateFunc separate = NULL;
	
	va_list args;
	va_start(args, moment);
	
	while (moment != 0)
	{
		switch (moment) 
		{
			case COLLISION_BEGIN:
				begin = collBegin;
				break;
			case COLLISION_PRESOLVE:
				preSolve = collPreSolve;
				break;
			case COLLISION_POSTSOLVE:
				postSolve = collPostSolve;
				break;
			case COLLISION_SEPARATE:
				separate = collSeparate;
				break;
			default:
				break;
		}
		moment = (CollisionMoment)va_arg(args, int);
	}

	va_end(args);
		
	//add the callback to chipmunk
	cpSpaceAddCollisionHandler(_space, type1, type2, begin, preSolve, postSolve, separate, info);
	
	//we'll keep a ref so it won't disappear, prob could just retain and clear hash later
	[_invocations addObject:info];
}

-(void) removeCollisionCallbackBetweenType:(unsigned int)type1 otherType:(unsigned int)type2
{
	//Chipmunk hashes the invocation for us, we must pull it out
	cpCollisionTypePair *pair = (cpCollisionTypePair*)malloc(sizeof(cpCollisionTypePair));
    pair->a = type1;
    pair->b = type2;
	
	//delete the invocation, if there is one
	if ([self isSpaceLocked])
		cpSpaceAddPostStepCallback(_space, removeCollision, (void*)pair, (void*)_invocations);
	else
		removeCollision(_space, (void*)pair, (void*)_invocations);
}

@end
