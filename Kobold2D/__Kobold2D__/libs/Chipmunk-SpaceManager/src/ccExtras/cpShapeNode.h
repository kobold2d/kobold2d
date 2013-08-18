/*********************************************************************
 *	
 *	cpShapeNode.h
 *
 *	Provide Drawing for Shapes
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 02/22/2009.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import "cocos2d.h"
#import "chipmunk.h"
#import "cpCCNode.h"

//Utility draw functions
#if (COCOS2D_VERSION < 0x00020000)
/*! GL pre draw state for cpShapeNode */
void cpShapeNodePreDrawState();
#else
/*! GL pre draw state for cpShapeNode */
void cpShapeNodePreDrawState(CCGLProgram* shader);
#endif

/*! GL post draw state for cpShapeNode */
void cpShapeNodePostDrawState();

//draw a shape with the correct pre/post states
void cpShapeNodeDrawAt(cpShape *shape, CGPoint pt, CGPoint rotation);

//draw a shape without the pre/post states
//Use the pre/post calls above to draw many shapes at once
void cpShapeNodeEfficientDrawAt(cpShape *shape, CGPoint pt, CGPoint rotation);

@interface cpShapeNode : cpCCNode <CCRGBAProtocol>
{
@protected	
	ccColor4B _color;
	
	cpFloat _pointSize;
	cpFloat _lineWidth;
	BOOL	_smoothDraw;
	BOOL	_fillShape;
	BOOL	_drawDecoration;
	BOOL	_cacheDraw;
	
	//cache
	cpShapeType	_lastType;
	GLfloat		*_vertices;
	int			_vertices_count;
        
    //this is only useful if there is more than one shape
    //on a body, and will only be set if the user calls setShape
    cpShape                 *_shape;
    
    //opengl es 2.0
#if (COCOS2D_VERSION >= 0x00020000)  
    int _colorLocation;
    int _pointSizeLocation;
#endif
}

/*! Color of our drawn shape */
@property (nonatomic, readwrite, assign) ccColor3B color;

/*! Opacity of our drawn shape */
@property (nonatomic, readwrite, assign) GLubyte opacity;

/*! Size of drawn points, default is 3 */
@property (readwrite, assign) cpFloat pointSize;    //### This isn't used..?

/*! Width of the drawn lines, default is 1 */
@property (readwrite, assign) cpFloat lineWidth;

/*! If this is set to YES/TRUE then the shape will be drawn
 with smooth lines/points */
@property (readwrite, assign) BOOL smoothDraw;

/*! If this is set to YES/TRUE then the shape will be filled
 when drawn */
@property (readwrite, assign) BOOL fillShape;

/*! Currently only circle has a "decoration" it is an extra line
 to see the rotation */
@property (readwrite, assign) BOOL drawDecoration;

/*! Cache the drawing (default is YES), if you are going to be changing the
 shape physically (ex. increase circle radius) then this should be NO */
@property (readwrite, assign) BOOL cacheDraw;

@end

@class cpShapeTextureBatchNode;

@interface cpShapeTextureNode : cpShapeNode
{
	CCTexture2D				*_texture;
	cpShapeTextureBatchNode	*_batchNode;
	
	CGPoint _textureOffset;
	float	_textureRotation;
	
	//cache
	GLfloat		*_coordinates;
	ccColor4B	*_colors;
}

@property (readwrite, retain) CCTexture2D	*texture;
@property (readwrite, assign) CGPoint		textureOffset;
@property (readwrite, assign) float			textureRotation;

/*! Create a node given a shape and texture filename */
+ (id) nodeWithShape:(cpShape*)shape file:(NSString*)file;

/*! Create a node given a shape and texture */
+ (id) nodeWithShape:(cpShape*)shape texture:(CCTexture2D*)texture;

/*! Create a node that will be added to a cpShapeTextureBatchNode */
+ (id) nodeWithShape:(cpShape*)shape batchNode:(cpShapeTextureBatchNode*)batchNode;

/*! Initialize a node given a shape and texture filename */
- (id) initWithShape:(cpShape*)shape file:(NSString*)file;

/*! Initialize a node given a shape and texture */
- (id) initWithShape:(cpShape*)shape texture:(CCTexture2D*)texture;

/*! Initialize a node that will be added to a cpShapeTextureBatchNode */
- (id) initWithShape:(cpShape*)shape batchNode:(cpShapeTextureBatchNode*)batchNode;

@end

@interface cpShapeTextureBatchNode : CCNode
{
	CCTexture2D *_texture;
}

@property (readwrite, retain) CCTexture2D *texture;

/*! Create a node given a texture filename */
+ (id) nodeWithFile:(NSString*)file;

/*! Create a node given a texture */
+ (id) nodeWithTexture:(CCTexture2D*)texture;

/*! Initialize a node given a texture filename */
- (id) initWithFile:(NSString*)file;

/*! Initialize a node given a texture */
- (id) initWithTexture:(CCTexture2D*)texture;

@end

