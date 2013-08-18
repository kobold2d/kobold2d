/* Copyright (c) 2010 Robert Blackwood
 * 
 * Based upon Box2d's b2PulleyJoint equations: 
 * Copyright (c) 2007 Erin Catto http://www.gphysics.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include <stdlib.h>
#include <math.h>

#include "chipmunk_private.h"
#include "constraints/util.h"
#include "cpPulleyJoint.h"

cpFloat cp_min_pulley_len = 0.5f;

// Pulley:
// length1 = norm(p1 - s1)
// length2 = norm(p2 - s2)
// C0 = (length1 + ratio * length2)_initial
// C = C0 - (length1 + ratio * length2) >= 0
// u1 = (p1 - s1) / norm(p1 - s1)
// u2 = (p2 - s2) / norm(p2 - s2)
// Cdot = -dot(u1, v1 + cross(w1, r1)) - ratio * dot(u2, v2 + cross(w2, r2))
// J = -[u1 cross(r1, u1) ratio * u2  ratio * cross(r2, u2)]
// K = J * invM * JT
//   = invMass1 + invI1 * cross(r1, u1)^2 + ratio^2 * (invMass2 + invI2 * cross(r2, u2)^2)
//
// Limit:
// C = maxLength - length
// u = (p - s) / norm(p - s)
// Cdot = -dot(u, v + cross(w, r))
// K = invMass + invI * cross(r, u)^2
// 0 <= impulse

static void
preStep(cpPulleyJoint *joint, cpFloat dt, cpFloat dt_inv)
{
	cpBody* b1 = joint->constraint.a;
	cpBody* b2 = joint->constraint.b;
	
	joint->r1 = cpvrotate(joint->anchr1, b1->rot);
	joint->r2 = cpvrotate(joint->anchr2, b2->rot);
    
	cpVect p1 = cpvadd(b1->p, joint->r1);
	cpVect p2 = cpvadd(b2->p, joint->r2);
    
	//Catto claimed that these needed to be "grounded" pts
	cpVect s1 = cpBodyLocal2World(joint->c, joint->anchr3a);
	cpVect s2 = cpBodyLocal2World(joint->c, joint->anchr3b);
    
	// Get the pulley axes.
	joint->u1 = cpvsub(p1, s1);
	joint->u2 = cpvsub(p2, s2);
    
	// Lengths
	cpFloat length1 = cpvlength(joint->u1);
	cpFloat length2 = cpvlength(joint->u2);
    
	// Check constraints
	joint->u1 = (length1 > .01) ? cpvmult(joint->u1, 1.0f/length1) : cpvzero;
	joint->u2 = (length2 > .01) ? cpvmult(joint->u2, 1.0f/length2) : cpvzero;
    
	// Compute 'C'
	cpFloat C = joint->constant - length1 - joint->ratio * length2;
    
	// Set state based on lengths
	joint->state = (C > 0.0f) ? 0 : 1;
	joint->limitState1 = (length1 < joint->max1) ? 0 : 1;
	joint->limitState2 = (length2 < joint->max2) ? 0 : 1;
    
	// Compute effective mass.
	cpFloat cr1u1 = cpvcross(joint->r1, joint->u1);
	cpFloat cr2u2 = cpvcross(joint->r2, joint->u2);
    
	// Set Mass Limits
	joint->limitMass1 = b1->m_inv + b1->i_inv * cr1u1 * cr1u1;
	joint->limitMass2 = b2->m_inv + b2->i_inv * cr2u2 * cr2u2;
	joint->pulleyMass = joint->limitMass1 + joint->ratio * joint->ratio * joint->limitMass2;
	
	// Check against evil
	//cpAssert(joint->limitMass1 != 0.0f, "Calculated Pulley Limit(1) is Zero");
	//cpAssert(joint->limitMass2 != 0.0f, "Calculated Pulley Limit(2) is Zero");
	//cpAssert(joint->pulleyMass != 0.0f, "Calculated Pulley Mass is Zero");
	
	// We want the inverse's
	joint->limitMass1 = 1.0f / joint->limitMass1;
	joint->limitMass2 = 1.0f / joint->limitMass2;
	joint->pulleyMass = 1.0f / joint->pulleyMass;
    
	// Reset accumulations, could also warm start here
	joint->jnAcc = 0.0f;
	joint->jnAccLim1 = 0.0f;
	joint->jnAccLim2 = 0.0f;
}

static void
applyCachedImpulse(cpPinJoint *joint, cpFloat dt_coef)
{
   //do nothing for now..
}

static void
applyImpulse(cpPulleyJoint *joint)
{
	cpBody* b1 = joint->constraint.a;
	cpBody* b2 = joint->constraint.b;
	cpVect r1 = joint->r1;
	cpVect r2 = joint->r2;
    
	// The magic and mystery below
	if (joint->state)
	{
		cpVect v1 = cpvadd(b1->v, cpv(-b1->w * r1.y, b1->w * r1.x));
		cpVect v2 = cpvadd(b2->v, cpv(-b2->w * r2.y, b2->w * r2.x));
        
		cpFloat Cdot = -cpvdot(joint->u1, v1) - joint->ratio * cpvdot(joint->u2, v2);
		cpFloat impulse = joint->pulleyMass * (-Cdot);
		cpFloat oldImpulse = joint->jnAcc;
		joint->jnAcc = cpfmax(0.0f, joint->jnAcc + impulse);
		impulse = joint->jnAcc - oldImpulse;
        
		cpVect P1 = cpvmult(joint->u1, -impulse);
		cpVect P2 = cpvmult(joint->u2, -joint->ratio * impulse);
		
		cpBodyApplyImpulse(b1, P1, r1);
		cpBodyApplyImpulse(b2, P2, r2);
	}
    
	if (joint->limitState1)
	{
		cpVect v1 = cpvadd(b1->v, cpv(-b1->w * r1.y, b1->w * r1.x));
        
		cpFloat Cdot = -cpvdot(joint->u1, v1);
		cpFloat impulse = -joint->limitMass1 * Cdot;
		cpFloat oldImpulse = joint->jnAccLim1;
		joint->jnAccLim1 = cpfmax(0.0f, joint->jnAccLim1 + impulse);
		impulse = joint->jnAccLim1 - oldImpulse;
        
		cpVect P1 = cpvmult(joint->u1, -impulse);
        
		cpBodyApplyImpulse(b1, P1, r1);
	}
    
	if (joint->limitState2)
	{	
		cpVect v2 = cpvadd(b2->v, cpv(-b2->w * r2.y, b2->w * r2.x));
        
		cpFloat Cdot = -cpvdot(joint->u2, v2);
		cpFloat impulse = -joint->limitMass2 * Cdot;
		cpFloat oldImpulse = joint->jnAccLim2;
		joint->jnAccLim2 = cpfmax(0.0f, joint->jnAccLim2 + impulse);
		impulse = joint->jnAccLim2 - oldImpulse;
        
		cpVect P2 = cpvmult(joint->u2, -impulse);
        
		cpBodyApplyImpulse(b2, P2, r2);
	}
}

static cpFloat
getImpulse(cpConstraint *joint)
{
	cpPulleyJoint* pulley = (cpPulleyJoint *)joint;
	
	//the sum?
	return cpfabs(pulley->jnAcc+pulley->jnAccLim1+pulley->jnAccLim2);
}

static const cpConstraintClass klass = {
	(cpConstraintPreStepImpl)preStep,
	(cpConstraintApplyCachedImpulseImpl)applyCachedImpulse,
	(cpConstraintApplyImpulseImpl)applyImpulse,
	(cpConstraintGetImpulseImpl)getImpulse,
};
CP_DefineClassGetter(cpPulleyJoint)


cpPulleyJoint *
cpPulleyJointAlloc(void)
{
	return (cpPulleyJoint *)malloc(sizeof(cpPulleyJoint));	
}

cpPulleyJoint *
cpPulleyJointInit(cpPulleyJoint *joint,
				  cpBody* a, cpBody* b, cpBody* c,
				  cpVect anchor1, cpVect anchor2,
				  cpVect anchor3a, cpVect anchor3b,
				  cpFloat ratio)
{
	cpConstraintInit((cpConstraint *)joint, &klass, a, b);
	
	joint->c = c;
	joint->anchr3a = anchor3a;
	joint->anchr3b = anchor3b;
	joint->anchr1 = anchor1;
	joint->anchr2 = anchor2;
	cpVect d1 = cpvsub(cpBodyLocal2World(a, anchor1), cpBodyLocal2World(c, anchor3a));
	cpVect d2 = cpvsub(cpBodyLocal2World(b, anchor2), cpBodyLocal2World(c, anchor3b));
	joint->dist1 = cpvlength(d1);
	joint->dist2 = cpvlength(d2);
	joint->ratio = ratio;
	
	//cpAssert(ratio != 0.0f, "Pulley Ratio is Zero");
	
	// Calculate max and constant
	joint->constant = joint->dist1 + ratio * joint->dist2;
	joint->max1 = joint->constant - ratio * cp_min_pulley_len;
	joint->max2 = (joint->constant - cp_min_pulley_len) / joint->ratio;
	
	// Initialize
	joint->jnAcc = 0.0f;
	joint->jnAccLim1 = 0.0f;
	joint->jnAccLim2 = 0.0f;
	
	return joint;
}

cpConstraint *
cpPulleyJointNew(cpBody* a, cpBody* b, cpBody* c,
				 cpVect anchor1, cpVect anchor2,
				 cpVect anchor3a, cpVect anchor3b,
				 cpFloat ratio)
{
	return (cpConstraint *)cpPulleyJointInit(cpPulleyJointAlloc(), a, b, c, anchor1, anchor2, anchor3a, anchor3b, ratio);
}

