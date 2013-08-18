	ABOUT:

SpaceManager is an Objective-C wrapper to Chipmunk with a slightly biased lean towards cocos2d-iphone. It's licensed under the unrestrictive, OSI approved MIT license. 

To be clear on the slight bias towards Cocos2d-iphone; this means that only SpaceManager.h/.m are independent of Cocos2d-iphone, the rest of the classes are meant as support for drawing cocos2d nodes on top of the corresponding chipmunk objects.

NOTE: SpaceManager will by default include support inside the class definition for Cocos2d-iphone. To clear this dependency look at the BUILDING section below;

Chipmunk is a simple, lightweight and fast 2D rigid body physics library written in C by Scott Lembcke

	BUILDING:

OS X: There is an included XCode project file for building the demo application with SpaceManager. To remove SpaceManager's dependency on Cocos2d-iphone take out the define for _SPACE_MANAGER_FOR_COCOS2D found in the SpaceManager.h file; this will mean you need to provide your own _iterateFunc to the SpaceManager if you want it to update your view;

	GETTING STARTED:

Documentation can be found in htmldoc/index.html

A good starting point is to take a look at the included Example application. The example uses cocos2d and an unreleased version (as of Sept '09) of chipmunk that has more extensive joint support.
	

Created by: Mobile Bros. www.mobile-bros.com

