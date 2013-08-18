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

#import "ContactListener.h"
#import "BodyNode.h"

@implementation Contact

@synthesize otherObject, ownFixture, otherFixture, b2contact;

+(id) contactWithObject:(NSObject*)otherObject
		   otherFixture:(b2Fixture*)otherFixture
			 ownFixture:(b2Fixture*)ownFixture
			  b2Contact:(b2Contact*)b2contact
{
    Contact* contact = [[Contact alloc] init];
#ifndef KK_ARC_ENABLED
	[contact autorelease];
#endif // KK_ARC_ENABLED

    if (contact)
    {
        contact.otherObject = otherObject;
        contact.otherFixture = otherFixture;
        contact.ownFixture = ownFixture;
        contact.b2contact = b2contact;
    }
    
    return contact;
}

#ifndef KK_ARC_ENABLED
-(id) retain
{
	[NSException raise:@"ContactRetainException"
				format:@"Do not retain a Contact - it is for temporary use only!"];
	return self;
}
#endif // KK_ARC_ENABLED

@end


// notify the listener
void ContactListener::notifyAB(b2Contact* contact, 
							   NSString* contactType, 
							   b2Fixture* fixture,
							   NSObject* obj, 
							   b2Fixture* otherFixture, 
							   NSObject* otherObj)
{
	NSString* format = @"%@ContactWith%@:";
	NSString* otherClassName = NSStringFromClass([otherObj class]);
	NSString* selectorString = [NSString stringWithFormat:format, contactType, otherClassName];
	//CCLOG(@"notifyAB selector: %@", selectorString);
    SEL contactSelector = NSSelectorFromString(selectorString);

    if ([obj respondsToSelector:contactSelector])
    {
		//CCLOG(@"notifyAB performs selector: %@", selectorString);
        Contact* contactInfo = [Contact contactWithObject:otherObj
                                             otherFixture:otherFixture
                                               ownFixture:fixture
                                                b2Contact:contact];
		
		// without the following diagnostic pragmas, the enclosed line will cause a warning
		// in Xcode 4.2 with ARC enabled, see this link for details: 
		// http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
#if KK_ARC_ENABLED
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#endif // KK_ARC_ENABLED
        [obj performSelector:contactSelector withObject:contactInfo];
#if KK_ARC_ENABLED
#pragma clang diagnostic pop
#endif // KK_ARC_ENABLED
	}
}

void ContactListener::notifyObjects(b2Contact* contact, NSString* contactType)
{
    b2Fixture* fixtureA = contact->GetFixtureA();
    b2Fixture* fixtureB = contact->GetFixtureB();

    b2Body* bodyA = fixtureA->GetBody();
    b2Body* bodyB = fixtureB->GetBody();

    NSObject* objA = (__bridge NSObject*)bodyA->GetUserData();
    NSObject* objB = (__bridge NSObject*)bodyB->GetUserData();

    if ((objA != nil) && (objB != nil))
    {
        notifyAB(contact, contactType, fixtureA, objA, fixtureB, objB);
        notifyAB(contact, contactType, fixtureB, objB, fixtureA, objA);
    }
}

/// Called when two fixtures begin to touch.
void ContactListener::BeginContact(b2Contact* contact)
{
    notifyObjects(contact, @"begin");
}

/// Called when two fixtures cease to touch.
void ContactListener::EndContact(b2Contact* contact)
{
    notifyObjects(contact, @"end");
}

void ContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold)
{
	// do nothing (yet)
}

void ContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse)
{
	// do nothing (yet)
}
