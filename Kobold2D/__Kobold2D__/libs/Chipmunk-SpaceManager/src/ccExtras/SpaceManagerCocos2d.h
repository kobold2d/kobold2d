/*
 *  SpaceManagerCocos2d.h
 *  Example
 *
 *  Created by Robert Blackwood on 1/4/11.
 *  Copyright 2011 Mobile Bros. All rights reserved.
 *
 */

#import "cocos2d.h"
#import "SpaceManager.h"
#import "cpCCNode.h"
#import "cpCCSprite.h"
#import "cpShapeNode.h"
#import "cpConstraintNode.h"

/*! iterateFunc for only active shapes */
void smgrBasicIterateActiveShapesOnlyFunc(cpSpace* space, smgrEachFunc func);

/*! iterateFunc for both static and active */
void smgrBasicIterateShapesFunc(cpSpace* space, smgrEachFunc func);
void smgrBasicEachShape(void *shape_ptr, void *data); /*!< sync's CCNode to pos/rot of shape->body */
void smgrBasicEachShapeOrBody(void *shape_ptr, void *data); /*! sync CCNode to pos/rot of body */

/*! experimental! do not use */
void smgrEachShapeAsChildren(void *shape_ptr, void* data);

/*! iteratFunc for those who prefer body->data = CCNode 
 
 TODO: figure out simplistic way to specify either method
 */
void smgrBasicIterateBodiesFunc(cpSpace* space, smgrEachFunc func);
void smgrBasicEachBody(void *body_ptr, void* data); /*!< sync's CCNode to pos/rot of body */

/*! A specialized sub-class of SpaceManager that adds specific Cocos2d functionality */
@interface SpaceManagerCocos2d : SpaceManager

/*! Schedule a timed loop (against step:) using Cocos2d's default dt */
-(void) start;

/*! Schedule a timed loop (against step:) using dt */
-(void) start:(ccTime)dt;

/*! Stop the timed loop */
-(void) stop;

/*! Attach cpShapeNode's and cpConstraintNode's to shapes/constraints that have NULL data fields */
-(CCLayer*) createDebugLayer;

/*! Attach cpShapeNode's and cpConstraintNode's to shapes/constraints that have NULL data fields */
-(CCLayer*) createDebugLayerWithColor:(ccColor4B)color;

/*! Create [debug] node with random color */
+(cpShapeNode*) createShapeNode:(cpShape*)shape;

/*! Create [debug] node with random color */
+(cpConstraintNode*) createConstraintNode:(cpConstraint*)constraint;

/*! Convenience method for adding a containment rect around the view */
-(NSArray*) addWindowContainmentWithFriction:(cpFloat)friction elasticity:(cpFloat)elasticity inset:(cpVect)inset;
-(NSArray*) addWindowContainmentWithFriction:(cpFloat)friction elasticity:(cpFloat)elasticity inset:(cpVect)inset radius:(cpFloat)radius;

@end

