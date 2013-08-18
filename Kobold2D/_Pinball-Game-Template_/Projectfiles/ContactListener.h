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

#import "Box2D.h"

@interface Contact : NSObject
{
@private
    __unsafe_unretained NSObject* otherObject;
    b2Fixture* ownFixture;
    b2Fixture* otherFixture;
    b2Contact* b2contact;
}
@property (assign, nonatomic) NSObject* otherObject;
@property (assign, nonatomic) b2Fixture* ownFixture;
@property (assign, nonatomic) b2Fixture* otherFixture;
@property (assign, nonatomic) b2Contact* b2contact;

+(id) contactWithObject:(NSObject*)otherObject
		   otherFixture:(b2Fixture*)otherFixture
			 ownFixture:(b2Fixture*)ownFixture
			  b2Contact:(b2Contact*)b2contact;

@end


class ContactListener : public b2ContactListener
{
private:
	void BeginContact(b2Contact* contact);
	void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);
	void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
	void EndContact(b2Contact* contact);

    void notifyObjects(b2Contact* contact, NSString* contactType);
    void notifyAB(b2Contact* contact,
				  NSString* contactType,
				  b2Fixture* fixtureA,
				  NSObject* objA,
				  b2Fixture* fixtureB,
				  NSObject* objB);
};