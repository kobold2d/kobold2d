/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 *
 *  Enhanced to use PhysicsEditor shapes and retina display
 *  by Andreas Loew / http://www.physicseditor.de
 *
 */

#include "GB2ShapeCache.h"

// Pixel to metres ratio. Box2D uses metres as the unit for measurement.
// This ratio defines how many pixels correspond to 1 Box2D "metre"
// Box2D is optimized for objects of 1x1 metre therefore it makes sense
// to define the ratio so that your most common object type is 1x1 metre.
// We use the value set in PhysicsEditor.
// The value must be divided by 2.0 (multiplied with 0.5) because the shapes 
// we used to create the polygons are in highres (Retina display) and 
// cocos2d always uses lowres "points"
#define PTM_RATIO ([[GB2ShapeCache sharedShapeCache] ptmRatio] * 0.5f)
