/*********************************************************************
 *	
 *	cpShapeNode.m
 *
 *	Provide Drawing for Shapes
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 02/22/2009.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import "cpShapeNode.h"
#import "CCDrawingPrimitives.h"

#if (COCOS2D_VERSION < 0x00020000)
#define SCALE_FACTOR CC_CONTENT_SCALE_FACTOR()
#else
#define SCALE_FACTOR 1
#endif

#define CP_CIRCLE_PT_COUNT 26
#define CP_SEG_PT_COUNT 26


static const int SMGR_sPtCount = CP_SEG_PT_COUNT;
static const GLfloat SMGR_sPt[CP_SEG_PT_COUNT+CP_SEG_PT_COUNT] = {
	0.0000,  1.0000,
	0.2588,  0.9659,
	0.5000,  0.8660,
	0.7071,  0.7071,
	0.8660,  0.5000,
	0.9659,  0.2588,
	1.0000,  0.0000,
	0.9659, -0.2588,
	0.8660, -0.5000,
	0.7071, -0.7071,
	0.5000, -0.8660,
	0.2588, -0.9659,
	0.0000, -1.0000,
	
	0.0000, -1.0000,
	-0.2588, -0.9659,
	-0.5000, -0.8660,
	-0.7071, -0.7071,
	-0.8660, -0.5000,
	-0.9659, -0.2588,
	-1.0000, -0.0000,
	-0.9659,  0.2588,
	-0.8660,  0.5000,
	-0.7071,  0.7071,
	-0.5000,  0.8660,
	-0.2588,  0.9659,
	0.0000,  1.0000,
};

static const int SMGR_cPtCount = CP_CIRCLE_PT_COUNT;
static const GLfloat SMGR_cPt[CP_CIRCLE_PT_COUNT+CP_CIRCLE_PT_COUNT] = {
	0.0000,  1.0000,
	0.2588,  0.9659,
	0.5000,  0.8660,
	0.7071,  0.7071,
	0.8660,  0.5000,
	0.9659,  0.2588,
	1.0000,  0.0000,
	0.9659, -0.2588,
	0.8660, -0.5000,
	0.7071, -0.7071,
	0.5000, -0.8660,
	0.2588, -0.9659,
	0.0000, -1.0000,
	-0.2588, -0.9659,
	-0.5000, -0.8660,
	-0.7071, -0.7071,
	-0.8660, -0.5000,
	-0.9659, -0.2588,
	-1.0000, -0.0000,
	-0.9659,  0.2588,
	-0.8660,  0.5000,
	-0.7071,  0.7071,
	-0.5000,  0.8660,
	-0.2588,  0.9659,
	0.0000,  1.0000,
	0.0f, 0.45f, // For an extra line to see the rotation.
};

#if (COCOS2D_VERSION < 0x00020000)
void cpShapeNodePreDrawState()
{
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);
}
#else
void cpShapeNodePreDrawState(CCGLProgram* shader)
{
	[shader use];
	[shader setUniformsForBuiltins];
    ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);
}
#endif

void cpShapeNodePostDrawState()
{
#if (COCOS2D_VERSION < 0x00020000)
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
#else
#endif
}

static void drawCircleShape(GLfloat *vertices, int vertices_count, BOOL fill, BOOL drawLine)
{
	int extraPtOffset = drawLine ? 0 : 1;
	
#if (COCOS2D_VERSION < 0x00020000)
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	
	if (fill)
		glDrawArrays(GL_TRIANGLE_FAN, 0, vertices_count-extraPtOffset-1);
    else
        glDrawArrays(GL_LINE_STRIP, 0, vertices_count-extraPtOffset);
#else    
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, vertices);
    
    if (fill)
        glDrawArrays(GL_TRIANGLE_FAN, 0, (GLsizei)vertices_count-extraPtOffset-1);
    else
        glDrawArrays(GL_LINE_STRIP, 0, (GLsizei)vertices_count-extraPtOffset);    
	
	CC_INCREMENT_GL_DRAWS(1);
#endif
}

static void drawPolyShape(GLfloat *vertices, int vertices_count, BOOL fill)
{
#if (COCOS2D_VERSION < 0x00020000)
	glVertexPointer(2, GL_FLOAT, 0, vertices);
#else
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, vertices);
	CC_INCREMENT_GL_DRAWS(1);
#endif
    
    if (fill)
        glDrawArrays(GL_TRIANGLE_FAN, 0, (GLsizei)vertices_count);
    else
        glDrawArrays(GL_LINE_LOOP, 0, (GLsizei)vertices_count);    

}

static void drawSegmentShape(GLfloat *vertices, int vertices_count, BOOL fill)
{
	drawPolyShape(vertices, vertices_count, fill);
}

static void cacheSentinel(GLfloat **vertices, int *vertices_count, int new_count)
{
	if (*vertices_count != new_count)
	{
		free(*vertices);
		*vertices = nil;
	}
	
	if (*vertices == nil)
	{
		*vertices = malloc(sizeof(GLfloat)*2*new_count);
		*vertices_count = new_count;
	}
}

static void cacheCircle(cpShape *shape, CGPoint pos, CGPoint rotation, GLfloat **vertices, int *vertices_count)
{	
    BOOL rotate = !ccpFuzzyEqual(rotation, CGPointZero, .1);
    
    float sx = cpCCNodeImpl.xScaleRatio;
    float sy = cpCCNodeImpl.yScaleRatio;
	cpFloat radius = cpCircleShapeGetRadius(shape);
    cpVect offset = cpCircleShapeGetOffset(shape);
    cpVect pt;
    
    offset.x *= sx;
    offset.y *= sy;

	cacheSentinel(vertices, vertices_count, SMGR_cPtCount);

	for (int i = 0; i < SMGR_cPtCount; i++)
	{		
        pt = cpv(offset.x + (SMGR_cPt[i*2] * radius),
                 offset.y + (SMGR_cPt[i*2+1] * radius));
        if (rotate)
            pt = cpvrotate(pt, rotation);
		(*vertices)[i*2] = (pos.x + pt.x) * SCALE_FACTOR * sx;
		(*vertices)[i*2+1] = (pos.y + pt.y) * SCALE_FACTOR * sx;
	}
}

static void cachePoly(cpShape *shape, CGPoint pos, CGPoint rotation, GLfloat **vertices, int *vertices_count)
{
    BOOL rotate = !ccpFuzzyEqual(rotation, CGPointZero, .1);
	int count = cpPolyShapeGetNumVerts(shape);
    
    float sx = cpCCNodeImpl.xScaleRatio;
    float sy = cpCCNodeImpl.yScaleRatio;
    
    cacheSentinel(vertices, vertices_count, count);
    
	for (int i=0; i<count; i++)
	{
		cpVect v = cpPolyShapeGetVert(shape, i);
        
        if (rotate)
            v = cpvrotate(v, rotation);
        
		(*vertices)[2*i] = (pos.x + v.x) * SCALE_FACTOR * sx;
		(*vertices)[2*i+1] = (pos.y + v.y) * SCALE_FACTOR * sy;
	}
}

static void cacheSegment(cpShape *shape, CGPoint pos, CGPoint rotation, GLfloat **vertices, int *vertices_count)
{	
	cpVect a = cpSegmentShapeGetA(shape);
	cpVect b = cpSegmentShapeGetB(shape);

    float sx = cpCCNodeImpl.xScaleRatio;
    float sy = cpCCNodeImpl.yScaleRatio;

    cpFloat radius = cpSegmentShapeGetRadius(shape);

	if (radius)
	{
		cacheSentinel(vertices, vertices_count, SMGR_sPtCount);
	
        BOOL        rotate = !ccpFuzzyEqual(rotation, CGPointZero, .1);            
		cpVect      delta = cpvsub(b, a);
		cpVect      mid = cpvmult(cpvadd(a,b), .5);
		cpFloat     len = cpvlength(delta);
		cpFloat     half = len/2;
		cpVect      norm = cpvmult(delta, 1/len);
		cpVect      pt;
		
		for (int i = 0; i < SMGR_sPtCount; i++)
		{
			pt.x = SMGR_sPt[i*2]*radius;
			pt.y = SMGR_sPt[i*2+1]*radius;
			
			if (i < SMGR_sPtCount/2)
				pt.x += half;
			else
				pt.x -= half;
			
			pt = cpvrotate(pt, norm);
			pt = cpvadd(pt, mid);
            
            if (rotate)
                pt = cpvrotate(pt, rotation);
			
			(*vertices)[i*2] = (pos.x + pt.x) * SCALE_FACTOR * sx;
			(*vertices)[i*2+1] = (pos.y + pt.y) * SCALE_FACTOR * sy;
		}
        
	} else 
	{
		cacheSentinel(vertices, vertices_count, 2);
		
		(*vertices)[0] = (pos.x + a.x) * SCALE_FACTOR * sx;
		(*vertices)[1] = (pos.y + a.y) * SCALE_FACTOR * sy;
		(*vertices)[2] = (pos.x + b.x) * SCALE_FACTOR * sx;
		(*vertices)[3] = (pos.y + b.y) * SCALE_FACTOR * sy;
	}
}

void cpShapeNodeEfficientDrawAt(cpShape *shape, CGPoint pt, CGPoint rotation)
{
    GLfloat		*vertices = nil;
	int			vertices_count = 0;
    cpShapeType type = shape->CP_PRIVATE(klass)->type;
    
    switch(type)
	{
		case CP_CIRCLE_SHAPE:
            cacheCircle(shape, pt, rotation, &vertices, &vertices_count);
			drawCircleShape(vertices, vertices_count, NO, YES);
			break;
		case CP_SEGMENT_SHAPE:
            cacheSegment(shape, pt, rotation, &vertices, &vertices_count);
			drawSegmentShape(vertices, vertices_count, NO);
			break;
		case CP_POLY_SHAPE:
            cachePoly(shape, pt, rotation, &vertices, &vertices_count);
			drawPolyShape(vertices, vertices_count, NO);
			break;
		default:
			break;
	}
    
    if (vertices)
        free(vertices);
}

void cpShapeNodeDrawAt(cpShape *shape, CGPoint pt, CGPoint rotation)
{    
#if (COCOS2D_VERSION < 0x00020000)  
	cpShapeNodePreDrawState();
#else
	cpShapeNodePreDrawState([[CCShaderCache sharedShaderCache] programForKey:kCCShader_Position_uColor]);    
#endif
    cpShapeNodeEfficientDrawAt(shape, pt, rotation);
	cpShapeNodePostDrawState();
}

@interface cpShapeNode (Private)
- (void) cacheCircle;
- (void) cachePoly;
- (void) cacheSegment;

- (void) preDrawState;
- (void) postDrawState;

- (void) drawCircleShape;
- (void) drawSegmentShape;
- (void) drawPolyShape;
@end

@implementation cpShapeNode
@synthesize displayedColor;
@synthesize cascadeColorEnabled;
@synthesize displayedOpacity;
@synthesize cascadeOpacityEnabled;

-(void)updateDisplayedColor:(ccColor3B)parentColor
{
	// does nothing, needs to be fixed by library author
}

-(void)updateDisplayedOpacity:(GLubyte)parentOpacity
{
	// does nothing, needs to be fixed by library author
}

@synthesize pointSize = _pointSize;
@synthesize lineWidth = _lineWidth;
@synthesize smoothDraw = _smoothDraw;
@synthesize fillShape = _fillShape;
@synthesize drawDecoration = _drawDecoration;
@synthesize cacheDraw = _cacheDraw;

- (id) initWithShape:(cpShape*)shape;
{
	[super initWithShape:shape];
	
	_color = ccc4(0, 0, 0, 255);
	_pointSize = 3;
	_lineWidth = 1;
	_smoothDraw = NO;	
	_fillShape = YES;
	_drawDecoration = YES;
	_cacheDraw = YES;
	_vertices = nil;
    _shape = shape;
	
	//Invalid type, force initial cache
	_lastType = CP_NUM_SHAPES;
	
	//Set internals
	self.contentSize = CGSizeMake(shape->bb.r - shape->bb.l, shape->bb.t - shape->bb.b);
	self.anchorPoint = ccp(0.0f, 0.0f);
    
#if (COCOS2D_VERSION >= 0x00020000)  
    self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_Position_uColor];
    
    _colorLocation = glGetUniformLocation(self.shaderProgram->_program, "u_color");
    _pointSizeLocation = glGetUniformLocation(self.shaderProgram->_program, "u_pointSize");
#endif
		
	return self;
}

- (void) dealloc
{
	free(_vertices);

	[super dealloc];
}

-(void) setShape:(cpShape*)shape
{
    [super setShape:shape];
    _shape = shape;
}

-(cpShape*) shape
{
    if (_shape)
        return _shape;
    else
        return _implementation.shape;
}

- (ccColor3B) color
{
    return ccc3(_color.r, _color.g, _color.b);
}

- (void) setColor:(ccColor3B)color
{
    _color = ccc4(color.r, color.g, color.b, _color.a);
}

-(GLubyte) opacity
{
    return _color.a;
}

-(void) setOpacity:(GLubyte)opacity
{
    _color.a = opacity;
}

- (void) cacheCircle
{
	cacheCircle([self shape], CGPointZero, CGPointZero, &_vertices, &_vertices_count);
}

- (void) cachePoly
{
    cachePoly([self shape], CGPointZero, CGPointZero, &_vertices, &_vertices_count);
}

- (void) cacheSegment
{
    cacheSegment([self shape], CGPointZero, CGPointZero, &_vertices, &_vertices_count);
}

- (void) preDrawState
{
#if (COCOS2D_VERSION < 0x00020000)
    cpShapeNodePreDrawState();
#else
    cpShapeNodePreDrawState(self.shaderProgram);

    ccColor4F color = ccc4FFromccc4B(_color);
    [self.shaderProgram setUniformLocation:_colorLocation with4fv:(GLfloat*) &color.r count:1];    
#endif
}

- (void) postDrawState
{
    cpShapeNodePostDrawState();
}

- (void) draw
{    
	cpShape *shape = [self shape];
    if (shape == nil)
        return;
    
	cpShapeType type = shape->CP_PRIVATE(klass)->type;
	
	//need to update verts? type changed, or don't want to cache
	BOOL update = (type != _lastType) || (!_cacheDraw);
	_lastType = type;
		
#if (COCOS2D_VERSION < 0x00020000)
	glPointSize(_pointSize);
	glLineWidth(_lineWidth);
	if (_smoothDraw && _lineWidth <= 1) //OpenGL ES 1.1 doesn't support smooth lineWidths > 1
	{
		glEnable(GL_LINE_SMOOTH);
		glEnable(GL_POINT_SMOOTH);
	}
	else
	{
		glDisable(GL_LINE_SMOOTH);
		glDisable(GL_POINT_SMOOTH);
	}
	
	//if( _color.a != 255 )
	//	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		
	glColor4ub(_color.r, _color.g, _color.b, _color.a);
#else    
	[self.shaderProgram use];
	[self.shaderProgram setUniformsForBuiltins];
#endif
    
    if( _color.a != 255 )
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    
    [self preDrawState];
	    
    switch(type)
    {
        case CP_CIRCLE_SHAPE:
            if (update) [self cacheCircle];
            [self drawCircleShape];
            break;
        case CP_SEGMENT_SHAPE:
            if (update) [self cacheSegment];
            [self drawSegmentShape];
            break;
        case CP_POLY_SHAPE:
            if (update) [self cachePoly];
            [self drawPolyShape];
            break;
        default:
            break;
    }
    
    [self postDrawState];

//#if (COCOS2D_VERSION < 0x00020000)
	if( _color.a != 255 )
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
//#endif
}

- (void) drawCircleShape
{
    drawCircleShape(_vertices, _vertices_count, _fillShape, _drawDecoration);
}

- (void) drawSegmentShape
{
    drawSegmentShape(_vertices, _vertices_count, _fillShape);
}

- (void) drawPolyShape
{
    drawPolyShape(_vertices, _vertices_count, _fillShape);
}

@end

@interface cpShapeTextureNode (Private)
-(void) cacheCoordsAndColors;
-(int) getTextureWidth;
-(int) getTextureHeight;
-(void) cacheSentinel:(int)count;
@end

@implementation cpShapeTextureNode
@synthesize texture = _texture;
@synthesize textureOffset = _textureOffset;
@synthesize textureRotation = _textureRotation;

+ (id) nodeWithShape:(cpShape *)shape file:(NSString*)file
{
	return [[[self alloc] initWithShape:shape file:file] autorelease];
}

+ (id) nodeWithShape:(cpShape*)shape texture:(CCTexture2D*)texture
{
	return [[[self alloc] initWithShape:shape texture:texture] autorelease];
}

+ (id) nodeWithShape:(cpShape*)shape batchNode:(cpShapeTextureBatchNode*)batchNode
{
	return [[[self alloc] initWithShape:shape batchNode:batchNode] autorelease];
}

- (id) initWithShape:(cpShape *)shape file:(NSString*)file
{
	return [self initWithShape:shape texture:[[CCTextureCache sharedTextureCache] addImage:file]];
}

- (id) initWithShape:(cpShape*)shape texture:(CCTexture2D*)texture
{
	[super initWithShape:shape];
	
	_color = ccc4(255, 255, 255, 255);
	_textureOffset = ccp(0,0);
	_textureRotation = 0;
	self.texture = texture;
	
	//set texture to repeat
	ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
	[_texture setTexParameters:&params];

#if (COCOS2D_VERSION >= 0x00020000)
    self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureColor];
#endif
	
	return self;
}

- (id) initWithShape:(cpShape*)shape batchNode:(cpShapeTextureBatchNode*)batchNode
{
	[self initWithShape:shape texture:nil];
	_batchNode = batchNode;
	
	return self;
}

- (void) dealloc
{
	free(_coordinates);
	free(_colors);
	self.texture = nil;
	[super dealloc];
}

-(int) getTextureWidth
{
	if (_batchNode)
		return _batchNode.texture.pixelsWide;
	else
		return _texture.pixelsWide;
}

-(int) getTextureHeight
{
	if (_batchNode)
		return _batchNode.texture.pixelsHigh;
	else
		return _texture.pixelsHigh;	
}

- (void) draw
{
	if (!_batchNode && _texture)
    {
#if (COCOS2D_VERSION < 0x00020000)
		glBindTexture(GL_TEXTURE_2D, _texture.name);
#else
        ccGLEnable( _glServerState );
        ccGLBindTexture2D(_texture.name);
#endif        
    }

	[super draw];
}

- (void) preDrawState
{
	//override to do nothing	
}

- (void) postDrawState
{
	//override to do nothing
}

- (void) drawCircleShape
{	
	[self drawPolyShape];
}

- (void) drawSegmentShape
{
	[self drawPolyShape];
}

- (void) drawPolyShape;
{
#if (COCOS2D_VERSION < 0x00020000)
	glVertexPointer(2, GL_FLOAT, 0, _vertices);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, _colors);
	glTexCoordPointer(2, GL_FLOAT, 0, _coordinates);
	
	glDrawArrays(GL_TRIANGLE_FAN, 0, _vertices_count);
#else    
    ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex);
    
    glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, _vertices);
    glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, _coordinates);
    glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, _colors);
        
    glDrawArrays(GL_TRIANGLE_FAN, 0, _vertices_count);
    
    CC_INCREMENT_GL_DRAWS(1);
#endif
}

- (void) cacheSentinel:(int)count
{	
	if (_vertices_count != count)
	{
		free(_colors);
		free(_coordinates);
		
		_colors = nil;
		_coordinates = nil;
	}
	
	if (_colors == nil)
		_colors = malloc(sizeof(ccColor4B)*2*count);
	if (_coordinates == nil)
		_coordinates = malloc(sizeof(GLfloat)*2*count);
}

- (void) cacheCircle
{
	[super cacheCircle];
    [self cacheSentinel:_vertices_count];
	[self cacheCoordsAndColors];
}

- (void) cachePoly
{
	[super cachePoly];
    [self cacheSentinel:_vertices_count];
	[self cacheCoordsAndColors];	
}

- (void) cacheSegment
{
	[super cacheSegment];
    [self cacheSentinel:_vertices_count];
	[self cacheCoordsAndColors];
}

-(void) cacheCoordsAndColors
{
	ccColor4B color = ccc4(_color.r, _color.g, _color.b, _color.a);
	
	const float width = [self getTextureWidth];	
	const float height = [self getTextureHeight];
	CGPoint t_rot = ccpForAngle(-CC_DEGREES_TO_RADIANS(_textureRotation));
	
	for (int i = 0; i < _vertices_count; i++)
	{	
		CGPoint coord = ccp(_vertices[i*2]/width, -_vertices[i*2+1]/height);
		if (_textureRotation)
			coord = ccpRotate(coord, t_rot);
		
		_coordinates[i*2] = coord.x + _textureOffset.x;
		_coordinates[i*2+1] = coord.y + _textureOffset.y;
		
		_colors[i*2] = color;
		_colors[i*2+1] = color;
	}	
}

@end

@implementation cpShapeTextureBatchNode
@synthesize texture = _texture;

+ (id) nodeWithFile:(NSString*)file
{
	return [[[self alloc] initWithFile:file] autorelease];
}

+ (id) nodeWithTexture:(CCTexture2D*)texture;
{
	return [[[self alloc] initWithTexture:texture] autorelease];
}

- (id) initWithFile:(NSString*)file;
{
	return [self initWithTexture:[[CCTextureCache sharedTextureCache] addImage:file]];
}

- (id) initWithTexture:(CCTexture2D*)texture;
{
	[super init];
	
	self.texture = texture;
	
	//set texture to repeat
	ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
	[_texture setTexParameters:&params];
	
	return self;
}

- (void) dealloc
{
	self.texture = nil;
	[super dealloc];
}

- (void) visit
{
	//cheap way to batch... not as efficient as CC implementation
#if (COCOS2D_VERSION < 0x00020000)
    glBindTexture(GL_TEXTURE_2D, _texture.name);
#else
    ccGLEnable( _glServerState );
    ccGLBindTexture2D(_texture.name);
#endif    

	[super visit];
}

@end


