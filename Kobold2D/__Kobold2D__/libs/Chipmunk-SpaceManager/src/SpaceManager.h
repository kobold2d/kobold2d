/*********************************************************************
 *	
 *	Space Manager
 *
 *	SpaceManager.h
 *
 *	Manage the space for the application
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 02/22/2009.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

/*
	ATTENTION! COCOS2D USERS
 
	Large change: Include and use SpaceManagerCocos2d class now found
	in the ccExtras folder. This design change gives a better seperation
	and will prove much more flexible in the long run, thanks for
	understanding.
 
    Also, note you will not want to include the PhysicsEditorExtras folder
    if you are not using PhysicsEditor support; your app will not compile.
 
	p.s. You may need to add the ccExtras folder path to your
	"Header Search Paths" found under your Target Info->Build area.
 */

// 0x00 HI ME LO
// 00   00 02 01
#define SPACE_MANAGER_VERSION 0x00000201

#import "chipmunk.h"
#import "ccTypes.h"

//cp extras
#import "cpExtras/cpPulleyJoint.h"

//A more definitive sounding define
#define STATIC_MASS	INFINITY

typedef void (*smgrEachFunc) (void *obj, void *data);
typedef void (*smgrIterateFunc)(cpSpace *space, smgrEachFunc func);

/*! Collision Moments */
typedef enum { 
	COLLISION_BEGIN = 1, 
	COLLISION_PRESOLVE, 
	COLLISION_POSTSOLVE, 
	COLLISION_SEPARATE
} CollisionMoment;

/*! Delegate for handling constraints that will be free'd by
	the method: removeAndFreeConstraintsOnBody */
@protocol cpConstraintCleanupDelegate<NSObject>
-(void) aboutToFreeConstraint:(cpConstraint*)constraint;
@end

/*! Delegate for handling I/O
 
	These functions are events that get fired when saving/loading
	a space, they enable you to use a specific id system (if you choose)
	as well as record any UI specific data at time of writing; the reading
	events will let you hook up your UI when an object has just been read,
	but not added to the space yet.
 */
@protocol SpaceManagerSerializeDelegate
@optional
-(long) makeShapeId:(cpShape*)shape;
-(long) makeBodyId:(cpBody*)body;
-(long) makeConstraintId:(cpConstraint*)constraint;

-(BOOL) aboutToWriteShape:(cpShape*)shape shapeId:(UInt64)id;
-(BOOL) aboutToWriteBody:(cpBody*)body bodyId:(UInt64)id;
-(BOOL) aboutToWriteConstraint:(cpConstraint*)constraint constraintId:(UInt64)id;

-(BOOL) aboutToReadShape:(cpShape*)shape shapeId:(UInt64)id;
-(BOOL) aboutToReadBody:(cpBody*)body bodyId:(UInt64)id;
-(BOOL) aboutToReadConstraint:(cpConstraint*)constraint constraintId:(UInt64)id;
@end

/*! The SpaceManager */
@interface SpaceManager : NSObject
{
	
@protected
	/* our chipmunk space! */
	cpSpace *_space;
	
	/* Internal devices (dev: Consider revamping) */
	NSMutableArray *_invocations;

	/* Helpful Shapes/Bodies */
	cpShape	*topWall,*bottomWall,*rightWall,*leftWall;
	
	/* Number of steps (across dt) perform on each step call */
	int	_steps;
	
	/* The dt used last within step */
	cpFloat	_lastDt;
	
	/* If constant dt used, then this accumulates left over */
	cpFloat _timeAccumulator;
		
	/* Options:
		-cleanupBodyDependencies will also free contraints connected to a free'd shape
		-constraintCleanupDelegate is the delegate that will be called when the above variable is true
		-rehashStaticEveryStep will rehash static shapes at the end of every step
		-iterateFunc; default will update cocosnodes for pos and rotation
		-constantDt; set this to a non-zero number to always step the simulation with that dt
	*/
	BOOL							_cleanupBodyDependencies;
	id<cpConstraintCleanupDelegate>	_constraintCleanupDelegate;
	BOOL							_rehashStaticEveryStep;
	smgrIterateFunc                 _iterateFunc;
    smgrEachFunc                    _eachFunc;
	cpFloat							_constantDt;
}

/*! The actual chipmunk space */
@property (readonly) cpSpace* space;

/*! The segment shapes that form the bounds of the window*/
@property (readwrite, assign) cpShape *topWall, *bottomWall, *rightWall, *leftWall;
 
/*! Number of steps (across dt) perform on each step call */
@property (readwrite, assign) int steps;

/*! The dt value that was used in step last */
@property (readonly) cpFloat lastDt;

/*! The gravity of the space */
@property (readwrite, assign) cpVect gravity;

/*! The damping of the space (viscousity in "air") */
@property (readwrite, assign) cpFloat damping;

/*! If this is set to YES/TRUE then step will call iterateFunc on static shapes */
//@property (readwrite, assign) BOOL iterateStatic;

/*! If this is set to YES/TRUE then step will call rehashStatic before stepping */
@property (readwrite, assign) BOOL rehashStaticEveryStep;

/*! Set the iterateFunc; the function that will use "eachFunc" to sync chipmunk values */
@property (readwrite, assign) smgrIterateFunc iterateFunc;

/*! Set the iterateFunc; the default will update cocosnodes for pos and rotation */
@property (readwrite, assign) smgrEachFunc eachFunc;

/*! A staticBody for any particular reusable purpose */
@property (readonly) cpBody *staticBody;

/*! Whether or not this space is internally locked */
@property (readonly) BOOL isSpaceLocked;

/*! If this is set to anything other than zero, the step routine will use its
 value as the dt (constant) */
@property (readwrite, assign) cpFloat constantDt;

/*! Setting this to YES/TRUE will also free contraints connected to a free'd shape */
@property (readwrite, assign) BOOL cleanupBodyDependencies;

/*! This will be called from all methods that auto-free constraints dependent on bodies being freed */
@property (readwrite, retain) id<cpConstraintCleanupDelegate> constraintCleanupDelegate;

/*! Default creation method */
+(id) spaceManager;

/*! Creation method
 @param size The average size of shapes in space
 @param count The expected number of shapes in a space (larger is better)
 */
+(id) spaceManagerWithSize:(int)size count:(int)count;

/* Creation method that takes a precreated space */
+(id) spaceManagerWithSpace:(cpSpace*)space;

/*! Initialization method
	@param size The average size of shapes in space
	@param count The expected number of shapes in a space (larger is better)
 */
-(id) initWithSize:(int)size count:(int)count;

/* Initialization method that takes a precreated space */
-(id) initWithSpace:(cpSpace*)space;

/*! load a cpSerializer file from a user docs file, delegate can be nil */
-(BOOL) loadSpaceFromUserDocs:(NSString*)file delegate:(NSObject<SpaceManagerSerializeDelegate>*)delegate;

/*! save a cpSerializer file to a user docs file, delegate can be nil */
-(BOOL) saveSpaceToUserDocs:(NSString*)file delegate:(NSObject<SpaceManagerSerializeDelegate>*)delegate;

/*! load a cpSerializer file from a file (path), delegate can be nil */
-(BOOL) loadSpaceFromPath:(NSString*)path delegate:(NSObject<SpaceManagerSerializeDelegate>*)delegate;

/*! save a cpSerializer file to a resource file (path), delegate can be nil */
-(BOOL) saveSpaceToPath:(NSString*)path delegate:(NSObject<SpaceManagerSerializeDelegate>*)delegate;

/*! after a load from a file, use this to retrieve a shape from it's id in the file */
- (cpShape*) loadedShapeForId:(UInt64) shapeId;

/*! after a load from a file, use this to retrieve a shape from it's id in the file */
- (cpBody*) loadedBodyForId:(UInt64) bodyId;

-(NSArray*) addWindowContainmentWithFriction:(cpFloat)friction elasticity:(cpFloat)elasticity size:(CGSize)wins inset:(cpVect)inset radius:(cpFloat)radius;

-(NSArray*) addWindowContainmentWithFriction:(cpFloat)friction elasticity:(cpFloat)elasticity rect:(CGRect)rect inset:(cpVect)inset radius:(cpFloat)radius;

/*! Manually advance time within the space */
-(void) step: (ccTime) delta;

/*! add a circle shape */
-(cpShape*) addCircleAt:(cpVect)pos mass:(cpFloat)mass radius:(cpFloat)radius;

/*! add a circle shape to existing body */
-(cpShape*) addCircleToBody:(cpBody*)body radius:(cpFloat)radius;

/*! add a circle shape to existing body, with offset */
-(cpShape*) addCircleToBody:(cpBody*)body radius:(cpFloat)radius offset:(CGPoint)offset;

/*! add a rectangle shape */
-(cpShape*) addRectAt:(cpVect)pos mass:(cpFloat)mass width:(cpFloat)width height:(cpFloat)height rotation:(cpFloat)r;

/*! add a rectangle shape to existing body */
-(cpShape*) addRectToBody:(cpBody*)body width:(cpFloat)width height:(cpFloat)height rotation:(cpFloat)r;

/*! add a rectangle shape to existing body, with offset */
-(cpShape*) addRectToBody:(cpBody*)body width:(cpFloat)width height:(cpFloat)height rotation:(cpFloat)r offset:(CGPoint)offset;

/*! add a polygon shape, convenience method */
-(cpShape*) addPolyAt:(cpVect)pos mass:(cpFloat)mass rotation:(cpFloat)r numPoints:(int)numPoints points:(cpVect)pt, ... ;

/*! add a polygon shape */
-(cpShape*) addPolyAt:(cpVect)pos mass:(cpFloat)mass rotation:(cpFloat)r points:(NSArray*)points;

/*! add a polygon shape */
-(cpShape*) addPolyAt:(cpVect)pos mass:(cpFloat)mass rotation:(cpFloat)r numPoints:(int)numPoints pointsArray:(cpVect*)points;

/*! add a polygon shape to existing body */
-(cpShape*) addPolyToBody:(cpBody*)body rotation:(cpFloat)r points:(NSArray*)points;

/*! add a polygon shape to existing body, with offset */
-(cpShape*) addPolyToBody:(cpBody*)body rotation:(cpFloat)r points:(NSArray*)points offset:(CGPoint)offset;

/*! Alternative, add a polygon shape to existing body */
-(cpShape*) addPolyToBody:(cpBody*)body rotation:(cpFloat)r numPoints:(int)numPoints pointsArray:(cpVect*)points;

/*! Alternative, add a polygon shape to existing body, with offset */
-(cpShape*) addPolyToBody:(cpBody*)body rotation:(cpFloat)r numPoints:(int)numPoints pointsArray:(cpVect*)points offset:(CGPoint)offset;

/* add a segment shape using world coordinates */
-(cpShape*) addSegmentAtWorldAnchor:(cpVect)fromPos toWorldAnchor:(cpVect)toPos mass:(cpFloat)mass radius:(cpFloat)radius;

/* add a segment shape using local coordinates */
-(cpShape*) addSegmentAt:(cpVect)pos fromLocalAnchor:(cpVect)fromPos toLocalAnchor:(cpVect)toPos mass:(cpFloat)mass radius:(cpFloat)radius;

/* add a segment shape using local coordinates */
-(cpShape*) addSegmentToBody:(cpBody*)body fromLocalAnchor:(cpVect)fromPos toLocalAnchor:(cpVect)toPos radius:(cpFloat)radius;

/*! Retrieve the first shape found at this position matching layers and group */
-(cpShape*) getShapeAt:(cpVect)pos layers:(cpLayers)layers group:(cpLayers)group;

/*! Retrieve the first shape found at this position */
-(cpShape*) getShapeAt:(cpVect)pos;

/*! Use if you need to call getShapes before you've actually started simulating */
-(void) rehashActiveShapes;

/*! Use if you move static shapes during simulation */
-(void) rehashStaticShapes;

/*! Use to only rehash one shape */
-(void) rehashShape:(cpShape*)shape;

/*! Given a point, return an array of NSValues with a pointer to a cpShape */
-(NSArray*) getShapesAt:(cpVect)pos layers:(cpLayers)layers group:(cpLayers)group;
/*! @see getShapesAt:layers:group: */
-(NSArray*) getShapesAt:(cpVect)pos;

/*! Given a point and a radius, return an array of NSValues with a pointer to a cpShape */
-(NSArray*) getShapesAt:(cpVect)pos radius:(float)radius layers:(cpLayers)layers group:(cpLayers)group;
/*! @see getShapesAt:radius:layers:group: */
-(NSArray*) getShapesAt:(cpVect)pos radius:(float)radius;

/*! Get shapes that are using this body */
-(NSArray*) getShapesOnBody:(cpBody*)body;

/*! Return first shape hit by the given raycast */
-(cpShape*) getShapeFromRayCastSegment:(cpVect)start end:(cpVect)end layers:(cpLayers)layers group:(cpGroup)group;
/*! see getShapeFromRayCastSegment:end:layers:group: */
-(cpShape*) getShapeFromRayCastSegment:(cpVect)start end:(cpVect)end;

/*! Return the info on the first shape hit by the given raycast */
-(cpSegmentQueryInfo) getInfoFromRayCastSegment:(cpVect)start end:(cpVect)end layers:(cpLayers)layers group:(cpGroup)group;
/*! see getInfoFromRayCastSegment:end:layers:group: */
-(cpSegmentQueryInfo) getInfoFromRayCastSegment:(cpVect)start end:(cpVect)end;

/*! Return an array of NSValues with a pointer to a cpShape that intersects the raycast */
-(NSArray*) getShapesFromRayCastSegment:(cpVect)start end:(cpVect)end layers:(cpLayers)layers group:(cpGroup)group;
/*! see getShapesFromRayCastSegment:end:layers:group: */
-(NSArray*) getShapesFromRayCastSegment:(cpVect)start end:(cpVect)end;

/*! Return an array of NSValues with a pointer to a cpSegmentQueryInfo, this array will clean up the infos when released */
-(NSArray*) getInfosFromRayCastSegment:(cpVect)start end:(cpVect)end layers:(cpLayers)layers group:(cpGroup)group;
/*! see getInfosFromRayCastSegment:end:layers:group: */
-(NSArray*) getInfosFromRayCastSegment:(cpVect)start end:(cpVect)end;

/*! Explosion, applied linear force to objects within radius */
-(void) applyLinearExplosionAt:(cpVect)at radius:(cpFloat)radius maxForce:(cpFloat)maxForce;
/*! Explosion, applied linear force to objects within radius given a group and layer(s) */
-(void) applyLinearExplosionAt:(cpVect)at radius:(cpFloat)radius maxForce:(cpFloat)maxForce layers:(cpLayers)layers group:(cpGroup)group;

/*! Queries the space as to whether these two shapes are in persistent contact */
-(BOOL) isPersistentContactOnShape:(cpShape*)shape contactShape:(cpShape*)shape2;

/*! Queries the space as to whether this shape has a persistent contact, returns the first arbiter info */
-(cpArbiter*) persistentContactInfoOnShape:(cpShape*)shape;

/*! Queries the space as to whether this shape has a persistent contact, returns the all arbiters  */
-(NSArray*) persistentContactInfosOnShape:(cpShape*)shape;

/*! Queries the space as to whether this shape has ANY persistent contact, It will return
 the first shape it finds or NULL if nothing is found*/
-(cpShape*) persistentContactOnShape:(cpShape*)shape;

/*! Will return an array of NSValues that point to the cpConstraints */
-(NSArray*) getConstraints;

/*! Will return an array of NSValues that point to the cpConstraints on given body */
-(NSArray*) getConstraintsOnBody:(cpBody*)body;

/*! Use when removing & freeing a shape AND it's body if the body is not used by other shapes */
-(void) removeAndFreeShape:(cpShape*)shape;

/*! Use when removing a shape, will pass ownership to caller */
-(cpShape*) removeShape:(cpShape*)shape;

/*! Manually add a shape to the space */
-(void) addShape:(cpShape*)shape;

/*! Use when removing & freeing a body */
-(void) removeAndFreeBody:(cpBody*)body;

/*! Use when removing a body, will pass ownership to caller */
-(void) removeBody:(cpBody*)body;

/*! Manually add a body to the space */
-(void) addBody:(cpBody*)body;

/*! Check is body belongs to more than one shape */
-(BOOL) isBodyShared:(cpBody*)body;

/*! Count shapes on body */
-(int) shapesOnBody:(cpBody*)body;

/*! This will force a shape into a static shape */
-(cpShape*) morphShapeToStatic:(cpShape*)shape __attribute__((__deprecated__));

/*! This will force a shape active and give it the given mass */
-(cpShape*) morphShapeToActive:(cpShape*)shape mass:(cpFloat)mass __attribute__((__deprecated__));

/*! This will force a shape to be kinematic (body will not simulate) */
-(cpShape*) morphShapeToKinematic:(cpShape*)shape __attribute__((__deprecated__));

/*! This will take a shape (any) and split it into the number of pieces you specify,
	@return An NSArray* of NSValues* with cpShape* as the value (the fragments) or nil if failed
 */
-(NSArray*) fragmentShape:(cpShape*)shape piecesNum:(int)pieces eachMass:(float)mass;

/*! This will take a rect and split it into the number of pieces (Rows x Cols) you specify,
 @return An NSArray* of NSValues* with cpShape* as the value (the fragments) or nil if failed
 */
-(NSArray*) fragmentRect:(cpPolyShape*)poly rowPiecesNum:(int)rows colPiecesNum:(int)cols eachMass:(float)mass;

/*! This will take a circle and split it into the number of pieces you specify,
 @return An NSArray* of NSValues* with cpShape* as the value (the fragments) or nil if failed
 */
-(NSArray*) fragmentCircle:(cpCircleShape*)circle piecesNum:(int)pieces eachMass:(float)mass;

/*! This will take a segment and split it into the number of pieces you specify,
 @return An NSArray* of NSValues* with cpShape* as the value (the fragments) or nil if failed
 */
-(NSArray*) fragmentSegment:(cpSegmentShape*)segment piecesNum:(int)pieces eachMass:(float)mass;

/*! Combine two shapes together by combining their bodies into one */
-(void) combineShapes:(cpShape*)shape, ... NS_REQUIRES_NIL_TERMINATION;

/*! Offset shape from body using (circle:center, segment:endpoints, poly:vertices) */
-(void) offsetShape:(cpShape*)shape offset:(cpVect)offset;

/*! Unique Collision: will ignore the effects a collsion between types */
-(void) ignoreCollisionBetweenType:(unsigned int)type1 otherType:(unsigned int)type2;

/*! Register a collision callback between types */
-(void) addCollisionCallbackBetweenType:(unsigned int)type1 otherType:(unsigned int)type2 target:(id)target selector:(SEL)selector;

/*! Register a collision callback between types for the given collision moments */
-(void) addCollisionCallbackBetweenType:(unsigned int)type1 
							  otherType:(unsigned int)type2 
								 target:(id)target 
							   selector:(SEL)selector
								moments:(CollisionMoment)moment, ... NS_REQUIRES_NIL_TERMINATION;

/*! Unregister a collision callback between types */
-(void) removeCollisionCallbackBetweenType:(unsigned int)type1 otherType:(unsigned int)type2;

/*! Use when adding created constraints */
-(void) addConstraint:(cpConstraint*)constraint;

/*! Use when removing constraints, ownership is given to caller*/
-(cpConstraint*) removeConstraint:(cpConstraint*)constraint;

/*! This will remove and free the constraint */
-(void) removeAndFreeConstraint:(cpConstraint*)constraint;

/*! This will calculate all constraints on a body and remove & free them */
-(void) removeAndFreeConstraintsOnBody:(cpBody*)body;

/*! Add a spring to two bodies at the body anchor points */
-(cpConstraint*) addSpringToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody toBodyAnchor:(cpVect)anchr1 fromBodyAnchor:(cpVect)anchr2 restLength:(cpFloat)rest stiffness:(cpFloat)stiff damping:(cpFloat)damp;
/*! Add a spring to two bodies at the body anchor points */
-(cpConstraint*) addSpringToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody restLength:(cpFloat)rest stiffness:(cpFloat)stiff damping:(cpFloat)damp;
/*! Add a spring to two bodies at the body anchor points */
-(cpConstraint*) addSpringToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody stiffness:(cpFloat)stiff;

/*! Add a groove (aka sliding pin) between two bodies */
-(cpConstraint*) addGrooveToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody grooveAnchor1:(cpVect)groove1 grooveAnchor2:(cpVect)groove2 fromBodyAnchor:(cpVect)anchor2;
/*! Add a groove (aka sliding pin) between two bodies */
-(cpConstraint*) addGrooveToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody grooveLength:(cpFloat)length isHorizontal:(bool)horiz fromBodyAnchor:(cpVect)anchor2;
/*! Add a groove (aka sliding pin) between two bodies */
-(cpConstraint*) addGrooveToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody grooveLength:(cpFloat)length isHorizontal:(bool)horiz;

/*! Add a sliding joint between two bodies */
-(cpConstraint*) addSlideToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody toBodyAnchor:(cpVect)anchr1 fromBodyAnchor:(cpVect)anchr2 minLength:(cpFloat)min maxLength:(cpFloat)max;
/*! Add a sliding joint between two bodies, calculating max length */
-(cpConstraint*) addSlideToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody toBodyAnchor:(cpVect)anchr1 fromBodyAnchor:(cpVect)anchr2 minLength:(cpFloat)min;
/*! Add a sliding joint between two bodies */
-(cpConstraint*) addSlideToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody minLength:(cpFloat)min maxLength:(cpFloat)max;

/*! Create a pin (rod) between two bodies */
-(cpConstraint*) addPinToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody toBodyAnchor:(cpVect)anchr1 fromBodyAnchor:(cpVect)anchr2;
/*! Create a pin (rod) between two bodies */
-(cpConstraint*) addPinToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody;

/*! Add a shared point between two bodies that they may rotate around */
-(cpConstraint*) addPivotToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody toBodyAnchor:(cpVect)anchr1 fromBodyAnchor:(cpVect)anchr2;
/*! Add a shared point between two bodies that they may rotate around */
-(cpConstraint*) addPivotToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody worldAnchor:(cpVect)anchr;
/*! Add a shared point between two bodies that they may rotate around */
-(cpConstraint*) addPivotToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody;

/*! Add a motor that applys torque to a specified body(s) */
-(cpConstraint*) addMotorToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody rate:(cpFloat)rate;
/*! Add a motor that applys torque to a specified body(s) */
-(cpConstraint*) addMotorToBody:(cpBody*)toBody rate:(cpFloat)rate;

/*! Add gears between two bodies */
-(cpConstraint*) addGearToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody phase:(cpFloat)phase ratio:(cpFloat)ratio;
/*! Add gears between two bodies */
-(cpConstraint*) addGearToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody ratio:(cpFloat)ratio;

/*! This does not work yet */
-(cpConstraint*) addBreakableToConstraint:(cpConstraint*)breakConstraint maxForce:(cpFloat)max;

/*! Specify a min and a max a body can rotate relative to another body */
-(cpConstraint*) addRotaryLimitToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody min:(cpFloat)min max:(cpFloat)max;
/*! Specify a min and a max a body can rotate */
-(cpConstraint*) addRotaryLimitToBody:(cpBody*)toBody min:(cpFloat)min max:(cpFloat)max;

/*! Add a ratchet between two bodies */
-(cpConstraint*) addRatchetToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody phase:(cpFloat)phase rachet:(cpFloat)ratchet;
/*! Add a ratchet to a body */
-(cpConstraint*) addRatchetToBody:(cpBody*)toBody phase:(cpFloat)phase rachet:(cpFloat)ratchet;

/*! Add a rotary spring between two bodies */
-(cpConstraint*) addRotarySpringToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody restAngle:(cpFloat)restAngle stiffness:(cpFloat)stiff damping:(cpFloat)damp;
/*! Add a rotary spring to a body */
-(cpConstraint*) addRotarySpringToBody:(cpBody*)toBody restAngle:(cpFloat)restAngle stiffness:(cpFloat)stiff damping:(cpFloat)damp;

/*! Add a pulley between two bodies and another body which is the actual pulley */
-(cpConstraint*) addPulleyToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody pulleyBody:(cpBody*)pulleyBody
					toBodyAnchor:(cpVect)anchor1 fromBodyAnchor:(cpVect)anchor2
				  toPulleyAnchor:(cpVect)anchor3a fromPulleyAnchor:(cpVect)anchor3b
						   ratio:(cpFloat)ratio;
/*! Add a pulley between two bodies */
-(cpConstraint*) addPulleyToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody
					toBodyAnchor:(cpVect)anchor1 fromBodyAnchor:(cpVect)anchor2
				  toPulleyWorldAnchor:(cpVect)anchor3a fromPulleyWorldAnchor:(cpVect)anchor3b
						   ratio:(cpFloat)ratio;
@end

//Layers (convenience)
#define CP_LAYER_FROM_NUM(x)            (1 << x)
#define CP_LAYER_NUM_ON(layers, num)    ((layers & CP_LAYER_FROM_NUM(x) != 0)

#define CP_LAYER1   (1 << 0)
#define CP_LAYER2   (1 << 1)
#define CP_LAYER3   (1 << 2)
#define CP_LAYER4   (1 << 3)
#define CP_LAYER5   (1 << 4)
#define CP_LAYER6   (1 << 5)
#define CP_LAYER7   (1 << 6)
#define CP_LAYER8   (1 << 7)
#define CP_LAYER9   (1 << 8)
#define CP_LAYER10  (1 << 9)
#define CP_LAYER11  (1 << 10)
#define CP_LAYER12  (1 << 11)
#define CP_LAYER13  (1 << 12)
#define CP_LAYER14  (1 << 13)
#define CP_LAYER15  (1 << 14)
#define CP_LAYER16  (1 << 15)
#define CP_LAYER17  (1 << 16)
#define CP_LAYER18  (1 << 17)
#define CP_LAYER19  (1 << 18)
#define CP_LAYER20  (1 << 19)
#define CP_LAYER21  (1 << 20)
#define CP_LAYER22  (1 << 21)
#define CP_LAYER23  (1 << 22)
#define CP_LAYER24  (1 << 23)
#define CP_LAYER25  (1 << 24)
#define CP_LAYER26  (1 << 25)
#define CP_LAYER27  (1 << 26)
#define CP_LAYER28  (1 << 27)
#define CP_LAYER29  (1 << 28)
#define CP_LAYER30  (1 << 29)
#define CP_LAYER31  (1 << 30)
#define CP_LAYER32  (1 << 31)
