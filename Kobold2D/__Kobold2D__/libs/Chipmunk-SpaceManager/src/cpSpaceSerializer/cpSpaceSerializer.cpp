//
//  cpSpaceSerializer.cpp
//
//  Created by Robert Blackwood on 4/8/10.
//  Copyright 2010 Mobile Bros. All rights reserved.
//

#include "cpSpaceSerializer.h"
#include <sstream>

struct cpSpaceSerializerContext
{
    cpSpaceSerializer *serializer;
    TiXmlNode *node;
};

static bool stringEquals(const char* s1, const char* s2)
{
	return (strcmp(s1, s2) == 0);
}

static bool elementEquals(TiXmlNode *elm, const char* value)
{
	return stringEquals(elm->Value(), value);
}

template <typename T>
static T stringToValue(const char* str)
{
	T value(0);
	std::istringstream stream(str);
	stream >> value;
	
	return value;
}

template <typename T>
static T getAttribute(TiXmlElement *elm, const char* name)
{
	return stringToValue<T>(elm->Attribute(name));
}

template <typename T>
static T createValue(const char* name, TiXmlElement* elm)
{
	T value(0);
	TiXmlNode *node = elm->FirstChild(name);

	if (node)
	{	
		TiXmlNode *text = node->FirstChild();
		if (text)
		{            
			if (elementEquals(text, "INF"))
				value = static_cast<T>(INFINITY);
			else
				value = stringToValue<T>(text->Value());			
		}
	}
	
	return value;
}

template <typename T>
static void setAttribute(TiXmlElement *elm, const char* name, T value)
{
	std::ostringstream stream;
	stream << value;
	
	elm->SetAttribute(name, stream.str().c_str());
}

template <typename T>
static TiXmlElement *createValueElm(const char* name, T value)
{
	TiXmlElement *elm = new TiXmlElement(name);
	
	if (value != INFINITY)
	{
		std::ostringstream stream;
		stream << value;
		elm->LinkEndChild(new TiXmlText(stream.str().c_str()));
	}
	else
		elm->LinkEndChild(new TiXmlText("INF"));
	
	return elm;
}

static void writeConstraint(cpConstraint *constraint, void *data)
{
    cpSpaceSerializerContext *context = (cpSpaceSerializerContext*)data;
    context->node->LinkEndChild(context->serializer->createConstraintElm(constraint));
}

static void writeShape(cpShape *shape, void *data)
{
    cpSpaceSerializerContext *context = (cpSpaceSerializerContext*)data;
    context->node->LinkEndChild(context->serializer->createShapeElm(shape)); 
}

cpSpace* cpSpaceSerializer::load(const char* filename)
{
	return load(cpSpaceNew(), filename);
}

cpSpace* cpSpaceSerializer::load(cpSpace *space, const char* filename)
{
	if (!_doc.LoadFile(filename))
		return space;
	
	//Grab our space
	TiXmlElement *root = _doc.FirstChildElement("space");
	if (!root)
		return space;

    _space = space;

    //Initialize
    _bodyMap.clear();
    _shapeMap.clear();

    //A body id of zero is the space's static body
    _bodyMap[0] = space->staticBody;
	
	space->iterations = createValue<int>("iterations", root);
	space->gravity = createPoint("gravity", root);	
	space->damping = createValue<cpFloat>("damping", root);
	
	TiXmlElement *child = root->FirstChildElement("shape");
	
	//Read Shapes
	while (child)
	{
		//attempt a shape
		cpShape *shape = createShape(child);
		if (shape)
		{
			//This should not happen like this, need to reflect reality -rkb
            if (shape->body->m != INFINITY && !cpSpaceContainsBody(space, shape->body))
				cpSpaceAddBody(space, shape->body);

            cpSpaceAddShape(space, shape);
		}
		
		//Next!
		child = child->NextSiblingElement("shape");
	}
	
	//Read Constraints
	child = root->FirstChildElement("constraint");
	while (child)
	{
		//else attempt a constraint
		cpConstraint *constraint = createConstraint(child);
		if (constraint)
			cpSpaceAddConstraint(space, constraint);
		
		child = child->NextSiblingElement("constraint");
    }
	
	return space;
}

cpShape *cpSpaceSerializer::createShape(TiXmlElement *elm)
{
	cpShape *shape;
	
	const char* type = elm->Attribute("type");
	
	if (stringEquals(type, "circle"))
		shape = createCircle(elm);
	else if (stringEquals(type, "segment"))
		shape = createSegment(elm);
	else if (stringEquals(type, "poly"))
		shape = createPoly(elm);
	else
		return NULL;
	
	CPSS_ID id = createValue<CPSS_ID>("id", elm);
    _shapeMap[id] = shape;
	
	shape->sensor = createValue<int>("sensor", elm);
	shape->e = createValue<cpFloat>("e", elm);
	shape->u = createValue<cpFloat>("u", elm);
	shape->surface_v = createPoint("surface_v", elm);
	shape->collision_type = createValue<cpCollisionType>("collision_type", elm);
	shape->group = createValue<cpGroup>("group", elm);
	shape->layers = createValue<cpLayers>("layers", elm);
	
	if (delegate)
	{
		if (!delegate->reading(shape, id))
		{
            if (shape->body != _space->staticBody)
                cpBodyFree(shape->body);

            cpShapeFree(shape);
			shape = NULL;
		}
	}
	return shape;
}

cpShape *cpSpaceSerializer::createCircle(TiXmlElement *elm)
{
	cpShape *shape;
	cpBody *body = createBody(elm);
	
	cpFloat radius = createValue<cpFloat>("radius", elm);
	cpVect offset = createPoint("offset", elm);
	
	shape = cpCircleShapeNew(body, radius, offset);
	
	return shape;
}

cpShape *cpSpaceSerializer::createSegment(TiXmlElement *elm)
{
	cpShape *shape;
	cpBody *body = createBody(elm);
	
	cpVect a = createPoint("a", elm);
	cpVect b = createPoint("b", elm);
	cpFloat radius = createValue<cpFloat>("radius", elm);
	
	shape = cpSegmentShapeNew(body, a, b, radius);
	
	return shape;
}

cpShape *cpSpaceSerializer::createPoly(TiXmlElement *elm)
{
	cpShape *shape = NULL;
	cpBody *body = createBody(elm);
	
	TiXmlElement *vertsElm = elm->FirstChildElement("verts");
	int numVerts = getAttribute<int>(vertsElm, "numVerts");

	cpVect *verts = (cpVect*)malloc(sizeof(cpVect)*numVerts);
	
	TiXmlElement *vertElm = vertsElm->FirstChildElement("vert");
	
	int i;
	for (i = 0; i < numVerts && vertElm; i++)
	{
		verts[i] = cpv(getAttribute<cpFloat>(vertElm, "x"), getAttribute<cpFloat>(vertElm, "y"));
		vertElm = vertElm->NextSiblingElement("vert");
	}
	
	cpVect offset = createPoint("offset", elm);
	
	shape = cpPolyShapeNew(body, i, verts, offset);
	
	return shape;
}

cpBody *cpSpaceSerializer::createBody(TiXmlElement *elm)
{	
	TiXmlElement *bodyElm;;
	cpBody *body;
	
	CPSS_ID b_id = createValue<CPSS_ID>("body_id", elm);
	BodyMap::iterator itr = _bodyMap.find(b_id);
	
	//If it doesn't exist, try to create it
	if (itr == _bodyMap.end())
	{
		bodyElm = elm->FirstChildElement("body");
		
		if (bodyElm)
		{
			cpFloat mass = createValue<cpFloat>("mass", bodyElm);
			cpFloat inertia = createValue<cpFloat>("inertia", bodyElm);
			
            if (mass == INFINITY)
                body = cpBodyNewStatic();
            else
                body = cpBodyNew(mass, inertia);
			
			body->p = createPoint("p", bodyElm);
			body->v = createPoint("v", bodyElm);
			body->f = createPoint("f", bodyElm);
			body->w = createValue<cpFloat>("w", bodyElm);
			body->t = createValue<cpFloat>("t", bodyElm);
            cpBodySetAngle(body, createValue<cpFloat>("a", bodyElm));
			
			_bodyMap[b_id] = body;

            if (delegate && b_id != 0)
            {
                if (!delegate->reading(body, b_id))
                {
                    cpBodyFree(body);
                    body = NULL;
                }
            }
		}
		else
			body = cpBodyNewStatic(); //Fail case, should throw or something
	}
	else 
		body = itr->second; //Else grab it
	
	return body;
}

void cpSpaceSerializer::createBodies(TiXmlElement *elm, cpBody **a, cpBody **b)
{
	CPSS_ID id_a = createValue<CPSS_ID>("body_a_id", elm);
	CPSS_ID id_b = createValue<CPSS_ID>("body_b_id", elm);
	
	*a = NULL;
	*b = NULL;
	
	BodyMap::iterator itr;
	
	itr = _bodyMap.find(id_a);
	if (itr != _bodyMap.end())
		*a = itr->second;
	
	itr = _bodyMap.find(id_b);
	if (itr != _bodyMap.end())
		*b = itr->second;
}

cpConstraint *cpSpaceSerializer::createConstraint(TiXmlElement *elm)
{
	cpConstraint *constraint = NULL;
	
	const char* type = elm->Attribute("type");
	
	if (stringEquals(type, "pin"))
		constraint = createPinJoint(elm);
	else if (stringEquals(type, "slide"))
		constraint = createSlideJoint(elm);
	else if (stringEquals(type, "pivot"))
		constraint = createPivotJoint(elm);
	else if (stringEquals(type, "groove"))
		constraint = createGrooveJoint(elm);
	else if (stringEquals(type, "motor"))
		constraint = createMotorJoint(elm);
	else if (stringEquals(type, "gear"))
		constraint = createGearJoint(elm);
	else if (stringEquals(type, "spring"))
		constraint = createSpringJoint(elm);
	else if (stringEquals(type, "rotaryLimit"))
		constraint = createRotaryLimitJoint(elm);
	else if (stringEquals(type, "ratchet"))
		constraint = createRatchetJoint(elm);
	else if (stringEquals(type, "rotarySpring"))
		constraint = createRotarySpringJoint(elm);
	else
		return NULL;
	
	CPSS_ID id = createValue<CPSS_ID>("id", elm);
	constraint->maxForce = createValue<cpFloat>("maxForce", elm);
	constraint->errorBias = createValue<cpFloat>("errorBias", elm);
	constraint->maxBias = createValue<cpFloat>("maxBias", elm);
	
	if (delegate)
	{
		if (!delegate->reading(constraint, id))
		{
			cpConstraintFree(constraint);
			constraint = NULL;
		}
	}
	
	return constraint;
}

cpConstraint *cpSpaceSerializer::createPinJoint(TiXmlElement *elm)
{
	cpConstraint *constraint;
	
	cpVect anchr1 = createPoint("anchr1", elm);
	cpVect anchr2 = createPoint("anchr2", elm);
	
	cpBody *a;
	cpBody *b;
	createBodies(elm, &a, &b);
	
	constraint = cpPinJointNew(a, b, anchr1, anchr2);
	
	((cpPinJoint*)constraint)->dist = createValue<cpFloat>("dist", elm);
	//((cpPinJoint*)constraint)->jnAcc = createValue<cpFloat>("jnAcc", elm);
	
	return constraint;
}

cpConstraint *cpSpaceSerializer::createSlideJoint(TiXmlElement *elm)
{
	cpConstraint *constraint;
	
	cpVect anchr1 = createPoint("anchr1", elm);
	cpVect anchr2 = createPoint("anchr2", elm);
	
	cpBody *a;
	cpBody *b;
	createBodies(elm, &a, &b);
	
	cpFloat min = createValue<cpFloat>("min", elm);
	cpFloat max = createValue<cpFloat>("max", elm);
	
	constraint = cpSlideJointNew(a, b, anchr1, anchr2, min, max);
	
	//((cpSlideJoint*)constraint)->jnAcc = createValue<cpFloat>("jnAcc", elm);
	
	return constraint;
}

cpConstraint *cpSpaceSerializer::createPivotJoint(TiXmlElement *elm)
{
	cpConstraint *constraint;

    cpBody *a;
    cpBody *b;
    createBodies(elm, &a, &b);
	
    if (elm->FirstChildElement("worldAnchor"))
    {
        cpVect worldPt = createPoint("worldAnchor", elm);

        constraint = cpPivotJointNew(a, b, worldPt);
    }
    else
    {
        cpVect anchr1 = createPoint("anchr1", elm);
        cpVect anchr2 = createPoint("anchr2", elm);

        constraint = cpPivotJointNew2(a, b, anchr1, anchr2);
    }
	
	//((cpPivotJoint*)constraint)->jAcc = createPoint("jAcc", elm);
	
	return constraint;
}

cpConstraint *cpSpaceSerializer::createGrooveJoint(TiXmlElement *elm)
{
	cpConstraint *constraint;
	
	cpVect grv_a = createPoint("grv_a", elm);
	cpVect grv_b = createPoint("grv_b", elm);
	cpVect anchr2 = createPoint("anchr2", elm);
	
	cpBody *a;
	cpBody *b;
	createBodies(elm, &a, &b);
	
	constraint = cpGrooveJointNew(a, b, grv_a, grv_b, anchr2);
	
	//((cpGrooveJoint*)constraint)->jAcc = createPoint("jAcc", elm);
	//((cpGrooveJoint*)constraint)->jMaxLen = createValue<cpFloat>("jMaxLen", elm);
	
	return constraint;
}

cpConstraint *cpSpaceSerializer::createMotorJoint(TiXmlElement *elm)
{
	cpConstraint *constraint;
	
	cpBody *a;
	cpBody *b;
	createBodies(elm, &a, &b);
	
	cpFloat rate = createValue<cpFloat>("rate", elm);
	
	constraint = cpSimpleMotorNew(a, b, rate);
	
	//((cpSimpleMotor*)constraint)->jMax = createValue<cpFloat>("jMax", elm);
	
	return constraint;
}

cpConstraint *cpSpaceSerializer::createGearJoint(TiXmlElement *elm)
{
	cpConstraint *constraint;
	
	cpBody *a;
	cpBody *b;
	createBodies(elm, &a, &b);
	
	cpFloat phase = createValue<cpFloat>("phase", elm);
	cpFloat ratio = createValue<cpFloat>("ratio", elm);
	
	constraint = cpGearJointNew(a, b, phase, ratio);
	
	//((cpGearJoint*)constraint)->jAcc = createValue<cpFloat>("jAcc", elm);
	
	return constraint;
}

cpConstraint *cpSpaceSerializer::createSpringJoint(TiXmlElement *elm)
{
	cpConstraint *constraint;
	
	cpVect anchr1 = createPoint("anchr1", elm);
	cpVect anchr2 = createPoint("anchr2", elm);
	
	cpBody *a;
	cpBody *b;
	createBodies(elm, &a, &b);
	
	cpFloat restLen = createValue<cpFloat>("restLength", elm);
	cpFloat stiffness = createValue<cpFloat>("stiffness", elm);
	cpFloat damping = createValue<cpFloat>("damping", elm);
	
	constraint = cpDampedSpringNew(a, b, anchr1, anchr2, restLen, stiffness, damping);
	
	return constraint;
}

cpConstraint *cpSpaceSerializer::createRotaryLimitJoint(TiXmlElement *elm)
{	
	cpConstraint *constraint;
	
	cpBody *a;
	cpBody *b;
	createBodies(elm, &a, &b);
	
	cpFloat min = createValue<cpFloat>("min", elm);
	cpFloat max = createValue<cpFloat>("max", elm);
	
	constraint = cpRotaryLimitJointNew(a, b, min, max);
	
	//((cpRotaryLimitJoint*)constraint)->jAcc = createValue<cpFloat>("jAcc", elm);
	
	return constraint;
}

cpConstraint *cpSpaceSerializer::createRatchetJoint(TiXmlElement *elm)
{
	cpConstraint *constraint;
	
	cpBody *a;
	cpBody *b;
	createBodies(elm, &a, &b);
	
	cpFloat phase = createValue<cpFloat>("phase", elm);
	cpFloat ratchet = createValue<cpFloat>("ratchet", elm);
	
	constraint = cpRatchetJointNew(a, b, phase, ratchet);
	
	((cpRatchetJoint*)constraint)->angle = createValue<cpFloat>("angle", elm);
	//((cpRatchetJoint*)constraint)->jAcc = createValue<cpFloat>("jAcc", elm);
	
	return constraint;
}

cpConstraint *cpSpaceSerializer::createRotarySpringJoint(TiXmlElement *elm)
{
	cpConstraint *constraint;
	
	cpBody *a;
	cpBody *b;
	createBodies(elm, &a, &b);
	
	cpFloat restAngle = createValue<cpFloat>("restAngle", elm);
	cpFloat stiffness = createValue<cpFloat>("stiffness", elm);
	cpFloat damping = createValue<cpFloat>("damping", elm);
	
	constraint = cpDampedRotarySpringNew(a, b, restAngle, stiffness, damping);
	
	return constraint;
}


cpVect cpSpaceSerializer::createPoint(const char* name, TiXmlElement *elm)
{
	TiXmlElement *ptElm = elm->FirstChildElement(name);
	cpVect pt = cpvzero;
	
	if (ptElm)
	{
		pt.x = getAttribute<cpFloat>(ptElm, "x");
		pt.y = getAttribute<cpFloat>(ptElm, "y");
	}
	
	return pt;
}

bool cpSpaceSerializer::save(cpSpace* space, const char* filename)
{
    _space = space;

    //Initialize
    _bodyMap.clear();

    //This id is always the staticBody of the space
    _bodyMap[0] = space->staticBody;

	TiXmlElement *root = new TiXmlElement("space");
	_doc.LinkEndChild(root);
	
	root->LinkEndChild(createValueElm("iterations", space->iterations));
	root->LinkEndChild(createPointElm("gravity", space->gravity));	
	root->LinkEndChild(createValueElm("damping", space->damping));
	
    cpSpaceSerializerContext context = {this, root};
    
	//Write out all types of shapes
	cpSpaceEachShape(space, writeShape, &context);

    //Write out constraints
    cpSpaceEachConstraint(space, writeConstraint, &context);
	
	return _doc.SaveFile(filename);
}

TiXmlElement *cpSpaceSerializer::createShapeElm(cpShape *shape)
{
	TiXmlElement *elm; 

	//Generate id
	CPSS_ID id, body_id;
	if (delegate)
	{
		id = delegate->makeId(shape);
		body_id = delegate->makeId(shape->body);
		
		//Tell delegate we're about to write
		delegate->writing(shape, id);        
		delegate->writing(shape->body, body_id);
	}
	else
	{
		id = CPSS_DEFAULT_MAKE_ID(shape);
		body_id = CPSS_DEFAULT_MAKE_ID(shape->body);
	}

    //If body is the staticBody zero is reserved
    if (shape->body == _space->staticBody)
        body_id = 0;
	
	//Specific
	switch(shape->CP_PRIVATE(klass)->type)
	{
		case CP_CIRCLE_SHAPE:
			elm = createCircleElm(shape);
			break;
		case CP_SEGMENT_SHAPE:
			elm = createSegmentElm(shape);
			break;
		case CP_POLY_SHAPE:
			elm = createPolyElm(shape);
			break;
		default:
			elm = NULL;
			break;
	}

	if (elm)
	{
		//Generic Properties	
		elm->LinkEndChild(createValueElm("id", id));
		elm->LinkEndChild(createValueElm("body_id", body_id));
		
		elm->LinkEndChild(createValueElm("sensor", shape->sensor));
		elm->LinkEndChild(createValueElm("e", shape->e));
		elm->LinkEndChild(createValueElm("u", shape->u));
		elm->LinkEndChild(createPointElm("surface_v", shape->surface_v));
		elm->LinkEndChild(createValueElm("collision_type", shape->collision_type));
		elm->LinkEndChild(createValueElm("group", shape->group));
		elm->LinkEndChild(createValueElm("layers", shape->layers));

		//Write out the body (if not already)
		elm->LinkEndChild(createBodyElm(shape->body));
	}
	
	return elm;
}

TiXmlElement *cpSpaceSerializer::createCircleElm(cpShape *shape)
{
	TiXmlElement *elm = new TiXmlElement("shape");
	setAttribute(elm, "type", "circle");
	
	cpCircleShape *circle = reinterpret_cast<cpCircleShape*>(shape);
	
	elm->LinkEndChild(createPointElm("offset", circle->c));
	elm->LinkEndChild(createValueElm("radius", circle->r));	
	
	return elm;
}

TiXmlElement *cpSpaceSerializer::createSegmentElm(cpShape *shape)
{
	TiXmlElement *elm = new TiXmlElement("shape");
	setAttribute(elm, "type", "segment");
	
	cpSegmentShape *segment = reinterpret_cast<cpSegmentShape*>(shape);
	
	elm->LinkEndChild(createPointElm("a", segment->a));
	elm->LinkEndChild(createPointElm("b", segment->b));
	elm->LinkEndChild(createValueElm("radius", segment->r));
	
	return elm;
}

TiXmlElement *cpSpaceSerializer::createPolyElm(cpShape *shape)
{
	TiXmlElement *elm = new TiXmlElement("shape");
	setAttribute(elm, "type", "poly");

	TiXmlElement *verts = new TiXmlElement("verts");
	cpPolyShape *poly = reinterpret_cast<cpPolyShape*>(shape);
	
	setAttribute(verts, "numVerts", poly->numVerts);

	elm->LinkEndChild(verts);
	for (int i = 0; i < poly->numVerts; i++)
		verts->LinkEndChild(createPointElm("vert", poly->verts[i]));

	return elm;
}

TiXmlElement *cpSpaceSerializer::createBodyElm(cpBody *body)
{
	TiXmlElement *elm = new TiXmlElement("body");
	
	CPSS_ID id;

    if (delegate)
	{
		id = delegate->makeId(body);
		delegate->writing(body, id);
	}
    else
		id = CPSS_DEFAULT_MAKE_ID(body);


    BodyMap::iterator itr = _bodyMap.find(id);

    //It hasn't been written yet, so write it, but not the staticBody
    if (itr == _bodyMap.end() && body != _space->staticBody)
    {
        elm->LinkEndChild(createValueElm("id", id));
        elm->LinkEndChild(createValueElm("mass", body->m));
        elm->LinkEndChild(createValueElm("inertia", body->i));
        elm->LinkEndChild(createPointElm("p", body->p));
        elm->LinkEndChild(createPointElm("v", body->v));
        elm->LinkEndChild(createPointElm("f", body->f));
        elm->LinkEndChild(createValueElm("a", body->a));
        elm->LinkEndChild(createValueElm("w", body->w));
        elm->LinkEndChild(createValueElm("t", body->t));

        _bodyMap[id] = body;
    }

	return elm;
}

TiXmlElement *cpSpaceSerializer::createConstraintElm(cpConstraint* constraint)
{
	TiXmlElement *elm;
	
	CPSS_ID id, body_a_id, body_b_id;
	if (delegate)
	{
		id = delegate->makeId(constraint);
		delegate->writing(constraint, id);
		
		body_a_id = delegate->makeId(constraint->a);
		body_b_id = delegate->makeId(constraint->b);
	}
	else
	{
		id = CPSS_DEFAULT_MAKE_ID(constraint);
		body_a_id = CPSS_DEFAULT_MAKE_ID(constraint->a);
		body_b_id = CPSS_DEFAULT_MAKE_ID(constraint->b);
	}
    
    //Correct id's for staticBody
    if (constraint->a == _space->staticBody)
        body_a_id = 0;
    if (constraint->b == _space->staticBody)
        body_b_id = 0;
    
	//Specific	
	const cpConstraintClass *klass = constraint->CP_PRIVATE(klass);
	
	if(klass == cpPinJointGetClass())
		elm = createPinJointElm((cpPinJoint*)constraint);
	else if(klass == cpSlideJointGetClass())
		elm = createSlideJointElm((cpSlideJoint*)constraint);
	else if(klass == cpPivotJointGetClass())
		elm = createPivotJointElm((cpPivotJoint*)constraint);
	else if(klass == cpGrooveJointGetClass())
		elm = createGrooveJointElm((cpGrooveJoint*)constraint);
	else if (klass == cpSimpleMotorGetClass())
		elm = createMotorJointElm((cpSimpleMotor*)constraint);
	else if (klass == cpGearJointGetClass())
		elm = createGearJointElm((cpGearJoint*)constraint);
	else if(klass == cpDampedSpringGetClass())
		elm = createSpringJointElm((cpDampedSpring*)constraint);
	else if(klass == cpRotaryLimitJointGetClass())
		elm = createRotaryLimitJointElm((cpRotaryLimitJoint*)constraint);
	else if(klass == cpRatchetJointGetClass())
		elm = createRatchetJointElm((cpRatchetJoint*)constraint);
	else if(klass == cpDampedRotarySpringGetClass())
		elm = createRotarySpringJointElm((cpDampedRotarySpring*)constraint);
	else
		elm = new TiXmlElement("unknown");

	//Generic
	elm->LinkEndChild(createValueElm("id", id));
	elm->LinkEndChild(createValueElm("body_a_id", body_a_id));
	elm->LinkEndChild(createValueElm("body_b_id", body_b_id));

	elm->LinkEndChild(createValueElm("maxForce", constraint->maxForce));
	elm->LinkEndChild(createValueElm("errorBias", constraint->errorBias));
	elm->LinkEndChild(createValueElm("maxBias", constraint->maxBias));	
	
	return elm;
}

TiXmlElement *cpSpaceSerializer::createPinJointElm(cpPinJoint *constraint)
{
	TiXmlElement *elm = new TiXmlElement("constraint");
	setAttribute(elm, "type", "pin");

	elm->LinkEndChild(createPointElm("anchr1", constraint->anchr1));
	elm->LinkEndChild(createPointElm("anchr2", constraint->anchr2));
	elm->LinkEndChild(createValueElm("dist", constraint->dist));
	elm->LinkEndChild(createValueElm("jnAcc", constraint->jnAcc));

	return elm;
}

TiXmlElement *cpSpaceSerializer::createSlideJointElm(cpSlideJoint *constraint)
{
	TiXmlElement *elm = new TiXmlElement("constraint");
	setAttribute(elm, "type", "slide");
	
	elm->LinkEndChild(createPointElm("anchr1", constraint->anchr1));
	elm->LinkEndChild(createPointElm("anchr2", constraint->anchr2));
	elm->LinkEndChild(createValueElm("min", constraint->min));
	elm->LinkEndChild(createValueElm("max", constraint->max));
	elm->LinkEndChild(createValueElm("jnAcc", constraint->jnAcc));

	return elm;	
}

TiXmlElement *cpSpaceSerializer::createPivotJointElm(cpPivotJoint *constraint)
{
	TiXmlElement *elm = new TiXmlElement("constraint");
	setAttribute(elm, "type", "pivot");
	
    elm->LinkEndChild(createPointElm("anchr1", constraint->anchr1));
    elm->LinkEndChild(createPointElm("anchr2", constraint->anchr2));
    cpVect wPt = cpBodyLocal2World(((cpConstraint*)(constraint))->a, constraint->anchr1);

    elm->LinkEndChild(createPointElm("worldAnchor", wPt));
    elm->LinkEndChild(createPointElm("jAcc", constraint->jAcc));

	return elm;
}

TiXmlElement *cpSpaceSerializer::createGrooveJointElm(cpGrooveJoint *constraint)
{
	TiXmlElement *elm = new TiXmlElement("constraint");
	setAttribute(elm, "type", "groove");

	elm->LinkEndChild(createPointElm("grv_a", constraint->grv_a));
	elm->LinkEndChild(createPointElm("grv_b", constraint->grv_b));
	elm->LinkEndChild(createPointElm("anchr2", constraint->anchr2));
	elm->LinkEndChild(createPointElm("jAcc", constraint->jAcc));
	//elm->LinkEndChild(createValueElm("jMaxLen", constraint->jMaxLen));

	return elm;
}

TiXmlElement *cpSpaceSerializer::createMotorJointElm(cpSimpleMotor *constraint)
{
	TiXmlElement *elm = new TiXmlElement("constraint");
	setAttribute(elm, "type", "motor");

	elm->LinkEndChild(createValueElm("rate", constraint->rate));
	//elm->LinkEndChild(createValueElm("jMax", constraint->jMax));
	
	return elm;
}

TiXmlElement *cpSpaceSerializer::createGearJointElm(cpGearJoint *constraint)
{
	TiXmlElement *elm = new TiXmlElement("constraint");
	setAttribute(elm, "type", "gear");
	
	elm->LinkEndChild(createValueElm("phase", constraint->phase));
	elm->LinkEndChild(createValueElm("ratio", constraint->ratio));
	elm->LinkEndChild(createValueElm("jAcc", constraint->jAcc));
	
	return elm;
}

TiXmlElement *cpSpaceSerializer::createSpringJointElm(cpDampedSpring *constraint)
{
	TiXmlElement *elm = new TiXmlElement("constraint");
	setAttribute(elm, "type", "spring");
	
	elm->LinkEndChild(createPointElm("anchr1", constraint->anchr1));
	elm->LinkEndChild(createPointElm("anchr2", constraint->anchr2));
	
	elm->LinkEndChild(createValueElm("restLength", constraint->restLength));
	elm->LinkEndChild(createValueElm("stiffness", constraint->stiffness));
	elm->LinkEndChild(createValueElm("damping", constraint->damping));
	
	return elm;
}

TiXmlElement *cpSpaceSerializer::createRotaryLimitJointElm(cpRotaryLimitJoint *constraint)
{
	TiXmlElement *elm = new TiXmlElement("constraint");
	setAttribute(elm, "type", "rotaryLimit");
	
	elm->LinkEndChild(createValueElm("min", constraint->min));
	elm->LinkEndChild(createValueElm("max", constraint->max));
	elm->LinkEndChild(createValueElm("jAcc", constraint->jAcc));
	
	return elm;
}

TiXmlElement *cpSpaceSerializer::createRatchetJointElm(cpRatchetJoint *constraint)
{
	TiXmlElement *elm = new TiXmlElement("constraint");
	setAttribute(elm, "type", "ratchet");

	elm->LinkEndChild(createValueElm("angle", constraint->angle));
	elm->LinkEndChild(createValueElm("phase", constraint->phase));
	elm->LinkEndChild(createValueElm("ratchet", constraint->ratchet));
	elm->LinkEndChild(createValueElm("jAcc", constraint->jAcc));
	
	return elm;
}

TiXmlElement *cpSpaceSerializer::createRotarySpringJointElm(cpDampedRotarySpring *constraint)
{
	TiXmlElement *elm = new TiXmlElement("constraint");
	setAttribute(elm, "type", "rotarySpring");
	
	elm->LinkEndChild(createValueElm("restAngle", constraint->restAngle));
	elm->LinkEndChild(createValueElm("stiffness", constraint->stiffness));
	elm->LinkEndChild(createValueElm("damping", constraint->damping));
	
	return elm;
}

TiXmlElement *cpSpaceSerializer::createPointElm(const char* name, cpVect pt)
{
	TiXmlElement *elm = new TiXmlElement(name);
	setAttribute(elm, "x", pt.x);
	setAttribute(elm, "y", pt.y);
	
	return elm;
}


