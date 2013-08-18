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

#ifndef CPPULLEYJOINT_H
#define CPPULLEYJOINT_H

#ifdef __cplusplus
extern "C" {
#endif
    
    const cpConstraintClass *cpPulleyJointGetClass();
    
    extern cpFloat cp_min_pulley_len;
    extern cpFloat cp_min_correction;
    
    /*
     cpPulleyJoint
     
     -First two parameters (a, b) are the bodies on the ends of the "rope"
     -Third parameter (c) is the body the pulley is attached to
     -anchor1 and anchor2 are relative attach pts on the first two bodies
     -anchor3a and anchor3b are the points that represent the pulley rope's enter/exit
     -anchor1 --> anchor3a
     -anchor2 --> anchor3b
     -ratio simulates a block & tackle, one side extends faster than the other
     */
    typedef struct cpPulleyJoint
    {
        cpConstraint constraint;
        cpBody *c;
        cpVect anchr1, anchr2;
        cpVect anchr3a, anchr3b;
        
        cpFloat dist1, dist2;
        cpFloat max1, max2;
        
        cpFloat ratio;
        
        cpVect r1, r2;
        
        cpVect u1;
        cpVect u2;
        
        cpFloat constant;
        
        // Effective masses
        cpFloat pulleyMass;
        cpFloat limitMass1;
        cpFloat limitMass2;
        
        // Impulses for accumulation
        cpFloat jnAcc;
        cpFloat jnAccLim1;
        cpFloat jnAccLim2;
        
        // States are no fun... any way to get rid of this?
        int state;
        int limitState1;
        int limitState2;
    } cpPulleyJoint;
    
    cpPulleyJoint *cpPulleyJointAlloc(void);
    cpPulleyJoint *cpPulleyJointInit(cpPulleyJoint *joint,
                                     cpBody* a, cpBody* b, cpBody* c,
                                     cpVect anchor1, cpVect anchor2,
                                     cpVect anchor3a, cpVect anchor3b,
                                     cpFloat ratio);
    cpConstraint *cpPulleyJointNew(cpBody* a, cpBody* b, cpBody* c,
                                   cpVect anchor1, cpVect anchor2,
                                   cpVect anchor3a, cpVect anchor3b,
                                   cpFloat ratio);
    
    CP_DefineConstraintProperty(cpPulleyJoint, cpVect, anchr1, Anchr1);
    CP_DefineConstraintProperty(cpPulleyJoint, cpVect, anchr2, Anchr2);
    CP_DefineConstraintProperty(cpPulleyJoint, cpFloat, ratio, Ratio);
	
#ifdef __cplusplus
}
#endif

#endif //CPPULLEYJOINT_H
