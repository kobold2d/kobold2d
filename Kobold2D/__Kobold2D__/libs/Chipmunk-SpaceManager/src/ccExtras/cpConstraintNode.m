/*********************************************************************
 *	
 *	cpConstraintNode
 *
 *	cpConstraintNode.m
 *
 *	Provide Drawing for Constraints
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 02/22/2009.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import "cpConstraintNode.h"
#import "CCDrawingPrimitives.h"
#import "cpCCNodeImpl.h"

#if (COCOS2D_VERSION < 0x00020000)
#define SCALE_FACTOR CC_CONTENT_SCALE_FACTOR()
#else
#define SCALE_FACTOR 1
#endif

static void drawCircle(cpVect center, float r, int segs)
{
	const float coef = 2.0f * (float)M_PI/segs;
	float *vertices = malloc(sizeof(float)*2*segs);
    float sx = cpCCNodeImpl.xScaleRatio;
    float sy = cpCCNodeImpl.yScaleRatio;

	for (int i=0;i<segs;i++)
	{
		float rads = i*coef;
		float j = r * cosf(rads) + center.x*sx;
		float k = r * sinf(rads) + center.y*sy;
		
		vertices[i*2] = j;
		vertices[i*2+1] =k;
	}
#if (COCOS2D_VERSION < 0x00020000)
	glVertexPointer(2, GL_FLOAT, 0, vertices);	
#else
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, vertices);
#endif
    glDrawArrays(GL_LINE_LOOP, 0, segs);

	free(vertices);
}

static void drawPinJoint(cpPinJoint* joint, cpBody* body_a, cpBody* body_b)
{	
	cpVect a = cpvmult(cpvadd(body_a->p, cpvrotate(joint->anchr1, body_a->rot)), SCALE_FACTOR);
	cpVect b = cpvmult(cpvadd(body_b->p, cpvrotate(joint->anchr2, body_b->rot)), SCALE_FACTOR);
    
    float sx = cpCCNodeImpl.xScaleRatio;
    float sy = cpCCNodeImpl.yScaleRatio;
	
	const float array[] = { a.x*sx, a.y*sy, b.x*sx, b.y*sy };
	
#if (COCOS2D_VERSION < 0x00020000)
	glVertexPointer(2, GL_FLOAT, 0, array);
	//glEnableClientState(GL_VERTEX_ARRAY);
#else
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, array);
    	
	CC_INCREMENT_GL_DRAWS(2);
#endif
	
	glDrawArrays(GL_POINTS, 0, (GLsizei)2);
	glDrawArrays(GL_LINES, 0, (GLsizei)2);
	
	//glDisableClientState(GL_VERTEX_ARRAY);	
}

static void drawSlideJoint(cpSlideJoint* joint, cpBody* body_a, cpBody* body_b)
{	
	cpVect a = cpvmult(cpvadd(body_a->p, cpvrotate(joint->anchr1, body_a->rot)), SCALE_FACTOR);
	cpVect b = cpvmult(cpvadd(body_b->p, cpvrotate(joint->anchr2, body_b->rot)), SCALE_FACTOR);
    
    float sx = cpCCNodeImpl.xScaleRatio;
    float sy = cpCCNodeImpl.yScaleRatio;
	
	const float array[] = { a.x*sx, a.y*sy, b.x*sx, b.y*sy };
	
#if (COCOS2D_VERSION < 0x00020000)
	glVertexPointer(2, GL_FLOAT, 0, array);
	//glEnableClientState(GL_VERTEX_ARRAY);
#else
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, array);
    
	CC_INCREMENT_GL_DRAWS(2);
#endif
	
	glDrawArrays(GL_POINTS, 0, 2);
	glDrawArrays(GL_LINES, 0, 2);
	
	//glDisableClientState(GL_VERTEX_ARRAY);	
}

static void drawPivotJoint(cpPivotJoint* joint, cpBody* body_a, cpBody* body_b)
{	
	cpVect a = cpvmult(cpvadd(body_a->p, cpvrotate(joint->anchr1, body_a->rot)), SCALE_FACTOR);
	cpVect b = cpvmult(cpvadd(body_b->p, cpvrotate(joint->anchr2, body_b->rot)), SCALE_FACTOR);

    float sx = cpCCNodeImpl.xScaleRatio;
    float sy = cpCCNodeImpl.yScaleRatio;

	const float array[] = { a.x*sx, a.y*sy, b.x*sx, b.y*sy };
	
#if (COCOS2D_VERSION < 0x00020000)
    glVertexPointer(2, GL_FLOAT, 0, array);
	//glEnableClientState(GL_VERTEX_ARRAY);
#else
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, array);
    
	CC_INCREMENT_GL_DRAWS(2);
#endif
    
	glDrawArrays(GL_POINTS, 0, 2);	
	glDrawArrays(GL_LINES, 0, 2);
	//glDisableClientState(GL_VERTEX_ARRAY);	
}

static void drawGrooveJoint(cpGrooveJoint* joint, cpBody* body_a, cpBody* body_b)
{
	cpVect a = cpvmult(cpvadd(body_a->p, cpvrotate(joint->grv_a, body_a->rot)), SCALE_FACTOR);
	cpVect b = cpvmult(cpvadd(body_a->p, cpvrotate(joint->grv_b, body_a->rot)), SCALE_FACTOR);
    
	cpVect grv = cpvmult(cpvadd(body_a->p, cpvrotate(joint->r1, body_a->rot)), SCALE_FACTOR);
    
    float sx = cpCCNodeImpl.xScaleRatio;
    float sy = cpCCNodeImpl.yScaleRatio;
	
	float groove[6];
	groove[0] = a.x*sx;
	groove[1] = a.y*sy;
	groove[2] = b.x*sx;
	groove[3] = b.y*sy;	
	groove[4] = grv.x*sx;
	groove[5] = grv.y*sy;
    
#if (COCOS2D_VERSION < 0x00020000)
    //glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(2, GL_FLOAT, 0, groove);
#else
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, groove);
    
	CC_INCREMENT_GL_DRAWS(2);
#endif
	glDrawArrays(GL_POINTS, 0, 3);
	glDrawArrays(GL_LINES, 0, 2);
    
	//glDisableClientState(GL_VERTEX_ARRAY);
}

static void drawSpringJoint(cpDampedSpring* joint, cpBody* body_a, cpBody* body_b)
{
	static const GLfloat spring[] = {
		0.00f, 0.0f,
		0.20f, 0.0f,
		0.25f, 3.0f,
		0.30f,-6.0f,
		0.35f, 6.0f,
		0.40f,-6.0f,
		0.45f, 6.0f,
		0.50f,-6.0f,
		0.55f, 6.0f,
		0.60f,-6.0f,
		0.65f, 6.0f,
		0.70f,-3.0f,
		0.75f, 6.0f,
		0.80f, 0.0f,
		1.00f, 0.0f,
	};
	static const int springCount = sizeof(spring)/sizeof(GLfloat)/2;
	
	cpVect a = cpvmult(cpvadd(body_a->p, cpvrotate(joint->anchr1, body_a->rot)), SCALE_FACTOR);
	cpVect b = cpvmult(cpvadd(body_b->p, cpvrotate(joint->anchr2, body_b->rot)), SCALE_FACTOR);
    
    float sx = cpCCNodeImpl.xScaleRatio;
    float sy = cpCCNodeImpl.yScaleRatio;

    a.x *= sx; a.y *= sy;
    b.x *= sx; b.y *= sy;
	
	const float array[] = { a.x, a.y, b.x, b.y };

#if (COCOS2D_VERSION < 0x00020000)
	glVertexPointer(2, GL_FLOAT, 0, array);
#else
    glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, array);
#endif
	
	glDrawArrays(GL_POINTS, 0, 2);	

#if (COCOS2D_VERSION < 0x00020000)  
    cpVect delta = cpvsub(b, a);
    GLfloat x = a.x;
    GLfloat y = a.y;
    GLfloat cos = delta.x;
    GLfloat sin = delta.y;
    GLfloat s = 1.0f/cpvlength(delta);
    
    const GLfloat matrix[] = {
        cos,	sin,	0.0f, 0.0f,
        -sin*s, cos*s,	0.0f, 0.0f,
        0.0f,	0.0f,	1.0f, 1.0f,
        x,		y,		0.0f, 1.0f,
    };
    
	glVertexPointer(2, GL_FLOAT, 0, spring);
	glPushMatrix();		
		glMultMatrixf(matrix);
		glDrawArrays(GL_LINE_STRIP, 0, springCount);
    glPopMatrix();
#else
#pragma unused(springCount)
//    kmMat4 kmMatrix;
//
//    kmMat4Fill(&kmMatrix, matrix);
//    kmGLMatrixMode(KM_GL_MODELVIEW);
//       
//    glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, spring);
//    kmGLPushMatrix();
//        kmGLMultMatrix(&kmMatrix);
//    
//        CCGLProgram *shader = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_Position_uColor];
//        [shader setUniformLocation:glGetUniformLocation(shader->program_, kCCUniformMVPMatrix_s) withMatrix4fv:kmMatrix.mat count:1];
//
//        glDrawArrays(GL_LINE_STRIP, 0, springCount);            
//    kmGLPopMatrix();
    static const cpFloat totalStemLenFactor = .5;
    static const cpFloat heightFactor = .1;
    
    cpFloat restLen = joint->restLength*sx;
    
    // Assume some length
    if (restLen <= 0)
        restLen = 5;
    
    cpVect dxdy = ccpSub(b, a);
    cpFloat len = cpvlength(dxdy);
    cpVect norm = cpvmult(dxdy, 1.0f/len);
    cpVect perp = cpvperp(norm);
    
    // No division by zero
    if (len <= 0)
        len = 5;
    
    cpFloat lenFactor = (restLen/len);
    
    // Don't get too large
    if (lenFactor > 4)
        lenFactor = 4;
    
    cpFloat h = heightFactor*restLen*lenFactor;
    
    cpVect a2 = cpvadd(a, cpvmult(norm, totalStemLenFactor/2*restLen));
    cpVect b2 = cpvsub(b, cpvmult(norm, totalStemLenFactor/2*restLen));
    
    // Adjust len to account for stems
    len -= (totalStemLenFactor*restLen);
    
    // Not a "true" calculation but looks right enough
    cpVect p1 = cpvadd(cpvadd(a2, cpvmult(perp, h)), cpvmult(norm, .2*len));
    cpVect p2 = cpvadd(cpvsub(a2, cpvmult(perp, h)), cpvmult(norm, .4*len));
    cpVect p3 = cpvadd(cpvadd(a2, cpvmult(perp, h)), cpvmult(norm, .6*len));
    cpVect p4 = cpvadd(cpvsub(a2, cpvmult(perp, h)), cpvmult(norm, .8*len));
        
    const float lines[] = {
        // Stems
        a.x, a.y, 
        a2.x, a2.y,
        
        b.x, b.y,
        b2.x, b2.y,
        
        //Coils
        a2.x, a2.y,
        p1.x, p1.y,
        
        p1.x, p1.y,
        p2.x, p2.y,
        
        p2.x, p2.y,
        p3.x, p3.y,
        
        p3.x, p3.y,
        p4.x, p4.y,
        
        p4.x, p4.y,
        b2.x, b2.y,    
    };
    
    glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, lines);        
    glDrawArrays(GL_LINES, 0, 14);
    
    CC_INCREMENT_GL_DRAWS(2);
#endif
}

static void drawMotorJoint(cpSimpleMotor* joint, cpBody* body_a, cpBody* body_b)
{
    // Figure out which body isn't static (maybe both aren't tho....)
    cpBody *b = cpBodyGetMass(body_a) != STATIC_MASS ? body_a : body_b;
	drawCircle(cpvmult(b->p, SCALE_FACTOR), 4.0*SCALE_FACTOR, 12);
}

static void drawGearJoint(cpGearJoint* joint, cpBody* body_a, cpBody* body_b)
{
	cpFloat ratio = joint->ratio;
	
	cpFloat radius1 = fabs(5.0 / ratio) * SCALE_FACTOR;
	cpFloat radius2 = fabs(5.0 * ratio) * SCALE_FACTOR;
    
	cpVect a_pos = cpvmult(body_a->p, SCALE_FACTOR);
	cpVect b_pos = cpvmult(body_b->p, SCALE_FACTOR);
        
	drawCircle(a_pos, radius1, radius1*2+3);
	drawCircle(b_pos, radius2, radius2*2+3);
        
    float sx = cpCCNodeImpl.xScaleRatio;
    float sy = cpCCNodeImpl.yScaleRatio;
    
    a_pos.x *= sx; a_pos.y *= sy;
    b_pos.x *= sx; b_pos.y *= sy;
	
	cpVect a = cpv(0,radius1);
	cpVect b = cpv(0,radius2);
	cpVect c = cpv(0,-radius1);
	cpVect d = cpv(0,-radius2);
	
	float dx = a_pos.x - b_pos.x;
	float dy = a_pos.y - b_pos.y;
	cpVect rotation = cpvforangle(atan2f(dy,dx));	
	
	a = cpvadd(a_pos, cpvrotate(a,rotation));
	b = cpvadd(b_pos, cpvrotate(b,rotation));
	c = cpvadd(a_pos, cpvrotate(c,rotation));
	d = cpvadd(b_pos, cpvrotate(d,rotation));
	
	float array[8];
	array[0] = a.x;
	array[1] = a.y;
	array[4] = c.x;
	array[5] = c.y;
    
	if (ratio >= 0)
	{
		array[2] = b.x;
		array[3] = b.y;
		array[6] = d.x;
		array[7] = d.y;
	}
	else 
	{
		array[2] = d.x;
		array[3] = d.y;
		array[6] = b.x;
		array[7] = b.y;
	}
    
#if (COCOS2D_VERSION < 0x00020000)
	glVertexPointer(2, GL_FLOAT, 0, array);
#else
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, array);
    CC_INCREMENT_GL_DRAWS(1);
#endif
    
	glDrawArrays(GL_LINES, 0, 4);
}

static void drawPulleyJoint(cpPulleyJoint* joint, cpBody* body_a, cpBody* body_b)
{
	cpBody *body_c = joint->c;
	
	cpVect a = cpvmult(cpBodyLocal2World(body_a, joint->anchr1), SCALE_FACTOR);
	cpVect b = cpvmult(cpBodyLocal2World(body_b, joint->anchr2), SCALE_FACTOR);
	cpVect c = cpvmult(cpBodyLocal2World(body_c, joint->anchr3a), SCALE_FACTOR);
	cpVect d = cpvmult(cpBodyLocal2World(body_c, joint->anchr3b), SCALE_FACTOR);
    
    float sx = cpCCNodeImpl.xScaleRatio;
    float sy = cpCCNodeImpl.yScaleRatio;
	
	float array[] = {a.x*sx,a.y*sy,c.x*sx,c.y*sy,b.x*sx,b.y*sy,d.x*sx,d.y*sy};
	
#if (COCOS2D_VERSION < 0x00020000)
	glVertexPointer(2, GL_FLOAT, 0, array);
#else
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, array);
    CC_INCREMENT_GL_DRAWS(2);
#endif
    
    glDrawArrays(GL_POINTS, 0, 4);
	glDrawArrays(GL_LINES, 0, 4);
}

void cpConstraintNodeEfficientDraw(cpConstraint *constraint)
{
    cpBody *body_a = constraint->a;
	cpBody *body_b = constraint->b;

    const cpConstraintClass *klass = constraint->CP_PRIVATE(klass);
    
	if(klass == cpPinJointGetClass())
		drawPinJoint((cpPinJoint*)constraint, body_a, body_b); 
	else if(klass == cpSlideJointGetClass())
		drawSlideJoint((cpSlideJoint*)constraint, body_a, body_b);  
	else if(klass == cpPivotJointGetClass())
		drawPivotJoint((cpPivotJoint*)constraint, body_a, body_b); 
	else if(klass == cpGrooveJointGetClass())
		drawGrooveJoint((cpGrooveJoint*)constraint, body_a, body_b); 
	else if (klass == cpSimpleMotorGetClass())
		drawMotorJoint((cpSimpleMotor*)constraint, body_a, body_b); 
	else if (klass == cpGearJointGetClass())
		drawGearJoint((cpGearJoint*)constraint, body_a, body_b); 
	else if(klass == cpDampedSpringGetClass())
		drawSpringJoint((cpDampedSpring *)constraint, body_a, body_b); 
	else if (klass == cpPulleyJointGetClass())
		drawPulleyJoint((cpPulleyJoint*)constraint, body_a, body_b);
}

#if (COCOS2D_VERSION < 0x00020000)
void cpConstraintNodePreDrawState()
{
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisable(GL_TEXTURE_2D);
}
#else
void cpConstraintNodePreDrawState(CCGLProgram* shader)
{
	[shader use];
	[shader setUniformsForBuiltins];
    ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);
}
#endif

void cpConstraintNodePostDrawState()
{
#if (COCOS2D_VERSION < 0x00020000)
    glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
#else
#endif
}

void cpConstraintNodeDraw(cpConstraint *constraint)
{
#if (COCOS2D_VERSION < 0x00020000)
    cpConstraintNodePreDrawState();
#else
    cpConstraintNodePreDrawState([[CCShaderCache sharedShaderCache] programForKey:kCCShader_Position_uColor]);    
#endif
    cpConstraintNodeEfficientDraw(constraint);
    cpConstraintNodePostDrawState();
}

@interface cpConstraintNode(PrivateMethods)
- (BOOL) containsPoint:(cpVect)pt padding:(cpFloat)padding constraint:(cpConstraint*)constraint;
@end

@implementation cpConstraintNode
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

@synthesize constraint = _constraint;
@synthesize color = _color;
@synthesize opacity = _opacity;
@synthesize pointSize = _pointSize;
@synthesize lineWidth = _lineWidth;
@synthesize smoothDraw = _smoothDraw;
@synthesize autoFreeConstraint = _autoFreeConstraint;
@synthesize spaceManager = _spaceManager;

+ (id) nodeWithConstraint:(cpConstraint*)c
{
	return [[[self alloc] initWithConstraint:c] autorelease];
}

- (id) initWithConstraint:(cpConstraint*)c
{
	[super init];
	
	_constraint = c;
	_color = ccBLACK;
	_opacity = 255;
	_pointSize = 3;
	_lineWidth = 1;
	_smoothDraw = YES;
	_constraint->data = self;
    
#if (COCOS2D_VERSION >= 0x00020000)  
    self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_Position_uColor];
    
    _colorLocation = glGetUniformLocation(self.shaderProgram->_program, "u_color");
    _pointSizeLocation = glGetUniformLocation(self.shaderProgram->_program, "u_pointSize");
#endif
	
	return self;
}

- (void) dealloc
{
	if (_autoFreeConstraint)
		[_spaceManager removeAndFreeConstraint:_constraint];
	[super dealloc];
}

- (BOOL) containsPoint:(cpVect)pt padding:(cpFloat)padding
{
	return [self containsPoint:pt padding:padding constraint:_constraint];
}

- (BOOL) containsPoint:(cpVect)pt padding:(cpFloat)padding constraint:(cpConstraint*)constraint
{
	BOOL contains = NO;
	cpBody *body_a = constraint->a;
	cpBody *body_b = constraint->b;
	
	cpVect apt, bpt;
	
	const cpConstraintClass *klass = constraint->CP_PRIVATE(klass);
	
	if(klass == cpPinJointGetClass())
	{
		cpPinJoint *joint = (cpPinJoint*)constraint;
		
		apt = cpvmult(cpBodyLocal2World(body_a, joint->anchr1), SCALE_FACTOR);
		bpt = cpvmult(cpBodyLocal2World(body_b, joint->anchr2), SCALE_FACTOR);
	}
	else if(klass == cpSlideJointGetClass())
	{
		cpSlideJoint *joint = (cpSlideJoint*)constraint;
		
		apt = cpvmult(cpBodyLocal2World(body_a, joint->anchr1), SCALE_FACTOR);
		bpt = cpvmult(cpBodyLocal2World(body_b, joint->anchr2), SCALE_FACTOR);
	}
	else if(klass == cpPivotJointGetClass())
	{
		cpPivotJoint* joint = (cpPivotJoint*)constraint;
		
		apt = cpvmult(cpBodyLocal2World(body_a, joint->anchr1), SCALE_FACTOR);
		bpt = cpvmult(cpBodyLocal2World(body_b, joint->anchr2), SCALE_FACTOR);
	}
	else if(klass == cpGrooveJointGetClass())
	{
		cpGrooveJoint *joint = (cpGrooveJoint*)constraint;
		
		apt = cpvmult(cpBodyLocal2World(body_a, joint->grv_a), SCALE_FACTOR);
		bpt = cpvmult(cpBodyLocal2World(body_a, joint->grv_b), SCALE_FACTOR);
	}
	//else if(klass == cpBreakableJointGetClass())
	//{
		//This works... but it uses the assumption that data is a cpConstraintNode
		//cpBreakableJoint *joint = (cpBreakableJoint*)constraint;
		//return [(cpConstraintNode*)joint->delegate->data containsPoint:pt padding:padding constraint:joint->delegate];
	//}
	else if (klass == cpSimpleMotorGetClass())
	{
		apt = bpt = cpvmult(body_a->p, SCALE_FACTOR);
	}
	else if (klass == cpGearJointGetClass())
	{
		cpGearJoint *joint = (cpGearJoint*)constraint;
		
		cpFloat ratio = joint->ratio;
		
		cpFloat radius1 = 5.0 / ratio * SCALE_FACTOR;
		cpFloat radius2 = 5.0 * ratio * SCALE_FACTOR;

		// pad it out by radius (half diameter as the biggest gear...)
		padding += (radius1 > radius2) ? radius1 : radius2;
		
		apt = cpvmult(body_a->p, SCALE_FACTOR);
		bpt = cpvmult(body_b->p, SCALE_FACTOR);
	}
	else if(klass == cpDampedSpringGetClass())
	{
		padding += 20; // 20 is width of spring
		cpDampedSpring *joint = (cpDampedSpring*)constraint;
		
		apt = cpvmult(cpBodyLocal2World(body_a, joint->anchr1), SCALE_FACTOR);
		bpt = cpvmult(cpBodyLocal2World(body_b, joint->anchr2), SCALE_FACTOR);
	}
	else
		return NO;
		
	cpFloat width = (_pointSize > _lineWidth) ? _pointSize : _lineWidth;
	width += padding*2*SCALE_FACTOR;
	
	cpFloat length = cpvlength(cpvsub(bpt, apt)) + padding*2*SCALE_FACTOR;
	cpVect halfpt = cpvadd(apt, cpvmult(cpvsub(bpt, apt), 0.5f));
	
	/* Algorithm Explained
	 
		At this point we have 2 pts (in some cases they are the same point).
		From these two points we construct a flat (rotation zero) rectangle, we
		then rotate the point in question by the same rotation it would take to make 
		the actual bounding rect "flat". Rotation is always around the center (halfpt)
		of the rect.
	 */
	
	float dx = apt.x - bpt.x;
	float dy = apt.y - bpt.y;
	float rotation = atan2f(dy,dx);	
		
	//recalc pt (non-rotated)
	pt = cpvadd(halfpt, cpvrotate(cpvsub(pt,halfpt), cpvforangle(-rotation)));
	
	contains = CGRectContainsPoint(CGRectMake(halfpt.x-length/2.0, halfpt.y-width/2.0, length, width), CGPointMake(pt.x,pt.y));
	
	return contains;
}

-(void)draw
{	
    glLineWidth(_lineWidth * SCALE_FACTOR);

#if (COCOS2D_VERSION < 0x00020000)
	glColor4ub(_color.r, _color.g, _color.b, _opacity);
	glPointSize(_pointSize * SCALE_FACTOR);
	if (_smoothDraw && _lineWidth <= 1) //OpelGL ES doesn't support smooth lineWidths > 1
	{
		glEnable(GL_LINE_SMOOTH);
		glEnable(GL_POINT_SMOOTH);
	}
	else
	{
		glDisable(GL_LINE_SMOOTH);
		glDisable(GL_POINT_SMOOTH);
	}
#else
    cpConstraintNodePreDrawState(self.shaderProgram);
    ccColor4F color = ccc4FFromccc3B(_color);
    color.a = _opacity;
    [self.shaderProgram setUniformLocation:_colorLocation with4fv:(GLfloat*) &color.r count:1];
    [self.shaderProgram setUniformLocation:_pointSizeLocation withF1:_pointSize];
#endif
    
	if( _opacity != 255 )
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
				
    cpConstraintNodeDraw(_constraint);
	
	if( _opacity != 255 )
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
}

@end
